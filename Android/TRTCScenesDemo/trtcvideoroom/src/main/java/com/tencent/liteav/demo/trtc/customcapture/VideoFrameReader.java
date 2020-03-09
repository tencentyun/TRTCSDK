package com.tencent.liteav.demo.trtc.customcapture;

import android.content.Context;
import android.graphics.SurfaceTexture;
import android.media.MediaFormat;
import android.os.SystemClock;
import android.util.Log;

import com.tencent.liteav.demo.trtc.customcapture.decoder.Decoder;
import com.tencent.liteav.demo.trtc.customcapture.exceptions.ProcessException;
import com.tencent.liteav.demo.trtc.customcapture.exceptions.SetupException;
import com.tencent.liteav.demo.trtc.customcapture.extractor.Extractor;
import com.tencent.liteav.demo.trtc.customcapture.extractor.ExtractorAdvancer;
import com.tencent.liteav.demo.trtc.customcapture.extractor.RangeExtractorAdvancer;
import com.tencent.liteav.demo.trtc.customcapture.structs.TextureFrame;
import com.tencent.liteav.demo.trtc.customcapture.utils.MediaUtils;
import com.tencent.liteav.demo.trtc.customcapture.utils.Size;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;

import java.util.concurrent.CountDownLatch;

import static java.util.concurrent.TimeUnit.MILLISECONDS;

public class VideoFrameReader extends BaseReader {
    private static final String TAG = "VideoFrameReader";

    private final TRTCCloud mTRTCCloud;
    private final String mVideoPath;
    private final long mLoopDurationMs;

    private Decoder mVideoDecoder;
    private VideoDecoderConsumer mDecoderConsumer;
    private long mStartTimeMs = -1;

    public VideoFrameReader(Context context, String videoPath, long durationMs, CountDownLatch countDownLatch) {
        super(countDownLatch);
        mTRTCCloud = TRTCCloud.sharedInstance(context);
        mVideoPath = videoPath;
        mLoopDurationMs = durationMs;
    }

    @Override
    protected void setup() throws SetupException {
        Size size = retriveVideoSize();
        mDecoderConsumer = new VideoDecoderConsumer(size.width, size.height);
        mDecoderConsumer.setup();
        SurfaceTexture surfaceTexture = mDecoderConsumer.getSurfaceTexture();

        ExtractorAdvancer advancer = new RangeExtractorAdvancer(MILLISECONDS.toMicros(mLoopDurationMs));
        Extractor extractor = new Extractor(true, mVideoPath, advancer);
        mVideoDecoder = new Decoder(extractor, surfaceTexture);
        mVideoDecoder.setLooping(true);
        mVideoDecoder.setup();

        mDecoderConsumer.setFrameProvider(mVideoDecoder);
    }

    @Override
    protected void processFrame() throws ProcessException {
        if (mStartTimeMs == -1) {
            mStartTimeMs = SystemClock.elapsedRealtime();
        }

        mVideoDecoder.processFrame();
        mDecoderConsumer.processFrame();

        TextureFrame textureFrame = mDecoderConsumer.dequeueOutputBuffer();
        if (textureFrame == null) {
            return;
        }

        //将视频帧通过纹理方式塞给SDK
        TRTCCloudDef.TRTCVideoFrame videoFrame = new TRTCCloudDef.TRTCVideoFrame();
        videoFrame.texture = new TRTCCloudDef.TRTCTexture();
        videoFrame.texture.textureId = textureFrame.textureId;
        videoFrame.texture.eglContext14 = textureFrame.eglContext;
        videoFrame.width = textureFrame.width;
        videoFrame.height = textureFrame.height;
        videoFrame.pixelFormat = TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D;
        videoFrame.bufferType = TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE;

        // 检查当前帧与预期发送的时间差多久，睡眠这段时间，然后再发送
        long time = SystemClock.elapsedRealtime() - mStartTimeMs;
        if (textureFrame.timestampMs > time) {
            try {
                Thread.sleep(textureFrame.timestampMs - time);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }

        mTRTCCloud.sendCustomVideoData(videoFrame);
        mDecoderConsumer.enqueueOutputBuffer(textureFrame);
    }

    private Size retriveVideoSize() throws SetupException {
        MediaFormat mediaFormat = MediaUtils.retriveMediaFormat(mVideoPath, true);
        Size size = new Size();
        size.width = mediaFormat.getInteger(MediaFormat.KEY_WIDTH);
        size.height = mediaFormat.getInteger(MediaFormat.KEY_HEIGHT);
        if (mediaFormat.containsKey(MediaUtils.KEY_ROTATION)) {
            int rotation = mediaFormat.getInteger(MediaUtils.KEY_ROTATION);
            if (rotation == 90 || rotation == 270) {
                size.swap();
            }
        }
        return size;
    }

    @Override
    protected void release() {
        if (mVideoDecoder != null) {
            mVideoDecoder.release();
            mVideoDecoder = null;
        }

        if (mDecoderConsumer != null) {
            mDecoderConsumer.release();
            mDecoderConsumer = null;
        }
        Log.i(TAG, "released");
    }
}
