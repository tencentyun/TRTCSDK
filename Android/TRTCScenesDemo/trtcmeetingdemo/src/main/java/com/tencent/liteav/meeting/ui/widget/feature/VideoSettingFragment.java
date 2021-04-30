package com.tencent.liteav.meeting.ui.widget.feature;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.View;
import android.widget.LinearLayout;

import com.blankj.utilcode.util.SizeUtils;
import com.tencent.liteav.demo.trtc.R;
import com.tencent.liteav.meeting.ui.widget.base.BaseSettingFragment;
import com.tencent.liteav.meeting.ui.widget.settingitem.BaseSettingItem;
import com.tencent.liteav.meeting.ui.widget.settingitem.SeekBarSettingItem;
import com.tencent.liteav.meeting.ui.widget.settingitem.SelectionSettingItem;
import com.tencent.liteav.meeting.ui.widget.settingitem.SwitchSettingItem;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.List;

/**
 * 视频设置页
 *
 * @author guanyifeng
 */
public class VideoSettingFragment extends BaseSettingFragment {
    private static final String                TAG = VideoSettingFragment.class.getName();
    /**
     * 界面相关
     */
    private              LinearLayout          mContentItem;
    private              List<BaseSettingItem> mSettingItemList;
    private              SelectionSettingItem  mResolutionItem;
    private              SelectionSettingItem  mVideoFpsItem;
    private              SeekBarSettingItem    mBitrateItem;
    private              SwitchSettingItem     mMirrorTypeItem;

    private ArrayList<TRTCSettingBitrateTable> paramArray;
    private int                                mAppScene = TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL;
    private int                                mCurRes;
    private FeatureConfig                      mFeatureConfig;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initData();
    }


    private void initData() {
        boolean isVideoCall = mAppScene == TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL;
        paramArray = new ArrayList<>();
        paramArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_320_180, isVideoCall ? 350 : 350, 80, 350, 10));
        paramArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_480_270, isVideoCall ? 500 : 750, 200, 1000, 10));
        paramArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360, isVideoCall ? 600 : 900, 200, 1000, 10));
        paramArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540, isVideoCall ? 900 : 1350, 400, 1600, 50));
        paramArray.add(new TRTCSettingBitrateTable(TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720, isVideoCall ? 1250 : 1850, 500, 2000, 50));
    }

    @Override
    protected void initView(View itemView) {
        mContentItem = (LinearLayout) itemView.findViewById(R.id.item_content);
        mSettingItemList = new ArrayList<>();
        mFeatureConfig = FeatureConfig.getInstance();
        /**
         * 界面中的码率会和选择的分辨率\帧率相关，在选择对应的分辨率之后，要设置对应的码率
         * 所以要在一开始先初始化码率的item，不然会出现null的情况
         */
        BaseSettingItem.ItemText itemText =
                new BaseSettingItem.ItemText(getString(R.string.meeting_title_bitrate), "");
        mBitrateItem = new SeekBarSettingItem(getContext(), itemText, new SeekBarSettingItem.Listener() {
            @Override
            public void onSeekBarChange(int progress, boolean fromUser) {
                int bitrate = getBitrate(progress, mCurRes);
                mBitrateItem.setTips(bitrate + "kbps");
                if (bitrate != mFeatureConfig.getVideoBitrate()) {
                    mFeatureConfig.setVideoBitrate(bitrate);
                    mTRTCMeeting.setVideoBitrate(bitrate);
                }
            }
        });

        // 分辨率相关
        mCurRes = getResolutionPos(mFeatureConfig.getVideoResolution());
        itemText =
                new BaseSettingItem.ItemText(getString(R.string.meeting_title_resolution), getResources().getStringArray(R.array.solution));
        mResolutionItem = new SelectionSettingItem(getContext(), itemText,
                new SelectionSettingItem.Listener() {
                    @Override
                    public void onItemSelected(int position, String text) {
                        mCurRes = position;
                        updateSolution(mCurRes);
                        int resolution = getResolution(mResolutionItem.getSelected());
                        if (resolution != mFeatureConfig.getVideoResolution()) {
                            mFeatureConfig.setVideoResolution(resolution);
                            mTRTCMeeting.setVideoResolution(resolution);
                        }
                    }
                }
        ).setSelect(mCurRes);
        mSettingItemList.add(mResolutionItem);

        //帧率
        itemText = new BaseSettingItem.ItemText(getString(R.string.meeting_title_frame_rate), getResources().getStringArray(R.array.video_fps));
        mVideoFpsItem = new SelectionSettingItem(getContext(), itemText,
                new SelectionSettingItem.Listener() {
                    @Override
                    public void onItemSelected(int position, String text) {
                        int fps = getFps(position);
                        if (fps != mFeatureConfig.getVideoFps()) {
                            mFeatureConfig.setVideoFps(fps);
                            mTRTCMeeting.setVideoFps(fps);
                        }
                    }
                }
        ).setSelect(getFpsPos(mFeatureConfig.getVideoFps()));
        mSettingItemList.add(mVideoFpsItem);

        /**
         * 这里更新码率的界面并且加入到ItemList中
         */
        updateSolution(mCurRes);
        mBitrateItem.setProgress(getBitrateProgress(mFeatureConfig.getVideoBitrate(), mCurRes));
        mBitrateItem.setTips(getBitrate(mFeatureConfig.getVideoBitrate(), mCurRes) + "kbps");
        mSettingItemList.add(mBitrateItem);

        itemText =
                new BaseSettingItem.ItemText(getString(R.string.meeting_title_local_mirror),
                        getString(R.string.meeting_title_enable), getString(R.string.meeting_title_disable));
        mMirrorTypeItem = new SwitchSettingItem(getContext(), itemText, new SwitchSettingItem.Listener() {
            @Override
            public void onSwitchChecked(boolean isChecked) {
                //设置本地
                mFeatureConfig.setMirror(isChecked);
                mTRTCMeeting.setLocalViewMirror(isChecked ? TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE : TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_DISABLE);
            }
        }).setCheck(mFeatureConfig.isMirror());
        mSettingItemList.add(mMirrorTypeItem);

        updateItem();

        // 将这些view添加到对应的容器中
        for (BaseSettingItem item : mSettingItemList) {
            View view = item.getView();
            view.setPadding(0, SizeUtils.dp2px(15), 0, 0);
            mContentItem.addView(view);
        }
    }

    private void updateItem() {
    }

    @Override
    protected int getLayoutId() {
        return R.layout.meeting_fragment_common_setting;
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
