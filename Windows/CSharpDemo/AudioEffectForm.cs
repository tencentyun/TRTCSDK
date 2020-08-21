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

    public partial class AudioEffectForm : Form, ITXMusicPlayObserver
    {

        public enum BGM_MusicStatus
        {
            BGM_Music_Play = 0,
            BGM_Music_Pause = 1,
            BGM_Music_Stop = 2,
        };
        private BGM_MusicStatus mMusicStatus = BGM_MusicStatus.BGM_Music_Stop;
        private ITRTCCloud mTRTCCloud;

        private AudioMusicParam mEffectParam1 = new AudioMusicParam(0, System.Environment.CurrentDirectory + "\\Resources\\trtcres\\clap.aac");
        private AudioMusicParam mEffectParam2 = new AudioMusicParam(0, System.Environment.CurrentDirectory + "\\Resources\\trtcres\\gift_sent.aac");
        private AudioMusicParam mEffectParam3 = new AudioMusicParam(0, System.Environment.CurrentDirectory + "\\Resources\\trtcres\\on_mic.aac");
        private AudioMusicParam mBGMParam = new AudioMusicParam(4, System.Environment.CurrentDirectory + "\\Resources\\trtcres\\BGM.mp3");

        private ITXAudioEffectManager AudioEffectManager;

        private int AUDIO_BGM_SPEED_CONVERSION_RATE = 10;
        private int AUDIO_BGM_PITCH_CONVERSION_RATE = 10;
        public AudioEffectForm()
        {
            InitializeComponent();

            this.Disposed += new EventHandler(OnDisposed);

            mTRTCCloud = DataManager.GetInstance().trtcCloud;

            Init();
        }
        private void Init()
        {
            this.BGMprogressBar.Maximum = 100;
            this.BGMprogressBar.Value = 0;

            this.BGMVolumTrackBar.Maximum = 100;
            this.BGMVolumTrackBar.Minimum = 0;
            this.BGMVolumTrackBar.Value = 50;
            this.RemoteVolumTrackBar.Maximum = 100;
            this.RemoteVolumTrackBar.Minimum = 0;
            this.RemoteVolumTrackBar.Value = 50;

            this.LocalVolumTrackBar.Maximum = 100;
            this.LocalVolumTrackBar.Minimum = 0;
            this.LocalVolumTrackBar.Value = 50;

            this.BGMSpeedTrackBar.Maximum = 20;
            this.BGMSpeedTrackBar.Minimum = 5;
            this.BGMSpeedTrackBar.Value = 10;

            this.BGMPitchTrackBar.Maximum = 10;
            this.BGMPitchTrackBar.Minimum = -10;
            this.BGMPitchTrackBar.Value = 0;
            

            mEffectParam1.isShortFile = true;


            mEffectParam2.isShortFile = true;

            mEffectParam3.isShortFile = true;

            mBGMParam.id = 4;
            mBGMParam.publish = true;



            AudioEffectManager = mTRTCCloud.getAudioEffectManager();

            AudioEffectManager.setMusicPlayoutVolume(mBGMParam.id, this.BGMVolumTrackBar.Value);
            AudioEffectManager.setMusicPublishVolume(mBGMParam.id, this.BGMVolumTrackBar.Value);
        }
        private void OnDisposed(object sender, EventArgs e)
        {
            //清理资源
            if (mTRTCCloud == null) return;

            mTRTCCloud = null;
            AudioEffectManager = null;
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

        private void exitPicBox_Click(object sender, EventArgs e)
        {
            this.bgmPlayBtn.Text = "播放";
            AudioEffectManager.stopPlayMusic(mBGMParam.id);
            mMusicStatus = BGM_MusicStatus.BGM_Music_Stop;
           

            this.BGMVolumTrackBar.Value = 50;
            this.RemoteVolumTrackBar.Value = 50;
            this.LocalVolumTrackBar.Value = 50;
            this.BGMSpeedTrackBar.Value = 10;
            this.BGMPitchTrackBar.Value = 0;
            this.BGMprogressBar.Value = 0;
            this.bgmTimeLabel.Text = "00:00/00:00";


            AudioEffectManager.stopPlayMusic(mEffectParam1.id);
            AudioEffectManager.stopPlayMusic(mEffectParam2.id);
            AudioEffectManager.stopPlayMusic(mEffectParam3.id);

            this.effect1CheckBox.Checked = false;
            this.effect2CheckBox.Checked = false;
            this.effect3CheckBox.Checked = false;

            this.effect1CycleCheckBox.Checked = false;
            this.effect2CycleCheckBox.Checked = false;
            this.effect3CycleCheckBox.Checked = false;

            this.effect1PublishCheckBox.Checked = false;
            this.effect2PublishCheckBox.Checked = false;
            this.effect3PublishCheckBox.Checked = false;

            this.Close();
        }
        public void onStart(int id, int errCode)
        {
            if (this.IsHandleCreated)
                this.BeginInvoke(new Action(() =>
                {
                    AudioEffectManager.setMusicPlayoutVolume(mBGMParam.id, this.LocalVolumTrackBar.Value);
                    AudioEffectManager.setMusicPublishVolume(mBGMParam.id, this.RemoteVolumTrackBar.Value);

                    float fSpeed = (float)this.BGMSpeedTrackBar.Value / AUDIO_BGM_SPEED_CONVERSION_RATE;
                    AudioEffectManager.setMusicSpeedRate(mBGMParam.id, fSpeed);

                    float fPitch = ((float)this.BGMPitchTrackBar.Value / AUDIO_BGM_PITCH_CONVERSION_RATE);
                    AudioEffectManager.setMusicPitch(mBGMParam.id, fPitch);

                }));
            
        }
        public void onPlayProgress(int id, int curPtsMS, int durationMS)
        {
            if (this.IsHandleCreated)
                this.BeginInvoke(new Action(() =>
                {
                    int nProgressPos = 100 * curPtsMS / durationMS;
                    this.BGMprogressBar.Value = nProgressPos;

                    this.bgmTimeLabel.Text = Util.ConvertMSToTime(curPtsMS, durationMS);
                }));

        }
        public  void onComplete(int id, int errCode)
        {
            if (this.IsHandleCreated)
                this.BeginInvoke(new Action(() =>
                {
                    if (id == mBGMParam.id)
                    {
                        mMusicStatus = BGM_MusicStatus.BGM_Music_Stop;
                        this.BGMprogressBar.Value = 0;
                        this.bgmPlayBtn.Text = "播放";
                        this.bgmTimeLabel.Text = "00:00/00:00";
                        AudioEffectManager.setMusicObserver(mBGMParam.id, null);
                    }
                }));
        }
        private void bgmPlayBtn_Click(object sender, EventArgs e)
        {
            if (mMusicStatus == BGM_MusicStatus.BGM_Music_Stop)
            {
                
                if (AudioEffectManager != null)
                {
                    this.bgmPlayBtn.Text = "暂停";
                    AudioEffectManager.startPlayMusic(mBGMParam);
                    AudioEffectManager.setMusicObserver(mBGMParam.id,this);
                    mMusicStatus = BGM_MusicStatus.BGM_Music_Play;
                }
                   
            }
            else if (mMusicStatus == BGM_MusicStatus.BGM_Music_Play)
            {
               
                if (AudioEffectManager != null)
                {
                   
                    this.bgmPlayBtn.Text = "播放";
                    AudioEffectManager.pausePlayMusic(mBGMParam.id);
                    mMusicStatus = BGM_MusicStatus.BGM_Music_Pause;
                }
                   
            }
            else if(mMusicStatus == BGM_MusicStatus.BGM_Music_Pause)
            {
                if (AudioEffectManager != null)
                {

                    this.bgmPlayBtn.Text = "暂停";
                    AudioEffectManager.resumePlayMusic(mBGMParam.id);
                    mMusicStatus = BGM_MusicStatus.BGM_Music_Play;
                }
            }
        }

        private void bgmStopBtn_Click(object sender, EventArgs e)
        {
            if (mMusicStatus != BGM_MusicStatus.BGM_Music_Stop)
            {
                // 停止BGM测试

                if (AudioEffectManager != null)
                {
                    this.bgmPlayBtn.Text = "播放";
                    AudioEffectManager.stopPlayMusic(mBGMParam.id);
                    mMusicStatus = BGM_MusicStatus.BGM_Music_Stop;
                }
                   
            }

            this.BGMprogressBar.Value = 0;
            this.BGMVolumTrackBar.Value = 50;
            this.RemoteVolumTrackBar.Value = 50;
            this.LocalVolumTrackBar.Value = 50;
            this.BGMSpeedTrackBar.Value = 10;
            this.BGMPitchTrackBar.Value = 0;
            this.bgmTimeLabel.Text = "00:00/00:00";
        }

        private void BGMVolumTrackBar_Scroll(object sender, EventArgs e)
        {

            if (AudioEffectManager == null) return;
            AudioEffectManager.setMusicPlayoutVolume(mBGMParam.id, this.BGMVolumTrackBar.Value);
            AudioEffectManager.setMusicPublishVolume(mBGMParam.id, this.BGMVolumTrackBar.Value);
            this.RemoteVolumTrackBar.Value = this.BGMVolumTrackBar.Value;
            this.LocalVolumTrackBar.Value = this.BGMVolumTrackBar.Value;
        }

        private void LocalVolumTrackBar_Scroll(object sender, EventArgs e)
        {
            if (AudioEffectManager == null) return;

            AudioEffectManager.setMusicPlayoutVolume(mBGMParam.id, this.LocalVolumTrackBar.Value);
        }

        private void RemoteVolumTrackBar_Scroll(object sender, EventArgs e)
        {
            if (AudioEffectManager == null) return;

            AudioEffectManager.setMusicPublishVolume(mBGMParam.id, this.RemoteVolumTrackBar.Value);
        }

        private void effect1CheckBox_CheckedChanged(object sender, EventArgs e)
        {
            if (AudioEffectManager == null) return;
           
            if (this.effect1CheckBox.Checked)
            {
                mEffectParam1.id = 1;
                AudioEffectManager.startPlayMusic(mEffectParam1);
            }
            else
            {
                AudioEffectManager.stopPlayMusic(mEffectParam1.id);
                mEffectParam1.id = 0;
            }
        }

 
        private void effect1CycleCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            if (AudioEffectManager == null) return;
           
            if (this.effect1CycleCheckBox.Checked)
            {
                mEffectParam1.loopCount = 1000;
                
            }
            else
            {
                mEffectParam1.loopCount = 1;
            }
            if (mEffectParam1.id <= 0) return;
            AudioEffectManager.startPlayMusic(mEffectParam1);
        }

        private void effect1PublishCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            if (AudioEffectManager == null) return;
            
            if (this.effect1PublishCheckBox.Checked)
            {
                mEffectParam1.publish = true;
            }
            else
            {
                mEffectParam1.publish = false;
                
            }
            if (mEffectParam1.id <= 0) return;
            AudioEffectManager.startPlayMusic(mEffectParam1);
        }

        private void effect2CheckBox_CheckedChanged(object sender, EventArgs e)
        {
            if (AudioEffectManager == null) return;
            if (this.effect2CheckBox.Checked)
            {
                mEffectParam2.id = 2;
                AudioEffectManager.startPlayMusic(mEffectParam2);
            }
            else
            {
                AudioEffectManager.stopPlayMusic(mEffectParam2.id);
                mEffectParam2.id = 0;
            }
        }

        private void effect2CycleCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            if (AudioEffectManager == null) return;
            if (this.effect2CycleCheckBox.Checked)
            {
                mEffectParam2.loopCount = 1000;   
            }
            else
            {
                mEffectParam2.loopCount = 1;
            }
            if (mEffectParam2.id <= 0) return;
            AudioEffectManager.startPlayMusic(mEffectParam2);
        }

        private void effect2PublishCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            if (AudioEffectManager == null) return;
            if (this.effect2PublishCheckBox.Checked)
            {
                mEffectParam2.publish = true;
            }
            else
            {
                mEffectParam2.publish = false;
            }
            if (mEffectParam2.id <= 0) return;
            AudioEffectManager.startPlayMusic(mEffectParam2);
        }

        private void effect3CheckBox_CheckedChanged(object sender, EventArgs e)
        {
            if (AudioEffectManager == null) return;
            if (this.effect3CheckBox.Checked)
            {
                mEffectParam3.id = 3;
                AudioEffectManager.startPlayMusic(mEffectParam3);
            }
            else
            {
                AudioEffectManager.stopPlayMusic(mEffectParam3.id);
                mEffectParam3.id = 0;
            }
        }

        private void effect3CycleCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            if (AudioEffectManager == null) return;
            if (this.effect3CycleCheckBox.Checked)
            {
                mEffectParam3.loopCount = 1000;
            }
            else
            {
                mEffectParam3.loopCount = 1;
            }
            if (mEffectParam3.id <= 0) return;
            AudioEffectManager.startPlayMusic(mEffectParam3);
        }

        private void effect3PublishCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            if (AudioEffectManager == null) return;
            if (this.effect3PublishCheckBox.Checked)
            {
                mEffectParam3.publish = true;
            }
            else
            {
                mEffectParam3.publish = false;
            }
            if (mEffectParam3.id <= 0) return;
            AudioEffectManager.startPlayMusic(mEffectParam3);
        }

        private void bgmSpeedTrackBar_Scroll(object sender, EventArgs e)
        {
            if (AudioEffectManager == null) return;

            float fSpeed = (float)this.BGMSpeedTrackBar.Value / AUDIO_BGM_SPEED_CONVERSION_RATE;

            AudioEffectManager.setMusicSpeedRate(mBGMParam.id, fSpeed);
        }

        private void bgmPitchTrackBar_Scroll(object sender, EventArgs e)
        {
            if (AudioEffectManager == null) return;

            float fPitch = ((float)this.BGMPitchTrackBar.Value / AUDIO_BGM_PITCH_CONVERSION_RATE);

            AudioEffectManager.setMusicPitch(mBGMParam.id, fPitch);

        }
    }
}
