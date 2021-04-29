package com.tencent.trtc.mediashare.helper.reader.decoder.pipeline;

import android.util.Log;

import com.tencent.trtc.mediashare.helper.reader.exceptions.ProcessException;
import com.tencent.trtc.mediashare.helper.reader.exceptions.SetupException;


/**
 * 针对于每一帧进行处理的模块
 */
public abstract class Stage {
    protected static final int    DEFAULT_FRAME_COUNT = 3;
    private static final   String TAG                 = "Stage";
    protected              State  mState              = State.INIT;

    /**
     * 初始化设置
     */
    public abstract void setup() throws SetupException;

    /**
     * <p>处理一帧</p>
     * 该方法中不允许等待
     */
    public abstract void processFrame() throws ProcessException;

    /**
     * 释放持有的资源
     */
    public abstract void release();

    public boolean isDone() {
        return mState == State.DONE;
    }

    protected void setState(State state) {
        mState = state;
        if (State.DONE == mState) {
            Log.i(TAG, this + "is done");
        }
    }

    protected boolean isAllDataReady() {
        return mState == State.ALL_DATA_READY || mState == State.DONE;
    }

    protected enum State {
        INIT,
        SETUPED,

        /**
         * 所有数据都准备好了，下一个节点读取完成后就算结束
         */
        ALL_DATA_READY,

        /**
         * 这个Stage处理完成了
         */
        DONE
    }
}
