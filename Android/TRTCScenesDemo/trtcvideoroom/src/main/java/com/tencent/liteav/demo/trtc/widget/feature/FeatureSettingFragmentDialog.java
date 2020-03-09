package com.tencent.liteav.demo.trtc.widget.feature;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.DisplayMetrics;

import com.blankj.utilcode.util.CollectionUtils;
import com.tencent.liteav.demo.trtc.sdkadapter.TRTCCloudManager;
import com.tencent.liteav.demo.trtc.sdkadapter.remoteuser.TRTCRemoteUserManager;
import com.tencent.liteav.demo.trtc.widget.BaseSettingFragment;
import com.tencent.liteav.demo.trtc.widget.BaseTabSettingFragmentDialog;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 点击设置后弹出的dialog
 *
 * @author guanyifeng
 */
public class FeatureSettingFragmentDialog extends BaseTabSettingFragmentDialog {
    /**
     * 控件布局相关
     */
    public final String[]              TITLE_LIST = {"视频", "音频", "混流", "PK", "其他"};
    private      VideoSettingFragment  mVideoSettingFragment;
    private      AudioSettingFragment  mAudioSettingFragment;
    private      SteamSettingFragment  mSteamSettingFragment;
    private      PkSettingFragment     mPkSettingFragment;
    private      MoreSettingFragment   mMoreSettingFragment;
    private      List<Fragment>        mFragmentList;
    private      TRTCCloudManager      mTRTCCloudManager;
    private      TRTCRemoteUserManager mTRTCRemoteUserManager;
    private      String                mRoomId;
    private      String                mUserId;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initFragment();
    }

    private void initFragment() {
        if (mFragmentList == null) {
            mFragmentList = new ArrayList<>();
            mVideoSettingFragment = new VideoSettingFragment();
            mAudioSettingFragment = new AudioSettingFragment();
            mSteamSettingFragment = new SteamSettingFragment();
            mPkSettingFragment = new PkSettingFragment();
            mPkSettingFragment.setPkSettingListener(new PkSettingFragment.PkSettingListener() {
                @Override
                public void onPkSettingComplete() {
                    dismiss();
                }
            });
            mMoreSettingFragment = new MoreSettingFragment();
            mFragmentList.add(mVideoSettingFragment);
            mFragmentList.add(mAudioSettingFragment);
            mFragmentList.add(mSteamSettingFragment);
            mFragmentList.add(mPkSettingFragment);
            mFragmentList.add(mMoreSettingFragment);
            if (mTRTCCloudManager != null) {
                for (Fragment fragment : mFragmentList) {
                    if (fragment instanceof BaseSettingFragment) {
                        ((BaseSettingFragment) fragment).setTRTCCloudManager(mTRTCCloudManager);
                        ((BaseSettingFragment) fragment).setTRTCRemoteUserManager(mTRTCRemoteUserManager);
                    }
                }
            }
        }
    }

    public void setTRTCCloudManager(TRTCCloudManager trtcCloudManager, TRTCRemoteUserManager trtcRemoteUserManager) {
        mTRTCCloudManager = trtcCloudManager;
        mTRTCRemoteUserManager = trtcRemoteUserManager;
        if (!CollectionUtils.isEmpty(mFragmentList)) {
            for (Fragment fragment : mFragmentList) {
                if (fragment instanceof BaseSettingFragment) {
                    ((BaseSettingFragment) fragment).setTRTCCloudManager(mTRTCCloudManager);
                    ((BaseSettingFragment) fragment).setTRTCRemoteUserManager(mTRTCRemoteUserManager);
                }
            }
        }
    }

    @Override
    protected List<Fragment> getFragments() {
        return mFragmentList;
    }

    @Override
    protected List<String> getTitleList() {
        return Arrays.asList(TITLE_LIST);
    }

    @Override
    protected int getHeight(DisplayMetrics dm) {
        return (int) (dm.heightPixels * 0.7);
    }
}
