package com.tencent.trtc.screenshare;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.trtc.debug.Constant;

/**
 * 直播分享入口类，可输入房间ID，选择角色进入直播间
 *
 * 以主播角色进入房间{@link ScreenAnchorActivity}
 * 以观众角色进入房间{@link ScreenAudienceActvity}
 */

/**
 * Entrance for Screen Sharing Live Streaming (enter a room after specifying the room ID and selecting a role)
 *
 * Enter a room as an anchor: {@link ScreenAnchorActivity}
 * Enter a room as audience: {@link ScreenAudienceActvity}
 */
public class ScreenEntranceActivity extends AppCompatActivity {

    private EditText    mEditInputUserId;
    private EditText    mEditInputRoomId;
    private Button      mBtnAnchor;
    private Button      mBtnAudience;

    private int         mRoleSelectFlag = 1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.screenshare_activity_entrance);
        getSupportActionBar().hide();

        initView();
    }

    private void initView() {
        mEditInputUserId = findViewById(R.id.et_input_username);
        mEditInputRoomId = findViewById(R.id.et_input_room_id);
        mBtnAnchor = findViewById(R.id.btn_anchor);
        mBtnAudience = findViewById(R.id.btn_audience);
        mBtnAnchor.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(mRoleSelectFlag != 1){
                    mRoleSelectFlag = 1;
                    mBtnAnchor.setBackgroundColor(getResources().getColor(R.color.screenshare_single_select_button_bg));
                    mBtnAudience.setBackgroundColor(getResources().getColor(R.color.screenshare_single_select_button_bg_off));
                }
            }
        });

        mBtnAudience.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(mRoleSelectFlag != 2){
                    mRoleSelectFlag = 2;
                    mBtnAnchor.setBackgroundColor(getResources().getColor(R.color.screenshare_single_select_button_bg_off));
                    mBtnAudience.setBackgroundColor(getResources().getColor(R.color.screenshare_single_select_button_bg));
                }
            }
        });
        findViewById(R.id.bt_enter_room).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startEnterRoom();
            }
        });
        findViewById(R.id.rtc_entrance_main).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                hideInput();
            }
        });
        findViewById(R.id.entrance_ic_back).setOnClickListener(new View.OnClickListener() {
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
            Toast.makeText(ScreenEntranceActivity.this, getString(R.string.screenshare_room_input_error_tip), Toast.LENGTH_LONG).show();
            return;
        }
        if(mRoleSelectFlag == 1){
            Intent intent = new Intent(ScreenEntranceActivity.this, ScreenAnchorActivity.class);
            intent.putExtra(Constant.ROOM_ID, mEditInputRoomId.getText().toString().trim());
            intent.putExtra(Constant.USER_ID, mEditInputUserId.getText().toString().trim());
            startActivity(intent);
        }else if(mRoleSelectFlag == 2){
            Intent intent = new Intent(ScreenEntranceActivity.this, ScreenAudienceActvity.class);
            intent.putExtra(Constant.ROOM_ID, mEditInputRoomId.getText().toString().trim());
            intent.putExtra(Constant.USER_ID, mEditInputUserId.getText().toString().trim());
            startActivity(intent);
        }else{
            Toast.makeText(ScreenEntranceActivity.this, getString(R.string.screenshare_please_select_role), Toast.LENGTH_SHORT).show();
        }

    }

    protected void hideInput() {
        InputMethodManager imm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
        View v = getWindow().peekDecorView();
        if (null != v) {
            imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
        }
    }
}
