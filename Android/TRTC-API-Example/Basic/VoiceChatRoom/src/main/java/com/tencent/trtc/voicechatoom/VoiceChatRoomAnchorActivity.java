package com.tencent.trtc.voicechatoom;

import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.example.basic.TRTCBaseActivity;
import com.tencent.liteav.TXLiteAVCode;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.debug.Constant;
import com.tencent.trtc.debug.GenerateTestUserSig;

import java.lang.ref.WeakReference;

import static com.tencent.trtc.TRTCCloudDef.TRTC_APP_SCENE_VOICE_CHATROOM;
/**
 * TRTC 语音互动聊天模块主播角色页面
 *
 * 包含功能如下：
 * - 静音{@link VoiceChatRoomAnchorActivity#muteAudio()}
 * - 上麦/下麦{@link VoiceChatRoomAudienceActivity#upDownMic()}
 *
 * - 详见API文档{https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a915a4b3abca0e41f057022a4587faf66}
 */

/**
 * Interactive Live Audio Streaming View for Room Owner
 *
 * Features:
 * - Mute: {@link VoiceChatRoomAnchorActivity#muteAudio()}
 * - Become speaker/listener: {@link VoiceChatRoomAudienceActivity#upDownMic()}
 *
 * - For more information, please see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a915a4b3abca0e41f057022a4587faf66}
 */
public class VoiceChatRoomAnchorActivity extends TRTCBaseActivity {
    private static final String             TAG                             = "VoiceChatRoomAnchor";

    private Button                          mButtonMuteAudio;
    private Button                          mButtonDownMic;
    private TextView                        mTextTitle;
    private ImageView                       mImageBack;

    private TRTCCloud                       mTRTCCloud;                     // SDK 核心类
    private String                          mRoomId;                        // 房间Id
    private String                          mUserId;                        // 用户Id
    private boolean                         mMuteAudioFlag = true;          // 默认不静音
    private boolean                         mUpMicFlag = true;              // 默认上麦（主播角色）
    private String                          mRemoteUserId;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().setFormat(PixelFormat.TRANSLUCENT);
        setContentView(R.layout.voicechatroom_activity_anchor);

        getSupportActionBar().hide();
        handleIntent();
        if (checkPermission()) {
            initView();
            enterRoom();
        }
    }

    private void enterRoom() {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(VoiceChatRoomAnchorActivity.this));

        TRTCCloudDef.TRTCParams mTRTCParams = new TRTCCloudDef.TRTCParams();
        mTRTCParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        mTRTCParams.userId = mUserId;
        mTRTCParams.roomId = Integer.parseInt(mRoomId);
        mTRTCParams.role = TRTCCloudDef.TRTCRoleAnchor;
        mTRTCParams.userSig = GenerateTestUserSig.genTestUserSig(mTRTCParams.userId);

        mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
        mTRTCCloud.enterRoom(mTRTCParams, TRTC_APP_SCENE_VOICE_CHATROOM);
    }

    private void initView() {
        mButtonMuteAudio    = findViewById(R.id.btn_mute_audio);
        mButtonDownMic      = findViewById(R.id.btn_down_mic);
        mTextTitle          = findViewById(R.id.tv_room_number);
        mImageBack          = findViewById(R.id.iv_back);

        mTextTitle.setText(getString(R.string.voicechatroom_roomid) + mRoomId);

        mImageBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });

        mButtonMuteAudio.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                muteAudio();
            }
        });

        mButtonDownMic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                upDownMic();
            }
        });
    }

    private void upDownMic() {
        if(mUpMicFlag){
            mUpMicFlag = false;
            mTRTCCloud.switchRole(TRTCCloudDef.TRTCRoleAudience);
            mTRTCCloud.stopLocalAudio();
            mButtonDownMic.setText( getString(R.string.voicechatroom_up_mic));
        }else{
            mUpMicFlag = true;
            mTRTCCloud.switchRole(TRTCCloudDef.TRTCRoleAnchor);
            mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
            mButtonDownMic.setText( getString(R.string.voicechatroom_down_mic));
        }
    }

    private void muteAudio() {
        if(mMuteAudioFlag){
            mMuteAudioFlag = false;
            mTRTCCloud.muteRemoteAudio(mRemoteUserId, true);
            mButtonMuteAudio.setText( getString(R.string.voicechatroom_stop_mute_audio));
        }else {
            mMuteAudioFlag = true;
            mTRTCCloud.muteRemoteAudio(mRemoteUserId, false);
            mButtonMuteAudio.setText( getString(R.string.voicechatroom_mute_audio));
        }
    }

    private void handleIntent() {
        Intent intent = getIntent();
        if (null != intent) {
            if (intent.getStringExtra(Constant.USER_ID) != null) {
                mUserId = intent.getStringExtra(Constant.USER_ID);
            }
            if (intent.getStringExtra(Constant.ROOM_ID) != null) {
                mRoomId = intent.getStringExtra(Constant.ROOM_ID);
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exitRoom();
    }

    protected class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<VoiceChatRoomAnchorActivity> mContext;

        public TRTCCloudImplListener(VoiceChatRoomAnchorActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onUserAudioAvailable(String userId, boolean available) {
            if (available) {
                mRemoteUserId = userId;
            } else {
                mRemoteUserId = "";
            }
        }

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            VoiceChatRoomAnchorActivity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "onError: " + errMsg + "[" + errCode+ "]" , Toast.LENGTH_SHORT).show();
                if (errCode == TXLiteAVCode.ERR_ROOM_ENTER_FAIL) {
                    activity.exitRoom();
                }
            }
        }
    }

    private void exitRoom() {
        if (mTRTCCloud != null) {
            mTRTCCloud.stopLocalAudio();
            mTRTCCloud.exitRoom();
            mTRTCCloud.setListener(null);
        }
        mTRTCCloud = null;
        TRTCCloud.destroySharedInstance();
    }

    @Override
    protected void onPermissionGranted() {
        initView();
        enterRoom();
    }
}
