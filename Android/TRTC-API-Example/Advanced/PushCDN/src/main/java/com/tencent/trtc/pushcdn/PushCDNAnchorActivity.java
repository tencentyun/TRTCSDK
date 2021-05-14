package com.tencent.trtc.pushcdn;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RadioButton;
import android.widget.TextView;
import android.widget.Toast;

import com.example.basic.TRTCBaseActivity;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.debug.Constant;
import com.tencent.trtc.debug.GenerateTestUserSig;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * TRTC CDN发布主播页面，可以进行推流，CDN发布，混流（需要主播数anchor>=2）
 *
 * - API使用方式见<a href="https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#af7cf5544f9b8027e9526c32319a13838">setMixTranscodingConfig	(	TRTCCloudDef.TRTCTranscodingConfig 	config	)	</a>
 * - 混流场景及使用介绍见<a href="https://cloud.tencent.com/document/product/647/16827">云端混流转码</a>
 */

/**
 * CDN Publishing (stream pushing, CDN publishing, and stream mixing when there are 2 or more anchors in the room)
 *
 * - For how to use the API, see <a href="https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#af7cf5544f9b8027e9526c32319a13838">setMixTranscodingConfig	(	TRTCCloudDef.TRTCTranscodingConfig 	config	)	</a>.
 * - To learn about the use cases and other details of On-Cloud MixTranscoding, see <a href=https://cloud.tencent.com/document/product/647/16827">On-Cloud MixTranscoding</a>.
 */
public class PushCDNAnchorActivity extends TRTCBaseActivity implements View.OnClickListener, CompoundButton.OnCheckedChangeListener {

    private static final String     TAG                 = "PushCDNAnchorActivity";

    private TXCloudVideoView        mVideoViewMain;
    private List<TXCloudVideoView>  mRemoteVideoList;
    private TextView                mTextTitle;
    private TextView                mTextStreamUrl;
    private Button                  mButtonPushCDN;
    private EditText                mEditRoomId;
    private EditText                mEditStreamId;
    private Button                  mButtonEnterRoom;
    private RadioButton             mRadioManul;
    private RadioButton             mRadioLeftRight;
    private RadioButton             mRadioInPicture;
    private ImageView               mImageBack;

    private TRTCCloud               mTRTCCloud;
    private boolean                 mIsRoomEntered = false;
    private String                  mUserId;
    private String                  mRoomId;
    private String                  mStreamId;
    private List<String>            mRemoteUidList;
    private MixMode                 mMixConfigFlag = MixMode.MIX_MODE_PRESET_IN_PICTURE;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getSupportActionBar().hide();
        setContentView(R.layout.pushcdn_activity_anchor);
        if (checkPermission()) {
            initView();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        release();
    }

    private void release() {
        if (mTRTCCloud != null) {
            mTRTCCloud.stopLocalAudio();
            mTRTCCloud.stopLocalPreview();

            if (mIsRoomEntered) {
                mTRTCCloud.exitRoom();
            }

            mTRTCCloud.setListener(null);
            mTRTCCloud = null;
            TRTCCloud.destroySharedInstance();
        }
    }

    private void initView() {
        mRemoteVideoList    = new ArrayList<>();
        mRemoteUidList      = new ArrayList<>();

        mTextTitle          = findViewById(R.id.tv_pushcdn_anchor_title);
        mTextStreamUrl      = findViewById(R.id.tv_pushcdn_anchor_stream_url);
        mButtonPushCDN      = findViewById(R.id.btn_start_pushcdn);
        mEditRoomId         = findViewById(R.id.et_pushcdn_anchor_room_id);
        mEditStreamId       = findViewById(R.id.et_pushcdn_anchor_stream_id);
        mButtonEnterRoom    = findViewById(R.id.btn_push_enterroom);
        mVideoViewMain      = findViewById(R.id.videoview_pushcdn_anchor_main);
        mImageBack          = findViewById(R.id.iv_back);
        mRadioManul         = findViewById(R.id.rb_mix_mode_manual);
        mRadioInPicture     = findViewById(R.id.rb_mix_mode_left_right);
        mRadioLeftRight     = findViewById(R.id.rb_mix_mode_in_picture);

        mRemoteVideoList.add((TXCloudVideoView)findViewById(R.id.videoview_pushcdn_anchor_user1));
        mRemoteVideoList.add((TXCloudVideoView)findViewById(R.id.videoview_pushcdn_anchor_user1));
        mRemoteVideoList.add((TXCloudVideoView)findViewById(R.id.videoview_pushcdn_anchor_user1));

        mRadioManul.setOnCheckedChangeListener(this);
        mRadioLeftRight.setOnCheckedChangeListener(this);
        mRadioInPicture.setOnCheckedChangeListener(this);
        mImageBack.setOnClickListener(this);
        mButtonEnterRoom.setOnClickListener(this);
        mButtonPushCDN.setOnClickListener(this);
    }

    private void setMixConfig() {
        Log.d(TAG, "setMixConfig:  mMixConfigFlag = " + mMixConfigFlag);
        if(mMixConfigFlag == MixMode.MIX_MODE_MANUAL){
            setMixConfigManual(mRemoteUidList);
        }else if(mMixConfigFlag == MixMode.MIX_MODE_PRESET_IN_PICTURE){
            setMixConfigInPicture();
        }else if(mMixConfigFlag == MixMode.MIX_MODE_PRESSET_LEFT_RIGHT){
            setMixConfigLeftRight();
        }
    }

    /**
     * 设置全手动排版模式
     * 具体使用方式见<a href="https://cloud.tencent.com/document/product/647/16827">云端混流转码</a>
     */
    private void setMixConfigManual(List<String> mRemoteUidList) {
        TRTCCloudDef.TRTCTranscodingConfig config = new TRTCCloudDef.TRTCTranscodingConfig();
        config.videoWidth      = 720;
        config.videoHeight     = 1280;
        config.videoBitrate    = 1500;
        config.videoFramerate  = 20;
        config.videoGOP        = 2;
        config.audioSampleRate = 48000;
        config.audioBitrate    = 64;
        config.audioChannels   = 2;
        config.streamId        = mStreamId;
        config.appId           = GenerateTestUserSig.APPID;
        config.bizId           = GenerateTestUserSig.BIZID;
        config.backgroundColor = 0x000000;
        config.backgroundImage = null;

        config.mode = TRTCCloudDef.TRTC_TranscodingConfigMode_Manual;
        config.mixUsers = new ArrayList<>();

//       主播自己
        TRTCCloudDef.TRTCMixUser mixUser = new TRTCCloudDef.TRTCMixUser();
        mixUser.userId = mUserId;
        mixUser.zOrder = 0;
        mixUser.x = 0;
        mixUser.y = 0;
        mixUser.width = 720;
        mixUser.height = 1280;
        mixUser.roomId = null;
        mixUser.inputType = TRTCCloudDef.TRTC_MixInputType_AudioVideo;
        config.mixUsers.add(mixUser);

        for(int i = 0; i < mRemoteUidList.size() && i < 3; i++){
            TRTCCloudDef.TRTCMixUser remote = new TRTCCloudDef.TRTCMixUser();
            remote.userId = mRemoteUidList.get(i);
            remote.streamType = TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG;
            remote.zOrder = 1;
            remote.x      = 180 + i * 20;
            remote.y      = 400 + i * 20;
            remote.width  = 135;
            remote.height = 240;
            remote.roomId = mRoomId;
            mixUser.inputType = TRTCCloudDef.TRTC_MixInputType_AudioVideo;
            config.mixUsers.add(remote);
        }
        mTRTCCloud.setMixTranscodingConfig(config);
    }

    /**
     * 设置混流预排版模式
     * 具体使用方式见<a href="https://cloud.tencent.com/document/product/647/16827">云端混流转码</a>
     */
    private void setMixConfigLeftRight() {
        TRTCCloudDef.TRTCTranscodingConfig config = new TRTCCloudDef.TRTCTranscodingConfig();
        config.videoWidth      = 720;
        config.videoHeight     = 640;
        config.videoBitrate    = 1500;
        config.videoFramerate  = 20;
        config.videoGOP        = 2;
        config.audioSampleRate = 48000;
        config.audioBitrate    = 64;
        config.audioChannels   = 2;
        config.streamId        = mStreamId;

        config.mode = TRTCCloudDef.TRTC_TranscodingConfigMode_Template_PresetLayout;
        config.mixUsers = new ArrayList<>();

//       主播自己
        TRTCCloudDef.TRTCMixUser mixUser = new TRTCCloudDef.TRTCMixUser();
        mixUser.userId = "$PLACE_HOLDER_LOCAL_MAIN$";
        mixUser.zOrder = 0;
        mixUser.x = 0;
        mixUser.y = 0;
        mixUser.width = 360;
        mixUser.height = 640;
        mixUser.roomId = null;
        config.mixUsers.add(mixUser);


        //连麦者画面位置
        TRTCCloudDef.TRTCMixUser remote = new TRTCCloudDef.TRTCMixUser();
        remote.userId = "$PLACE_HOLDER_REMOTE$";
        remote.streamType = TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG;
        remote.zOrder = 1;
        remote.x      = 360;
        remote.y      = 0;
        remote.width  = 360;
        remote.height = 640;
        remote.roomId = mRoomId;
        config.mixUsers.add(remote);

        mTRTCCloud.setMixTranscodingConfig(config);
    }

    /**
     * 设置全手动排版模式
     * 具体使用方式见<a href="https://cloud.tencent.com/document/product/647/16827">云端混流转码</a>
     */
    private void setMixConfigInPicture() {
        TRTCCloudDef.TRTCTranscodingConfig config = new TRTCCloudDef.TRTCTranscodingConfig();
        config.videoWidth      = 720;
        config.videoHeight     = 1280;
        config.videoBitrate    = 1500;
        config.videoFramerate  = 20;
        config.videoGOP        = 2;
        config.audioSampleRate = 48000;
        config.audioBitrate    = 64;
        config.audioChannels   = 2;
        config.streamId        = mStreamId;

        config.mode = TRTCCloudDef.TRTC_TranscodingConfigMode_Template_PresetLayout;
        config.mixUsers = new ArrayList<>();

//       主播自己
        TRTCCloudDef.TRTCMixUser mixUser = new TRTCCloudDef.TRTCMixUser();
        mixUser.userId = "$PLACE_HOLDER_LOCAL_MAIN$";
        mixUser.zOrder = 0;
        mixUser.x = 0;
        mixUser.y = 0;
        mixUser.width = 720;
        mixUser.height = 1280;
        mixUser.roomId = null;
        config.mixUsers.add(mixUser);


        //连麦者画面位置
        TRTCCloudDef.TRTCMixUser remote = new TRTCCloudDef.TRTCMixUser();
        remote.userId = "$PLACE_HOLDER_REMOTE$";
        remote.streamType = TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG;

        remote.zOrder = 1;
        remote.x      = 500;
        remote.y      = 150;
        remote.width  = 135;
        remote.height = 240;
        remote.roomId = mRoomId;
        config.mixUsers.add(remote);

        mTRTCCloud.setMixTranscodingConfig(config);
    }

    private void hideRemoteView(){
        mRemoteUidList.clear();
        for(TXCloudVideoView videoView : mRemoteVideoList){
            videoView.setVisibility(View.GONE);
        }
    }

    private void exitRoom() {
        hideRemoteView();
        mTRTCCloud.exitRoom();
        mRemoteUidList.clear();
    }

    private void enterRoom() {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(mTRTCCloudListener);

        TRTCCloudDef.TRTCParams trtcParams = new TRTCCloudDef.TRTCParams();
        trtcParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        trtcParams.userId = mUserId;
        trtcParams.roomId = Integer.parseInt(mRoomId);
        trtcParams.userSig = GenerateTestUserSig.genTestUserSig(mUserId);
        trtcParams.streamId = mStreamId;
        trtcParams.role = TRTCCloudDef.TRTCRoleAnchor;

        mTRTCCloud.startLocalPreview(true, mVideoViewMain);
        mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
        mTRTCCloud.enterRoom(trtcParams, TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);

        /**
         * 需要首先开启CDN旁路直播
         * 地址为：http://播放域名/live/[streamId].flv
         * 具体可参考：https://cloud.tencent.com/document/product/647/16826
         */
        mTextTitle.setText(getString(R.string.pushcdn_anchor_room_title) + mRoomId);
        mTextStreamUrl.setText(getString(R.string.pushcdn_anchor_cdn_url_guide));
    }

    private static int generateRandomInt(int bound) {
        Random random = new Random();
        int result = random.nextInt(bound);
        while (result == 0) {
            result = random.nextInt(bound);
        }
        return result;
    }

    @Override
    public void onClick(View view) {
        if(view.getId() == R.id.iv_back){
            finish();
        }else if(view.getId() == R.id.btn_start_pushcdn){
            if (!mIsRoomEntered) {
                Toast.makeText(PushCDNAnchorActivity.this, R.string.pushcdn_anchor_need_enter_room_tip, Toast.LENGTH_SHORT).show();
            } else if (mRemoteUidList.isEmpty()) {
                Toast.makeText(PushCDNAnchorActivity.this, R.string.pushcdn_anchor_more_anchor_tip, Toast.LENGTH_SHORT).show();
            } else {
                mTextStreamUrl.setVisibility(View.VISIBLE);
                setMixConfig();
                mButtonPushCDN.setBackgroundColor(getResources().getColor(R.color.pushcdn_green_bg));
                mButtonPushCDN.setText(R.string.pushcdn_more_cloud_mix);
            }
        }else if(view.getId() == R.id.btn_push_enterroom){
            if (mIsRoomEntered) {
                mIsRoomEntered = false;
                exitRoom();
                mButtonPushCDN.setBackgroundColor(getResources().getColor(R.color.pushcdn_mixconfig_button_disable_bg));
                mButtonPushCDN.setText(R.string.pushcdn_anchor_mixconfig_disabled);
                mButtonEnterRoom.setText(getString(R.string.pushcdn_anchor_enter_room));
                mTextStreamUrl.setVisibility(View.GONE);
            } else {
                if (TextUtils.isEmpty(mEditRoomId.getText())) {
                    Toast.makeText(PushCDNAnchorActivity.this, R.string.pushcdn_anchor_empty_room_id_tip, Toast.LENGTH_SHORT).show();
                } else {
                    if (TextUtils.isEmpty(mEditStreamId.getText())) {
                        mStreamId = "abc123";
                        mEditStreamId.setText(mStreamId);
                    } else {
                        mStreamId = mEditStreamId.getText().toString().trim();
                    }
                    mRoomId = mEditRoomId.getText().toString();
                    mUserId = "" + generateRandomInt(Integer.MAX_VALUE);
                    mIsRoomEntered = true;
                    mButtonEnterRoom.setText(getString(R.string.pushcdn_anchor_exit_room));
                    enterRoom();
                    if(mRemoteUidList.size() > 0){
                        mButtonPushCDN.setBackgroundColor(getResources().getColor(R.color.pushcdn_green_bg));
                        mButtonPushCDN.setText(R.string.pushcdn_more_cloud_mix);
                    }
                }
            }
        }
    }

    @Override
    public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
        if(!mIsRoomEntered){
            return;
        }
        if(compoundButton.getId() == R.id.rb_mix_mode_manual){
            if(compoundButton.isChecked()
                    && mMixConfigFlag != MixMode.MIX_MODE_MANUAL){
                mMixConfigFlag = MixMode.MIX_MODE_MANUAL;
                setMixConfig();
            }
        }else if(compoundButton.getId() == R.id.rb_mix_mode_in_picture){
            if(compoundButton.isChecked()
                    && mMixConfigFlag != MixMode.MIX_MODE_PRESET_IN_PICTURE){
                mMixConfigFlag = MixMode.MIX_MODE_PRESET_IN_PICTURE;
                setMixConfig();
            }
        }else if(compoundButton.getId() == R.id.rb_mix_mode_left_right){
            if(compoundButton.isChecked()
                    && mMixConfigFlag != MixMode.MIX_MODE_PRESSET_LEFT_RIGHT){
                mMixConfigFlag = MixMode.MIX_MODE_PRESSET_LEFT_RIGHT;
                setMixConfig();
            }
        }
    }


    private final TRTCCloudListener mTRTCCloudListener = new TRTCCloudListener() {
        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            super.onError(errCode, errMsg, extraInfo);
        }

        @Override
        public void onUserVideoAvailable(String userId, boolean available) {
            super.onUserVideoAvailable(userId, available);
            if (available) {
                mRemoteUidList.add(userId);
            } else {
                mRemoteUidList.remove(userId);
            }
            refreshRemoteVideo();
            if(mRemoteUidList.size() > 0 && mIsRoomEntered){
                mButtonPushCDN.setBackgroundColor(getResources().getColor(R.color.pushcdn_green_bg));
                mButtonPushCDN.setText(R.string.pushcdn_more_cloud_mix);
                setMixConfig();
            }else{
                mButtonPushCDN.setBackgroundColor(getResources().getColor(R.color.pushcdn_mixconfig_button_disable_bg));
                mButtonPushCDN.setText(R.string.pushcdn_anchor_mixconfig_disabled);
            }
        }

        @Override
        public void onStartPublishing(int err, String errMsg) {
            super.onStartPublishing(err, errMsg);
        }

        @Override
        public void onStopPublishing(int err, String errMsg) {
            super.onStopPublishing(err, errMsg);
        }

        @Override
        public void onSetMixTranscodingConfig(int err, String errMsg) {
            super.onSetMixTranscodingConfig(err, errMsg);
        }

        private void refreshRemoteVideo() {
            if(mRemoteUidList.size() > 0){
                for(int i =0 ; i < mRemoteUidList.size() || i < 3; i++){
                    if(i < mRemoteUidList.size() && !TextUtils.isEmpty(mRemoteUidList.get(i))){
                        mRemoteVideoList.get(i).setVisibility(View.VISIBLE);
                        mTRTCCloud.startRemoteView(mRemoteUidList.get(i),TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, mRemoteVideoList.get(i));
                    }else{
                        mRemoteVideoList.get(i).setVisibility(View.GONE);
                    }
                }
            }else{
                mTextStreamUrl.setVisibility(View.GONE);
                for(int i = 0; i < 3; i++){
                    mRemoteVideoList.get(i).setVisibility(View.GONE);
                }
            }
        }
    };

    @Override
    protected void onPermissionGranted() {
        initView();
    }

    enum MixMode{
        MIX_MODE_MANUAL,
        MIX_MODE_PRESSET_LEFT_RIGHT,
        MIX_MODE_PRESET_IN_PICTURE,
    }


}