package com.tencent.trtc.mediashare.helper.reader.decoder.pipeline;

/**
 * 作为某个处理单元的数据提供者
 *
 * @param <T> 数据类型
 */
public interface Provider<T> {
    /**
     * 从提供者中读取出来一个buffer，如果读取完毕了，则返回null
     */
    T dequeueOutputBuffer();

    /**
     * 将buffer返回给提供者，以便重复使用该buffer
     */
    void enqueueOutputBuffer(T buffer);
}
