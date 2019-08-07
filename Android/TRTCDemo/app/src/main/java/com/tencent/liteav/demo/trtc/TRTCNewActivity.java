package com.tencent.liteav.demo.trtc;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.ActivityCompat;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.demo.R;
import com.tencent.liteav.demo.trtc.debug.GenerateTestUserSig;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import static com.tencent.liteav.demo.trtc.utils.Utils.getPath;
import static com.tencent.liteav.demo.trtc.utils.Utils.getRealPathFromURI;


/**
 * Module:   TRTCNewActivity
 * <p>
 * Function: 该界面可以让用户输入一个【房间号】和一个【用户名】
 * <p>
 * Notice:
 * 1. 房间号为数字类型，用户名为字符串类型
 *
 * 2. 在真实的使用场景中，房间号大多不是用户手动输入的，而是系统分配的，
 * 比如视频会议中的会议号是会控系统提前预定好的，客服系统中的房间号也是根据客服员工的工号决定的。
 *
 * 3. 【*****】目前 Demo 为了方便您接入，使用的是本地签发 sig 的方式，您的项目上线，务必要保证将签发逻辑转移到服务端，否者会出现 key 被盗用，流量盗用的风险。
 *     {@link TRTCNewActivity#startJoinRoomInternal(int, String)}
 */
public class TRTCNewActivity extends Activity {
    private final static int REQ_PERMISSION_CODE = 0x1000;
    private String mVideoFile = "";
    private int mCurrentType; // 0 视频通话，1在线直播

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_trtc_new_room);
        mCurrentType = getIntent().getIntExtra("TYPE", 0);
        String name = getIntent().getStringExtra("TITLE");


        final EditText etRoomId = (EditText) findViewById(R.id.et_room_name);
        final EditText etUserId = (EditText) findViewById(R.id.et_user_name);

        loadUserInfo(etRoomId, etUserId);

        if (mCurrentType == 0) {
            findViewById(R.id.role).setVisibility(View.GONE);
        }
        RadioButton rbAnchor = (RadioButton) findViewById(R.id.rb_anchor);
        rbAnchor.setChecked(true);

        RadioButton rbCamera = (RadioButton) findViewById(R.id.rb_camera);
        rbCamera.setChecked(true);

        TextView title = (TextView) findViewById(R.id.main_title);
        title.setText(name);
        title.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                File logFile = getLastModifiedLogFile();
                if (logFile != null) {
                    Intent intent = new Intent(Intent.ACTION_SEND);
                    intent.setType("application/octet-stream");
                    intent.setPackage("com.tencent.mobileqq");
                    intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(logFile));
                    startActivity(Intent.createChooser(intent, "分享日志"));
                } else {
                    Toast.makeText(TRTCNewActivity.this.getApplicationContext(), "日志文件不存在！", Toast.LENGTH_SHORT);
                }
                return false;
            }
        });

        TextView tvEnterRoom = (TextView) findViewById(R.id.tv_enter);
        tvEnterRoom.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (((RadioButton) findViewById(R.id.rb_video_file)).isChecked()) {
                    Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
                    intent.setType("video/*");
                    startActivityForResult(intent, 1);
                    return;
                }
                startJoinRoom();
            }
        });

        // 申请动态权限
        checkPermission();
    }


    private void startJoinRoom() {
        final EditText etRoomId = (EditText) findViewById(R.id.et_room_name);
        final EditText etUserId = (EditText) findViewById(R.id.et_user_name);
        int roomId = 123;
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

        startJoinRoomInternal(roomId, userId);
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
     *                        目前 Demo 为了方便您接入，使用的是本地签发 sig 的方式，您的项目上线，务必要保证将签发逻辑转移到服务端，否者会出现 key 被盗用，流量盗用的风险。
     * <p>
     * 参考文档：https://cloud.tencent.com/document/product/647/17275
     */
    private void startJoinRoomInternal(final int roomId, final String userId) {
        final Intent intent = new Intent(this, TRTCMainActivity.class);
        // sdkAppId 和 userSig
        // 【*****】目前 Demo 为了方便您接入，使用的是本地签发 sig 的方式，您的项目上线，务必要保证将签发逻辑转移到服务端，否者会出现 key 被盗用，流量盗用的风险。
        // 【*****】目前 Demo 为了方便您接入，使用的是本地签发 sig 的方式，您的项目上线，务必要保证将签发逻辑转移到服务端，否者会出现 key 被盗用，流量盗用的风险。
        // 【*****】目前 Demo 为了方便您接入，使用的是本地签发 sig 的方式，您的项目上线，务必要保证将签发逻辑转移到服务端，否者会出现 key 被盗用，流量盗用的风险。
        int sdkAppId =  GenerateTestUserSig.SDKAPPID;
        String userSig = GenerateTestUserSig.genTestUserSig(userId);
        intent.putExtra(TRTCMainActivity.KEY_SDK_APP_ID, sdkAppId);
        intent.putExtra(TRTCMainActivity.KEY_USER_SIG,   userSig);

        // roomId userId
        intent.putExtra(TRTCMainActivity.KEY_ROOM_ID, roomId);
        intent.putExtra(TRTCMainActivity.KEY_USER_ID, userId);

        saveUserInfo(String.valueOf(roomId), userId);

        // 模式选择
        if (mCurrentType == 1) {// 直播低延时大房间
            intent.putExtra(TRTCMainActivity.KEY_APP_SCENE, TRTCCloudDef.TRTC_APP_SCENE_LIVE);
            RadioButton rbAnchor = (RadioButton) findViewById(R.id.rb_anchor);
            intent.putExtra(TRTCMainActivity.KEY_ROLE, rbAnchor.isChecked() ? TRTCCloudDef.TRTCRoleAnchor : TRTCCloudDef.TRTCRoleAudience);
        } else {// 视频通话
            intent.putExtra(TRTCMainActivity.KEY_APP_SCENE, TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);
        }

        // 是否使用外部采集
        boolean isCustomVideoCapture = ((RadioButton) findViewById(R.id.rb_video_file)).isChecked();
        if (TextUtils.isEmpty(mVideoFile)) isCustomVideoCapture = false;
        intent.putExtra(TRTCMainActivity.KEY_CUSTOM_CAPTURE, isCustomVideoCapture);
        intent.putExtra(TRTCMainActivity.KEY_VIDEO_FILE_PATH, mVideoFile);

        startActivity(intent);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode == Activity.RESULT_OK) {
            Uri uri = data.getData();
            if ("file".equalsIgnoreCase(uri.getScheme())) {//使用第三方应用打开
                mVideoFile = uri.getPath();
            } else {
                if (Build.VERSION.SDK_INT > Build.VERSION_CODES.KITKAT) {//4.4以后
                    mVideoFile = getPath(this, uri);
                } else {//4.4以下下系统调用方法
                    mVideoFile = getRealPathFromURI(this,uri);
                }
            }
        }

        startJoinRoom();
    }
    //////////////////////////////////    动态权限申请   ////////////////////////////////////////

    private boolean checkPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            List<String> permissions = new ArrayList<>();
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.CAMERA)) {
                permissions.add(Manifest.permission.CAMERA);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)) {
                permissions.add(Manifest.permission.RECORD_AUDIO);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)) {
                permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE);
            }
            if (permissions.size() != 0) {
                ActivityCompat.requestPermissions(TRTCNewActivity.this,
                        (String[]) permissions.toArray(new String[0]),
                        REQ_PERMISSION_CODE);
                return false;
            }
        }

        return true;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case REQ_PERMISSION_CODE:
                for (int ret : grantResults) {
                    if (PackageManager.PERMISSION_GRANTED != ret) {
                        Toast.makeText(this, "用户没有允许需要的权限，使用可能会受到限制！", Toast.LENGTH_SHORT).show();
                    }
                }
                break;
            default:
                break;
        }
    }

    private void saveUserInfo(String roomId, String userId) {
        try {
            SharedPreferences shareInfo = this.getSharedPreferences("per_data", 0);
            SharedPreferences.Editor editor = shareInfo.edit();
            editor.putString("userId", userId);
            editor.putString("roomId", roomId);
            editor.commit();
        } catch (Exception e) {

        }
    }

    private void loadUserInfo(EditText etRoomId, EditText etUserId) {
        try {
            SharedPreferences shareInfo = this.getSharedPreferences("per_data", 0);
            String userId = shareInfo.getString("userId", "");
            String roomId = shareInfo.getString("roomId", "");
            if (TextUtils.isEmpty(roomId)) {
                etRoomId.setText(String.valueOf(System.nanoTime() % 10000 + 10000));
            } else {
                etRoomId.setText(roomId);
            }
            if (TextUtils.isEmpty(userId)) {
                etUserId.setText(String.valueOf(System.currentTimeMillis() % 1000000));
            } else {
                etUserId.setText(userId);
            }
        } catch (Exception e) {

        }
    }

    private File getLastModifiedLogFile() {
        File retFile = null;

        File directory = new File("/sdcard/log/tencent/liteav");
        if (directory != null && directory.exists() && directory.isDirectory()) {
            long lastModify = 0;
            File files[] = directory.listFiles();
            if (files != null && files.length > 0) {
                for (File file : files) {
                    if (file.getName().endsWith("xlog")) {
                        if (file.lastModified() > lastModify) {
                            retFile = file;
                            lastModify = file.lastModified();
                        }
                    }
                }
            }
        }

        return retFile;
    }

}
