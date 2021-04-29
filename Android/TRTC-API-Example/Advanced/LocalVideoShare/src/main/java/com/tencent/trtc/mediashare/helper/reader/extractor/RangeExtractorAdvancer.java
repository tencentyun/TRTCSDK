package com.tencent.trtc.mediashare.helper.reader.extractor;

import android.media.MediaCodec;
import android.media.MediaExtractor;
import android.util.Log;

import androidx.annotation.NonNull;

import java.nio.ByteBuffer;

public class RangeExtractorAdvancer extends ExtractorAdvancer {
    private static final String TAG = "RangeExtractorAdvancer";

    protected long mRangeEndUs;
    private   long mFirstFrameTime;
    private   int  mLoopCount = -1;

    public RangeExtractorAdvancer() {
        this(-1);
    }

    /**
     * <p>构造一个Advancer，同时指定该文件只会读取哪个范围的数据。</p>
     * 注：如果开始时间不是关键帧，则会调整到上一个关键帧
     *
     * @param endUs 结束时间
     */
    public RangeExtractorAdvancer(long endUs) {
        mRangeEndUs = endUs;
    }

    @Override
    public void seekTo(long timeUs, boolean isRelativeTime) {
        mMediaExtractor.seekTo(timeUs, MediaExtractor.SEEK_TO_PREVIOUS_SYNC);
        Log.i(TAG, "seekTo timeUs: " + timeUs + ", isRelativeTime: " + isRelativeTime);
    }

    @Override
    public void updateExtractor(MediaExtractor mediaExtractor) {
        super.updateExtractor(mediaExtractor);
        mFirstFrameTime = mMediaExtractor.getSampleTime();
        Log.i(TAG, "first frame time: " + mFirstFrameTime);

        // seek到指定时间的上一个关键帧
        mMediaExtractor.seekTo(mFirstFrameTime, MediaExtractor.SEEK_TO_PREVIOUS_SYNC);
    }

    @Override
    public void readSampleData(MediaCodec.BufferInfo bufferInfo, @NonNull ByteBuffer byteBuf, int offset) {
        if (isInRange()) {
            if (mMediaExtractor.getSampleTime() == mFirstFrameTime) {
                mLoopCount++;
            }

            bufferInfo.size = mMediaExtractor.readSampleData(byteBuf, offset);
            bufferInfo.flags = mMediaExtractor.getSampleFlags();
            bufferInfo.presentationTimeUs = mLoopCount * mRangeEndUs + mMediaExtractor.getSampleTime();
            bufferInfo.offset = offset;
        } else {
            bufferInfo.size = -1;
        }
    }

    @Override
    public boolean advance() {
        return isInRange() && mMediaExtractor.advance();
    }

    @Override
    public long getSampleTime() {
        return mMediaExtractor.getSampleTime();
    }

    protected boolean isInRange() {
        long sampleTime = mMediaExtractor.getSampleTime();
        return (0 <= sampleTime) && (mRangeEndUs == -1 || sampleTime <= mRangeEndUs);
    }
}
