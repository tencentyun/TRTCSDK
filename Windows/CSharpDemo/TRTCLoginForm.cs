using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Xml.Serialization;
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
        private const string FILEPATH = "./userinfo.xml";
        private XmlSerializer mSerializer = new XmlSerializer(typeof(UserInfo));

        private UserInfo mUserInfo;
        private int mTestEnv = 0;

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

            if (IsTestEnv())
            {
                this.formalEnvRadioBtn.Visible = true;
                this.testEnvRadioBtn.Visible = true;
                this.lifeEnvRadioBtn.Visible = true;
            }
            else
            {
                this.formalEnvRadioBtn.Visible = false;
                this.testEnvRadioBtn.Visible = false;
                this.lifeEnvRadioBtn.Visible = false;
            }

            try
            {
                if (File.Exists(FILEPATH))
                {
                    FileStream fs = new FileStream(FILEPATH, FileMode.Open);
                    UserInfo info = (UserInfo)mSerializer.Deserialize(fs);
                    mUserInfo = info;
                    this.userTextBox.Text = info.userId;
                    this.roomTextBox.Text = info.roomId.ToString();
                    fs.Close();
                }
                else
                {
                    mUserInfo = new UserInfo
                    {
                        userId = this.userTextBox.Text,
                        roomId = int.Parse(this.roomTextBox.Text)
                    };
                    FileStream fs = new FileStream(FILEPATH, FileMode.CreateNew);
                    TextWriter tw = new StreamWriter(fs);
                    mSerializer.Serialize(tw, mUserInfo);
                    tw.Close();
                    fs.Close();
                }

            }
            catch (Exception ex)
            {
                Log.E(ex.Message);
            }

            if (mTestEnv == 0)
                this.formalEnvRadioBtn.Checked = true;
            else if (mTestEnv == 1)
                this.testEnvRadioBtn.Checked = true;
            else if (mTestEnv == 2)
                this.lifeEnvRadioBtn.Checked = true;
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
            SetTestEnv();

            string userId = this.userTextBox.Text;
            string roomId = this.roomTextBox.Text;
            if(string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(roomId))
            {
                ShowMessage("房间号或用户号不能为空！");
                return;
            }
            int room = int.Parse(roomId);
            // 从本地计算获取 userId 对应的 userSig
            string userSig = GenerateTestUserSig.GetInstance().GenTestUserSig(userId);
            if (string.IsNullOrEmpty(userSig))
            {
                ShowMessage("userSig 获取失败，请检查是否填写账号信息！");
                return;
            }

            TRTCParams trtcParams = new TRTCParams();
            trtcParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
            trtcParams.roomId = (uint)room;
            trtcParams.userId = userId;
            trtcParams.userSig = userSig;
            trtcParams.privateMapKey = "";
            trtcParams.businessInfo = "";
            trtcParams.role = TRTCRoleType.TRTCRoleAnchor;

            this.Hide();
            TRTCMainForm mainForm  = new TRTCMainForm(this);
            mainForm.Show();
            SaveUserInfo();
            mainForm.SetTestEnv(mTestEnv);
            mainForm.EnterRoom(trtcParams);
        }

        private void SetTestEnv()
        {
            if (this.formalEnvRadioBtn.Checked)
                mTestEnv = 0;
            else if (this.testEnvRadioBtn.Checked)
                mTestEnv = 1;
            else if (this.lifeEnvRadioBtn.Checked)
                mTestEnv = 2;
        }

        private void SaveUserInfo()
        {
            try
            {
                mUserInfo.userId = this.userTextBox.Text;
                mUserInfo.roomId = int.Parse(this.roomTextBox.Text);
                FileStream fs = new FileStream(FILEPATH, FileMode.Create);
                TextWriter tw = new StreamWriter(fs);
                mSerializer.Serialize(tw, mUserInfo);
                tw.Close();
                fs.Close();
            }
            catch (Exception e)
            {
                Log.E(e.Message);
            }
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

        private bool IsTestEnv()
        {
            string path = Environment.CurrentDirectory + "\\ShowTestEnv.txt";
            return File.Exists(path);
        }
    }

    [Serializable]
    public class UserInfo
    {

        public string userId { get; set; }

        public int roomId { get; set; }
    }
}
