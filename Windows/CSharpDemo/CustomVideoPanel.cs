using System;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using ManageLiteAV;
using TRTCCSharpDemo.Common;

namespace TRTCCSharpDemo.CustomControl
{
    /// <summary>
    /// 支持本地自定义渲染的Panel，如果需要开启渲染，则调用 startCustomRender(true)。
    /// </summary>
    public class CustomVideoPanel : Panel, ITRTCVideoRenderCallback
    {
        // 是否开启自定义渲染
        private bool mIsStartCustomRender;
        private bool isRegEngine;

        private ITRTCCloud mTRTCCloud;

        // 同步锁，防止回调数据在进行操作时，渲染也同时在操作，导致同步问题
        private Object locker = new Object();

        private TRTCVideoFillMode mRenderMode;
        private volatile AVFrameBufferInfo mArgbRenderFrame;

        public CustomVideoPanel()
        {
            mIsStartCustomRender = false;  // 默认关闭自定义渲染
            mRenderMode = TRTCVideoFillMode.TRTCVideoFillMode_Fit;
            mArgbRenderFrame = new AVFrameBufferInfo();

            // 使用双缓冲，防止绘制过程出现闪烁
            SetStyle(ControlStyles.UserPaint, true);
            SetStyle(ControlStyles.AllPaintingInWmPaint, true); // 禁止擦除背景.
            SetStyle(ControlStyles.DoubleBuffer, true); // 双缓冲

            this.Disposed += new EventHandler(OnDispose);
        }

        public void RegEngine(ITRTCCloud cloud)
        {
            isRegEngine = true;
            mTRTCCloud = cloud;
            mTRTCCloud.setLocalVideoRenderCallback(TRTCVideoPixelFormat.TRTCVideoPixelFormat_BGRA32, TRTCVideoBufferType.TRTCVideoBufferType_Buffer, this);
        }

        private void OnDispose(object sender, EventArgs e)
        {
            // 清理资源
            if (isRegEngine)
                mTRTCCloud.setLocalVideoRenderCallback(TRTCVideoPixelFormat.TRTCVideoPixelFormat_Unknown, TRTCVideoBufferType.TRTCVideoBufferType_Unknown, null);
            mTRTCCloud = null;
            mArgbRenderFrame.data = null;
            mArgbRenderFrame = null;
        }

        public void onRenderVideoFrame(string userId, TRTCVideoStreamType streamType, TRTCVideoFrame frame)
        {
            // 回调不是在主线程，处理数据时需要注意多线程下的同步问题
            if (mIsStartCustomRender && string.IsNullOrEmpty(userId) && streamType == TRTCVideoStreamType.TRTCVideoStreamTypeBig)
            {
                AppendVideoFrame(frame.data, frame.length, frame.width, frame.height, frame.videoFormat, frame.rotation);
                // 实时刷新画面渲染数据
                this.Invoke(new Action(() => { this.Refresh(); }));
            }
        }

        /// <summary>
        /// 支持rbga数据处理，如需自定义数据，需重载此函数。
        /// </summary>
        private void AppendVideoFrame(byte[] data, uint length, uint width, uint height, TRTCVideoPixelFormat videoFormat, TRTCVideoRotation rotation)
        {
            if (data == null) return;
            // 当下不支持YUV
            if (videoFormat == TRTCVideoPixelFormat.TRTCVideoPixelFormat_I420 && length != width * height * 3 / 2)
                return;
            if (videoFormat == TRTCVideoPixelFormat.TRTCVideoPixelFormat_BGRA32 && length != width * height * 4)
                return;

            if (videoFormat == TRTCVideoPixelFormat.TRTCVideoPixelFormat_BGRA32)
            {
                lock (locker)
                {
                    if (mArgbRenderFrame.data == null || mArgbRenderFrame.width != width || mArgbRenderFrame.height != height)
                    {
                        ReleaseBuffer(mArgbRenderFrame);
                        mArgbRenderFrame.width = (int)width;
                        mArgbRenderFrame.height = (int)height;
                        mArgbRenderFrame.data = new byte[length];
                    }
                    Buffer.BlockCopy(data, 0, mArgbRenderFrame.data, 0, (int)length);
                    mArgbRenderFrame.newFrame = true;
                    mArgbRenderFrame.rotation = rotation;
                }
            }
        }

        private void ReleaseBuffer(AVFrameBufferInfo info)
        {
            if (info.data != null)
                info.data = null;
            info.width = 0;
            info.height = 0;
            info.newFrame = false;
            info.rotation = TRTCVideoRotation.TRTCVideoRotation0;
        }

        public void StartCustomRender(bool start)
        {
            mIsStartCustomRender = start;
            this.Visible = start;
        }

        public void SetRenderMode(TRTCVideoFillMode fillMode)
        {
            mRenderMode = fillMode;
        }

        [ToolboxItem(true)]
        protected override void OnPaint(PaintEventArgs pe)
        {
            base.OnPaint(pe);
            lock (locker)
            {
                if (mArgbRenderFrame.data == null) return;
                if (mRenderMode == TRTCVideoFillMode.TRTCVideoFillMode_Fit)
                    RenderFitMode(pe, mArgbRenderFrame.data, mArgbRenderFrame.width, mArgbRenderFrame.height, (int)mArgbRenderFrame.rotation * 90);
                else if (mRenderMode == TRTCVideoFillMode.TRTCVideoFillMode_Fill)
                    RenderFillMode(pe, mArgbRenderFrame.data, mArgbRenderFrame.width, mArgbRenderFrame.height, (int)mArgbRenderFrame.rotation * 90);
            }
        }

        private void RenderFillMode(PaintEventArgs pe, byte[] data, int width, int height, int rotation)
        {
            Graphics graphics = pe.Graphics;
            // 设置背景为全黑
            graphics.Clear(Color.Black);

            Bitmap bmp = new Bitmap(width, height, PixelFormat.Format32bppPArgb);
            BitmapData bmpData = bmp.LockBits(new Rectangle(0, 0, width, height), ImageLockMode.WriteOnly, PixelFormat.Format32bppPArgb);

            // 获取图像参数  
            int stride = bmpData.Stride;      // 扫描线的宽度  
            IntPtr iptr = bmpData.Scan0;      // 获取bmpData的内存起始位置  
            int scanBytes = stride * height;  // 用stride宽度，表示这是内存区域的大小  

            // 用Marshal的Copy方法，将刚才得到的内存字节数组复制到BitmapData中
            Marshal.Copy(data, 0, iptr, scanBytes);
            bmp.UnlockBits(bmpData);

            bmp = Util.Rotate(bmp, rotation);

            // 填充整个画面
            int viewWidth = this.ClientSize.Width;
            int viewHeight = this.ClientSize.Height;
            PicSize size = Util.AdjustSize(viewWidth, viewHeight, bmp.Width, bmp.Height);
            width = size.width;
            height = size.height;
            if (size.width == viewWidth)
            {
                // 此时上下有黑边，需填充
                height = viewHeight;
            }
            else
            {
                // 此时左右有黑边，需填充
                width = viewWidth;
            }

            int x = (viewWidth - width) / 2;
            int y = (viewHeight - height) / 2;
            Rectangle rect = new Rectangle(x, y, width, height);

            graphics.DrawImage(bmp, rect);
            bmp.Dispose();
        }

        private void RenderFitMode(PaintEventArgs pe, byte[] data, int width, int height, int rotation)
        {
            Graphics graphics = pe.Graphics;
            // 设置背景为全黑
            graphics.Clear(Color.Black);

            Bitmap bmp = new Bitmap(width, height, PixelFormat.Format32bppPArgb);
            BitmapData bmpData = bmp.LockBits(new Rectangle(0, 0, width, height), ImageLockMode.WriteOnly, PixelFormat.Format32bppPArgb);

            // 获取图像参数  
            int stride = bmpData.Stride;      // 扫描线的宽度  
            IntPtr iptr = bmpData.Scan0;      // 获取bmpData的内存起始位置  
            int scanBytes = stride * height;  // 用stride宽度，表示这是内存区域的大小  

            // 用Marshal的Copy方法，将刚才得到的内存字节数组复制到BitmapData中
            Marshal.Copy(data, 0, iptr, scanBytes);
            bmp.UnlockBits(bmpData);

            bmp = Util.Rotate(bmp, rotation);

            // 获取缩放后的矩形大小
            int viewWidth = this.ClientSize.Width;
            int viewHeight = this.ClientSize.Height;
            PicSize size = Util.AdjustSize(viewWidth, viewHeight, bmp.Width, bmp.Height);
            width = size.width;
            height = size.height;
            int x = (viewWidth - width) / 2;
            int y = (viewHeight - height) / 2;
            Rectangle rect = new Rectangle(x, y, width, height);

            graphics.DrawImage(bmp, rect);
            bmp.Dispose();
        }
    }
}
