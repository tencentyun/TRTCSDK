using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using ManageLiteAV;

namespace TRTCCSharpDemo
{
    public partial class VedioSettingForm : Form
    {
        private TRTCVideoEncParam mEncParam;
        private ITRTCDeviceCollection mCameraDeviceList;
        private ITRTCCloud mTRTCCloud;
        private ITXDeviceManager mDeviceManager;
        private ITRTCDeviceInfo mCameraDevice;
        private TRTCMainForm mMainForm;
        public VedioSettingForm(TRTCMainForm mainform)
        {
            InitializeComponent();
            this.Disposed += new EventHandler(OnDisposed);

            this.mTRTCCloud = DataManager.GetInstance().trtcCloud;
            this.mDeviceManager = mTRTCCloud.getDeviceManager();

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

            this.resolutionModeComboBox.Items.Add("横屏模式");
            this.resolutionModeComboBox.Items.Add("竖屏模式");

            mMainForm = mainform;
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
        public void OnDeviceChange(string deviceId, TRTCDeviceType type, TRTCDeviceState state)
        {
            if (type == TRTCDeviceType.TXMediaDeviceTypeCamera)
            {
                RefreshCameraDeviceList();
            }
        }
        private void OnDisposed(object sender, EventArgs e)
        {
            //清理资源
            if (mTRTCCloud == null) return;

            if (mCameraDeviceList != null)
                mCameraDeviceList.release();
            mCameraDeviceList = null;

            mTRTCCloud = null;
            mDeviceManager = null;
        }
        private void OnLoad(object sender, EventArgs e)
        {
            RefreshCameraDeviceList();
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

            if (mEncParam.resMode == TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape)
                this.resolutionModeComboBox.SelectedIndex = 0;
            else
                this.resolutionModeComboBox.SelectedIndex = 1;

            int bitrate = (int)mEncParam.videoBitrate;
            this.bitrateTrackBar.Value = bitrate;
            this.bitrateNumLabel.Text = bitrate + " kbps";

            this.saveBtn.Enabled = false;
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
        }

        private void RefreshCameraDeviceList()
        {
            if (mDeviceManager == null) return;
            this.cameraDeviceComboBox.Items.Clear();
            mCameraDeviceList = mDeviceManager.getDevicesList(TRTCDeviceType.TXMediaDeviceTypeCamera);
            if (mCameraDeviceList.getCount() <= 0)
            {
                this.cameraDeviceComboBox.Items.Add("");
                this.cameraDeviceComboBox.SelectionStart = this.cameraDeviceComboBox.Text.Length;
                return;
            }
            mCameraDevice = mDeviceManager.getCurrentDevice(TRTCDeviceType.TXMediaDeviceTypeCamera);
            for (uint i = 0; i < mCameraDeviceList.getCount(); i++)
            {
                this.cameraDeviceComboBox.Items.Add(mCameraDeviceList.getDeviceName(i));
                if (mCameraDevice.getDeviceName().Equals(mCameraDeviceList.getDeviceName(i)))
                    this.cameraDeviceComboBox.SelectedIndex = (int)i;
            }
            if (string.IsNullOrEmpty(mCameraDevice.getDeviceName()) && mCameraDeviceList.getCount() > 0)
                this.cameraDeviceComboBox.SelectedIndex = 0;
        }
        private void resolutionComboBox_SelectedIndexChanged(object sender, EventArgs e)
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

        private bool IsChanged()
        {
            if (DataManager.GetInstance().videoEncParams.videoResolution != mEncParam.videoResolution)
                return true;
            if (DataManager.GetInstance().videoEncParams.videoFps != mEncParam.videoFps)
                return true;
            if (DataManager.GetInstance().videoEncParams.resMode != mEncParam.resMode)
                return true;
            if (DataManager.GetInstance().videoEncParams.videoBitrate != mEncParam.videoBitrate)
                return true;

          
            return false;
        }

        private void cameraDeviceComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(this.cameraDeviceComboBox.Text)) return;
            for (uint i = 0; i < mCameraDeviceList.getCount(); i++)
            {
                if (mCameraDeviceList.getDeviceName(i).Equals(this.cameraDeviceComboBox.Text))
                {
                    mDeviceManager.setCurrentDevice(TRTCDeviceType.TXMediaDeviceTypeCamera, mCameraDeviceList.getDevicePID(i));
                    mMainForm.OnCameraDeviceChange(mCameraDeviceList.getDevicePID(i));
                }
            }
        }

        private void exitPicBox_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void fpsComboBox_SelectedIndexChanged(object sender, EventArgs e)
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

        private void confirmBtn_Click(object sender, EventArgs e)
        {
            TRTCVideoEncParam encParams = DataManager.GetInstance().videoEncParams;
            TRTCNetworkQosParam qosParams = DataManager.GetInstance().qosParams;
            TRTCAppScene appScene = DataManager.GetInstance().appScene;
            if (encParams.videoResolution != mEncParam.videoResolution || encParams.videoFps != mEncParam.videoFps
                || encParams.videoBitrate != mEncParam.videoBitrate || encParams.resMode != mEncParam.resMode)
            {
                mTRTCCloud.setVideoEncoderParam(ref mEncParam);
            }
          
            DataManager.GetInstance().videoEncParams = mEncParam;
          
            this.Close();
        }

        private void resolutionModeComboBox_SelectedIndexChanged(object sender, EventArgs e)
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

        private void bitrateTrackBar_Scroll(object sender, EventArgs e)
        {
            int bitrate = this.bitrateTrackBar.Value;
            this.bitrateNumLabel.Text = bitrate + " kbps";
            mEncParam.videoBitrate = (uint)bitrate;
            this.saveBtn.Enabled = this.IsChanged();
        }
    }
}
