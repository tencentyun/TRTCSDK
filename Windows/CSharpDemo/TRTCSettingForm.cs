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
using System.IO;
using System.Xml.Serialization;

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

        public TRTCSettingForm(ITRTCCloud cloud)
        {
            InitializeComponent();

            this.Disposed += new EventHandler(OnDisposed);

            this.mTRTCCloud = cloud;

            this.resolutionComboBox.Items.Add("320 x 180");
            this.resolutionComboBox.Items.Add("320 x 240");
            this.resolutionComboBox.Items.Add("640 x 360");
            this.resolutionComboBox.Items.Add("640 x 480");
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
            if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_320_180)
                this.resolutionComboBox.SelectedIndex = 0;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_320_240)
                this.resolutionComboBox.SelectedIndex = 1;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_640_360)
                this.resolutionComboBox.SelectedIndex = 2;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_640_480)
                this.resolutionComboBox.SelectedIndex = 3;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_960_540)
                this.resolutionComboBox.SelectedIndex = 4;
            else if (mEncParam.videoResolution == TRTCVideoResolution.TRTCVideoResolution_1280_720)
                this.resolutionComboBox.SelectedIndex = 5;
            
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

            int bitrate = (int)mEncParam.videoBitrate;
            this.bitrateTrackBar.Value = bitrate;
            this.bitrateNumLabel.Text = bitrate + " kbps";
            
            this.playTypeCheckBox.Checked = mPlaySmallVideo;
            this.pushTypeCheckBox.Checked = mPushSmallVideo;

            this.saveBtn.Enabled = false;
        }

        private void OnSaveBtnClick(object sender, EventArgs e)
        {
            PropertySaver saver = PropertySaver.GetInstance();
            TRTCVideoEncParam encParams = saver.encParams;
            TRTCNetworkQosParam qosParams = saver.qosParams;
            TRTCAppScene appScene = saver.appScene;
            if (encParams.videoResolution != mEncParam.videoResolution || encParams.videoFps != mEncParam.videoFps || encParams.videoBitrate != mEncParam.videoBitrate)
            {
                mTRTCCloud.setVideoEncoderParam(ref mEncParam);
            }
            if(qosParams.controlMode != mQosParams.controlMode || qosParams.preference != mQosParams.preference)
            {
                mTRTCCloud.setNetworkQosParam(ref mQosParams);
            }
            bool pushSmallVideo = saver.pushSmallVideo;
            if(pushSmallVideo != mPushSmallVideo)
            {
                TRTCVideoEncParam param = new TRTCVideoEncParam()
                {
                    videoFps = 15,
                    videoBitrate = 100,
                    videoResolution = TRTCVideoResolution.TRTCVideoResolution_320_240
                };
                bool enable = true;
                if (mPushSmallVideo == false)
                    enable = false;
                mTRTCCloud.enableSmallVideoStream(enable, ref param);
            }
            bool playSmallVideo = saver.playSmallVideo;
            if(playSmallVideo != mPlaySmallVideo)
            {
                if (mPlaySmallVideo)
                    mTRTCCloud.setPriorRemoteVideoStreamType(TRTCVideoStreamType.TRTCVideoStreamTypeSmall);
                else
                    mTRTCCloud.setPriorRemoteVideoStreamType(TRTCVideoStreamType.TRTCVideoStreamTypeBig);
            }

            saver.encParams = mEncParam;
            saver.qosParams = mQosParams;
            saver.appScene = mAppScene;
            saver.playSmallVideo = mPlaySmallVideo;
            saver.pushSmallVideo = mPushSmallVideo;

            PropertySaver.GetInstance().SaveProperty();

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
                videoBitrate = PropertySaver.GetInstance().encParams.videoBitrate,
                videoFps = PropertySaver.GetInstance().encParams.videoFps,
                videoResolution = PropertySaver.GetInstance().encParams.videoResolution,
                resMode = PropertySaver.GetInstance().encParams.resMode
            };
            mQosParams = new TRTCNetworkQosParam()
            {
                preference = PropertySaver.GetInstance().qosParams.preference,
                controlMode = PropertySaver.GetInstance().qosParams.controlMode
            };
            mAppScene = PropertySaver.GetInstance().appScene;
            mPlaySmallVideo = PropertySaver.GetInstance().playSmallVideo;
            mPushSmallVideo = PropertySaver.GetInstance().pushSmallVideo;
        }

        private void OnBitrateTrackBarScroll(object sender, EventArgs e)
        {
            int bitrate = this.bitrateTrackBar.Value;
            this.bitrateNumLabel.Text = bitrate + " kbps";
            mEncParam.videoBitrate = (uint)bitrate;
            bool changed = this.IsChanged();
            this.saveBtn.Enabled = changed;
        }

        private void OnResolutionSelectedIndexChanged(object sender, EventArgs e)
        {
            int index = this.resolutionComboBox.SelectedIndex;
            switch(index)
            {
                case 0:
                    mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_320_180;
                    break;
                case 1:
                    mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_320_240;
                    break;
                case 2:
                    mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_640_360;
                    break;
                case 3:
                    mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_640_480;
                    break;
                case 4:
                    mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_960_540;
                    break;
                case 5:
                    mEncParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_1280_720;
                    break;
            }
            bool changed = this.IsChanged();
            this.saveBtn.Enabled = changed;
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
            bool changed = this.IsChanged();
            this.saveBtn.Enabled = changed;
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
            bool changed = this.IsChanged();
            this.saveBtn.Enabled = changed;
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
            bool changed = this.IsChanged();
            this.saveBtn.Enabled = changed;
        }

        private void OnPushTypeCheckedChanged(object sender, EventArgs e)
        {
            mPushSmallVideo = this.pushTypeCheckBox.Checked;
            bool changed = this.IsChanged();
            this.saveBtn.Enabled = changed;
        }

        private void OnPlayTypeCheckedChanged(object sender, EventArgs e)
        {
            mPlaySmallVideo = this.playTypeCheckBox.Checked;
            bool changed = this.IsChanged();
            this.saveBtn.Enabled = changed;
        }

        private bool IsChanged()
        {
            if (PropertySaver.GetInstance().encParams.videoResolution != mEncParam.videoResolution)
                return true;
            if (PropertySaver.GetInstance().encParams.videoFps != mEncParam.videoFps)
                return true;
            if (PropertySaver.GetInstance().qosParams.preference != mQosParams.preference)
                return true;
            if (PropertySaver.GetInstance().qosParams.controlMode != mQosParams.controlMode)
                return true;
            if (PropertySaver.GetInstance().appScene != mAppScene)
                return true;
            if(PropertySaver.GetInstance().encParams.videoBitrate != mEncParam.videoBitrate)
                return true;
            if (PropertySaver.GetInstance().playSmallVideo != mPlaySmallVideo)
                return true;
            if(PropertySaver.GetInstance().pushSmallVideo != mPushSmallVideo)
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
            bool changed = this.IsChanged();
            this.saveBtn.Enabled = changed;
        }
    }

    /// <summary>
    /// 主要用于存储 TRTCSettingFrom 中设置的相关音视频属性，本地存储
    /// </summary>
    [Serializable]
    public class PropertySaver
    {
        private static PropertySaver mInstance;

        private const string FILEPATH = "./property.xml";
        private XmlSerializer ser = new XmlSerializer(typeof(PropertySaver));

        // 视频流控类型
        public TRTCVideoEncParam encParams { get; set; }
        public TRTCNetworkQosParam qosParams { get; set; }
        public TRTCAppScene appScene { get; set; }

        //推流打开推双流标志
        public bool pushSmallVideo { get; set; }
        //默认拉低请视频流标志
        public bool playSmallVideo { get; set; }  
        
        public static PropertySaver GetInstance()
        {
            if (mInstance == null)
            {
                mInstance = new PropertySaver();
            }
            return mInstance;
        }
        private PropertySaver()
        {
            LoadProperty();
        }
        
        // 初始化SDK的local配置信息
        private void InitSDKProperty()
        {
            encParams = new TRTCVideoEncParam
            {
                videoResolution = TRTCVideoResolution.TRTCVideoResolution_640_360,
                videoFps = 15,
                videoBitrate = 500
            };
            qosParams = new TRTCNetworkQosParam
            {
                preference = TRTCVideoQosPreference.TRTCVideoQosPreferenceClear,
                controlMode = TRTCQosControlMode.TRTCQosControlModeServer
            };
            appScene = TRTCAppScene.TRTCAppSceneVideoCall;
            pushSmallVideo = false;
            playSmallVideo = false;
        }
        
        private void LoadProperty()
        {
            try
            {
                if (File.Exists(FILEPATH))
                {
                    FileStream fs = new FileStream(FILEPATH, FileMode.Open);
                    PropertySaver saver = (PropertySaver)ser.Deserialize(fs);
                    encParams = saver.encParams;
                    qosParams = saver.qosParams;
                    appScene = saver.appScene;
                    pushSmallVideo = saver.pushSmallVideo;
                    playSmallVideo = saver.playSmallVideo;
                    fs.Close();
                }
                else
                {
                    InitSDKProperty();
                    FileStream fs = new FileStream(FILEPATH, FileMode.CreateNew);
                    TextWriter tw = new StreamWriter(fs);
                    ser.Serialize(tw, this);
                    tw.Close();
                    fs.Close();
                }
            }
            catch (Exception e)
            {
                Log.E(e.Message);
            }
        }

        public void SaveProperty()
        {
            try
            {
                FileStream fs = new FileStream(FILEPATH, FileMode.Create);
                TextWriter tw = new StreamWriter(fs);
                ser.Serialize(tw, this);
                tw.Close();
                fs.Close();
            }
            catch (Exception e)
            {
                Log.E(e.Message);
            }
        }
    }
}
