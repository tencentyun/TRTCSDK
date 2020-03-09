using System;
using System.Drawing;
using System.Windows.Forms;
using ManageLiteAV;

/// <summary>
/// Module:   TRTCDeviceForm
/// 
/// Function: 用于选择本地设备（摄像头、扬声器、麦克风）的功能
/// </summary>
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

        public TRTCDeviceForm(TRTCMainForm mainform)
        {
            InitializeComponent();

            this.Disposed += new EventHandler(OnDisposed);

            mTRTCCloud = DataManager.GetInstance().trtcCloud;
            mMainForm = mainform;
        }

        private void OnDisposed(object sender, EventArgs e)
        {
            //清理资源
            if (mCameraDevice != null)
                mCameraDevice.release();
            if (mMicDevice != null)
                mMicDevice.release();
            if (mSpeakerDevice != null)
                mSpeakerDevice.release();
            if (mCameraDeviceList != null)
                mCameraDeviceList.release();
            if (mMicDeviceList != null)
                mMicDeviceList.release();
            if (mSpeakerDeviceList != null)
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
            mCameraDeviceList = mTRTCCloud.getCameraDevicesList();
            if (mCameraDeviceList.getCount() <= 0)
            {
                this.cameraDeviceComboBox.Items.Add("");
                this.cameraDeviceComboBox.SelectionStart = this.cameraDeviceComboBox.Text.Length;
                return;
            }
            mCameraDevice = mTRTCCloud.getCurrentCameraDevice();
            for (uint i = 0; i < mCameraDeviceList.getCount(); i++)
            {
                this.cameraDeviceComboBox.Items.Add(mCameraDeviceList.getDeviceName(i));
                if (mCameraDevice.getDeviceName().Equals(mCameraDeviceList.getDeviceName(i)))
                    this.cameraDeviceComboBox.SelectedIndex = (int)i;
            }
            if (string.IsNullOrEmpty(mCameraDevice.getDeviceName()) && mCameraDeviceList.getCount() > 0)
                this.cameraDeviceComboBox.SelectedIndex = 0;
        }

        private void RefreshMicDeviceList()
        {
            if (mTRTCCloud == null) return;
            this.micDeviceComboBox.Items.Clear();
            mMicDeviceList = mTRTCCloud.getMicDevicesList();
            if (mMicDeviceList.getCount() <= 0)
            {
                this.micDeviceComboBox.Items.Add("");
                this.micDeviceComboBox.SelectionStart = this.micDeviceComboBox.Text.Length;
                return;
            }
            mMicDevice = mTRTCCloud.getCurrentMicDevice();
            for (uint i = 0; i < mMicDeviceList.getCount(); i++)
            {
                this.micDeviceComboBox.Items.Add(mMicDeviceList.getDeviceName(i));
                if (mMicDevice.getDeviceName().Equals(mMicDeviceList.getDeviceName(i)))
                    this.micDeviceComboBox.SelectedIndex = (int)i;
            }
        }

        private void RefreshSpeakerList()
        {
            if (mTRTCCloud == null) return;
            this.speakerDeviceComboBox.Items.Clear();
            mSpeakerDeviceList = mTRTCCloud.getSpeakerDevicesList();
            if (mSpeakerDeviceList.getCount() <= 0)
            {
                this.speakerDeviceComboBox.Items.Add("");
                this.speakerDeviceComboBox.SelectionStart = this.speakerDeviceComboBox.Text.Length;
                return;
            }
            mSpeakerDevice = mTRTCCloud.getCurrentSpeakerDevice();
            for (uint i = 0; i < mSpeakerDeviceList.getCount(); i++)
            {
                this.speakerDeviceComboBox.Items.Add(mSpeakerDeviceList.getDeviceName(i));
                if (mSpeakerDevice.getDeviceName().Equals(mSpeakerDeviceList.getDeviceName(i)))
                    this.speakerDeviceComboBox.SelectedIndex = (int)i;
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
            if (String.IsNullOrEmpty(this.cameraDeviceComboBox.Text)) return;
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
            if (String.IsNullOrEmpty(this.micDeviceComboBox.Text)) return;
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
            if (String.IsNullOrEmpty(this.speakerDeviceComboBox.Text)) return;
            for (uint i = 0; i < mSpeakerDeviceList.getCount(); i++)
            {
                if (mSpeakerDeviceList.getDeviceName(i).Equals(this.speakerDeviceComboBox.Text))
                {
                    mTRTCCloud.setCurrentSpeakerDevice(mSpeakerDeviceList.getDevicePID(i));
                    mMainForm.OnSpeakerDeviceChange(mSpeakerDeviceList.getDeviceName(i));
                }
            }
        }

        private void OnExitPicBoxClick(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
