using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using ManageLiteAV;
using TRTCWPFDemo;
using TRTCWPFDemo.Common;

namespace TRTCWPFDemo
{
    /// <summary>
    /// MainWindow.xaml 的交互逻辑
    /// </summary>
    public partial class MainWindow : Window, IDisposable, ITRTCCloudCallback
    {
        private ITRTCCloud mTRTCCloud;

        private bool mIsEnterSuccess;

        private string mUserId;          // 本地用户 Id
        private uint mRoomId;            // 房间 Id

        private Dictionary<string, TXLiteAVVideoView> mVideoViews;

        public MainWindow()
        {
            InitializeComponent();
            this.Closed += MainWindow_Closed;

            mTRTCCloud = DataManager.GetInstance().trtcCloud;
            mVideoViews = new Dictionary<string, TXLiteAVVideoView>();

            // 初始化 SDK 配置并设置回调
            Log.I(String.Format(" SDKVersion : {0}", mTRTCCloud.getSDKVersion()));
            mTRTCCloud.addCallback(this);
        }

        private void MainWindow_Closed(object sender, EventArgs e)
        {
            if (mIsEnterSuccess)
            {
                this.ExitRoom();
            }
        }

        public void Dispose()
        {
            // 清理资源
            mTRTCCloud = null;
        }

        public void EnterRoom()
        {
            // 设置进房所需的相关参数
            TRTCParams trtcParams = new TRTCParams();
            trtcParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
            trtcParams.roomId = DataManager.GetInstance().roomId;
            trtcParams.userId = DataManager.GetInstance().userId;
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

            // 设置默认参数配置
            TRTCVideoEncParam encParams = DataManager.GetInstance().videoEncParams;   // 视频编码参数设置
            TRTCNetworkQosParam qosParams = DataManager.GetInstance().qosParams;      // 网络流控相关参数设置
            mTRTCCloud.setVideoEncoderParam(ref encParams);
            mTRTCCloud.setNetworkQosParam(ref qosParams);
            mTRTCCloud.setLocalViewFillMode(DataManager.GetInstance().videoFillMode);
            mTRTCCloud.setLocalViewMirror(DataManager.GetInstance().isLocalVideoMirror);
            mTRTCCloud.setLocalViewRotation(DataManager.GetInstance().videoRotation);
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
            if (DataManager.GetInstance().playSmallVideo)
            {
                mTRTCCloud.setPriorRemoteVideoStreamType(TRTCVideoStreamType.TRTCVideoStreamTypeSmall);
            }
            // 房间信息
            mUserId = trtcParams.userId;
            mRoomId = trtcParams.roomId;
            this.infoLabel.Content = "房间号：" + mRoomId;

            // 本地主流自定义渲染 View 动态绑定和监听 SDK 渲染回调
            mTRTCCloud.startLocalPreview(IntPtr.Zero);
            AddCustomVideoView(this.videoContainer, mUserId, TRTCVideoStreamType.TRTCVideoStreamTypeBig, true);

            mTRTCCloud.startLocalAudio();
        }

        public void onUserVideoAvailable(string userId, bool available)
        {
            this.Dispatcher.BeginInvoke(new Action(() => {
                if (available)
                {
                    // 远端主流自定义渲染 View 动态绑定和监听 SDK 渲染回调
                    mTRTCCloud.startRemoteView(userId, IntPtr.Zero);
                    AddCustomVideoView(this.videoContainer, userId, TRTCVideoStreamType.TRTCVideoStreamTypeBig);
                }
                else
                {
                    // 远端主流自定义渲染 View 移除绑定
                    mTRTCCloud.stopRemoteView(userId);
                    RemoveCustomVideoView(this.videoContainer, userId, TRTCVideoStreamType.TRTCVideoStreamTypeBig);
                }
            }));
        }

        public void onUserSubStreamAvailable(string userId, bool available)
        {
            this.Dispatcher.BeginInvoke(new Action(() => {
                if (available)
                {
                    // 远端辅流自定义渲染 View 动态绑定和监听 SDK 渲染回调
                    mTRTCCloud.startRemoteSubStreamView(userId, IntPtr.Zero);
                    AddCustomVideoView(this.videoContainer, userId, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
                }
                else
                {
                    // 远端辅流自定义渲染 View 移除绑定
                    mTRTCCloud.stopRemoteSubStreamView(userId);
                    RemoveCustomVideoView(this.videoContainer, userId, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
                }
            }));
        }

        /// <summary>
        /// 添加自定义渲染 View 并绑定渲染回调
        /// </summary>
        private void AddCustomVideoView(Panel parent, string userId, TRTCVideoStreamType streamType, bool local = false)
        {
            TXLiteAVVideoView videoView = new TXLiteAVVideoView();
            videoView.RegEngine(userId, streamType, mTRTCCloud, local);
            videoView.SetRenderMode(DataManager.GetInstance().videoFillMode);
            videoView.Width = 320;
            videoView.Height = 240;
            videoView.Margin = new Thickness(5, 5, 5, 5);
            parent.Children.Add(videoView);
            string key = String.Format("{0}_{1}", userId, streamType);
            mVideoViews.Add(key, videoView);
        }

        /// <summary>
        /// 移除自定义渲染 View 并解绑渲染回调
        /// </summary>
        private void RemoveCustomVideoView(Panel parent, string userId, TRTCVideoStreamType streamType, bool local = false)
        {
            TXLiteAVVideoView videoView = null;
            string key = String.Format("{0}_{1}", userId, streamType);
            if (mVideoViews.TryGetValue(key, out videoView))
            {
                videoView.RemoveEngine(mTRTCCloud);
                parent.Children.Remove(videoView);
                mVideoViews.Remove(key);
            }
        }

        public void ExitRoom()
        {
            Uninit();
            mTRTCCloud.exitRoom();
        }

        /// <summary>
        /// 退房后执行的清理操作和关闭 SDK 内部功能。
        /// </summary>
        private void Uninit()
        {
            mTRTCCloud.stopAllRemoteView();
            mTRTCCloud.stopLocalPreview();
            foreach (var item in mVideoViews)
            {
                if (item.Value != null)
                {
                    item.Value.RemoveEngine(mTRTCCloud);
                    this.videoContainer.Children.Remove(item.Value);
                }
            }
            TXLiteAVVideoView.RemoveAllRegEngine();

            mTRTCCloud.stopLocalAudio();
            mTRTCCloud.muteLocalAudio(true);
            mTRTCCloud.muteLocalVideo(true);

            mTRTCCloud.removeCallback(this);
            mTRTCCloud.setLogCallback(null);
        }

        public void onError(TXLiteAVError errCode, string errMsg, IntPtr arg)
        {
            Log.E(String.Format("errCode : {0}, errMsg : {1}, arg = {2}", errCode, errMsg, arg));
        }

        public void onWarning(TXLiteAVWarning warningCode, string warningMsg, IntPtr arg)
        {
            Log.I(String.Format("warningCode : {0}, warningMsg : {1}, arg = {2}", warningCode, warningMsg, arg));
        }

        public void onEnterRoom(int result)
        {
            this.Dispatcher.Invoke(new Action(() => {
                if (result >= 0)
                {
                    // 开启本地音视频流
                    mTRTCCloud.muteLocalAudio(false);
                    mTRTCCloud.muteLocalVideo(false);
                    
                    // 进房成功
                    mIsEnterSuccess = true;
                }
                else
                {
                    // 进房失败
                    mIsEnterSuccess = false;
                    ShowMessage("进房失败，请重试");
                }
            }));
        }

        public void onStartPublishing(int errCode, string errMsg)
        {
           Log.I(String.Format("errCode : {0}, errorMsg : {1}", errCode, errMsg));
        }
        public void onStopPublishing(int errCode, string errMsg)
        {
            Log.I(String.Format("errCode : {0}, errorMsg : {1}", errCode, errMsg));
        }
        public void onExitRoom(int reason)
        {
            mIsEnterSuccess = false;
            this.Close();
        }

        #region ITRTCCloudCallback
        public void onSwitchRole(TXLiteAVError errCode, string errMsg)
        {
            
        }

        public void onConnectOtherRoom(string userId, TXLiteAVError errCode, string errMsg)
        {
            
        }

        public void onDisconnectOtherRoom(TXLiteAVError errCode, string errMsg)
        {
            
        }

        public void onUserEnter(string userId)
        {
            
        }

        public void onUserExit(string userId, int reason)
        {
            
        }

        public void onRemoteUserEnterRoom(string userId)
        {

        }

        public void onRemoteUserLeaveRoom(string userId, int reason)
        {

        }

        public void onUserAudioAvailable(string userId, bool available)
        {
            
        }

        public void onFirstVideoFrame(string userId, TRTCVideoStreamType streamType, int width, int height)
        {
            
        }

        public void onFirstAudioFrame(string userId)
        {
            
        }

        public void onSendFirstLocalVideoFrame(TRTCVideoStreamType streamType)
        {
            
        }

        public void onSendFirstLocalAudioFrame()
        {
            
        }

        public void onNetworkQuality(TRTCQualityInfo localQuality, TRTCQualityInfo[] remoteQuality, uint remoteQualityCount)
        {
            
        }

        public void onStatistics(TRTCStatistics statis)
        {
            
        }

        public void onConnectionLost()
        {
            
        }

        public void onTryToReconnect()
        {
            
        }

        public void onConnectionRecovery()
        {
            
        }

        public void onSpeedTest(TRTCSpeedTestResult currentResult, uint finishedCount, uint totalCount)
        {
            
        }

        public void onCameraDidReady()
        {
            
        }

        public void onMicDidReady()
        {
            
        }

        public void onUserVoiceVolume(TRTCVolumeInfo[] userVolumes, uint userVolumesCount, uint totalVolume)
        {
            
        }

        public void onDeviceChange(string deviceId, TRTCDeviceType type, TRTCDeviceState state)
        {
            
        }

        public void onTestMicVolume(uint volume)
        {
            
        }

        public void onTestSpeakerVolume(uint volume)
        {
            
        }

        public void onRecvCustomCmdMsg(string userId, int cmdID, uint seq, byte[] msg, uint msgSize)
        {
            
        }

        public void onMissCustomCmdMsg(string userId, int cmdId, int errCode, int missed)
        {
            
        }

        public void onRecvSEIMsg(string userId, byte[] message, uint msgSize)
        {
            
        }

        public void onStartPublishCDNStream(int errCode, string errMsg)
        {
            
        }

        public void onStopPublishCDNStream(int errCode, string errMsg)
        {
            
        }

        public void onSetMixTranscodingConfig(int errCode, string errMsg)
        {
            
        }

        public void onScreenCaptureCovered()
        {
            
        }

        public void onScreenCaptureStarted()
        {
            
        }

        public void onScreenCapturePaused(int reason)
        {
            
        }

        public void onScreenCaptureResumed(int reason)
        {
            
        }

        public void onScreenCaptureStoped(int reason)
        {
            
        }

        public void onPlayBGMBegin(TXLiteAVError errCode)
        {
            
        }

        public void onPlayBGMProgress(uint progressMS, uint durationMS)
        {
            
        }

        public void onPlayBGMComplete(TXLiteAVError errCode)
        {
            
        }

        public void onAudioEffectFinished(int effectId, int code)
        {

        }

        #endregion

        private void ShowMessage(string message)
        {
            MessageBox.Show(message);
        }

        public void onSwitchRoom(TXLiteAVError errCode, string errMsg)
        {
        }

        public void onAudioDeviceCaptureVolumeChanged(uint volume, bool muted)
        {
        }

        public void onAudioDevicePlayoutVolumeChanged(uint volume, bool muted)
        {
        }
    }
}
