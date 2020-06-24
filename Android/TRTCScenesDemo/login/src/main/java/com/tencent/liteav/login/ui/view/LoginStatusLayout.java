package com.tencent.liteav.login.ui.view;

import android.content.Context;
import android.support.constraint.ConstraintLayout;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.liteav.login.R;
import com.tencent.liteav.login.ui.utils.Utils;

/**
 * 腾讯云工具包登录界面中，顶部登录状态等提示布局；
 */
public class LoginStatusLayout extends ConstraintLayout {

    private static final int STATUS_WITHOUT_LOGIN = 0;
    private static final int STATUS_LOGGING_IN = 1;
    private static final int STATUS_LOGIN_SUCCESS = 2;
    private static final int STATUS_LOGIN_FAIL = 3;

    private ConstraintLayout mRootView;            // 整个布局控件
    private TextView         mTextTitle;           // 显示UI标题
    private TextView         mTextLoginStatus;     // 显示登录状态提示文本
    private ImageView        mImageLoginStatus;    // 显示登录状态提示图标

    public LoginStatusLayout(Context context) {
        super(context);
        initView(context);
    }

    public LoginStatusLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView(context);
    }

    public LoginStatusLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView(context);
    }

    private void initView(Context context) {
        mRootView = (ConstraintLayout) LayoutInflater.from(context).inflate(R.layout.login_layout_login_status, this);
        mTextTitle = (TextView) mRootView.findViewById(R.id.tv_title);
        mTextLoginStatus = (TextView) mRootView.findViewById(R.id.tv_login_status);
        mImageLoginStatus = (ImageView) mRootView.findViewById(R.id.iv_login_status);

        if (Utils.isTRTCDemo(context)) {
            mTextTitle.setText(R.string.login_title_trtc);
        } else {
            mTextTitle.setText(R.string.login_title_liteav);
        }
    }

    public void setLoginStatus(int loginStatus) {
        switch (loginStatus) {
            case STATUS_WITHOUT_LOGIN:
                mRootView.setBackgroundColor(getResources().getColor(R.color.login_transparent));
                mTextLoginStatus.setVisibility(View.GONE);
                mImageLoginStatus.setVisibility(View.GONE);
                mTextTitle.setVisibility(View.VISIBLE);
                break;
            case STATUS_LOGGING_IN:
                mRootView.setBackgroundColor(getResources().getColor(R.color.login_color_head_login_success));
                mTextLoginStatus.setVisibility(View.VISIBLE);
                mImageLoginStatus.setVisibility(View.GONE);
                mTextTitle.setVisibility(View.GONE);
                mTextLoginStatus.setText(R.string.login_status_logging_in);
                mTextLoginStatus.setTextColor(getResources().getColor(R.color.login_color_text_login_success));
                break;
            case STATUS_LOGIN_SUCCESS:
                mRootView.setBackgroundColor(getResources().getColor(R.color.login_color_head_login_success));
                mTextLoginStatus.setVisibility(View.VISIBLE);
                mImageLoginStatus.setVisibility(View.VISIBLE);
                mTextTitle.setVisibility(View.GONE);
                mTextLoginStatus.setText(R.string.login_status_login_success);
                mTextLoginStatus.setTextColor(getResources().getColor(R.color.login_color_text_login_success));
                mImageLoginStatus.setBackgroundResource(R.drawable.login_tips_login_success);
                break;
            case STATUS_LOGIN_FAIL:
                mRootView.setBackgroundColor(getResources().getColor(R.color.login_color_head_login_fail));
                mTextLoginStatus.setVisibility(View.VISIBLE);
                mImageLoginStatus.setVisibility(View.VISIBLE);
                mTextTitle.setVisibility(View.GONE);
                mTextLoginStatus.setText(R.string.login_status_login_fail);
                mTextLoginStatus.setTextColor(getResources().getColor(R.color.login_color_text_login_fail));
                mImageLoginStatus.setBackgroundResource(R.drawable.login_tips_login_fail);
                break;
            default:
                break;
        }
    }

}
