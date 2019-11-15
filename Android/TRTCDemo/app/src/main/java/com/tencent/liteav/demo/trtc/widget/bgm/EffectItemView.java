package com.tencent.liteav.demo.trtc.widget.bgm;

import android.content.Context;
import android.support.constraint.ConstraintLayout;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.SeekBar;
import android.widget.TextView;

import com.tencent.liteav.demo.R;

/**
 * 音效item的界面和逻辑相关
 *
 * @author guanyifeng
 */
public class EffectItemView extends ConstraintLayout implements View.OnClickListener {
    private Callback mCallback;
    private TextView mTitleTv;
    private CheckBox mUploadCb;
    private SeekBar  mAudioVolSb;
    private Button   mStartBtn;
    private Button   mEndBtn;

    public EffectItemView(Context context) {
        this(context, null);
    }

    public EffectItemView(Context context, AttributeSet attrs) {
        super(context, attrs);
        inflate(context, R.layout.trtc_item_setting_sound_effect, this);
        initView();
    }


    public void setCallback(Callback callback) {
        mCallback = callback;
    }

    private void initView() {
        mTitleTv = (TextView) findViewById(R.id.tv_title);
        mUploadCb = (CheckBox) findViewById(R.id.cb_upload);
        mAudioVolSb = (SeekBar) findViewById(R.id.sb_audio_vol);
        mStartBtn = (Button) findViewById(R.id.btn_start);
        mEndBtn = (Button) findViewById(R.id.btn_end);

        mStartBtn.setOnClickListener(this);
        mEndBtn.setOnClickListener(this);
        mUploadCb.setOnClickListener(this);
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

    public boolean isCheckUpload() {
        return mUploadCb.isChecked();
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.btn_start) {
            if (mCallback != null) {
                mCallback.onStart();
            }
        } else if (id == R.id.btn_end) {
            if (mCallback != null) {
                mCallback.onEnd();
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
        void onStart();

        void onEnd();

        void onVolChange(int gain);
    }
}
