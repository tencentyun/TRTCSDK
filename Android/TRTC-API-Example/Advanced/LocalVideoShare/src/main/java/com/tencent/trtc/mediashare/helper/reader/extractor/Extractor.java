package com.tencent.trtc.mediashare.helper.reader.extractor;

import android.media.MediaCodec;
import android.media.MediaExtractor;
import android.media.MediaFormat;
import android.util.Log;

import com.tencent.trtc.mediashare.helper.reader.exceptions.SetupException;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Locale;

public class Extractor {
    private static final String TAG = "Extractor";

    private final boolean           mIsVideo;
    private final ExtractorAdvancer mAdvancer;
    private final String            mFileName;

    private MediaExtractor mMediaExtractor;
    private MediaFormat    mMediaFormat;
    private int            mTrackIndex;

    public Extractor(boolean isVideo, String filename, ExtractorAdvancer advancer) {
        mIsVideo = isVideo;
        mAdvancer = advancer;
        mFileName = filename;
    }

    public void setup() throws SetupException {
        initMediaExtractor();
        mAdvancer.updateExtractor(mMediaExtractor);
    }

    public void restart() throws SetupException {
        releaseMediaExtractor();
        initMediaExtractor();
        mAdvancer.updateExtractor(mMediaExtractor);
    }

    public void seekTo(long timeUs, boolean isRelative) {
        mAdvancer.seekTo(timeUs, isRelative);
    }

    public MediaCodec.BufferInfo readSampleData(ByteBuffer buffer) {
        MediaCodec.BufferInfo bufferInfo = new MediaCodec.BufferInfo();
        mAdvancer.readSampleData(bufferInfo, buffer, 0);
        // Log.v(TAG, String.format(Locale.ENGLISH, "read[%d] size: %d, time: %d, flags: %d",
        //        mTrackIndex, bufferInfo.size, bufferInfo.presentationTimeUs, bufferInfo.flags));

        if (bufferInfo.size < 0) {
            bufferInfo.size = 0;
            bufferInfo.flags |= MediaCodec.BUFFER_FLAG_END_OF_STREAM;
            Log.i(TAG, String.format(Locale.ENGLISH, "[%s] meet end of stream", mIsVideo ? "video" : "audio"));
        }

        mAdvancer.advance();
        return bufferInfo;
    }

    public MediaFormat getMediaFormat() {
        return mMediaFormat;
    }

    public void release() {
        releaseMediaExtractor();
    }

    public int getTraceIndex() {
        return mTrackIndex;
    }

    private void initMediaExtractor() throws SetupException {
        releaseMediaExtractor();
        try {
            mMediaExtractor = new MediaExtractor();
            mMediaExtractor.setDataSource(mFileName);

            mTrackIndex = selectTrack(mMediaExtractor);
            if (mTrackIndex < 0) {
                throw new SetupException("No wanted track found");
            }
            mMediaExtractor.selectTrack(mTrackIndex);
            mMediaFormat = mMediaExtractor.getTrackFormat(mTrackIndex);
        } catch (IOException e) {
            throw new SetupException("updateExtractor extractor failed.", e);
        }
    }

    private void releaseMediaExtractor() {
        if (mMediaExtractor != null) {
            mMediaExtractor.release();
            mMediaExtractor = null;
        }
    }

    private boolean isWantedMime(final String mime) {
        return mIsVideo ? mime.startsWith("video/") : mime.startsWith("audio/");
    }

    private int selectTrack(MediaExtractor extractor) {
        int numTracks = extractor.getTrackCount();
        for (int index = 0; index < numTracks; index++) {
            MediaFormat format = extractor.getTrackFormat(index);
            String      mime   = format.getString(MediaFormat.KEY_MIME);
            if (isWantedMime(mime)) {
                return index;
            }
        }

        return -1;
    }
}
