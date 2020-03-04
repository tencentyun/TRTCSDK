package com.tencent.liteav.demo.trtc.customcapture;

/***********************************************************************************************************************
 *
 *                 测试自定义渲染功能 TestRenderVideoFrame
 *
 *  该示例代码通过 openGL 将 SDK 回调出来的视频帧渲染到系统的 TextureView 上。
 *
 *  本示例代码中采用了 texture，也就是 openGL 纹理的方案，这是 android 系统下性能最好的一种视频处理方案。
 *
 *  1. 构造函数：会创建一个{@link android.os.HandlerThread}线程，所有的OpenGL操作均在该线程进行。
 *
 *  2. start()：传入一个系统TextureView（这个 View 需要加到 activity 的控件树上），用来显示渲染的结果。
 *
 *  3. onSurfaceTextureAvailable(): TextureView 的 SurfaceTexture 已经准备好，将SurfaceTexture与
 *     {@link com.tencent.trtc.TRTCCloudDef.TRTCVideoFrame#texture}中的EGLContext（可为null）作为参数，
 *     生成一个新的EGLContext，SurfaceTexture也会作为此EGLContext的渲染目标。
 *
 *  4. onRenderVideoFrame(): SDK 视频帧回调，在回调中可以拿到视频纹理ID和对应的 EGLContext。
 *     用这个 EGLContext 作为参数创建出来的新的 EGLContext，这样新的 EGLContext 就能访问SDK返回的纹理。
 *     然后会向HandlerThread发送一个渲染消息，用来渲染得到的视频纹理。
 *
 *  5. renderInternal(): HandlerThread线程具体的渲染流程，将视频纹理渲染到 TextureView。
 *************************************************************************************************************************/

import android.annotation.TargetApi;
import android.graphics.SurfaceTexture;
import android.opengl.GLES20;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.util.Pair;
import android.view.Surface;
import android.view.TextureView;
import android.widget.ImageView.ScaleType;

import com.tencent.liteav.demo.trtc.customcapture.opengl.GPUImageFilter;
import com.tencent.liteav.demo.trtc.customcapture.opengl.GpuImageI420Filter;
import com.tencent.liteav.demo.trtc.customcapture.opengl.OpenGlUtils;
import com.tencent.liteav.demo.trtc.customcapture.opengl.Rotation;
import com.tencent.liteav.demo.trtc.customcapture.render.EglCore;
import com.tencent.liteav.demo.trtc.customcapture.utils.Size;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.util.concurrent.CountDownLatch;

@TargetApi(17)
public class TestRenderVideoFrame implements TRTCCloudListener.TRTCVideoRenderListener, Handler.Callback {
    public static final String TAG = "TestRenderVideoFrame";

    private static final int MSG_RENDER = 2;
    private static final int MSG_DESTROY = 3;

    private static final int RENDER_TYPE_TEXTURE = 0;
    private static final int RENDER_TYPE_I420   = 1;

    private final HandlerThread mGLThread;
    private final GLHandler mGLHandler;
    private TextureView mRenderView;

    private int mRenderType = RENDER_TYPE_TEXTURE;

    private EglCore mEglCore;
    private SurfaceTexture mSurfaceTexture;
    private Size mSurfaceSize = new Size();
    private Size mLastInputSize = new Size();
    private Size mLastOutputSize = new Size();

    private final FloatBuffer mGLCubeBuffer;
    private final FloatBuffer mGLTextureBuffer;
    private GPUImageFilter mNormalFilter;
    private GpuImageI420Filter mYUVFilter;
    private String mUserId;
    private int mSteamType;

    public TestRenderVideoFrame(String userId, int steamType) {
        mUserId = userId;
        mSteamType = steamType;
        mGLCubeBuffer = ByteBuffer.allocateDirect(OpenGlUtils.CUBE.length * 4)
                .order(ByteOrder.nativeOrder()).asFloatBuffer();
        mGLCubeBuffer.put(OpenGlUtils.CUBE).position(0);

        mGLTextureBuffer = ByteBuffer.allocateDirect(OpenGlUtils.TEXTURE.length * 4)
                .order(ByteOrder.nativeOrder()).asFloatBuffer();
        mGLTextureBuffer.put(OpenGlUtils.TEXTURE).position(0);

        mGLThread = new HandlerThread(TAG);
        mGLThread.start();
        mGLHandler = new GLHandler(mGLThread.getLooper(), this);
        Log.i(TAG, "TestRenderVideoFrame");
    }

    public void start(TextureView videoView) {
        if (videoView == null) {
            Log.w(TAG, "start error when render view is null");
            return;
        }
        Log.i(TAG, "start render");

        // 设置TextureView的SurfaceTexture生命周期回调，用于管理GLThread的创建和销毁
        mRenderView = videoView;
        mSurfaceTexture = mRenderView.getSurfaceTexture();

        mRenderView.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {
            @Override
            public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
                // 保存surfaceTexture，用于创建OpenGL线程
                mSurfaceTexture = surface;
                mSurfaceSize = new Size(width, height);
                Log.i(TAG, String.format("onSurfaceTextureAvailable width: %d, height: %d", width, height));
            }

            @Override
            public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
                mSurfaceSize = new Size(width, height);
                Log.i(TAG, String.format("onSurfaceTextureSizeChanged width: %d, height: %d", width, height));
            }

            @Override
            public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
                // surface释放了，需要停止渲染
                mSurfaceTexture = null;
                // 等待Runnable执行完，再返回，否则GL线程会使用一个无效的SurfaceTexture
                mGLHandler.runAndWaitDone(new Runnable() {
                    @Override
                    public void run() {
                        uninitGlComponent();
                    }
                });
                return false;
            }

            @Override
            public void onSurfaceTextureUpdated(SurfaceTexture surface) {
            }
        });
    }

    public void stop() {
        if (mRenderView != null) {
            mRenderView.setSurfaceTextureListener(null);
        }
        mGLHandler.obtainMessage(MSG_DESTROY).sendToTarget();
    }

    /**
     * 当视频帧准备送入编码器时，SDK会触发该回调，将视频帧抛出来，这里主要处理TRTC_VIDEO_BUFFER_TYPE_TEXTURE
     */
    @Override
    public void onRenderVideoFrame(String userId, int streamType, final TRTCCloudDef.TRTCVideoFrame frame) {
        if (!userId.equals(mUserId) || mSteamType != streamType) {
            // 如果渲染回调的id或者steamtype对不上
            return;
        }
        if (frame.texture != null) {
            // 等待frame.texture的纹理绘制完成
            GLES20.glFinish();
        }
        mGLHandler.obtainMessage(MSG_RENDER, frame).sendToTarget();
    }

    private void initGlComponent(Object eglContext) {
        if (mSurfaceTexture == null) {
            return;
        }

        // 创建的时候，增加判断，防止这边创建的时候，传入的EGLContext已经被销毁了。
        try {
            if (eglContext instanceof javax.microedition.khronos.egl.EGLContext) {
                mEglCore = new EglCore((javax.microedition.khronos.egl.EGLContext) eglContext, new Surface(mSurfaceTexture));
            } else {
                mEglCore = new EglCore((android.opengl.EGLContext) eglContext, new Surface(mSurfaceTexture));
            }
        } catch (Exception e) {
            Log.e(TAG, "create EglCore failed.", e);
            return;
        }

        mEglCore.makeCurrent();
        if (mRenderType == RENDER_TYPE_TEXTURE) {
            mNormalFilter = new GPUImageFilter();
            mNormalFilter.init();
        } else if (mRenderType == RENDER_TYPE_I420) {
            mYUVFilter = new GpuImageI420Filter();
            mYUVFilter.init();
        }
    }

    private void renderInternal(TRTCCloudDef.TRTCVideoFrame frame) {
        mRenderType = RENDER_TYPE_I420;
        if (frame.bufferType == TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE) {
            mRenderType = RENDER_TYPE_TEXTURE;
        } else if (frame.pixelFormat == TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_I420
                && frame.bufferType == TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_BYTE_ARRAY) {
            mRenderType = RENDER_TYPE_I420;
        } else {
            Log.w(TAG, "error video frame type");
            return;
        }

        if (mEglCore == null && mSurfaceTexture != null) {
            Object eglContext = null;
            if (frame.texture != null) {
                eglContext = frame.texture.eglContext10 != null ? frame.texture.eglContext10 : frame.texture.eglContext14;
            }
            initGlComponent(eglContext);
        }

        if (mEglCore == null) {
            return;
        }

        if (mLastInputSize.width != frame.width || mLastInputSize.height != frame.height
            || mLastOutputSize.width != mSurfaceSize.width || mLastOutputSize.height != mSurfaceSize.height) {
            Pair<float[], float[]> cubeAndTextureBuffer = OpenGlUtils.calcCubeAndTextureBuffer(ScaleType.CENTER,
                    Rotation.ROTATION_180, true, frame.width, frame.height, mSurfaceSize.width, mSurfaceSize.height);
            mGLCubeBuffer.clear();
            mGLCubeBuffer.put(cubeAndTextureBuffer.first);
            mGLTextureBuffer.clear();
            mGLTextureBuffer.put(cubeAndTextureBuffer.second);

            mLastInputSize = new Size(frame.width, frame.height);
            mLastOutputSize = new Size(mSurfaceSize.width, mSurfaceSize.height);
        }

        mEglCore.makeCurrent();
        GLES20.glViewport(0, 0, mSurfaceSize.width, mSurfaceSize.height);
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);

        GLES20.glClearColor(0, 0, 0, 1.0f);
        GLES20.glClear(GLES20.GL_DEPTH_BUFFER_BIT | GLES20.GL_COLOR_BUFFER_BIT);
        if (mRenderType == RENDER_TYPE_TEXTURE) {
            mNormalFilter.onDraw(frame.texture.textureId, mGLCubeBuffer, mGLTextureBuffer);
        } else {
            mYUVFilter.loadYuvDataToTexture(frame.data, frame.width, frame.height);
            mYUVFilter.onDraw(OpenGlUtils.NO_TEXTURE, mGLCubeBuffer, mGLTextureBuffer);
        }
        mEglCore.swapBuffer();
    }

    private void uninitGlComponent() {
        if (mNormalFilter != null) {
            mNormalFilter.destroy();
            mNormalFilter = null;
        }
        if (mYUVFilter != null) {
            mYUVFilter.destroy();
            mYUVFilter = null;
        }
        if (mEglCore != null) {
            mEglCore.unmakeCurrent();
            mEglCore.destroy();
            mEglCore = null;
        }
    }

    private void destroyInternal() {
        uninitGlComponent();

        if (Build.VERSION.SDK_INT >= 18) {
            mGLHandler.getLooper().quitSafely();
        } else {
            mGLHandler.getLooper().quit();
        }
    }

    @Override
    public boolean handleMessage(Message msg) {
        switch (msg.what) {
        case MSG_RENDER:
            renderInternal((TRTCCloudDef.TRTCVideoFrame) msg.obj);
            break;
        case MSG_DESTROY:
            destroyInternal();
            break;
        }
        return false;
    }

    public static class GLHandler extends Handler {
        public GLHandler(Looper looper, Callback callback) {
            super(looper, callback);
        }

        public void runAndWaitDone(final Runnable runnable) {
            final CountDownLatch countDownLatch = new CountDownLatch(1);
            post(new Runnable() {
                @Override
                public void run() {
                    runnable.run();
                    countDownLatch.countDown();
                }
            });

            try {
                countDownLatch.await();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}
