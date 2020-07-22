package com.tencent.trtcsimpledemo;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.custom.CustomEntranceActivity;
import com.tencent.liteav.screen.ScreenEntranceActivity;
import com.tencent.live.LiveRoomListActivity;
import com.tencent.rtc.RTCEntranceActivity;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        getSupportActionBar().hide();
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                findViewById(R.id.launch_view).setVisibility(View.GONE);
            }
        }, 1000);
        findViewById(R.id.bt_rtc).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, RTCEntranceActivity.class);
                startActivity(intent);
            }
        });
        findViewById(R.id.bt_live).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, LiveRoomListActivity.class);
                startActivity(intent);
            }
        });
        findViewById(R.id.bt_screen).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, ScreenEntranceActivity.class);
                startActivity(intent);
            }
        });
        findViewById(R.id.bt_custom_capture).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, CustomEntranceActivity.class);
                startActivity(intent);
            }
        });
    }

}
