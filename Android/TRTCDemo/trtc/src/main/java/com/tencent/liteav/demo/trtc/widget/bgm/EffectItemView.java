package com.tencent.liteav.demo.trtc.widget.bgm;

import android.content.Context;
import android.support.constraint.ConstraintLayout;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.SeekBar;
import android.widget.TextView;

import com.tencent.liteav.demo.trtc.R;

/**
 * 音效item的界面和逻辑相关
 *
 * @author guanyifeng
 */
public class EffectItemView extends ConstraintLayout implements View.OnClickListener {
    public static final int STATUS_IDLE   = 0;
    public static final int STATUS_PAUSE  = 1;
    public static final int STATUS_RESUME = 2;

    private Callback mCallback;
    private TextView mTitleTv;
    private CheckBox mUploadCb;
    private SeekBar  mAudioVolSb;
    private Button   mStartBtn;
    private Button   mEndBtn;
    private int      mPlayNextStatus = STATUS_IDLE;

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

    public void onPlayComplete() {
        mPlayNextStatus = STATUS_IDLE;
        updateStartBtnIcon();
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
            if (mCallback == null) {
                return;
            }
            switch (mPlayNextStatus) {
                case STATUS_IDLE:
                    mCallback.onStart();
                    mPlayNextStatus = STATUS_PAUSE;
                    break;
                case STATUS_PAUSE:
                    mCallback.onPause();
                    mPlayNextStatus = STATUS_RESUME;
                    break;
                case STATUS_RESUME:
                    mCallback.onResume();
                    mPlayNextStatus = STATUS_PAUSE;
                    break;
                default:
                    break;
            }
        } else if (id == R.id.btn_end) {
            if (mCallback != null) {
                mPlayNextStatus = STATUS_IDLE;
                mCallback.onEnd();
            }
        }
        updateStartBtnIcon();
    }

    private void updateStartBtnIcon() {
        switch (mPlayNextStatus) {
            case STATUS_IDLE:
                mStartBtn.setBackgroundResource(R.drawable.trtc_ic_play_start);
                break;
            case STATUS_PAUSE:
                mStartBtn.setBackgroundResource(R.drawable.trtc_ic_play_pause);
                break;
            case STATUS_RESUME:
                mStartBtn.setBackgroundResource(R.drawable.trtc_ic_play_start);
                break;
            default:
                break;
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

        void onPause();

        void onResume();

        void onEnd();

        void onVolChange(int gain);
    }
}
