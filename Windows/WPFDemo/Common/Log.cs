using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Threading;
using System.Diagnostics;
using System.Reflection;

namespace TRTCWPFDemo.Common
{
    class Log
    {
        private static TextWriter tWriter = null;  

        public static void Open()
        {
            try
            {
                string path = AppDomain.CurrentDomain.SetupInformation.ApplicationBase;
                path += "demolog\\";
                Directory.CreateDirectory(path);

                path += DateTime.Now.ToString("yyyy_MM_dd_HH_mm_ss_fff");
                path += ".log";
                // 使用Synchronized进行包装，防止 IO 不安全
                tWriter = TextWriter.Synchronized(new StreamWriter(path));  
                
            }
            catch (Exception e)
            {
                Debug.Assert(false);
                Console.WriteLine(e.ToString());
            }
        }

        public static void Close()
        {
            if (null != tWriter)
            {
                tWriter.Flush();
                tWriter.Close();

                tWriter = null;
            }
        }

        public static void I(string content)
        {
            string parentMethod = "";

            StackTrace stackTrace = new StackTrace(true);
            MethodBase methodBase = stackTrace.GetFrame(1).GetMethod();

            // 取得父方法类全名
            parentMethod += methodBase.DeclaringType.FullName;

            // 分隔符
            parentMethod += ".";

            // 取得父方法名
            parentMethod += methodBase.Name;

            write(parentMethod, content);
        }

        public static void E(string content)
        {
            string parentMethod = "";

            StackTrace stackTrace = new StackTrace(true);
            MethodBase methodBase = stackTrace.GetFrame(1).GetMethod();

            // 取得父方法类全名
            parentMethod += methodBase.DeclaringType.FullName;

            // 分隔符
            parentMethod += ".";

            // 取得父方法名
            parentMethod += methodBase.Name;

            write(parentMethod, content);
        }

        private static void write(string parentMethod, string content)
        {
            string msg = String.Format("[{0}][{1}], [{2}], [{3}]"
                , System.Threading.Thread.CurrentThread.ManagedThreadId
                , DateTime.Now.ToString("MM-dd HH:mm:ss.fff")
                , parentMethod
                , content);

            Console.WriteLine(msg);

            if (null != tWriter)
            {
                tWriter.WriteLine(msg);
            }
        }
    }
}
