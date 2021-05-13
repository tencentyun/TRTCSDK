package com.tencent.liteav.login.ui;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import com.tencent.liteav.login.R;
import com.tencent.liteav.login.model.ProfileManager;

import java.util.Locale;

public class UserProtocolActivity extends Activity {
    private static final String TAG = UserProtocolActivity.class.getName();
    private static final int CODE_LOGIN_SUCCESS       = 2;
    private static final int CODE_NEED_REGISTER       = -2;

    private WebView mWebView;
    private Button mBtnApprove;
    private Button mBtnRefuse;
    private int mIntentCode;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.login_activity_user_protocol);
        Intent intent = getIntent();
        if (intent != null) {
            mIntentCode = intent.getIntExtra("code", 0);
        }
        initView();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    private void initView() {
        mWebView = (WebView) findViewById(R.id.wv_protocol);
        mBtnApprove = (Button) findViewById(R.id.btn_approve);
        mBtnRefuse = (Button) findViewById(R.id.btn_refuse);

        mBtnApprove.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIntentCode == CODE_LOGIN_SUCCESS) {
                    Intent intent = new Intent();
                    intent.addCategory("android.intent.category.DEFAULT");
                    intent.setAction("com.tencent.liteav.action.portal");
                    startActivity(intent);
                    finish();
                } else  {
                    Intent starter = new Intent(UserProtocolActivity.this, ProfileActivity.class);
                    startActivity(starter);
                    finish();
                }
            }
        });
        mBtnRefuse.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ProfileManager.getInstance().setToken(""); //清下token
                Intent starter = new Intent(UserProtocolActivity.this, LoginActivity.class);
                startActivity(starter);
                finish();
            }
        });

        Locale locale = getResources().getConfiguration().locale;
        String language = locale.getLanguage();
        if ("en".endsWith(language)) {
            mWebView.loadUrl("file:///android_asset/UserProtocol_EN.html");
        } else {
            mWebView.loadUrl("file:///android_asset/UserProtocol.html");
        }

        //设置Web视图
        mWebView.setWebViewClient(new webViewClient ());
    }

    private class webViewClient extends WebViewClient {
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            view.loadUrl(url);
            return true;
        }
    }

}
