package com.tencent.trtc.voicechatoom;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.debug.Constant;

/**
 * TRTC 语音互动直播入口类，可输入房间ID，选择角色进入直播间
 *
 * - 以主播角色进入房间{@link VoiceChatRoomAnchorActivity}
 * - 以观众角色进入房间{@link VoiceChatRoomAudienceActivity}
 *
 * - 详见API文档{https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a915a4b3abca0e41f057022a4587faf66}
 */

/**
 * Interactive Live Audio Streaming Entrance (enter a room after specifying the room ID and selecting a role)
 *
 * - Enter a room as a room owner: {@link VoiceChatRoomAnchorActivity}
 * - Enter a room as a listener: {@link VoiceChatRoomAudienceActivity}
 *
 * - For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a915a4b3abca0e41f057022a4587faf66}.
 */
public class VoiceChatRoomEnterActivity extends AppCompatActivity {
    private EditText    mEditInputUserId;
    private EditText    mEditInputRoomId;
    private Button      mButtonAnchor;
    private Button      mButtonAudience;
    private Button      mButtonEnterRoom;
    private ImageView   mImageBack;

    private int         mRoleSelectFlag = TRTCCloudDef.TRTCRoleAnchor;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.voicechatroom_activity_enter);
        getSupportActionBar().hide();
        initView();
    }

    private void initView() {
        mEditInputUserId = findViewById(R.id.et_input_username);
        mEditInputRoomId = findViewById(R.id.et_input_room_id);
        mButtonAnchor = findViewById(R.id.btn_anchor);
        mButtonAudience = findViewById(R.id.btn_audience);
        mButtonEnterRoom = findViewById(R.id.btn_enter_room);
        mImageBack = findViewById(R.id.iv_back);

        mButtonAnchor.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(mRoleSelectFlag != TRTCCloudDef.TRTCRoleAnchor){
                    mRoleSelectFlag = TRTCCloudDef.TRTCRoleAnchor;
                    mButtonAnchor.setBackgroundColor(getResources().getColor(R.color.voicechatroom_single_select_button_bg));
                    mButtonAudience.setBackgroundColor(getResources().getColor(R.color.voicechatroom_single_select_button_bg_off));
                }
            }
        });

        mButtonAudience.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(mRoleSelectFlag != TRTCCloudDef.TRTCRoleAudience){
                    mRoleSelectFlag = TRTCCloudDef.TRTCRoleAudience;
                    mButtonAnchor.setBackgroundColor(getResources().getColor(R.color.voicechatroom_single_select_button_bg_off));
                    mButtonAudience.setBackgroundColor(getResources().getColor(R.color.voicechatroom_single_select_button_bg));
                }
            }
        });
        mButtonEnterRoom.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startEnterRoom(); // 开始进房
            }
        });
        mImageBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();  // 返回结束
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
            Toast.makeText(VoiceChatRoomEnterActivity.this, getString(R.string.voicechatroom_room_input_error_tip), Toast.LENGTH_LONG).show();
            return;
        }
        if(mRoleSelectFlag == TRTCCloudDef.TRTCRoleAnchor){
            Intent intent = new Intent(VoiceChatRoomEnterActivity.this, VoiceChatRoomAnchorActivity.class);
            intent.putExtra(Constant.ROOM_ID, mEditInputRoomId.getText().toString().trim());
            intent.putExtra(Constant.USER_ID, mEditInputUserId.getText().toString().trim());
            startActivity(intent);
        }else if(mRoleSelectFlag == TRTCCloudDef.TRTCRoleAudience){
            Intent intent = new Intent(VoiceChatRoomEnterActivity.this, VoiceChatRoomAudienceActivity.class);
            intent.putExtra(Constant.ROOM_ID, mEditInputRoomId.getText().toString().trim());
            intent.putExtra(Constant.USER_ID, mEditInputUserId.getText().toString().trim());
            startActivity(intent);
        }else{
            Toast.makeText(VoiceChatRoomEnterActivity.this, getString(R.string.voicechatroom_please_select_role), Toast.LENGTH_SHORT).show();
        }
    }
}
