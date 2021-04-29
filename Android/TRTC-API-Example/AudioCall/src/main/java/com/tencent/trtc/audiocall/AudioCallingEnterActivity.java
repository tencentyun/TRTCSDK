package com.tencent.trtc.audiocall;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.trtc.debug.Constant;

/**
 * TRTC语音通话的入口页面（可以设置房间id和用户id）
 *
 * TRTC语音通话是基于房间来实现的，通话的双方要进入一个相同的房间id才能进行语音通话
 */
public class AudioCallingEnterActivity extends AppCompatActivity {

    private EditText mEditInputUserId;
    private EditText mEditInputRoomId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.audiocall_activity_enter);

        getSupportActionBar().hide();
        mEditInputUserId = findViewById(R.id.et_input_username);
        mEditInputRoomId = findViewById(R.id.et_input_room_id);
        findViewById(R.id.btn_enter_room).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startEnterRoom();
            }
        });
        findViewById(R.id.rl_entrance_main).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                hideInput();
            }
        });
        findViewById(R.id.iv_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        mEditInputRoomId.setText("1256732");
        String time = String.valueOf(System.currentTimeMillis());
        String userId = time.substring(time.length() - 8);
        mEditInputUserId.setText(userId);
    }

    private void startEnterRoom() {
        if (TextUtils.isEmpty(mEditInputUserId.getText().toString().trim())
                || TextUtils.isEmpty(mEditInputRoomId.getText().toString().trim())) {
            Toast.makeText(AudioCallingEnterActivity.this, getString(R.string.audiocall_input_error_tip), Toast.LENGTH_LONG).show();
            return;
        }
        Intent intent = new Intent(AudioCallingEnterActivity.this, AudioCallingActivity.class);
        intent.putExtra(Constant.ROOM_ID, mEditInputRoomId.getText().toString().trim());
        intent.putExtra(Constant.USER_ID, mEditInputUserId.getText().toString().trim());
        startActivity(intent);
    }

    protected void hideInput() {
        InputMethodManager imm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
        View v = getWindow().peekDecorView();
        if (null != v) {
            imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
        }
    }

}

