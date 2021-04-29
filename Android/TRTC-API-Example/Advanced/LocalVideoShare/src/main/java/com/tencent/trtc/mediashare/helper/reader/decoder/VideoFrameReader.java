package com.tencent.trtc.mediashare.helper.reader.decoder;

import android.media.MediaFormat;
import android.opengl.EGLContext;
import android.os.SystemClock;
import android.util.Log;

import com.tencent.trtc.mediashare.helper.basic.Size;
import com.tencent.trtc.mediashare.helper.basic.TextureFrame;
import com.tencent.trtc.mediashare.helper.basic.Utils;
import com.tencent.trtc.mediashare.helper.reader.exceptions.ProcessException;
import com.tencent.trtc.mediashare.helper.reader.exceptions.SetupException;

import java.util.concurrent.CountDownLatch;

public class VideoFrameReader extends BaseReader {
    private static final String TAG = "VideoFrameReader";

    private final String mVideoPath;
    private final long   mLoopDurationMs;

    private VideoFrameToTexture mDecoderConsumer;
    private long                   mStartTimeMs = -1;
    private VideoFrameReadListener mListener;

    public interface VideoFrameReadListener {
        void onFrameAvailable(EGLContext eglContext, int textureId, int width, int height, long timestamp);
    }

    public VideoFrameReader(String videoPath, long durationMs, CountDownLatch countDownLatch) {
        super(countDownLatch);
        mVideoPath = videoPath;
        mLoopDurationMs = durationMs;
    }

    public void setListener(VideoFrameReadListener listener) {
        mListener = listener;
    }

    @Override
    protected void setup() throws SetupException {
        Size size = retrieveVideoSize();
        mDecoderConsumer = new VideoFrameToTexture(size.width, size.height);
        mDecoderConsumer.setup();
        mDecoderConsumer.setFrameProvider(mVideoPath, mLoopDurationMs);
    }

    @Override
    protected void processFrame() throws ProcessException {
        if (mStartTimeMs == -1) {
            mStartTimeMs = SystemClock.elapsedRealtime();
        }


        mDecoderConsumer.processFrame();

        TextureFrame textureFrame = mDecoderConsumer.dequeueOutputBuffer();
        if (textureFrame == null) {
            return;
        }

        // 检查当前帧与预期发送的时间差多久，睡眠这段时间，然后再发送
        long time = SystemClock.elapsedRealtime() - mStartTimeMs;
        if (textureFrame.timestampMs > time) {
            try {
                Thread.sleep(textureFrame.timestampMs - time);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }

        VideoFrameReadListener listener = mListener;
        if (listener != null) {
            listener.onFrameAvailable(textureFrame.eglContext, textureFrame.textureId, textureFrame.width, textureFrame.height, textureFrame.timestampMs);
        }

        mDecoderConsumer.enqueueOutputBuffer(textureFrame);
    }

    private Size retrieveVideoSize() throws SetupException {
        MediaFormat mediaFormat = Utils.retrieveMediaFormat(mVideoPath, true);
        Size        size        = new Size();
        size.width = mediaFormat.getInteger(MediaFormat.KEY_WIDTH);
        size.height = mediaFormat.getInteger(MediaFormat.KEY_HEIGHT);
        if (mediaFormat.containsKey(Utils.KEY_ROTATION)) {
            int rotation = mediaFormat.getInteger(Utils.KEY_ROTATION);
            if (rotation == 90 || rotation == 270) {
                size.swap();
            }
        }
        return size;
    }

    @Override
    protected void release() {
        if (mDecoderConsumer != null) {
            mDecoderConsumer.release();
            mDecoderConsumer = null;
        }
        Log.i(TAG, "released");
    }
}
