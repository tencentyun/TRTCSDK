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

namespace TRTCCSharpDemo
{
    public partial class TRTCDeviceForm : Form
    {
        private ITRTCCloud mTRTCCloud;
        private TRTCMainForm mMainForm;
        private ITRTCDeviceInfo mCameraDevice;
        private ITRTCDeviceInfo mMicDevice;
        private ITRTCDeviceInfo mSpeakerDevice;
        private ITRTCDeviceCollection mCameraDeviceList;
        private ITRTCDeviceCollection mMicDeviceList;
        private ITRTCDeviceCollection mSpeakerDeviceList;

        private int mMicVolume;
        private int mSpeakerVolume;

        public TRTCDeviceForm(ITRTCCloud cloud, TRTCMainForm mainform)
        {
            InitializeComponent();

            this.Disposed += new EventHandler(OnDisposed);

            mTRTCCloud = cloud;
            mMainForm = mainform;
        }

        private void OnDisposed(object sender, EventArgs e)
        {
            //清理资源
            mCameraDevice.release();
            mMicDevice.release();
            mSpeakerDevice.release();
            mCameraDeviceList.release();
            mMicDeviceList.release();
            mSpeakerDeviceList.release();
            mCameraDevice = null;
            mMicDevice = null;
            mSpeakerDevice = null;
            mCameraDeviceList = null;
            mMicDeviceList = null;
            mSpeakerDeviceList = null;
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
            RefreshCameraDeviceList();
            RefreshMicDeviceList();
            RefreshSpeakerList();

            mMicVolume = (int)mTRTCCloud.getCurrentMicDeviceVolume();
            this.micVolumeTrackBar.Value = mMicVolume;
            this.micVolumeNumLabel.Text = mMicVolume + "%";
            
            mSpeakerVolume = (int)mTRTCCloud.getCurrentSpeakerVolume();
            this.speakerVolumeTrackBar.Value = mSpeakerVolume;
            this.speakerVolumeNumLabel.Text = mSpeakerVolume + "%";
        }

        private void RefreshCameraDeviceList()
        {
            if (mTRTCCloud == null) return;
            this.cameraDeviceComboBox.Items.Clear();
            mCameraDevice = mTRTCCloud.getCurrentCameraDevice();
            Log.I(String.Format("CurrentCameraDevice: pid = {0}, name = {1}", mCameraDevice.getDevicePID(), mCameraDevice.getDeviceName()));
            mCameraDeviceList = mTRTCCloud.getCameraDevicesList();
            for (uint i = 0; i < mCameraDeviceList.getCount(); i++)
            {
                this.cameraDeviceComboBox.Items.Add(mCameraDeviceList.getDeviceName(i));
                if (mCameraDevice.getDeviceName().Equals(mCameraDeviceList.getDeviceName(i)))
                    this.cameraDeviceComboBox.SelectedIndex = (int)i;
                Log.I(String.Format("CameraDevice{0} : name = {1}, pid = {2}", i + 1, mCameraDeviceList.getDeviceName(i), mCameraDeviceList.getDevicePID(i)));
            }
            if (string.IsNullOrEmpty(mCameraDevice.getDeviceName()) && mCameraDeviceList.getCount() > 0)
                this.cameraDeviceComboBox.SelectedIndex = 0;
        }

        private void RefreshMicDeviceList()
        {
            if (mTRTCCloud == null) return;
            this.micDeviceComboBox.Items.Clear();
            mMicDevice = mTRTCCloud.getCurrentMicDevice();
            Log.I(String.Format("CurrentMicDevice: pid = {0}, name = {1}", mMicDevice.getDevicePID(), mMicDevice.getDeviceName()));
            mMicDeviceList = mTRTCCloud.getMicDevicesList();
            for (uint i = 0; i < mMicDeviceList.getCount(); i++)
            {
                this.micDeviceComboBox.Items.Add(mMicDeviceList.getDeviceName(i));
                if (mMicDevice.getDeviceName().Equals(mMicDeviceList.getDeviceName(i)))
                    this.micDeviceComboBox.SelectedIndex = (int)i;
                Log.I(String.Format("MicDevice{0} : name = {1}, pid = {2}", i + 1, mMicDeviceList.getDeviceName(i), mMicDeviceList.getDevicePID(i)));
            }
        }

        private void RefreshSpeakerList()
        {
            if (mTRTCCloud == null) return;
            this.speakerDeviceComboBox.Items.Clear();
            mSpeakerDevice = mTRTCCloud.getCurrentSpeakerDevice();

            Log.I(String.Format("CurrentSpeakerDevice: pid = {0}, name = {1}", mSpeakerDevice.getDevicePID(), mSpeakerDevice.getDeviceName()));
            mSpeakerDeviceList = mTRTCCloud.getSpeakerDevicesList();
            for (uint i = 0; i < mSpeakerDeviceList.getCount(); i++)
            {
                this.speakerDeviceComboBox.Items.Add(mSpeakerDeviceList.getDeviceName(i));
                if (mSpeakerDevice.getDeviceName().Equals(mSpeakerDeviceList.getDeviceName(i)))
                    this.speakerDeviceComboBox.SelectedIndex = (int)i;
                Log.I(String.Format("SpeakerDevice{0} : name = {1}, pid = {2}", i + 1, mSpeakerDeviceList.getDeviceName(i), mSpeakerDeviceList.getDevicePID(i)));
            }
        }

        private void OnMicVolumeTrackBarScroll(object sender, EventArgs e)
        {
            mMicVolume = this.micVolumeTrackBar.Value;
            this.micVolumeNumLabel.Text = mMicVolume + "%";
            mTRTCCloud.setCurrentMicDeviceVolume((uint)(mMicVolume * 100 / 100));
        }

        private void OnSpeakerVolumeTrackBarScroll(object sender, EventArgs e)
        {
            mSpeakerVolume = this.speakerVolumeTrackBar.Value;
            this.speakerVolumeNumLabel.Text = mSpeakerVolume + "%";
            mTRTCCloud.setCurrentSpeakerVolume((uint)(mSpeakerVolume * 100 / 100));
        }

        public void OnDeviceChange(string deviceId, TRTCDeviceType type, TRTCDeviceState state)
        {
            if (type == TRTCDeviceType.TRTCDeviceTypeCamera)
            {
                RefreshCameraDeviceList();
            }
            else if (type == TRTCDeviceType.TRTCDeviceTypeMic)
            {
                RefreshMicDeviceList();
            }
            else if (type == TRTCDeviceType.TRTCDeviceTypeSpeaker)
            {
                RefreshSpeakerList();
            }
        }

        private void OnConfirmBtnClick(object sender, EventArgs e)
        {
            this.Hide();
        }

        private void OnCameraDeviceComboBoxSelectedIndexChanged(object sender, EventArgs e)
        {
            for (uint i = 0; i < mCameraDeviceList.getCount(); i++)
            {
                if (mCameraDeviceList.getDeviceName(i).Equals(this.cameraDeviceComboBox.Text))
                {
                    mTRTCCloud.setCurrentCameraDevice(mCameraDeviceList.getDevicePID(i));
                    mMainForm.OnCameraDeviceChange(mCameraDeviceList.getDeviceName(i));
                }
            }
        }

        private void OnMicDeviceComboBoxSelectedIndexChanged(object sender, EventArgs e)
        {
            for (uint i = 0; i < mMicDeviceList.getCount(); i++)
            {
                if (mMicDeviceList.getDeviceName(i).Equals(this.micDeviceComboBox.Text))
                {
                    mTRTCCloud.setCurrentMicDevice(mMicDeviceList.getDevicePID(i));
                    mMainForm.OnMicDeviceChange(mMicDeviceList.getDeviceName(i));
                }
            }
        }

        private void OnSpeakerDeviceComboBoxSelectedIndexChanged(object sender, EventArgs e)
        {
            for (uint i = 0; i < mSpeakerDeviceList.getCount(); i++)
            {
                if (mSpeakerDeviceList.getDeviceName(i).Equals(this.speakerDeviceComboBox.Text))
                {
                    mTRTCCloud.setCurrentSpeakerDevice(mSpeakerDeviceList.getDevicePID(i));
                    mMainForm.OnSpeakerDeviceChange(mSpeakerDeviceList.getDeviceName(i));
                }
            }
        }
    }
}
