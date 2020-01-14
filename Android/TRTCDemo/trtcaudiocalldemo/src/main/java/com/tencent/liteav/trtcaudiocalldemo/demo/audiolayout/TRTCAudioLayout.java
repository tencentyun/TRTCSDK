package com.tencent.liteav.trtcaudiocalldemo.demo.audiolayout;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.AttributeSet;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.liteav.trtcaudiocalldemo.R;

/**
 *
 */
public class TRTCAudioLayout extends RelativeLayout {
    private ImageView   mHeadImg;
    private TextView    mNameTv;
    private ProgressBar mAudioPb;
    private String      mUserId;

    public TRTCAudioLayout(Context context) {
        this(context, null);
    }

    public TRTCAudioLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        inflate(context, R.layout.audiocall_item_user_layout, this);
        initView();
    }

    private void initView() {
        mHeadImg = (ImageView) findViewById(R.id.img_head);
        mNameTv = (TextView) findViewById(R.id.tv_name);
        mAudioPb = (ProgressBar) findViewById(R.id.pb_audio);
    }

    public void setAudioVolume(int vol) {
        mAudioPb.setProgress(vol);
    }

    public void setUserId(String userId) {
        mUserId = userId;
        mNameTv.setText(mUserId);
    }

    public void setBitmap(Bitmap bitmap) {
        mHeadImg.setImageBitmap(bitmap);
    }
}
