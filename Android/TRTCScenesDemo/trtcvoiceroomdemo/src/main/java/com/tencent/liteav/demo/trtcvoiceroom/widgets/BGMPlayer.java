package com.tencent.liteav.demo.trtcvoiceroom.widgets;

import android.util.Log;

import com.tencent.trtc.TRTCCloud;

public class BGMPlayer {
    private static final int STATUS_IDLE  = 0;
    private static final int STATUS_PLAY  = 1;
    private static final int STATUS_PAUSE = 2;

    private String              mPath;
    private TRTCCloud.BGMNotify mBGMNotify;
    private Listener            mListener;
    private int                 status;

    public BGMPlayer(String path, final Listener listener) {
        status = STATUS_IDLE;
        mPath = path;
        mListener = listener;
        mBGMNotify = new TRTCCloud.BGMNotify() {
            @Override
            public void onBGMStart(int errCode) {

            }

            @Override
            public void onBGMProgress(long progress, long duration) {
                Log.d("BGMPlayer", "onBGMProgress: " + progress + " " + duration);
                if (status != STATUS_PLAY) {
                    return;
                }
                int actualProgress = ((int) (progress / (float) duration * 100));
                if (mListener != null) {
                    mListener.onProgress(actualProgress);
                }
                if (actualProgress >= 100) {
                    status = STATUS_IDLE;
                    if (mListener != null) {
                        mListener.onStop();
                    }
                }
            }

            @Override
            public void onBGMComplete(int err) {
            }
        };
    }

    public boolean isWorking() {
        return status != STATUS_IDLE;
    }

    public void startPlay(TRTCCloud trtcCloud) {
        if (status == STATUS_IDLE) {
            trtcCloud.playBGM(mPath, mBGMNotify);
        } else if (status == STATUS_PAUSE) {
            trtcCloud.resumeBGM();
        }
        status = STATUS_PLAY;
    }

    public void pausePlay(TRTCCloud trtcCloud) {
        trtcCloud.pauseBGM();
        status = STATUS_PAUSE;
    }

    public void stopPlay(TRTCCloud trtcCloud) {
        trtcCloud.stopBGM();
        status = STATUS_IDLE;
        if (mListener != null) {
            mListener.onStop();
        }
    }

    public interface Listener {
        void onProgress(int progress);
        void onStop();
    }
}
