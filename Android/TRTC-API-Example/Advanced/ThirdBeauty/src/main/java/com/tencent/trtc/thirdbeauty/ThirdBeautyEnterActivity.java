package com.tencent.trtc.thirdbeauty;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import com.example.basic.TRTCBaseActivity;

public class ThirdBeautyEnterActivity extends TRTCBaseActivity implements View.OnClickListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_third_beauty_enter);
        getSupportActionBar().hide();
        initViews();
    }

    private void initViews() {
        findViewById(R.id.btn_faceunity).setOnClickListener(this);
        findViewById(R.id.btn_bytedance).setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();
        if (id == R.id.btn_faceunity) {
            Intent intent = new Intent(ThirdBeautyEnterActivity.this, ThirdBeautyActivity.class);
            startActivity(intent);
        } else if (id == R.id.btn_bytedance) {
            Intent intent = new Intent(ThirdBeautyEnterActivity.this, ThirdBeautyByteDanceActivity.class);
            startActivity(intent);
        }
    }

    @Override
    protected void onPermissionGranted() {

    }
}
