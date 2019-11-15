package com.tencent.liteav.demo.trtc.widget.feature;

import android.util.TypedValue;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;

import com.blankj.utilcode.util.SizeUtils;
import com.tencent.liteav.demo.R;
import com.tencent.liteav.demo.trtc.sdkadapter.ConfigHelper;
import com.tencent.liteav.demo.trtc.sdkadapter.feature.AudioConfig;
import com.tencent.liteav.demo.trtc.widget.BaseSettingFragment;
import com.tencent.liteav.demo.trtc.widget.settingitem.BaseSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.CheckBoxSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.CustomSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.RadioButtonSettingItem;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.List;

/**
 * 音频相关的设置页
 *
 * @author guanyifeng
 */
public class AudioSettingFragment extends BaseSettingFragment {
    private LinearLayout           mContentItem;
    private List<BaseSettingItem>  mSettingItemList;
    private RadioButtonSettingItem mAudioSampleRateItem;
    private RadioButtonSettingItem mAudioVolumeTypeItem;
    private CheckBoxSettingItem    mAGCItem;
    private CheckBoxSettingItem    mANSItem;
    private CheckBoxSettingItem    mAudioCaptureItem;
    private CheckBoxSettingItem    mAudioEarMonitoringItem;
    private CheckBoxSettingItem    mAudioHandFreeModeItem;
    private CheckBoxSettingItem    mAudioVolumeEvaluationItem;
    private AudioConfig            mAudioConfig;
    private CustomSettingItem      mRecordItem;

    @Override
    protected void initView(View itemView) {
        mContentItem = (LinearLayout) itemView.findViewById(R.id.item_content);
        mSettingItemList = new ArrayList<>();
        mAudioConfig = ConfigHelper.getInstance().getAudioConfig();
        BaseSettingItem.ItemText itemText =
                new BaseSettingItem.ItemText("音频采样率", "48K", "16K");
        mAudioSampleRateItem = new RadioButtonSettingItem(getContext(), itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                        mAudioConfig.setEnable16KSampleRate(index == 1);
                        mTRTCCloudManager.enable16KSampleRate(mAudioConfig.isEnable16KSampleRate());
                    }
                });
        mSettingItemList.add(mAudioSampleRateItem);
        itemText =
                new BaseSettingItem.ItemText("音量类型", "自动模式", "媒体音量");
        mAudioVolumeTypeItem = new RadioButtonSettingItem(getContext(), itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                        mAudioConfig.setAudioVolumeType(
                                mAudioVolumeTypeItem.getSelected() == 0 ?
                                        TRTCCloudDef.TRTCSystemVolumeTypeAuto : TRTCCloudDef.TRTCSystemVolumeTypeMedia
                        );
                        mTRTCCloudManager.setSystemVolumeType(mAudioConfig.getAudioVolumeType());
                    }
                });
        mSettingItemList.add(mAudioVolumeTypeItem);

        itemText =
                new BaseSettingItem.ItemText("自动增益", "");
        mAGCItem = new CheckBoxSettingItem(getContext(), itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        mAudioConfig.setAGC(mAGCItem.getChecked());
                        mTRTCCloudManager.enableAGC(mAudioConfig.isAGC());
                    }
                });
        mSettingItemList.add(mAGCItem);

        itemText =
                new BaseSettingItem.ItemText("噪音消除", "");
        mANSItem = new CheckBoxSettingItem(getContext(), itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        mAudioConfig.setANS(mANSItem.getChecked());
                        mTRTCCloudManager.enableANS(mAudioConfig.isANS());
                    }
                });
        mSettingItemList.add(mANSItem);

        itemText =
                new BaseSettingItem.ItemText("声音采集", "");
        mAudioCaptureItem = new CheckBoxSettingItem(getContext(), itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        mAudioConfig.setEnableAudio(mAudioCaptureItem.getChecked());
                        mTRTCCloudManager.muteLocalAudio(!mAudioCaptureItem.getChecked());
                    }
                });
        mSettingItemList.add(mAudioCaptureItem);

        //耳返设置入口
        itemText =
                new BaseSettingItem.ItemText("声音耳返", "");
        mAudioEarMonitoringItem = new CheckBoxSettingItem(getContext(), itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        mAudioConfig.setEnableEarMonitoring(mAudioEarMonitoringItem.getChecked());
                        mTRTCCloudManager.enableEarMonitoring(mAudioEarMonitoringItem.getChecked());
                    }
                });
        mSettingItemList.add(mAudioEarMonitoringItem);

        itemText =
                new BaseSettingItem.ItemText("免提模式", "");
        mAudioHandFreeModeItem = new CheckBoxSettingItem(getContext(), itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        mAudioConfig.setAudioHandFreeMode(mAudioHandFreeModeItem.getChecked());
                        mTRTCCloudManager.enableAudioHandFree(mAudioConfig.isAudioHandFreeMode());
                    }
                });
        mSettingItemList.add(mAudioHandFreeModeItem);

        itemText =
                new BaseSettingItem.ItemText("音量提示", "");
        mAudioVolumeEvaluationItem = new CheckBoxSettingItem(getContext(), itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        mAudioConfig.setAudioVolumeEvaluation(mAudioVolumeEvaluationItem.getChecked());
                        mTRTCCloudManager.enableAudioVolumeEvaluation(mAudioConfig.isAudioVolumeEvaluation());
                    }
                });
        mSettingItemList.add(mAudioVolumeEvaluationItem);

        itemText =
                new BaseSettingItem.ItemText("音频录制", "");
        mRecordItem = new CustomSettingItem(getContext(), itemText, createAudioRecordButton());
        mRecordItem.setAlign(CustomSettingItem.ALIGN_RIGHT);
        mSettingItemList.add(mRecordItem);

        updateItem();

        // 将这些view添加到对应的容器中
        for (BaseSettingItem item : mSettingItemList) {
            View view = item.getView();
            view.setPadding(0, SizeUtils.dp2px(5), 0, 0);
            mContentItem.addView(view);
        }
    }

    private List<View> createAudioRecordButton() {
        List<View>   views  = new ArrayList<>();
        final Button button = new Button(getContext());
        if (!mAudioConfig.isRecording()) {
            button.setText("开始录制");
        } else {
            button.setText("结束录制");
        }
        button.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // 这里开始录制进行操作
                if (!mAudioConfig.isRecording()) {
                    if (mTRTCCloudManager.startRecord()) {
                        button.setText("结束录制");
                    }
                } else {
                    mTRTCCloudManager.stopRecord();
                    button.setText("开始录制");
                }
            }
        });
        views.add(button);
        return views;
    }

    @Override
    public void onPause() {
        super.onPause();
        mAudioConfig.saveCache();
    }

    private void updateItem() {
        mAudioSampleRateItem.setSelect(mAudioConfig.isEnable16KSampleRate() ? 1 : 0);
        mAudioVolumeTypeItem.setSelect(mAudioConfig.getAudioVolumeType() == TRTCCloudDef.TRTCSystemVolumeTypeAuto ? 0 : 1);
        mAGCItem.setCheck(mAudioConfig.isAGC());
        mANSItem.setCheck(mAudioConfig.isANS());
        mAudioCaptureItem.setCheck(mAudioConfig.isEnableAudio());
        mAudioEarMonitoringItem.setCheck(mAudioConfig.isEnableEarMonitoring());
        mAudioHandFreeModeItem.setCheck(mAudioConfig.isAudioHandFreeMode());
        mAudioVolumeEvaluationItem.setCheck(mAudioConfig.isAudioVolumeEvaluation());
    }

    @Override
    protected int getLayoutId() {
        return R.layout.trtc_fragment_confirm_setting;
    }
}
