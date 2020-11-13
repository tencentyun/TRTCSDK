package com.tencent.liteav.demo;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.liteav.login.model.ProfileManager;
import com.tencent.liteav.login.ui.LoginActivity;

public class SplashActivity extends Activity {

    private static final String TAG = "SplashActivity";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        navigation();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        Log.d(TAG, "onNewIntent: intent -> " + intent.getData());
        setIntent(intent);
        navigation();
    }

    private void navigation() {
        Intent intent = getIntent();
        if (!TextUtils.isEmpty(intent.getScheme())) {
            navigationWebData();
        } else {
            navigationMain();
        }
    }

    private void navigationMain() {
        if ((getIntent().getFlags() & Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT) != 0) {
            finish();
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

    private void navigationWebData() {
        Uri data = getIntent().getData();
        Intent intent = new Intent("com.tencent.liteav.action.WED_DATA");
        intent.setData(data);
        if (Build.VERSION.SDK_INT >= 26) {
            ComponentName componentName = new ComponentName(getPackageName(), "com.tencent.liteav.demo.player.expand.webdata.reveiver.WebDataReceiver");
            intent.setComponent(componentName);
        }
        Log.d(TAG, "navigationWebData: intent -> " + intent);
        sendBroadcast(intent);
        finish();
    }
}
