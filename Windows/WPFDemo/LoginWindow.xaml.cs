using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using TRTCWPFDemo;

namespace TRTCWPFDemo
{
    /// <summary>
    /// LoginWindow.xaml 的交互逻辑
    /// </summary>
    public partial class LoginWindow : Window
    {
        public LoginWindow()
        {
            InitializeComponent();
            this.Loaded += LoginWindow_Loaded;
        }

        private void LoginWindow_Loaded(object sender, RoutedEventArgs e)
        {
            this.userTextBox.Text = DataManager.GetInstance().userId;
            this.roomTextBox.Text = DataManager.GetInstance().roomId.ToString();
        }

        private void ShowMessage(string message)
        {
            MessageBox.Show(message);
        }

        private void JoinBtn_Click(object sender, RoutedEventArgs e)
        {
            if (GenerateTestUserSig.SDKAPPID == 0)
            {
                ShowMessage("Error: 请先在 GenerateTestUserSig 填写 sdkappid 信息");
                return;
            }

            string userId = this.userTextBox.Text;
            string roomId = this.roomTextBox.Text;
            if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(roomId))
            {
                ShowMessage("房间号或用户号不能为空！");
                return;
            }

            DataManager.GetInstance().userId = userId;
            DataManager.GetInstance().roomId = uint.Parse(roomId);

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

            MainWindow mainWindow = new MainWindow();
            mainWindow.Show();
            mainWindow.EnterRoom();
            this.Close();
        }

        private void RoomTextBox_PreviewKeyDown(object sender, KeyEventArgs e)
        {
            bool shiftKey = (Keyboard.Modifiers & ModifierKeys.Shift) != 0;
            if (shiftKey == true)
            {
                e.Handled = true;
            }
            else
            {
                if (!((e.Key >= Key.D0 && e.Key <= Key.D9) || (e.Key >= Key.NumPad0 && e.Key <= Key.NumPad9) || e.Key == Key.Delete || e.Key == Key.Back || e.Key == Key.Tab || e.Key == Key.Enter))
                {
                    e.Handled = true;
                }
            }
        }
    }
}
