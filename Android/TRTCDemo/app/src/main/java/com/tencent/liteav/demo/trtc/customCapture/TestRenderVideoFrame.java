package com.tencent.liteav.demo.trtc.customCapture;

/***********************************************************************************************************************
 *
 *                 测试自定义渲染功能 TestRenderVideoFrame
 *
 *  该示例代码通过 openGL 将 SDK 回调出来的视频帧渲染到系统的 TextureView 上。
 *
 *  本示例代码中采用了 texture，也就是 openGL 纹理的方案，这是 android 系统下性能最好的一种视频处理方案。
 *
 *  1. start()：传入一个系统TextureView（这个 View 需要加到 activity 的控件树上），并启动一个 GLThread 线程，用来将视频纹理渲染到 TextureView。
 *
 *  2. onSurfaceTextureAvailable(): TextureView 的 SurfaceTexture 已经准备好，可以用来生成 GLThread 的 EGLSurface ，
 *      这样在 openGL 线程做的渲染就可以在 TextureView 上显示出来
 *
 *  3. onRenderVideoFrame(): SDK 视频帧回调，在回调中可以拿到视频纹理ID和对应的 EGLContext。
 *      用这个 EGLContext 作为共享纹理来创建 GLThread ，这样 GLThread 就能访问SDK返回的纹理。
 *      触发 GLThread 线程的一个异步任务，用来渲染得到的视频纹理。
 *
 *  4. onTextureProcess(): GLThread 线程的回调，在回调中将视频纹理渲染到 TextureView。
 *************************************************************************************************************************/

import android.content.Context;
import android.graphics.SurfaceTexture;

import android.opengl.EGLContext;
import android.opengl.GLES20;
import android.os.HandlerThread;
import android.util.Log;
import android.view.Surface;
import android.view.TextureView;

import com.tencent.liteav.demo.trtc.customCapture.openGLBaseModule.GLI420RenderFilter;
import com.tencent.liteav.demo.trtc.customCapture.openGLBaseModule.GLTexture2DFilter;
import com.tencent.liteav.demo.trtc.customCapture.openGLBaseModule.GLThread;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import java.nio.ByteBuffer;

public class TestRenderVideoFrame implements TRTCCloudListener.TRTCVideoRenderListener, GLThread.IEGLListener {

    public static final String TAG = "TestRenderVideoFrame";
    private static final int RENDER_TYPE_TEXTURE = 0;
    private static final int RENDER_TYPE_I420   = 1;

    private GLThread.GLThreadHandler mGLHandler;
    private HandlerThread mGLThread;
    private TextureView mRenderView;

    private int mVideoWidth;
    private int mVideoHeight;
    private int mRenderType = RENDER_TYPE_TEXTURE;

    private SurfaceTexture mSurfaceTexture;

    private int mTextureId = -1;
    private GLTexture2DFilter mTextureFilter;

    private ByteBuffer mYdata;
    private ByteBuffer mUVData;
    private GLI420RenderFilter mYUVFilter;

    public TestRenderVideoFrame(Context context) {

    }

    public void start(TextureView videoView) {
        if (videoView == null) {
            Log.w(TAG, "start error when render view is null");
            return;
        }

        //保存视频渲染view，在渲染时用来获取渲染画布尺寸
        mRenderView = videoView;

        //设置TextureView的SurfaceTexture生命周期回调，用于管理GLThread的创建和销毁
        mRenderView.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {
            @Override
            public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
                //保存surfaceTexture，用于创建OpenGL线程
                mSurfaceTexture = surface;
            }

            @Override
            public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {

            }

            @Override
            public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
                //surface释放了，需要停止渲染
                mSurfaceTexture = null;
                destroyGLThread();
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

        destroyGLThread();
    }

    /**
     * 当视频帧准备送入编码器时，SDK会触发该回调，将视频帧抛出来，这里主要处理TRTC_VIDEO_BUFFER_TYPE_TEXTURE
     */
    @Override
    public void onRenderVideoFrame(String userId, int streamType, final TRTCCloudDef.TRTCVideoFrame frame) {
        if (frame.bufferType == TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE) {
            mVideoWidth = frame.width;
            mVideoHeight = frame.height;
            renderTexture(frame.texture);
        } else if (frame.pixelFormat == TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_I420 && frame.bufferType == TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_BYTE_ARRAY) {
            mVideoWidth = frame.width;
            mVideoHeight = frame.height;
            renderI420(frame.data, frame.width, frame.height);
        } else {
            Log.w(TAG, "error video frame type");
        }
    }

    @Override
    public void onEGLCreate() {
        initGL();
    }

    /**
     * 当SDK抛出一个视频帧时，GLThread会触发一次这个回调
     * 在回调中我们可以将视频帧渲染到TextureView的SurfaceTexture上
     */
    @Override
    public void onTextureProcess(EGLContext eglContext) {
        if (mRenderView != null) {
            if (mTextureId != -1) {
                if (mTextureFilter != null) {
                    mTextureFilter.draw(mTextureId, mVideoWidth, mVideoHeight, mRenderView.getWidth(), mRenderView.getHeight());
                }
                mGLHandler.swap();
                mTextureId = -1;
            } else if (mUVData != null && mYdata != null) {
                ByteBuffer yData = null;
                ByteBuffer uvData = null;
                synchronized (this) {
                    yData = mYdata;
                    uvData = mUVData;
                    mYdata = null;
                    mUVData = null;
                }
                if (mYUVFilter != null && yData != null && uvData != null) {
                    mYUVFilter.drawFrame(yData, uvData, mVideoWidth, mVideoHeight, mRenderView.getWidth(), mRenderView.getHeight());
                    mGLHandler.swap();
                }

            }

        }
    }

    @Override
    public void onEGLDestroy() {
        unInitGL();
    }

    /**
     * 在OpenGL线程中将每一帧视频纹理渲染到TextureView对应的SurfaceTexture上
     *
     */
    private void renderTexture(TRTCCloudDef.TRTCTexture textureFrame) {
        if (textureFrame == null) return;

        if (mGLHandler == null) {
            mRenderType = RENDER_TYPE_TEXTURE;
            //OpenGL渲染线程共享SDK的eglContext
            createGLThread(textureFrame.eglContext14);
        }
        mTextureId = textureFrame.textureId;
        GLES20.glFinish();
        sendMsg(GLThread.GLThreadHandler.MSG_REND);
    }

    private void renderI420(byte[] yuvData, int width, int height) {
        if (yuvData == null) return;
        if (mGLHandler == null) {
            mRenderType = RENDER_TYPE_I420;
            //OpenGL渲染线程
            createGLThread(null);
        }
        synchronized (this) {
            mYdata = ByteBuffer.wrap(yuvData, 0, width*height);
            mUVData = ByteBuffer.allocate(width*height/2);
            mUVData.put(yuvData, width*height, width*height/2);
            mUVData.position(0);
        }

        sendMsg(GLThread.GLThreadHandler.MSG_REND);
    }
    /**
     * 创建OpenGL线程，绑定TextureView的SurfaceTexture和SDK 的EGLContext
     *
     */
    private void createGLThread(EGLContext eglContext) {
        if (mSurfaceTexture == null) return;

        destroyGLThread();

        synchronized (this) {
            mGLThread = new HandlerThread(TAG);
            mGLThread.start();
            mGLHandler = new GLThread.GLThreadHandler(mGLThread.getLooper());
            mGLHandler.mSurface = new Surface(mSurfaceTexture);
            mGLHandler.mEgl14Context = eglContext;
            mGLHandler.setListener(this);

            Log.w(TAG,"surface-render: create gl thread " +mGLThread.getName());
        }

        sendMsg(GLThread.GLThreadHandler.MSG_INIT);
    }

    private void destroyGLThread() {
        synchronized (this) {
            if(mGLHandler != null) {
                GLThread.GLThreadHandler.quitGLThread(mGLHandler, mGLThread);
                Log.w(TAG,"surface-render: destroy gl thread");
            }

            mGLHandler  = null;
            mGLThread   = null;
        }
    }

    private void sendMsg(int what) {
        synchronized (this) {
            if (mGLHandler != null) {
                mGLHandler.sendEmptyMessage(what);
            }
        }
    }

    private void initGL() {
        if (mRenderType == RENDER_TYPE_TEXTURE) {
            mTextureFilter = new GLTexture2DFilter();
        } else if (mRenderType == RENDER_TYPE_I420) {
            mYUVFilter = new GLI420RenderFilter();
        }
    }

    private void unInitGL() {
        if (mTextureFilter != null) {
            mTextureFilter.release();
            mTextureFilter = null;
        }
        if (mYUVFilter != null) {
            mYUVFilter.release();
            mYUVFilter = null;
        }
    }

}
