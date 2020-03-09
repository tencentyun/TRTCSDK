package com.tencent.liteav.demo.trtcvoiceroom.widgets;

import android.app.Dialog;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import com.tencent.liteav.demo.trtcvoiceroom.R;


/**
 * 用户设置页的基类
 */
public abstract class BaseSettingFragmentDialog extends DialogFragment {
    public static final String DATA = "data";

    private boolean needMargin = false;
    private int mMarginBottom;

    public void setMarginBottom(int marginBottom) {
        mMarginBottom = marginBottom;
        needMargin = true;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NO_TITLE, R.style.ChatRoomBaseFragmentDialogTheme);
    }

    @Override
    public void onStart() {
        super.onStart();
        // 设置弹窗占据屏幕的大小
        Window window = getDialog().getWindow();
        if (window != null) {
            WindowManager.LayoutParams windowParams = window.getAttributes();
            DisplayMetrics dm = new DisplayMetrics();
            getActivity().getWindowManager().getDefaultDisplay().getMetrics(dm);
            windowParams.dimAmount = getDimAmount();
            windowParams.gravity = getGravity();
            if (needMargin) {
                windowParams.y = mMarginBottom;
            }
            window.setAttributes(windowParams);
            Dialog dialog = getDialog();
            if (dialog != null) {
                dialog.getWindow().setLayout(getWidth(dm), ViewGroup.LayoutParams.WRAP_CONTENT);
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
     *
     * @param dm DisplayMetrics
     * @return 界面宽度
     */
    protected int getWidth(DisplayMetrics dm) {
        return (int) (dm.widthPixels * 0.9);
    }

    /**
     * 可以通过覆盖这个函数达到改变弹窗大小的效果
     *
     * @param dm DisplayMetrics
     * @return 界面高度
     */
    protected int getHeight(DisplayMetrics dm) {
        return (int) (dm.heightPixels * 0.8);
    }

    /**
     * @return 背景透明度
     */
    protected float getDimAmount() {
        return 0.0f;
    }

    /**
     * 弹窗的方位
     * @return
     */
    protected int getGravity() {
        return Gravity.BOTTOM;
    }

}
