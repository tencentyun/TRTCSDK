package com.tencent.liteav.login.ui;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.login.model.ProfileManager;
import com.tencent.liteav.login.R;
import com.tencent.liteav.login.ui.view.LoginStatusLayout;

public class LoginActivity extends BaseActivity {
    private static final String TAG = LoginActivity.class.getName();

    private static final int STATUS_WITHOUT_LOGIN = 0;          // 未登录
    private static final int STATUS_LOGGING_IN = 1;             // 正在登录
    private static final int STATUS_LOGIN_SUCCESS = 2;          // 登录成功
    private static final int STATUS_LOGIN_FAIL = 3;             // 登录失败

    private EditText          mEditUserId;
    private Button            mButtonLogin;
    private LoginStatusLayout mLayoutLoginStatus;               // 登录状态的提示栏
    private Handler           mMainHandler;

    private Runnable mResetLoginStatusRunnable = new Runnable() {
        @Override
        public void run() {
            handleLoginStatus(STATUS_WITHOUT_LOGIN);
        }
    };

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.login_activity_login);
        mMainHandler = new Handler();
        initView();
        initData();
    }

    @Override
    protected void onResume() {
        super.onResume();
        updateLoginBtnStatus();
    }

    private void startMainActivity() {
        Intent intent = new Intent();
        intent.addCategory("android.intent.category.DEFAULT");
        intent.setAction("com.tencent.liteav.action.portal");
        startActivity(intent);
        finish();
    }

    private void initData() {
        String userId = ProfileManager.getInstance().getUserId();
        String token  = ProfileManager.getInstance().getToken();
        if (!TextUtils.isEmpty(userId)) {
            mEditUserId.setText(userId);
            if (!TextUtils.isEmpty(token)) {
                handleLoginStatus(STATUS_LOGGING_IN);
                ProfileManager.getInstance().autoLogin(userId, token, new ProfileManager.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        handleLoginStatus(STATUS_LOGIN_SUCCESS);
                        startMainActivity();
                    }

                    @Override
                    public void onFailed(int code, String msg) {
                        handleLoginStatus(STATUS_LOGIN_FAIL);
                        ToastUtils.showLong(R.string.login_tips_auto_login_fail);
                    }
                });
            }
        }
    }

    private void initView() {
        mLayoutLoginStatus = (LoginStatusLayout) findViewById(R.id.cl_login_status);
        initEditPhone();
        initButtonLogin();
    }

    private void initEditPhone() {
        mEditUserId = (EditText) findViewById(R.id.et_userId);
        mEditUserId.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                updateLoginBtnStatus();
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
    }

    private void initButtonLogin() {
        mButtonLogin = (Button) findViewById(R.id.tv_login);
        mButtonLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                login();
            }
        });
    }

    private void updateLoginBtnStatus() {
        if (mEditUserId.length() == 0) {
            mButtonLogin.setEnabled(false);
            return;
        }
        mButtonLogin.setEnabled(true);
    }

    private void login() {
        String userId = mEditUserId.getText().toString().trim();
        if (TextUtils.isEmpty(userId)) {
            ToastUtils.showLong(R.string.login_tips_input_correct_info);
            return;
        }
        handleLoginStatus(STATUS_LOGGING_IN);
        ProfileManager.getInstance().login(userId, "", new ProfileManager.ActionCallback() {
            @Override
            public void onSuccess() {
                handleLoginStatus(STATUS_LOGIN_SUCCESS);
                startMainActivity();
            }

            @Override
            public void onFailed(int code, String msg) {
            }
        });
    }

    public void handleLoginStatus(int loginStatus) {
        mLayoutLoginStatus.setLoginStatus(loginStatus);

        if (STATUS_LOGGING_IN == loginStatus) {
            mMainHandler.removeCallbacks(mResetLoginStatusRunnable);
            mMainHandler.postDelayed(mResetLoginStatusRunnable, 6000);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mMainHandler.removeCallbacks(mResetLoginStatusRunnable);
    }
}
