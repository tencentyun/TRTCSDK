using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;

namespace TRTCCSharpDemo.Common
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
            string buffer = "0123456789";// 随机字符中也可以为汉字（任何）
            StringBuilder sb = new StringBuilder();
            Random r = new Random();
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

        public static Bitmap Rotate(Bitmap b, int angle)
        {
            angle = angle % 360;
            //弧度转换
            double radian = angle * Math.PI / 180.0;
            double cos = Math.Cos(radian);
            double sin = Math.Sin(radian);
            //原图的宽和高
            int w = b.Width;
            int h = b.Height;
            int W = (int)(Math.Max(Math.Abs(w * cos - h * sin), Math.Abs(w * cos + h * sin)));
            int H = (int)(Math.Max(Math.Abs(w * sin - h * cos), Math.Abs(w * sin + h * cos)));
            //目标位图
            Bitmap dsImage = new Bitmap(W, H);
            System.Drawing.Graphics g = System.Drawing.Graphics.FromImage(dsImage);
            g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.Bilinear;
            g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
            //计算偏移量
            Point Offset = new Point((W - w) / 2, (H - h) / 2);
            //构造图像显示区域：让图像的中心与窗口的中心点一致
            Rectangle rect = new Rectangle(Offset.X, Offset.Y, w, h);
            Point center = new Point(rect.X + rect.Width / 2, rect.Y + rect.Height / 2);
            g.TranslateTransform(center.X, center.Y);
            g.RotateTransform(360 - angle);
            //恢复图像在水平和垂直方向的平移
            g.TranslateTransform(-center.X, -center.Y);
            g.DrawImage(b, rect);
            //重至绘图的所有变换
            g.ResetTransform();
            g.Save();
            g.Dispose();
            return dsImage;
        }

        public static PicSize AdjustSize(int spcWidth, int spcHeight, int orgWidth, int orgHeight)
        {
            PicSize size = new PicSize();
            if (orgWidth <= spcWidth && orgHeight <= spcHeight)
            {
                // 取得比例系数 
                float w = spcWidth / (float)orgWidth;
                float h = spcHeight / (float)orgHeight;
                if (w > h)
                {
                    size.height = spcHeight;
                    size.width = (int)(Math.Round(orgWidth * h));
                }
                else if (w < h)
                {
                    size.width = spcWidth;
                    size.height = (int)(Math.Round(orgHeight * w));
                }
                else
                {
                    size.width = spcWidth;
                    size.height = spcWidth;
                }
            }
            else
            {
                // 取得比例系数 
                float w = orgWidth / (float)spcWidth;
                float h = orgHeight / (float)spcHeight;
                // 宽度比大于高度比 
                if (w > h)
                {
                    size.width = spcWidth;
                    size.height = (int)(w >= 1 ? Math.Round(orgHeight / w) : Math.Round(orgHeight * w));
                }
                // 宽度比小于高度比 
                else if (w < h)
                {
                    size.height = spcHeight;
                    size.width = (int)(h >= 1 ? Math.Round(orgWidth / h) : Math.Round(orgWidth * h));
                }
                // 宽度比等于高度比 
                else
                {
                    size.width = spcWidth;
                    size.height = spcHeight;
                }
            }
            return size;
        }
    }

    public struct PicSize
    {
        public int width;
        public int height;
    }
}
