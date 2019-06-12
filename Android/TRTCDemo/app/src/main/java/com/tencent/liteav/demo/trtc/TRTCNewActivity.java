package com.tencent.liteav.demo.trtc;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.support.v4.app.ActivityCompat;
import android.text.TextUtils;
import android.view.View;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.demo.R;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;

import java.io.File;
import java.util.ArrayList;
import java.util.List;


/**
 * Module:   TRTCNewActivity
 *
 * Function: 该界面可以让用户输入一个【房间号】和一个【用户名】
 *
 * Notice:
 *
 *  （1）房间号为数字类型，用户名为字符串类型
 *
 *  （2）在真实的使用场景中，房间号大多不是用户手动输入的，而是系统分配的，
 *       比如视频会议中的会议号是会控系统提前预定好的，客服系统中的房间号也是根据客服员工的工号决定的。
 */
public class TRTCNewActivity extends Activity implements View.OnClickListener {
    private final static int REQ_PERMISSION_CODE = 0x1000;
    private TRTCGetUserIDAndUserSig mUserInfoLoader;
    private String mUserId = "";
    private String mUserSig= "";
    private String mVideoFile = "";
    @Override
    protected void onCreate( Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.new_activity);

        final EditText etRoomId = (EditText)findViewById(R.id.et_room_name);
        final EditText etUserId = (EditText)findViewById(R.id.et_user_name);

        loadUserInfo(etRoomId, etUserId);

        RadioButton rbLive = (RadioButton) findViewById(R.id.rb_live);
        rbLive.setOnClickListener(this);

        RadioButton rbVideoCall = (RadioButton) findViewById(R.id.rb_videocall);
        rbVideoCall.setChecked(true);
        rbVideoCall.setOnClickListener(this);

        RadioButton rbAnchor = (RadioButton) findViewById(R.id.rb_anchor);
        rbAnchor.setChecked(true);

        RadioButton rbCamera = (RadioButton) findViewById(R.id.rb_camera);
        rbCamera.setChecked(true);

        TextView title = (TextView) findViewById(R.id.main_title);
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

        TextView tvEnterRoom = (TextView)findViewById(R.id.tv_enter);
        tvEnterRoom.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (((RadioButton)findViewById(R.id.rb_video_file)).isChecked()) {
                    Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
                    intent.setType("video/*");
//                    intent.addCategory(Intent.CATEGORY_OPENABLE);
                    startActivityForResult(intent, 1);
                    return;
                }
                startJoinRoom();
            }
        });

        // 如果配置有config文件，则从config文件中选择userId
        mUserInfoLoader = new TRTCGetUserIDAndUserSig(this);
        final ArrayList<String> userIds = mUserInfoLoader.getUserIdFromConfig();
        if (userIds != null && userIds.size() > 0) {
            TRTCUserSelectDialog dialog = new TRTCUserSelectDialog(getContext(), mUserInfoLoader.getUserIdFromConfig());
            dialog.setTitle("请选择登录的用户:");
            dialog.setCanceledOnTouchOutside(false);
            dialog.setOnItemClickListener(new TRTCUserSelectDialog.onItemClickListener() {
                @Override
                public void onItemClick(int position) {
                    final EditText etUserId = (EditText)findViewById(R.id.et_user_name);
                    etUserId.setText(userIds.get(position));
                    etUserId.setEnabled(false);
                }
            });
            dialog.show();
        }
        else {
            showAlertDialog();
        }

        // 申请动态权限
        checkPermission();
    }
    /**
     *  Function: 读取用户输入，并创建（或加入）音视频房间
     *
     *  此段示例代码最主要的作用是组装 TRTC SDK 进房所需的 TRTCParams
     *
     *  TRTCParams.sdkAppId => 可以在腾讯云实时音视频控制台（https://console.cloud.tencent.com/rav）获取
     *  TRTCParams.userId   => 此处即用户输入的用户名，它是一个字符串
     *  TRTCParams.roomId   => 此处即用户输入的音视频房间号，比如 125
     *  TRTCParams.userSig  => 此处示例代码展示了两种获取 usersig 的方式，一种是从【控制台】获取，一种是从【服务器】获取
     *
     * （1）控制台获取：可以获得几组已经生成好的 userid 和 usersig，他们会被放在一个 json 格式的配置文件中，仅适合调试使用
     * （2）服务器获取：直接在服务器端用我们提供的源代码，根据 userid 实时计算 usersig，这种方式安全可靠，适合线上使用
     *
     *  参考文档：https://cloud.tencent.com/document/product/647/17275
     */
    private void onJoinRoom(final int roomId, final String userId) {
        final Intent intent = new Intent(getContext(), TRTCMainActivity.class);
        intent.putExtra("roomId", roomId);
        intent.putExtra("userId", userId);

        RadioButton rbLive = (RadioButton) findViewById(R.id.rb_live);
        if (rbLive.isChecked()) {
            intent.putExtra("AppScene", TRTCCloudDef.TRTC_APP_SCENE_LIVE);
            RadioButton rbAnchor = (RadioButton) findViewById(R.id.rb_anchor);
            if (rbAnchor.isChecked())  {
                intent.putExtra("role", TRTCCloudDef.TRTCRoleAnchor);
            } else {
                intent.putExtra("role", TRTCCloudDef.TRTCRoleAudience);
            }
        } else {
            intent.putExtra("AppScene", TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);
        }


        boolean isCustomVideoCapture = ((RadioButton)findViewById(R.id.rb_video_file)).isChecked();
        if (TextUtils.isEmpty(mVideoFile)) isCustomVideoCapture = false;
        intent.putExtra("customVideoCapture", isCustomVideoCapture);
        intent.putExtra("videoFile", mVideoFile);

        int sdkAppId = mUserInfoLoader.getSdkAppIdFromConfig();
        if (sdkAppId > 0) {
            //（1） 从控制台获取的 json 文件中，简单获取几组已经提前计算好的 userid 和 usersig
            ArrayList<String> userIdList = mUserInfoLoader.getUserIdFromConfig();
            ArrayList<String> userSigList = mUserInfoLoader.getUserSigFromConfig();
            int position = userIdList.indexOf(userId);
            String userSig = "";
            if (userSigList != null && userSigList.size() > position) {
                userSig = userSigList.get(position);
            }
            intent.putExtra("sdkAppId", sdkAppId);
            intent.putExtra("userSig", userSig);
            startActivity(intent);
        } else {
            //appId 可以在腾讯云实时音视频控制台（https://console.cloud.tencent.com/rav）获取
            sdkAppId = -1;
            if(!TextUtils.isEmpty(mUserId) && mUserId.equalsIgnoreCase(userId) && !TextUtils.isEmpty(mUserSig)) {
                intent.putExtra("sdkAppId", sdkAppId);
                intent.putExtra("userSig", mUserSig);
                saveUserInfo(String.valueOf(roomId), userId, mUserSig);
                startActivity(intent);
            } else {
                //（2） 通过 http 协议向一台服务器获取 userid 对应的 usersig
                final int finalSdkAppId = sdkAppId;
                mUserInfoLoader.getUserSigFromServer(sdkAppId, roomId, userId, "12345678", new TRTCGetUserIDAndUserSig.IGetUserSigListener() {
                    @Override
                    public void onComplete(String userSig, String errMsg) {
                        if (!TextUtils.isEmpty(userSig)) {
                            intent.putExtra("sdkAppId", finalSdkAppId);
                            intent.putExtra("userSig", userSig);
                            saveUserInfo(String.valueOf(roomId), userId, userSig);
                            startActivity(intent);
                        } else {
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    Toast.makeText(getContext(), "从服务器获取userSig失败", Toast.LENGTH_SHORT).show();
                                }
                            });
                        }
                    }
                });
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

    }

    private void startJoinRoom() {
        final EditText etRoomId = (EditText)findViewById(R.id.et_room_name);
        final EditText etUserId = (EditText)findViewById(R.id.et_user_name);
        int roomId = 123;
        try{
            roomId = Integer.valueOf(etRoomId.getText().toString());
        }catch (Exception e){
            Toast.makeText(getContext(), "请输入有效的房间号", Toast.LENGTH_SHORT).show();
            return;
        }
        final String userId = etUserId.getText().toString();
        if(TextUtils.isEmpty(userId)) {
            Toast.makeText(getContext(), "请输入有效的用户名", Toast.LENGTH_SHORT).show();
            return;
        }

        onJoinRoom(roomId, userId);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode == Activity.RESULT_OK) {
            Uri uri = data.getData();
            if ("file".equalsIgnoreCase(uri.getScheme())){//使用第三方应用打开
                mVideoFile = uri.getPath();
            } else {
                if (Build.VERSION.SDK_INT > Build.VERSION_CODES.KITKAT) {//4.4以后
                    mVideoFile = getPath(this, uri);
                } else {//4.4以下下系统调用方法
                    mVideoFile = getRealPathFromURI(uri);
                }
            }
        }

        startJoinRoom();
    }

    private Context getContext(){
        return this;
    }

    private void showAlertDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("注意")
                .setMessage("读取配置文件失败，请在【控制台】->【快速上手】中生成配置内容复制到config.json文件");
        AlertDialog alertDialog = builder.create();
        alertDialog.setCanceledOnTouchOutside(true);
        alertDialog.show();
    }
    //////////////////////////////////    动态权限申请   ////////////////////////////////////////

    private boolean checkPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            List<String> permissions = new ArrayList<>();
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(getContext(), Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(getContext(), Manifest.permission.CAMERA)) {
                permissions.add(Manifest.permission.CAMERA);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(getContext(), Manifest.permission.RECORD_AUDIO)) {
                permissions.add(Manifest.permission.RECORD_AUDIO);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(getContext(), Manifest.permission.READ_EXTERNAL_STORAGE)) {
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
                        Toast.makeText(getContext(), "用户没有允许需要的权限，使用可能会受到限制！", Toast.LENGTH_SHORT).show();
                    }
                }
                break;
            default:
                break;
        }
    }

    private void saveUserInfo(String roomId, String userId, String userSig) {
        try {
            mUserId = userId;
            mUserSig= userSig;
            SharedPreferences shareInfo = this.getSharedPreferences("per_data", 0);
            SharedPreferences.Editor editor = shareInfo.edit();
            editor.putString("userId", userId);
            editor.putString("roomId", roomId);
            editor.putString("userSig", userSig);
            editor.putLong("userTime", System.currentTimeMillis());
            editor.commit();
        } catch (Exception e) {

        }
    }

    private void loadUserInfo(EditText etRoomId, EditText etUserId) {
        try {
            TRTCCloud.getSDKVersion();
            SharedPreferences shareInfo = this.getSharedPreferences("per_data", 0);
            mUserId = shareInfo.getString("userId", "");
            String roomId = shareInfo.getString("roomId", "");
            mUserSig= shareInfo.getString("userSig", "");
            if (TextUtils.isEmpty(roomId)) {
                etRoomId.setText("999");
            } else {
                etRoomId.setText(roomId);
            }
            if (TextUtils.isEmpty(mUserId)) {
                etUserId.setText(String.valueOf(System.currentTimeMillis() % 1000000));
            } else {
                etUserId.setText(mUserId);
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

    public String getRealPathFromURI(Uri contentUri) {
        String res = null;
        String[] proj = { MediaStore.Images.Media.DATA };
        Cursor cursor = getContentResolver().query(contentUri, proj, null, null, null);
        if(null!=cursor&&cursor.moveToFirst()){;
            int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
            res = cursor.getString(column_index);
            cursor.close();
        }
        return res;
    }

    /**
     * 专为Android4.4设计的从Uri获取文件绝对路径，以前的方法已不好使
     */
    public String getPath(final Context context, final Uri uri) {

        final boolean isKitKat = Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT;

        // DocumentProvider
        if (isKitKat && DocumentsContract.isDocumentUri(context, uri)) {
            // ExternalStorageProvider
            if (isExternalStorageDocument(uri)) {
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];

                if ("primary".equalsIgnoreCase(type)) {
                    return Environment.getExternalStorageDirectory() + "/" + split[1];
                }
            }
            // DownloadsProvider
            else if (isDownloadsDocument(uri)) {

                final String id = DocumentsContract.getDocumentId(uri);
                final Uri contentUri = ContentUris.withAppendedId(
                        Uri.parse("content://downloads/public_downloads"), Long.valueOf(id));

                return getDataColumn(context, contentUri, null, null);
            }
            // MediaProvider
            else if (isMediaDocument(uri)) {
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];

                Uri contentUri = null;
                if ("image".equals(type)) {
                    contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                } else if ("video".equals(type)) {
                    contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                } else if ("audio".equals(type)) {
                    contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                }

                final String selection = "_id=?";
                final String[] selectionArgs = new String[]{split[1]};

                return getDataColumn(context, contentUri, selection, selectionArgs);
            }
        }
        // MediaStore (and general)
        else if ("content".equalsIgnoreCase(uri.getScheme())) {
            return getDataColumn(context, uri, null, null);
        }
        // File
        else if ("file".equalsIgnoreCase(uri.getScheme())) {
            return uri.getPath();
        }
        return null;
    }

    public String getDataColumn(Context context, Uri uri, String selection,
                                String[] selectionArgs) {

        Cursor cursor = null;
        final String column = "_data";
        final String[] projection = {column};

        try {
            cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs,
                    null);
            if (cursor != null && cursor.moveToFirst()) {
                final int column_index = cursor.getColumnIndexOrThrow(column);
                return cursor.getString(column_index);
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }
        return null;
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is ExternalStorageProvider.
     */
    public boolean isExternalStorageDocument(Uri uri) {
        return "com.android.externalstorage.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is DownloadsProvider.
     */
    public boolean isDownloadsDocument(Uri uri) {
        return "com.android.providers.downloads.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is MediaProvider.
     */
    public boolean isMediaDocument(Uri uri) {
        return "com.android.providers.media.documents".equals(uri.getAuthority());
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        switch (id) {
            case R.id.rb_live: {
                findViewById(R.id.role).setVisibility(View.VISIBLE);
                break;
            }
            case R.id.rb_videocall: {
                findViewById(R.id.role).setVisibility(View.GONE);
                break;
            }
        }
    }
}
