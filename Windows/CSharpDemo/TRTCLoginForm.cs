using System;
using System.Drawing;
using System.Windows.Forms;
using TRTCCSharpDemo.Common;
using ManageLiteAV;

/// <summary>
/// Module： TRTCLoginForm
/// 
/// Function： 该界面可以让用户输入一个【房间号】和一个【用户名】
/// 
/// Notice：
/// （1）房间号为数字类型，用户名为字符串类型
///
/// （2）在真实的使用场景中，房间号大多不是用户手动输入的，而是系统分配的，
///      比如视频会议中的会议号是会控系统提前预定好的，客服系统中的房间号也是根据客服员工的工号决定的。
/// </summary>

namespace TRTCCSharpDemo
{
    public partial class TRTCLoginForm : Form
    {
        public TRTCLoginForm()
        {
            InitializeComponent();

            this.Disposed += new EventHandler(OnDisposed);
        }

        private void OnDisposed(object sender, EventArgs e)
        {
            //清理资源
        }

        private void ShowMessage(string text)
        {
            MessageForm msgBox = new MessageForm();
            msgBox.setText(text);
            msgBox.setCancelBtn(false);
            msgBox.ShowDialog();
        }

        private void OnLoad(object sender, EventArgs e)
        {
            this.roomTextBox.Focus();
            this.userTextBox.Text = DataManager.GetInstance().userId;
            this.roomTextBox.Text = DataManager.GetInstance().roomId.ToString();

            if (Util.IsTestEnv())
            {
                this.formalEnvRadioBtn.Visible = true;
                this.testEnvRadioBtn.Visible = true;
                this.lifeEnvRadioBtn.Visible = true;
                this.audioRadioBtn.Visible = true;
                this.videoRadioBtn.Visible = true;

                if (DataManager.GetInstance().testEnv == 0)
                    this.formalEnvRadioBtn.Checked = true;
                else if (DataManager.GetInstance().testEnv == 1)
                    this.testEnvRadioBtn.Checked = true;
                else if (DataManager.GetInstance().testEnv == 2)
                    this.lifeEnvRadioBtn.Checked = true;
                if (DataManager.GetInstance().pureAudioStyle)
                    this.audioRadioBtn.Checked = true;
                else
                    this.videoRadioBtn.Checked = true;
            }
            else
            {
                this.formalEnvRadioBtn.Visible = false;
                this.testEnvRadioBtn.Visible = false;
                this.lifeEnvRadioBtn.Visible = false;
                this.audioRadioBtn.Visible = false;
                this.videoRadioBtn.Visible = false;

                DataManager.GetInstance().testEnv = 0;
                DataManager.GetInstance().pureAudioStyle = false;
            }
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

        private void OnJoinRoomBtnClick(object sender, EventArgs e)
        {
            if (GenerateTestUserSig.SDKAPPID == 0)
            {
                ShowMessage("Error: 请先在 GenerateTestUserSig 填写 sdkappid 信息");
                return;
            }

            SetTestEnv();
            SetPureAudioStyle();

            string userId = this.userTextBox.Text;
            string roomId = this.roomTextBox.Text;
            if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(roomId))
            {
                ShowMessage("房间号或用户号不能为空！");
                return;
            }

            uint room = 0;
            if (!uint.TryParse(roomId, out room))
            {
                ShowMessage(String.Format("目前支持的最大房间号为{0}", uint.MaxValue));
                return;
            }

            DataManager.GetInstance().userId = userId;
            DataManager.GetInstance().roomId = room;

            // 从本地计算获取 userId 对应的 userSig
            // 注意！本地计算是适合在本地环境下调试使用，正确的做法是将 UserSig 的计算代码和加密密钥放在您的业务服务器上，
            // 然后由 App 按需向您的服务器获取实时算出的 UserSig。
            // 由于破解服务器的成本要高于破解客户端 App，所以服务器计算的方案能够更好地保护您的加密密钥。
            string userSig = GenerateTestUserSig.GetInstance().GenTestUserSig(userId);
            if (string.IsNullOrEmpty(userSig))
            {
                ShowMessage("userSig 获取失败，请检查是否填写账号信息！");
                return;
            }

            this.Hide();
            TRTCMainForm mainForm  = new TRTCMainForm(this);
            mainForm.Show();
            mainForm.EnterRoom();
        }

        /// <summary>
        /// 设置连接环境，只适用于本地调试测试使用
        /// </summary>
        private void SetTestEnv()
        {
            if (this.formalEnvRadioBtn.Checked)
                DataManager.GetInstance().testEnv = 0;
            else if (this.testEnvRadioBtn.Checked)
                DataManager.GetInstance().testEnv = 1;
            else if (this.lifeEnvRadioBtn.Checked)
                DataManager.GetInstance().testEnv = 2;
        }

        /// <summary>
        /// 设置是否使用纯音频环境进房
        /// </summary>
        private void SetPureAudioStyle()
        {
            if (this.audioRadioBtn.Checked)
                DataManager.GetInstance().pureAudioStyle = true;
            else if (this.videoRadioBtn.Checked)
                DataManager.GetInstance().pureAudioStyle = false;
        }

        private void OnExitPicBoxClick(object sender, EventArgs e)
        {
            this.Close();
            Application.Exit();
        }

        private void OnRoomTextBoxKeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar != '\b')
            {
                if (e.KeyChar < 48 || e.KeyChar > 57)
                    e.Handled = true;
            }
        }
        
    }
}
