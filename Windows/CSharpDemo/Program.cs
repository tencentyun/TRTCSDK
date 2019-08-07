using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using TRTCCSharpDemo.Common;
using System.Diagnostics;
using System.Threading;
using ManageLiteAV;

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

            // 统一在程序运行时获取ITRTCCloud实例
            ITRTCCloud cloud = ITRTCCloud.getTRTCShareInstance();

            ManageLiteAV.CrashDump dump = new ManageLiteAV.CrashDump();
            dump.open();

            Log.Open();

            Process processes = Process.GetCurrentProcess();
            Log.I(String.Format("Progress <{0}, {1}>", processes.ProcessName, processes.Id));

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new TRTCCSharpDemo.TRTCLoginForm());

            Log.Close();

            dump.close();

            // 在程序结束后调用 Dispose 方法清理资源，并摧毁ITRTCCloud实例。
            cloud.Dispose();
            ITRTCCloud.destroyTRTCShareInstance();
        }
    }
}
