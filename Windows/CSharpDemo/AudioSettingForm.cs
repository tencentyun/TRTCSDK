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
    public partial class AudioSettingForm : Form
    {
        private ITRTCCloud mTRTCCloud;
        private ITXDeviceManager mDeviceManager;
        private TRTCMainForm mMainForm;
        private ITRTCDeviceInfo mMicDevice;
        private ITRTCDeviceInfo mSpeakerDevice;
        private ITRTCDeviceCollection mMicDeviceList;
        private ITRTCDeviceCollection mSpeakerDeviceList;

        private int mMicVolume; 
        private int mSpeakerVolume;
        private string mTestPath = System.Environment.CurrentDirectory + "\\Resources\\trtcres\\testspeak.mp3";
        public AudioSettingForm(TRTCMainForm mainform)
        {
            InitializeComponent();
            this.Disposed += new EventHandler(OnDisposed);

            mTRTCCloud = DataManager.GetInstance().trtcCloud;
            mDeviceManager = mTRTCCloud.getDeviceManager();

            mMainForm = mainform;
        }
        private void OnDisposed(object sender, EventArgs e)
        {
            //清理资源
            if (mTRTCCloud == null || mDeviceManager == null) return;
            if (this.micTestBtn.Text.Equals("停止"))
            {
                mDeviceManager.stopMicDeviceTest();
            }
            if (this.speakerTestBtn.Text.Equals("停止"))
            {
                mDeviceManager.stopSpeakerDeviceTest();
            }

            if (this.systemAudioCheckBox.Checked)
                mTRTCCloud.stopSystemAudioLoopback();

            if (mMicDevice != null)
                mMicDevice.release();
            if (mSpeakerDevice != null)
                mSpeakerDevice.release();
          
            if (mMicDeviceList != null)
                mMicDeviceList.release();
            if (mSpeakerDeviceList != null)
                mSpeakerDeviceList.release();

            mMicDevice = null;
            mSpeakerDevice = null;
            mMicDeviceList = null;
            mSpeakerDeviceList = null;
            mTRTCCloud = null;
            mDeviceManager = null;
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
            this.audioQualityComboBox.Items.Clear();
            this.audioQualityComboBox.Items.Add("语音（16K 单声道）");
            this.audioQualityComboBox.Items.Add("默认（48K 单声道）");
            this.audioQualityComboBox.Items.Add("音乐（128K 双声道）");

            switch (DataManager.GetInstance().AudioQuality)
            {
                case TRTCAudioQuality.TRTCAudioQualitySpeech:
                    this.audioQualityComboBox.SelectedIndex = 0;
                    break;
                case TRTCAudioQuality.TRTCAudioQualityDefault:
                    this.audioQualityComboBox.SelectedIndex = 1;
                    break;
                case TRTCAudioQuality.TRTCAudioQualityMusic:
                    this.audioQualityComboBox.SelectedIndex = 2;
                    break;
                default:
                    break;
            }
            RefreshMicDeviceList();
            RefreshSpeakerList();

            mMicVolume = (int)mDeviceManager.getCurrentDeviceVolume(TRTCDeviceType.TXMediaDeviceTypeMic);
            this.micVolumeTrackBar.Value = mMicVolume;
            this.micVolumeNumLabel.Text = mMicVolume + "%";

            mSpeakerVolume = (int)mDeviceManager.getCurrentDeviceVolume(TRTCDeviceType.TXMediaDeviceTypeSpeaker);
            this.speakerVolumeTrackBar.Value = mSpeakerVolume;
            this.speakerVolumeNumLabel.Text = mSpeakerVolume + "%";
        }
        private void RefreshMicDeviceList()
        {
            if (mDeviceManager == null) return;
            this.micDeviceComboBox.Items.Clear();
            mMicDeviceList = mDeviceManager.getDevicesList(TRTCDeviceType.TXMediaDeviceTypeMic);
            if (mMicDeviceList.getCount() <= 0)
            {
                this.micDeviceComboBox.Items.Add("");
                this.micDeviceComboBox.SelectionStart = this.micDeviceComboBox.Text.Length;
                return;
            }
            mMicDevice = mDeviceManager.getCurrentDevice(TRTCDeviceType.TXMediaDeviceTypeMic);
            for (uint i = 0; i < mMicDeviceList.getCount(); i++)
            {
                this.micDeviceComboBox.Items.Add(mMicDeviceList.getDeviceName(i));
                if (mMicDevice.getDeviceName().Equals(mMicDeviceList.getDeviceName(i)))
                    this.micDeviceComboBox.SelectedIndex = (int)i;
            }
        }

        private void RefreshSpeakerList()
        {
            if (mDeviceManager == null) return;
            this.speakerDeviceComboBox.Items.Clear();
            mSpeakerDeviceList = mDeviceManager.getDevicesList(TRTCDeviceType.TXMediaDeviceTypeSpeaker);
            if (mSpeakerDeviceList.getCount() <= 0)
            {
                this.speakerDeviceComboBox.Items.Add("");
                this.speakerDeviceComboBox.SelectionStart = this.speakerDeviceComboBox.Text.Length;
                return;
            }
            mSpeakerDevice = mDeviceManager.getCurrentDevice(TRTCDeviceType.TXMediaDeviceTypeSpeaker);
            for (uint i = 0; i < mSpeakerDeviceList.getCount(); i++)
            {
                this.speakerDeviceComboBox.Items.Add(mSpeakerDeviceList.getDeviceName(i));
                if (mSpeakerDevice.getDeviceName().Equals(mSpeakerDeviceList.getDeviceName(i)))
                    this.speakerDeviceComboBox.SelectedIndex = (int)i;
            }
        }
        public void OnDeviceChange(string deviceId, TRTCDeviceType type, TRTCDeviceState state)
        {
            if (type == TRTCDeviceType.TXMediaDeviceTypeMic)
            {
                RefreshMicDeviceList();
            }
            else if (type == TRTCDeviceType.TXMediaDeviceTypeSpeaker)
            {
                RefreshSpeakerList();
            }
        }
        private void micDeviceComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(this.micDeviceComboBox.Text)) return;
            for (uint i = 0; i < mMicDeviceList.getCount(); i++)
            {
                if (mMicDeviceList.getDeviceName(i).Equals(this.micDeviceComboBox.Text))
                {
                    mDeviceManager.setCurrentDevice(TRTCDeviceType.TXMediaDeviceTypeMic, mMicDeviceList.getDevicePID(i));
                    mMainForm.OnMicDeviceChange(mMicDeviceList.getDevicePID(i));
                }
            }
        }

        private void micVolumeTrackBar_Scroll(object sender, EventArgs e)
        {
            mMicVolume = this.micVolumeTrackBar.Value;
            this.micVolumeNumLabel.Text = mMicVolume + "%";
            mDeviceManager.setCurrentDeviceVolume(TRTCDeviceType.TXMediaDeviceTypeMic, (uint)(mMicVolume * 100 / 100));
        }

        private void speakerDeviceComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(this.speakerDeviceComboBox.Text)) return;
            for (uint i = 0; i < mSpeakerDeviceList.getCount(); i++)
            {
                if (mSpeakerDeviceList.getDeviceName(i).Equals(this.speakerDeviceComboBox.Text))
                {
                    mDeviceManager.setCurrentDevice(TRTCDeviceType.TXMediaDeviceTypeSpeaker, mSpeakerDeviceList.getDevicePID(i));
                    mMainForm.OnSpeakerDeviceChange(mSpeakerDeviceList.getDevicePID(i));
                }
            }
        }

        private void speakerVolumeTrackBar_Scroll(object sender, EventArgs e)
        {
            mSpeakerVolume = this.speakerVolumeTrackBar.Value;
            this.speakerVolumeNumLabel.Text = mSpeakerVolume + "%";
            mDeviceManager.setCurrentDeviceVolume(TRTCDeviceType.TXMediaDeviceTypeSpeaker, (uint)(mSpeakerVolume * 100 / 100));
        }

        private void micTestBtn_Click(object sender, EventArgs e)
        {
            if (this.micTestBtn.Text.Equals("麦克风测试"))
            {
                // 开始麦克风测试
                this.micTestBtn.Text = "停止";

                if (mTRTCCloud != null)
                    mDeviceManager.startMicDeviceTest(200);
            }
            else
            {
                // 停止麦克风测试
                this.micTestBtn.Text = "麦克风测试";
                this.micProgressBar.Value = 0;
                if (mTRTCCloud != null)
                    mDeviceManager.stopMicDeviceTest();
            }
        }

        private void speakerTestBtn_Click(object sender, EventArgs e)
        {
            if (this.speakerTestBtn.Text.Equals("扬声器测试"))
            {
                // 开始扬声器测试
                this.speakerTestBtn.Text = "停止";
                if (mTRTCCloud != null)
                    mDeviceManager.startSpeakerDeviceTest(mTestPath);
            }
            else
            {
                // 停止扬声器测试
                this.speakerTestBtn.Text = "扬声器测试";
                this.speakerProgressBar.Value = 0;
                if (mTRTCCloud != null)
                    mDeviceManager.stopSpeakerDeviceTest();
            }
        }

        public void OnTestMicVolume(uint volume)
        {
            if (this.micTestBtn.Text.Equals("停止"))
            {
                this.micProgressBar.Value = (int)volume;
            }
            else
            {
                this.micProgressBar.Value = 0;
            }
        }

        public void OnTestSpeakerVolume(uint volume)
        {
            if (this.speakerTestBtn.Text.Equals("停止"))
            {
                this.speakerProgressBar.Value = (int)volume;
            }
            else
            {
                this.speakerProgressBar.Value = 0;
            }
        }
        private void exitPicBox_Click(object sender, EventArgs e)
        {
            if (this.micTestBtn.Text.Equals("停止"))
            {
                mDeviceManager.stopMicDeviceTest();
            }
            if (this.speakerTestBtn.Text.Equals("停止"))
            {
                mDeviceManager.stopSpeakerDeviceTest();
            }
            this.Close();
        }
        private void OnSystemAudioCheckBoxClick(object sender, EventArgs e)
        {
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

        private void aecCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            //todo
        }

        private void ansCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            //todo
        }

        private void agcCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            //todo
        }

        private void audioQualityComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            switch (this.audioQualityComboBox.SelectedIndex)
            {
                case 0:
                    DataManager.GetInstance().AudioQuality = TRTCAudioQuality.TRTCAudioQualitySpeech;
                    break;
                case 1:
                    DataManager.GetInstance().AudioQuality = TRTCAudioQuality.TRTCAudioQualityDefault;
                    break;
                case 2:
                    DataManager.GetInstance().AudioQuality = TRTCAudioQuality.TRTCAudioQualityMusic;
                    break;
                default:
                    break;
            }
        }
    }
}
