using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using ManageLiteAV;
using TRTCCSharpDemo.Common;
using System.Threading;
using System.Runtime.InteropServices;

/// <summary>
/// Module： TRTCMainForm
/// 
/// Function： 使用TRTC SDK完成 1v1 和 1vn 的视频通话功能
/// 
/// Notice：
/// 1. 暂时只支持静态的的视频画面布局方式
///
/// 2. 支持对视频通话的分辨率、帧率和流畅模式进行调整，该部分由 TRTCSettingForm 来实现
///
/// 3. 创建或者加入某一个通话房间，需要先指定 roomid 和 userid，这部分由 TRTCLoginForm 来实现
/// </summary>

namespace TRTCCSharpDemo
{
    public partial class TRTCMainForm : Form, ITRTCCloudCallback, ITRTCLogCallback
    {
        private int mainThreadId;

        private string mUserId;
        private uint mRoomId;
        private ITRTCCloud mTRTCCloud;

        // 记录大小界面显示的是摄像头还是屏幕
        private IntPtr mCameraLocalVideo;
        private IntPtr mScreenLocalVideo;

        private bool mIsEnterSuccess;    // 是否进房成功
        private bool mIsSetScreenSuccess;   // 是否设置屏幕参数成功

        private List<UserVideoMeta> mMixStreamVideoMeta;   //混流信息
        private List<string> mRoomUsers;    // 当前房间里的远端用户（除了本地用户）

        private string mCurCameraDevice;
        private string mCurMicDevice;
        private string mCurSpeakerDevice;

        private int mLogLevel = 0;
        private TRTCLoginForm mLoginForm;
        private TRTCSettingForm mSettingForm;
        private TRTCBeautyForm mBeautyForm;
        private TRTCDeviceTestForm mDeviceTestForm;
        private TRTCDeviceForm mDeviceForm;

        private delegate void SetNetEnvDelegate(int bTestEnv);

        [DllImport("liteav.dll", CallingConvention = CallingConvention.Cdecl)]
        private static extern void setNetEnv(int bTestEnv);

        public TRTCMainForm(TRTCLoginForm loginForm)
        {
            InitializeComponent();

            this.Disposed += new EventHandler(OnDisposed);

            mLoginForm = loginForm;

            mTRTCCloud = ITRTCCloud.getTRTCShareInstance();
            Log.I(String.Format(" SDKVersion : {0}", mTRTCCloud.getSDKVersion()));
            mTRTCCloud.addCallback(this);
            mTRTCCloud.setLogCallback(this);
            mTRTCCloud.setConsoleEnabled(true);
            mTRTCCloud.setLogLevel(TRTCLogLevel.TRTCLogLevelVerbose);

            mMixStreamVideoMeta = new List<UserVideoMeta>();
            mRoomUsers = new List<string>();

            ThreadPool.RegisterWaitForSingleObject(Program.ProgramStarted, OnProgramStarted, null, -1, false);
        }

        // 这里需要回到 UI 线程进行操作
        private void OnProgramStarted(object state, bool timeout)
        {
            this.Invoke(new Action(() =>
            {
                if (this.IsHandleCreated)
                {
                    this.Show();
                    this.WindowState = FormWindowState.Normal; //注意：一定要在窗体显示后，再对属性进行设置
                    this.Activate();
                }
            }));
        }

        private void OnDisposed(object sender, EventArgs e)
        {
            // 清理资源
            mTRTCCloud = null;
            if (mCameraLocalVideo != IntPtr.Zero)
            {
                mCameraLocalVideo = IntPtr.Zero;
            }
            if (mScreenLocalVideo != IntPtr.Zero)
            {
                mScreenLocalVideo = IntPtr.Zero;
            }
        }

        private void OnFormLoad(object sender, EventArgs e)
        {
            mainThreadId = System.Threading.Thread.CurrentThread.ManagedThreadId;

            mCameraLocalVideo = this.localVideoPanel.Handle;
            mScreenLocalVideo = this.localVideoSmallPanel.Handle;
        }

        #region Form Move

        private bool mIsMouseDown = false;
        private Point mFormLocation;     // Form的location
        private Point mMouseOffset;      // 鼠标的按下位置

        private void OnFormMouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                mIsMouseDown = true;
                mFormLocation = this.Location;
                mMouseOffset = Control.MousePosition;
            }
        }

        private void OnFormMouseUp(object sender, MouseEventArgs e)
        {
            mIsMouseDown = false;
        }

        private void OnFormMouseMove(object sender, MouseEventArgs e)
        {
            if (mIsMouseDown)
            {
                Point pt = Control.MousePosition;
                int x = mMouseOffset.X - pt.X;
                int y = mMouseOffset.Y - pt.Y;

                this.Location = new Point(mFormLocation.X - x, mFormLocation.Y - y);
            }
        }

        #endregion

        public void SetTestEnv(int testEnv)
        {
            setNetEnv(testEnv);
        }

        private void ShowMessage(string text, int delay = 0)
        {
            this.BeginInvoke(new Action(() =>
            {
                MessageForm msgBox = new MessageForm();
                msgBox.setText(text, delay);
                msgBox.setCancelBtn(false);
                msgBox.ShowDialog();
            }));
        }

        private bool IsMainThread()
        {
            return System.Threading.Thread.CurrentThread.ManagedThreadId == mainThreadId;
        }

        public void EnterRoom(TRTCParams @params)
        {
            // 大画面的编码器参数设置
            // 设置视频编码参数，包括分辨率、帧率、码率等等，这些编码参数来自于 TRTCSettingViewController 的设置
            // 注意（1）：不要在码率很低的情况下设置很高的分辨率，会出现较大的马赛克
            // 注意（2）：不要设置超过25FPS以上的帧率，因为电影才使用24FPS，我们一般推荐15FPS，这样能将更多的码率分配给画质
            TRTCVideoEncParam encParams = PropertySaver.GetInstance().encParams;
            TRTCNetworkQosParam qosParams = PropertySaver.GetInstance().qosParams;
            mTRTCCloud.setVideoEncoderParam(ref encParams);
            mTRTCCloud.setNetworkQosParam(ref qosParams);

            bool pushSmallVideo = PropertySaver.GetInstance().pushSmallVideo;
            bool playSmallVideo = PropertySaver.GetInstance().playSmallVideo;

            if(pushSmallVideo)
            {
                //小画面的编码器参数设置
                //TRTC SDK 支持大小两路画面的同时编码和传输，这样网速不理想的用户可以选择观看小画面
                //注意：iPhone & Android 不要开启大小双路画面，非常浪费流量，大小路画面适合 Windows 和 MAC 这样的有线网络环境
                TRTCVideoEncParam param = new TRTCVideoEncParam
                {
                    videoFps = 15,
                    videoBitrate = 100,
                    videoResolution = TRTCVideoResolution.TRTCVideoResolution_320_240
                };
                mTRTCCloud.enableSmallVideoStream(pushSmallVideo, ref param);
            }
            if(playSmallVideo)
            {
                mTRTCCloud.setPriorRemoteVideoStreamType(TRTCVideoStreamType.TRTCVideoStreamTypeSmall);
            }
            mTRTCCloud.enterRoom(ref @params, PropertySaver.GetInstance().appScene);
            mUserId = @params.userId;
            mRoomId = @params.roomId;
            this.roomLabel.Text = "房间号：" + @params.roomId.ToString() + "   用户名：" + @params.userId;
            this.localUserLabel.Text = mUserId;

            mTRTCCloud.setLocalViewFillMode(TRTCVideoFillMode.TRTCVideoFillMode_Fit);
            mTRTCCloud.startLocalPreview(mCameraLocalVideo);
            mTRTCCloud.startLocalAudio();
            InitDevice();
        }

        public void onEnterRoom(int result)
        {
            // 回调后的线程不一定在主线程，如果在回调后需要进行 UI 操作，则最好判断一下是否是主线程，其他回调皆是。
            if (IsMainThread())
                OnEnterRoom(result);
            else
                this.BeginInvoke(new Action(() => {
                    OnEnterRoom(result);
                }));
            
        }
        
        private void OnEnterRoom(int result)
        {
            UpdateMixTranCodeInfo();
            if (result >= 0)
            {
                mIsEnterSuccess = true;
                Log.I(String.Format("network timeout = {0}", result));
            }
            else
            {
                mIsEnterSuccess = false;
                ShowMessage("进房失败，请重试");
                Log.E(String.Format("onEnterRoom : enterRoom failed."));
            }
        }

        private void InitDevice()
        {
            ITRTCDeviceCollection cameraList = mTRTCCloud.getCameraDevicesList();
            if (cameraList.getCount() <= 0)
                ShowMessage("Error: 未检出到摄像头，请检查本地电脑设备。");
            else
            {
                ITRTCDeviceInfo camera = mTRTCCloud.getCurrentCameraDevice();
                mCurCameraDevice = camera.getDeviceName();
            }
            cameraList.release();
            
            ITRTCDeviceCollection micList = mTRTCCloud.getMicDevicesList();
            if (micList.getCount() <= 0)
                ShowMessage("Error: 未检出到麦克风，请检查本地电脑设备。");
            else
            {
                ITRTCDeviceInfo mic = mTRTCCloud.getCurrentMicDevice();
                mCurMicDevice = mic.getDeviceName();
            }
            micList.release();
            ITRTCDeviceCollection speakerList = mTRTCCloud.getSpeakerDevicesList();
            if (speakerList.getCount() <= 0)
                ShowMessage("Error: 未检出到扬声器，请检查本地电脑设备。");
            else
            {
                ITRTCDeviceInfo speaker = mTRTCCloud.getCurrentSpeakerDevice();
                mCurSpeakerDevice = speaker.getDeviceName();
            }
            speakerList.release();
        }

        public void onError(TXLiteAVError errCode, string errMsg, IntPtr arg)
        {
            Log.E(String.Format("errCode : {0}, errMsg : {1}, arg = {2}", errCode, errMsg, arg));
            if (errCode == TXLiteAVError.ERR_SERVER_CENTER_ANOTHER_USER_PUSH_SUB_VIDEO || 
                errCode == TXLiteAVError.ERR_SERVER_CENTER_NO_PRIVILEDGE_PUSH_SUB_VIDEO || 
                errCode == TXLiteAVError.ERR_SERVER_CENTER_INVALID_PARAMETER_SUB_VIDEO)
            {
                ShowMessage("Error: 屏幕分享发起失败，是否当前已经有人发起了共享！");
            }
            else
            {
                ShowMessage(String.Format("SDK出错[err:{0},msg:{1}]", errCode, errMsg));
            }
        }

        public void onExitRoom(int reason)
        {
            Log.I(String.Format("reason : {0}", reason));
            mIsEnterSuccess = false;
            Uninit();
            this.Close();
        }

        private void Uninit()
        {
            mMixStreamVideoMeta.Clear();
            mRoomUsers.Clear();
            mTRTCCloud.removeCallback(this);
            mTRTCCloud.setLogCallback(null);
            if (this.systemAudioCheckBox.Checked)
                mTRTCCloud.stopSystemAudioLoopback();
            if (this.screenShareCheckBox.Checked)
                mTRTCCloud.stopScreenCapture();
            if (this.systemAudioCheckBox.Checked)
                mTRTCCloud.stopSystemAudioLoopback();
            if (this.mixTransCodingCheckBox.Checked)
                mTRTCCloud.setMixTranscodingConfig(null);
        }

        public void onUserAudioAvailable(string userId, bool available)
        {
            Log.I(String.Format("onUserAudioAvailable : userId = {0}, available = {1}", userId, available));
            if (available)
            {
                mTRTCCloud.muteRemoteAudio(userId, false);
            }
            else
            {
                mTRTCCloud.muteRemoteAudio(userId, true);
            }
        }

        // 不推荐在此回调中显示远端视频画面，推荐使用 onUserVideoAvailable 
        public void onUserEnter(string userId)
        {
            Log.I(String.Format("onUserEnter : userId = {0}", userId));
            mRoomUsers.Add(userId);
        }

        private IntPtr GetHandleAndSetUserId(int pos, string userId, bool isOpenSubStream)
        {
            switch(pos)
            {
                case 1:
                    this.remoteUserLabel1.Text = userId + (isOpenSubStream ? "(屏幕分享)" : "");
                    return this.remoteVideoPanel1.Handle;
                case 2:
                    this.remoteUserLabel2.Text = userId + (isOpenSubStream ? "(屏幕分享)" : "");
                    return this.remoteVideoPanel2.Handle;
                case 3:
                    this.remoteUserLabel3.Text = userId + (isOpenSubStream ? "(屏幕分享)" : "");
                    return this.remoteVideoPanel3.Handle;
                case 4:
                    this.remoteUserLabel4.Text = userId + (isOpenSubStream ? "(屏幕分享)" : "");
                    return this.remoteVideoPanel4.Handle;
                case 5:
                    this.remoteUserLabel5.Text = userId + (isOpenSubStream ? "(屏幕分享)" : "");
                    return this.remoteVideoPanel5.Handle;
                default:
                    return IntPtr.Zero;
            }
        }

        private int GetRemoteVIdeoPosition(String userId)
        {
            if (this.remoteUserLabel1.Text.Equals(userId))
                return 1;
            else if (this.remoteUserLabel2.Text.Equals(userId))
                return 2;
            else if (this.remoteUserLabel3.Text.Equals(userId))
                return 3;
            else if (this.remoteUserLabel4.Text.Equals(userId))
                return 4;
            else if (this.remoteUserLabel5.Text.Equals(userId))
                return 5;
            return -1;
        }
        
        private int GetIdleRemoteVideoPosition(String userId)
        {
            if (string.IsNullOrEmpty(this.remoteUserLabel1.Text) || this.remoteUserLabel1.Text.Equals(userId))
                return 1;
            else if (string.IsNullOrEmpty(this.remoteUserLabel2.Text) || this.remoteUserLabel2.Text.Equals(userId))
                return 2;
            else if (string.IsNullOrEmpty(this.remoteUserLabel3.Text) || this.remoteUserLabel3.Text.Equals(userId))
                return 3;
            else if (string.IsNullOrEmpty(this.remoteUserLabel4.Text) || this.remoteUserLabel4.Text.Equals(userId))
                return 4;
            else if (string.IsNullOrEmpty(this.remoteUserLabel5.Text) || this.remoteUserLabel5.Text.Equals(userId))
                return 5;
            return -1;
        }

        public void onUserExit(string userId, int reason)
        {
            Log.I(String.Format("onUserExit : userId = {0}, reason = {1}", userId, reason));
            if (IsMainThread())
                OnUserExit(userId, reason);
            else
                this.BeginInvoke(new Action(() => {
                    OnUserExit(userId, reason);
                }));
        }

        private void OnUserExit(string userId, int reason)
        {
            foreach (string user in mRoomUsers)
            {
                if (user.Equals(userId))
                {
                    mRoomUsers.Remove(user);
                    break;
                }
            }
            int pos = FindOccupyRemoteVideoPosition(userId, true);
            if (pos != -1)
            {
                mTRTCCloud.stopRemoteView(userId);
                mTRTCCloud.stopRemoteSubStreamView(userId);
            }
        }

        private int FindOccupyRemoteVideoPosition(string userId, bool isExitRoom)
        {
            int pos = -1;
            if(this.remoteUserLabel1.Text.Equals(userId))
            {
                pos = 1;
                if (isExitRoom)
                    this.remoteUserLabel1.Text = "";
            }
            if(this.remoteUserLabel2.Text.Equals(userId))
            {
                pos = 2;
                if (isExitRoom)
                    this.remoteUserLabel2.Text = "";
            }
            if (this.remoteUserLabel3.Text.Equals(userId))
            {
                pos = 3;
                if (isExitRoom)
                    this.remoteUserLabel3.Text = "";
            }
            if (this.remoteUserLabel4.Text.Equals(userId))
            {
                pos = 4;
                if (isExitRoom)
                    this.remoteUserLabel4.Text = "";
            }
            if (this.remoteUserLabel5.Text.Equals(userId))
            {
                pos = 5;
                if (isExitRoom)
                    this.remoteUserLabel5.Text = "";
            }
            if(isExitRoom) 
                SetVisableInfoView(pos, false);
            return pos;
        }

        public void onUserSubStreamAvailable(string userId, bool available)
        {
            Log.I(String.Format("onUserSubStreamAvailable : userId = {0}, available = {1}", userId, available));
            if (IsMainThread())
                OnUserSubStreamAvailable(userId, available);
            else
                this.BeginInvoke(new Action(() => {
                    OnUserSubStreamAvailable(userId, available);
                }));
        }

        private void OnUserSubStreamAvailable(string userId, bool available)
        {
            if (available)
            {
                // 显示远端辅流界面
                int pos = GetIdleRemoteVideoPosition(userId + "(屏幕分享)");
                if (pos != -1)
                {
                    IntPtr ptr = GetHandleAndSetUserId(pos, userId, true);
                    SetVisableInfoView(pos, false);
                    mTRTCCloud.setRemoteSubStreamViewFillMode(userId, TRTCVideoFillMode.TRTCVideoFillMode_Fit);
                    mTRTCCloud.startRemoteSubStreamView(userId, ptr);
                }
            }
            else
            {
                int pos = FindOccupyRemoteVideoPosition(userId + "(屏幕分享)", true);
                if (pos != -1)
                {
                    mTRTCCloud.stopRemoteSubStreamView(userId);
                    RemoveVideoMeta(userId, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
                    UpdateMixTranCodeInfo();
                }
            }
        }

        public void onUserVideoAvailable(string userId, bool available)
        {
            Log.I(String.Format("onUserVideoAvailable : userId = {0}, available = {1}", userId, available));
            if (IsMainThread())
                OnUserVideoAvailable(userId, available);
            else
                this.BeginInvoke(new Action(() =>
                {
                    OnUserVideoAvailable(userId, available);
                }));
        }

        private void OnUserVideoAvailable(string userId, bool available)
        {
            bool isExit = mRoomUsers.Exists((user) =>
            {
                if (user.Equals(userId)) return true;
                else return false;
            });
            if (!isExit) return;
            if (available)
            {
                int pos = GetIdleRemoteVideoPosition(userId);
                if (pos != -1)
                {
                    IntPtr ptr = GetHandleAndSetUserId(pos, userId, false);
                    SetVisableInfoView(pos, false);
                    mTRTCCloud.setRemoteViewFillMode(userId, TRTCVideoFillMode.TRTCVideoFillMode_Fit);
                    mTRTCCloud.startRemoteView(userId, ptr);
                }
            }
            else
            {
                int pos = GetRemoteVIdeoPosition(userId);
                if (pos != -1)
                {
                    SetVisableInfoView(pos, true);
                    mTRTCCloud.stopRemoteView(userId);
                    RemoveVideoMeta(userId, TRTCVideoStreamType.TRTCVideoStreamTypeBig);
                    UpdateMixTranCodeInfo();
                }
            }
        }

        private void SetVisableInfoView(int pos, bool visable)
        {
            switch(pos)
            {
                case 1:
                    this.remoteInfoLabel1.Visible = visable;
                    break;
                case 2:
                    this.remoteInfoLabel2.Visible = visable;
                    break;
                case 3:
                    this.remoteInfoLabel3.Visible = visable;
                    break;
                case 4:
                    this.remoteInfoLabel4.Visible = visable;
                    break;
                case 5:
                    this.remoteInfoLabel5.Visible = visable;
                    break;
            }
        }

        private void OnExitLabelClick(object sender, EventArgs e)
        {
            if (mBeautyForm != null)
                mBeautyForm.Close();
            if (mDeviceTestForm != null)
                mDeviceTestForm.Close();
            if (mSettingForm != null)
                mSettingForm.Close();
            if (mDeviceForm != null)
                mDeviceForm.Close();
            PreUninit();
            // 两种情况：1. 进房成功后需要退房，所以把清理资源放入 onExitRoom中；2. 进房失败后退出直接清理资源并退出。
            if (mIsEnterSuccess)
            {
                mTRTCCloud.exitRoom();
                this.Hide();
            }
            else
            {
                Uninit();
                this.Close();
            }
            if (mLoginForm == null)
            {
                mLoginForm = new TRTCLoginForm();
            }
            mLoginForm.Show();
        }

        private void PreUninit()
        {
            mTRTCCloud.stopAllRemoteView();
            mTRTCCloud.stopLocalPreview();
            mTRTCCloud.stopLocalAudio();
            mTRTCCloud.muteLocalAudio(true);
            mTRTCCloud.muteLocalVideo(true);
        }

        private void OnSettingLabelClick(object sender, EventArgs e)
        {
            if(mSettingForm == null)
            {
                mSettingForm = new TRTCSettingForm(mTRTCCloud);
            }
            mSettingForm.ShowDialog();
        }

        private void OnLogLabelClick(object sender, EventArgs e)
        {
            mLogLevel++;
            int style = mLogLevel % 3;
            if(mTRTCCloud != null)
            {
                mTRTCCloud.showDebugView(style);
            }
        }

        private void OnLocalVideoSmallPanelClick(object sender, EventArgs e)
        {
            if(this.localVideoSmallPanel.Visible == true && mIsEnterSuccess)
            {
                // 切换主流与辅流的画面
                IntPtr temp;
                temp = mCameraLocalVideo;
                mCameraLocalVideo = mScreenLocalVideo;
                mScreenLocalVideo = temp;
                // 这里切换窗口句柄时无需调用 stopScreenCapture 来进行切换，但需要调用 stopLocalPreview 
                mTRTCCloud.stopLocalPreview();
                mTRTCCloud.startScreenCapture(mScreenLocalVideo);
                mTRTCCloud.startLocalPreview(mCameraLocalVideo);
            }
        }

        public void onLog(string log, TRTCLogLevel level, string module)
        {
            Log.I(String.Format("onLog : log = {0}, level = {1}, module = {2}", log, level, module));
        }

        public void onFirstVideoFrame(string userId, TRTCVideoStreamType streamType, int width, int height)
        {
            Log.I(String.Format("onFirstVideoFrame : userId = {0}, TRTCVideoStreamType = {1}, width = {2}, height = {3}", userId, streamType, width, height));
            if (!this.screenShareCheckBox.Checked)
            {
                if (string.IsNullOrEmpty(userId) && streamType == TRTCVideoStreamType.TRTCVideoStreamTypeSub)
                    return;
            }
            if (!string.IsNullOrEmpty(userId))
            {
                // 暂时只支持最多6个人同时视频
                if (streamType == TRTCVideoStreamType.TRTCVideoStreamTypeBig && FindOccupyRemoteVideoPosition(userId, false) == -1 )
                    return;
                if (streamType == TRTCVideoStreamType.TRTCVideoStreamTypeSub && FindOccupyRemoteVideoPosition(userId + "(屏幕分享)", false) == -1)
                    return;
            }
            if (string.IsNullOrEmpty(userId)) userId = mUserId;
            bool find = false;
            foreach (UserVideoMeta info in mMixStreamVideoMeta)
            {
                if (info.userId.Equals(userId) && info.streamType == streamType)
                {
                    info.width = width;
                    info.height = height;
                    find = true;
                    break;
                }
            }
            if (!find && !(streamType == TRTCVideoStreamType.TRTCVideoStreamTypeBig && userId == mUserId))
            {
                UserVideoMeta info = new UserVideoMeta();
                info.streamType = streamType;
                info.userId = userId;
                info.width = width;
                info.height = height;
                mMixStreamVideoMeta.Add(info);
                UpdateMixTranCodeInfo();
            }
            else
            {
                if (userId != mUserId)
                    UpdateMixTranCodeInfo();
            }
        }

        public void onFirstAudioFrame(string userId)
        {
            Log.I(String.Format("onFirstAudioFrame : userId = {0}", userId));
        }

        public void onSendFirstLocalVideoFrame(TRTCVideoStreamType streamType)
        {
            Log.I(String.Format("onSendFirstLocalVideoFrame : streamType = {0}", streamType));
        }

        public void onSendFirstLocalAudioFrame()
        {
            Log.I(String.Format("onSendFirstLocalAudioFrame"));
        }

        private void OnScreenShareCheckBoxClick(object sender, EventArgs e)
        {
            if (!mIsEnterSuccess)
            {
                ShowMessage("进房失败，请重试");
                this.screenShareCheckBox.Checked = false;
                return;
            }
            if (this.screenShareCheckBox.Checked)
            {
                // 开启屏幕分享功能
                TRTCScreenForm screenForm = new TRTCScreenForm(mTRTCCloud, this);
                screenForm.ShowDialog();
            }
            else
            {
                // 关闭屏幕分享功能
                if (!mIsSetScreenSuccess) return;
                this.localVideoSmallPanel.Visible = false;
                mTRTCCloud.stopScreenCapture();
                if(mScreenLocalVideo == this.localVideoPanel.Handle)
                {
                    mCameraLocalVideo = this.localVideoPanel.Handle;
                    mScreenLocalVideo = this.localVideoSmallPanel.Handle;
                }
                // 视频出现白边，重新加载
                mTRTCCloud.stopLocalPreview();
                mTRTCCloud.startLocalPreview(mCameraLocalVideo);

                // 移除混流中的屏幕分享画面
                RemoveVideoMeta(mUserId, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
                UpdateMixTranCodeInfo();
            }
        }

        private void OnMixTransCodingCheckBoxClick(object sender, EventArgs e)
        {
            if (!mIsEnterSuccess)
            {
                ShowMessage("进房失败，请重试");
                this.mixTransCodingCheckBox.Checked = false;
                return;
            }
            if (this.mixTransCodingCheckBox.Checked)
            {
                // 开启云端画面混合功能
                UpdateMixTranCodeInfo();
            }
            else
            {
                // 关闭与那段画面混合功能
                mTRTCCloud.setMixTranscodingConfig(null);
            }
        }

        private void RemoveVideoMeta(string userId, TRTCVideoStreamType streamType)
        {
            foreach (UserVideoMeta info in mMixStreamVideoMeta)
            {
                if (info.userId == userId && info.streamType == streamType)
                {
                    mMixStreamVideoMeta.Remove(info);
                    break;
                }
            }
        }

        private void UpdateMixTranCodeInfo()
        {
            if (!this.mixTransCodingCheckBox.Checked)
                return;

            if (mMixStreamVideoMeta.Count == 0)
            {
                mTRTCCloud.setMixTranscodingConfig(null);
                return;
            }

            if (this.muteVideoCheckBox.Checked)
            {
                foreach (UserVideoMeta info in mMixStreamVideoMeta)
                    info.pureAudio = true;
            }

            UserVideoMeta localMainVideo = new UserVideoMeta()
            {
                userId = mUserId
            };
            // 连麦后的User可进行设置对应的roomId（暂时未完成连麦）

            int canvasWidth = 960, canvasHeight = 720;
            int appId = GenerateTestUserSig.APPID;
            int bizId = GenerateTestUserSig.BIZID;

            if (appId == 0 || bizId == 0)
            {
                ShowMessage("混流功能不可使用，请在TRTCGetUserIDAndUserSig.h->TXCloudAccountInfo填写混流的账号信息\n");
                return;
            }
            TRTCTranscodingConfig config = new TRTCTranscodingConfig();
            config.mode = TRTCTranscodingConfigMode.TRTCTranscodingConfigMode_Manual;
            config.appId = (uint)appId;
            config.bizId = (uint)bizId;
            config.videoWidth = (uint)canvasWidth;
            config.videoHeight = (uint)canvasHeight;
            config.videoBitrate = 800;
            config.videoFramerate = 15;
            config.videoGOP = 1;
            config.audioSampleRate = 48000;
            config.audioBitrate = 64;
            config.audioChannels = 1;
            config.mixUsersArraySize = (uint)(1 + mMixStreamVideoMeta.Count);
            TRTCMixUser[] mixUsersArray = new TRTCMixUser[config.mixUsersArraySize];
            for (int i = 0; i < config.mixUsersArraySize; i++)
                mixUsersArray[i] = new TRTCMixUser();

            int zOrder = 1, index = 0;
            mixUsersArray[index].roomId = null;
            mixUsersArray[index].userId = localMainVideo.userId;
            mixUsersArray[index].pureAudio = localMainVideo.pureAudio;
            RECT rect = new RECT()
            {
                left = 0,
                top = 0,
                right = canvasWidth,
                bottom = canvasHeight
            };
            mixUsersArray[index].rect = rect;
            mixUsersArray[index].streamType = localMainVideo.streamType;
            mixUsersArray[index].zOrder = zOrder++;
            index++;
            Log.I(string.Format("mMixStreamVideoMeta : length = {0}", mMixStreamVideoMeta.Count));
            foreach (UserVideoMeta info in mMixStreamVideoMeta)
            {
                Log.I(String.Format("mMixStreamVideoMeta : userId = {0}, streamType = {1}", info.userId, info.streamType));
            }
            foreach (UserVideoMeta info in mMixStreamVideoMeta)
            {
                int left = 20, top = 40;

                if (zOrder == 2)
                {
                    left = 240 / 4 * 3 + 240 * 2;
                    top = 240 / 3 * 1;
                }
                if (zOrder == 3)
                {
                    left = 240 / 4 * 3 + 240 * 2;
                    top = 240 / 3 * 2 + 240 * 1;
                }
                if (zOrder == 4)
                {
                    left = 240 / 4 * 2 + 240 * 1;
                    top = 240 / 3 * 1;
                }
                if (zOrder == 5)
                {
                    left = 240 / 4 * 2 + 240 * 1;
                    top = 240 / 3 * 2 + 240 * 1;
                }
                if (zOrder == 6)
                {
                    left = 240 / 4 * 1;
                    top = 240 / 3 * 1;
                }
                if (zOrder == 7)
                {
                    left = 240 / 4 * 1;
                    top = 240 / 3 * 2 + 240 * 1;
                }

                int right = 240 + left, bottom = 240 + top;
                if (info.roomId.CompareTo("") == 0)
                    mixUsersArray[index].roomId = null;
                else
                    mixUsersArray[index].roomId = info.roomId;
                mixUsersArray[index].userId = info.userId;
                mixUsersArray[index].pureAudio = info.pureAudio;
                RECT rt = new RECT()
                {
                    left = left,
                    top = top,
                    right = right,
                    bottom = bottom
                };
                mixUsersArray[index].rect = rt;
                mixUsersArray[index].streamType = info.streamType;
                mixUsersArray[index].zOrder = zOrder;
                zOrder++;
                index++;
            }
            config.mixUsersArray = mixUsersArray;
            mTRTCCloud.setMixTranscodingConfig(config);
        }

        private void OnMuteAudioCheckBoxClick(object sender, EventArgs e)
        {
            if (!mIsEnterSuccess)
            {
                ShowMessage("进房失败，请重试");
                this.muteAudioCheckBox.Checked = false;
                return;
            }
            if (this.muteAudioCheckBox.Checked)
            {
                // 静音本地的音频
                mTRTCCloud.muteLocalAudio(true);
            }
            else
            {
                // 开启本地的音频
                mTRTCCloud.muteLocalAudio(false);
            }
        }

        private void OnMuteVideoCheckBoxClick(object sender, EventArgs e)
        {
            if (!mIsEnterSuccess)
            {
                ShowMessage("进房失败，请重试");
                this.muteVideoCheckBox.Checked = false;
                return;
            }
            if (!this.muteVideoCheckBox.Checked)
            {
                // 开启本地视频画面
                mTRTCCloud.muteLocalVideo(false);
                // 视频出现白边，重新加载
                mTRTCCloud.startLocalPreview(mCameraLocalVideo);
                if (this.screenShareCheckBox.Checked)
                {
                    this.localVideoSmallPanel.Visible = true;
                    mTRTCCloud.resumeScreenCapture();
                }
                this.localInfoLabel.Visible = false;
            }
            else
            {
                // 屏蔽本地视频画面
                this.localInfoLabel.Visible = true;
                mTRTCCloud.muteLocalVideo(true);
                // 视频出现白边，重新加载
                mTRTCCloud.stopLocalPreview();
                if (this.screenShareCheckBox.Checked)
                {
                    this.localVideoSmallPanel.Visible = false;
                    mTRTCCloud.pauseScreenCapture();
                }
            }
        }

        private void OnMirrorCheckBoxClick(object sender, EventArgs e)
        {
            if (!mIsEnterSuccess)
            {
                ShowMessage("进房失败，请重试");
                this.mirrorCheckBox.Checked = false;
                return;
            }
            if (this.mirrorCheckBox.Checked)
            {
                mTRTCCloud.setVideoEncoderMirror(true);
                mTRTCCloud.setLocalViewMirror(true);
            }
            else
            {
                mTRTCCloud.setVideoEncoderMirror(false);
                mTRTCCloud.setLocalViewMirror(false);
            }
        }

        private void OnDeviceLabelClick(object sender, EventArgs e)
        {
            if (mDeviceForm == null)
                mDeviceForm = new TRTCDeviceForm(mTRTCCloud, this);
            mDeviceForm.ShowDialog();
        }

        private void OnShareUrlLabelClick(object sender, EventArgs e)
        {
            if (!this.mixTransCodingCheckBox.Checked)
            {
                ShowMessage("请勾选云端混流选项！");
                return;
            }
            // 计算 CDN 地址(格式： http://[bizid].liveplay.myqcloud.com/live/[bizid]_[streamid].flv )
            int bizId = GenerateTestUserSig.BIZID;
            // streamid = MD5 (房间号_用户名_流类型)
            string streamId = Util.MD5(String.Format("{0}_{1}_{2}", mRoomId, Util.UTF16To8(mUserId), "main"));
            string shareUrl = String.Format("http://{0}.liveplay.myqcloud.com/live/{0}_{1}.flv", bizId, streamId);
            Log.I("播放地址： " + shareUrl);
            Clipboard.SetDataObject(shareUrl);
            ShowMessage("播放地址：（已复制到剪切板）\n" + shareUrl);
        }

        private void OnTestDeviceLabelClick(object sender, EventArgs e)
        {
            if (mDeviceTestForm == null)
                mDeviceTestForm = new TRTCDeviceTestForm(mTRTCCloud);
            mDeviceTestForm.ShowDialog();
        }

        private void OnBeautyLabelClick(object sender, EventArgs e)
        {
            if (!mIsEnterSuccess)
            {
                ShowMessage("进房失败，请重试");
                return;
            }
            if (mBeautyForm == null)
                mBeautyForm = new TRTCBeautyForm(mTRTCCloud);
            mBeautyForm.ShowDialog();
        }

        private void OnSystemAudioCheckBoxClick(object sender, EventArgs e)
        {
            if (!mIsEnterSuccess)
            {
                ShowMessage("进房失败，请重试");
                this.systemAudioCheckBox.Checked = false;
                return;
            }
            if (this.systemAudioCheckBox.Checked)
            {
                // 这里直接采集操作系统的播放声音，如需采集个别软件的声音请填写对应 exe 的路径。
                mTRTCCloud.startSystemAudioLoopback(null);
            }
            else
            {
                mTRTCCloud.stopSystemAudioLoopback();
            }
        }

        public void onUserVoiceVolume(TRTCVolumeInfo[] userVolumes, uint userVolumesCount, uint totalVolume)
        {
            Log.I(String.Format("onUserVoiceVolume : userVolumes = {0}, userVolumesCount = {1}, totalVolume = {2}", userVolumes, userVolumesCount, totalVolume));
        }

        public void onWarning(TXLiteAVWarning warningCode, string warningMsg, IntPtr arg)
        {
            Log.I(String.Format("warningCode : {0}, warningMsg : {1}", warningCode, warningMsg));
        }

        public void onCameraDidReady()
        {
            Log.I(String.Format("onCameraDidReady"));
            mCurCameraDevice = mTRTCCloud.getCurrentCameraDevice().getDeviceName();
        }

        public void onConnectionLost()
        {
            Log.I(String.Format("onConnectionLost"));
            ShowMessage("网络异常，请重试");
        }

        public void onTryToReconnect()
        {
            Log.I(String.Format("onTryToReconnect"));
            ShowMessage("尝试重进房...");
        }

        public void onConnectionRecovery()
        {
            Log.I(String.Format("onConnectionRecovery"));
            ShowMessage("网络恢复，重进房成功");
        }

        public void onConnectOtherRoom(string userId, TXLiteAVError errCode, string errMsg)
        {
            Log.I(String.Format("onConnectOtherRoom : userId = {0}, errCode = {1}, errMsg = {2}", userId, errCode, errMsg));
        }

        public void OnCameraDeviceChange(string deviceName)
        {
            mCurCameraDevice = deviceName;
        }

        public void OnMicDeviceChange(string deviceName)
        {
            mCurMicDevice = deviceName;
        }

        public void OnSpeakerDeviceChange(string deviceName)
        {
            mCurSpeakerDevice = deviceName;
        }

        public void onDeviceChange(string deviceId, TRTCDeviceType type, TRTCDeviceState state)
        {
            Log.I(String.Format("onDeviceChange : deviceId = {0}, type = {1}, state = {2}", deviceId, type, state));
            if (type == TRTCDeviceType.TRTCDeviceTypeCamera)
            {
                this.BeginInvoke(new Action(() =>
                {
                    RefreshVideoDevice(deviceId, state);
                }));
                
            }
            else if (type == TRTCDeviceType.TRTCDeviceTypeMic)
            {
                this.BeginInvoke(new Action(() =>
                {
                    RefreshAudioDevice(deviceId, state);
                }));
            }
            this.BeginInvoke(new Action(() =>
            {
                if (mDeviceForm != null)
                    mDeviceForm.OnDeviceChange(deviceId, type, state);
            }));
        }

        private void RefreshVideoDevice(string deviceId, TRTCDeviceState state)
        {
            bool reSelectDevice = false;
            
            if (state == TRTCDeviceState.TRTCDeviceStateRemove)
            {
                // 选择设备被移除了，此时可能还有其他设备
                if (mCurCameraDevice.Equals(deviceId))
                {
                    reSelectDevice = true;
                }
                // 有设备变成没设备
                if (!string.IsNullOrEmpty(mCurCameraDevice) && mTRTCCloud.getCameraDevicesList().getCount() <= 0)
                {
                    ShowMessage("Error: 未检出到摄像头，请检查本地电脑设备。");
                    Log.I("Error: 未检出到摄像头，请检查本地电脑设备。");
                    mCurCameraDevice = "";
                    return;
                }
            }
            else if (state == TRTCDeviceState.TRTCDeviceStateAdd)
            {
                // 没有设备变成有设备
                if (string.IsNullOrEmpty(mCurCameraDevice))
                {
                    reSelectDevice = true;
                }
            }

            if (reSelectDevice)
            {
                // 选择第一个设备为当前使用设备
                ITRTCDeviceCollection collection = mTRTCCloud.getCameraDevicesList();
                if (collection.getCount() > 0)
                {
                    mTRTCCloud.setCurrentCameraDevice(collection.getDevicePID(0));
                    mTRTCCloud.startLocalPreview(mCameraLocalVideo);
                    mCurCameraDevice = collection.getDeviceName(0);
                }
                collection.release();
            }
        }

        private void RefreshAudioDevice(string deviceId, TRTCDeviceState state)
        {
            bool reSelectDevice = false;
            ITRTCDeviceCollection collection = mTRTCCloud.getMicDevicesList();
            if (state == TRTCDeviceState.TRTCDeviceStateRemove)
            {
                // 选择设备被移除了，此时可能还有其他设备
                if (mCurMicDevice.Equals(deviceId))
                {
                    reSelectDevice = true;
                }
                // 有设备变成没设备
                if (!string.IsNullOrEmpty(mCurMicDevice) && collection.getCount() <= 0)
                {
                    ShowMessage("Error: 未检出到麦克风，请检查本地电脑设备。");
                    Log.I("Error: 未检出到麦克风，请检查本地电脑设备。");
                    mCurMicDevice = "";
                    return;
                }
            }
            else if (state == TRTCDeviceState.TRTCDeviceStateAdd)
            {
                // 没有设备变成有设备
                if (string.IsNullOrEmpty(mCurMicDevice))
                {
                    reSelectDevice = true;
                }
            }

            if (reSelectDevice)
            {
                // 选择第一个设备为当前使用设备
                if (collection.getCount() > 0)
                {
                    mTRTCCloud.setCurrentMicDevice(collection.getDevicePID(0));
                    mTRTCCloud.startLocalAudio();
                    mCurMicDevice = collection.getDeviceName(0);
                }
            }
            collection.release();
        }

        public void onDisconnectOtherRoom(TXLiteAVError errCode, string errMsg)
        {
            Log.I(String.Format("onDisconnectOtherRoom : errCode = {0}, errmsg = {1}", errCode, errMsg));
        }

        public void onMicDidReady()
        {
            Log.I(String.Format("onMicDidReady"));
            mCurMicDevice = mTRTCCloud.getCurrentMicDevice().getDeviceName();
        }

        public void onMissCustomCmdMsg(string userId, int cmdId, int errCode, int missed)
        {
            Log.I(String.Format("onMissCustomCmdMsg : userId = {0}, cmdId = {1}, errCode = {2}, missed = {3}", userId, cmdId, errCode, missed));
        }

        public void onPlayBGMBegin(TXLiteAVError errCode)
        {
            Log.I(String.Format("onPlayBGMBegin : errCode = {0}", errCode));
        }

        public void onPlayBGMComplete(TXLiteAVError errCode)
        {
            Log.I(String.Format("onPlayBGMComplete : errCode = {0}", errCode));
        }

        public void onPlayBGMProgress(uint progressMS, uint durationMS)
        {
            Log.I(String.Format("onPlayBGMProgress : progressMs = {0}, durationMS = {1}", progressMS, durationMS));
        }

        public void onRecvCustomCmdMsg(string userId, int cmdId, uint seq, byte[] msg, uint msgSize)
        {
            Log.I(String.Format("onRecvCustomCmdMsg : userId = {0}, cmdId = {1}, seq = {2}, msg = {3}, msgSize = {4}", userId, cmdId, seq, msg, msgSize));
        }

        public void onRecvSEIMsg(string userId, byte[] message, uint msgSize)
        {
            Log.I(String.Format("onRecvSEIMsg : userId = {0}, message = {1}, msgSize = {2}", userId, message, msgSize));
        }

        public void onScreenCaptureCovered()
        {
            Log.I(String.Format("onScreenCaptureCovered"));
        }

        public void onScreenCapturePaused(int reason)
        {
            Log.I(String.Format("onScreenCapturePaused : reason = {0}", reason));
        }

        public void onScreenCaptureResumed(int reason)
        {
            Log.I(String.Format("onScreenCaptureResumed : reason = {0}", reason));
        }

        public void onScreenCaptureStarted()
        {
            Log.I(String.Format("onScreenCaptureStarted"));
        }

        public void onScreenCaptureStoped(int reason)
        {
            Log.I(String.Format("onScreenCaptureStoped : reason = {0}", reason));
        }

        public void onSetMixTranscodingConfig(int errCode, string errMsg)
        {
            Log.I(String.Format("onSetMixTranscodingConfig : errCode = {0}, errMsg = {1}", errCode, errMsg));
        }

        public void onSpeedTest(TRTCSpeedTestResult currentResult, uint finishedCount, uint totalCount)
        {
            Log.I(String.Format(@"onSpeedTest : currentResult.ip = {0}, currentResult.quality = {1}, 
                currentResult.upLostRate = {2}, currentResult.downLostRate = {3}, currentResult.rtt = {4}, 
                finishedCount = {5}, totalCount = {6}", currentResult.ip, currentResult.quality, currentResult.upLostRate,
                currentResult.downLostRate, currentResult.rtt, finishedCount, totalCount));
        }

        public void onStartPublishCDNStream(int errCode, string errMsg)
        {
            Log.I(String.Format("onStartPublishCDNStream : errCode = {0}, errMsg = {1}", errCode, errMsg));
        }

        public void onNetworkQuality(TRTCQualityInfo localQuality, TRTCQualityInfo[] remoteQuality, uint remoteQualityCount)
        {
            Log.I(String.Format("上行网络质量： userId = {0} , Quality = {1}", mUserId, localQuality.quality));
            foreach (TRTCQualityInfo info in remoteQuality)
            {
                Log.I(String.Format("下行网络质量： userId = {0}, Quality = {1}", info.userId, info.quality));
            }
        }

        public void onStatistics(TRTCStatistics statis)
        {
            Log.I(String.Format(@"onStatistics : upLoss = {0}, downLoss = {1}, appCpu = {2}, systemCpu = {3}, 
                rtt = {4}, receivedBytes = {5}, sentBytes = {6}, localStatisticsArraySize = {7}, remoteStatisticsArraySize = {8}", 
                statis.upLoss, statis.downLoss, statis.appCpu, statis.systemCpu, statis.rtt, statis.receivedBytes, 
                statis.sentBytes, statis.localStatisticsArraySize, statis.remoteStatisticsArraySize));
            if (statis.localStatisticsArray != null && statis.localStatisticsArraySize > 0)
            {
                // 从这里记录本地的屏幕分享信息
                TRTCLocalStatistics[] localStatisticsArray = statis.localStatisticsArray;
                for (int i = 0; i < statis.localStatisticsArraySize; i++)
                {
                    if (localStatisticsArray[i].streamType == TRTCVideoStreamType.TRTCVideoStreamTypeSub)
                    {
                        int width = (int)localStatisticsArray[i].width;
                        int height = (int)localStatisticsArray[i].height;
                        TRTCVideoStreamType streamType = localStatisticsArray[i].streamType;
                        onFirstVideoFrame(null, TRTCVideoStreamType.TRTCVideoStreamTypeSub, width, height);
                    }
                    Log.I(String.Format(@"localStatisticsArray[{0}] : width = {1}, height = {2}, frameRate = {3}, 
                    videoBitrate = {4}, audioSampleRate = {5}, audioBitrate = {6}, streamType = {7}", i + 1,
                        localStatisticsArray[i].width, localStatisticsArray[i].height, localStatisticsArray[i].frameRate,
                        localStatisticsArray[i].videoBitrate, localStatisticsArray[i].audioSampleRate, localStatisticsArray[i].audioBitrate,
                        localStatisticsArray[i].streamType));
                }
            }
            if (statis.remoteStatisticsArray != null && statis.remoteStatisticsArraySize > 0)
            {
                TRTCRemoteStatistics[] remoteStatisticsArray = statis.remoteStatisticsArray;
                for (int i = 0; i < statis.remoteStatisticsArraySize; i++)
                {
                    Log.I(String.Format(@"remoteStatisticsArray[{0}] : userId = {1}, finalLoss = {2}, width = {3}, height = {4}, 
                    frameRate = {5}, videoBitrate = {6}, audioSampleRate = {7}, audioBitrate = {8}, streamType = {9}", i + 1,
                        remoteStatisticsArray[i].userId, remoteStatisticsArray[i].finalLoss, remoteStatisticsArray[i].width,
                        remoteStatisticsArray[i].height, remoteStatisticsArray[i].frameRate, remoteStatisticsArray[i].videoBitrate,
                        remoteStatisticsArray[i].audioSampleRate, remoteStatisticsArray[i].audioBitrate, remoteStatisticsArray[i].streamType));
                }
            }
        }

        public void onStopPublishCDNStream(int errCode, string errMsg)
        {
            Log.I(String.Format("onStopPublishCDNStream : errCode = {0}, errMsg = {1}", errCode, errMsg));
        }

        public void onSwitchRole(TXLiteAVError errCode, string errMsg)
        {
            Log.I(String.Format("onSwitchRole : errCode = {0}, errMsg = {1}", errCode, errMsg));
        }

        public void onTestMicVolume(uint volume)
        {
            Log.I(String.Format("onTestMicVolume : volume = {0}", volume));
            if (mDeviceTestForm != null)
            {
                mDeviceTestForm.OnTestMicVolume(volume);
            }
        }

        public void onTestSpeakerVolume(uint volume)
        {
            Log.I(String.Format("onTestSpeakerVolume : volume = {0}", volume));
            if (mDeviceTestForm != null)
            {
                mDeviceTestForm.OnTestSpeakerVolume(volume);
            }
        }

        public void OnSetScreenParamsCallback(bool success)
        {
            mIsSetScreenSuccess = success;
            if (success)
            {
                if (mTRTCCloud != null)
                {
                    this.localVideoSmallPanel.Visible = true;
                    mTRTCCloud.startScreenCapture(mScreenLocalVideo);
                }
            }
            else
            {
                this.screenShareCheckBox.Checked = false;
            }
        }

    }

    class UserVideoMeta
    {
        public string userId { get; set; }
        public string roomId { get; set; }
        public TRTCVideoStreamType streamType { get; set; }
        public int width { get; set; }
        public int height { get; set; }
        public uint fps { get; set; }
        public bool pureAudio { get; set; }
        public bool mainStream { get; set; }

        public UserVideoMeta()
        {
            userId = "";
            roomId = "";
            streamType = TRTCVideoStreamType.TRTCVideoStreamTypeBig;
            width = 0;
            height = 0;
            fps = 0;
            pureAudio = false;
            mainStream = false;
        }
    }
    
}
