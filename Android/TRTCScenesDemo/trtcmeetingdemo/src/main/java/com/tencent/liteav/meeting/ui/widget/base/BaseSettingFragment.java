package com.tencent.liteav.meeting.ui.widget.base;

import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.liteav.meeting.model.TRTCMeeting;

/**
 * 设置fragment的基类
 *
 * @author guanyifeng
 */
public abstract class BaseSettingFragment extends Fragment {
    protected Handler     mHandler = new Handler();
    protected TRTCMeeting mTRTCMeeting;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(getLayoutId(), container, false);
    }

    public TRTCMeeting getTRTCMeeting() {
        return mTRTCMeeting;
    }

    public void setTRTCMeeting(TRTCMeeting TRTCMeeting) {
        mTRTCMeeting = TRTCMeeting;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView(view);
    }

    protected abstract void initView(View view);

    protected abstract int getLayoutId();
}
