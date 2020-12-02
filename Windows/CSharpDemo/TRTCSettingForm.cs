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

            this.qosComboBox.Items.Add("优先流畅");
            this.qosComboBox.Items.Add("优先清晰");

            this.sceneComboBox.Items.Add("在线直播");
            this.sceneComboBox.Items.Add("视频通话");

            this.controlComboBox.Items.Add("客户端控");
            this.controlComboBox.Items.Add("云端流控");
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

            this.playTypeCheckBox.Checked = mPlaySmallVideo;
            this.pushTypeCheckBox.Checked = mPushSmallVideo;

            this.saveBtn.Enabled = false;
        }

        private void OnSaveBtnClick(object sender, EventArgs e)
        {

            TRTCNetworkQosParam qosParams = DataManager.GetInstance().qosParams;
            TRTCAppScene appScene = DataManager.GetInstance().appScene;

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
            if (playSmallVideo != mPlaySmallVideo)
            {
                if (mPlaySmallVideo)
                    mTRTCCloud.setPriorRemoteVideoStreamType(TRTCVideoStreamType.TRTCVideoStreamTypeSmall);
                else
                    mTRTCCloud.setPriorRemoteVideoStreamType(TRTCVideoStreamType.TRTCVideoStreamTypeBig);
            }

            DataManager.GetInstance().qosParams = mQosParams;
            DataManager.GetInstance().appScene = mAppScene;
            DataManager.GetInstance().playSmallVideo = mPlaySmallVideo;
            DataManager.GetInstance().pushSmallVideo = mPushSmallVideo;

            this.Close();
        }

        private void OnCancelBtnClick(object sender, EventArgs e)
        {
            this.Hide();
        }

        private void InitData()
        {
           
            mQosParams = new TRTCNetworkQosParam()
            {
                preference = DataManager.GetInstance().qosParams.preference,
                controlMode = DataManager.GetInstance().qosParams.controlMode
            };
            mAppScene = DataManager.GetInstance().appScene;
            mPlaySmallVideo = DataManager.GetInstance().playSmallVideo;
            mPushSmallVideo = DataManager.GetInstance().pushSmallVideo;
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
            if (DataManager.GetInstance().qosParams.preference != mQosParams.preference)
                return true;
            if (DataManager.GetInstance().qosParams.controlMode != mQosParams.controlMode)
                return true;
            if (DataManager.GetInstance().appScene != mAppScene)
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

        private void OnExitPicBoxClick(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
