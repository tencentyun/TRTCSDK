package com.tencent.liteav.demo.trtc.widget.bgm;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.DisplayMetrics;

import com.tencent.liteav.demo.trtc.sdkadapter.bgm.TRTCBgmManager;
import com.tencent.liteav.demo.trtc.widget.BaseTabSettingFragmentDialog;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 点击音乐按钮后弹出的窗口
 *
 * @author guanyifeng
 */
public class BgmSettingFragmentDialog extends BaseTabSettingFragmentDialog {

    public final String[]              TITLE_LIST = {"BGM", "音效"};
    private      List<Fragment>        mFragmentList;
    private      BgmSettingFragment    mBgmSettingFragment;
    private      EffectSettingFragment mEffectSettingFragment;
    private      TRTCBgmManager        mTRTCBgmManager;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initFragment();
    }

    private void initFragment() {
        if (mFragmentList == null) {
            mFragmentList = new ArrayList<>();
            mBgmSettingFragment = new BgmSettingFragment();
            mEffectSettingFragment = new EffectSettingFragment();
            mEffectSettingFragment.copyEffectFolder(getActivity());
            if (mTRTCBgmManager != null) {
                mBgmSettingFragment.setTRTCBgmManager(mTRTCBgmManager);
                mEffectSettingFragment.setTRTCBgmManager(mTRTCBgmManager);
            }
            mFragmentList.add(mBgmSettingFragment);
            mFragmentList.add(mEffectSettingFragment);
        }
    }

    public void setTRTCBgmManager(TRTCBgmManager trtcBgmManager) {
        mTRTCBgmManager = trtcBgmManager;
        if (mBgmSettingFragment != null) {
            mBgmSettingFragment.setTRTCBgmManager(mTRTCBgmManager);
        }
        if (mEffectSettingFragment != null) {
            mEffectSettingFragment.setTRTCBgmManager(mTRTCBgmManager);
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
        return (int) (dm.heightPixels * 0.6);
    }

    public void onAudioEffectFinished(int effectId, int code) {
        mEffectSettingFragment.onAudioEffectFinished(effectId, code);
    }
}
