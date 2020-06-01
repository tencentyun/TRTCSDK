package com.tencent.liteav.demo;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;

import com.tencent.liteav.login.LoginActivity;
import com.tencent.liteav.login.ProfileManager;


public class SplashActivity extends Activity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if ((getIntent().getFlags() & Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT) != 0) {
            finish();
            return;
        } else {
            if (!ProfileManager.getInstance().isLogin()) {
                Intent intent = new Intent(this, LoginActivity.class);
                startActivity(intent);
            } else {
                Intent intent = new Intent(this, TRTCMainActivity.class);
                startActivity(intent);
            }
            finish();
        }
    }
}
