package com.tencent.liteav.demo.trtcvoiceroom.widgets;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.view.View;
import android.widget.Button;
import android.widget.NumberPicker;

import com.tencent.liteav.demo.trtcvoiceroom.VoiceRoomContract;
import com.tencent.liteav.demo.trtcvoiceroom.R;
import com.tencent.liteav.demo.trtcvoiceroom.model.SettingConfig;
import com.tencent.trtc.TRTCCloudDef;

import java.util.Arrays;
import java.util.List;

public class MoreSettingFragment extends BaseSettingFragmentDialog {
    // 对应 SDK 的混响列表（TRTCCloudDef中定义）
    private static final List<String>  REVERB_LIST     = Arrays.asList("关闭混响", "KTV", "小房间", "大会堂", "低沉", "洪亮", "金属声", "磁性");
    private static final List<Integer> REVERB_TYPE_ARR = Arrays.asList(TRTCCloudDef.TRTC_REVERB_TYPE_0,
            TRTCCloudDef.TRTC_REVERB_TYPE_1, TRTCCloudDef.TRTC_REVERB_TYPE_2, TRTCCloudDef.TRTC_REVERB_TYPE_3,
            TRTCCloudDef.TRTC_REVERB_TYPE_4, TRTCCloudDef.TRTC_REVERB_TYPE_5, TRTCCloudDef.TRTC_REVERB_TYPE_6, TRTCCloudDef.TRTC_REVERB_TYPE_7);

    private VoiceRoomContract.IPresenter mPresenter;

    private NumberPicker mReverbPk;
    private Button       mConfirmBtn;

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView(view);
        initListener();
        updateView();
    }

    private void updateView() {
        SettingConfig config = SettingConfig.getInstance();
        mReverbPk.setValue(config.mReverbIndex);
    }

    private void initListener() {
    }

    @Override
    protected int getLayoutId() {
        return R.layout.voiceroom_fragment_more;
    }

    private void initView(@NonNull final View itemView) {
        mReverbPk = (NumberPicker) itemView.findViewById(R.id.pk_reverb);
        mConfirmBtn = (Button) itemView.findViewById(R.id.btn_confirm);

        mReverbPk.setMinValue(0);
        mReverbPk.setMaxValue(REVERB_LIST.size() - 1);
        mReverbPk.setWrapSelectorWheel(false);
        mReverbPk.setDisplayedValues(REVERB_LIST.toArray(new String[0]));

        mReverbPk.setOnValueChangedListener(new NumberPicker.OnValueChangeListener() {
            @Override
            public void onValueChange(NumberPicker picker, int oldVal, int newVal) {
                int index = mReverbPk.getValue();
                if (mPresenter != null && index >= 0 && index < REVERB_TYPE_ARR.size()) {
                    SettingConfig.getInstance().mReverbIndex = index;
                    mPresenter.setReverbType(REVERB_TYPE_ARR.get(index), REVERB_LIST.get(index));
                }
            }
        });

        mConfirmBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });

    }

    public void setPresenter(VoiceRoomContract.IPresenter presenter) {
        mPresenter = presenter;
    }
}
