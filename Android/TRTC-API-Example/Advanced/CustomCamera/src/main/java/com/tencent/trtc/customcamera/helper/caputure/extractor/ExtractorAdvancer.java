package com.tencent.trtc.customcamera.helper.caputure.extractor;

import android.media.MediaCodec;
import android.media.MediaExtractor;

import androidx.annotation.NonNull;

import java.nio.ByteBuffer;

/**
 * 用来控制Extractor的行为，如正常的往前进，或者只提取关键帧
 */
public abstract class ExtractorAdvancer {
    protected MediaExtractor mMediaExtractor;

    /**
     * 更新MediaExtractor
     */
    public void updateExtractor(MediaExtractor mediaExtractor) {
        mMediaExtractor = mediaExtractor;
    }

    /**
     * 跳到指定位置来播放
     *
     * @param timeUs         指定的时间
     * @param isRelativeTime 是否是相对时间
     */
    public abstract void seekTo(long timeUs, boolean isRelativeTime);

    /**
     * 见{@link MediaExtractor#readSampleData(ByteBuffer, int)}
     */
    public abstract void readSampleData(MediaCodec.BufferInfo bufferInfo, @NonNull ByteBuffer byteBuf, int offset);

    /**
     * 下一帧数据
     */
    public abstract boolean advance();

    /**
     * 获取当前帧的时间戳
     */
    public abstract long getSampleTime();
}
