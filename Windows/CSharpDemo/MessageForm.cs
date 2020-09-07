using System;
using System.Drawing;
using System.Windows.Forms;

namespace TRTCCSharpDemo
{
    public partial class MessageForm : Form
    {
        private bool mIsMouseDown = false;
        private Point mFormLocation;     // Form的location
        private Point mMouseOffset;      // 鼠标的按下位置
        private System.Timers.Timer mTimer = null;

        public MessageForm()
        {
            InitializeComponent();
        }

        public void setText(string title, int delayCloseMs = 0)
        {
            labelTitle.Text = title;
            if(delayCloseMs != 0)
            {
                mTimer = new System.Timers.Timer(delayCloseMs);
                mTimer.Interval = delayCloseMs;
                mTimer.Elapsed += new System.Timers.ElapsedEventHandler(OnTimerEvent);
                mTimer.Start();
            }
        }

        public void OnTimerEvent(object sender, System.Timers.ElapsedEventArgs e)
        {
            this.BeginInvoke(new Action(() =>
            {
                this.DialogResult = DialogResult.Abort;
                mTimer.Stop();
                this.Close();
            }));
        }

        public void setCancelBtn(bool show)
        {
            cancelBtn.Visible = show;
        }

        private void OnFormMouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                mIsMouseDown = true;
                mFormLocation = this.Location;
                mMouseOffset = Control.MousePosition;
            }
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

        private void OnFormMouseUp(object sender, MouseEventArgs e)
        {
            mIsMouseDown = false;
        }

        private void Form_Closing(object sender, FormClosingEventArgs e)
        {
            if(null != mTimer)
            {
                mTimer.Stop();
            }
        }

        private void okBtnClick(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        private void cancelBtnClick(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        private void MessageForm_Load(object sender, EventArgs e)
        {
            //文字内容太小时，就居中显示，Form高度适中就可以
            if (this.labelTitle.Height < 50)
            {
                labelTitle.Location = new Point((this.Width - labelTitle.Width) / 2, 25);
                labelTitle.TextAlign = ContentAlignment.MiddleCenter;
                this.Height = 120;
            }
            else
            {
                this.Height = labelTitle.Height + 100;
                labelTitle.TextAlign = ContentAlignment.MiddleLeft;
            }
        }

        private void exitPicBox_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }
    }
}
