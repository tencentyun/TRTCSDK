package com.tencent.trtc.customcamera.helper;

import android.graphics.SurfaceTexture;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
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

import androidx.annotation.RequiresApi;

import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.customcamera.helper.basic.Size;
import com.tencent.trtc.customcamera.helper.render.EglCore;
import com.tencent.trtc.customcamera.helper.render.opengl.GPUImageFilter;
import com.tencent.trtc.customcamera.helper.render.opengl.GpuImageI420Filter;
import com.tencent.trtc.customcamera.helper.render.opengl.OpenGlUtils;
import com.tencent.trtc.customcamera.helper.render.opengl.Rotation;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.util.concurrent.CountDownLatch;

/**
 * 本地媒体文件直播分享的自定义渲染辅助类，可以帮助开发者快速实现TRTC 自定义渲染的相关功能
 * 主要包含：
 * - 本地预览视频帧/远端用户视频帧的自定义渲染；
 * - 本地音频/远端音频混音后的播放；
 *
 * ## 视频帧渲染流程
 * 视频帧渲染采用了 texture，也就是 openGL 纹理的方案，这是 android 系统下性能最好的一种视频处理方案，具体流程如下：
 *
 *  1. 构造函数：会创建一个{@link HandlerThread}线程，所有的OpenGL操作均在该线程进行。
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
 *
 *  ## 音频帧播放流程
 *  音频帧的播放采用了AudioTrack的方式，整体流程比较简单：
 *  1. onMixedAllAudioFrame(): SDK 所有音频数据混合后的数据回调（包括采集音频数据和所有播放音频数据）
 *     在这个回调中，可以拿到音频帧的data信息，使用AudioTrack播放即可；
 *
 */
@RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR1)
public class CustomFrameRender implements TRTCCloudListener.TRTCVideoRenderListener, TRTCCloudListener.TRTCAudioFrameListener, Handler.Callback {
    public static final String TAG = "TestRenderVideoFrame";

    private static final int MSG_RENDER              = 2;
    private static final int MSG_DESTROY             = 3;
    private static final int RENDER_TYPE_TEXTURE     = 0;
    private static final int RENDER_TYPE_I420        = 1;

    private       int                mRenderType     = RENDER_TYPE_TEXTURE;
    private       int                mSteamType;
    private       String             mUserId;
    private       Size               mSurfaceSize    = new Size();
    private       Size               mLastInputSize  = new Size();
    private       Size               mLastOutputSize = new Size();
    private final HandlerThread      mGLThread;
    private final GLHandler          mGLHandler;
    private final FloatBuffer        mGLCubeBuffer;
    private final FloatBuffer        mGLTextureBuffer;
    private       EglCore            mEglCore;
    private       SurfaceTexture     mSurfaceTexture;
    private       TextureView        mRenderView;
    private       GPUImageFilter     mNormalFilter;
    private       GpuImageI420Filter mYUVFilter;
    private       AudioTrack         mAudioTrack;

    @Override
    public void onRenderVideoFrame(String userId, int streamType, final TRTCCloudDef.TRTCVideoFrame frame) {
        if (!userId.equals(mUserId) || mSteamType != streamType) {
            return;
        }
        if (frame.texture != null) {
            GLES20.glFinish();
        }
        mGLHandler.obtainMessage(MSG_RENDER, frame).sendToTarget();
    }

    @Override
    public void onCapturedRawAudioFrame(TRTCCloudDef.TRTCAudioFrame audioFrame) {

    }

    @Override
    public void onLocalProcessedAudioFrame(TRTCCloudDef.TRTCAudioFrame audioFrame) {

    }

    @Override
    public void onRemoteUserAudioFrame(TRTCCloudDef.TRTCAudioFrame audioFrame, String s) {

    }

    @Override
    public void onMixedPlayAudioFrame(TRTCCloudDef.TRTCAudioFrame audioFrame) {

    }

    @Override
    public void onMixedAllAudioFrame(TRTCCloudDef.TRTCAudioFrame audioFrame) {
        if (audioFrame == null) {
            return;
        }
        if (mAudioTrack == null) {
            int channelConfig;
            if (audioFrame.channel == 1) {
                channelConfig = AudioFormat.CHANNEL_OUT_MONO;
            } else if (audioFrame.channel == 2) {
                channelConfig = AudioFormat.CHANNEL_OUT_STEREO;
            } else {
                Log.e(TAG, "audioFrame channel [" + audioFrame.channel + "] is error !");
                return;
            }
            mAudioTrack = new AudioTrack(AudioManager.STREAM_MUSIC,
                    audioFrame.sampleRate, channelConfig, AudioFormat.ENCODING_PCM_16BIT,
                    AudioTrack.getMinBufferSize(audioFrame.sampleRate, channelConfig, AudioFormat.ENCODING_PCM_16BIT), AudioTrack.MODE_STREAM);
            mAudioTrack.play();
        }
        mAudioTrack.write(audioFrame.data, 0, audioFrame.data.length);
    }

    public CustomFrameRender(String userId, int steamType) {
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
        if (mAudioTrack != null) {
            mAudioTrack.stop();
            mAudioTrack.release();
            mAudioTrack = null;
        }
        mGLHandler.obtainMessage(MSG_DESTROY).sendToTarget();
    }

    private void initGlComponent(Object eglContext) {
        if (mSurfaceTexture == null) {
            return;
        }

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
