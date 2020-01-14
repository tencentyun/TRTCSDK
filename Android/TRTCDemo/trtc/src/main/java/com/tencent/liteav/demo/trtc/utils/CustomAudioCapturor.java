package com.tencent.liteav.demo.trtc.utils;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;

import java.lang.ref.WeakReference;
import java.sql.Array;
import java.util.Arrays;

public class CustomAudioCapturor  implements Runnable {
    private static final String TAG = CustomAudioCapturor.class.getSimpleName();
    private static CustomAudioCapturor instance = null;

    private int mSampleRate = 48000;
    private int mChannels = 1;
    private int mBits = 16;

    private AudioRecord mCapturor;
    private byte[] mCaptureBuffer = null;
    private WeakReference<TXICustomAudioCapturorListener> mWeakRefListener;
    private Thread mCaptureThread = null;
    private volatile boolean mIsRunning = false;

    public interface TXICustomAudioCapturorListener {
        void onAudioCapturePcm(byte[] data, int sampleRate, int channels, long timestampMs);
    }

    //单例录制类
    public static CustomAudioCapturor getInstance() {
        if (instance == null) {
            synchronized (CustomAudioCapturor.class) {
                if (instance == null) {
                    instance = new CustomAudioCapturor();
                }
            }
        }
        return instance;
    }

    private CustomAudioCapturor() {}


    //启动采集线程
    public void start(int sampleRate, int channels) {
        stop();

        mSampleRate = sampleRate;
        mChannels = channels;
        mIsRunning = true;
        mCaptureThread = new Thread(this, "CustomAudioCapturor Thread");
        mCaptureThread.start();
    }

    //停止采集线程
    public void stop() {
        mIsRunning = false;
        if (mCaptureThread != null && mCaptureThread.isAlive() && Thread.currentThread().getId() != mCaptureThread.getId()) {
            try {
                mCaptureThread.join();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        mCaptureThread = null;
    }

    //配置AudioRecord对象
    private void init() {
        //采样率
        int sampleRate = mSampleRate;

        //声道数
        int channels = mChannels;
        int channelConfig = AudioFormat.CHANNEL_IN_STEREO;
        if (channels == 1) {
            channelConfig = AudioFormat.CHANNEL_IN_MONO;
        }

        //位宽
        int bits = mBits;
        int audioFormat = AudioFormat.ENCODING_PCM_16BIT;
        if (bits == 8) {
            audioFormat = AudioFormat.ENCODING_PCM_8BIT;
        }

        //计算AudioRecord的采集缓冲
        int bufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat);

        //创建AudioRecord
        try {
            mCapturor = new AudioRecord(MediaRecorder.AudioSource.MIC, sampleRate, channelConfig, audioFormat, bufferSize * 2);
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        }

        if (mCapturor == null || mCapturor.getState() != AudioRecord.STATE_INITIALIZED) {
            uninit();
            return;
        }

        //分配存储采集数据的缓冲
        int oneFrameSize = 960 * channels * bits / 8;
        if (oneFrameSize > bufferSize) {
            mCaptureBuffer = new byte[bufferSize];
        } else {
            mCaptureBuffer = new byte[oneFrameSize];
        }

        //启动采集
        if (mCapturor != null) {
            try {
                mCapturor.startRecording();
            } catch (Exception e) {
                e.printStackTrace();
                return;
            }
        }
    }

    //释放AudioRecord对象
    private void uninit() {
        if (mCapturor != null) {
            try {
                mCapturor.stop();
                mCapturor.release();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        mCapturor = null;
        mCaptureBuffer = null;
    }

    public void setCustomAudioCaptureListener(TXICustomAudioCapturorListener listener) {
        if (listener == null) {
            mWeakRefListener = null;
        } else {
            mWeakRefListener = new WeakReference<TXICustomAudioCapturorListener>(listener);
        }
    }

    private void onAudioCapturePcm(byte[] data, int dataLen, long timestampMs) {
        TXICustomAudioCapturorListener listener = null;
        synchronized (this) {
            if (null != mWeakRefListener) {
                listener = mWeakRefListener.get();
            }
        }
        if (null != listener) {
            byte[] pcmData = new byte[dataLen];
            System.arraycopy(data, 0, pcmData, 0, dataLen);
            listener.onAudioCapturePcm(pcmData, mSampleRate, mChannels, timestampMs);
        }
    }

    @Override
    public void run() {
        if (!mIsRunning) {
            return;
        }

        init();

        while (mIsRunning && !Thread.interrupted() && mCapturor != null) {
            int readSize = mCapturor.read(mCaptureBuffer, 0, mCaptureBuffer.length);
            if (readSize > 0) onAudioCapturePcm(mCaptureBuffer, readSize, System.currentTimeMillis());
        }

        uninit();
    }
}
