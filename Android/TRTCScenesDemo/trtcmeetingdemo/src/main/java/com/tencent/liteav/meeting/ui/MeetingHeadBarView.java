package com.tencent.liteav.meeting.ui;

import android.content.Context;
import android.support.annotation.NonNull;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.liteav.demo.trtc.R;

/**
 * 头部view
 *
 * @author guanyifeng
 */
public class MeetingHeadBarView extends RelativeLayout {
    private ImageView       mHeadsetImg;
    private ImageView       mCameraSwitchImg;
    private TextView        mTitleTv;
    private TextView        mExitTv;
    private HeadBarCallback mHeadBarCallback;

    public MeetingHeadBarView(Context context) {
        this(context, null);
    }

    public MeetingHeadBarView(Context context, AttributeSet attrs) {
        super(context, attrs);
        inflate(context, R.layout.view_meeting_head_bar, this);
        initView(this);
    }

    private void initView(@NonNull final View itemView) {
        mHeadsetImg = (ImageView) itemView.findViewById(R.id.img_headset);
        mCameraSwitchImg = (ImageView) itemView.findViewById(R.id.img_camera_switch);
        mTitleTv = (TextView) itemView.findViewById(R.id.tv_title);
        mExitTv = (TextView) itemView.findViewById(R.id.tv_exit);

        mHeadsetImg.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mHeadBarCallback != null) {
                    mHeadBarCallback.onHeadSetClick();
                }
            }
        });

        mCameraSwitchImg.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mHeadBarCallback != null) {
                    mHeadBarCallback.onSwitchCameraClick();
                }
            }
        });

        mExitTv.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mHeadBarCallback != null) {
                    mHeadBarCallback.onExitClick();
                }
            }
        });
    }

    public void setTitle(String text) {
        if (mTitleTv != null) {
            mTitleTv.setText(text);
        }
    }

    public void setHeadsetImg(boolean useSpeaker) {
        if (mHeadsetImg != null) {
            mHeadsetImg.setImageResource(useSpeaker ? R.drawable.ic_meeting_speaker : R.drawable.ic_meeting_headset);
        }
    }

    public void setHeadBarCallback(HeadBarCallback headBarCallback) {
        mHeadBarCallback = headBarCallback;
    }

    public interface HeadBarCallback {
        void onHeadSetClick();

        void onSwitchCameraClick();

        void onExitClick();
    }
}
