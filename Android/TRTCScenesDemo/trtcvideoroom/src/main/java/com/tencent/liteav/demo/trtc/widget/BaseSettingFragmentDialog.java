package com.tencent.liteav.demo.trtc.widget;

import android.app.Dialog;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import com.tencent.liteav.demo.trtc.R;

/**
 * 用户设置页的基类
 *
 * @author guanyifeng
 */
public abstract class BaseSettingFragmentDialog extends DialogFragment {
    public static final String DATA = "data";

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NO_TITLE, R.style.BaseFragmentDialogTheme);
    }

    @Override
    public void onStart() {
        super.onStart();
        // 设置弹窗占据屏幕的大小
        Window window = getDialog().getWindow();
        if (window != null) {
            WindowManager.LayoutParams windowParams = window.getAttributes();
            DisplayMetrics             dm           = new DisplayMetrics();
            getActivity().getWindowManager().getDefaultDisplay().getMetrics(dm);
            window.setAttributes(windowParams);
            Dialog dialog = getDialog();
            if (dialog != null) {
                dialog.getWindow().setLayout(getWidth(dm), getHeight(dm));
            }
        }
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(getLayoutId(), container, false);
    }

    /**
     * @return layout的resId
     */
    protected abstract int getLayoutId();

    /**
     * 可以通过覆盖这个函数达到改变弹窗大小的效果
     * @param dm DisplayMetrics
     * @return 界面宽度
     */
    protected int getWidth(DisplayMetrics dm) {
        return (int) (dm.widthPixels * 0.9);
    }

    /**
     * 可以通过覆盖这个函数达到改变弹窗大小的效果
     * @param dm DisplayMetrics
     * @return 界面高度
     */
    protected int getHeight(DisplayMetrics dm) {
        return (int) (dm.heightPixels * 0.8);
    }
}
