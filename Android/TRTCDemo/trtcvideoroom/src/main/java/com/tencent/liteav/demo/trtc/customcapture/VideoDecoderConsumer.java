package com.tencent.liteav.demo.trtc.customcapture;

import android.annotation.TargetApi;
import android.graphics.SurfaceTexture;
import android.opengl.EGLContext;
import android.opengl.GLES20;

import com.tencent.liteav.demo.trtc.customcapture.exceptions.ProcessException;
import com.tencent.liteav.demo.trtc.customcapture.opengl.GPUImageFilter;
import com.tencent.liteav.demo.trtc.customcapture.opengl.GPUImageFilterGroup;
import com.tencent.liteav.demo.trtc.customcapture.opengl.OesInputFilter;
import com.tencent.liteav.demo.trtc.customcapture.opengl.OpenGlUtils;
import com.tencent.liteav.demo.trtc.customcapture.pipeline.ProvidedStage;
import com.tencent.liteav.demo.trtc.customcapture.pipeline.Provider;
import com.tencent.liteav.demo.trtc.customcapture.render.EglCore;
import com.tencent.liteav.demo.trtc.customcapture.structs.Frame;
import com.tencent.liteav.demo.trtc.customcapture.structs.FrameBuffer;
import com.tencent.liteav.demo.trtc.customcapture.structs.TextureFrame;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.util.List;

import static com.tencent.liteav.demo.trtc.customcapture.opengl.OpenGlUtils.NO_TEXTURE;

/**
 * 将解码出来的内容绘制到自己的FrameBuffer上，然后作为输出给到下一个节点
 */
@TargetApi(17)
public class VideoDecoderConsumer extends ProvidedStage<TextureFrame> implements SurfaceTexture.OnFrameAvailableListener {
    private final static int STATE_WAIT_INPUT   = 1;
    private final static int STATE_WAIT_TEXTURE = 2;
    private final static int STATE_WAIT_RENDER  = 3;

    private final int mWidth;
    private final int mHeight;

    private final float[] mTextureTransform = new float[16];
    private final FloatBuffer mGLCubeBuffer;
    private final FloatBuffer mGLTextureBuffer;

    private Provider<Frame> mFrameProvider;
    private EglCore mEglCore;
    private SurfaceTexture mSurfaceTexture;
    private int mSurfaceTextureId = NO_TEXTURE;
    private FrameBuffer mFrameBuffer;
    private OesInputFilter mOesInputFilter;
    private GPUImageFilterGroup mGpuImageFilterGroup;

    // 标识FrameBuffer是否被外部使用，当前不可再写
    private boolean mFrameBufferIsUnusable = false;
    private int mState = STATE_WAIT_INPUT;

    public VideoDecoderConsumer(int width, int height) {
        mWidth = width;
        mHeight = height;

        mGLCubeBuffer = ByteBuffer.allocateDirect(OpenGlUtils.CUBE.length * 4)
                .order(ByteOrder.nativeOrder()).asFloatBuffer();
        mGLCubeBuffer.put(OpenGlUtils.CUBE).position(0);

        mGLTextureBuffer = ByteBuffer.allocateDirect(OpenGlUtils.TEXTURE.length * 4)
                .order(ByteOrder.nativeOrder()).asFloatBuffer();
        mGLTextureBuffer.put(OpenGlUtils.TEXTURE).position(0);
    }

    public void setFrameProvider(Provider<Frame> provider) {
        mFrameProvider = provider;
    }

    @Override
    public void setup() {
        // 创建一个EGLCore出来，采用的是离屏的Surface
        mEglCore = new EglCore(mWidth, mHeight);
        mEglCore.makeCurrent();

        // 创建SurfaceTexture，用于给解码器作为输出，该类以texture id作为输入
        mSurfaceTextureId = OpenGlUtils.generateTextureOES();
        mSurfaceTexture = new SurfaceTexture(mSurfaceTextureId);
        mSurfaceTexture.setOnFrameAvailableListener(this);

        // 创建一个FrameBuffer，作为输出给到外面（外面不能异步使用）
        mFrameBuffer = new FrameBuffer(mWidth, mHeight);
        mFrameBuffer.initialize();

        mGpuImageFilterGroup = new GPUImageFilterGroup();
        mOesInputFilter = new OesInputFilter();
        mGpuImageFilterGroup.addFilter(mOesInputFilter);
        mGpuImageFilterGroup.addFilter(new GPUImageFilter(true));
        mGpuImageFilterGroup.init();
        mGpuImageFilterGroup.onOutputSizeChanged(mWidth, mHeight);
    }

    public SurfaceTexture getSurfaceTexture() {
        return mSurfaceTexture;
    }

    @Override
    public void processFrame() throws ProcessException {
        super.processFrame();
        if (mState == STATE_WAIT_INPUT) {
            Frame frame = mFrameProvider.dequeueOutputBuffer();
            if (frame != null) {
                // 将Frame归还给Decoder之后，会触发Decoder释放buffer并渲染到Decoder的Surface上
                mFrameProvider.enqueueOutputBuffer(frame);
                mState = STATE_WAIT_TEXTURE;
            }
        } else if (mState == STATE_WAIT_RENDER) {
            renderOesToFrameBuffer();
        }
    }

    private void renderOesToFrameBuffer() {
        if (mFrameBufferIsUnusable) {
            return;
        }

        mSurfaceTexture.updateTexImage();
        mSurfaceTexture.getTransformMatrix(mTextureTransform);
        long timestamp = mSurfaceTexture.getTimestamp() / 1000000;

        mOesInputFilter.setTexutreTransform(mTextureTransform);
        mGpuImageFilterGroup.draw(mSurfaceTextureId, mFrameBuffer.getFrameBufferId(), mGLCubeBuffer, mGLTextureBuffer);

        // 等待绘制完成
        GLES20.glFinish();

        TextureFrame textureFrame = new TextureFrame();
        textureFrame.eglContext = (EGLContext) mEglCore.getEglContext();
        textureFrame.textureId = mFrameBuffer.getTextureId();
        textureFrame.width = mWidth;
        textureFrame.height = mHeight;
        textureFrame.timestampMs = timestamp;
        synchronized (this) {
            mWaitOutBuffers.add(textureFrame);
        }

        mState = STATE_WAIT_INPUT;
    }

    @Override
    protected void recycleBuffers(List<TextureFrame> canReuseBuffers) {
        mFrameBufferIsUnusable = false;
    }

    @Override
    public void release() {
        mGpuImageFilterGroup.destroy();
        mGpuImageFilterGroup = null;

        mFrameBuffer.uninitialize();
        mFrameBuffer = null;

        OpenGlUtils.deleteTexture(mSurfaceTextureId);
        mSurfaceTextureId = NO_TEXTURE;
        mSurfaceTexture.release();
        mSurfaceTexture = null;

        mEglCore.unmakeCurrent();
        mEglCore.destroy();
        mEglCore = null;
    }

    @Override
    public void onFrameAvailable(SurfaceTexture surfaceTexture) {
        mState = STATE_WAIT_RENDER;
    }
}
