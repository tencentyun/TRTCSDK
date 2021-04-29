package com.tencent.trtc.mediashare.helper.basic;

import android.media.MediaCodec;
import android.media.MediaCodec.BufferInfo;

import java.nio.ByteBuffer;

public class Frame {
    /**
     * 该帧所包含的数据，这个buffer有可能是从{@link MediaCodec#getInputBuffers()}返回的，
     * 需要在使用完成后，返回给MediaCodec。
     */
    public ByteBuffer buffer;

    /**
     * 如果{@link Frame#buffer}是从其他模块返回的，则该成员记录它的索引。
     */
    public int bufferIndex;

    /**
     * 标识缓存的哪个字节开始是有效数据。
     */
    public int offset;

    /**
     * 标识缓存中有效数据的长度。
     */
    public int size;

    /**
     * 该数据对应的显示时间
     */
    public long presentationTimeUs;

    /**
     * 一些标识，具体见{@link BufferInfo#flags}
     */
    public int flags;
}
