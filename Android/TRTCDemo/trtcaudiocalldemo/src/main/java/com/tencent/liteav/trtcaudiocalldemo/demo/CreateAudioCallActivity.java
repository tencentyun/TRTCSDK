package com.tencent.liteav.trtcaudiocalldemo.demo;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.TextView;
import android.widget.Toast;

import com.blankj.utilcode.constant.PermissionConstants;
import com.blankj.utilcode.util.PermissionUtils;
import com.blankj.utilcode.util.SPUtils;
import com.tencent.liteav.trtcaudiocalldemo.R;
import com.tencent.trtc.TRTCCloud;


public class CreateAudioCallActivity extends AppCompatActivity {
    public static final String ROOM_ID = "audiocall_id";
    public static final String USER_ID = "audiocall_user_id";

    private LinearLayout mNetEnv;
    private TextView     mEnterTv;
    private Toolbar      mToolbar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.audiocall_activity_create);
        initView();
        initData();
        initPermission();
    }

    private void initPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PermissionUtils.permission(PermissionConstants.STORAGE, PermissionConstants.MICROPHONE, PermissionConstants.CAMERA)
                    .request();
        }
    }

    private void initData() {
        mNetEnv.setVisibility(View.VISIBLE);
        //获取存取的用户名和房间号
        String         roomId   = SPUtils.getInstance().getString(ROOM_ID);
        String         userId   = SPUtils.getInstance().getString(USER_ID);
        final EditText etRoomId = (EditText) findViewById(R.id.et_room_name);
        final EditText etUserId = (EditText) findViewById(R.id.et_user_name);
        if (TextUtils.isEmpty(roomId)) {
            roomId = String.valueOf(System.currentTimeMillis() % 10000 + 10000);
        }
        if (TextUtils.isEmpty(userId)) {
            userId = String.valueOf(System.currentTimeMillis() % 1000000);
        }
        etRoomId.setText(roomId);
        etUserId.setText(userId);

        findViewById(R.id.NetEnv).setVisibility(View.VISIBLE);
    }

    private void initView() {
        mNetEnv = (LinearLayout) findViewById(R.id.NetEnv);
        mEnterTv = (TextView) findViewById(R.id.tv_enter);
        mEnterTv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startJoinRoom();
            }
        });
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }

    /**
     * Function: 读取用户输入，并创建（或加入）音视频房间
     * <p>
     * 此段示例代码最主要的作用是组装 TRTC SDK 进房所需的 TRTCParams
     * <p>
     * TRTCParams.sdkAppId => 可以在腾讯云实时音视频控制台（https://console.cloud.tencent.com/rav）获取
     * TRTCParams.userId   => 此处即用户输入的用户名，它是一个字符串
     * TRTCParams.roomId   => 此处即用户输入的音视频房间号，比如 125
     * TRTCParams.userSig  => 此处示例代码展示了本地签发 userSig 的示例。
     * 目前 Demo 为了方便您接入，使用的是本地签发 sig 的方式，您的项目上线，务必要保证将签发逻辑转移到服务端，否者会出现 key 被盗用，流量盗用的风险。
     * <p>
     * 参考文档：https://cloud.tencent.com/document/product/647/17275
     */
    private void startJoinRoomInternal(final int roomId, final String userId) {
        final Intent intent = new Intent(this, AudioCallMainActivity.class);
        intent.putExtra(ROOM_ID, roomId);
        intent.putExtra(USER_ID, userId);
        startActivity(intent);
    }

    private void startJoinRoom() {
        // 这里对房间号和用户名的有效性进行校验
        final EditText etRoomId = (EditText) findViewById(R.id.et_room_name);
        final EditText etUserId = (EditText) findViewById(R.id.et_user_name);
        int            roomId   = 123;
        try {
            roomId = Integer.valueOf(etRoomId.getText().toString());
        } catch (Exception e) {
            Toast.makeText(this, "请输入有效的房间号", Toast.LENGTH_SHORT).show();
            return;
        }
        final String userId = etUserId.getText().toString();
        if (TextUtils.isEmpty(userId)) {
            Toast.makeText(this, "请输入有效的用户名", Toast.LENGTH_SHORT).show();
            return;
        }
        // 保存roomId和userId
        SPUtils.getInstance().put(ROOM_ID, String.valueOf(roomId));
        SPUtils.getInstance().put(USER_ID, userId);

        startJoinRoomInternal(roomId, userId);
    }
}
