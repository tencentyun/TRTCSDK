using ManageLiteAV;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;
using TRTCCSharpDemo.Common;

/// <summary>
/// Winform 框架实现的自定义视频渲染 View，与 TRTC SDK 相关联，可直接拷贝使用，也可以对其进行相应的扩展。
/// 
/// 主要提供的 API 如下：
/// 1.RegEngine(string userId, TRTCVideoStreamType type, ITRTCCloud engine, bool local = false);
/// 2.RemoveEngine(ITRTCCloud engine);
/// 3.SetRenderMode(TRTCVideoFillMode mode);
/// 4.IsViewOccupy();
/// 5.SetPause(bool pause);
/// 6.RemoveAllRegEngine();
/// 
/// 主要使用方式如下：
/// 1. 本地画面渲染：
/// 在打开 startLocalPreview(IntPtr.Zero) 前后通过 TXLiteAVVideoView.RegEngine(localUserId, type, engine, true) 
/// 设置好该 View 绑定的 SDK 渲染回调，并把该 View 添加到您需要显示的父 View 中即可。
/// 2. 远端画面渲染：
/// 在打开 startRemoteView(remoteUserId, IntPtr.Zero) 或 startRemoteSubStreamView(remoteUserId, IntPtr.Zero) 
/// 前后通过 TXLiteAVVideoView.RegEngine(remoteUserId, type, engine, true) 
/// 设置好该 View 绑定的 SDK 渲染回调，并把该 View 添加到您需要显示的父 View 中即可。
/// 3. 移除画面：
/// 在用户退出房间或者远端用户退出时使用 TXLiteAVVideoView.RemoveEngine(engine) 即可。
/// </summary>
/// <remarks>
/// 接口非线程安全，请在主线程中调用。
/// 
/// 注意：由于远端主流和辅流只需要设置一次 setRemoteVideoRenderCallback 即可，所以最好统一在远端用户退房时移除监听，
/// 否则当有一流的数据调用了取消监听时，就会导致该用户的其他流都接收不到数据。
/// </remarks>
namespace TRTCCSharpDemo
{
    public class TXLiteAVVideoView : Panel
    {
        private bool mOccupy = false;     // view 是否已被占用
        private bool mLocalView = false;  // 是否为本地画面
        private bool mPause = false;
        private bool mFirstFrame = false;

        private string mUserId;
        private TRTCVideoStreamType mStreamType;
        private TRTCVideoFillMode mRenderMode = TRTCVideoFillMode.TRTCVideoFillMode_Fit;  // 0：填充，1：适应

        private volatile FrameBufferInfo mArgbFrame = new FrameBufferInfo();  // 帧缓存

        public TXLiteAVVideoView()
        {
            this.BorderStyle = BorderStyle.None;

            // 使用双缓冲，防止绘制过程出现闪烁
            SetStyle(ControlStyles.UserPaint, true);
            SetStyle(ControlStyles.AllPaintingInWmPaint, true); // 禁止擦除背景.
            SetStyle(ControlStyles.DoubleBuffer, true); // 双缓冲

            this.Disposed += new EventHandler(OnDispose);
        }

        private void OnDispose(object sender, EventArgs e)
        {
            // 清理资源
            ReleaseBuffer(mArgbFrame);
        }

        /// <summary>
        /// 设置 View 绑定参数
        /// </summary>
        /// <param name="userId">需要渲染画面的 userId，如果是本地画面，则传空字符串。</param>
        /// <param name="type">渲染类型</param>
        /// <param name="engine">TRTCCloud 实例，用户注册视频数据回调。</param>
        /// <param name="local">渲染本地画面，SDK 返回的 userId 为""</param>
        /// <returns>true：绑定成功，false：绑定失败</returns>
        public bool RegEngine(string userId, TRTCVideoStreamType type, ITRTCCloud engine, bool local = false)
        {
            if (mOccupy) return false;
            mLocalView = local;
            mUserId = userId;
            mStreamType = type;
            int count = TXLiteAVVideoViewManager.GetInstance().Count;
            if (engine != null)
            {
                if (count == 0)
                {
                    engine.setLocalVideoRenderCallback(TRTCVideoPixelFormat.TRTCVideoPixelFormat_BGRA32,
                        TRTCVideoBufferType.TRTCVideoBufferType_Buffer, TXLiteAVVideoViewManager.GetInstance());
                }
                if (!mLocalView)
                {
                    engine.setRemoteVideoRenderCallback(userId, TRTCVideoPixelFormat.TRTCVideoPixelFormat_BGRA32,
                        TRTCVideoBufferType.TRTCVideoBufferType_Buffer, TXLiteAVVideoViewManager.GetInstance());
                }
            }
            if (mLocalView)
                TXLiteAVVideoViewManager.GetInstance().AddView("", type, this);
            else
                TXLiteAVVideoViewManager.GetInstance().AddView(userId, type, this);
            lock (mArgbFrame)
                ReleaseBuffer(mArgbFrame);
            mOccupy = true;
            this.Refresh();
            return true;
        }

        /// <summary>
        /// 移除 View 绑定参数
        /// </summary>
        /// <param name="engine">TRTCCloud 实例，用户注册视频数据回调。</param>
        public void RemoveEngine(ITRTCCloud engine)
        {
            if (mLocalView)
                TXLiteAVVideoViewManager.GetInstance().RemoveView("", mStreamType, this);
            else
                TXLiteAVVideoViewManager.GetInstance().RemoveView(mUserId, mStreamType, this);
            int count = TXLiteAVVideoViewManager.GetInstance().Count;
            if (engine != null)
            {
                if (count == 0)
                {
                    engine.setLocalVideoRenderCallback(TRTCVideoPixelFormat.TRTCVideoPixelFormat_Unknown,
                        TRTCVideoBufferType.TRTCVideoBufferType_Unknown, null);
                }
                if (!mLocalView && !TXLiteAVVideoViewManager.GetInstance().HasUserId(mUserId))
                {
                    engine.setRemoteVideoRenderCallback(mUserId, TRTCVideoPixelFormat.TRTCVideoPixelFormat_Unknown,
                        TRTCVideoBufferType.TRTCVideoBufferType_Unknown, null);
                }
            }
            lock (mArgbFrame)
                ReleaseBuffer(mArgbFrame);
            mUserId = "";
            mOccupy = false;
            mLocalView = false;
            mFirstFrame = false;
            mRenderMode = TRTCVideoFillMode.TRTCVideoFillMode_Fit;
            this.Refresh();
        }

        /// <summary>
        /// 设置 View 的渲染模式
        /// </summary>
        /// <param name="mode">渲染模式</param>
        public void SetRenderMode(TRTCVideoFillMode mode)
        {
            mRenderMode = mode;
        }

        /// <summary>
        /// 判断 View 是否被占用
        /// </summary>
        /// <returns>true：当前 View 已被占用，false：当前 View 未被占用</returns>
        public bool IsViewOccupy()
        {
            return mOccupy;
        }

        /// <summary>
        /// 暂停渲染，显示默认图片
        /// </summary>
        /// <param name="pause">是否暂停</param>
        public void SetPause(bool pause)
        {
            if (mPause != pause)
            {
                mPause = pause;
                if (mPause)
                {
                    this.BackColor = Color.FromArgb(0xFF, 0x20, 0x20, 0x20);
                }
                else
                {
                    this.BackColor = Color.FromArgb(0xFF, 0x00, 0x00, 0x00);
                    // 避免刷新最后一帧数据
                    lock (mArgbFrame)
                        ReleaseBuffer(mArgbFrame);
                }
                this.Refresh();
            }
        }

        /// <summary>
        /// 清除所有映射信息
        /// </summary>
        public static void RemoveAllRegEngine()
        {
            TXLiteAVVideoViewManager.GetInstance().RemoveAllView();
        }

        public bool AppendVideoFrame(byte[] data, int width, int height, TRTCVideoPixelFormat videoFormat, TRTCVideoRotation rotation)
        {
            if (!mFirstFrame)
                mFirstFrame = true;
            if (mPause)
                return false;
            if (data == null || data.Length <= 0)
                return false;
            // data 数据有误
            if (videoFormat == TRTCVideoPixelFormat.TRTCVideoPixelFormat_BGRA32 && width * height * 4 != data.Length)
                return false;
            // 暂时不支持其他 YUV 类型
            if (videoFormat == TRTCVideoPixelFormat.TRTCVideoPixelFormat_I420 && width * height * 3 / 2 != data.Length)
                return false;

            // 目前只实现了 BGRA32 的数据类型，如需其他类型请重写，并设置回调的数据类型
            if (videoFormat == TRTCVideoPixelFormat.TRTCVideoPixelFormat_BGRA32)
            {
                lock (mArgbFrame)
                {
                    if (mArgbFrame.data == null || mArgbFrame.width != width || mArgbFrame.height != height)
                    {
                        ReleaseBuffer(mArgbFrame);
                        mArgbFrame.width = width;
                        mArgbFrame.height = height;
                        mArgbFrame.data = new byte[data.Length];
                    }
                    Buffer.BlockCopy(data, 0, mArgbFrame.data, 0, (int)data.Length);
                    mArgbFrame.newFrame = true;
                    mArgbFrame.rotation = rotation;
                }
            }

            // 回到主线程刷新当前画面
            this.InvokeOnUiThreadIfRequired(new Action(() =>
            {
                this.Refresh();
            }));
            return true;
        }

        private void InvokeOnUiThreadIfRequired(Action action)
        {
            try
            {
                if (!this.IsDisposed)
                {
                    if (this.InvokeRequired)
                    {
                        this.Invoke(action);
                    }
                    else
                    {
                        action.Invoke();
                    }
                }
                else
                    System.Threading.Thread.CurrentThread.Abort();
            }
            catch (Exception ex)
            {
                Log.E(ex.Message);
            }
        }

        protected override void OnPaint(PaintEventArgs pe)
        {
            bool needDrawFrame = true;
            if (mPause)
                needDrawFrame = false;
            if (mArgbFrame.data == null)
                needDrawFrame = false;
            if (!needDrawFrame)
            {
                return;
            }

            lock (mArgbFrame)
            {
                if (mArgbFrame.data == null)
                    return;
                if (mRenderMode == TRTCVideoFillMode.TRTCVideoFillMode_Fill)
                {
                    RenderFillMode(pe, mArgbFrame.data, mArgbFrame.width, mArgbFrame.height, (int)mArgbFrame.rotation * 90);
                }
                else if (mRenderMode == TRTCVideoFillMode.TRTCVideoFillMode_Fit)
                {
                    RenderFitMode(pe, mArgbFrame.data, mArgbFrame.width, mArgbFrame.height, (int)mArgbFrame.rotation * 90);
                }
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

            if (rotation > 0)
                bmp = Rotate(bmp, rotation);

            // 填充整个画面
            int viewWidth = this.ClientSize.Width;
            int viewHeight = this.ClientSize.Height;
            AdjustSize(viewWidth, viewHeight, bmp.Width, bmp.Height, out width, out height);
            if (width == viewWidth)
                height = viewHeight;
            else
                width = viewWidth;

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

            if (rotation > 0)
                bmp = Rotate(bmp, rotation);

            // 获取缩放后的矩形大小
            int viewWidth = this.ClientSize.Width;
            int viewHeight = this.ClientSize.Height;
            AdjustSize(viewWidth, viewHeight, bmp.Width, bmp.Height, out width, out height);
            int x = (viewWidth - width) / 2;
            int y = (viewHeight - height) / 2;
            Rectangle rect = new Rectangle(x, y, width, height);

            graphics.DrawImage(bmp, rect);
            bmp.Dispose();
        }

        private void ReleaseBuffer(FrameBufferInfo info)
        {
            if (info.data != null)
                info.data = null;
            info.width = 0;
            info.height = 0;
            info.newFrame = false;
            info.rotation = TRTCVideoRotation.TRTCVideoRotation0;
        }

        private Bitmap Rotate(Bitmap b, int angle)
        {
            if (angle == 0) return b;
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
            b.Dispose();
            g.Dispose();
            return dsImage;
        }

        private void AdjustSize(int spcWidth, int spcHeight, int orgWidth, int orgHeight, out int width, out int height)
        {
            if (orgWidth <= spcWidth && orgHeight <= spcHeight)
            {
                // 取得比例系数 
                float w = spcWidth / (float)orgWidth;
                float h = spcHeight / (float)orgHeight;
                if (w > h)
                {
                    height = spcHeight;
                    width = (int)(Math.Round(orgWidth * h));
                }
                else if (w < h)
                {
                    width = spcWidth;
                    height = (int)(Math.Round(orgHeight * w));
                }
                else
                {
                    width = spcWidth;
                    height = spcWidth;
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
                    width = spcWidth;
                    height = (int)(w >= 1 ? Math.Round(orgHeight / w) : Math.Round(orgHeight * w));
                }
                // 宽度比小于高度比 
                else if (w < h)
                {
                    height = spcHeight;
                    width = (int)(h >= 1 ? Math.Round(orgWidth / h) : Math.Round(orgWidth * h));
                }
                // 宽度比等于高度比 
                else
                {
                    width = spcWidth;
                    height = spcHeight;
                }
            }
        }
    }

    class TXLiteAVVideoViewManager : ITRTCVideoRenderCallback
    {
        private volatile Dictionary<string, TXLiteAVVideoView> mMapViews;

        public static TXLiteAVVideoViewManager sInstance;

        private static Object mLocker = new Object();

        public static TXLiteAVVideoViewManager GetInstance()
        {
            if (sInstance == null)
            {
                lock (mLocker)
                {
                    if (sInstance == null)
                        sInstance = new TXLiteAVVideoViewManager();
                }
            }
            return sInstance;
        }

        private TXLiteAVVideoViewManager()
        {
            mMapViews = new Dictionary<string, TXLiteAVVideoView>();
        }

        private string GetKey(string userId, TRTCVideoStreamType type)
        {
            return String.Format("{0}_{1}", userId, type);
        }

        // 主要用于判断当前 user 是否还有存在流画面，存在则不移除监听。
        public bool HasUserId(string userId)
        {
            bool exit = false;
            lock (mMapViews)
            {
                exit = mMapViews.ContainsKey(GetKey(userId, TRTCVideoStreamType.TRTCVideoStreamTypeBig)) ||
                    mMapViews.ContainsKey(GetKey(userId, TRTCVideoStreamType.TRTCVideoStreamTypeSub));
            }
            return exit;
        }

        public void AddView(string userId, TRTCVideoStreamType type, TXLiteAVVideoView view)
        {
            lock (mMapViews)
            {
                bool find = false;
                foreach (var item in mMapViews)
                {
                    if (item.Key.Equals(GetKey(userId, type)))
                    {
                        find = true;
                        break;
                    }
                }
                if (!find)
                {
                    mMapViews.Add(GetKey(userId, type), view);
                }
            }
        }

        public void RemoveView(string userId, TRTCVideoStreamType type, TXLiteAVVideoView view)
        {
            lock (mMapViews)
            {
                foreach (var item in mMapViews.ToList())
                {
                    if (item.Key.Equals(GetKey(userId, type)))
                    {
                        if (item.Value != null)
                        {
                            item.Value.Dispose();
                        }
                        mMapViews.Remove(item.Key);
                        break;
                    }
                }
            }
        }

        public void RemoveAllView()
        {
            lock (mMapViews)
                mMapViews.Clear();
        }

        public int Count
        {
            get
            {
                lock (mMapViews)
                    return mMapViews.Count;
            }
        }

        public void onRenderVideoFrame(string userId, TRTCVideoStreamType streamType, TRTCVideoFrame frame)
        {
            // 大小视频是占一个视频位，底层支持动态切换。
            if (streamType == TRTCVideoStreamType.TRTCVideoStreamTypeSmall)
                streamType = TRTCVideoStreamType.TRTCVideoStreamTypeBig;
            TXLiteAVVideoView view = null;
            lock (mMapViews)
            {
                foreach (var item in mMapViews)
                {
                    if (item.Key.Equals(GetKey(userId, streamType)) && item.Value != null)
                    {
                        view = item.Value;
                        break;
                    }
                }
            }

            if (view != null)
            {
                view.AppendVideoFrame(frame.data, (int)frame.width, (int)frame.height, frame.videoFormat, frame.rotation);
            }
        }
    }

    class FrameBufferInfo
    {
        public byte[] data { get; set; }

        public int width { get; set; }

        public int height { get; set; }

        public bool newFrame { get; set; }

        public TRTCVideoRotation rotation { get; set; }

        public FrameBufferInfo()
        {
            rotation = TRTCVideoRotation.TRTCVideoRotation0;
            newFrame = false;
            width = 0;
            height = 0;
            data = null;
        }
    }
}
