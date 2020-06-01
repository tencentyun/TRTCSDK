package com.tencent.liteav.meeting.ui.widget.base;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.View;

import com.tencent.liteav.demo.trtc.R;

import java.util.ArrayList;
import java.util.List;

/**
 * 带tab的用户设置页基类
 * {@link BaseTabSettingFragmentDialog#getTitleList()} 和 {@link BaseTabSettingFragmentDialog#getFragments()}
 * 这两个返回的顺序在界面中是一一对应的，比如title list是 {"视频","音频"} 那fragment 应该是 {videofragment, audiofragment}
 * @author guanyifeng
 */
public abstract class BaseTabSettingFragmentDialog extends BaseSettingFragmentDialog {
    private TabLayout      mTopTl;
    private ViewPager      mContentVp;
    private List<Fragment> mFragmentList;
    private List<String>   mTitleList;
    private PagerAdapter   mPagerAdapter;

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView(view);
        initData();
    }

    private void initData() {
        mFragmentList = getFragments();
        mTitleList = getTitleList();

        if (mFragmentList == null) {
            mFragmentList = new ArrayList<>();
        }
        mTopTl.setupWithViewPager(mContentVp, false);
        mPagerAdapter = new FragmentPagerAdapter(getChildFragmentManager()) {
            @Override
            public Fragment getItem(int position) {
                return mFragmentList == null ? null : mFragmentList.get(position);
            }

            @Override
            public int getCount() {
                return mFragmentList == null ? 0 : mFragmentList.size();
            }
        };
        mContentVp.setAdapter(mPagerAdapter);
        for (int i = 0; i < mTitleList.size(); i++) {
            TabLayout.Tab tab = mTopTl.getTabAt(i);
            if (tab != null) {
                tab.setText(mTitleList.get(i));
            }
        }
    }

    public void addFragment(Fragment fragment) {
        if (mFragmentList == null) {
            return;
        }
        mFragmentList.add(fragment);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.meeting_fragment_base_tab_setting;
    }

    private void initView(@NonNull final View itemView) {
        mTopTl = (TabLayout) itemView.findViewById(R.id.tl_top);
        mContentVp = (ViewPager) itemView.findViewById(R.id.vp_content);
    }

    /**
     * @return 这里返回对应的fragment
     */
    protected abstract List<Fragment> getFragments();


    /**
     * @return 这里返回对应的标题列表
     */
    protected abstract List<String> getTitleList();
}
