package com.tencent.trtc.mediashare.helper;

import android.content.Context;
import android.media.MediaFormat;
import android.opengl.EGLContext;
import android.util.Log;
import android.widget.Toast;

import com.tencent.trtc.mediashare.helper.basic.Utils;
import com.tencent.trtc.mediashare.helper.reader.decoder.AudioFrameReader;
import com.tencent.trtc.mediashare.helper.reader.decoder.VideoFrameReader;
import com.tencent.trtc.mediashare.helper.reader.exceptions.SetupException;

import java.util.concurrent.CountDownLatch;

import static java.util.concurrent.TimeUnit.MICROSECONDS;
import static java.util.concurrent.TimeUnit.MILLISECONDS;

/**
 * 本地媒体文件直播分享的帮助类，用来帮助开发者快速实现TRTC 自定义音/视频采集相关功能；
 * 主要包含：
 * - 实现诸如.mp4、.mp3的媒体文件音视频帧的硬解码流程；
 * - 实现音画对齐等操作；
 * - 以回调的方式将解码后的数据返回；
 */
public class MediaFileSyncReader {
    private static final String TAG = "TestSendCustomData";

    private final boolean          mWithVideo;
    private       String           mMediaFilePath;
    private       Context          mContext;
    private VideoFrameReader mVideoFrameReader;
    private AudioFrameReader mAudioFrameReader;
    private       boolean          mIsAudioStopped = false;

    public interface AudioFrameReadListener  extends AudioFrameReader.AudioFrameReadListener {
        void onFrameAvailable(byte[] data, int sampleRate, int channel, long timestamp);
    }

    public interface VideoFrameReadListener extends VideoFrameReader.VideoFrameReadListener {
        void onFrameAvailable(EGLContext eglContext, int textureId, int width, int height, long timestamp);
    }

    public MediaFileSyncReader(Context context, String mediaFilePath, boolean withVideo) {
        mWithVideo = withVideo;
        mContext = context.getApplicationContext();
        mMediaFilePath = mediaFilePath;
    }

    // 需要一定耗时，最好放在非主线程调用
    public synchronized void start(AudioFrameReadListener audioListener, VideoFrameReadListener videoListener) {
        if (mAudioFrameReader != null || mVideoFrameReader != null) {
            return;
        }

        long duration;
        try {
            // 循环的时长按照音频长度，同时按照20ms对齐
            MediaFormat mediaFormat = Utils.retrieveMediaFormat(mMediaFilePath, false);
            duration = mediaFormat.getLong(MediaFormat.KEY_DURATION);
            duration = (duration / MILLISECONDS.toMicros(20) + 1) * MILLISECONDS.toMicros(20);
        } catch (SetupException e) {
            Log.e(TAG, "setup failed.", e);
            Toast.makeText(mContext, "打开文件失败!", Toast.LENGTH_LONG).show();
            return;
        }

        CountDownLatch countDownLatch = new CountDownLatch(mWithVideo ? 2 : 1);
        if (mWithVideo) {
            mVideoFrameReader = new VideoFrameReader(mMediaFilePath, MICROSECONDS.toMillis(duration), countDownLatch);
            mVideoFrameReader.setListener(videoListener);
            mVideoFrameReader.start();
        }

        mAudioFrameReader = new AudioFrameReader(mMediaFilePath, MICROSECONDS.toMillis(duration), countDownLatch);
        mAudioFrameReader.setListener(audioListener);
        mAudioFrameReader.start();
        stopAudio(mIsAudioStopped);
    }

    public void stopAudio(boolean stop) {
        mIsAudioStopped = stop;
        if (mAudioFrameReader != null) {
            mAudioFrameReader.enableSend(!mIsAudioStopped);
        }
    }

    public synchronized void stop() {
        if (mVideoFrameReader != null) {
            mVideoFrameReader.stopRead();
            mVideoFrameReader.setListener(null);
            mVideoFrameReader = null;
        }

        if (mAudioFrameReader != null) {
            mAudioFrameReader.stopRead();
            mAudioFrameReader.setListener(null);
            mAudioFrameReader = null;
        }
    }
}
