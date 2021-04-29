package com.tencent.trtc.mediashare.helper.reader.decoder.pipeline;


import com.tencent.trtc.mediashare.helper.reader.exceptions.ProcessException;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

public abstract class ProvidedStage<T> extends Stage implements Provider<T> {
    protected final Queue<T> mWaitOutBuffers   = new LinkedList<>();
    protected final Queue<T> mRecycledBuffers  = new LinkedList<>();
    protected       int      mBufferOutedCount = 0;

    @Override
    public T dequeueOutputBuffer() {
        synchronized (this) {
            T t = mWaitOutBuffers.poll();
            if (t != null) {
                mBufferOutedCount++;
            }
            return t;
        }
    }

    @Override
    public void enqueueOutputBuffer(T buffer) {
        synchronized (this) {
            mBufferOutedCount--;
            mRecycledBuffers.add(buffer);
        }
    }

    @Override
    public void processFrame() throws ProcessException {
        List<T> canReuseBuffers;
        synchronized (this) {
            canReuseBuffers = new ArrayList<>(mRecycledBuffers);
            mRecycledBuffers.clear();
        }
        recycleBuffers(canReuseBuffers);

        synchronized (this) {
            if (isAllDataReady() && noBufferKeepByUs()) {
                setState(State.DONE);
            }
        }
    }

    public void drainOutputBuffers() {
        T t = dequeueOutputBuffer();
        if (t != null) {
            enqueueOutputBuffer(t);
        }
    }

    protected abstract void recycleBuffers(List<T> canReuseBuffers);

    protected boolean noBufferKeepByUs() {
        synchronized (this) {
            return mRecycledBuffers.isEmpty() && mWaitOutBuffers.isEmpty() && mBufferOutedCount == 0;
        }
    }
}
