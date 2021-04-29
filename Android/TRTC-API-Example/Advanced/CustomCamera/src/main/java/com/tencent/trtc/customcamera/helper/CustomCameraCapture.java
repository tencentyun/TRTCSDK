package com.tencent.trtc.customcamera.helper;


import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import android.opengl.EGLContext;
import android.opengl.GLES20;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.util.Pair;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.tencent.trtc.customcamera.helper.basic.FrameBuffer;
import com.tencent.trtc.customcamera.helper.basic.TextureFrame;
import com.tencent.trtc.customcamera.helper.render.EglCore;
import com.tencent.trtc.customcamera.helper.render.opengl.GPUImageFilter;
import com.tencent.trtc.customcamera.helper.render.opengl.GPUImageFilterGroup;
import com.tencent.trtc.customcamera.helper.render.opengl.OesInputFilter;
import com.tencent.trtc.customcamera.helper.render.opengl.OpenGlUtils;
import com.tencent.trtc.customcamera.helper.render.opengl.Rotation;

import java.io.IOException;
import java.lang.ref.WeakReference;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

import static com.tencent.trtc.customcamera.helper.render.opengl.OpenGlUtils.NO_TEXTURE;

public class CustomCameraCapture implements SurfaceTexture.OnFrameAvailableListener {

    private static final String TAG = "CameraVideoFrameReader";

    private static final int        WIDTH       = 1280;
    private static final int        HEIGHT      = 720;
    private static final int        WHAT_START  = 0;
    private static final int        WHAT_UPDATE = 1;
    public static final int         VIDEO_FPS   = 15;

    private Camera                  mCamera;
    private SurfaceTexture          mSurfaceTexture;
    private EglCore                 mEglCore;
    private FrameBuffer             mFrameBuffer;
    private OesInputFilter          mOesInputFilter;
    private GPUImageFilterGroup     mGpuImageFilterGroup;

    private final FloatBuffer       mGLCubeBuffer;
    private final FloatBuffer       mGLTextureBuffer;
    private final float[]           mTextureTransform = new float[16]; // OES纹理转换为2D纹理
    private int                     mSurfaceTextureId = NO_TEXTURE;
    private boolean                 mFrameUpdated;
    private VideoFrameReadListener  mVideoFrameReadListener;
    private HandlerThread           mRenderHandlerThread;
    private volatile RenderHandler  mRenderHandler;


    public interface VideoFrameReadListener{
        void onFrameAvailable(EGLContext eglContext, int textureId, int width, int height);
    }

    public CustomCameraCapture() {
        mFrameUpdated = false;

        Pair<float[], float[]> cubeAndTextureBuffer = OpenGlUtils.calcCubeAndTextureBuffer(ImageView.ScaleType.CENTER, Rotation.NORMAL, false, WIDTH, HEIGHT, WIDTH, HEIGHT);

        mGLCubeBuffer = ByteBuffer.allocateDirect(OpenGlUtils.CUBE.length * 4).order(ByteOrder.nativeOrder()).asFloatBuffer();
        mGLCubeBuffer.put(cubeAndTextureBuffer.first);
        mGLTextureBuffer = ByteBuffer.allocateDirect(OpenGlUtils.TEXTURE.length * 4).order(ByteOrder.nativeOrder()).asFloatBuffer();
        mGLTextureBuffer.put(cubeAndTextureBuffer.second);
    }


    @Override
    public void onFrameAvailable(SurfaceTexture surfaceTexture) {
        mFrameUpdated = true;
        mRenderHandler.sendEmptyMessage(WHAT_UPDATE);
    }

    public void startInternal(final VideoFrameReadListener videoFrameReadListener) {
        mVideoFrameReadListener = videoFrameReadListener;
        mRenderHandlerThread = new HandlerThread("RenderHandlerThread");
        mRenderHandlerThread.start();
        mRenderHandler = new RenderHandler(mRenderHandlerThread.getLooper(), this);
        mRenderHandler.sendEmptyMessage(WHAT_START);
    }

    public void stop() {
        if (mRenderHandlerThread != null) {
            mRenderHandlerThread.quit();
        }

        if (mCamera != null) {
            mCamera.stopPreview();
        }
        if(mGpuImageFilterGroup != null){
            mGpuImageFilterGroup.destroy();
            mGpuImageFilterGroup = null;
        }

        if(mFrameBuffer != null){
            mFrameBuffer.uninitialize();
            mFrameBuffer = null;
        }

        if(mSurfaceTextureId != NO_TEXTURE){
            OpenGlUtils.deleteTexture(mSurfaceTextureId);
            mSurfaceTextureId = NO_TEXTURE;
        }

        if (mSurfaceTexture != null) {
            mSurfaceTexture.release();
            mSurfaceTexture = null;
        }

        if(mEglCore != null){
            mEglCore.unmakeCurrent();
            mEglCore.destroy();
            mEglCore = null;
        }
    }

    private void startInternal() {
        mEglCore = new EglCore(WIDTH, HEIGHT);
        mEglCore.makeCurrent();

        mSurfaceTextureId = OpenGlUtils.generateTextureOES();
        mSurfaceTexture = new SurfaceTexture(mSurfaceTextureId);

        mFrameBuffer = new FrameBuffer(WIDTH, HEIGHT);
        mFrameBuffer.initialize();

        mGpuImageFilterGroup = new GPUImageFilterGroup();
        mOesInputFilter = new OesInputFilter();
        mGpuImageFilterGroup.addFilter(mOesInputFilter);
        mGpuImageFilterGroup.addFilter(new GPUImageFilter(true));
        mGpuImageFilterGroup.init();
        mGpuImageFilterGroup.onOutputSizeChanged(WIDTH, HEIGHT);

        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                try {
                    mSurfaceTextureId = OpenGlUtils.generateTextureOES();
                    mSurfaceTexture = new SurfaceTexture(mSurfaceTextureId);
                    mSurfaceTexture.setOnFrameAvailableListener(CustomCameraCapture.this);
                    mCamera = Camera.open(Camera.CameraInfo.CAMERA_FACING_FRONT);
                    mCamera.setPreviewTexture(mSurfaceTexture);
                    mCamera.setDisplayOrientation(90);
                    Camera.Parameters parameters = mCamera.getParameters();
                    parameters.setPreviewSize(WIDTH, HEIGHT);
                    parameters.setPreviewFrameRate(VIDEO_FPS);
                    mCamera.setParameters(parameters);
                    mCamera.startPreview();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR1)
    private void updateTexture() {
        synchronized (this) {
            if (mFrameUpdated) {
                mFrameUpdated = false;
            }
            try {
                if (mSurfaceTexture != null) {

                    mSurfaceTexture.updateTexImage();
                    mSurfaceTexture.getTransformMatrix(mTextureTransform);
                    mOesInputFilter.setTexutreTransform(mTextureTransform);
                    mGpuImageFilterGroup.draw(mSurfaceTextureId, mFrameBuffer.getFrameBufferId(), mGLCubeBuffer, mGLTextureBuffer);

                    GLES20.glFinish();

                    if (mVideoFrameReadListener != null) {
                        TextureFrame textureFrame = new TextureFrame();
                        textureFrame.eglContext = (EGLContext) mEglCore.getEglContext();
                        textureFrame.textureId = mFrameBuffer.getTextureId();
                        textureFrame.width = HEIGHT;
                        textureFrame.height = WIDTH;
                        mVideoFrameReadListener.onFrameAvailable(textureFrame.eglContext, textureFrame.textureId, textureFrame.width, textureFrame.height);
                    }
                }
            } catch (Exception e) {
                Log.e(TAG, "onFrameAvailable: " + e.getMessage(), e);
            }
        }
    }

    private static class RenderHandler extends Handler {

        private final WeakReference<CustomCameraCapture> readerWeakReference;

        public RenderHandler(@NonNull Looper looper, CustomCameraCapture cameraVideoFrameReader) {
            super(looper);
            readerWeakReference = new WeakReference<>(cameraVideoFrameReader);
        }

        @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR1)
        @Override
        public void handleMessage(@NonNull Message msg) {
            super.handleMessage(msg);
            CustomCameraCapture cameraVideoFrameReader = readerWeakReference.get();
            if (cameraVideoFrameReader != null) {
                if (WHAT_START == msg.what) {
                    cameraVideoFrameReader.startInternal();
                } else if (WHAT_UPDATE == msg.what) {
                    cameraVideoFrameReader.updateTexture();
                }
            }
        }
    }
}
