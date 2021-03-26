package com.tencent.liteav.audiosettingkit;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomSheetDialog;
import android.view.Window;

import com.tencent.liteav.audio.TXAudioEffectManager;

public class AudioEffectDialog extends BottomSheetDialog {

    private AudioEffectPanel mAudioEffectPanel;

    public AudioEffectDialog(@NonNull Context context) {
        super(context);
        initialize(context);
    }

    @Override
    public void show() {
        super.show();
        mAudioEffectPanel.showAudioPanel();
    }

    @Override
    public void cancel() {
        super.cancel();
        mAudioEffectPanel.hideAudioPanel();
    }

    @Override
    public void dismiss() {
        super.dismiss();
        mAudioEffectPanel.hideAudioPanel();
    }

    private void initialize(Context context) {
        mAudioEffectPanel = new AudioEffectPanel(context);
        setContentView(mAudioEffectPanel);
        Window window = getWindow();
        if (window != null) {
            window.findViewById(R.id.design_bottom_sheet).setBackgroundResource(android.R.color.transparent);
        }
    }

    public void setAudioEffectManager(TXAudioEffectManager audioEffectManager) {
        mAudioEffectPanel.setAudioEffectManager(audioEffectManager);
    }

    public void setOnAudioEffectPanelHideListener(AudioEffectPanel.OnAudioEffectPanelHideListener listener) {
        mAudioEffectPanel.setOnAudioEffectPanelHideListener(listener);
    }

    public void setBackgroundColor(int color) {
        mAudioEffectPanel.setBackgroundColor(color);
    }

    public void reset() {
        mAudioEffectPanel.reset();
    }

    public void unInit() {
        mAudioEffectPanel.unInit();
    }
}
