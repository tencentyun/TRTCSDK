using System;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using TRTCCSharpDemo.Common;
using System.Diagnostics;
using System.Threading;

namespace TRTCCSharpDemo
{
    static class Program
    {
        // 外部函数声明
        [DllImport("User32.dll")]
        private static extern Int32 SetProcessDPIAware();

        public static EventWaitHandle ProgramStarted;

        /// <summary>
        /// 应用程序的主入口点。
        /// </summary>
        [STAThread]
        static void Main()
        {
            ManageLiteAV.CrashDump dump = new ManageLiteAV.CrashDump();
            dump.open();

            // 尝试创建一个命名事件
            bool createNew;
            ProgramStarted = new EventWaitHandle(false, EventResetMode.AutoReset, "TRTCStartEvent", out createNew);

            // 如果该命名事件已经存在(存在有前一个运行实例)，则发事件通知并退出
            if (!createNew)
            {
                ProgramStarted.Set();
                return;
            }

            SetProcessDPIAware();   // 默认关闭高DPI，避免SDK录制出错

            Log.Open();
            // 初始化SDK的 Local 配置信息
            DataManager.GetInstance().InitConfig();

            Process processes = Process.GetCurrentProcess();
            Log.I(String.Format("Progress <{0}, {1}>", processes.ProcessName, processes.Id));

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new TRTCCSharpDemo.TRTCLoginForm());

            // 退出程序前写入最新的 Local 配置信息。
            DataManager.GetInstance().Uninit();
            DataManager.GetInstance().Dispose();

            Log.Close();

            dump.close();
        }
    }
}
