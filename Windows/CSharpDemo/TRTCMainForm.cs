using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using ManageLiteAV;
using TRTCCSharpDemo.Common;
using System.Threading;
using System.Timers;
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
/// 
/// 4. 下面的窗口实现了 SDK 的内部回调，最后在回调数据后回调到主线程操作（参考 onEnterRoom），这样确保不会导致 UI 跨线程操作
/// </summary>

namespace TRTCCSharpDemo
{
    public partial class TRTCMainForm : Form, ITRTCCloudCallback, ITRTCLogCallback,ITRTCAudioFrameCallback
    {
        private ITRTCCloud mTRTCCloud;
        private ITXDeviceManager mDeviceManager;

        // 渲染模式：
        // 1 为真窗口渲染（通过窗口句柄传入 SDK），2 为自定义渲染（使用 TXLiteAVVideoView 渲染）
        // 默认为1（真窗口渲染）
        private int mRenderMode = 1;
        private IntPtr mCameraVideoHandle; 

        private string mUserId;          // 本地用户 Id
        private uint mRoomId;            // 房间 Id

        private bool mIsSetScreenSuccess;   // 是否设置屏幕参数成功

        private List<UserVideoMeta> mMixStreamVideoMeta;   //混流信息
        private List<RemoteUserInfo> mRemoteUsers;    // 当前房间里的远端用户（除了本地用户）
        private List<PKUserInfo> mPKUsers;  // 当前房间里的连麦用户

        // 当前正在使用的摄像头、麦克风和扬声器设备
        private string mCurCameraDevice;
        private string mCurMicDevice;
        private string mCurSpeakerDevice;

        // 日志等级：0 为 不显示仪表盘， 1 为 精简仪表盘， 2 为 完整仪表盘
        private int mLogLevel = 0;

        // 窗口实例
        private TRTCLoginForm mLoginForm;
        private TRTCSettingForm mSettingForm;
        private VedioSettingForm mVedioSettingForm;
        private AudioSettingForm mAudioSettingForm;
        private OtherSettingForm mOtherSettingForm;
        private TRTCBeautyForm mBeautyForm;
        private AudioEffectOldForm mAudioEffectOldForm;
        private AudioEffectForm mAudioEffectForm;
        private TRTCConnectionForm mConnectionForm;
        private ToastForm mToastForm;

        // 检查是否第一次退出房间
        private bool mIsFirstExitRoom;

        private Dictionary<string, TXLiteAVVideoView> mVideoViews;

        public TRTCMainForm(TRTCLoginForm loginForm)
        {
            // 初始化 Form
            InitializeComponent();

            this.Disposed += new EventHandler(OnDisposed);
            // 窗口退出事件监听
            this.FormClosing += new FormClosingEventHandler(OnExitLabelClick);

            // 初始化数据。
            mLoginForm = loginForm;
            mTRTCCloud = DataManager.GetInstance().trtcCloud;
            mDeviceManager = mTRTCCloud.getDeviceManager();
            mMixStreamVideoMeta = new List<UserVideoMeta>();
            mRemoteUsers = new List<RemoteUserInfo>();
            mPKUsers = new List<PKUserInfo>();
            mVideoViews = new Dictionary<string, TXLiteAVVideoView>();

            // 初始化 SDK 配置并设置回调
            Log.I(String.Format(" SDKVersion : {0}", mTRTCCloud.getSDKVersion()));
            mTRTCCloud.addCallback(this);
            mTRTCCloud.setLogCallback(this);
            mTRTCCloud.setConsoleEnabled(true);
            mTRTCCloud.setLogLevel(TRTCLogLevel.TRTCLogLevelVerbose);

            // 监听单实例事件，当点击应用图标，会返回该事件
            ThreadPool.RegisterWaitForSingleObject(Program.ProgramStarted, OnProgramStarted, null, -1, false);
        }

        private void SetRenderMode(int mode)
        {
            mRenderMode = mode;
        }


        private void OnProgramStarted(object state, bool timeout)
        {
            // 这里需要回到 UI 线程进行操作，防止窗口句柄还未创建
            if (this.IsHandleCreated)
            {
                this.BeginInvoke(new Action(() =>
                {
                    if (this.IsHandleCreated)
                    {
                        this.Show();
                        this.WindowState = FormWindowState.Normal; //注意：一定要在窗体显示后，再对属性进行设置
                        this.Activate();
                    }
                }));
            }
        }

        /// <summary>
        /// 添加自定义渲染 View 并绑定渲染回调
        /// </summary>
        private void AddCustomVideoView(Control parent, string userId, TRTCVideoStreamType streamType, bool local = false)
        {
            TXLiteAVVideoView videoView = new TXLiteAVVideoView();
            videoView.RegEngine(userId, streamType, mTRTCCloud, local);
            videoView.SetRenderMode(DataManager.GetInstance().videoFillMode);
            videoView.Size = new Size(parent.Width, parent.Height);
            parent.Controls.Add(videoView);
            string key = String.Format("{0}_{1}", userId, streamType);
            mVideoViews.Add(key, videoView);
        }

        /// <summary>
        /// 移除自定义渲染 View 并解绑渲染回调
        /// </summary>
        private void RemoveCustomVideoView(Control parent, string userId, TRTCVideoStreamType streamType, bool local = false)
        {
            TXLiteAVVideoView videoView = null;
            string key = String.Format("{0}_{1}", userId, streamType);
            if (mVideoViews.TryGetValue(key, out videoView))
            {
                videoView.RemoveEngine(mTRTCCloud);
                mVideoViews.Remove(key);
                parent.Controls.Remove(videoView);
            }
        }

        private void OnDisposed(object sender, EventArgs e)
        {
            // 清理资源
            if (mTRTCCloud != null)
            {
                mTRTCCloud.removeCallback(this);
                mTRTCCloud.setLogCallback(null);
                mTRTCCloud = null;
            }
            mDeviceManager = null;
        }

        private void OnFormLoad(object sender, EventArgs e)
        {
            if (mRenderMode == 1)
                mCameraVideoHandle = this.localVideoPanel.Handle;
            else if (mRenderMode == 2)
                mCameraVideoHandle = IntPtr.Zero;
        }

        /// <summary>
        /// 设置本地配置信息到 SDK
        /// </summary>
        private void InitLocalConfig()
        {
            // 判断是否开启本地和远程镜像，用户可以单独分开使用
            if (DataManager.GetInstance().isLocalVideoMirror && DataManager.GetInstance().isRemoteVideoMirror)
            {
                Mirror(true);
            }
            // 判断是否开启音量提示功能
            if (DataManager.GetInstance().isShowVolume)
            {
                VoicePrompt(true);
            }
            // 判断是否开启远端混流功能
            if (DataManager.GetInstance().isMixTranscoding)
            {
                this.mixTransCodingCheckBox.Checked = true;
                OnMixTransCodingCheckBoxClick(null, null);
            }
            // 判断是否开启美颜功能
            if (DataManager.GetInstance().isOpenBeauty)
                mTRTCCloud.setBeautyStyle(DataManager.GetInstance().beautyStyle, DataManager.GetInstance().beauty,
                    DataManager.GetInstance().white, DataManager.GetInstance().ruddiness);
        }

        #region Form Move Function

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

        /// <summary>
        /// 显示 Message 的 Dialog
        /// </summary>
        private void ShowMessage(string text, int delay = 0)
        {
            // 判断是否此时该窗口句柄已创建，防止出现问题
            if (this.IsHandleCreated)
            {
                this.BeginInvoke(new Action(() =>
                {
                    MessageForm msgBox = new MessageForm();
                    msgBox.setText(text, delay);
                    msgBox.setCancelBtn(false);
                    msgBox.ShowDialog();
                }));
            }
        }

        /// <summary>
        /// 用户进房前准备和进房后打开摄像头和麦克风
        /// </summary>
        /// <param name="params"></param>
        public void EnterRoom()
        {
            // 设置进房所需的相关参数
            TRTCParams trtcParams = new TRTCParams();
            trtcParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
            trtcParams.roomId = DataManager.GetInstance().roomId;
            trtcParams.userId = DataManager.GetInstance().userId;
            trtcParams.strRoomId = DataManager.GetInstance().strRoomId;
            trtcParams.userSig = GenerateTestUserSig.GetInstance().GenTestUserSig(DataManager.GetInstance().userId);
            // 如果您有进房权限保护的需求，则参考文档{https://cloud.tencent.com/document/product/647/32240}完成该功能。
            // 在有权限进房的用户中的下面字段中添加在服务器获取到的privateMapKey。
            trtcParams.privateMapKey = "";
            trtcParams.businessInfo = "";
            trtcParams.role = DataManager.GetInstance().roleType;
            // 若您的项目有纯音频的旁路直播需求，请配置参数。
            // 配置该参数后，音频达到服务器，即开始自动旁路；
            // 否则无此参数，旁路在收到第一个视频帧之前，会将收到的音频包丢弃。
            if (DataManager.GetInstance().pureAudioStyle)
                trtcParams.businessInfo = "{\"Str_uc_params\":{\"pure_audio_push_mod\": 1}}";
            else
                trtcParams.businessInfo = "";

            // 用户进房
            mTRTCCloud.enterRoom(ref trtcParams, DataManager.GetInstance().appScene);

            //如果当前是视频通话模式，默认打开弱网降分辨率
            if (DataManager.GetInstance().appScene == TRTCAppScene.TRTCAppSceneVideoCall)
            {
                DataManager.GetInstance().videoEncParams.enableAdjustRes = true;
            }

            // 设置默认参数配置
            TRTCVideoEncParam encParams = DataManager.GetInstance().videoEncParams;   // 视频编码参数设置
            TRTCNetworkQosParam qosParams = DataManager.GetInstance().qosParams;      // 网络流控相关参数设置
            mTRTCCloud.setVideoEncoderParam(ref encParams);
            mTRTCCloud.setNetworkQosParam(ref qosParams);
            TRTCRenderParams renderParams = DataManager.GetInstance().GetRenderParams();
            mTRTCCloud.setLocalRenderParams(ref renderParams);
            mTRTCCloud.setVideoEncoderMirror(DataManager.GetInstance().isRemoteVideoMirror);
            // 设置美颜
            if (DataManager.GetInstance().isOpenBeauty)
                mTRTCCloud.setBeautyStyle(DataManager.GetInstance().beautyStyle, DataManager.GetInstance().beauty,
                    DataManager.GetInstance().white, DataManager.GetInstance().ruddiness);

            // 设置大小流
            if (DataManager.GetInstance().pushSmallVideo)
            {
                TRTCVideoEncParam param = new TRTCVideoEncParam
                {
                    videoFps = 15,
                    videoBitrate = 100,
                    videoResolution = TRTCVideoResolution.TRTCVideoResolution_320_240
                };
                mTRTCCloud.enableSmallVideoStream(true, ref param);
            }
            // 房间信息
            mUserId = trtcParams.userId;
            mRoomId = trtcParams.roomId;
            this.roomLabel.Text = "房间号：" + trtcParams.roomId.ToString() + "   用户名：" + trtcParams.userId;
            this.localUserLabel.Text = mUserId;

            // 处理是否纯音频模式
            bool audioCallStyle = DataManager.GetInstance().pureAudioStyle;
            if (audioCallStyle)
            {
                this.localInfoLabel.Visible = true;
                this.localInfoLabel.Text = "纯音频模式";
                this.muteVideoCheckBox.Checked = true;
            }
            else
            {
                this.localInfoLabel.Text = "视频已关闭";
                this.localInfoLabel.Visible = false;
                StartLocalVideo();
            }
            // 如果不是观众角色进房，则打开本地摄像头采集和预览
            if (trtcParams.role != TRTCRoleType.TRTCRoleAudience)
                mTRTCCloud.startLocalAudio(DataManager.GetInstance().AudioQuality);

            InitLocalDevice();
            InitLocalConfig();
        }

        private void StartLocalVideo()
        {
            mTRTCCloud.startLocalPreview(mCameraVideoHandle);
            if (mRenderMode == 2)
            {
                AddCustomVideoView(this.localVideoPanel, mUserId, TRTCVideoStreamType.TRTCVideoStreamTypeBig, true);
            }
        }

        private void StopLocalVideo()
        {
            if (mRenderMode == 1)
            {
                mTRTCCloud.stopLocalPreview();
            }
            else if (mRenderMode == 2)
            {
                mTRTCCloud.stopLocalPreview();
                RemoveCustomVideoView(this.localVideoPanel, mUserId, TRTCVideoStreamType.TRTCVideoStreamTypeBig, true);
            }
        }

        /// <summary>
        /// 进房后的回调结果
        /// </summary>
        /// <param name="result">小于0：进房失败，错误结果会在 onError 回调显示</param>
        public void onEnterRoom(int result)
        {
            // 回调后的线程不一定在主线程，所以需要统一在回调的地方回到主线程操作，确保不导致跨线程操作 UI。
            if (this.IsHandleCreated)
                this.Invoke(new Action(() =>
                {
                    if (result >= 0)
                    {
                        // 进房成功
                        DataManager.GetInstance().enterRoom = true;
                        // 确保 SDK 内部的音频和视频采集是开启的。
                        mTRTCCloud.muteLocalVideo(false);
                        mTRTCCloud.muteLocalAudio(false);
                        this.startLocalPreviewCheckBox.Checked = true;
                        this.startLocalAudioCheckBox.Checked = true;
                        // 更新混流信息
                        UpdateMixTranCodeInfo();
                    }
                    else
                    {
                        // 进房失败
                        DataManager.GetInstance().enterRoom = false;
                        ShowMessage("进房失败，请重试");
                    }
                }));
        }

        /// <summary>
        /// 初始化本地设备使用
        /// </summary>
        private void InitLocalDevice()
        {
            ITRTCDeviceCollection cameraList = mDeviceManager.getDevicesList(TRTCDeviceType.TXMediaDeviceTypeCamera);
            mCurCameraDevice = "";
            if (cameraList.getCount() > 0)
            {
                ITRTCDeviceInfo camera = mDeviceManager.getCurrentDevice(TRTCDeviceType.TXMediaDeviceTypeCamera);
                mCurCameraDevice = camera.getDevicePID();
            }
            cameraList.release();
            ITRTCDeviceCollection micList = mDeviceManager.getDevicesList(TRTCDeviceType.TXMediaDeviceTypeMic);
            mCurMicDevice = "";
            if (micList.getCount() > 0)
            {
                ITRTCDeviceInfo mic = mDeviceManager.getCurrentDevice(TRTCDeviceType.TXMediaDeviceTypeMic);
                mCurMicDevice = mic.getDevicePID();
            }
            micList.release();
            ITRTCDeviceCollection speakerList = mDeviceManager.getDevicesList(TRTCDeviceType.TXMediaDeviceTypeSpeaker);
            mCurSpeakerDevice = "";
            if (speakerList.getCount() > 0)
            {
                ITRTCDeviceInfo speaker = mDeviceManager.getCurrentDevice(TRTCDeviceType.TXMediaDeviceTypeSpeaker);
                mCurSpeakerDevice = speaker.getDevicePID();
            }
            speakerList.release();
        }

        

        /// <summary>
        /// 回调 SDK 中抛出的错误信息，一般抛出错误就不应该继续使用，而是排查错误。
        /// 下面只列出了常见的几种错误信息提示，如需了解更多 SDK 错误信息，请参考 TXLiteAVError
        /// </summary>
        public void onError(TXLiteAVError errCode, string errMsg, IntPtr arg)
        {
            Log.E(String.Format("errCode : {0}, errMsg : {1}, arg = {2}", errCode, errMsg, arg));
            if (errCode == TXLiteAVError.ERR_SERVER_CENTER_ANOTHER_USER_PUSH_SUB_VIDEO ||
                errCode == TXLiteAVError.ERR_SERVER_CENTER_NO_PRIVILEDGE_PUSH_SUB_VIDEO ||
                errCode == TXLiteAVError.ERR_SERVER_CENTER_INVALID_PARAMETER_SUB_VIDEO)
            {
                ShowMessage("Error: 屏幕分享发起失败，是否当前已经有人发起了共享！");
            }
            else if (errCode == TXLiteAVError.ERR_MIC_START_FAIL || errCode == TXLiteAVError.ERR_CAMERA_START_FAIL ||
                errCode == TXLiteAVError.ERR_SPEAKER_START_FAIL)
            {
                ShowMessage("Error: 请检查本地电脑设备。");
            }
            else
            {
                ShowMessage(String.Format("SDK出错[err:{0},msg:{1}]", errCode, errMsg));
            }
        }

        /// <summary>
        /// 本地用户退出房间回调
        /// </summary>
        public void onExitRoom(int reason)
        {
            DataManager.GetInstance().enterRoom = false;
            this.Close();
        }

        /// <summary>
        /// 退房后执行的清理操作和关闭 SDK 内部功能。
        /// </summary>
        private void Uninit()
        {
            // 如果开启了自定义采集和渲染，则关闭功能，清理资源
            if (DataManager.GetInstance().isLocalVideoMirror && DataManager.GetInstance().isRemoteVideoMirror)
            {
                mTRTCCloud.enableCustomVideoCapture(false);
                mTRTCCloud.enableCustomAudioCapture(false);
            }
            mTRTCCloud.stopAllRemoteView();
            if (mRenderMode == 1)
            {
                mTRTCCloud.stopLocalPreview();
            }
            else if (mRenderMode == 2)
            {
                StopLocalVideo();
                foreach (var item in mVideoViews)
                {
                    if (item.Value != null)
                    {
                        item.Value.RemoveEngine(mTRTCCloud);
                    }
                }
                TXLiteAVVideoView.RemoveAllRegEngine();
            }
            
            mTRTCCloud.stopLocalAudio();
            mTRTCCloud.muteLocalAudio(true);
            mTRTCCloud.muteLocalVideo(true);

            // 清理混流信息和用户信息
            mMixStreamVideoMeta.Clear();
            mRemoteUsers.Clear();
            mPKUsers.Clear();
           
            if (this.screenShareCheckBox.Checked)
            {
                mTRTCCloud.stopScreenCapture();
                if (mToastForm != null)
                    mToastForm.Close();
            }
            if (this.mixTransCodingCheckBox.Checked)
                mTRTCCloud.setMixTranscodingConfig(null);
            
        }

        /// <summary>
        /// 用户是否开启音频上行
        /// </summary>
        public void onUserAudioAvailable(string userId, bool available)
        {
            Log.I(String.Format("onUserAudioAvailable : userId = {0}, available = {1}", userId, available));
            mTRTCCloud.setAudioFrameCallback(this);
        }

        /// <summary>
        /// 注意：该接口已被废弃，不推荐使用（保持空实现），请使用 onRemoteUserEnterRoom 替代。
        /// </summary>
        public void onUserEnter(string userId) { }

        /// <summary>
        /// 注意：该接口已被废弃，不推荐使用（保持空实现），请使用 onRemoteUserLeaveRoom 替代。
        /// </summary>
        public void onUserExit(string userId, int reason) { }

        public void onRemoteUserEnterRoom(string userId)
        {
            if (this.IsHandleCreated)
                this.BeginInvoke(new Action(() =>
                {
                    // 添加远端进房用户信息
                    mRemoteUsers.Add(new RemoteUserInfo() { userId = userId, position = -1 });
                    OnPKUserEnter(userId);
                }));
        }

        public void onRemoteUserLeaveRoom(string userId, int reason)
        {
            if (this.IsHandleCreated)
                this.BeginInvoke(new Action(() =>
                {
                    // 清理远端用户退房信息，回收窗口
                    OnPKUserExit(userId);
                    int pos = FindOccupyRemoteVideoPosition(userId, true);
                    if (pos != -1)
                    {
                        foreach (RemoteUserInfo user in mRemoteUsers)
                        {
                            if (user.userId.Equals(userId))
                            {
                                mRemoteUsers.Remove(user);
                                break;
                            }
                        }
                    }
                }));
        }

        /// <summary>
        /// 远端连麦用户进房通知
        /// </summary>
        private void OnPKUserEnter(string userId)
        {
            foreach (PKUserInfo info in mPKUsers)
            {
                if (info.userId.Equals(userId))
                {
                    info.isEnterRoom = true;
                    Log.I(String.Format("连麦用户[{0}]进入房间", userId));
                    break;
                }
            }
        }

        /// <summary>
        /// 获取空闲的窗口句柄分发给进房用户或屏幕分享界面
        /// </summary>
        private IntPtr GetHandleAndSetUserId(int pos, string userId, bool isOpenSubStream)
        {
            switch (pos)
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

        /// <summary>
        /// 获取远端用户的的窗口位置
        /// </summary>
        private int GetRemoteVideoPosition(String userId)
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

        /// <summary>
        /// 获取空闲窗口的位置
        /// </summary>
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

        /// <summary>
        /// 连麦用户退出房间，清理用户信息
        /// </summary>
        /// <param name="userId"></param>
        private void OnPKUserExit(string userId)
        {
            foreach (PKUserInfo info in mPKUsers)
            {
                if (info.userId.Equals(userId) && info.isEnterRoom)
                {
                    mPKUsers.Remove(info);
                    Log.I(String.Format("连麦用户[{0}]离开房间", userId));
                    break;
                }
            }
            if (mPKUsers.Count <= 0)
                this.connectRoomCheckBox.Checked = false;
        }

        /// <summary>
        /// 根据用户是否退房找到用户画面当前窗口的位置
        /// </summary>
        private int FindOccupyRemoteVideoPosition(string userId, bool isExitRoom)
        {
            int pos = -1;
            if (this.remoteUserLabel1.Text.Equals(userId))
            {
                pos = 1;
                if (isExitRoom)
                    this.remoteUserLabel1.Text = "";
            }
            if (this.remoteUserLabel2.Text.Equals(userId))
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
            if (isExitRoom)
                SetVisableInfoView(pos, false);
            return pos;
        }

        /// <summary>
        /// 用户是否开启辅流
        /// </summary>
        public void onUserSubStreamAvailable(string userId, bool available)
        {
            if (this.IsHandleCreated)
                this.BeginInvoke(new Action(() =>
                {
                    if (available)
                    {
                        // 显示远端辅流界面
                        int pos = GetIdleRemoteVideoPosition(userId + "(屏幕分享)");
                        if (pos != -1)
                        {
                            SetVisableInfoView(pos, false);
                            if (mRenderMode == 1)
                            {
                                IntPtr ptr = GetHandleAndSetUserId(pos, userId, true);
                                TRTCRenderParams renderParams = DataManager.GetInstance().GetRenderParams();
                                mTRTCCloud.setRemoteRenderParams(userId, TRTCVideoStreamType.TRTCVideoStreamTypeSub, ref renderParams);
                                mTRTCCloud.startRemoteView(userId, TRTCVideoStreamType.TRTCVideoStreamTypeSub, ptr);
                            }
                            else if (mRenderMode == 2)
                            {
                                Panel panel = GetPanelAndSetUserId(pos, userId, true, true);
                                mTRTCCloud.startRemoteView(userId, TRTCVideoStreamType.TRTCVideoStreamTypeSub, IntPtr.Zero);
                                if (panel != null)
                                    AddCustomVideoView(panel, userId, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
                            }
                        }
                    }
                    else
                    {
                        // 移除远端辅流界面
                        int pos = FindOccupyRemoteVideoPosition(userId + "(屏幕分享)", true);
                        if (pos != -1)
                        {
                            mTRTCCloud.stopRemoteView(userId, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
                            if (mRenderMode == 2)
                            {
                                Panel panel = GetPanelAndSetUserId(pos, userId, false, true);
                                if (panel != null)
                                    RemoveCustomVideoView(panel, userId, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
                            }
                            RemoveVideoMeta(userId, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
                            UpdateMixTranCodeInfo();
                        }
                    }
                }));
        }

        /// <summary>
        /// 用户是否开启摄像头视频
        /// </summary>
        public void onUserVideoAvailable(string userId, bool available)
        {
            if (this.IsHandleCreated)
                this.BeginInvoke(new Action(() =>
                {
                    // 判断用户是否已经退出房间
                    bool isExit = mRemoteUsers.Exists((user) =>
                    {
                        if (user.userId.Equals(userId)) return true;
                        else return false;
                    });
                    if (!isExit) return;
                    if (available)
                    {
                        // 显示远端用户主流画面
                        int pos = GetIdleRemoteVideoPosition(userId);
                        if (pos != -1)
                        {
                            SetVisableInfoView(pos, false);
                            TRTCVideoStreamType streamType = DataManager.GetInstance().playSmallVideo ?
                                    TRTCVideoStreamType.TRTCVideoStreamTypeSmall : TRTCVideoStreamType.TRTCVideoStreamTypeBig;
                            if (mRenderMode == 1)
                            {
                                IntPtr ptr = GetHandleAndSetUserId(pos, userId, false);
                                TRTCRenderParams renderParams = DataManager.GetInstance().GetRenderParams();
                                mTRTCCloud.setRemoteRenderParams(userId, TRTCVideoStreamType.TRTCVideoStreamTypeBig, ref renderParams);
                                
                                mTRTCCloud.startRemoteView(userId, streamType, ptr);
                            }
                            else if (mRenderMode == 2)
                            {
                                Panel panel = GetPanelAndSetUserId(pos, userId);
                                mTRTCCloud.startRemoteView(userId, streamType, IntPtr.Zero);
                                if (panel != null)
                                    AddCustomVideoView(panel, userId, TRTCVideoStreamType.TRTCVideoStreamTypeBig);
                            }

                            foreach (RemoteUserInfo info in mRemoteUsers)
                            {
                                if (info.userId.Equals(userId))
                                {
                                    info.position = pos;
                                    break;
                                }
                            }
                            if (DataManager.GetInstance().isShowVolume)
                                SetRemoteVoiceVisable(pos, true);
                        }
                    }
                    else
                    {
                        // 移除远端用户主流画面
                        int pos = GetRemoteVideoPosition(userId);
                        if (pos != -1)
                        {
                            SetVisableInfoView(pos, true);
                            mTRTCCloud.stopRemoteView(userId, TRTCVideoStreamType.TRTCVideoStreamTypeBig);
                            if (mRenderMode == 2)
                            {
                                Panel panel = GetPanelAndSetUserId(pos, userId, false, false);
                                if (panel != null)
                                    RemoveCustomVideoView(panel, userId, TRTCVideoStreamType.TRTCVideoStreamTypeBig);
                            }
                            // 关闭远端音量提示
                            if (DataManager.GetInstance().isShowVolume)
                                SetRemoteVoiceVisable(pos, false);
                            RemoveVideoMeta(userId, TRTCVideoStreamType.TRTCVideoStreamTypeBig);
                            UpdateMixTranCodeInfo();
                        }
                    }
                }));
        }

        private Panel GetPanelAndSetUserId(int pos, string userId, bool isSetUserId = true, bool isOpenSubStream = false)
        {
            switch (pos)
            {
                case 1:
                    if (isSetUserId)
                        this.remoteUserLabel1.Text = userId + (isOpenSubStream ? "(屏幕分享)" : "");
                    return this.remoteVideoPanel1;
                case 2:
                    if (isSetUserId)
                        this.remoteUserLabel2.Text = userId + (isOpenSubStream ? "(屏幕分享)" : "");
                    return this.remoteVideoPanel2;
                case 3:
                    if (isSetUserId)
                        this.remoteUserLabel3.Text = userId + (isOpenSubStream ? "(屏幕分享)" : "");
                    return this.remoteVideoPanel3;
                case 4:
                    if (isSetUserId)
                        this.remoteUserLabel4.Text = userId + (isOpenSubStream ? "(屏幕分享)" : "");
                    return this.remoteVideoPanel4;
                case 5:
                    if (isSetUserId)
                        this.remoteUserLabel5.Text = userId + (isOpenSubStream ? "(屏幕分享)" : "");
                    return this.remoteVideoPanel5;
                default:
                    return null;
            }
        }

        /// <summary>
        /// 是否显示提示远端用户是否打开视频的画面
        /// </summary>
        private void SetVisableInfoView(int pos, bool visable)
        {
            switch (pos)
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
            // 退出房间
            if (mIsFirstExitRoom) return;
            mIsFirstExitRoom = true;
            if (mBeautyForm != null)
                mBeautyForm.Close();
            if (mAudioEffectOldForm != null)
                mAudioEffectOldForm.Close();
            if (mAudioEffectForm != null)
                mAudioEffectForm.Close();
            if (mSettingForm != null)
                mSettingForm.Close();
            if (mVedioSettingForm != null)
                mVedioSettingForm.Close();
            if (mAudioSettingForm != null)
                mAudioSettingForm.Close();
            if (mOtherSettingForm != null)
                mOtherSettingForm.Close();
            if (mConnectionForm != null)
                mConnectionForm.Close();
            Uninit();
            // 如果进房成功，需要正常退房再关闭窗口，防止资源未清理和释放完毕
            if (DataManager.GetInstance().enterRoom)
                mTRTCCloud.exitRoom();
            else
                onExitRoom(0);
            if (mLoginForm == null)
                mLoginForm = new TRTCLoginForm();
            mLoginForm.Show();
        }

        private void OnSettingLabelClick(object sender, EventArgs e)
        {
            if (mSettingForm == null)
                mSettingForm = new TRTCSettingForm();
            mSettingForm.ShowDialog();
        }

        /// <summary>
        /// 打开仪表盘信息（自定义渲染下由于不是使用真窗口渲染，所以暂时无法显示仪表盘信息）
        /// </summary>
        private void OnLogCheckBoxClick(object sender, EventArgs e)
        {
            mLogLevel++;
            int style = mLogLevel % 3;
            if(style > 0)
            {
                this.logCheckBox.Checked = true;
            }
            else
            {
                this.logCheckBox.Checked = false;
            }
            if (mTRTCCloud != null)
            {
                mTRTCCloud.showDebugView(style);
            }
        }

        public void onLog(string log, TRTCLogLevel level, string module)
        {
            // SDK 内部日志显示
            Log.I(String.Format("onLog : log = {0}, level = {1}, module = {2}", log, level, module));
        }

        /// <summary>
        /// 开始渲染本地或远程用户的首帧画面
        /// </summary>
        public void onFirstVideoFrame(string userId, TRTCVideoStreamType streamType, int width, int height)
        {
            if (this.IsHandleCreated)
                this.BeginInvoke(new Action(() =>
                {
                    if (!this.screenShareCheckBox.Checked)
                    {
                        if (string.IsNullOrEmpty(userId) && streamType == TRTCVideoStreamType.TRTCVideoStreamTypeSub)
                            return;
                    }
                    if (!string.IsNullOrEmpty(userId))
                    {
                        // 暂时只支持最多6个人同时视频
                        if (streamType == TRTCVideoStreamType.TRTCVideoStreamTypeBig && FindOccupyRemoteVideoPosition(userId, false) == -1)
                            return;
                        if (streamType == TRTCVideoStreamType.TRTCVideoStreamTypeSub && FindOccupyRemoteVideoPosition(userId + "(屏幕分享)", false) == -1)
                            return;
                    }

                    // 这里主要用于添加用户的混流信息（包括本地和远端用户），并实时更新混流信息
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
                        else if (info.userId.Equals(userId) && streamType != TRTCVideoStreamType.TRTCVideoStreamTypeSub)
                        {
                            info.streamType = streamType;
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
                }));
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
            if (!DataManager.GetInstance().enterRoom)
            {
                ShowMessage("进房失败，请重试");
                this.screenShareCheckBox.Checked = false;
                return;
            }
            if (this.screenShareCheckBox.Checked)
            {
                // 开启屏幕分享功能
                TRTCScreenForm screenForm = new TRTCScreenForm(this);
                screenForm.ShowDialog();
            }
            else
            {
                // 关闭屏幕分享功能
                if (!mIsSetScreenSuccess) return;
                mTRTCCloud.stopScreenCapture();
                if (mToastForm != null)
                    mToastForm.Hide();

                // 移除混流中的屏幕分享画面
                RemoveVideoMeta(mUserId, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
                UpdateMixTranCodeInfo();
            }
        }

        private void OnMixTransCodingCheckBoxClick(object sender, EventArgs e)
        {
            if (this.mixTransCodingCheckBox.Checked)
            {
                // 开启云端画面混合功能
                DataManager.GetInstance().isMixTranscoding = true;
                UpdateMixTranCodeInfo();
            }
            else
            {
                // 关闭云端画面混合功能
                DataManager.GetInstance().isMixTranscoding = false;
                mTRTCCloud.setMixTranscodingConfig(null);
            }
        }

        /// <summary>
        /// 移除混流画面的用户信息
        /// </summary>
        private void RemoveVideoMeta(string userId, TRTCVideoStreamType streamType)
        {
            foreach (UserVideoMeta info in mMixStreamVideoMeta)
            {
                if (info.userId == userId && (info.streamType == streamType ||
                    info.streamType != TRTCVideoStreamType.TRTCVideoStreamTypeSub))
                {
                    mMixStreamVideoMeta.Remove(info);
                    break;
                }
            }
        }

        /// <summary>
        /// 更新云端混流界面信息（本地用户进房或远程用户进房或开启本地屏幕共享画面则需要更新）
        /// </summary>
        private void UpdateMixTranCodeInfo()
        {
            // 没有打开云端混流功能则退出
            if (!this.mixTransCodingCheckBox.Checked)
                return;

            // 云端混流的没有辅流界面，则退出（无需混流）
            if (mMixStreamVideoMeta.Count == 0)
            {
                mTRTCCloud.setMixTranscodingConfig(null);
                return;
            }

            // 如果使用的是纯音频进房，则需要混流设置每一路为纯音频，云端会只混流音频数据
            if (DataManager.GetInstance().pureAudioStyle)
            {
                foreach (UserVideoMeta meta in mMixStreamVideoMeta)
                    meta.pureAudio = true;
            }

            // 没有主流，直接停止混流。
            if (this.muteVideoCheckBox.Checked && this.muteAudioCheckBox.Checked)
            {
                mTRTCCloud.setMixTranscodingConfig(null);
                return;
            }

            // 配置本地主流的混流信息
            UserVideoMeta localMainVideo = new UserVideoMeta()
            {
                userId = mUserId
            };
            // 连麦后的User可进行设置对应的roomId
            foreach (UserVideoMeta info in mMixStreamVideoMeta)
            {
                foreach (PKUserInfo pKUserInfo in mPKUsers)
                {
                    if (pKUserInfo.userId.Equals(info.userId))
                    {
                        info.roomId = pKUserInfo.roomId;
                        break;
                    }
                }
            }

            // 这里的显示混流的方式只提供参考，如需使用其他方式显示请参考以下方式
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
            // 设置每一路子画面的位置信息（仅供参考）
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
                if (info.roomId <= 0)
                    mixUsersArray[index].roomId = null;
                else
                    mixUsersArray[index].roomId = info.roomId.ToString();
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
            // 设置云端混流配置信息
            mTRTCCloud.setMixTranscodingConfig(config);
        }

        private void OnStartLocalAudioClick(object sender, EventArgs e)
        {
            if (!DataManager.GetInstance().enterRoom)
            {
                ShowMessage("进房失败，请重试");
                this.startLocalAudioCheckBox.Checked = false;
                return;
            }
            
            if (this.startLocalAudioCheckBox.Checked)
            {
                mTRTCCloud.startLocalAudio(DataManager.GetInstance().AudioQuality);
            }
            else
            {
                mTRTCCloud.stopLocalAudio();
            }
        }

        private void OnStartLocalPreviewClick(object sender, EventArgs e)
        {
            if (!DataManager.GetInstance().enterRoom)
            {
                ShowMessage("进房失败，请重试");
                this.startLocalPreviewCheckBox.Checked = false;
                return;
            }
            if (DataManager.GetInstance().pureAudioStyle)
            {
                ShowMessage("Error: 纯音频场景，无法打开视频，请退房重新选择模式");
                this.startLocalPreviewCheckBox.Checked = false;
                return;
            }
            if (this.startLocalPreviewCheckBox.Checked)
            {
                StartLocalVideo();
                if (!this.muteVideoCheckBox.Checked)
                {
                    this.localInfoLabel.Visible = false;
                }
            }
            else
            {
                StopLocalVideo();
                this.localInfoLabel.Visible = true;
            }
        }

        private void OnMuteAudioCheckBoxClick(object sender, EventArgs e)
        {
            if (!DataManager.GetInstance().enterRoom)
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
            if (!DataManager.GetInstance().enterRoom)
            {
                ShowMessage("进房失败，请重试");
                this.muteVideoCheckBox.Checked = false;
                return;
            }
            if (DataManager.GetInstance().pureAudioStyle)
            {
                ShowMessage("Error: 纯音频场景，无法打开视频，请退房重新选择模式");
                this.muteVideoCheckBox.Checked = true;
                return;
            }
            if (!this.muteVideoCheckBox.Checked)
            {
                // 开启本地视频画面
                mTRTCCloud.muteLocalVideo(false);
                this.localInfoLabel.Visible = false;
            }
            else
            {
                // 屏蔽本地视频画面
                this.localInfoLabel.Visible = true;
                mTRTCCloud.muteLocalVideo(true);
            }
        }

        private void Mirror(bool isMirror)
        {
            // 这里同时同步本地和远端的镜像模式，用户可自行拆分功能
            if (isMirror)
            {
                DataManager.GetInstance().isLocalVideoMirror = true;
                DataManager.GetInstance().isRemoteVideoMirror = true;
                mTRTCCloud.setVideoEncoderMirror(true);
            }
            else
            {
                DataManager.GetInstance().isLocalVideoMirror = false;
                DataManager.GetInstance().isRemoteVideoMirror = false;
                mTRTCCloud.setVideoEncoderMirror(false);
            }
            TRTCRenderParams renderParams = DataManager.GetInstance().GetRenderParams();
            mTRTCCloud.setLocalRenderParams(ref renderParams);
        }


        private void OnShareUrlLabelClick(object sender, EventArgs e)
        {
            // 获取旁路直播的 url
            if (!this.mixTransCodingCheckBox.Checked)
            {
                ShowMessage("请勾选云端混流选项！");
                return;
            }
            // 计算 CDN 地址(格式： http://[bizid].liveplay.myqcloud.com/live/sdkappid_roomId_userId_main.flv )
            int bizId = GenerateTestUserSig.BIZID;
            // streamid = SDKAPPID_房间号_用户名_流类型
            string streamId = String.Format("{0}_{1}_{2}_{3}", GenerateTestUserSig.SDKAPPID, mRoomId, Util.UTF16To8(mUserId), "main");
            string shareUrl = String.Format("http://{0}.liveplay.myqcloud.com/live/{1}.flv", bizId, streamId);
            Log.I("播放地址： " + shareUrl);
            Clipboard.SetDataObject(shareUrl);
            ShowMessage("播放地址：（已复制到剪切板）\n" + shareUrl);
        }

        private void OnBgmCheckBoxClick(object sender, EventArgs e)
        {
            if(Util.IsTestEnv())
            {
                if (mAudioEffectOldForm == null)
                    mAudioEffectOldForm = new AudioEffectOldForm();
                mAudioEffectOldForm.ShowDialog();
                this.bgmCheckBox.Checked = false;
            }
            else
            {
                if (mAudioEffectForm == null)
                    mAudioEffectForm = new AudioEffectForm();
                mAudioEffectForm.ShowDialog();
                this.bgmCheckBox.Checked = false;
            }
           
        }

        private void OnBeautyLabelClick(object sender, EventArgs e)
        {
            if (!DataManager.GetInstance().enterRoom)
            {
                ShowMessage("进房失败，请重试");
                return;
            }
            if (mBeautyForm == null)
                mBeautyForm = new TRTCBeautyForm();
            mBeautyForm.ShowDialog();
        }

        /// <summary>
        /// 用于提示音量大小的回调,包括每个 userId 的音量和远端总音量
        /// </summary>
        public void onUserVoiceVolume(TRTCVolumeInfo[] userVolumes, uint userVolumesCount, uint totalVolume)
        {
            if (this.IsHandleCreated)
                this.BeginInvoke(new Action(() =>
                {
                    if (userVolumesCount <= 0) return;
                    foreach (TRTCVolumeInfo info in userVolumes)
                    {
                        if (string.IsNullOrEmpty(info.userId) && this.localVoiceProgressBar.Visible)
                            this.localVoiceProgressBar.Value = (int)info.volume;
                        else
                            SetRemoteVoiceVolume(info.userId, (int)info.volume);
                    }
                }));
        }

        /// <summary>
        /// 根据位置设置远端用户的音量提示功能显示
        /// </summary>
        private void SetRemoteVoiceVisable(int pos, bool visable)
        {
            if (pos == 1)
                this.remoteVoiceProgressBar1.Visible = visable;
            if (pos == 2)
                this.remoteVoiceProgressBar2.Visible = visable;
            if (pos == 3)
                this.remoteVoiceProgressBar3.Visible = visable;
            if (pos == 4)
                this.remoteVoiceProgressBar4.Visible = visable;
            if (pos == 5)
                this.remoteVoiceProgressBar5.Visible = visable;
        }

        /// <summary>
        /// 设置远端主流的麦克风音量
        /// </summary>
        private void SetRemoteVoiceVolume(string userId, int volume)
        {
            if (this.remoteUserLabel1.Text.Equals(userId) && this.remoteVoiceProgressBar1.Visible)
                this.remoteVoiceProgressBar1.Value = volume;
            else if (this.remoteUserLabel2.Text.Equals(userId) && this.remoteVoiceProgressBar2.Visible)
                this.remoteVoiceProgressBar2.Value = volume;
            else if (this.remoteUserLabel3.Text.Equals(userId) && this.remoteVoiceProgressBar3.Visible)
                this.remoteVoiceProgressBar3.Value = volume;
            else if (this.remoteUserLabel4.Text.Equals(userId) && this.remoteVoiceProgressBar4.Visible)
                this.remoteVoiceProgressBar4.Value = volume;
            else if (this.remoteUserLabel5.Text.Equals(userId) && this.remoteVoiceProgressBar5.Visible)
                this.remoteVoiceProgressBar5.Value = volume;
        }

        public void VoicePrompt(bool bIsPrompt)
        {
            if (bIsPrompt)
            {
                // 开启音量提示
                DataManager.GetInstance().isShowVolume = true;
                if (mTRTCCloud != null)
                    mTRTCCloud.enableAudioVolumeEvaluation(300);
                this.localVoiceProgressBar.Visible = true;
                foreach (RemoteUserInfo info in mRemoteUsers)
                {
                    if (info.position != -1)
                        SetRemoteVoiceVisable(info.position, true);
                }
            }
            else
            {
                // 关闭音量提示
                DataManager.GetInstance().isShowVolume = false;
                if (mTRTCCloud != null)
                    mTRTCCloud.enableAudioVolumeEvaluation(0);
                this.localVoiceProgressBar.Visible = false;
                foreach (RemoteUserInfo info in mRemoteUsers)
                {
                    if (info.position != -1)
                        SetRemoteVoiceVisable(info.position, false);
                }
            }
        }

        public void onWarning(TXLiteAVWarning warningCode, string warningMsg, IntPtr arg)
        {
            Log.I(String.Format("warningCode : {0}, warningMsg : {1}", warningCode, warningMsg));

            if (warningCode == TXLiteAVWarning.WARNING_MICROPHONE_DEVICE_EMPTY)
            {
                ShowMessage("Warning: 未检出到麦克风，请检查本地电脑设备。");
            }
            else if (warningCode == TXLiteAVWarning.WARNING_CAMERA_DEVICE_EMPTY)
            {
                ShowMessage("Warning: 未检出到摄像头，请检查本地电脑设备。");
            }
            else if (warningCode == TXLiteAVWarning.WARNING_SPEAKER_DEVICE_EMPTY)
            {
                ShowMessage("Warning: 未检出到扬声器，请检查本地电脑设备。");
            }
        }

        public void onCameraDidReady()
        {
            Log.I(String.Format("onCameraDidReady"));
            // 实时获取当前使用的摄像头设备信息
            if (mTRTCCloud != null)
                mCurCameraDevice = mDeviceManager.getCurrentDevice(TRTCDeviceType.TXMediaDeviceTypeCamera).getDevicePID();
        }

        public void onMicDidReady()
        {
            Log.I(String.Format("onMicDidReady"));
            // 实时获取当前使用的麦克风设备信息
            if (mTRTCCloud != null)
            mCurMicDevice = mDeviceManager.getCurrentDevice(TRTCDeviceType.TXMediaDeviceTypeMic).getDevicePID();
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

        public void OnConnectionFormClose()
        {
            if (mPKUsers.Count > 0)
                this.connectRoomCheckBox.Checked = true;
            else
                this.connectRoomCheckBox.Checked = false;
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
            // 实时监控本地设备的拔插
            // SDK 内部已支持摄像头、麦克风以及扬声器拔插时判断是否需要自动打开或切换，外部无需做处理
            Log.I(String.Format("onDeviceChange : deviceId = {0}, type = {1}, state = {2}", deviceId, type, state));
            this.BeginInvoke(new Action(() =>
            {
                if (type == TRTCDeviceType.TXMediaDeviceTypeCamera)
                {
                    if (mVedioSettingForm != null)
                        mVedioSettingForm.OnDeviceChange(deviceId, type, state);
                }
                else if (type == TRTCDeviceType.TXMediaDeviceTypeMic || type == TRTCDeviceType.TXMediaDeviceTypeSpeaker)
                {
                    if (mAudioSettingForm != null)
                        mAudioSettingForm.OnDeviceChange(deviceId, type, state);
                }
            }));
        }

        private void OnConnectRoomCheckBoxClick(object sender, EventArgs e)
        {
            if (!DataManager.GetInstance().enterRoom)
            {
                ShowMessage("进房失败，请重试");
                return;
            }
            if (mPKUsers.Count > 0)
                this.connectRoomCheckBox.Checked = true;
            else
                this.connectRoomCheckBox.Checked = false;
            if (mConnectionForm == null)
                mConnectionForm = new TRTCConnectionForm(this);
            mConnectionForm.SetDisconnectBtnEnabled(mPKUsers.Count > 0);
            mConnectionForm.ShowDialog();
        }

        public void onConnectOtherRoom(string userId, TXLiteAVError errCode, string errMsg)
        {
            if (this.IsHandleCreated)
                this.BeginInvoke(new Action(() =>
                {
                    // 连麦后事件回调，如果 errCode == ERR_NULL 则表示连麦成功。
                    if (mConnectionForm != null)
                        mConnectionForm.OnConnectOtherRoom(userId, errCode, errMsg);
                }));
        }

        public void onDisconnectOtherRoom(TXLiteAVError errCode, string errMsg)
        {
            if (this.IsHandleCreated)
                this.BeginInvoke(new Action(() =>
                {
                    // 取消连麦后事件回调，如果 errCode == ERR_NULL 则表示取消连麦成功。
                    if (mConnectionForm != null)
                        mConnectionForm.OnDisconnectOtherRoom(errCode, errMsg);
                }));
        }

        public void AddPKUser(uint roomId, string userId)
        {
            mPKUsers.Add(new PKUserInfo() { roomId = roomId, userId = userId });
        }

        public void ClearPKUsers()
        {
            mPKUsers.Clear();
            this.connectRoomCheckBox.Checked = false;
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
            if (this.IsHandleCreated)
                this.BeginInvoke(new Action(() =>
                {
                    if (mAudioEffectOldForm != null)
                        mAudioEffectOldForm.OnPlayBGMComplete(errCode);
                }));
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
            if (this.IsHandleCreated)
                this.BeginInvoke(new Action(() =>
                {
                    this.screenShareCheckBox.Checked = false;
                    if (mToastForm != null && mToastForm.Visible)
                        mToastForm.Hide();
                }));
        }

        public void onSetMixTranscodingConfig(int errCode, string errMsg)
        {
            Log.I(String.Format("onSetMixTranscodingConfig : errCode = {0}, errMsg = {1}", errCode, errMsg));
        }

        public void onAudioEffectFinished(int effectId, int code)
        {
            Log.I(String.Format("onAudioEffectFinished : effectId = {0}, code = {1}", effectId, code));
            if (this.IsHandleCreated)
                this.BeginInvoke(new Action(() =>
                {
                    if (mAudioEffectOldForm != null)
                        mAudioEffectOldForm.onAudioEffectFinished(effectId, code);
                }));
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

        public void onStartPublishing(int errCode, string errMsg)
        {
            Log.I(String.Format("onStartPublishing : errCode = {0}, errMsg = {1}", errCode, errMsg));
        }

        public void onStopPublishing(int errCode, string errMsg)
        {
            Log.I(String.Format("onStopPublishing : errCode = {0}, errMsg = {1}", errCode, errMsg));
        }

        public void onStopPublishCDNStream(int errCode, string errMsg)
        {
            Log.I(String.Format("onStopPublishCDNStream : errCode = {0}, errMsg = {1}", errCode, errMsg));
        }

        /// <summary>
        /// 网络质量：该回调每2秒触发一次，统计当前网络的上行和下行质量
        /// </summary>
        public void onNetworkQuality(TRTCQualityInfo localQuality, TRTCQualityInfo[] remoteQuality, uint remoteQualityCount)
        {
        }

        public void onStatistics(TRTCStatistics statis)
        {
            if (statis.localStatisticsArray != null && statis.localStatisticsArraySize > 0)
            {
                // 从这里记录本地的屏幕分享信息，实时更新混流
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
                }
            }
        }

        public void onSwitchRole(TXLiteAVError errCode, string errMsg)
        {
            Log.I(String.Format("onSwitchRole : errCode = {0}, errMsg = {1}", errCode, errMsg));
        }

        /// <summary>
        /// 测试麦克风设备的音量回调
        /// </summary>
        public void onTestMicVolume(uint volume)
        {
            if (this.IsHandleCreated)
                this.BeginInvoke(new Action(() =>
                {
                    if (mAudioSettingForm != null)
                        mAudioSettingForm.OnTestMicVolume(volume);
                }));
        }

        /// <summary>
        /// 测试扬声器设备的音量回调
        /// </summary>
        public void onTestSpeakerVolume(uint volume)
        {
            if (this.IsHandleCreated)
                this.BeginInvoke(new Action(() =>
                {
                    if (mAudioSettingForm != null)
                        mAudioSettingForm.OnTestSpeakerVolume(volume);
                }));
        }

        public void OnSetScreenParamsCallback(bool success)
        {
            mIsSetScreenSuccess = success;
            if (success)
            {
                if (mTRTCCloud != null)
                {
                    mTRTCCloud.startScreenCapture(IntPtr.Zero, TRTCVideoStreamType.TRTCVideoStreamTypeSub, null);
                    this.Invoke(new Action(() =>
                    {
                        if (mToastForm == null)
                            mToastForm = new ToastForm();
                        mToastForm.SetText(mUserId + " 正在屏幕共享");
                        mToastForm.Show();
                    }));
                }
            }
            else
            {
                this.screenShareCheckBox.Checked = false;
            }
        }

        /// <summary>
        /// 开始发送采集的音频数据
        /// </summary>
        private void OnAudioTimerEvent(object sender, ElapsedEventArgs e)
        {
            if (mOtherSettingForm != null && mTRTCCloud != null)
                mOtherSettingForm.SendCustomAudioFrame();
        }

        /// <summary>
        /// 开始发送采集的视频数据
        /// </summary>
        public void OnVideoTimerEvent(object sender, ElapsedEventArgs e)
        {
            if (mOtherSettingForm != null && mTRTCCloud != null)
                mOtherSettingForm.SendCustomVideoFrame();
        }

        public void OnCustomCaptureAudioCallback(bool stop)
        {
            if (!stop)
            {
                // 开启自定义采集音频，停止本地采集音频
                mTRTCCloud.stopLocalAudio();
            }
            else
            {
                // 关闭自定义采集音频，开启本地采集音频
                if (this.startLocalAudioCheckBox.Checked)
                {
                    mTRTCCloud.startLocalAudio(DataManager.GetInstance().AudioQuality);
                }
                if (this.muteAudioCheckBox.Checked)
                    mTRTCCloud.muteLocalAudio(true);
                else
                    mTRTCCloud.muteLocalAudio(false);
            }
        }

        public void OnCustomCaptureVideoCallback(bool stop)
        {
            if (!stop)
            {
                // 开启自定义采集视频，停止本地采集视频，开启自定义渲染视频
                mTRTCCloud.stopLocalPreview();
                this.localInfoLabel.Visible = false;
                if (mRenderMode == 1)
                {
                    AddCustomVideoView(this.localVideoPanel, mUserId, TRTCVideoStreamType.TRTCVideoStreamTypeBig, true);
                }
            }
            else
            {
                // 关闭自定义采集视频，开启本地采集视频，关闭自定义渲染视频
                if (this.startLocalPreviewCheckBox.Checked)
                {
                    mTRTCCloud.startLocalPreview(mCameraVideoHandle);
                }
                else
                {
                    this.localInfoLabel.Visible = true;
                }
                if (mRenderMode == 1)
                {
                    RemoveCustomVideoView(this.localVideoPanel, mUserId, TRTCVideoStreamType.TRTCVideoStreamTypeBig, true);
                }
                if (this.muteVideoCheckBox.Checked)
                {
                    mTRTCCloud.muteLocalVideo(true);
                    this.localInfoLabel.Visible = true;
                }
                else
                {
                    mTRTCCloud.muteLocalVideo(false);
                }
            }
        }

        public void onCapturedAudioFrame(TRTCAudioFrame frame)
        {
            //throw new NotImplementedException();
        }

        public void onPlayAudioFrame(TRTCAudioFrame frame, string userId)
        {
            Log.I(String.Format("onPlayAudioFrame : userId = {0}", userId));
        }

        public void onMixedPlayAudioFrame(TRTCAudioFrame frame)
        {
            //throw new NotImplementedException();
        }
        public void onSwitchRoom(TXLiteAVError errCode, string errMsg)
        {
            Log.I(String.Format("onSwitchRoom : errCode = {0}, errMsg = {1}", errCode, errMsg));
        }

        public void onAudioDeviceCaptureVolumeChanged(uint volume, bool muted)
        {
            Log.I(String.Format("onAudioDeviceCaptureVolumeChanged : volume = {0}, muted = {1}", volume, muted));
        }

        public void onAudioDevicePlayoutVolumeChanged(uint volume, bool muted)
        {
            Log.I(String.Format("onAudioDevicePlayoutVolumeChanged : volume = {0}, muted = {1}", volume, muted));
        }

        private void vedioSettingLabel_Click(object sender, EventArgs e)
        {
            if (mVedioSettingForm == null)
                mVedioSettingForm = new VedioSettingForm(this);
            mVedioSettingForm.ShowDialog();
        }

        private void audioSettingLabel_Click(object sender, EventArgs e)
        {
            if (mAudioSettingForm == null)
                mAudioSettingForm = new AudioSettingForm(this);
            mAudioSettingForm.ShowDialog();
        }

        private void otherSettingLabel_Click(object sender, EventArgs e)
        {
            if (mOtherSettingForm == null)
                mOtherSettingForm = new OtherSettingForm(this);
            mOtherSettingForm.ShowDialog();
        }
    }
}
