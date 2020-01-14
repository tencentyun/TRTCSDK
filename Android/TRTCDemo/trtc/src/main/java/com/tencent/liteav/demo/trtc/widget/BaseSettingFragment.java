package com.tencent.liteav.demo.trtc.widget;

import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.liteav.demo.trtc.sdkadapter.TRTCCloudManager;
import com.tencent.liteav.demo.trtc.sdkadapter.remoteuser.TRTCRemoteUserManager;

/**
 * 设置fragment的基类
 *
 * @author guanyifeng
 */
public abstract class BaseSettingFragment extends Fragment {
    protected Handler               mHandler = new Handler();
    protected TRTCCloudManager      mTRTCCloudManager;
    protected TRTCRemoteUserManager mTRTCRemoteUserManager;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(getLayoutId(), container, false);
    }

    public TRTCCloudManager getTRTCCloudManager() {
        return mTRTCCloudManager;
    }

    public void setTRTCCloudManager(TRTCCloudManager trtcCloudManager) {
        mTRTCCloudManager = trtcCloudManager;
    }

    public TRTCRemoteUserManager getTRTCRemoteUserManager() {
        return mTRTCRemoteUserManager;
    }

    public void setTRTCRemoteUserManager(TRTCRemoteUserManager TRTCRemoteUserManager) {
        mTRTCRemoteUserManager = TRTCRemoteUserManager;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView(view);
    }

    protected abstract void initView(View view);

    protected abstract int getLayoutId();
}
