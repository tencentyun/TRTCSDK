package com.tencent.liteav.demo.trtc;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.media.MediaFormat;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.app.ActivityCompat;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.blankj.utilcode.util.SizeUtils;
import com.tencent.liteav.debug.GenerateTestUserSig;
import com.tencent.liteav.demo.trtc.customcapture.utils.MediaUtils;
import com.tencent.liteav.demo.trtc.widget.settingitem.BaseSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.CheckBoxSettingItem;
import com.tencent.liteav.demo.trtc.widget.settingitem.RadioButtonSettingItem;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import static com.tencent.liteav.demo.trtc.TRTCVideoRoomActivity.KEY_AUDIO_EARPIECEMODE;
import static com.tencent.liteav.demo.trtc.TRTCVideoRoomActivity.KEY_AUDIO_VOLUMETYOE;
import static com.tencent.liteav.demo.trtc.TRTCVideoRoomActivity.KEY_RECEIVED_AUDIO;
import static com.tencent.liteav.demo.trtc.TRTCVideoRoomActivity.KEY_RECEIVED_VIDEO;
import static com.tencent.liteav.demo.trtc.utils.Utils.getPath;
import static com.tencent.liteav.demo.trtc.utils.Utils.getRealPathFromURI;

/**
 * Module:   TRTCNewRoomActivity
 * Function: 该界面可以让用户输入一个【房间号】和一个【用户名】
 * Notice:
 * 1. 房间号为数字类型，用户名为字符串类型
 * <p>
 * 2. 在真实的使用场景中，房间号大多不是用户手动输入的，而是系统分配的，
 * 比如视频会议中的会议号是会控系统提前预定好的，客服系统中的房间号也是根据客服员工的工号决定的。
 * <p>
 * 3. 【*****】目前 Demo 为了方便您接入，使用的是本地签发 sig 的方式，您的项目上线，务必要保证将签发逻辑转移到服务端，否者会出现 key 被盗用，流量盗用的风险。
 * 4. {@link TRTCNewRoomActivity#startJoinRoomInternal(int, String)} 中您可以了解到进房有两种模式分别对应【视频通话】和【视频互动直播】
 */
public class TRTCNewRoomActivity extends Activity {
    private static final String TAG = "TRTCNewRoomActivity";

    private static final int INDEX_AUDIO_VOLUME_TYPE_MEDIA       = 1;
    private static final int INDEX_AUDIO_VOLUME_TYPE_NO_SELECTED = 3;

    private final static int                    REQ_PERMISSION_CODE  = 0x1000;
    private              String                 mVideoFile           = "";
    /**
     * 0 视频通话，1在线直播
     */
    public static final  int                    TRTC_VOICECALL       = 0;
    public static final  int                    TRTC_LIVE            = 1;
    private              int                    mCurrentType;
    /**
     * 接收模式
     * 可以参考 {@link TRTCCloud#setDefaultStreamRecvMode(boolean, boolean)} 中的操作
     */
    private              boolean                mReceivedVideo       = true;
    private              boolean                mReceivedAudio       = true;
    private              Handler                mUiHandler           = new Handler(Looper.getMainLooper());
    private              LinearLayout           mContainerLl;
    private              List<BaseSettingItem>  mSettingItemList;
    private              RadioButtonSettingItem mInputItem;
    private              RadioButtonSettingItem mRoleItem;
    private              RadioButtonSettingItem mVideoReceivedItem;
    private              RadioButtonSettingItem mAudioReceivedItem;
    private              RadioButtonSettingItem mAudioVolumeTypeItem;
    private              int                    mAudioVolumeType     = TRTCCloudDef.TRTCSystemVolumeTypeAuto;
    private              CheckBoxSettingItem    mAudioEarpieceModeItem;
    private              boolean                mIsAudioEarpieceMode = false;
    private              Toolbar                mToolbar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.trtc_activity_new_room);
        mCurrentType = getIntent().getIntExtra("TYPE", TRTC_VOICECALL);
        String name = getIntent().getStringExtra("TITLE");
        mContainerLl = (LinearLayout) findViewById(R.id.ll_container);
        final EditText etRoomId = (EditText) findViewById(R.id.et_room_name);
        final EditText etUserId = (EditText) findViewById(R.id.et_user_name);
        loadUserInfo(etRoomId, etUserId);
        mSettingItemList = new ArrayList<>();
        BaseSettingItem.ItemText itemText = new BaseSettingItem.ItemText("视频输入", "前摄像头", "视频文件", "录屏");
        mInputItem = new RadioButtonSettingItem(this, itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                        if (mAudioVolumeTypeItem == null) {
                            return;
                        }
                        // 这里会设置选择视频文件的时候音量类型默认使用媒体音量
                        if (index == 1) {
                            mAudioVolumeTypeItem.setSelect(INDEX_AUDIO_VOLUME_TYPE_MEDIA);
                            mAudioVolumeTypeItem.getView().setVisibility(View.GONE);
                        } else {
                            mAudioVolumeTypeItem.setSelect(INDEX_AUDIO_VOLUME_TYPE_NO_SELECTED);
                            mAudioVolumeTypeItem.getView().setVisibility(View.VISIBLE);
                        }
                    }
                });
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        mSettingItemList.add(mInputItem);
        // 直播的情况下增加角色选择的item
        if (mCurrentType == TRTC_LIVE) {
            itemText =
                    new BaseSettingItem.ItemText("角色选择", "上麦主播", "普通观众");
            mRoleItem = new RadioButtonSettingItem(this, itemText,
                    new RadioButtonSettingItem.SelectedListener() {
                        @Override
                        public void onSelected(int index) {
                        }
                    });
            mSettingItemList.add(mRoleItem);
        }
        itemText =
                new BaseSettingItem.ItemText("视频接收", "自动", "手动");
        mVideoReceivedItem = new RadioButtonSettingItem(this, itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                    }
                });
        mSettingItemList.add(mVideoReceivedItem);
        itemText =
                new BaseSettingItem.ItemText("音频接收", "自动", "手动");
        mAudioReceivedItem = new RadioButtonSettingItem(this, itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                    }
                });
        mSettingItemList.add(mAudioReceivedItem);

        itemText =
                new BaseSettingItem.ItemText("音量的类型", "自动", "媒体", "通话", "不选");
        mAudioVolumeTypeItem = new RadioButtonSettingItem(this, itemText,
                new RadioButtonSettingItem.SelectedListener() {
                    @Override
                    public void onSelected(int index) {
                    }
                });
        mSettingItemList.add(mAudioVolumeTypeItem);

        itemText =
                new BaseSettingItem.ItemText("听筒模式", "");
        mAudioEarpieceModeItem = new CheckBoxSettingItem(this, itemText,
                new CheckBoxSettingItem.ClickListener() {
                    @Override
                    public void onClick() {
                        mIsAudioEarpieceMode = mAudioEarpieceModeItem.getChecked();
                        Log.e(TAG, "startJoinRoomInternal getChecked() SetAudioRoute:" + mIsAudioEarpieceMode);
                    }
                });
        mSettingItemList.add(mAudioEarpieceModeItem);

        mAudioEarpieceModeItem.setCheck(mIsAudioEarpieceMode);
        mAudioVolumeTypeItem.setSelect(INDEX_AUDIO_VOLUME_TYPE_NO_SELECTED);

        // 将这些view添加到对应的容器中
        for (BaseSettingItem item : mSettingItemList) {
            View view = item.getView();
            view.setPadding(0, SizeUtils.dp2px(5), 0, 0);
            mContainerLl.addView(view);
        }

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
                    Toast.makeText(TRTCNewRoomActivity.this.getApplicationContext(), "日志文件不存在！", Toast.LENGTH_SHORT);
                }
                return false;
            }
        });

        TextView tvEnterRoom = (TextView) findViewById(R.id.tv_enter);
        tvEnterRoom.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mInputItem.getSelected() == 1) {
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
        // 这里对房间号和用户名的有效性进行校验
        final EditText etRoomId = (EditText) findViewById(R.id.et_room_name);
        final EditText etUserId = (EditText) findViewById(R.id.et_user_name);
        int            roomId   = 123;
        try {
            roomId = Long.valueOf(etRoomId.getText().toString()).intValue();
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
     * 目前 Demo 为了方便您接入，使用的是本地签发 sig 的方式，您的项目上线，务必要保证将签发逻辑转移到服务端，否者会出现 key 被盗用，流量盗用的风险。
     * <p>
     * 参考文档：https://cloud.tencent.com/document/product/647/17275
     */
    private void startJoinRoomInternal(final int roomId, final String userId) {
        final Intent intent = new Intent(this, TRTCVideoRoomActivity.class);
        // sdkAppId 和 userSig
        // 【*****】目前 Demo 为了方便您接入，使用的是本地签发 sig 的方式，您的项目上线，务必要保证将签发逻辑转移到服务端，否者会出现 key 被盗用，流量盗用的风险。
        // 【*****】目前 Demo 为了方便您接入，使用的是本地签发 sig 的方式，您的项目上线，务必要保证将签发逻辑转移到服务端，否者会出现 key 被盗用，流量盗用的风险。
        // 【*****】目前 Demo 为了方便您接入，使用的是本地签发 sig 的方式，您的项目上线，务必要保证将签发逻辑转移到服务端，否者会出现 key 被盗用，流量盗用的风险。
        int    sdkAppId = GenerateTestUserSig.SDKAPPID;
        String userSig  = GenerateTestUserSig.genTestUserSig(userId);
        intent.putExtra(TRTCVideoRoomActivity.KEY_SDK_APP_ID, sdkAppId);
        intent.putExtra(TRTCVideoRoomActivity.KEY_USER_SIG, userSig);

        // roomId userId
        intent.putExtra(TRTCVideoRoomActivity.KEY_ROOM_ID, roomId);
        intent.putExtra(TRTCVideoRoomActivity.KEY_USER_ID, userId);

        saveUserInfo(String.valueOf(roomId), userId);

        // 模式选择
        if (mCurrentType == TRTC_LIVE) {// 直播低延时大房间
            intent.putExtra(TRTCVideoRoomActivity.KEY_APP_SCENE, TRTCCloudDef.TRTC_APP_SCENE_LIVE);
            intent.putExtra(TRTCVideoRoomActivity.KEY_ROLE, mRoleItem.getSelected() == 0 ? TRTCCloudDef.TRTCRoleAnchor : TRTCCloudDef.TRTCRoleAudience);
        } else {// 视频通话
            intent.putExtra(TRTCVideoRoomActivity.KEY_APP_SCENE, TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);
        }

        // 是否使用外部采集
        if (mInputItem.getSelected() == 1 && !TextUtils.isEmpty(mVideoFile)) {
            intent.putExtra(TRTCVideoRoomActivity.KEY_CUSTOM_CAPTURE, true);
            intent.putExtra(TRTCVideoRoomActivity.KEY_VIDEO_FILE_PATH, mVideoFile);
        } else if (mInputItem.getSelected() == 2) {
            intent.putExtra(TRTCVideoRoomActivity.KEY_SCREEN_CAPTURE, true);
        }

        // 接收模式
        mReceivedVideo = (mVideoReceivedItem.getSelected() == 0);
        mReceivedAudio = (mAudioReceivedItem.getSelected() == 0);
        int index = mAudioVolumeTypeItem.getSelected();
        //"音量的类型",  "自动T", "媒体T","通话T"
        if (0 == index) {
            mAudioVolumeType = TRTCCloudDef.TRTCSystemVolumeTypeAuto;
            Log.e(TAG, "startJoinRoomInternal mAudioVolumeType: TRTCSystemVolumeTypeAuto");
        } else if (1 == index) {
            mAudioVolumeType = TRTCCloudDef.TRTCSystemVolumeTypeMedia;
            Log.e(TAG, "startJoinRoomInternal mAudioVolumeType: TRTCSystemVolumeTypeMedia");
        } else if (2 == index) {
            mAudioVolumeType = TRTCCloudDef.TRTCSystemVolumeTypeVOIP;
            Log.e(TAG, "startJoinRoomInternal mAudioVolumeType: TRTCSystemVolumeTypeVOIP");
        } else {
            mAudioVolumeType = -1;
            Log.e(TAG, "startJoinRoomInternal mAudioVolumeType: TRTCSystemVolumeTypeAuto");
        }

        intent.putExtra(KEY_AUDIO_VOLUMETYOE, mAudioVolumeType);

        Log.e(TAG, "startJoinRoomInternal EarpieceMode:" + mIsAudioEarpieceMode);
        intent.putExtra(KEY_AUDIO_EARPIECEMODE, mIsAudioEarpieceMode);
        intent.putExtra(KEY_RECEIVED_VIDEO, mReceivedVideo);
        intent.putExtra(KEY_RECEIVED_AUDIO, mReceivedAudio);
        startActivity(intent);
    }

    private Runnable mDelayStartJoinRoom = new Runnable() {
        @Override
        public void run() {
            startJoinRoom();
        }
    };

    @Override
    protected void onStop() {
        super.onStop();
        mUiHandler.removeCallbacks(mDelayStartJoinRoom);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        boolean needDelay = false;
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
                if (sampleRate != 48000 || channelCount != 1) {
                    Toast.makeText(this, "音频仅支持采样率48000、单声道，请重新选择！", Toast.LENGTH_SHORT).show();
                    mVideoFile = null;
                    needDelay = true;
                }
            } catch (Exception e) {
                Log.e(TAG, "Failed to open file " + mVideoFile);
                Toast.makeText(this, "打开文件失败!", Toast.LENGTH_LONG).show();
                mVideoFile = null;
                needDelay = true;
            }
        }

        if (needDelay) {
            // 有错误出现时，延时一点再进房，防止错误提示被冲掉
            mUiHandler.postDelayed(mDelayStartJoinRoom, 2000);
        } else {
            startJoinRoom();
        }
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
                ActivityCompat.requestPermissions(TRTCNewRoomActivity.this,
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
            SharedPreferences        shareInfo = this.getSharedPreferences("per_data", 0);
            SharedPreferences.Editor editor    = shareInfo.edit();
            editor.putString("userId", userId);
            editor.putString("roomId", roomId);
            editor.commit();
        } catch (Exception e) {

        }
    }

    private void loadUserInfo(EditText etRoomId, EditText etUserId) {
        try {
            SharedPreferences shareInfo = this.getSharedPreferences("per_data", 0);
            String            userId    = shareInfo.getString("userId", "");
            String            roomId    = shareInfo.getString("roomId", "");
            if (TextUtils.isEmpty(roomId)) {
                etRoomId.setText(String.valueOf(System.currentTimeMillis() % 10000 + 10000));
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
        File retFile   = null;
        File sdcardDir = getExternalFilesDir(null);
        if (sdcardDir == null) {
            return null;
        }
        String pathname  = sdcardDir.getAbsolutePath() + "/log/tencent/liteav";
        File   directory = new File(pathname);
        if (directory != null && directory.exists() && directory.isDirectory()) {
            long lastModify = 0;
            File files[]    = directory.listFiles();
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
