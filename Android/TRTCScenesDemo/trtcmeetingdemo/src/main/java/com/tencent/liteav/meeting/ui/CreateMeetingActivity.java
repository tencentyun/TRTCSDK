package com.tencent.liteav.meeting.ui;

import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.TextView;

import com.blankj.utilcode.constant.PermissionConstants;
import com.blankj.utilcode.util.PermissionUtils;
import com.blankj.utilcode.util.SizeUtils;
import com.tencent.liteav.demo.trtc.R;
import com.tencent.liteav.login.ProfileManager;
import com.tencent.liteav.login.UserModel;
import com.tencent.liteav.meeting.ui.widget.settingitem.BaseSettingItem;
import com.tencent.liteav.meeting.ui.widget.settingitem.SwitchSettingItem;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;

/**
 * 创建会议页面
 *
 * @author guanyifeng
 */
public class CreateMeetingActivity extends AppCompatActivity {
    private TextView                   mTitleMain;
    private Toolbar                    mToolbar;
    private EditText                   mRoomIdEt;
    private EditText                   mUserNameEt;
    private TextView                   mEnterTv;
    private LinearLayout               mSettingContainerLl;
    private RadioButton                mVoiceRb;
    private RadioButton                mNormalRb;
    private RadioButton                mMusicRb;
    private ArrayList<BaseSettingItem> mSettingItemList;

    private int     mAudioQuality;
    private boolean mOpenCamera;
    private boolean mOpenAudio;

    private TextWatcher mEditTextWatcher = new TextWatcher() {
        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {

        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
            if (!TextUtils.isEmpty(mRoomIdEt.getText().toString()) && !TextUtils.isEmpty(mUserNameEt.getText().toString())) {
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
        setContentView(R.layout.activity_create_meeting);
        initView();
        initData();
        initPermission();
    }

    private void initData() {
        String name = getIntent().getStringExtra("TITLE");
        mTitleMain.setText(name);
        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        mRoomIdEt.addTextChangedListener(mEditTextWatcher);
        mUserNameEt.addTextChangedListener(mEditTextWatcher);
        mEnterTv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                enterMeeting(mRoomIdEt.getText().toString(), mUserNameEt.getText().toString());
            }
        });
    }

    private void enterMeeting(final String roomId, final String userName) {
        UserModel userModel  = ProfileManager.getInstance().getUserModel();
        String    userId     = userModel.userId;
        String    userAvatar = userModel.userAvatar;
        int       tempRoomId;
        try {
            tempRoomId = Integer.parseInt(roomId);
        } catch (Exception e) {
            tempRoomId = 10000;
        }
        if (mMusicRb.isChecked()) {
            mAudioQuality = TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC;
        } else if (mNormalRb.isChecked()) {
            mAudioQuality = TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT;
        } else {
            mAudioQuality = TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH;
        }
        MeetingMainActivity.enterRoom(this, tempRoomId, userId, userName, userAvatar, mOpenCamera, mOpenAudio, mAudioQuality);
    }

    private void initView() {
        mTitleMain = (TextView) findViewById(R.id.main_title);
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mRoomIdEt = (EditText) findViewById(R.id.et_room_id);
        mUserNameEt = (EditText) findViewById(R.id.et_user_name);
        mEnterTv = (TextView) findViewById(R.id.tv_enter);
        mSettingContainerLl = (LinearLayout) findViewById(R.id.ll_setting_container);

        mSettingItemList = new ArrayList<>();
        BaseSettingItem.ItemText itemText = new BaseSettingItem.ItemText("开启摄像头", "");
        SwitchSettingItem mOpenCameraItem = new SwitchSettingItem(this, itemText,
                new SwitchSettingItem.Listener() {
                    @Override
                    public void onSwitchChecked(boolean isChecked) {
                        mOpenCamera = isChecked;
                    }
                }).setCheck(true);
        mSettingItemList.add(mOpenCameraItem);

        itemText = new BaseSettingItem.ItemText("开启麦克风", "");
        SwitchSettingItem mOpenAudioItem = new SwitchSettingItem(this, itemText,
                new SwitchSettingItem.Listener() {
                    @Override
                    public void onSwitchChecked(boolean isChecked) {
                        mOpenAudio = isChecked;
                    }
                }).setCheck(true);
        mSettingItemList.add(mOpenAudioItem);

        for (BaseSettingItem item : mSettingItemList) {
            View view = item.getView();
            view.setPadding(0, SizeUtils.dp2px(20), 0, 0);
            mSettingContainerLl.addView(view);
        }
        mVoiceRb = (RadioButton) findViewById(R.id.rb_voice);
        mNormalRb = (RadioButton) findViewById(R.id.rb_normal);
        mMusicRb = (RadioButton) findViewById(R.id.rb_music);

        setStyle(mVoiceRb);
        setStyle(mNormalRb);
        setStyle(mMusicRb);
    }

    private void setStyle(RadioButton rb) {
        Drawable drawable = getResources().getDrawable(R.drawable.bg_meeting_rb_icon_selector);
        //定义底部标签图片大小和位置
        drawable.setBounds(0, 0, 45, 45);
        //设置图片在文字的哪个方向
        rb.setCompoundDrawables(drawable, null, null, null);
        rb.setCompoundDrawablePadding(20);
    }

    private void initPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PermissionUtils.permission(PermissionConstants.STORAGE, PermissionConstants.MICROPHONE, PermissionConstants.CAMERA)
                    .request();
        }
    }
}
