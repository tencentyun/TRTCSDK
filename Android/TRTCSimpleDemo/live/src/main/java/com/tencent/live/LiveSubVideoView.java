package com.tencent.live;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import com.tencent.rtmp.ui.TXCloudVideoView;

/**
 * RTC视频互动直播房间内的小视频画面
 *
 * 用于管理小视频画面上的“关闭声音”、“关闭视频”按钮的状态
 */
public class LiveSubVideoView extends FrameLayout {

    private TXCloudVideoView                mSubVideoView;         // 【控件】子画面View
    private Button                          mMuteAudio;            // 【控件】关闭声音
    private Button                          mMuteVideo;            // 【控件】关闭视频
    private LiveSubViewListener             mListener;             //  监听器，比如关闭声音，关闭视频时通知
    private LinearLayout                    mVideoMutedTipsView;   // 【控件】关闭视频时，显示默认头像

    public LiveSubVideoView(Context context) {
        super(context);
    }

    public LiveSubVideoView(Context context, AttributeSet attrs) {
        super(context, attrs);
        LayoutInflater.from(context).inflate(R.layout.live_sub_view_layout, this);
        mSubVideoView = findViewById(R.id.live_cloud_view);
        mVideoMutedTipsView = findViewById(R.id.ll_mute_video_default);
        mMuteVideo = findViewById(R.id.btn_mute_video);
        mMuteAudio = findViewById(R.id.btn_mute_audio);
        mMuteAudio.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mListener != null) {
                    mListener.onMuteRemoteAudioClicked(view);
                }
            }
        });
        mMuteVideo.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mListener != null) {
                    mListener.onMuteRemoteVideoClicked(view);
                }
            }
        });
        mMuteVideo.setVisibility(View.GONE);
        mMuteAudio.setVisibility(View.GONE);
    }

    public LiveSubVideoView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public TXCloudVideoView getVideoView() {
        mMuteVideo.setVisibility(View.VISIBLE);
        mMuteAudio.setVisibility(View.VISIBLE);
        return mSubVideoView;
    }

    public LinearLayout getMuteVideoDefault() {
        return mVideoMutedTipsView;
    }

    public void setLiveSubViewListener(LiveSubViewListener listener) {
        mListener = listener;
    }

    public interface LiveSubViewListener {
        void onMuteRemoteAudioClicked(View view);
        void onMuteRemoteVideoClicked(View view);
    }

}
