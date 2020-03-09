package com.tencent.liteav.login;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.v7.app.AppCompatActivity;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.blankj.utilcode.util.ToastUtils;

/**
 * @author guanyifeng
 */
public class LoginActivity extends AppCompatActivity {
    private static final String TAG = LoginActivity.class.getName();

    private EditText       mUserIdEt;
    private TextView       mLoginTv;
    private ProgressDialog mLoadingDialog;
    // 用于loading超时处理
    private Handler        mMainHandler;
    private Runnable       mLoadingTimeoutRunnable = new Runnable() {
        @Override
        public void run() {
            stopLoading();
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.login_activity_login);
        mMainHandler = new Handler();
        initView();
        initData();
    }

    private void startMainActivity() {
        Intent intent = new Intent();
        intent.addCategory("android.intent.category.DEFAULT");
        intent.setAction("com.tencent.liteav.action.portal");
        startActivity(intent);
    }

    private void initData() {
        String userId = ProfileManager.getInstance().getUserId();
        String token  = ProfileManager.getInstance().getToken();
        if (!TextUtils.isEmpty(userId)) {
            mUserIdEt.setText(userId);
            if (!TextUtils.isEmpty(token)) {
                startLoading();
                // 自动登录
                ProfileManager.getInstance().autoLogin(userId, token, new ProfileManager.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        stopLoading();
                        startMainActivity();
                        finish();
                    }

                    @Override
                    public void onFailed(int code, String msg) {
                        stopLoading();
                        ToastUtils.showLong("自动登录失败，请重新获取验证码登录");
                    }
                });
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mMainHandler.removeCallbacks(mLoadingTimeoutRunnable);
    }

    private void initView() {
        mUserIdEt = (EditText) findViewById(R.id.et_userId);
        mLoginTv = (TextView) findViewById(R.id.tv_login);
        // 设置loading对话框
        mLoadingDialog = new ProgressDialog(this, R.style.loading_dialog);
        mLoadingDialog.setCancelable(false);
        mLoadingDialog.setCanceledOnTouchOutside(false);

        // 设置listener
        mLoginTv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                login();
            }
        });
    }

    /**
     * 登录
     */
    private void login() {
        String userId = mUserIdEt.getText().toString().trim();
        startLoading();
        ProfileManager.getInstance().login(userId, "", new ProfileManager.ActionCallback() {
            @Override
            public void onSuccess() {
                stopLoading();
                ToastUtils.showLong("登录成功");
                startMainActivity();
                finish();
            }

            @Override
            public void onFailed(int code, String msg) {
            }
        });
    }

    public void stopLoading() {
        Log.d(TAG, "dismissLoading");
        if (mLoadingDialog != null && mLoadingDialog.isShowing()) {
            mLoadingDialog.dismiss();
        }
    }

    public void startLoading() {
        Log.d(TAG, "showLoading");
        mLoadingDialog.show();
        mMainHandler.removeCallbacks(mLoadingTimeoutRunnable);
        mMainHandler.postDelayed(mLoadingTimeoutRunnable, 6000);
    }
}
