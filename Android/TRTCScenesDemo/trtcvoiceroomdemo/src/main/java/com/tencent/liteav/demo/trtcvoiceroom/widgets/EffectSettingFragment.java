package com.tencent.liteav.demo.trtcvoiceroom.widgets;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.SeekBar;

import com.tencent.liteav.demo.trtcvoiceroom.VoiceRoomContract;
import com.tencent.liteav.demo.trtcvoiceroom.R;
import com.tencent.liteav.demo.trtcvoiceroom.Utils;

import java.io.File;
import java.io.IOException;

/**
 * @author guanyifeng
 */
public class EffectSettingFragment extends BaseSettingFragmentDialog {
    private static final String TAG = EffectSettingFragment.class.getName();

    private Button                       mStopAllBtn;
    private SeekBar                      mAudioVolAllSb;
    private EditText                     mLoopTimeEt;
    private int                          mLoopTime = 0;
    private EffectItemView               mEffectClipSe;
    private EffectItemView               mEffectGiftSe;
    private int                          mClipVol  = 100;
    private int                          mGiftVol  = 100;
    private VoiceRoomContract.IPresenter mPresenter;

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView(view);
        initListener();
    }

    private void initListener() {
        mEffectClipSe.setCallback(new EffectItemView.Callback() {
            @Override
            public void onPreview() {
                if (mPresenter != null) {
                    mPresenter.stopAudioEffect(1);

                    File sdcardDir = getContext().getExternalFilesDir(null);
                    if (sdcardDir != null) {
                        mPresenter.playAudioEffect(1,
                                sdcardDir.getAbsolutePath() + "/trtc_test_effect/clap.aac",
                                mLoopTime,
                                false,
                                mEffectClipSe.getVol());
                    }
                }
            }

            @Override
            public void onUse() {
                if (mPresenter != null) {
                    mPresenter.stopAudioEffect(1);
                    File sdcardDir = getContext().getExternalFilesDir(null);
                    if (sdcardDir != null) {
                        mPresenter.playAudioEffect(1,
                                sdcardDir.getAbsolutePath() + "/trtc_test_effect/clap.aac",
                                mLoopTime,
                                true,
                                mEffectClipSe.getVol());
                    }
                }
            }

            @Override
            public void onVolChange(int gain) {
                mClipVol = gain;
                if (mPresenter != null) {
                    mPresenter.setAudioEffectVolume(1, gain);
                }
            }
        });

        mEffectGiftSe.setCallback(new EffectItemView.Callback() {
            @Override
            public void onPreview() {
                if (mPresenter != null) {
                    mPresenter.stopAudioEffect(2);
                    File sdcardDir = getContext().getExternalFilesDir(null);
                    if (sdcardDir != null) {
                        mPresenter.playAudioEffect(2,
                                sdcardDir.getAbsolutePath() + "/trtc_test_effect/gift_sent.aac",
                                mLoopTime,
                                false,
                                mEffectGiftSe.getVol());
                    }
                }
            }

            @Override
            public void onUse() {
                if (mPresenter != null) {
                    mPresenter.stopAudioEffect(2);
                    File sdcardDir = getContext().getExternalFilesDir(null);
                    if (sdcardDir != null) {
                        mPresenter.playAudioEffect(2,
                                sdcardDir.getAbsolutePath() + "/trtc_test_effect/gift_sent.aac",
                                mLoopTime,
                                true,
                                mEffectGiftSe.getVol());
                    }
                }
            }

            @Override
            public void onVolChange(int gain) {
                mGiftVol = gain;
                if (mPresenter != null) {
                    mPresenter.setAudioEffectVolume(2, gain);
                }
            }
        });

        mAudioVolAllSb.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                mEffectClipSe.setProgress(progress);
                mEffectGiftSe.setProgress(progress);
                mClipVol = progress;
                mGiftVol = progress;
                if (mPresenter != null) {
                    mPresenter.setAllAudioEffectsVolume(progress);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });

        mLoopTimeEt.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                try {
                    mLoopTime = Integer.valueOf(s.toString().trim());
                } catch (Exception e) {
                    mLoopTime = 0;
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });


        mStopAllBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mPresenter != null) {
                    mPresenter.stopAllAudioEffects();
                }
            }
        });
    }

    protected void initView(View view) {
        mStopAllBtn = (Button) view.findViewById(R.id.btn_stop_all);
        mAudioVolAllSb = (SeekBar) view.findViewById(R.id.sb_audio_vol_all);
        mLoopTimeEt = (EditText) view.findViewById(R.id.et_loop_time);
        mEffectClipSe = (EffectItemView) view.findViewById(R.id.se_effect_clip);
        mEffectGiftSe = (EffectItemView) view.findViewById(R.id.se_effect_gift);

        mEffectClipSe.setTitle("鼓掌");
        mEffectClipSe.setProgress(mClipVol);
        mEffectGiftSe.setTitle("礼物");
        mEffectGiftSe.setProgress(mGiftVol);
        mLoopTimeEt.setText(String.valueOf(mLoopTime));
    }

    /**
     * 拷贝音效文件到本地
     */
    public void copyEffectFolder(final Context context) {
        File sdcardDir = context.getExternalFilesDir(null);
        if (sdcardDir == null) {
            Log.e(TAG, "copyEffectFolder sdcardDir is null");
            return;
        }
        final String localPath   = sdcardDir.getAbsolutePath() + "/trtc_test_effect";
        final String assetsPath  = "effect";
        File         musicFolder = new File(localPath);
        if (!musicFolder.exists()) {
            musicFolder.mkdirs();
        }
        if (musicFolder.exists() && musicFolder.isDirectory()) {
            File[] listFiles = musicFolder.listFiles();
            try {
                String[] musicFilePaths = context.getAssets().list(assetsPath);
                // 将musicFiles拷贝到本地
                if (listFiles != null && listFiles.length != musicFilePaths.length) {
                    AsyncTask.execute(new Runnable() {
                        @Override
                        public void run() {
                            Utils.copyFilesFromAssets(context, assetsPath, localPath);
                            Log.i(TAG, "run -> copy effect assets finish.");
                        }
                    });
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public void setPresenter(VoiceRoomContract.IPresenter presenter) {
        mPresenter = presenter;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.voiceroom_fragment_effect;
    }

    @Override
    protected int getHeight(DisplayMetrics dm) {
        return (int) (dm.heightPixels * 0.6);
    }
}
