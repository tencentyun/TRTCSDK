package com.tencent.trtc.renderparams;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.PopupMenu;

import com.example.basic.TRTCBaseActivity;
import com.tencent.liteav.TXLiteAVCode;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.debug.GenerateTestUserSig;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * TRTC视频渲染控制页面
 *
 * 包含如下简单功能：
 * - 设置本地视频渲染参数{@link TRTCCloud#setLocalRenderParams(TRTCCloudDef.TRTCRenderParams)}
 * - 设置远端视频渲染参数{@link TRTCCloud#setRemoteRenderParams(String, int, TRTCCloudDef.TRTCRenderParams)}
 *
 * - 详见API说明文档{https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#afe6ea1bf7c959722595356a9b7fc2179}
 */

/**
 * Video Rendering Control
 *
 * Features:
 * - Set rendering parameters for local video: {@link TRTCCloud#setLocalRenderParams(TRTCCloudDef.TRTCRenderParams)}
 * - Set rendering parameters for remote video: {@link TRTCCloud#setRemoteRenderParams(String, int, TRTCCloudDef.TRTCRenderParams)}
 *
 * - For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#afe6ea1bf7c959722595356a9b7fc2179}.
 */
public class SetRenderParamsActivity extends TRTCBaseActivity implements View.OnClickListener {

    private static final String     TAG                     = "SetRenderParamsActivity";

    private ImageView               mImageBack;
    private TextView                mTextTitle;
    private EditText                mEditRoomId;
    private EditText                mEdituserId;
    private Button                  mButtonStartPush;
    private LinearLayout            mLLLocalMode;
    private TextView                mTextLocalMode;
    private LinearLayout            mLLLocalMirror;
    private TextView                mTextLocalMirror;
    private LinearLayout            mLLLocalRotate;
    private TextView                mTextLocalRotate;
    private LinearLayout            mLLRemoteMode;
    private TextView                mTextRemoteMode;
    private LinearLayout            mLLRemoteRotate;
    private TextView                mTextRemoteRotate;
    private LinearLayout            mLLRemoteUserId;
    private TextView                mTextRemoteUserId;
    private TXCloudVideoView        mTXCloudPreviousView;
    private List<TXCloudVideoView>  mRemoteVideoList;
    private List<TextView>          mRemoteUserviewList;

    private TRTCCloud               mTRTCCloud;
    private List<String>            mRemoteUserIdList;
    private boolean                 mStartPushFlag      = false;
    private int                     mLocalRoateFlag     = TRTCCloudDef.TRTC_VIDEO_ROTATION_0;
    private int                     mLocalModeFlag      = TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL;
    private int                     mLocalMirrorFlag    = TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO;
    private int                     mRemoteRoateFlag    = TRTCCloudDef.TRTC_VIDEO_ROTATION_0;
    private int                     mRemoteModeFlag     = TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.renderparams_activity_set);
        getSupportActionBar().hide();

        if (checkPermission()) {
            initView();
        }
    }

    private void initView() {
        mRemoteUserIdList       = new ArrayList<>();
        mRemoteVideoList        = new ArrayList<>();
        mRemoteUserviewList     = new ArrayList<>();

        mImageBack              = findViewById(R.id.iv_back);
        mTextTitle              = findViewById(R.id.tv_room_number);
        mButtonStartPush        = findViewById(R.id.btn_start_push);
        mEditRoomId             = findViewById(R.id.et_room_id);
        mEdituserId             = findViewById(R.id.et_user_id);

        mLLLocalRotate          = findViewById(R.id.ll_local_rotate);
        mTextLocalRotate        = findViewById(R.id.tv_local_rotate);
        mLLLocalMirror          = findViewById(R.id.ll_local_mirror);
        mTextLocalMirror        = findViewById(R.id.tv_local_mirror);
        mLLLocalMode            = findViewById(R.id.ll_local_mode);
        mTextLocalMode          = findViewById(R.id.tv_local_mode);

        mLLRemoteRotate         = findViewById(R.id.ll_remote_rotate);
        mTextRemoteRotate       = findViewById(R.id.tv_remote_rotate);
        mLLRemoteMode           = findViewById(R.id.ll_remote_mode);
        mTextRemoteMode         = findViewById(R.id.tv_remote_mode);
        mLLRemoteUserId         = findViewById(R.id.ll_remote_userid);
        mTextRemoteUserId       = findViewById(R.id.tv_remote_userid);
        mTXCloudPreviousView    = findViewById(R.id.txcvv_main_local);

        mRemoteUserviewList.add((TextView) findViewById(R.id.tv_remote_user1));
        mRemoteUserviewList.add((TextView) findViewById(R.id.tv_remote_user2));
        mRemoteUserviewList.add((TextView) findViewById(R.id.tv_remote_user3));
        mRemoteUserviewList.add((TextView) findViewById(R.id.tv_remote_user4));
        mRemoteUserviewList.add((TextView) findViewById(R.id.tv_remote_user5));
        mRemoteUserviewList.add((TextView) findViewById(R.id.tv_remote_user6));

        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote1));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote2));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote3));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote4));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote5));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote6));

        mImageBack.setOnClickListener(this);
        mLLLocalRotate.setOnClickListener(this);
        mLLLocalMirror.setOnClickListener(this);
        mLLLocalMode.setOnClickListener(this);
        mLLRemoteMode.setOnClickListener(this);
        mLLRemoteRotate.setOnClickListener(this);
        mButtonStartPush.setOnClickListener(this);
        mLLRemoteUserId.setOnClickListener(this);

        mEdituserId.setText(new Random().nextInt(100000) + 1000000 + "");
        mTextTitle.setText(getString(R.string.renderparams_roomid) + ":" + mEditRoomId.getText().toString());
    }

    private void showPopupMenu(View view) {
        PopupMenu popupMenu = new PopupMenu(this, view, Gravity.TOP);
        popupMenu.getMenuInflater().inflate(R.menu.renderparams_mode, popupMenu.getMenu());
        popupMenu.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                Toast.makeText(getApplicationContext(), item.getTitle(), Toast.LENGTH_SHORT).show();
                return false;
            }
        });

        popupMenu.show();
    }

    @Override
    public void onClick(View view) {
        if(view.getId() == R.id.iv_back){
            finish();
        }else if(view.getId() == R.id.btn_start_push){
            String roomId = mEditRoomId.getText().toString();
            String userId = mEdituserId.getText().toString();
            if(!mStartPushFlag){
                if(!TextUtils.isEmpty(roomId) && !TextUtils.isEmpty(userId)){
                    mButtonStartPush.setText(getString(R.string.renderparams_stop_push));
                    enterRoom(roomId, userId);
                    mStartPushFlag = true;
                }else{
                    Toast.makeText(SetRenderParamsActivity.this, getString(R.string.renderparams_please_input_roomid_and_userid), Toast.LENGTH_SHORT).show();
                }
            }else{
                mButtonStartPush.setText(getString(R.string.renderparams_start_push));
                exitRoom();
                mStartPushFlag = false;
            }
        }else if(view.getId() == R.id.ll_local_rotate){
            if(!mStartPushFlag){
                Toast.makeText(SetRenderParamsActivity.this, getString(R.string.renderparams_please_start_push), Toast.LENGTH_SHORT).show();
                return;
            }
            showLocalRotateMenu();
        }else if(view.getId() == R.id.ll_local_mirror){
            if(!mStartPushFlag){
                Toast.makeText(SetRenderParamsActivity.this, getString(R.string.renderparams_please_start_push), Toast.LENGTH_SHORT).show();
                return;
            }
            showLocalMirrorMenu();
        }else if(view.getId() == R.id.ll_local_mode){
            if(!mStartPushFlag){
                Toast.makeText(SetRenderParamsActivity.this, getString(R.string.renderparams_please_start_push), Toast.LENGTH_SHORT).show();
                return;
            }
            showLocalModeMenu();
        }else if(view.getId() == R.id.ll_remote_rotate){
            String remoteId = mTextRemoteUserId.getText().toString();
            if(!TextUtils.isEmpty(remoteId) && mRemoteUserIdList.contains(remoteId)){
                showRemoteRotateMenu();
            }else{
                Toast.makeText(SetRenderParamsActivity.this, getString(R.string.renderparams_plsase_ensure_remote_userid), Toast.LENGTH_SHORT).show();
            }
        }else if(view.getId() == R.id.ll_remote_mode){
            String remoteId = mTextRemoteUserId.getText().toString();
            if(!TextUtils.isEmpty(remoteId) && mRemoteUserIdList.contains(remoteId)){
                showRemoteModeMenu();
            }else{
                Toast.makeText(SetRenderParamsActivity.this,  getString(R.string.renderparams_plsase_ensure_remote_userid), Toast.LENGTH_SHORT).show();
            }
        }else if(view.getId() == R.id.ll_remote_userid){
            if(mRemoteUserIdList.size() > 0){
                showRemoteUserMenu();
            }else{
                Toast.makeText(SetRenderParamsActivity.this, getString(R.string.renderparams_no_remote_user_list), Toast.LENGTH_SHORT).show();
            }
        }
    }

    private void showRemoteUserMenu(){
        if(mRemoteUserIdList.size() > 0) {
            PopupMenu popupMenu = new PopupMenu(this, mLLRemoteMode, Gravity.TOP);
            for(String userId : mRemoteUserIdList){
                if(!TextUtils.isEmpty(userId)){
                    popupMenu.getMenu().add(userId);
                }
            }
            popupMenu.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
                @Override
                public boolean onMenuItemClick(MenuItem item) {
                    mTextRemoteUserId.setText(item.getTitle());
                    return false;
                }
            });
            popupMenu.show();
        }
    }

    private void showRemoteModeMenu() {
        PopupMenu popupMenu = new PopupMenu(this, mLLRemoteMode, Gravity.TOP);
        popupMenu.getMenuInflater().inflate(R.menu.renderparams_mode, popupMenu.getMenu());
        popupMenu.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                if(item.getItemId() == R.id.mode_fill){
                    mRemoteModeFlag = TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL;
                    mTextRemoteMode.setText(getString(R.string.renderparams_mode_fill));
                }else if(item.getItemId() == R.id.mode_fit){
                    mRemoteModeFlag = TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT;
                    mTextRemoteMode.setText(R.string.renderparams_mdoe_fit);
                }
                setRemoteRenderParams();
                return false;
            }
        });
        popupMenu.show();
    }

    private void showRemoteRotateMenu() {
        PopupMenu popupMenu = new PopupMenu(this, mLLRemoteRotate, Gravity.TOP);
        popupMenu.getMenuInflater().inflate(R.menu.renderparams_rotate, popupMenu.getMenu());
        popupMenu.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                if(item.getItemId() == R.id.rotate_0){
                    mRemoteRoateFlag = TRTCCloudDef.TRTC_VIDEO_ROTATION_0;
                    mTextRemoteRotate.setText(getString(R.string.renderparams_rotate_0));
                }else if(item.getItemId() == R.id.rotate_90){
                    mRemoteRoateFlag = TRTCCloudDef.TRTC_VIDEO_ROTATION_90;
                    mTextRemoteRotate.setText(getString(R.string.renderparams_rotate_90));
                }else if(item.getItemId() == R.id.rotate_180){
                    mRemoteRoateFlag = TRTCCloudDef.TRTC_VIDEO_ROTATION_180;
                    mTextRemoteRotate.setText(getString(R.string.renderparams_rotate_180));
                }else if(item.getItemId() == R.id.rotate_270){
                    mRemoteRoateFlag = TRTCCloudDef.TRTC_VIDEO_ROTATION_270;
                    mTextRemoteRotate.setText(getString(R.string.renderparams_rotate_270));
                }
                setRemoteRenderParams();
                return false;
            }
        });
        popupMenu.show();
    }

    private void showLocalModeMenu() {
        PopupMenu popupMenu = new PopupMenu(this, mLLLocalMode, Gravity.TOP);
        popupMenu.getMenuInflater().inflate(R.menu.renderparams_mode, popupMenu.getMenu());
        popupMenu.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                if(item.getItemId() == R.id.mode_fill){
                    mLocalModeFlag = TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL;
                    mTextLocalMode.setText(getString(R.string.renderparams_mode_fill));
                }else if(item.getItemId() == R.id.mode_fit){
                    mLocalModeFlag = TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT;
                    mTextLocalMode.setText(getString(R.string.renderparams_mdoe_fit));
                }
                setLocalRenderParams();
                return false;
            }
        });
        popupMenu.show();
    }

    private void showLocalMirrorMenu() {
        PopupMenu popupMenu = new PopupMenu(this, mLLLocalMirror, Gravity.TOP);
        popupMenu.getMenuInflater().inflate(R.menu.renderparams_mirror, popupMenu.getMenu());
        popupMenu.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                if(item.getItemId() == R.id.mirror_auto){
                    mLocalMirrorFlag = TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO;
                    mTextLocalMirror.setText(getString(R.string.renderparams_mirror_auto));
                }else if(item.getItemId() == R.id.mirror_enable){
                    mLocalMirrorFlag = TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE;
                    mTextLocalMirror.setText(R.string.renderparams_mirror_enable);
                }else if(item.getItemId() == R.id.mirror_disable){
                    mLocalMirrorFlag = TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_DISABLE;
                    mTextLocalMirror.setText(R.string.renderparams_mirror_disable);
                }
                setLocalRenderParams();
                return false;
            }
        });
        popupMenu.show();
    }

    private void showLocalRotateMenu() {
        PopupMenu popupMenu = new PopupMenu(this, mLLLocalRotate, Gravity.TOP);
        popupMenu.getMenuInflater().inflate(R.menu.renderparams_rotate, popupMenu.getMenu());
        popupMenu.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                if(item.getItemId() == R.id.rotate_0){
                    mLocalRoateFlag = TRTCCloudDef.TRTC_VIDEO_ROTATION_0;
                    mTextLocalRotate.setText(R.string.renderparams_rotate_0);
                }else if(item.getItemId() == R.id.rotate_90){
                    mLocalRoateFlag = TRTCCloudDef.TRTC_VIDEO_ROTATION_90;
                    mTextLocalRotate.setText(R.string.renderparams_rotate_90);
                }else if(item.getItemId() == R.id.rotate_180){
                    mLocalRoateFlag = TRTCCloudDef.TRTC_VIDEO_ROTATION_180;
                    mTextLocalRotate.setText(R.string.renderparams_rotate_180);
                }else if(item.getItemId() == R.id.rotate_270){
                    mLocalRoateFlag = TRTCCloudDef.TRTC_VIDEO_ROTATION_270;
                    mTextLocalRotate.setText(R.string.renderparams_rotate_270);
                }
                setLocalRenderParams();
                return false;
            }
        });
        popupMenu.show();
    }

    private void setLocalRenderParams(){
        TRTCCloudDef.TRTCRenderParams param = new TRTCCloudDef.TRTCRenderParams();
        param.fillMode      = mLocalModeFlag;
        param.mirrorType    = mLocalMirrorFlag;
        param.rotation      = mLocalRoateFlag;
        mTRTCCloud.setLocalRenderParams(param);
    }

    private void setRemoteRenderParams(){
        String remoteUserId = mTextRemoteUserId.getText().toString();
        TRTCCloudDef.TRTCRenderParams param = new TRTCCloudDef.TRTCRenderParams();
        param.fillMode      = mRemoteModeFlag;
        param.rotation      = mRemoteRoateFlag;
        mTRTCCloud.setRemoteRenderParams(remoteUserId,TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, param);
    }

    protected class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<SetRenderParamsActivity> mContext;

        public TRTCCloudImplListener(SetRenderParamsActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onUserVideoAvailable(String userId, boolean available) {
            if(available){
                mRemoteUserIdList.add(userId);
            }else{
                String textUserId = mTextRemoteUserId.getText().toString();
                if(!TextUtils.isEmpty(textUserId) && !TextUtils.isEmpty(userId)){
                    if(textUserId.equals(userId)){
                        mTextRemoteUserId.setText("");
                    }
                }
                if(mRemoteUserIdList.contains(userId)){
                    mRemoteUserIdList.remove(userId);
                    mTRTCCloud.stopRemoteView(userId);
                }
            }
            refreshRemoteVideo();
        }

        private void refreshRemoteVideo() {
            if(mRemoteUserIdList.size() > 0){
                for(int i =0 ; i < mRemoteUserIdList.size() || i < 6; i++){
                    if(i < mRemoteUserIdList.size() && !TextUtils.isEmpty(mRemoteUserIdList.get(i))){
                        mRemoteVideoList.get(i).setVisibility(View.VISIBLE);
                        mRemoteUserviewList.get(i).setText(mRemoteUserIdList.get(i) + "");
                        mTRTCCloud.startRemoteView(mRemoteUserIdList.get(i),TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, mRemoteVideoList.get(i));
                    }else{
                        mRemoteUserviewList.get(i).setText("");
                        mRemoteVideoList.get(i).setVisibility(View.GONE);
                    }
                }
            }else{
                for(int i = 0; i < 6; i++){
                    mRemoteVideoList.get(i).setVisibility(View.GONE);
                    mRemoteUserviewList.get(i).setText("");
                }
            }
        }

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            SetRenderParamsActivity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "onError: " + errMsg + "[" + errCode+ "]" , Toast.LENGTH_SHORT).show();
                if (errCode == TXLiteAVCode.ERR_ROOM_ENTER_FAIL) {
                    activity.exitRoom();
                }
            }
        }
    }

    private void enterRoom(String roomId,  String userId) {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(SetRenderParamsActivity.this));
        TRTCCloudDef.TRTCParams mTRTCParams = new TRTCCloudDef.TRTCParams();
        mTRTCParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        mTRTCParams.userId = userId;
        mTRTCParams.roomId = Integer.parseInt(roomId);
        mTRTCParams.userSig = GenerateTestUserSig.genTestUserSig(mTRTCParams.userId);
        mTRTCParams.role = TRTCCloudDef.TRTCRoleAnchor;

        mTRTCCloud.startLocalPreview(true, mTXCloudPreviousView);
        mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
        mTRTCCloud.enterRoom(mTRTCParams, TRTCCloudDef.TRTC_APP_SCENE_LIVE);
    }

    private void hideRemoteView(){
        mRemoteUserIdList.clear();
        for(TXCloudVideoView videoView : mRemoteVideoList){
            videoView.setVisibility(View.GONE);
        }

        for(TextView textView : mRemoteUserviewList){
            textView.setText("");
        }
    }

    private void exitRoom(){
        hideRemoteView();
        if (mTRTCCloud != null) {
            mTRTCCloud.stopAllRemoteView();
            mTRTCCloud.stopLocalAudio();
            mTRTCCloud.stopLocalPreview();
            mTRTCCloud.exitRoom();
            mTRTCCloud.setListener(null);
        }
        mTRTCCloud = null;
        TRTCCloud.destroySharedInstance();
    }

    @Override
    protected void onPermissionGranted() {
        initView();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exitRoom();
    }

}
