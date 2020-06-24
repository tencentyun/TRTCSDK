package com.tencent.liteav.trtcaudiocalldemo.ui.widget;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.AttributeSet;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.liteav.trtcaudiocalldemo.R;
import com.wang.avi.AVLoadingIndicatorView;


/**
 * 通话界面中，显示单个用户头像的自定义布局
 */
public class TRTCAudioLayout extends RelativeLayout {
    private static final int MIN_AUDIO_VOLUME = 2;
    private ImageView               mImageHead;
    private TextView                mTextName;
    private ImageView              mImageAudioInput;
    private AVLoadingIndicatorView  mViewLoading;
    private FrameLayout             mLayoutShade;
    private String                  mUserId;

    public TRTCAudioLayout(Context context) {
        this(context, null);
    }

    public TRTCAudioLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        inflate(context, R.layout.trtcaudiocall_item_user_layout, this);
        initView();
    }

    private void initView() {
        mImageHead = (ImageView) findViewById(R.id.img_head);
        mTextName = (TextView) findViewById(R.id.tv_name);
        mImageAudioInput = (ImageView) findViewById(R.id.iv_audio_input);
        mViewLoading = (AVLoadingIndicatorView) findViewById(R.id.loading_view);
        mLayoutShade = (FrameLayout) findViewById(R.id.fl_shade);
    }

    public void setAudioVolume(int vol) {
        if (vol > MIN_AUDIO_VOLUME){
            mImageAudioInput.setVisibility(VISIBLE);
        } else {
            mImageAudioInput.setVisibility(GONE);
        }
    }

    public void setUserId(String userId) {
        mUserId = userId;
        mTextName.setText(mUserId);
    }

    public void setBitmap(Bitmap bitmap) {
        mImageHead.setImageBitmap(bitmap);
    }

    public ImageView getImageView() {
        return mImageHead;
    }

    public void startLoading() {
        mLayoutShade.setVisibility(VISIBLE);
        mViewLoading.show();
    }

    public void stopLoading() {
        mLayoutShade.setVisibility(GONE);
        mViewLoading.hide();
    }
}
