package com.tencent.liteav.demo.trtc.widget.feature;

import android.view.View;
import android.widget.LinearLayout;

import com.blankj.utilcode.util.SizeUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.demo.trtc.R;
import com.tencent.liteav.demo.trtc.sdkadapter.ConfigHelper;
import com.tencent.liteav.demo.trtc.sdkadapter.feature.MoreConfig;
import com.tencent.liteav.demo.trtc.sdkadapter.feature.VideoConfig;
import com.tencent.liteav.demo.trtc.widget.BaseSettingFragment;
import com.tencent.liteav.demo.trtc.widget.settingitem.BaseSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.CheckBoxSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.EditTextSendSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.RadioButtonSettingItem;

import java.util.ArrayList;
import java.util.List;

import static com.tencent.trtc.TRTCCloudDef.VIDEO_QOS_CONTROL_CLIENT;
import static com.tencent.trtc.TRTCCloudDef.VIDEO_QOS_CONTROL_SERVER;

/**
 * 更多相关的设置页
 *
 * @author guanyifeng
 */
public class MoreSettingFragment extends BaseSettingFragment {
    private LinearLayout            mContentItem;
    private List<BaseSettingItem>   mSettingItemList;
    private RadioButtonSettingItem  mQosModeItem;
    private CheckBoxSettingItem     mEnableSmallItem;
    private CheckBoxSettingItem     mPriorSmallItem;
    private CheckBoxSettingItem     mEnableFlashItem;
    private CheckBoxSettingItem     mGSensorModeItem;
    private MoreConfig              mMoreConfig;
    private VideoConfig             mVideoConfig;
    private EditTextSendSettingItem mCustomMsgItem;
    private EditTextSendSettingItem mSeiMsgItem;

    @Override
    protected void initView(View itemView) {
        mContentItem = (LinearLayout) itemView.findViewById(R.id.item_content);
        mSettingItemList = new ArrayList<>();
        mMoreConfig = ConfigHelper.getInstance().getMoreConfig();
        mVideoConfig = ConfigHelper.getInstance().getVideoConfig();
        BaseSettingItem.ItemText itemText =
                new BaseSettingItem.ItemText("流控方案", "客户端控", "云端流控");
        mQosModeItem = new RadioButtonSettingItem(getContext(), itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                        mVideoConfig.setQosMode(
                                index == 0 ? VIDEO_QOS_CONTROL_CLIENT
                                        : VIDEO_QOS_CONTROL_SERVER);
                        onParamsChange();
                    }
                });
        mSettingItemList.add(mQosModeItem);
        itemText =
                new BaseSettingItem.ItemText("开启双路编码", "");
        mEnableSmallItem = new CheckBoxSettingItem(getContext(), itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        mVideoConfig.setEnableSmall(mEnableSmallItem.getChecked());
                        onParamsChange();
                    }
                });
        mSettingItemList.add(mEnableSmallItem);

        itemText =
                new BaseSettingItem.ItemText("默认观看低清", "");
        mPriorSmallItem = new CheckBoxSettingItem(getContext(), itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        mVideoConfig.setPriorSmall(mPriorSmallItem.getChecked());
                        onParamsChange();
                    }
                });
        mSettingItemList.add(mPriorSmallItem);

        itemText =
                new BaseSettingItem.ItemText("开启闪光灯", "");
        mEnableFlashItem = new CheckBoxSettingItem(getContext(), itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        openFlashlight();
                    }
                });
        mSettingItemList.add(mEnableFlashItem);

        itemText =
                new BaseSettingItem.ItemText("开启重力感应", "");
        mGSensorModeItem = new CheckBoxSettingItem(getContext(), itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        mVideoConfig.setEnableGSensorMode(mGSensorModeItem.getChecked());
                        onParamsChange();
                    }
                });
        mSettingItemList.add(mGSensorModeItem);

        itemText =
                new BaseSettingItem.ItemText("自定义消息", "");
        mCustomMsgItem = new EditTextSendSettingItem(getContext(), itemText, new EditTextSendSettingItem.OnSendListener() {
            @Override
            public void send(String msg) {
                mTRTCCloudManager.sendCustomMsg(msg);
            }
        });
        mSettingItemList.add(mCustomMsgItem);

        itemText =
                new BaseSettingItem.ItemText("SEI消息", "");
        mSeiMsgItem = new EditTextSendSettingItem(getContext(), itemText, new EditTextSendSettingItem.OnSendListener() {
            @Override
            public void send(String msg) {
                mTRTCCloudManager.sendSEIMsg(msg);
            }
        });
        mSettingItemList.add(mSeiMsgItem);

        // 将这些view添加到对应的容器中
        for (BaseSettingItem item : mSettingItemList) {
            View view = item.getView();
            view.setPadding(0, SizeUtils.dp2px(5), 0, 0);
            mContentItem.addView(view);
        }

        updateView();
    }

    private void onParamsChange() {
        if (mTRTCCloudManager != null) {
            mTRTCCloudManager.setTRTCCloudParam();
            mTRTCCloudManager.enableGSensor(mVideoConfig.isEnableGSensorMode());
        }
    }

    private void openFlashlight() {
        if (mTRTCCloudManager != null) {
            boolean openStatus = mTRTCCloudManager.openFlashlight();
            if (openStatus) {
                mEnableFlashItem.setCheck(mMoreConfig.isEnableFlash());
            } else {
                ToastUtils.showLong("打开闪光灯失败");
            }
        }
    }

    private void updateView() {
        mQosModeItem.setSelect(
                mVideoConfig.getQosMode() == VIDEO_QOS_CONTROL_SERVER ? 1 : 0);
        mEnableSmallItem.setCheck(mVideoConfig.isEnableSmall());
        mPriorSmallItem.setCheck(mVideoConfig.isPriorSmall());
        mEnableFlashItem.setCheck(mMoreConfig.isEnableFlash());
        mGSensorModeItem.setCheck(mVideoConfig.isEnableGSensorMode());
    }

    @Override
    protected int getLayoutId() {
        return R.layout.trtc_fragment_confirm_setting;
    }
}
