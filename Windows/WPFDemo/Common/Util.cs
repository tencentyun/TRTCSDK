using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace TRTCWPFDemo.Common
{
    class Util
    {
        public static string UTF16To8(string str)
        {
            byte[] utf16Bytes = Encoding.Unicode.GetBytes(str);
            byte[] utf8Bytes = Encoding.Convert(Encoding.Unicode, Encoding.UTF8, utf16Bytes);
            return Encoding.UTF8.GetString(utf8Bytes);
        }

        public static bool IsSys64bit()
        {
            return IntPtr.Size == 8;
        }

        public static string GetRandomString(int iLength)
        {
            string buffer = "0123456789";
            StringBuilder sb = new StringBuilder();
            Random r = new Random(iLength);
            int range = buffer.Length;
            for (int i = 0; i < iLength; i++)
            {
                sb.Append(buffer.Substring(r.Next(range), 1));
            }
            return sb.ToString();
        }

        public static string MD5(string str)
        {
            MD5 md5 = System.Security.Cryptography.MD5.Create();
            byte[] byteOld = Encoding.UTF8.GetBytes(str);
            byte[] byteNew = md5.ComputeHash(byteOld);
            StringBuilder sb = new StringBuilder();
            foreach (byte b in byteNew)
            {
                // 将字节转换成16进制表示的字符串
                sb.Append(b.ToString("x2"));
            }
            return sb.ToString();
        }
    }
}
