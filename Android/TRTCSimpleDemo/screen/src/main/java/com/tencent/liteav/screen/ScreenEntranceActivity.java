package com.tencent.liteav.screen;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.liteav.debug.Constant;

/**
 * 屏幕分享的入口页面（可以设置房间id和用户id）
 *
 */
public class ScreenEntranceActivity extends AppCompatActivity {

    private EditText mInputUserId;
    private EditText mInputRoomId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_screen_entrance);
        getSupportActionBar().hide();
        mInputUserId = findViewById(R.id.et_input_username);
        mInputRoomId = findViewById(R.id.et_input_room_id);
        findViewById(R.id.bt_enter_room).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startEnterRoom(); // 开始进房
            }
        });
        findViewById(R.id.rtc_entrance_main).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                hideInput(); // 点击非EditText输入区域，隐藏键盘
            }
        });
        findViewById(R.id.entrance_ic_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();  // 返回结束
            }
        });
        mInputRoomId.setText("1256732");
        String time = String.valueOf(System.currentTimeMillis());
        String userId = time.substring(time.length() - 8);
        mInputUserId.setText(userId);
    }

    private void startEnterRoom() {
        if (TextUtils.isEmpty(mInputUserId.getText().toString().trim())
                || TextUtils.isEmpty(mInputRoomId.getText().toString().trim())) {
            Toast.makeText(ScreenEntranceActivity.this, getString(R.string.screen_room_input_error_tip), Toast.LENGTH_LONG).show();
            return;
        }
        Intent intent = new Intent(ScreenEntranceActivity.this, ScreenActivity.class);
        intent.putExtra(Constant.ROOM_ID, mInputRoomId.getText().toString().trim());
        intent.putExtra(Constant.USER_ID, mInputUserId.getText().toString().trim());
        startActivity(intent);
    }

    /**
     * 隐藏键盘
     */
    protected void hideInput() {
        InputMethodManager imm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
        View v = getWindow().peekDecorView();
        if (null != v) {
            imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
        }
    }

}
