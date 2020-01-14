package com.tencent.liteav.trtcaudiocalldemo.demo;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.AppCompatImageButton;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.TextView;

import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.trtcaudiocalldemo.R;
import com.tencent.liteav.trtcaudiocalldemo.debug.GenerateTestUserSig;
import com.tencent.liteav.trtcaudiocalldemo.demo.audiolayout.TRTCAudioLayout;
import com.tencent.liteav.trtcaudiocalldemo.demo.audiolayout.TRTCAudioLayoutManager;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import org.json.JSONObject;

import java.util.ArrayList;

public class AudioCallMainActivity extends AppCompatActivity {
    private static final String TAG = AudioCallMainActivity.class.getName();

    /**
     * 重要信息
     */
    private int                    mRoomId;
    private String                 mUserId;
    private TRTCCloud              mTRTCCloud;
    /**
     * 界面元素
     */
    private TextView               mTitleToolbar;
    private Toolbar                mToolbar;
    private AppCompatImageButton   mMicBtn;
    private AppCompatImageButton   mAudioBtn;
    private TRTCAudioLayoutManager mLayoutManagerTrtc;


    /**
     * 用于监听TRTC事件
     */
    private TRTCCloudListener    mChatRoomTRTCListener = new TRTCCloudListener() {
        @Override
        public void onEnterRoom(long result) {
            if (result == 0) {
                ToastUtils.showShort("进房成功");
            }
        }

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            ToastUtils.showLong("进房失败: " + errCode);
            finish();
        }

        @Override
        public void onRemoteUserEnterRoom(String userId) {
            TRTCAudioLayout layout = mLayoutManagerTrtc.allocAudioCallLayout(userId);
            layout.setUserId(userId);
            layout.setBitmap(Utils.getAvatar(userId));
        }

        @Override
        public void onRemoteUserLeaveRoom(String userId, int reason) {
            mLayoutManagerTrtc.recyclerAudioCallLayout(userId);
        }

        @Override
        public void onUserVoiceVolume(ArrayList<TRTCCloudDef.TRTCVolumeInfo> userVolumes, int totalVolume) {
            for (TRTCCloudDef.TRTCVolumeInfo info : userVolumes) {
                String userId = info.userId;
                // 如果userId为空，代表自己
                if (info.userId == null) {
                    userId = mUserId;
                }
                TRTCAudioLayout layout = mLayoutManagerTrtc.findAudioCallLayout(info.userId);
                if (layout != null) {
                    layout.setAudioVolume(info.volume);
                }
            }
        }
    };
    private AppCompatImageButton mHandsfreeBtn;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.audiocall_activity_main);
        initView();
        initData();
        initListener();
        enterTRTCRoom();
    }

    @Override
    protected void onDestroy() {
        exitRoom();
        super.onDestroy();
    }


    private void initListener() {
        mMicBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                boolean currentMode = !mMicBtn.isSelected();
                // 开关麦克风
                enableMic(currentMode);
                mMicBtn.setSelected(currentMode);
                if (currentMode) {
                    ToastUtils.showLong("您已开启麦克风");
                } else {
                    ToastUtils.showLong("您已关闭麦克风");
                }
            }
        });
        mAudioBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                boolean currentMode = !mAudioBtn.isSelected();
                // 是否静音
                enableAudio(currentMode);
                mAudioBtn.setSelected(currentMode);
                if (currentMode) {
                    ToastUtils.showLong("您已取消静音");
                } else {
                    ToastUtils.showLong("您已静音");
                }
            }
        });
        mHandsfreeBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                boolean currentMode = !mHandsfreeBtn.isSelected();
                // 是否走扬声器
                enableHandfree(currentMode);
                mHandsfreeBtn.setSelected(currentMode);
                if (currentMode) {
                    ToastUtils.showLong("扬声器");
                } else {
                    ToastUtils.showLong("耳机");
                }
            }
        });
    }

    private void initData() {
        Intent intent = getIntent();
        mRoomId = intent.getIntExtra(CreateAudioCallActivity.ROOM_ID, 0);
        mUserId = intent.getStringExtra(CreateAudioCallActivity.USER_ID);
        mTitleToolbar.setText(getString(R.string.audiocall_title, mRoomId));
        mTRTCCloud = TRTCCloud.sharedInstance(this);
        // 给自己分配一个view
        mLayoutManagerTrtc.setMySelfUserId(mUserId);
        TRTCAudioLayout layout = mLayoutManagerTrtc.allocAudioCallLayout(mUserId);
        layout.setBitmap(Utils.getAvatar(mUserId));
        layout.setUserId(mUserId);
    }

    private void initView() {
        mTitleToolbar = (TextView) findViewById(R.id.toolbar_title);
        mToolbar = (Toolbar) findViewById(R.id.toolbar);

        mMicBtn = (AppCompatImageButton) findViewById(R.id.btn_mic);
        mAudioBtn = (AppCompatImageButton) findViewById(R.id.btn_audio);
        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        mLayoutManagerTrtc = (TRTCAudioLayoutManager) findViewById(R.id.trtc_layout_manager);
        mHandsfreeBtn = (AppCompatImageButton) findViewById(R.id.btn_handsfree);

        //设置选中态
        mMicBtn.setActivated(true);
        mAudioBtn.setActivated(true);
        mHandsfreeBtn.setActivated(true);
        mMicBtn.setSelected(true);
        mAudioBtn.setSelected(true);
        mHandsfreeBtn.setSelected(true);
    }

    private void enterTRTCRoom() {
        mTRTCCloud.enableAudioVolumeEvaluation(800);
        mTRTCCloud.setListener(mChatRoomTRTCListener);
        mTRTCCloud.startLocalAudio();
        // 拼接进房参数
        TRTCCloudDef.TRTCParams params = new TRTCCloudDef.TRTCParams();
        params.userSig = GenerateTestUserSig.genTestUserSig(mUserId);
        params.roomId = mRoomId;
        params.sdkAppId = GenerateTestUserSig.SDKAPPID;
        params.role = TRTCCloudDef.TRTCRoleAnchor;
        params.userId = mUserId;
        mTRTCCloud.enterRoom(params, TRTCCloudDef.TRTC_APP_SCENE_AUDIOCALL);
    }

    private void exitRoom() {
        mTRTCCloud.exitRoom();
    }

    public void enableMic(boolean enable) {
        if (enable) {
            mTRTCCloud.startLocalAudio();
        } else {
            mTRTCCloud.stopLocalAudio();
        }
    }

    public void enableHandfree(boolean isUseHandsfree) {
        mTRTCCloud.setAudioRoute(isUseHandsfree ? TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER :
                TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
    }

    public void enableAudio(boolean enable) {
        mTRTCCloud.muteAllRemoteAudio(!enable);
    }
}
