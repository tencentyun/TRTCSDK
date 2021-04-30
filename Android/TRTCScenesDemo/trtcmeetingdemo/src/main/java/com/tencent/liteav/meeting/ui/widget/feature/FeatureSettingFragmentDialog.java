package com.tencent.liteav.meeting.ui.widget.feature;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.DisplayMetrics;
import android.view.WindowManager;

import com.tencent.liteav.demo.trtc.R;
import com.tencent.liteav.meeting.model.TRTCMeeting;
import com.tencent.liteav.meeting.ui.widget.base.BaseSettingFragment;
import com.tencent.liteav.meeting.ui.widget.base.BaseTabSettingFragmentDialog;

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
    private      String[]             TITLE_LIST;
    private      VideoSettingFragment mVideoSettingFragment;
    private      AudioSettingFragment mAudioSettingFragment;
    private      ShareSettingFragment mShareSettingFragment;
    private      List<Fragment>       mFragmentList;
    private      TRTCMeeting          mTRTCMeeting;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TITLE_LIST = new String[]{
                getString(R.string.meeting_title_video),
                getString(R.string.meeting_title_audio),
                getString(R.string.meeting_title_sharing)
        };
        initFragment();
    }

    private void initFragment() {
        if (mFragmentList == null) {
            mFragmentList = new ArrayList<>();
            mVideoSettingFragment = new VideoSettingFragment();
            mAudioSettingFragment = new AudioSettingFragment();
            mShareSettingFragment = new ShareSettingFragment();
            mFragmentList.add(mVideoSettingFragment);
            mFragmentList.add(mAudioSettingFragment);
            mFragmentList.add(mShareSettingFragment);
            if (mTRTCMeeting != null) {
                for (Fragment fragment : mFragmentList) {
                    if (fragment instanceof BaseSettingFragment) {
                        ((BaseSettingFragment) fragment).setTRTCMeeting(mTRTCMeeting);
                    }
                }
            }
        }
    }

    public void setTRTCMeeting(TRTCMeeting TRTCMeeting) {
        mTRTCMeeting = TRTCMeeting;
        if (mFragmentList != null && mFragmentList.size() != 0) {
            for (Fragment fragment : mFragmentList) {
                if (fragment instanceof BaseSettingFragment) {
                    ((BaseSettingFragment) fragment).setTRTCMeeting(mTRTCMeeting);
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
        return (int) (dm.heightPixels * 0.5);
    }

    @Override
    protected int getWidth(DisplayMetrics dm) {
        return WindowManager.LayoutParams.MATCH_PARENT;
    }
}
