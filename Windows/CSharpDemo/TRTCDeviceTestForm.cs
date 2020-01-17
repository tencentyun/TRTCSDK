using System;
using System.Drawing;
using System.Windows.Forms;
using ManageLiteAV;

/// <summary>
/// Module:   TRTCDeviceTestForm
/// 
/// Function: 用于本地设备（摄像头、扬声器、麦克风）测试的功能
/// </summary>
namespace TRTCCSharpDemo
{
    public partial class TRTCDeviceTestForm : Form
    {
        private ITRTCCloud mTRTCCloud;

        private string mTestPath = System.Environment.CurrentDirectory + "\\Resources\\trtcres\\testspeak.mp3";

        public TRTCDeviceTestForm()
        {
            InitializeComponent();

            this.Disposed += new EventHandler(OnDisposed);

            mTRTCCloud = DataManager.GetInstance().trtcCloud;
        }

        private void OnDisposed(object sender, EventArgs e)
        {
            //清理资源
            if (mTRTCCloud == null) return;
            if(this.micTestBtn.Text.Equals("停止"))
            {
                mTRTCCloud.stopMicDeviceTest();
            }
            if (this.speakerTestBtn.Text.Equals("停止"))
            {
                mTRTCCloud.stopSpeakerDeviceTest();
            }
            if (this.bgmTestBtn.Text.Equals("停止BGM测试"))
            {
                mTRTCCloud.stopBGM();
            }
            if (this.audioEffectTestBtn.Text.Equals("停止音效测试"))
            {
                mTRTCCloud.stopAllAudioEffects();
            }
            if (this.audioRecordBtn.Text.Equals("停止录音"))
            {
                mTRTCCloud.stopAudioRecording();
            }
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

        private void OnMicTestBtnClick(object sender, EventArgs e)
        {
            if (this.micTestBtn.Text.Equals("麦克风测试"))
            {
                // 开始麦克风测试
                this.micTestBtn.Text = "停止";
                
                if (mTRTCCloud != null)
                    mTRTCCloud.startMicDeviceTest(200);
            }
            else
            {
                // 停止麦克风测试
                this.micTestBtn.Text = "麦克风测试";
                this.micProgressBar.Value = 0;
                if (mTRTCCloud != null)
                    mTRTCCloud.stopMicDeviceTest();
            }
        }

        private void OnSpeakerTestBtnClick(object sender, EventArgs e)
        {
            if (this.speakerTestBtn.Text.Equals("扬声器测试"))
            {
                // 开始扬声器测试
                this.speakerTestBtn.Text = "停止";
                if (mTRTCCloud != null)
                    mTRTCCloud.startSpeakerDeviceTest(mTestPath);
            }
            else
            {
                // 停止扬声器测试
                this.speakerTestBtn.Text = "扬声器测试";
                this.speakerProgressBar.Value = 0;
                if (mTRTCCloud != null)
                    mTRTCCloud.stopSpeakerDeviceTest();
            }
        }

        private void OnBGMTestBtnClick(object sender, EventArgs e)
        {
            if (this.bgmTestBtn.Text.Equals("启动BGM测试"))
            {
                // 开启BGM测试
                this.bgmTestBtn.Text = "停止BGM测试";
                if (mTRTCCloud != null)
                    mTRTCCloud.playBGM(mTestPath);
            }
            else
            {
                // 停止BGM测试
                this.bgmTestBtn.Text = "启动BGM测试";
                if (mTRTCCloud != null)
                    mTRTCCloud.stopBGM();
            }
        }

        private void OnAudioTestBtnClick(object sender, EventArgs e)
        {
            if (this.audioEffectTestBtn.Text.Equals("启动音效测试"))
            {
                // 开启音效测试
                this.audioEffectTestBtn.Text = "停止音效测试";
                TRTCAudioEffectParam param = new TRTCAudioEffectParam(1, mTestPath);
                param.loopCount = 0;
                param.publish = true;
                param.volume = 50;
                mTRTCCloud.playAudioEffect(param);
            }
            else
            {
                // 关闭音效测试
                this.audioEffectTestBtn.Text = "启动音效测试";
                mTRTCCloud.stopAllAudioEffects();
            }
            
        }

        private void OnAudioRecordBtnClick(object sender, EventArgs e)
        {
            if (this.audioRecordBtn.Text.Equals("开启录音"))
            {
                // 开启音效测试
                this.audioRecordBtn.Text = "停止录音";
                TRTCAudioRecordingParams param = new TRTCAudioRecordingParams();
                param.filePath = Environment.CurrentDirectory + "\\Test\\audio.wav";
                mTRTCCloud.startAudioRecording(ref param);
            }
            else
            {
                // 关闭音效测试
                this.audioRecordBtn.Text = "开启录音";
                mTRTCCloud.stopAudioRecording();
            }
        }

        private void OnConfirmBtnClick(object sender, EventArgs e)
        {
            this.Hide();
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

        public void OnPlayBGMComplete(TXLiteAVError errCode)
        {
            this.bgmTestBtn.Text = "启动BGM测试";
        }

        public void onAudioEffectFinished(int effectId, int code)
        {
            this.audioEffectTestBtn.Text = "启动音效测试";
        }

        private void OnExitPicBoxClick(object sender, EventArgs e)
        {
            this.Hide();
        }
    }
}
