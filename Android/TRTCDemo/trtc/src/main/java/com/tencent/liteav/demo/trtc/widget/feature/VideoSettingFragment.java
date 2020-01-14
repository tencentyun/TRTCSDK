package com.tencent.liteav.demo.trtc.widget.feature;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;

import com.blankj.utilcode.util.SizeUtils;
import com.tencent.liteav.demo.trtc.R;
import com.tencent.liteav.demo.trtc.sdkadapter.ConfigHelper;
import com.tencent.liteav.demo.trtc.sdkadapter.feature.VideoConfig;
import com.tencent.liteav.demo.trtc.widget.BaseSettingFragment;
import com.tencent.liteav.demo.trtc.widget.settingitem.BaseSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.CheckBoxSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.CustomSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.RadioButtonSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.SeekBarSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.SelectionSettingItem;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.List;

import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO;
import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_DISABLE;
import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE;
import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_ROTATION_0;
import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_ROTATION_270;
import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_ROTATION_90;

/**
 * 视频设置页
 *
 * @author guanyifeng
 */
public class VideoSettingFragment extends BaseSettingFragment {
    private static final String                 TAG = VideoSettingFragment.class.getName();
    /**
     * 界面相关
     */
    private              LinearLayout           mContentItem;
    private              List<BaseSettingItem>  mSettingItemList;
    private              SeekBarSettingItem     mBitrateItem;
    private              SelectionSettingItem   mResolutionItem;
    private              SelectionSettingItem   mVideoFpsItem;
    private              RadioButtonSettingItem mQosPreferenceItem;
    private              RadioButtonSettingItem mVideoVerticalItem;
    private              RadioButtonSettingItem mVideoFillModeItem;
    private              RadioButtonSettingItem mMirrorTypeItem;
    private              CheckBoxSettingItem    mAutoStartCapItem;
    private              RadioButtonSettingItem mRotationItem;
    private              CheckBoxSettingItem    mRemoteMirrorItem;
    private              CheckBoxSettingItem    mWatermark;
    private              CheckBoxSettingItem    publishVideoItem;

    private VideoConfig                        mVideoConfig;
    private ArrayList<TRTCSettingBitrateTable> paramArray;
    private int                                mAppScene = TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL;
    private int                                mCurRes;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initData();
    }


    private void initData() {
        boolean isVideoCall = mAppScene == TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL;
        paramArray = new ArrayList<>();
        paramArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_160_160, isVideoCall ? 250 : 300, 40, 300, 10));
        paramArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_320_180, isVideoCall ? 350 : 350, 80, 350, 10));
        paramArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_320_240, isVideoCall ? 400 : 400, 100, 400, 10));
        paramArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_480_480, isVideoCall ? 500 : 750, 200, 1000, 10));
        paramArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360, isVideoCall ? 600 : 900, 200, 1000, 10));
        paramArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_480, isVideoCall ? 700 : 1000, 250, 1000, 50));
        paramArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540, isVideoCall ? 900 : 1350, 400, 1600, 50));
        paramArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720, isVideoCall ? 1250 : 1850, 500, 2000, 50));
        paramArray.add(new TRTCSettingBitrateTable(114, isVideoCall ? 1900 : 1900, 800, 3000, 50));
    }

    @Override
    protected void initView(View itemView) {
        mContentItem = (LinearLayout) itemView.findViewById(R.id.item_content);
        mSettingItemList = new ArrayList<>();
        mVideoConfig = ConfigHelper.getInstance().getVideoConfig();

        /**
         * 界面中的码率会和选择的分辨率\帧率相关，在选择对应的分辨率之后，要设置对应的码率
         * 所以要在一开始先初始化码率的item，不然会出现null的情况
         */
        BaseSettingItem.ItemText itemText =
                new BaseSettingItem.ItemText("码率", "");
        mBitrateItem = new SeekBarSettingItem(getContext(), itemText, new SeekBarSettingItem.Listener() {
            @Override
            public void onSeekBarChange(int progress, boolean fromUser) {
                int bitrate = getBitrate(progress, mCurRes);
                mBitrateItem.setTips(bitrate + "kbps");
                if (bitrate != mVideoConfig.getVideoBitrate()) {
                    mVideoConfig.setVideoBitrate(bitrate);
                    mTRTCCloudManager.setTRTCCloudParam();
                }
            }
        });

        // 分辨率相关
        mCurRes = getResolutionPos(mVideoConfig.getVideoResolution());
        itemText =
                new BaseSettingItem.ItemText("分辨率", getResources().getStringArray(R.array.solution));
        mResolutionItem = new SelectionSettingItem(getContext(), itemText,
                new SelectionSettingItem.Listener() {
                    @Override
                    public void onItemSelected(int position, String text) {
                        mCurRes = position;
                        updateSolution(mCurRes);
                        int resolution = getResolution(mResolutionItem.getSelected());
                        if (resolution != mVideoConfig.getVideoResolution()) {
                            mVideoConfig.setVideoResolution(resolution);
                            mTRTCCloudManager.setTRTCCloudParam();
                        }
                    }
                }
        ).setSelect(mCurRes);
        mSettingItemList.add(mResolutionItem);

        //帧率
        itemText = new BaseSettingItem.ItemText("帧率", getResources().getStringArray(R.array.video_fps));
        mVideoFpsItem = new SelectionSettingItem(getContext(), itemText,
                new SelectionSettingItem.Listener() {
                    @Override
                    public void onItemSelected(int position, String text) {
                        int fps = getFps(position);
                        if (fps != mVideoConfig.getVideoFps()) {
                            mVideoConfig.setVideoFps(fps);
                            mTRTCCloudManager.setTRTCCloudParam();
                        }
                    }
                }
        ).setSelect(getFpsPos(mVideoConfig.getVideoFps()));
        mSettingItemList.add(mVideoFpsItem);

        /**
         * 这里更新码率的界面并且加入到ItemList中
         */
        updateSolution(mCurRes);
        mBitrateItem.setProgress(getBitrateProgress(mVideoConfig.getVideoBitrate(), mCurRes));
        mBitrateItem.setTips(getBitrate(mVideoConfig.getVideoBitrate(), mCurRes) + "kbps");
        mSettingItemList.add(mBitrateItem);

        //画质偏好
        itemText =
                new BaseSettingItem.ItemText("画质偏好", "优先流畅", "优先清晰");
        mQosPreferenceItem = new RadioButtonSettingItem(getContext(), itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                        mVideoConfig.setQosPreference(index == 0 ?
                                TRTCCloudDef.TRTC_VIDEO_QOS_PREFERENCE_SMOOTH : TRTCCloudDef.TRTC_VIDEO_QOS_PREFERENCE_CLEAR);
                        mTRTCCloudManager.setQosParam();
                    }
                });
        mSettingItemList.add(mQosPreferenceItem);
        //画质方向
        itemText =
                new BaseSettingItem.ItemText("画面方向", "横屏模式", "竖屏模式");
        mVideoVerticalItem = new RadioButtonSettingItem(getContext(), itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                        mVideoConfig.setVideoVertical(index == 1);
                        mTRTCCloudManager.setTRTCCloudParam();

                    }
                });
        mSettingItemList.add(mVideoVerticalItem);
        //画面填充方向
        itemText =
                new BaseSettingItem.ItemText("画面填充方向", "充满", "适应");
        mVideoFillModeItem = new RadioButtonSettingItem(getContext(), itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                        mVideoConfig.setVideoFillMode(index == 0);
                        mTRTCCloudManager.setVideoFillMode(mVideoConfig.isVideoFillMode());
                    }
                });
        mSettingItemList.add(mVideoFillModeItem);

        itemText =
                new BaseSettingItem.ItemText("本地预览镜像", "auto", "开启", "关闭");
        mMirrorTypeItem = new RadioButtonSettingItem(getContext(), itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                        int type;
                        if (index == 0) {
                            //自动
                            type = TRTC_VIDEO_MIRROR_TYPE_AUTO;
                        } else if (mMirrorTypeItem.getSelected() == 1) {
                            type = TRTC_VIDEO_MIRROR_TYPE_ENABLE;
                        } else {
                            type = TRTC_VIDEO_MIRROR_TYPE_DISABLE;
                        }
                        mVideoConfig.setMirrorType(type);
                        mTRTCCloudManager.setLocalViewMirror(mVideoConfig.getMirrorType());
                    }
                });
        mSettingItemList.add(mMirrorTypeItem);

        itemText =
                new BaseSettingItem.ItemText("本地画面旋转", "0", "90", "270");
        mRotationItem = new RadioButtonSettingItem(getContext(), itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                        int rotation = TRTC_VIDEO_ROTATION_0;
                        if (index == 1) {
                            rotation = TRTC_VIDEO_ROTATION_90;
                        } else if (index == 2) {
                            rotation = TRTC_VIDEO_ROTATION_270;
                        }
                        mVideoConfig.setLocalRotation(rotation);
                        mTRTCCloudManager.setLocalVideoRotation(mVideoConfig.getLocalRotation());
                    }
                });
        mSettingItemList.add(mRotationItem);

        itemText =
                new BaseSettingItem.ItemText("开启视频采集", "");
        mAutoStartCapItem = new CheckBoxSettingItem(getContext(), itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        mVideoConfig.setEnableVideo(mAutoStartCapItem.getChecked());
                        if (mVideoConfig.isEnableVideo()) {
                            mTRTCCloudManager.startLocalPreview();
                        } else {
                            mTRTCCloudManager.stopLocalPreview();
                        }
                    }
                });
        mSettingItemList.add(mAutoStartCapItem);

        itemText =
                new BaseSettingItem.ItemText("推送视频", "");
        publishVideoItem = new CheckBoxSettingItem(getContext(), itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        mVideoConfig.setPublishVideo(publishVideoItem.getChecked());
                        mTRTCCloudManager.muteLocalVideo(!mVideoConfig.isPublishVideo());
                    }
                });
        mSettingItemList.add(publishVideoItem);

        itemText =
                new BaseSettingItem.ItemText("开启远程镜像", "");
        mRemoteMirrorItem = new CheckBoxSettingItem(getContext(), itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        mVideoConfig.setRemoteMirror(mRemoteMirrorItem.getChecked());
                        mTRTCCloudManager.enableVideoEncMirror(mVideoConfig.isRemoteMirror());
                    }
                });
        mSettingItemList.add(mRemoteMirrorItem);

        itemText =
                new BaseSettingItem.ItemText("开启视频水印", "");
        mWatermark = new CheckBoxSettingItem(getContext(), itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        mVideoConfig.setWatermark(mWatermark.getChecked());
                        mTRTCCloudManager.enableWatermark(mVideoConfig.isWatermark());
                    }
                });
        mSettingItemList.add(mWatermark);

        itemText =
                new BaseSettingItem.ItemText("本地视频截图", "");
        CustomSettingItem snapshotItem = new CustomSettingItem(getContext(), itemText, createSnapshotButton());
        snapshotItem.setAlign(CustomSettingItem.ALIGN_RIGHT);
        mSettingItemList.add(snapshotItem);

        updateItem();

        // 将这些view添加到对应的容器中
        for (BaseSettingItem item : mSettingItemList) {
            View view = item.getView();
            view.setPadding(0, SizeUtils.dp2px(8), 0, 0);
            mContentItem.addView(view);
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        mVideoConfig.saveCache();
    }

    private List<View> createSnapshotButton() {
        List<View>   views  = new ArrayList<>();
        final Button button = new Button(getContext());
        button.setText("截图");

        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCloudManager.snapshotLocalView();
            }
        });
        views.add(button);
        return views;
    }

    private void updateItem() {
        mQosPreferenceItem.setSelect(
                mVideoConfig.getQosPreference() == TRTCCloudDef.TRTC_VIDEO_QOS_PREFERENCE_SMOOTH ? 0 : 1);
        mVideoVerticalItem.setSelect(mVideoConfig.isVideoVertical() ? 1 : 0);
        mVideoFillModeItem.setSelect(mVideoConfig.isVideoFillMode() ? 0 : 1);
        int index = 0;
        int type  = mVideoConfig.getMirrorType();
        if (TRTC_VIDEO_MIRROR_TYPE_AUTO == type) {
            index = 0;
        } else if (TRTC_VIDEO_MIRROR_TYPE_ENABLE == type) {
            index = 1;
        } else {
            index = 2;
        }
        mMirrorTypeItem.setSelect(index);
        int rotation = mVideoConfig.getLocalRotation();
        if (TRTC_VIDEO_ROTATION_0 == rotation) {
            index = 0;
        } else if (TRTC_VIDEO_ROTATION_90 == rotation) {
            index = 1;
        } else {
            index = 2;
        }
        mRotationItem.setSelect(index);
        mAutoStartCapItem.setCheck(mVideoConfig.isEnableVideo());
        mRemoteMirrorItem.setCheck(mVideoConfig.isRemoteMirror());
        publishVideoItem.setCheck(mVideoConfig.isPublishVideo());
        mWatermark.setCheck(mVideoConfig.isWatermark());
    }

    @Override
    protected int getLayoutId() {
        return R.layout.trtc_fragment_confirm_setting;
    }


    private void updateSolution(int pos) {
        int minBitrate = getMinBitrate(pos);
        int maxBitrate = getMaxBitrate(pos);

        int stepBitrate = getStepBitrate(pos);
        int max         = (maxBitrate - minBitrate) / stepBitrate;
        if (mBitrateItem.getMax() != max) {    // 有变更时设置默认值
            mBitrateItem.setMax(max);
            int defBitrate = getDefBitrate(pos);
            mBitrateItem.setProgress(getBitrateProgress(defBitrate, pos));
        } else {
            mBitrateItem.setMax(max);
        }
    }

    private int getResolutionPos(int resolution) {
        for (int i = 0; i < paramArray.size(); i++) {
            if (resolution == (paramArray.get(i).resolution)) {
                return i;
            }
        }
        return 4;
    }

    private int getResolution(int pos) {
        if (pos >= 0 && pos < paramArray.size()) {
            return paramArray.get(pos).resolution;
        }
        return TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360;
    }

    private int getFpsPos(int fps) {
        switch (fps) {
            case 15:
                return 0;
            case 20:
                return 1;
            default:
                return 0;
        }
    }

    private int getFps(int pos) {
        switch (pos) {
            case 0:
                return 15;
            case 1:
                return 20;
            default:
                return 15;
        }
    }

    private int getMinBitrate(int pos) {
        if (pos >= 0 && pos < paramArray.size()) {
            return paramArray.get(pos).minBitrate;
        }
        return 300;
    }

    private int getMaxBitrate(int pos) {
        if (pos >= 0 && pos < paramArray.size()) {
            return paramArray.get(pos).maxBitrate;
        }
        return 1000;
    }

    private int getDefBitrate(int pos) {
        if (pos >= 0 && pos < paramArray.size()) {
            return paramArray.get(pos).defaultBitrate;
        }
        return 400;
    }

    /**
     * 获取当前精度
     */
    private int getStepBitrate(int pos) {
        if (pos >= 0 && pos < paramArray.size()) {
            return paramArray.get(pos).step;
        }
        return 10;
    }

    private int getBitrateProgress(int bitrate, int pos) {
        int minBitrate  = getMinBitrate(pos);
        int stepBitrate = getStepBitrate(pos);

        int progress = (bitrate - minBitrate) / stepBitrate;
        Log.i(TAG, "getBitrateProgress->progress: " + progress + ", min: " + minBitrate + ", stepBitrate: " + stepBitrate + "/" + bitrate);
        return progress;
    }

    private int getBitrate(int progress, int pos) {
        int minBitrate  = getMinBitrate(pos);
        int maxBitrate  = getMaxBitrate(pos);
        int stepBitrate = getStepBitrate(pos);
        int bit         = (progress * stepBitrate) + minBitrate;
        Log.i(TAG, "getBitrate->bit: " + bit + ", min: " + minBitrate + ", max: " + maxBitrate);
        return bit;
    }

    static class TRTCSettingBitrateTable {
        public int resolution;
        public int defaultBitrate;
        public int minBitrate;
        public int maxBitrate;
        public int step;

        public TRTCSettingBitrateTable(int resolution, int defaultBitrate, int minBitrate, int maxBitrate, int step) {
            this.resolution = resolution;
            this.defaultBitrate = defaultBitrate;
            this.minBitrate = minBitrate;
            this.maxBitrate = maxBitrate;
            this.step = step;
        }
    }
}
