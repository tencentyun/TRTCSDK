using System;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;
using ManageLiteAV;
using TRTCCSharpDemo.Common;

/// <summary>
/// Module:   TRTCCustomCaptureForm
/// 
/// Function: 用于选择是否打开自定义采集音视频的功能
/// </summary>
namespace TRTCCSharpDemo
{
    public partial class TRTCCustomCaptureForm : Form
    {
        private ITRTCCloud mTRTCCloud;
        private TRTCMainForm mMainForm;

        private string mTestPath = System.Environment.CurrentDirectory + "\\Resources\\trtcres\\";

        private volatile bool mStartCustomCaptureAudio;
        private volatile bool mStartCustomCaptureVideo;

        private string mAudioFilePath;
        private uint mAudioFileLength;
        private string mVideoFilePath;
        private uint mVideoFileLength;
        private uint mAudioSamplerate;
        private uint mAudioChannel;
        private uint mVideoWidth;
        private uint mVideoHeight;

        private byte[] mAudioBuffer;
        private byte[] mVideoBuffer;
        private uint mOffsetAudioRead = 0;
        private uint mOffsetVideoRead = 0;

        private Thread mAudioCustomThread;
        private Thread mVideoCustomThread;

        public TRTCCustomCaptureForm(TRTCMainForm mainForm)
        {
            InitializeComponent();

            this.Disposed += new EventHandler(OnDisposed);

            mTRTCCloud = DataManager.GetInstance().trtcCloud;
            mMainForm = mainForm;

            this.customAudioComboBox.Items.Add("48_1_audio.pcm");
            this.customAudioComboBox.Items.Add("16_1_audio.pcm");
            this.customVideoComboBox.Items.Add("320x240_video.yuv");
        }

        private void OnDisposed(object sender, EventArgs e)
        {
            //清理资源
            if (mTRTCCloud != null && mMainForm != null)
            {
                mTRTCCloud.enableCustomAudioCapture(false);
                mTRTCCloud.enableCustomVideoCapture(false);
                mMainForm.OnCustomCaptureAudioCallback(true);
                mMainForm.OnCustomCaptureVideoCallback(true);
                mStartCustomCaptureAudio = false;
                mStartCustomCaptureVideo = false;
                if (mAudioCustomThread != null)
                {
                    mAudioCustomThread.Join();
                    mAudioCustomThread.DisableComObjectEagerCleanup();
                    mAudioCustomThread = null;
                }
                if (mVideoCustomThread != null)
                {
                    mVideoCustomThread.Join();
                    mVideoCustomThread.DisableComObjectEagerCleanup();
                    mVideoCustomThread = null;
                }
            }
            mMainForm = null;
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
            this.customVideoComboBox.SelectedIndex = 0;
            this.customAudioComboBox.SelectedIndex = 0;
        }

        private void OnCustomAudioCheckBoxClick(object sender, EventArgs e)
        {
            if (this.customAudioCheckBox.Checked)
            {
                // 开启自定义渲染音频
                if (this.customAudioComboBox.SelectedIndex == 0)
                    StartCustomCaptureAudio(mTestPath + "48_1_audio.pcm", 48000, 1);
                else if (this.customAudioComboBox.SelectedIndex == 1)
                    StartCustomCaptureAudio(mTestPath + "16_1_audio.pcm", 16000, 1);
            }
            else
            {
                // 停止自定义渲染音频
                StopCustomCaptureAudio();
            }
        }

        private void StartCustomCaptureAudio(string path, uint samplerate, uint channel)
        {
            mAudioFilePath = path;
            mAudioSamplerate = samplerate;
            mAudioChannel = channel;
            mAudioFileLength = (uint)new FileInfo(path).Length;

            mStartCustomCaptureAudio = true;
            mMainForm.OnCustomCaptureAudioCallback(false);
            mTRTCCloud.enableCustomAudioCapture(true);

            if (mAudioCustomThread == null)
            {
                mAudioCustomThread = new Thread(() =>
                {
                    while (mStartCustomCaptureAudio)
                    {
                        SendCustomAudioFrame();
                        Thread.Sleep(20);
                    }
                })
                { IsBackground = true };
                mAudioCustomThread.Start();
            }

        }

        public void SendCustomAudioFrame()
        {
            if (!mStartCustomCaptureAudio) return;
            try
            {
                using (FileStream fs = File.OpenRead(mAudioFilePath))
                {
                    uint bufSize = (uint)((960 * mAudioSamplerate / 48000) * (mAudioChannel * 16 / 8));
                    if (mAudioBuffer == null)
                        mAudioBuffer = new byte[bufSize];
                    if (mOffsetAudioRead + bufSize > mAudioFileLength)
                        mOffsetAudioRead = 0;
                    fs.Seek(mOffsetAudioRead, SeekOrigin.Begin);
                    fs.Read(mAudioBuffer, 0, (int)bufSize);
                    mOffsetAudioRead += bufSize;

                    TRTCAudioFrame frame = new TRTCAudioFrame();
                    frame.audioFormat = TRTCAudioFrameFormat.TRTCAudioFrameFormatPCM;
                    frame.channel = mAudioChannel;
                    frame.length = bufSize;
                    frame.data = mAudioBuffer;
                    frame.sampleRate = mAudioSamplerate;
                    mTRTCCloud.sendCustomAudioData(frame);
                }
            }
            catch (Exception e)
            {
                Log.E(e.Message);
            }
        }

        private void StopCustomCaptureAudio()
        {
            mAudioFilePath = "";
            mAudioFileLength = 0;
            mOffsetAudioRead = 0;
            mAudioBuffer = null;

            mStartCustomCaptureAudio = false;
            mTRTCCloud.enableCustomAudioCapture(false);
            mMainForm.OnCustomCaptureAudioCallback(true);

            if (mAudioCustomThread != null)
            {
                mAudioCustomThread.Join();
                mAudioCustomThread.DisableComObjectEagerCleanup();
                mAudioCustomThread = null;
            }
        }

        private void OnCustomVideoCheckBoxClick(object sender, EventArgs e)
        {
            if (DataManager.GetInstance().pureAudioStyle)
            {
                MessageForm msgBox = new MessageForm();
                msgBox.setText("Error: 纯音频场景，无法打开自定义采集，请退房重新选择模式");
                msgBox.setCancelBtn(false);
                msgBox.ShowDialog();
                this.customVideoCheckBox.Checked = false;
                return;
            }
            if (this.customVideoCheckBox.Checked)
            {
                // 开启自定义渲染视频
                if (this.customVideoComboBox.SelectedIndex == 0)
                {
                    StartCustomCaptureVideo(mTestPath + "320x240_video.yuv", 320, 240);
                }
            }
            else
            {
                // 关闭自定义渲染视频
                StopCustomCaptureVideo();
            }
        }

        private void StartCustomCaptureVideo(string path, uint width, uint height)
        {
            mVideoFilePath = path;
            mVideoWidth = width;
            mVideoHeight = height;
            mVideoFileLength = (uint)new FileInfo(mVideoFilePath).Length;

            mStartCustomCaptureVideo = true;
            mMainForm.OnCustomCaptureVideoCallback(false);
            mTRTCCloud.enableCustomVideoCapture(true);

            if (mVideoCustomThread == null)
            {
                mVideoCustomThread = new Thread(() =>
                {
                    while (mStartCustomCaptureVideo)
                    {
                        SendCustomVideoFrame();
                        Thread.Sleep(66);
                    }
                })
                { IsBackground = true };
                mVideoCustomThread.Start();
            }
        }

        public void SendCustomVideoFrame()
        {
            if (!mStartCustomCaptureVideo) return;
            try
            {
                using (FileStream fs = File.OpenRead(mVideoFilePath))
                {
                    uint bufSize = mVideoWidth * mVideoHeight * 3 / 2;
                    if (mVideoBuffer == null)
                        mVideoBuffer = new byte[bufSize];
                    if (mOffsetVideoRead + bufSize > mVideoFileLength)
                        mOffsetVideoRead = 0;
                    fs.Seek(mOffsetVideoRead, SeekOrigin.Begin);
                    fs.Read(mVideoBuffer, 0, (int)bufSize);
                    mOffsetVideoRead += bufSize;

                    TRTCVideoFrame frame = new TRTCVideoFrame();
                    frame.videoFormat = TRTCVideoPixelFormat.TRTCVideoPixelFormat_I420;
                    frame.data = mVideoBuffer;
                    frame.width = mVideoWidth;
                    frame.height = mVideoHeight;
                    frame.length = bufSize;
                    mTRTCCloud.sendCustomVideoData(frame);
                }
            }
            catch (Exception e)
            {
                Log.E(e.Message);
            }
        }

        private void StopCustomCaptureVideo()
        {
            mVideoFileLength = 0;
            mVideoFilePath = "";
            mVideoWidth = 0;
            mVideoHeight = 0;
            mOffsetVideoRead = 0;
            mVideoBuffer = null;

            mStartCustomCaptureVideo = false;
            mTRTCCloud.enableCustomVideoCapture(false);
            mMainForm.OnCustomCaptureVideoCallback(true);

            if (mVideoCustomThread != null)
            {
                mVideoCustomThread.Join();
                mVideoCustomThread.DisableComObjectEagerCleanup();
                mVideoCustomThread = null;
            }
        }

        private void OnConfirmBtnClick(object sender, EventArgs e)
        {
            ExitHandle();
        }

        private void OnExitPicBoxClick(object sender, EventArgs e)
        {
            ExitHandle();
        }

        private void ExitHandle()
        {
            if ((this.customAudioCheckBox.Checked) || (this.customVideoCheckBox.Checked))
            {
                mMainForm.OnCustomCaptureEnabled(true);
            }
            else
            {
                mMainForm.OnCustomCaptureEnabled(false);
            }
            this.Hide();
        }

        public bool IsCustomVideoChecked()
        {
            return this.customVideoCheckBox.Checked;
        }
    }
}
