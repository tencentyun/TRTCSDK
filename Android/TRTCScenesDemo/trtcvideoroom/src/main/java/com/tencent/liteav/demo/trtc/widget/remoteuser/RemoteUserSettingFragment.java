package com.tencent.liteav.demo.trtc.widget.remoteuser;


import android.support.annotation.NonNull;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.blankj.utilcode.util.SizeUtils;
import com.tencent.liteav.demo.trtc.R;
import com.tencent.liteav.demo.trtc.sdkadapter.remoteuser.RemoteUserConfig;
import com.tencent.liteav.demo.trtc.widget.BaseSettingFragment;
import com.tencent.liteav.demo.trtc.widget.settingitem.BaseSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.CheckBoxSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.CustomSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.RadioButtonSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.SeekBarSettingItem;

import java.util.ArrayList;
import java.util.List;

import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_ROTATION_0;
import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_ROTATION_270;
import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_ROTATION_90;

/**
 * 用户列表管理界面
 *
 * @author guanyifeng
 */
public class RemoteUserSettingFragment extends BaseSettingFragment implements View.OnClickListener {
    public static final  String                 DATA = "data";
    private static final String                 TAG  = RemoteUserSettingFragment.class.getName();
    private              FrameLayout            mBackFl;
    private              TextView               mTvTitle;
    private              LinearLayout           mContentItem;
    private              List<BaseSettingItem>  mSettingItemList;
    private              CheckBoxSettingItem    mEnableVideoItem;
    private              CheckBoxSettingItem    mEnableAudioItem;
    private              RadioButtonSettingItem mVideoFillModeItem;
    private              RadioButtonSettingItem mRotationItem;

    private RemoteUserConfig   mRemoteUserConfig = null;
    private Listener           mListener;
    private SeekBarSettingItem mVolumeItem;

    public void setListener(Listener listener) {
        mListener = listener;
    }

    @Override
    protected void initView(@NonNull final View itemView) {
        mBackFl = (FrameLayout) itemView.findViewById(R.id.fl_back);
        mBackFl.setOnClickListener(this);
        mTvTitle = (TextView) itemView.findViewById(R.id.title_tv);
        mContentItem = (LinearLayout) itemView.findViewById(R.id.item_content);

        mSettingItemList = new ArrayList<>();

        BaseSettingItem.ItemText itemText =
                new BaseSettingItem.ItemText("开启视频", "");
        mEnableVideoItem = new CheckBoxSettingItem(getContext(), itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        if (mRemoteUserConfig != null) {
                            mRemoteUserConfig.setEnableVideo(mEnableVideoItem.getChecked());
                            mTRTCRemoteUserManager.muteRemoteVideo(mRemoteUserConfig.getUserName(),
                                    mRemoteUserConfig.getStreamType(), !mRemoteUserConfig.isEnableVideo());
                        }
                    }
                });
        mSettingItemList.add(mEnableVideoItem);

        itemText =
                new BaseSettingItem.ItemText("开启音频", "");
        mEnableAudioItem = new CheckBoxSettingItem(getContext(), itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        if (mRemoteUserConfig != null) {
                            mRemoteUserConfig.setEnableAudio(mEnableAudioItem.getChecked());
                            mTRTCRemoteUserManager.muteRemoteAudio(mRemoteUserConfig.getUserName(),
                                    !mRemoteUserConfig.isEnableAudio());
                        }
                    }
                });
        mSettingItemList.add(mEnableAudioItem);

        itemText =
                new BaseSettingItem.ItemText("视频截图", "");
        CustomSettingItem snapshotItem = new CustomSettingItem(getContext(), itemText, createSnapshotButton());
        snapshotItem.setAlign(CustomSettingItem.ALIGN_RIGHT);
        mSettingItemList.add(snapshotItem);

        //画面填充方向
        itemText =
                new BaseSettingItem.ItemText("画面填充方向", "充满", "适应");
        mVideoFillModeItem = new RadioButtonSettingItem(getContext(), itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                        mRemoteUserConfig.setFillMode(index == 0);
                        mTRTCRemoteUserManager.setRemoteFillMode(mRemoteUserConfig.getUserName(),
                                mRemoteUserConfig.getStreamType(), mRemoteUserConfig.isFillMode());
                    }
                });
        mSettingItemList.add(mVideoFillModeItem);

        // 旋转方向
        itemText =
                new BaseSettingItem.ItemText("画面旋转方向", "0", "90", "270");
        mRotationItem = new RadioButtonSettingItem(getContext(), itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                        if (mRemoteUserConfig == null) {
                            return;
                        }
                        int rotation = TRTC_VIDEO_ROTATION_0;
                        if (index == 1) {
                            rotation = TRTC_VIDEO_ROTATION_90;
                        } else if (index == 2) {
                            rotation = TRTC_VIDEO_ROTATION_270;
                        }
                        mRemoteUserConfig.setRotation(rotation);
                        mTRTCRemoteUserManager.setRemoteRotation(mRemoteUserConfig.getUserName(),
                                mRemoteUserConfig.getStreamType(), rotation);
                    }
                });
        mSettingItemList.add(mRotationItem);

        // 用户音量设置
        itemText =
                new BaseSettingItem.ItemText("音量大小", "");
        mVolumeItem = new SeekBarSettingItem(getContext(), itemText, new SeekBarSettingItem.Listener() {
            @Override
            public void onSeekBarChange(int progress, boolean fromUser) {
                if (mRemoteUserConfig == null || !fromUser) {
                    return;
                }
                mRemoteUserConfig.setVolume(progress);
                mTRTCRemoteUserManager.setRemoteVolume(mRemoteUserConfig.getUserName(), mRemoteUserConfig.getStreamType(), mRemoteUserConfig.getVolume());
            }
        });
        mSettingItemList.add(mVolumeItem);

        // 将这些view添加到对应的容器中
        for (BaseSettingItem item : mSettingItemList) {
            View view = item.getView();
            view.setPadding(0, SizeUtils.dp2px(5), 0, 0);
            mContentItem.addView(view);
        }

        updateView();
    }

    private void updateView() {
        if (mRemoteUserConfig == null) {
            return;
        }

        mHandler.post(new Runnable() {
            @Override
            public void run() {
                mTvTitle.setText(mRemoteUserConfig.getUserName());
                mEnableVideoItem.setCheck(mRemoteUserConfig.isEnableVideo());
                mEnableAudioItem.setCheck(mRemoteUserConfig.isEnableAudio());
                mVideoFillModeItem.setSelect(mRemoteUserConfig.isFillMode() ? 0 : 1);
                int index = 0;
                switch (mRemoteUserConfig.getRotation()) {
                    case 0:
                        index = 0;
                        break;
                    case 90:
                        index = 1;
                        break;
                    case 270:
                        index = 2;
                        break;
                    default:
                        break;
                }
                mRotationItem.setSelect(index);
                mVolumeItem.setProgress(mRemoteUserConfig.getVolume());
            }
        });
    }

    public void setRemoteUserConfig(RemoteUserConfig remoteUserConfig) {
        mRemoteUserConfig = remoteUserConfig;
        updateView();
    }

    @Override
    protected int getLayoutId() {
        return R.layout.trtc_fragment_remote_user_setting;
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.fl_back) {
            if (mListener != null) {
                mListener.onBackClick();
            }
        }
    }

    public interface Listener {
        void onBackClick();
    }

    private List<View> createSnapshotButton() {
        List<View>   views  = new ArrayList<>();
        final Button button = new Button(getContext());
        button.setText("截图");

        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mRemoteUserConfig != null) {
                    mTRTCRemoteUserManager.snapshotRemoteView(mRemoteUserConfig.getUserName(), mRemoteUserConfig.getStreamType());
                }
            }
        });
        views.add(button);
        return views;
    }
}
