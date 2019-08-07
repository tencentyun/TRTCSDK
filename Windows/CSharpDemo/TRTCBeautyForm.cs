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
    public partial class TRTCBeautyForm : Form
    {
        private ITRTCCloud mTRTCCloud;

        private TRTCBeautyStyle mBeautyStyle = TRTCBeautyStyle.TRTCBeautyStyleSmooth;
        private uint mBeauty = 0;
        private uint mWhite = 0;
        private uint mRuddiness = 0;  // 红润级别暂未生效

        public TRTCBeautyForm(ITRTCCloud cloud)
        {
            InitializeComponent();

            this.Disposed += new EventHandler(OnDisposed);

            mTRTCCloud = cloud;

            this.smoothRadioButton.Checked = true;
            UpdateBeauty();
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

        private void OnBeautyTrackBarScroll(object sender, EventArgs e)
        {
            mBeauty = (uint)this.beautyTrackBar.Value;
            SetBeautyStyle(true);
        }

        private void OnWhiteTrackBarScroll(object sender, EventArgs e)
        {
            mWhite = (uint)this.whiteTrackBar.Value;
            SetBeautyStyle(true);
        }
        private void OnSmoothRadioButtonCheckedChanged(object sender, EventArgs e)
        {
            if (this.smoothRadioButton.Checked)
            {
                mBeautyStyle = TRTCBeautyStyle.TRTCBeautyStyleSmooth;
                SetBeautyStyle(true);
            }
        }

        private void OnNatureRadioButtonCheckedChanged(object sender, EventArgs e)
        {
            if (this.natureRadioButton.Checked)
            {
                mBeautyStyle = TRTCBeautyStyle.TRTCBeautyStyleNature;
                SetBeautyStyle(true);
            }
        }

        private void SetBeautyStyle(bool isOpen)
        {
            if(mTRTCCloud != null)
            {
                if (isOpen)
                    mTRTCCloud.setBeautyStyle(mBeautyStyle, mBeauty, mWhite, mRuddiness);
                else
                    mTRTCCloud.setBeautyStyle(mBeautyStyle, 0, 0, 0);
            }
        }

        private void OnBeautyCheckBoxCheckedChanged(object sender, EventArgs e)
        {
            UpdateBeauty();
        }

        private void UpdateBeauty()
        {
            if (this.beautyCheckBox.Checked)
            {
                this.smoothRadioButton.Enabled = true;
                this.natureRadioButton.Enabled = true;
                this.beautyTrackBar.Enabled = true;
                this.whiteTrackBar.Enabled = true;
                SetBeautyStyle(true);
            }
            else
            {
                this.smoothRadioButton.Enabled = false;
                this.natureRadioButton.Enabled = false;
                this.beautyTrackBar.Enabled = false;
                this.whiteTrackBar.Enabled = false;
                SetBeautyStyle(false);
            }
        }

        private void OnConfirmBtnClick(object sender, EventArgs e)
        {
            this.Hide();
        }

    }
}
