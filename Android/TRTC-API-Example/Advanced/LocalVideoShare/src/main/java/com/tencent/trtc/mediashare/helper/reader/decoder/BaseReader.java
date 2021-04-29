package com.tencent.trtc.mediashare.helper.reader.decoder;

import android.os.SystemClock;
import android.util.Log;

import com.tencent.trtc.mediashare.helper.reader.exceptions.ProcessException;
import com.tencent.trtc.mediashare.helper.reader.exceptions.SetupException;

import java.util.concurrent.CountDownLatch;

public abstract class BaseReader extends Thread {
    private static final String TAG                            = "BaseReader";
    private static final int    DEFAULT_FRAME_PROCESS_INTERVAL = 3;

    private final    CountDownLatch mCountDownLatch;
    private volatile boolean        mIsCancelled = false;

    public BaseReader(CountDownLatch countDownLatch) {
        mCountDownLatch = countDownLatch;
    }

    public void stopRead() {
        mIsCancelled = true;
    }

    @Override
    public void run() {
        try {
            setup();
            mCountDownLatch.countDown();
            mCountDownLatch.await();

            while (!mIsCancelled) {
                long frameStartTime = SystemClock.elapsedRealtime();

                processFrame();

                // 如果一帧的处理时长太短，增加sleep，防止占用太高CPU。
                long frameCost = SystemClock.elapsedRealtime() - frameStartTime;
                if (frameCost < DEFAULT_FRAME_PROCESS_INTERVAL) {
                    try {
                        Thread.sleep(DEFAULT_FRAME_PROCESS_INTERVAL - frameCost);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "process failed.", e);
        } finally {
            release();
        }
    }

    protected abstract void setup() throws SetupException;

    protected abstract void processFrame() throws ProcessException;

    protected abstract void release();
}
