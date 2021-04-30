package com.tencent.liteav.trtcvoiceroom.ui.list;

import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.SwitchCompat;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.TextView;

import com.blankj.utilcode.constant.PermissionConstants;
import com.blankj.utilcode.util.PermissionUtils;
import com.tencent.liteav.login.model.ProfileManager;
import com.tencent.liteav.trtcvoiceroom.R;
import com.tencent.liteav.trtcvoiceroom.ui.room.VoiceRoomAnchorActivity;
import com.tencent.trtc.TRTCCloudDef;

/**
 * 创建语聊房页面
 *
 * @author guanyifeng
 */
public class VoiceRoomCreateActivity extends AppCompatActivity {
    private Toolbar      mToolbar;
    private EditText     mRoomNameEt;
    private EditText     mUserNameEt;
    private TextView     mEnterTv;
    private boolean      mNeedOwnerAgree = true;
    private SwitchCompat mSwitchNeedQuest;
    private RadioButton  mRbNormal;
    private RadioButton  mRbMusic;


    private TextWatcher mEditTextWatcher = new TextWatcher() {
        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {

        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
            if (!TextUtils.isEmpty(mRoomNameEt.getText().toString()) && !TextUtils.isEmpty(mUserNameEt.getText().toString())) {
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
        setContentView(R.layout.trtcvoiceroom_activity_create_voice_room);
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
        mUserNameEt.addTextChangedListener(mEditTextWatcher);
        mRbNormal = (RadioButton) findViewById(R.id.rb_normal);
        mRbMusic = (RadioButton) findViewById(R.id.rb_music);
        mEnterTv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                createRoom();
            }
        });
        setStyle(mRbNormal);
        setStyle(mRbMusic);
    }

    private void createRoom() {
        int audioQuality = TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC;
        if (mRbNormal.isChecked()) {
            audioQuality = TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT;
        } else if (mRbMusic.isChecked()) {
            audioQuality = TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC;
        }
        String roomName    = mRoomNameEt.getText().toString();
        String userId      = ProfileManager.getInstance().getUserModel().userId;
        String userName    = mUserNameEt.getText().toString();
        String userAvatar  = ProfileManager.getInstance().getUserModel().userAvatar;
        String coverAvatar = ProfileManager.getInstance().getUserModel().userAvatar;
        VoiceRoomAnchorActivity.createRoom(this, roomName, userId, userName, coverAvatar, audioQuality, mNeedOwnerAgree);
    }

    private void initView() {
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mRoomNameEt = (EditText) findViewById(R.id.et_room_name);
        mUserNameEt = (EditText) findViewById(R.id.et_user_name);
        mEnterTv = (TextView) findViewById(R.id.tv_enter);
        mSwitchNeedQuest = (SwitchCompat) findViewById(R.id.switch_need_request);
        mSwitchNeedQuest.setChecked(true);
        mSwitchNeedQuest.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                mNeedOwnerAgree = isChecked;
            }
        });
    }

    private void initPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PermissionUtils.permission(PermissionConstants.STORAGE, PermissionConstants.MICROPHONE, PermissionConstants.CAMERA)
                    .request();
        }
    }

    private void setStyle(RadioButton rb) {
        Drawable drawable = getResources().getDrawable(R.drawable.trtcvoiceroom_bg_rb_icon_selector);
        //定义底部标签图片大小和位置
        drawable.setBounds(0, 0, 70, 70);
        //设置图片在文字的哪个方向
        rb.setCompoundDrawables(drawable, null, null, null);
        rb.setCompoundDrawablePadding(20);
    }
}
