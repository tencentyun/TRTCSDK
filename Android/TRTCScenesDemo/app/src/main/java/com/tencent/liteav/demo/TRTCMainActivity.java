package com.tencent.liteav.demo;

import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentTabHost;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TabHost;
import android.widget.TextView;

import com.blankj.utilcode.constant.PermissionConstants;
import com.blankj.utilcode.util.PermissionUtils;
import com.tencent.bugly.beta.Beta;
import com.tencent.liteav.demo.common.widget.ConfirmDialogFragment;

public class TRTCMainActivity extends FragmentActivity {

    private static final String TAG = TRTCMainActivity.class.getName();
    private static final Class FRAGMENT_ARRAY[] = {
            TRTCMainFragment.class,
            TRTCUserInfoFragment.class
    };
    private static int IMAGE_ARRAY[] = {
            R.drawable.app_tab_main_list,
            R.drawable.app_tab_user_center
    };
    private static final String TAB_MAIN = "tab_main";
    private static final String TAB_MY = "tab_my";
    private static final String TAB_TAG_ARRAY[] = {
            TAB_MAIN,
            TAB_MY
    };

    private FragmentTabHost mFragmentTabHost;
    private LayoutInflater mLayoutInflater;
    private String[] mTabText;
    private ConfirmDialogFragment mAlertDialog;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_trtc_main);
        initStatusBar();
        if ((getIntent().getFlags() & Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT) != 0) {
            Log.d(TAG, "brought to front");
            finish();
            return;
        }
        mFragmentTabHost = (FragmentTabHost) findViewById(android.R.id.tabhost);
        mLayoutInflater = LayoutInflater.from(this);
        mFragmentTabHost.setup(this, getSupportFragmentManager(), R.id.contentPanel);
        mTabText = new String[]{
                getString(R.string.app_main_page),
                getString(R.string.app_my),
        };
        int fragmentCount = FRAGMENT_ARRAY.length;
        for (int i = 0; i < fragmentCount; i++) {
            TabHost.TabSpec tabSpec = mFragmentTabHost.newTabSpec(TAB_TAG_ARRAY[i]).setIndicator(getTabItemView(i));
            mFragmentTabHost.addTab(tabSpec, FRAGMENT_ARRAY[i], null);
            mFragmentTabHost.getTabWidget().setDividerDrawable(null);
        }
        TextView mainTab = (TextView) mFragmentTabHost.getTabWidget().getChildAt(0).findViewById(R.id.tab_text);
        mainTab.setTextColor(getResources().getColor(R.color.app_color_tab_select));
        mFragmentTabHost.setOnTabChangedListener(new TabHost.OnTabChangeListener() {
            @Override
            public void onTabChanged(String tabId) {
                for (int i = 0; i < mFragmentTabHost.getTabWidget().getChildCount(); i++) {
                    TextView tv = (TextView) mFragmentTabHost.getTabWidget().getChildAt(i).findViewById(R.id.tab_text);
                    if (mFragmentTabHost.getCurrentTab() == i) {
                        tv.setTextColor(getResources().getColor(R.color.app_color_tab_select));
                    } else {
                        tv.setTextColor(getResources().getColor(R.color.app_color_tab_normal));
                    }
                }
            }
        });
        initPermission();
        Beta.checkUpgrade();
        mAlertDialog = new ConfirmDialogFragment();
    }

    @Override
    protected void onResume() {
        super.onResume();
        CallService.start(this);
    }

    private void initStatusBar() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.TRANSPARENT);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }

    @Override
    public void onBackPressed() {
        if (mAlertDialog.isAdded()) {
            mAlertDialog.dismiss();
        }
        mAlertDialog.setMessage(getString(R.string.app_dialog_exit_app));
        mAlertDialog.setNegativeClickListener(new ConfirmDialogFragment.NegativeClickListener() {
            @Override
            public void onClick() {
                mAlertDialog.dismiss();
            }
        });
        mAlertDialog.setPositiveClickListener(new ConfirmDialogFragment.PositiveClickListener() {
            @Override
            public void onClick() {
                mAlertDialog.dismiss();
                CallService.stop(TRTCMainActivity.this);
                finish();
            }
        });
        mAlertDialog.show(getFragmentManager(), "confirm_fragment");
    }

    private View getTabItemView(int index) {
        View view = mLayoutInflater.inflate(R.layout.trtc_main_tab, null);
        ImageView tabIcon = (ImageView) view.findViewById(R.id.tab_icon);
        TextView tabText = (TextView) view.findViewById(R.id.tab_text);
        tabIcon.setImageResource(IMAGE_ARRAY[index]);
        tabText.setText(mTabText[index]);
        return view;
    }

    private void initPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PermissionUtils.permission(PermissionConstants.STORAGE, PermissionConstants.MICROPHONE, PermissionConstants.CAMERA)
                    .request();
        }
    }
}
