using System;
using System.Drawing;
using System.Windows.Forms;
using ManageLiteAV;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using TRTCCSharpDemo.Common;

/// <summary>
/// Module:   TRTCConnectionForm
/// 
/// Function: 用于主播之间连麦的功能
/// </summary>
namespace TRTCCSharpDemo
{
    public partial class TRTCConnectionForm : Form
    {
        private ITRTCCloud mTRTCCloud;
        private TRTCMainForm mMainForm;

        private bool mIsConnected;
        private string mPKUserId;
        private string mPKRoomId;

        public TRTCConnectionForm(TRTCMainForm mainForm)
        {
            InitializeComponent();

            this.Disposed += new EventHandler(OnDisposed);

            mTRTCCloud = DataManager.GetInstance().trtcCloud;
            mMainForm = mainForm;
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

        private void OnExitPicBoxClick(object sender, EventArgs e)
        {
            this.infoLabel.Text = "";
            mMainForm.OnConnectionFormClose();
            this.Close();
        }

        private void OnConnectBtnClick(object sender, EventArgs e)
        {
            mPKUserId = this.userTextBox.Text;
            mPKRoomId = this.roomTextBox.Text;
            if (string.IsNullOrEmpty(mPKUserId) || string.IsNullOrEmpty(mPKRoomId))
            {
                this.infoLabel.Text = "用户名或房间号不能为空！";
                return;
            }
            uint roomId;
            if (!uint.TryParse(mPKRoomId, out roomId))
            {
                this.infoLabel.Text = String.Format("目前支持的最大房间号为{0}", uint.MaxValue);
                return;
            }
            dynamic jsonObj = new JObject();
            jsonObj["roomId"] = roomId;
            jsonObj["userId"] = mPKUserId;
            string jsonData = JsonConvert.SerializeObject(jsonObj);
            mTRTCCloud.connectOtherRoom(jsonData);
            this.infoLabel.Text = String.Format("连接房间[{0}]中...", mPKRoomId, mPKUserId);
        }

        private void OnDisconnectBtnClick(object sender, EventArgs e)
        {
            if (mIsConnected)
            {
                // 如果此时是多人连麦，则是取消所有连麦的用户
                mTRTCCloud.disconnectOtherRoom();
                this.infoLabel.Text = String.Format("取消连麦中...");
            }
        }

        private void OnRoomTextBoxKeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar != '\b')
            {
                if (e.KeyChar < 48 || e.KeyChar > 57)
                    e.Handled = true;
            }
        }

        public void OnConnectOtherRoom(string userId, TXLiteAVError errCode, string errMsg)
        {
            if (userId != mPKUserId)
            {
                mIsConnected = false;
                return;
            }
            if (errCode == TXLiteAVError.ERR_NULL)
            {
                // 连麦成功
                mIsConnected = true;
                this.infoLabel.Text = String.Format("连麦成功:[room:{0}, user:{1}]", mPKRoomId, mPKUserId);
                this.disconnectBtn.Enabled = true;
                uint roomId;
                if (!uint.TryParse(mPKRoomId, out roomId))
                {
                    this.infoLabel.Text = String.Format("目前支持的最大房间号为{0}", uint.MaxValue);
                    return;
                }
                mMainForm.AddPKUser(roomId, mPKUserId);
            }
            else
            {
                // 连麦失败
                this.infoLabel.Text = String.Format("连麦失败,errCode:{0}", (int)errCode);
                Log.I(String.Format("连麦失败[userId:{0}, roomId:{1}, errCode:{2}, msg:{3}]", mPKUserId, mPKRoomId, errCode, errMsg));
            }
        }

        public void OnDisconnectOtherRoom(TXLiteAVError errCode, string errMsg)
        {
            if (errCode == TXLiteAVError.ERR_NULL)
            {
                // 取消连麦成功
                mIsConnected = false;
                this.infoLabel.Text = String.Format("取消连麦成功");
                this.disconnectBtn.Enabled = false;
                mMainForm.ClearPKUsers();
            }
            else
            {
                // 取消连麦失败
                this.infoLabel.Text = String.Format("取消连麦失败,errCode:{0}", (int)errCode);
                Log.I(String.Format("取消连麦失败[userId:{0}, roomId:{1}, errCode:{2}, msg:{3}]", mPKUserId, mPKRoomId, errCode, errMsg));

            }
        }

        public void SetDisconnectBtnEnabled(bool enable)
        {
            this.disconnectBtn.Enabled = enable;
        }
    }
}
