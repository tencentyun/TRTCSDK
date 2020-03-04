package com.tencent.liteav.demo.trtc.widget.cdnplay;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.DisplayMetrics;
import android.view.View;
import android.widget.LinearLayout;

import com.blankj.utilcode.util.SizeUtils;
import com.tencent.liteav.demo.trtc.R;
import com.tencent.liteav.demo.trtc.sdkadapter.ConfigHelper;
import com.tencent.liteav.demo.trtc.sdkadapter.cdn.CdnPlayManager;
import com.tencent.liteav.demo.trtc.sdkadapter.cdn.CdnPlayerConfig;
import com.tencent.liteav.demo.trtc.widget.BaseSettingFragmentDialog;
import com.tencent.liteav.demo.trtc.widget.settingitem.BaseSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.RadioButtonSettingItem;

import java.util.ArrayList;
import java.util.List;

import static com.tencent.liteav.demo.trtc.sdkadapter.cdn.CdnPlayerConfig.CACHE_STRATEGY_FAST;
import static com.tencent.rtmp.TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION;
import static com.tencent.rtmp.TXLiveConstants.RENDER_MODE_FULL_FILL_SCREEN;
import static com.tencent.rtmp.TXLiveConstants.RENDER_ROTATION_LANDSCAPE;
import static com.tencent.rtmp.TXLiveConstants.RENDER_ROTATION_PORTRAIT;
import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_ROTATION_0;
import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_ROTATION_270;
import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_ROTATION_90;

/**
 * cdn播放管理界面
 *
 * @author guanyifeng
 */
public class CdnPlayerSettingFragmentDialog extends BaseSettingFragmentDialog {
    private LinearLayout           mContentItem;
    private List<BaseSettingItem>  mSettingItemList;
    private RadioButtonSettingItem mVideoFillModeItem;
    private RadioButtonSettingItem mRotationItem;
    private RadioButtonSettingItem mCacheTypeItem;
    private CdnPlayerConfig        mCdnPlayerConfig;
    private CdnPlayManager         mCdnPlayManager;

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView(view);
    }

    public void setCdnPlayManager(CdnPlayManager cdnPlayManager) {
        mCdnPlayManager = cdnPlayManager;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.trtc_fragment_confirm_setting;
    }

    private void initView(@NonNull final View itemView) {
        mContentItem = (LinearLayout) itemView.findViewById(R.id.item_content);
        mCdnPlayerConfig = ConfigHelper.getInstance().getCdnPlayerConfig();
        mSettingItemList = new ArrayList<>();
        //画面填充方向
        BaseSettingItem.ItemText itemText = new BaseSettingItem.ItemText("画面填充方向", "充满", "适应");
        mVideoFillModeItem = new RadioButtonSettingItem(getContext(), itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                        mCdnPlayerConfig.setCurrentRenderMode(index == 0 ? RENDER_MODE_FULL_FILL_SCREEN
                                : RENDER_MODE_ADJUST_RESOLUTION);
                        if (mCdnPlayManager != null) {
                            mCdnPlayManager.applyConfigToPlayer();
                        }
                    }
                });
        mSettingItemList.add(mVideoFillModeItem);

        // 旋转方向
        itemText =
                new BaseSettingItem.ItemText("画面旋转方向", "0", "270");
        mRotationItem = new RadioButtonSettingItem(getContext(), itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                        int rotation = RENDER_ROTATION_PORTRAIT;
                        if (index == 1) {
                            rotation = RENDER_ROTATION_LANDSCAPE;
                        }
                        mCdnPlayerConfig.setCurrentRenderRotation(rotation);
                        if (mCdnPlayManager != null) {
                            mCdnPlayManager.applyConfigToPlayer();
                        }
                    }
                });
        mSettingItemList.add(mRotationItem);


        itemText =
                new BaseSettingItem.ItemText("缓冲方式", "快速", "平滑", "自动");
        mCacheTypeItem = new RadioButtonSettingItem(getContext(), itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                        mCdnPlayerConfig.setCacheStrategy(CACHE_STRATEGY_FAST + index);
                        if (mCdnPlayManager != null) {
                            mCdnPlayManager.applyConfigToPlayer();
                        }
                    }
                });
        mSettingItemList.add(mCacheTypeItem);

        // 将这些view添加到对应的容器中
        for (BaseSettingItem item : mSettingItemList) {
            View view = item.getView();
            view.setPadding(0, SizeUtils.dp2px(5), 0, 0);
            mContentItem.addView(view);
        }

        updateView();
    }

    private void updateView() {
        mVideoFillModeItem.setSelect(mCdnPlayerConfig.getCurrentRenderMode() == RENDER_MODE_ADJUST_RESOLUTION ? 1 : 0);
        mRotationItem.setSelect(getRotationIndex(mCdnPlayerConfig.getCurrentRenderRotation()));
        mCacheTypeItem.setSelect(mCdnPlayerConfig.getCacheStrategy() - CACHE_STRATEGY_FAST);
    }

    private int getRotationIndex(int type) {
        switch (type) {
            case RENDER_ROTATION_PORTRAIT:
                return 0;
            case RENDER_ROTATION_LANDSCAPE:
                return 1;
            default:
                return 0;
        }
    }

    @Override
    protected int getHeight(DisplayMetrics dm) {
        return (int) (dm.heightPixels * 0.4);
    }
}
