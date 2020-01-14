package com.tencent.liteav.demo.trtcvoiceroom.widgets;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.DisplayMetrics;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.SeekBar;
import android.widget.TextView;

import com.tencent.liteav.demo.trtcvoiceroom.VoiceRoomContract;
import com.tencent.liteav.demo.trtcvoiceroom.R;
import com.tencent.liteav.demo.trtcvoiceroom.model.SettingConfig;

public class BGMSettingFragment extends BaseSettingFragmentDialog {

    private VoiceRoomContract.IPresenter mPresenter;

    /**
     * 界面控件
     */
    private ProgressBar mLocalPb;
    private ImageView   mLocalBtn;
    private ProgressBar mOnlinePb;
    private ImageView   mOnlineBtn;
    private SeekBar     mBgmVolSb;
    private TextView    mBgmVolTv;
    private SeekBar     mMicVolSb;
    private TextView    mMicVolTv;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    public void setPresenter(VoiceRoomContract.IPresenter presenter) {
        mPresenter = presenter;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView(view);
        initListener();
    }

    private void initListener() {
        mLocalBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mPresenter != null) {
                    boolean shouldPause = !mLocalBtn.isActivated();
                    mPresenter.playLocalBGM(shouldPause);
                }
            }
        });
        mOnlineBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mPresenter != null) {
                    boolean shouldPause = !mOnlineBtn.isActivated();
                    mPresenter.playOnlineBGM(shouldPause);
                }
            }
        });
        mBgmVolSb.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (fromUser) {
                    if (mPresenter != null) {
                        mBgmVolTv.setText(String.valueOf(progress));
                        mPresenter.setBGMVol(progress);
                    }
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        mMicVolSb.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (mPresenter != null) {
                    mMicVolTv.setText(String.valueOf(progress));
                    mPresenter.setMicVol(progress);
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

    @Override
    protected int getLayoutId() {
        return R.layout.voiceroom_fragment_bgm;
    }

    private void initView(@NonNull final View itemView) {
        mLocalPb = (ProgressBar) itemView.findViewById(R.id.pb_local);
        mLocalBtn = (ImageView) itemView.findViewById(R.id.btn_local);
        mOnlinePb = (ProgressBar) itemView.findViewById(R.id.pb_online);
        mOnlineBtn = (ImageView) itemView.findViewById(R.id.btn_online);
        mBgmVolSb = (SeekBar) itemView.findViewById(R.id.sb_bgm_vol);
        mBgmVolTv = (TextView) itemView.findViewById(R.id.tv_bgm_vol);
        mMicVolSb = (SeekBar) itemView.findViewById(R.id.sb_mic_vol);
        mMicVolTv = (TextView) itemView.findViewById(R.id.tv_mic_vol);

        updateView();
    }

    public void updateView() {
        SettingConfig config = SettingConfig.getInstance();
        mBgmVolSb.setProgress(config.mBgmVol);
        mBgmVolTv.setText(String.valueOf(config.mBgmVol));
        mLocalBtn.setActivated(config.isPlayingLocal);
        mOnlineBtn.setActivated(config.isPlayingOnline);
        mMicVolSb.setProgress(config.mMicVol);
        mMicVolTv.setText(String.valueOf(config.mMicVol));
    }

    public void updateProgress(boolean isLocal, int progress) {
        if (isLocal) {
            mLocalPb.setProgress(progress);
        } else {
            mOnlinePb.setProgress(progress);
        }
    }

    @Override
    protected int getHeight(DisplayMetrics dm) {
        return (int) (dm.heightPixels * 0.4);
    }
}
