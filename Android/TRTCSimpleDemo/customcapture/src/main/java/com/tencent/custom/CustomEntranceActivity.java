package com.tencent.custom;

import android.app.Activity;
import android.content.Intent;
import android.media.MediaFormat;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.custom.customcapture.utils.MediaUtils;
import com.tencent.liteav.debug.Constant;

import static com.tencent.custom.Utils.getPath;
import static com.tencent.custom.Utils.getRealPathFromURI;

/**
 * RTC视频通话的入口页面（可以设置房间id和用户id）
 * <p>
 * RTC视频通话是基于房间来实现的，通话的双方要进入一个相同的房间id才能进行视频通话
 */
public class CustomEntranceActivity extends AppCompatActivity {
    private static final String TAG = "CustomEntranceActivity";

    private EditText mInputUserId;
    private EditText mInputRoomId;
    private String   mVideoFile;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_custom_entrance);
        getSupportActionBar().hide();
        mInputUserId = findViewById(R.id.et_input_username);
        mInputRoomId = findViewById(R.id.et_input_room_id);
        findViewById(R.id.bt_enter_room).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
                intent.setType("video/*");
                startActivityForResult(intent, 1);
            }
        });
        findViewById(R.id.rtc_entrance_main).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                hideInput(); // 点击非EditText输入区域，隐藏键盘
            }
        });
        findViewById(R.id.entrance_ic_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();  // 返回结束
            }
        });
        mInputRoomId.setText("1256732");
        String time   = String.valueOf(System.currentTimeMillis());
        String userId = time.substring(time.length() - 8);
        mInputUserId.setText(userId);
    }

    private void startEnterRoom() {
        if (TextUtils.isEmpty(mInputUserId.getText().toString().trim())
                || TextUtils.isEmpty(mInputRoomId.getText().toString().trim())) {
            Toast.makeText(CustomEntranceActivity.this, getString(R.string.custom_room_input_error_tip), Toast.LENGTH_LONG).show();
            return;
        }

        Intent intent = new Intent(CustomEntranceActivity.this, CustomCaptureActivity.class);
        intent.putExtra(Constant.ROOM_ID, mInputRoomId.getText().toString().trim());
        intent.putExtra(Constant.USER_ID, mInputUserId.getText().toString().trim());
        intent.putExtra(Constant.CUSTOM_VIDEO, mVideoFile);
        startActivity(intent);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == Activity.RESULT_OK) {
            Uri uri = data.getData();
            if ("file".equalsIgnoreCase(uri.getScheme())) {//使用第三方应用打开
                mVideoFile = uri.getPath();
            } else {
                if (Build.VERSION.SDK_INT > Build.VERSION_CODES.KITKAT) {//4.4以后
                    mVideoFile = getPath(this, uri);
                } else {//4.4以下下系统调用方法
                    mVideoFile = getRealPathFromURI(this, uri);
                }
            }

            try {
                MediaFormat mediaFormat  = MediaUtils.retriveMediaFormat(mVideoFile, false);
                int         sampleRate   = mediaFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE);
                int         channelCount = mediaFormat.getInteger(MediaFormat.KEY_CHANNEL_COUNT);
            } catch (Exception e) {
                Log.e(TAG, "Failed to open file " + mVideoFile);
                Toast.makeText(this, "打开文件失败!", Toast.LENGTH_LONG).show();
                mVideoFile = null;
                return;
            }
            startEnterRoom();
        }
    }

    /**
     * 隐藏键盘
     */
    protected void hideInput() {
        InputMethodManager imm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
        View               v   = getWindow().peekDecorView();
        if (null != v) {
            imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
        }
    }

}
