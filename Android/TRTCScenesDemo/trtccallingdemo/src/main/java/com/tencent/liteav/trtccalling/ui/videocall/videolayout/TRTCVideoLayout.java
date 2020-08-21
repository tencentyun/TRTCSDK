package com.tencent.liteav.trtccalling.ui.videocall.videolayout;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.FrameLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.liteav.trtccalling.R;
import com.tencent.rtmp.ui.TXCloudVideoView;

/**
 * Module: TRTCVideoLayout
 * <p>
 * Function:
 * <p>
 * 此 TRTCVideoLayout 封装了{@link TXCloudVideoView} 以及业务逻辑 UI 控件
 */
public class TRTCVideoLayout extends RelativeLayout {
    private boolean          mMoveAble;
    private TXCloudVideoView mTCCloudViewTRTC;
    private SquareImageView  mImageHead;
    private TextView         mTextUserName;
    private FrameLayout      mLayoutNoVideo;
    private ProgressBar      mProgressAudio;


    public TRTCVideoLayout(Context context) {
        this(context, null);
    }

    public TRTCVideoLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView();
        setClickable(true);
    }

    public TXCloudVideoView getVideoView() {
        return mTCCloudViewTRTC;
    }

    public SquareImageView getHeadImg() {
        return mImageHead;
    }

    public TextView getUserNameTv() {
        return mTextUserName;
    }

    public void setVideoAvailable(boolean available) {
        if (available) {
            mTCCloudViewTRTC.setVisibility(VISIBLE);
            mLayoutNoVideo.setVisibility(GONE);
        } else {
            mTCCloudViewTRTC.setVisibility(GONE);
            mLayoutNoVideo.setVisibility(VISIBLE);
        }
    }

    public void setAudioVolumeProgress(int progress) {
        if (mProgressAudio != null) {
            mProgressAudio.setProgress(progress);
        }
    }

    public void setAudioVolumeProgressBarVisibility(int visibility) {
        if (mProgressAudio != null) {
            mProgressAudio.setVisibility(visibility);
        }
    }

    private void initView() {
        LayoutInflater.from(getContext()).inflate(R.layout.trtccalling_videocall_item_user_layout, this, true);
        mTCCloudViewTRTC = (TXCloudVideoView) findViewById(R.id.trtc_tc_cloud_view);
        mImageHead = (SquareImageView) findViewById(R.id.iv_avatar);
        mTextUserName = (TextView) findViewById(R.id.tv_user_name);
        mLayoutNoVideo = (FrameLayout) findViewById(R.id.fl_no_video);
        mProgressAudio = (ProgressBar) findViewById(R.id.progress_bar_audio);
    }

    public boolean isMoveAble() {
        return mMoveAble;
    }

    public void setMoveAble(boolean enable) {
        mMoveAble = enable;
    }
}
