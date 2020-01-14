package com.tencent.liteav.demo.trtcvoiceroom.widgets;

import android.content.Context;
import android.support.constraint.ConstraintLayout;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;

import com.tencent.liteav.demo.trtcvoiceroom.R;


/**
 * 音效item的界面和逻辑相关
 *
 * @author guanyifeng
 */
public class EffectItemView extends ConstraintLayout implements View.OnClickListener {
    private Callback             mCallback;
    private TextView             mTitleTv;
    private SeekBar              mAudioVolSb;
    private ImageView            mVolImg;
    private Button               mPreviewBtn;
    private Button               mUseBtn;

    public EffectItemView(Context context) {
        this(context, null);
    }

    public EffectItemView(Context context, AttributeSet attrs) {
        super(context, attrs);
        inflate(context, R.layout.voiceroom_item_setting_sound_effect, this);
        initView();
    }


    public void setCallback(Callback callback) {
        mCallback = callback;
    }

    private void initView() {
        mTitleTv = (TextView) findViewById(R.id.tv_title);
        mAudioVolSb = (SeekBar) findViewById(R.id.sb_audio_vol);
        mVolImg = (ImageView) findViewById(R.id.img_vol);
        mPreviewBtn = (Button) findViewById(R.id.btn_preview);
        mUseBtn = (Button) findViewById(R.id.btn_use);
        mUseBtn.setOnClickListener(this);
        mPreviewBtn.setOnClickListener(this);

        // 调整音量大小会回调到onVolChange
        mAudioVolSb.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (mCallback != null && fromUser) {
                    mCallback.onVolChange(progress);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });
    }

    public void setTitle(String title) {
        mTitleTv.setText(title);
    }

    public int getVol() {
        return mAudioVolSb.getProgress();
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.btn_preview) {
            if (mCallback != null) {
                mCallback.onPreview();
            }
        } else if (id == R.id.btn_use) {
            if (mCallback != null) {
                mCallback.onUse();
            }
        }
    }

    public void setProgress(final int progress) {
        mAudioVolSb.post(new Runnable() {
            @Override
            public void run() {
                mAudioVolSb.setProgress(progress);
            }
        });
    }

    /**
     * 点击item后相关的回调
     */
    public interface Callback {
        void onPreview();

        void onUse();

        void onVolChange(int gain);
    }
}
