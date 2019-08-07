package com.tencent.liteav.demo.trtc.customCapture.openGLBaseModule;

import android.annotation.TargetApi;
import android.graphics.SurfaceTexture;
import android.opengl.EGL14;
import android.opengl.EGLContext;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.view.Surface;
import com.tencent.liteav.basic.log.TXCLog;


/**
 * <p>
 * EGL线程，提供SurfaceTexture给外部
 */
public class GLThread {
    final static private String TAG = "GLThread";
    private volatile HandlerThread      mGLThread   = null;
    private volatile GLThreadHandler    mGLHandler  = null;

    private GLTextureOESFilter mGLFilter;
    private float[]  mSTMatrix;
    private int []          mTextureID         = null;
    private SurfaceTexture  mSurfaceTexture    = null;
    private IGLSurfaceTextureListener mListener;

    public interface IGLSurfaceTextureListener {
        /**
         * SurfaceTexture可用
         *
         * @param surfaceTexture 可用的SurfaceTexture
         */
        void onSurfaceTextureAvailable(SurfaceTexture surfaceTexture);

        int  onTextureProcess(int textureId, EGLContext eglContext);

        /**
         * SurfaceTexture销毁
         *
         * @param surfaceTexture 可用的SurfaceTexture
         */
        void onSurfaceTextureDestroy(SurfaceTexture surfaceTexture);
    }

    public interface IEGLListener {
        void onEGLCreate();

        void onTextureProcess(EGLContext eglContext);

        void onEGLDestroy();
    }

    public GLThread() {
    }

    public void start() {
        TXCLog.i(TAG, "surface-render: surface render start ");
        initGLThread();
    }

    public void stop() {
        TXCLog.i(TAG, "surface-render: surface render stop ");
        unintGLThread();
    }

    public void setListener(IGLSurfaceTextureListener listener) {
        mListener = listener;
    }

    public Surface getSurface() {
        synchronized (this) {
            return mGLHandler != null ? mGLHandler.getSurface() : null;
        }
    }

    private int mInputWidth;
    private int mInputHeight;
    public void setInputSize(int width, int height) {
        mInputWidth = width;
        mInputHeight = height;
    }

    public void post(Runnable task){
        synchronized (this) {
            if(mGLHandler != null) mGLHandler.post(task);
        }
    }

    //////////////////////////////////////////////////////////////////////////////////////////////
    //                                                                                          //
    //                                    私有函数区域                                            //
    //////////////////////////////////////////////////////////////////////////////////////////////
    private void initGLThread() {
        unintGLThread();

        synchronized (this) {
            mGLThread = new HandlerThread(TAG);
            mGLThread.start();
            mGLHandler = new GLThreadHandler(mGLThread.getLooper());
            mGLHandler.setListener(new IEGLListener() {
                @Override
                public void onEGLCreate() {
                    initSurfaceTexture();

                    mGLFilter = new GLTextureOESFilter();
                    mGLFilter.setOutputResolution(mInputWidth, mInputHeight);
                }

                @Override
                public void onTextureProcess(EGLContext eglContext) {
                    if (mSurfaceTexture != null) {
                        mSurfaceTexture.updateTexImage();
                        mSurfaceTexture.getTransformMatrix(mSTMatrix);
                    }

                    if (mGLFilter != null) {
                        mGLFilter.setMatrix(mSTMatrix);
                        int textureId = mGLFilter.drawToTexture(mTextureID[0]);

                        IGLSurfaceTextureListener listener = mListener;
                        if (listener != null) {
                            listener.onTextureProcess(textureId, eglContext);
                        }
                    }
                }

                @Override
                public void onEGLDestroy() {
                    destroySurfaceTexture();
                    if (mGLFilter != null) {
                        mGLFilter.release();
                        mGLFilter = null;
                    }
                }
            });

            TXCLog.w(TAG,"surface-render: create gl thread " +mGLThread.getName());
        }

        sendMsg(GLThreadHandler.MSG_INIT);
    }

    private void unintGLThread() {
        synchronized (this) {
            if(mGLHandler != null) {
                GLThreadHandler.quitGLThread(mGLHandler, mGLThread);
                TXCLog.w(TAG,"surface-render: destroy gl thread");
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

    private void sendMsg(int what, Runnable completeTask) {
        synchronized (this) {
            if (mGLHandler != null) {
                Message msg = new Message();
                msg.what = what;
                msg.obj = completeTask;
                mGLHandler.sendMessage(msg);
            }
        }
    }

    private void destroySurfaceTexture() {
        TXCLog.w(TAG,"destroy surface texture ");
        IGLSurfaceTextureListener listener = mListener;
        if (listener != null) {
            listener.onSurfaceTextureDestroy(mSurfaceTexture);
        }
        if(mSurfaceTexture != null) {
            mSurfaceTexture.setOnFrameAvailableListener(null);
            mSurfaceTexture.release();
//            mbCaptureAvailable = false;
            mSurfaceTexture = null;
        }

        if(mTextureID != null) {
            GLES20.glDeleteTextures(1, mTextureID, 0);
            mTextureID = null;
        }
    }

    private int createOESTextureID(){
        int[] texture = new int[1];
        GLES20.glGenTextures(1, texture, 0);

        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, texture[0]);
        GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
        return texture[0];
    }

    private void initSurfaceTexture() {
        TXCLog.w(TAG,"init surface texture ");
        mSTMatrix = new float[16];
        mTextureID = new int[1];
        mTextureID[0] = createOESTextureID();

        mSurfaceTexture = new SurfaceTexture(mTextureID[0]);
        mSurfaceTexture.setDefaultBufferSize(1280, 720);
        mSurfaceTexture.setOnFrameAvailableListener(new SurfaceTexture.OnFrameAvailableListener() {
            @Override
            public void onFrameAvailable(SurfaceTexture surfaceTexture) {
                sendMsg(GLThreadHandler.MSG_RUN_TASK, new Runnable() {
                    @Override
                    public void run() {
                        sendMsg(GLThreadHandler.MSG_REND);
                    }
                });
            }
        });
        IGLSurfaceTextureListener listener = mListener;
        if (listener != null) {
            listener.onSurfaceTextureAvailable(mSurfaceTexture);
        }
    }

    public static class GLThreadHandler extends Handler {
        final static private String TAG             = "TXGLThreadHandler";

        public static final int MSG_INIT            = 100;
        public static final int MSG_END             = MSG_INIT + 1;
        public static final int MSG_REND            = MSG_END + 1;
        public static final int MSG_RUN_TASK        = MSG_REND + 1;

        public int              mCaptureWidth       = 720;
        public int              mCaptureHeight      = 1280;
        public Surface          mSurface            = null;
        public EGLContext       mEgl14Context       = null;
        private IEGLListener mListener           = null;

        private EglSurfaceBase mEglBase;


        public static void quitGLThread(Handler handler, HandlerThread thread) {
            final HandlerThread     glThread    = thread;
            final Handler           glHandler   = handler;
            if (glHandler == null || glThread == null) return;

            Message msg = new Message();
            msg.what = MSG_END;
            msg.obj = new Runnable() {
                @Override
                public void run() {
                    Handler mainHandler = new Handler(Looper.getMainLooper());
                    mainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            if (glHandler != null) {
                                glHandler.removeCallbacksAndMessages(null);
                            }

                            if (glThread != null) {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
                                    glThread.quitSafely();
                                } else {
                                    glThread.quit();
                                }
                            }
                        }
                    });
                }
            };
            glHandler.sendMessage(msg);
        }

        public GLThreadHandler(Looper looper) {
            super(looper);
        }

        public void setListener(IEGLListener listener) {
            mListener = listener;
        }

        public Surface  getSurface() {
            return mSurface;
        }

        public void swap() {
            if (mEglBase != null) {
                mEglBase.swapBuffers();
            }
        }

        public void handleMessage(Message msg) {
            if(msg == null) return;

            switch (msg.what) {
                case MSG_INIT:
                    onMsgInit(msg);
                    break;
                case MSG_REND:
                    try {
                        onMsgRend(msg);
                    }catch (Exception e) {

                    }
                    break;
                case MSG_END:
                    onMsgEnd(msg);
                    break;
                default:
                    break;
            }

            if(msg != null && msg.obj != null) {
                Runnable runTask = (Runnable)msg.obj;
                runTask.run();
            }
        }

        private void onMsgInit(Message msg) {
            try {
                initGL();
            } catch (Exception e) {
                TXCLog.e(TAG,"surface-render: init egl context exception " + mSurface);
                mSurface = null;
            }
        }

        private void onMsgEnd(Message msg) {
            destroyGL();
        }

        @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
        private void onMsgRend(Message msg) {
            try {
                if (mListener != null) {
                    mListener.onTextureProcess(EGL14.eglGetCurrentContext());
                }
            }catch (Exception e){
                TXCLog.e(TAG,"onMsgRend Exception "+e.getMessage());
                e.printStackTrace();
            }

        }

        private boolean initGL(){
            TXCLog.d(TAG, String.format("init egl size[%d/%d]",mCaptureWidth,mCaptureHeight));

            EglCore eglCore = new EglCore(mEgl14Context, 0);
            mEglBase = new EglSurfaceBase(eglCore);
            if (mSurface == null) {
                mEglBase.createOffscreenSurface(mCaptureWidth, mCaptureHeight);
            } else {
                mEglBase.createWindowSurface(mSurface);
            }
            mEglBase.makeCurrent();
            TXCLog.w(TAG,"surface-render: create egl context " + mSurface);
            if (mListener != null) {
                mListener.onEGLCreate();
            }
            return true;
        }


        private void destroyGL(){
            TXCLog.w(TAG,"surface-render: destroy egl context " + mSurface);

            if (mListener != null) {
                mListener.onEGLDestroy();
            }

            if(mEglBase != null) {
                mEglBase.releaseEglSurface();
                mEglBase = null;
            }
            mSurface = null;
        }
    }
}
