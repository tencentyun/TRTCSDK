package com.tencent.liteav.login.ui;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.blankj.utilcode.util.ToastUtils;
import com.squareup.picasso.Picasso;
import com.tencent.liteav.login.R;
import com.tencent.liteav.login.model.AvatarConstant;
import com.tencent.liteav.login.model.ProfileManager;
import com.tencent.liteav.login.ui.view.ModifyUserAvatarDialog;

import java.util.Random;


public class ProfileActivity extends BaseActivity {
    private static final String TAG = ProfileActivity.class.getName();

    private ImageView mImageAvatar;
    private EditText  mEditUserName;
    private Button    mButtonRegister;
    private TextView  mTvInputTips;
    private String    mAvatarUrl;

    public static void start(Context context) {
        Intent starter = new Intent(context, ProfileActivity.class);
        context.startActivity(starter);
    }

    private void startMainActivity() {
        Intent intent = new Intent();
        intent.addCategory("android.intent.category.DEFAULT");
        intent.setAction("com.tencent.liteav.action.portal");
        startActivity(intent);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.login_activity_profile);
        initStatusBar();
        initView();
    }

    @Override
    protected void onResume() {
        super.onResume();
        mButtonRegister.setEnabled(mEditUserName.length() != 0);
    }

    private void initView() {
        mImageAvatar = (ImageView) findViewById(R.id.iv_user_avatar);
        mEditUserName = (EditText) findViewById(R.id.et_user_name);
        mButtonRegister = (Button) findViewById(R.id.tv_register);
        mTvInputTips = (TextView) findViewById(R.id.tv_tips_user_name);
        String[] avatarArr = AvatarConstant.USER_AVATAR_ARRAY;
        int index = new Random().nextInt(avatarArr.length);
        mAvatarUrl  = avatarArr[index];
        Picasso.get().load(mAvatarUrl).into(mImageAvatar);
        mButtonRegister.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setProfile();
            }
        });
        mEditUserName.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence text, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence text, int start, int before, int count) {
                mButtonRegister.setEnabled(text.length() != 0);
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });
        findViewById(R.id.iv_user_avatar).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ModifyUserAvatarDialog dialog = new ModifyUserAvatarDialog(ProfileActivity.this, new ModifyUserAvatarDialog.ModifySuccessListener() {
                    @Override
                    public void onSuccess() {
                        String userAvatar  = ProfileManager.getInstance().getUserModel().userAvatar;
                        Picasso.get().load(userAvatar).into(mImageAvatar);
                    }
                });
                dialog.show();
            }
        });
    }

    private void initStatusBar() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.TRANSPARENT);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }

    private void setProfile() {
        String userName = mEditUserName.getText().toString().trim();
        if (TextUtils.isEmpty(userName)) {
            ToastUtils.showLong(getString(R.string.login_toast_set_username));
            return;
        }
        String reg = "^[a-z0-9A-Z\\u4e00-\\u9fa5\\_]{2,20}$";
        if (!userName.matches(reg)) {
            mTvInputTips.setTextColor(getResources().getColor(R.color.login_color_input_no_match));
            return;
        }
        mTvInputTips.setTextColor(getResources().getColor(R.color.login_color_input_normal));
        ProfileManager.getInstance().setNicknameAndAvatar(userName, mAvatarUrl, new ProfileManager.ActionCallback() {
            @Override
            public void onSuccess() {
                ToastUtils.showLong(getString(R.string.login_toast_register_success_and_logging_in));
                startMainActivity();
                finish();
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtils.showLong(getString(R.string.login_toast_failed_to_set_username, msg));
            }
        });
    }

}
