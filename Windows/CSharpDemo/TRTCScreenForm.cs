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
    public partial class TRTCScreenForm : Form
    {

        private TRTCMainForm mMainForm;
        private ITRTCCloud mTRTCCloud;
        private ITRTCScreenCaptureSourceList mScreenList;
        private TRTCScreenCaptureSourceInfo mScreenInfo;

        public TRTCScreenForm(ITRTCCloud cloud, TRTCMainForm form)
        {
            InitializeComponent();

            this.Disposed += new EventHandler(OnDisposed);

            mTRTCCloud = cloud;
            mMainForm = form;
        }

        private void OnDisposed(object sender, EventArgs e)
        {
            //清理资源
            mScreenList.release();
            mScreenList = null;
            mTRTCCloud = null;
            mMainForm = null;
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
            SIZE thumbSize = new SIZE() { cx = 100, cy = 100 };
            SIZE iconSize = new SIZE() { cx = 100, cy = 100 };
            mScreenList = mTRTCCloud.getScreenCaptureSources(ref thumbSize, ref iconSize);
            Log.I(String.Format("ITRTCScreenCaptureSourceList : count = {0}", mScreenList.getCount()));
            for (uint i = 0; i < mScreenList.getCount(); i++)
            {
                TRTCScreenCaptureSourceInfo sourse = mScreenList.getSourceInfo(i);
                this.screenComboBox.Items.Add(sourse.sourceName);
                Log.I(String.Format("ScreenCaoture{0} : type = {1}, sourseId = {2}, sourseName = {3}, thumbBuffer = {4}, iconBuffer = {5}",
                    i + 1, sourse.type, sourse.sourceId, sourse.sourceName, sourse.thumbBGRA.buffer + " {" + sourse.thumbBGRA.width + ", " + sourse.thumbBGRA.height + "}",
                    sourse.iconBGRA.buffer + " {" + sourse.iconBGRA.width + ", " + sourse.iconBGRA.height + "}"));
            }
            this.screenComboBox.SelectedIndex = 0;
        }

        private void OnSaveBtnClick(object sender, EventArgs e)
        {
            for (uint i = 0; i < mScreenList.getCount(); i++)
            {
                TRTCScreenCaptureSourceInfo sourse = mScreenList.getSourceInfo(i);
                if(sourse.sourceName.Equals(this.screenComboBox.Text))
                {
                    mScreenInfo = sourse;
                }
            }
            RECT rect = new RECT()
            {
                top = int.Parse(string.IsNullOrEmpty(this.topTextBox.Text) ? "0" : this.topTextBox.Text),
                left = int.Parse(string.IsNullOrEmpty(this.LeftTextBox.Text) ? "0" : this.LeftTextBox.Text),
                right = int.Parse(string.IsNullOrEmpty(this.rightTextBox.Text) ? "0" : this.rightTextBox.Text),
                bottom = int.Parse(string.IsNullOrEmpty(this.bottomTextBox.Text) ? "0" : this.bottomTextBox.Text)
            };
            mTRTCCloud.selectScreenCaptureTarget(ref mScreenInfo, ref rect, true, true);
            mMainForm.OnSetScreenParamsCallback(true);
            this.Close();
        }

        private void OnCancelBtnClick(object sender, EventArgs e)
        {
            mMainForm.OnSetScreenParamsCallback(false);
            this.Close();
        }

        private void OnLeftTextBoxKeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar != '\b')
            {
                if (e.KeyChar < 48 || e.KeyChar > 57)
                    e.Handled = true;
            }
        }

        private void OnRightTextBoxKeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar != '\b')
            {
                if (e.KeyChar < 48 || e.KeyChar > 57)
                    e.Handled = true;
            }
        }

        private void OnTopTextBoxKeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar != '\b')
            {
                if (e.KeyChar < 48 || e.KeyChar > 57)
                    e.Handled = true;
            }
        }

        private void OnBottomTextBoxKeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar != '\b')
            {
                if (e.KeyChar < 48 || e.KeyChar > 57)
                    e.Handled = true;
            }
        }

        private void OnLeftTextBoxTextChanged(object sender, EventArgs e)
        {
            if(string.IsNullOrEmpty(this.LeftTextBox.Text))
            {
                this.LeftTextBox.Text = "0";
            }
        }

        private void OnRightTextBoxTextChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(this.rightTextBox.Text))
            {
                this.rightTextBox.Text = "0";
            }
        }

        private void OnBottomTextBoxTextChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(this.bottomTextBox.Text))
            {
                this.bottomTextBox.Text = "0";
            }
        }

        private void OnTopTextBoxTextChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(this.topTextBox.Text))
            {
                this.topTextBox.Text = "0";
            }
        }
    }
}
