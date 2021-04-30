package com.tencent.liteav.trtcchatsalon.ui.list;

import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.blankj.utilcode.constant.PermissionConstants;
import com.blankj.utilcode.util.PermissionUtils;
import com.tencent.liteav.login.model.ProfileManager;
import com.tencent.liteav.trtcchatsalon.R;
import com.tencent.liteav.trtcchatsalon.ui.utils.StatusBarUtils;
import com.tencent.liteav.trtcchatsalon.ui.room.ChatSalonAnchorActivity;
import com.tencent.trtc.TRTCCloudDef;

/**
 * 创建语聊房页面
 */
public class ChatSalonCreateActivity extends AppCompatActivity {
    private Toolbar      mToolbar;
    private EditText     mRoomNameEt;
    private TextView     mEnterTv;


    private TextWatcher mEditTextWatcher = new TextWatcher() {
        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {

        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
            if (!TextUtils.isEmpty(mRoomNameEt.getText().toString())) {
                mEnterTv.setEnabled(true);
            } else {
                mEnterTv.setEnabled(false);
            }
        }

        @Override
        public void afterTextChanged(Editable s) {

        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.trtcchatsalon_activity_create_voice_room);
        StatusBarUtils.initStatusBar(this);
        initView();
        initData();
        initPermission();
    }

    private void initData() {
        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        mRoomNameEt.addTextChangedListener(mEditTextWatcher);
        mEnterTv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                createRoom();
                finish();
            }
        });
        initThemeAndNickname();
    }

    private void initThemeAndNickname() {
        String userId   = ProfileManager.getInstance().getUserModel().userId;
        String userName = ProfileManager.getInstance().getUserModel().userName;
        String showUserName = !TextUtils.isEmpty(userName) ? userName : userId;
        mRoomNameEt.setText(getString(R.string.trtcchatsalon_create_theme, showUserName));
    }

    private void createRoom() {
        String roomName    = mRoomNameEt.getText().toString();
        String userId      = ProfileManager.getInstance().getUserModel().userId;
        String userAvatar  = ProfileManager.getInstance().getUserModel().userAvatar;
        String coverAvatar = ProfileManager.getInstance().getUserModel().userAvatar;
        String userName = ProfileManager.getInstance().getUserModel().userName;
        ChatSalonAnchorActivity.createRoom(this, roomName, userId, userName, userAvatar, coverAvatar, TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT, true);
    }

    private void initView() {
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mRoomNameEt = (EditText) findViewById(R.id.et_room_name);
        mEnterTv = (TextView) findViewById(R.id.tv_enter);
    }

    private void initPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PermissionUtils.permission(PermissionConstants.STORAGE, PermissionConstants.MICROPHONE, PermissionConstants.CAMERA)
                    .request();
        }
    }
}
