package com.tencent.trtc.videocall;

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
 * TRTC视频通话的入口页面（可以设置房间id和用户id）
 *
 * - 可跳转TRTC视频通话页面{@link VideoCallingActivity}
 */

/**
 * Video Call Entrance View (set room ID and user ID)
 *
 * - Direct to the video call view: {@link VideoCallingActivity}
 */
public class VideoCallingEnterActivity extends AppCompatActivity {

    private EditText mEditInputUserId;
    private EditText mEditInputRoomId;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.videocall_activit_enter);
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
            Toast.makeText(VideoCallingEnterActivity.this, getString(R.string.videocall_room_input_error_tip), Toast.LENGTH_LONG).show();
            return;
        }
        Intent intent = new Intent(VideoCallingEnterActivity.this, VideoCallingActivity.class);
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
