using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using TRTCWPFDemo.Common;

namespace TRTCWPFDemo
{
    public static class Program
    {
        // 外部函数声明
        [DllImport("User32.dll")]
        private static extern Int32 SetProcessDPIAware();

        /// <summary>
        /// Application Entry Point.
        /// </summary>
        [System.STAThreadAttribute()]
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
        public static void Main()
        {
            ManageLiteAV.CrashDump dump = new ManageLiteAV.CrashDump();
            dump.open();

            SetProcessDPIAware();   // 默认关闭高DPI，避免SDK录制出错

            Log.Open();
            // 初始化SDK的 Local 配置信息
            DataManager.GetInstance().InitConfig();

            Process processes = Process.GetCurrentProcess();
            Log.I(String.Format("Progress <{0}, {1}>", processes.ProcessName, processes.Id));

            TRTCWPFDemo.App app = new TRTCWPFDemo.App();
            app.InitializeComponent();
            app.Run();

            // 退出程序前写入最新的 Local 配置信息。
            DataManager.GetInstance().Uninit();
            DataManager.GetInstance().Dispose();

            Log.Close();

            dump.close();
        }
    }
}
