package com.tencent.liteav.meeting.ui.widget.feature;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.support.v4.content.LocalBroadcastManager;
import android.util.TypedValue;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.blankj.utilcode.util.SizeUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.demo.trtc.R;
import com.tencent.liteav.meeting.ui.widget.base.BaseSettingFragment;
import com.tencent.liteav.meeting.ui.widget.settingitem.BaseSettingItem;
import com.tencent.liteav.meeting.ui.widget.settingitem.CustomSettingItem;
import com.tencent.liteav.meeting.ui.widget.settingitem.SeekBarSettingItem;
import com.tencent.liteav.meeting.ui.widget.settingitem.SwitchSettingItem;
import com.tencent.trtc.TRTCCloudDef;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * 音频相关的设置页
 *
 * @author guanyifeng
 */
public class AudioSettingFragment extends BaseSettingFragment {
    private LinearLayout          mContentItem;
    private List<BaseSettingItem> mSettingItemList;
    private SwitchSettingItem     mAudioVolumeEvaluationItem;
    private CustomSettingItem     mRecordItem;
    private FeatureConfig         mFeatureConfig;
    private String                mRecordFilePath;

    @Override
    protected void initView(View itemView) {
        mContentItem = (LinearLayout) itemView.findViewById(R.id.item_content);
        mSettingItemList = new ArrayList<>();
        mFeatureConfig = FeatureConfig.getInstance();
        mRecordFilePath = getRecordFilePath();

        BaseSettingItem.ItemText itemText =
                new BaseSettingItem.ItemText(getString(R.string.meeting_title_collection_volume), "");
        mSettingItemList.add(new SeekBarSettingItem(getContext(), itemText, new SeekBarSettingItem.Listener() {
            @Override
            public void onSeekBarChange(int progress, boolean fromUser) {
                mFeatureConfig.setMicVolume(progress);
                mTRTCMeeting.setAudioCaptureVolume(progress);
            }
        }).setProgress(mFeatureConfig.getMicVolume()));

        itemText =
                new BaseSettingItem.ItemText(getString(R.string.meeting_title_play_volume), "");
        mSettingItemList.add(new SeekBarSettingItem(getContext(), itemText, new SeekBarSettingItem.Listener() {
            @Override
            public void onSeekBarChange(int progress, boolean fromUser) {
                mFeatureConfig.setPlayoutVolume(progress);
                mTRTCMeeting.setAudioPlayoutVolume(progress);
            }
        }).setProgress(mFeatureConfig.getPlayoutVolume()));

        itemText =
                new BaseSettingItem.ItemText(getString(R.string.meeting_title_volume_reminder), "");
        mAudioVolumeEvaluationItem = new SwitchSettingItem(getContext(), itemText, new SwitchSettingItem.Listener() {
            @Override
            public void onSwitchChecked(boolean isChecked) {
                mFeatureConfig.setAudioVolumeEvaluation(isChecked);
                mTRTCMeeting.enableAudioEvaluation(isChecked);
                Intent intent = new Intent(FeatureConfig.AUDIO_EVALUATION_CHANGED);
                LocalBroadcastManager.getInstance(getActivity()).sendBroadcast(intent);

            }
        }).setCheck(mFeatureConfig.isAudioVolumeEvaluation());
        mSettingItemList.add(mAudioVolumeEvaluationItem);

        itemText =
                new BaseSettingItem.ItemText(getString(R.string.meeting_title_audio_recording), "");
        mRecordItem = new CustomSettingItem(getContext(), itemText, createAudioRecordButton());
        mRecordItem.setAlign(CustomSettingItem.ALIGN_RIGHT);
        mSettingItemList.add(mRecordItem);

        updateItem();

        // 将这些view添加到对应的容器中
        for (BaseSettingItem item : mSettingItemList) {
            View view = item.getView();
            view.setPadding(0, SizeUtils.dp2px(15), 0, 0);
            mContentItem.addView(view);
        }
    }

    private List<View> createAudioRecordButton() {
        List<View>     views  = new ArrayList<>();
        final TextView button = new TextView(getContext());
        if (!mFeatureConfig.isRecording()) {
            button.setText(getString(R.string.meeting_btn_start_recording));
        } else {
            button.setText(getString(R.string.meeting_btn_stop_recording));
        }
        button.setPadding(SizeUtils.dp2px(12), SizeUtils.dp2px(4), SizeUtils.dp2px(12), SizeUtils.dp2px(4));
        button.setBackgroundResource(R.drawable.meeting_button_border);
        button.setTextColor(getResources().getColor(R.color.meeting_color_white));

        button.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // 这里开始录制进行操作
                if (!mFeatureConfig.isRecording()) {
                    mFeatureConfig.setRecording(true);
                    createFile(mRecordFilePath);
                    TRTCCloudDef.TRTCAudioRecordingParams params = new TRTCCloudDef.TRTCAudioRecordingParams();
                    params.filePath = mRecordFilePath;
                    mTRTCMeeting.startFileDumping(params);
                    button.setText(getString(R.string.meeting_btn_end_recording));
                } else {
                    mTRTCMeeting.stopFileDumping();
                    mFeatureConfig.setRecording(false);
                    button.setText(getString(R.string.meeting_btn_start_recording));
                    ToastUtils.showLong(getString(R.string.meeting_toast_recording_file_path_copied, mRecordFilePath));
                    ClipboardManager cm = (ClipboardManager) getActivity().getSystemService(Context.CLIPBOARD_SERVICE);
                    if(cm != null) {
                        ClipData mClipData = ClipData.newPlainText("path", mRecordFilePath);
                        cm.setPrimaryClip(mClipData);
                    }
                }
            }
        });
        views.add(button);
        return views;
    }

    private String getRecordFilePath() {
        File sdcardDir = getActivity().getExternalFilesDir(null);
        if (sdcardDir == null) {
            return null;
        }

        String dirPath = sdcardDir.getAbsolutePath() + "/test/record/";
        File   dir     = new File(dirPath);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        File file = new File(dir, "record.aac");

        return file.getAbsolutePath();
    }

    private void createFile(String path) {
        File file = new File(path);
        try {
            file.delete();
            file.createNewFile();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
    }

    private void updateItem() {
    }

    @Override
    protected int getLayoutId() {
        return R.layout.meeting_fragment_common_setting;
    }
}
