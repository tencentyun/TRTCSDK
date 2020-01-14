package com.tencent.liteav.demo.trtcvoiceroom.widgets;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.DisplayMetrics;
import android.view.View;
import android.widget.Button;
import android.widget.NumberPicker;

import com.tencent.liteav.demo.trtcvoiceroom.VoiceRoomContract;
import com.tencent.liteav.demo.trtcvoiceroom.R;
import com.tencent.liteav.demo.trtcvoiceroom.model.SettingConfig;
import com.tencent.trtc.TRTCCloudDef;

import java.util.Arrays;
import java.util.List;

public class VoiceChangerSettingFragment extends BaseSettingFragmentDialog {
    // 对应 SDK 的变声列表（TRTCCloudDef中定义）
    private static final List<String>  VOICE_CHANGER_LIST     = Arrays.asList("关闭变声", "熊孩子", "萝莉", "大叔", "重金属", "感冒", "外国人", "困兽", "死肥仔", "强电流", "重机械", "空灵");
    private static final List<Integer> VOICE_CHANGER_TYPE_ARR = Arrays.asList(TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_0,
            TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_1, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_2, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_3,
            TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_4, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_5, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_6,
            TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_7, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_8, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_9,
            TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_10, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_11);

    private VoiceRoomContract.IPresenter mPresenter;
    private NumberPicker                 mVoiceChangePk;
    private Button                       mConfirmBtn;

    public void setPresenter(VoiceRoomContract.IPresenter presenter) {
        mPresenter = presenter;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView(view);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.voiceroom_fragment_voice_changer;
    }

    private void initView(@NonNull final View itemView) {
        mVoiceChangePk = (NumberPicker) itemView.findViewById(R.id.pk_voice_change);
        mConfirmBtn = (Button) itemView.findViewById(R.id.btn_confirm);
        mVoiceChangePk.setMinValue(0);
        mVoiceChangePk.setMaxValue(VOICE_CHANGER_LIST.size() - 1);
        mVoiceChangePk.setWrapSelectorWheel(false);
        mVoiceChangePk.setDisplayedValues(VOICE_CHANGER_LIST.toArray(new String[0]));

        mVoiceChangePk.setOnValueChangedListener(new NumberPicker.OnValueChangeListener() {
            @Override
            public void onValueChange(NumberPicker picker, int oldVal, int newVal) {
                int index = mVoiceChangePk.getValue();
                if (mPresenter != null && index >= 0 && index < VOICE_CHANGER_TYPE_ARR.size()) {
                    SettingConfig.getInstance().mVoiceChangerIndex = index;
                    mPresenter.setVoiceChanger(VOICE_CHANGER_TYPE_ARR.get(index), VOICE_CHANGER_LIST.get(index));
                }
            }
        });

        mConfirmBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });

        updateView();
    }

    private void updateView() {
        int index = SettingConfig.getInstance().mVoiceChangerIndex;
        mVoiceChangePk.setValue(index);
    }

    @Override
    protected int getHeight(DisplayMetrics dm) {
        return (int) (dm.heightPixels * 0.4);
    }
}
