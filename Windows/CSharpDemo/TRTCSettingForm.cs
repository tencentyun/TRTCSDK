using System;
using System.Drawing;
using System.Windows.Forms;
using ManageLiteAV;

/// <summary>
/// Module:   TRTCSettingForm
/// 
/// Function: 用于对视频通话的分辨率、帧率和流畅模式进行调整，并支持记录下这些设置项
/// </summary>
namespace TRTCCSharpDemo
{
    public partial class TRTCSettingForm : Form
    {
        private ITRTCCloud mTRTCCloud;

        private TRTCVideoEncParam mEncParam;
        private TRTCNetworkQosParam mQosParams;
        private TRTCAppScene mAppScene;
        private bool mPlaySmallVideo;
        private bool mPushSmallVideo;

        public TRTCSettingForm()
        {
            InitializeComponent();

            this.Disposed += new EventHandler(OnDisposed);

            this.mTRTCCloud = DataManager.GetInstance().trtcCloud;

            this.resolutionComboBox.Items.Add("120 x 120");
            this.resolutionComboBox.Items.Add("160 x 160");
            this.resolutionComboBox.Items.Add("270 x 270");
            this.resolutionComboBox.Items.Add("480 x 480");
            this.resolutionComboBox.Items.Add("160 x 120");
            this.resolutionComboBox.Items.Add("240 x 180");
            this.resolutionComboBox.Items.Add("280 x 210");
            this.resolutionComboBox.Items.Add("320 x 240");
            this.resolutionComboBox.Items.Add("400 x 300");
            this.resolutionComboBox.Items.Add("480 x 360");
            this.resolutionComboBox.Items.Add("640 x 480");
            this.resolutionComboBox.Items.Add("960 x 720");
            this.resolutionComboBox.Items.Add("160 x 90");
            this.resolutionComboBox.Items.Add("256 x 144");
            this.resolutionComboBox.Items.Add("320 x 180");
            this.resolutionComboBox.Items.Add("480 x 270");
            this.resolutionComboBox.Items.Add("640 x 360");
            this.resolutionComboBox.Items.Add("960 x 540");
            this.resolutionComboBox.Items.Add("1280 x 720");

            this.fpsComboBox.Items.Add("15 fps");
            this.fpsComboBox.Items.Add("20 fps");
            this.fpsComboBox.Items.Add("24 fps");

            this.qosComboBox.Items.Add("优先流畅");
            this.qosComboBox.Items.Add("优先清晰");

            this.sceneComboBox.Items.Add("在线直播");
            this.sceneComboBox.Items.Add("视频通话");

            this.controlComboBox.Items.Add("客户端控");
            this.controlComboBox.Items.Add("云端流控");

            this.resolutionModeComboBox.Items.Add("横屏模式");
            this.resolutionModeComboBox.Items.Add("竖屏模式");
        }

        private void OnDisposed(object sender, EventArgs e)
        {
            //清理资源
            mTRTCCloud = null;
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

        private void OnLoad(object sender, EventArgs e)
        {
            InitData();
            int selectedIndex = -1;
            if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_120_120)
                selectedIndex = 0;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_160_160)
                selectedIndex = 1;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_270_270)
                selectedIndex = 2;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_480_480)
                selectedIndex = 3;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_160_120)
                selectedIndex = 4;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_240_180)
                selectedIndex = 5;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_280_210)
                selectedIndex = 6;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_320_240)
                selectedIndex = 7;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_400_300)
                selectedIndex = 8;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_480_360)
                selectedIndex = 9;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_640_480)
                selectedIndex = 10;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_960_720)
                selectedIndex = 11;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_160_90)
                selectedIndex = 12;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_256_144)
                selectedIndex = 13;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_320_180)
                selectedIndex = 14;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_480_270)
                selectedIndex = 15;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_640_360)
                selectedIndex = 16;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_960_540)
                selectedIndex = 17;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_1280_720)
                selectedIndex = 18;
            this.resolutionComboBox.SelectedIndex = selectedIndex;

            if (mEncParam.videoFps == 15)
                this.fpsComboBox.SelectedIndex = 0;
            else if (mEncParam.videoFps == 20)
                this.fpsComboBox.SelectedIndex = 1;
            else if (mEncParam.videoFps == 24)
                this.fpsComboBox.SelectedIndex = 2;
            
            if (mQosParams.preference == TRTCVideoQosPreference.TRTCVideoQosPreferenceSmooth)
                this.qosComboBox.SelectedIndex = 0;
            else if (mQosParams.preference == TRTCVideoQosPreference.TRTCVideoQosPreferenceClear)
                this.qosComboBox.SelectedIndex = 1;

            if (mQosParams.controlMode == TRTCQosControlMode.TRTCQosControlModeClient)
                this.controlComboBox.SelectedIndex = 0;
            else if (mQosParams.controlMode == TRTCQosControlMode.TRTCQosControlModeServer)
                this.controlComboBox.SelectedIndex = 1;
            
            if (mAppScene == TRTCAppScene.TRTCAppSceneLIVE)
                this.sceneComboBox.SelectedIndex = 0;
            else if (mAppScene == TRTCAppScene.TRTCAppSceneVideoCall)
                this.sceneComboBox.SelectedIndex = 1;

            if (mEncParam.resMode == TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape)
                this.resolutionModeComboBox.SelectedIndex = 0;
            else
                this.resolutionModeComboBox.SelectedIndex = 1;

            int bitrate = (int)mEncParam.videoBitrate;
            this.bitrateTrackBar.Value = bitrate;
            this.bitrateNumLabel.Text = bitrate + " kbps";
            
            this.playTypeCheckBox.Checked = mPlaySmallVideo;
            this.pushTypeCheckBox.Checked = mPushSmallVideo;

            this.saveBtn.Enabled = false;
        }

        private void OnSaveBtnClick(object sender, EventArgs e)
        {
            TRTCVideoEncParam encParams = DataManager.GetInstance().videoEncParams;
            TRTCNetworkQosParam qosParams = DataManager.GetInstance().qosParams;
            TRTCAppScene appScene = DataManager.GetInstance().appScene;
            if (encParams.videoResolution != mEncParam.videoResolution || encParams.videoFps != mEncParam.videoFps 
                || encParams.videoBitrate != mEncParam.videoBitrate || encParams.resMode != mEncParam.resMode)
            {
                mTRTCCloud.setVideoEncoderParam(ref mEncParam);
            }
            if(qosParams.controlMode != mQosParams.controlMode || qosParams.preference != mQosParams.preference)
            {
                mTRTCCloud.setNetworkQosParam(ref mQosParams);
            }
            bool pushSmallVideo = DataManager.GetInstance().pushSmallVideo;
            if(pushSmallVideo != mPushSmallVideo)
            {
                TRTCVideoEncParam param = new TRTCVideoEncParam()
                {
                    videoFps = 15,
                    videoBitrate = 100,
                    videoResolution = TRTCVideoResolution.TRTCVideoResolution_320_240,
                    resMode = TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape
                };
                bool enable = true;
                if (mPushSmallVideo == false)
                    enable = false;
                mTRTCCloud.enableSmallVideoStream(enable, ref param);
            }
            bool playSmallVideo = DataManager.GetInstance().playSmallVideo;
            if(playSmallVideo != mPlaySmallVideo)
            {
                if (mPlaySmallVideo)
                    mTRTCCloud.setPriorRemoteVideoStreamType(TRTCVideoStreamType.TRTCVideoStreamTypeSmall);
                else
                    mTRTCCloud.setPriorRemoteVideoStreamType(TRTCVideoStreamType.TRTCVideoStreamTypeBig);
            }

            DataManager.GetInstance().videoEncParams = mEncParam;
            DataManager.GetInstance().qosParams = mQosParams;
            DataManager.GetInstance().appScene = mAppScene;
            DataManager.GetInstance().playSmallVideo = mPlaySmallVideo;
            DataManager.GetInstance().pushSmallVideo = mPushSmallVideo;

            this.Hide();
        }

        private void OnCancelBtnClick(object sender, EventArgs e)
        {
            this.Hide();
        }

        private void InitData()
        {
            mEncParam = new TRTCVideoEncParam()
            {
                videoBitrate = DataManager.GetInstance().videoEncParams.videoBitrate,
                videoFps = DataManager.GetInstance().videoEncParams.videoFps,
                videoResolution = DataManager.GetInstance().videoEncParams.videoResolution,
                resMode = DataManager.GetInstance().videoEncParams.resMode
            };
            mQosParams = new TRTCNetworkQosParam()
            {
                preference = DataManager.GetInstance().qosParams.preference,
                controlMode = DataManager.GetInstance().qosParams.controlMode
            };
            mAppScene = DataManager.GetInstance().appScene;
            mPlaySmallVideo = DataManager.GetInstance().playSmallVideo;
            mPushSmallVideo = DataManager.GetInstance().pushSmallVideo;
        }

        private void OnBitrateTrackBarScroll(object sender, EventArgs e)
        {
            int bitrate = this.bitrateTrackBar.Value;
            this.bitrateNumLabel.Text = bitrate + " kbps";
            mEncParam.videoBitrate = (uint)bitrate;
            this.saveBtn.Enabled = this.IsChanged();
        }

        private void OnResolutionSelectedIndexChanged(object sender, EventArgs e)
        {
            int index = this.resolutionComboBox.SelectedIndex;
            if (index == 0)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_120_120;
            else if (index == 1)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_160_160;
            else if (index == 2)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_270_270;
            else if (index == 3)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_480_480;
            else if (index == 4)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_160_120;
            else if (index == 5)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_240_180;
            else if (index == 6)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_280_210;
            else if (index == 7)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_320_240;
            else if (index == 8)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_400_300;
            else if (index == 9)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_480_360;
            else if (index == 10)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_640_480;
            else if (index == 11)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_960_720;
            else if (index == 12)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_160_90;
            else if (index == 13)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_256_144;
            else if (index == 14)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_320_180;
            else if (index == 15)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_480_270;
            else if (index == 16)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_640_360;
            else if (index == 17)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_960_540;
            else if (index == 18)
                mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_1280_720;
            this.saveBtn.Enabled = this.IsChanged();
        }

        private void OnFpsSelectedIndexChanged(object sender, EventArgs e)
        {
            int index = this.fpsComboBox.SelectedIndex;
            switch (index)
            {
                case 0:
                    mEncParam.videoFps = 15;
                    break;
                case 1:
                    mEncParam.videoFps = 20;
                    break;
                case 2:
                    mEncParam.videoFps = 24;
                    break;
            }
            this.saveBtn.Enabled = this.IsChanged();
        }

        private void OnQosSelectedIndexChanged(object sender, EventArgs e)
        {
            int index = this.qosComboBox.SelectedIndex;
            switch (index)
            {
                case 0:
                    mQosParams.preference = TRTCVideoQosPreference.TRTCVideoQosPreferenceSmooth;
                    break;
                case 1:
                    mQosParams.preference = TRTCVideoQosPreference.TRTCVideoQosPreferenceClear;
                    break;
            }
            this.saveBtn.Enabled = this.IsChanged();
        }

        private void OnSceneSelectedIndexChanged(object sender, EventArgs e)
        {
            int index = this.sceneComboBox.SelectedIndex;
            switch (index)
            {
                case 0:
                    mAppScene = TRTCAppScene.TRTCAppSceneLIVE;
                    break;
                case 1:
                    mAppScene = TRTCAppScene.TRTCAppSceneVideoCall;
                    break;
            }
            this.saveBtn.Enabled = this.IsChanged();
        }

        private void OnPushTypeCheckedChanged(object sender, EventArgs e)
        {
            mPushSmallVideo = this.pushTypeCheckBox.Checked;
            this.saveBtn.Enabled = this.IsChanged();
        }

        private void OnPlayTypeCheckedChanged(object sender, EventArgs e)
        {
            mPlaySmallVideo = this.playTypeCheckBox.Checked;
            this.saveBtn.Enabled = this.IsChanged();
        }

        private bool IsChanged()
        {
            if (DataManager.GetInstance().videoEncParams.videoResolution != mEncParam.videoResolution)
                return true;
            if (DataManager.GetInstance().videoEncParams.videoFps != mEncParam.videoFps)
                return true;
            if (DataManager.GetInstance().videoEncParams.resMode != mEncParam.resMode)
                return true;
            if (DataManager.GetInstance().qosParams.preference != mQosParams.preference)
                return true;
            if (DataManager.GetInstance().qosParams.controlMode != mQosParams.controlMode)
                return true;
            if (DataManager.GetInstance().appScene != mAppScene)
                return true;
            if (DataManager.GetInstance().videoEncParams.videoBitrate != mEncParam.videoBitrate)
                return true;
            if (DataManager.GetInstance().playSmallVideo != mPlaySmallVideo)
                return true;
            if (DataManager.GetInstance().pushSmallVideo != mPushSmallVideo)
                return true;
            return false;
        }

        private void OnControlComboBoxSelectedIndexChanged(object sender, EventArgs e)
        {
            int index = this.controlComboBox.SelectedIndex;
            switch (index)
            {
                case 0:
                    mQosParams.controlMode = TRTCQosControlMode.TRTCQosControlModeClient;
                    break;
                case 1:
                    mQosParams.controlMode = TRTCQosControlMode.TRTCQosControlModeServer;
                    break;
            }
            this.saveBtn.Enabled = this.IsChanged();
        }

        private void OnResolutionModeComboBoxSelectedIndexChanged(object sender, EventArgs e)
        {
            int index = this.resolutionModeComboBox.SelectedIndex;
            switch (index)
            {
                case 0:
                    mEncParam.resMode = TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape;
                    break;
                case 1:
                    mEncParam.resMode = TRTCVideoResolutionMode.TRTCVideoResolutionModePortrait;
                    break;
            }
            this.saveBtn.Enabled = this.IsChanged();
        }

        private void OnExitPicBoxClick(object sender, EventArgs e)
        {
            this.Hide();
        }

        
    }
}
