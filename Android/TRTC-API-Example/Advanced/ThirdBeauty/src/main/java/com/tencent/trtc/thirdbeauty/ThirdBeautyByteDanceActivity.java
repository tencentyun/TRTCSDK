package com.tencent.trtc.thirdbeauty;

import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

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

/**
 * 第三方美颜接入火山美颜功能
 * 接入步骤：
 * 第一步：集成火山美颜SDK（可参考火山美颜提供的接入文档：http://ailab-cv-sdk.bytedance.com/docs/2036/157783/）
 * 1.1、打开火山美颜提供的压缩包 byted_effect_andr.zip，找到 effectAAR-release.aar,拷贝该文件到我们项目某个module的libs文件夹下
 * 1.2、在项目的build.gradle中的repositories节点下添加如下配置（ 这里是因为第一步中拷贝到了:Advanced:ThirdBeauty module中），所以添加如下
 * allprojects {
 * repositories {
 * flatDir {
 * dirs project(':Advanced:ThirdBeauty').file('libs')
 * }
 * }
 * }
 * 1.3、复制火山美颜提供的 License 文件到当前module的 assets/resouce 目录中
 * <p>
 * 第二步：添加火山美颜的封装好的调用代码
 * 2.1、拷贝 androidsample 项目中的 com.bytedance.labcv.core 模块到自己的工程中
 * 2.2、拷贝火山美颜中需要用到的辅助类，具体为 com.bytedance.labcv.core.sync 目录
 * 2.3、修改 com.bytedance.labcv.core.Config#LICENSE_NAME 为1.3提到的火山提供的美颜License 的文件名称
 * <p>
 * 第三步：在TRTC中使用火山美颜
 * 3.1、详见{@link ThirdBeautyByteDanceActivity#initData()} 中的注释说明
 *
 * 注意：火山美颜提供的 License 与 applicationId 一一对应的，测试过程中需要修改 applicationId 为 License对应的applicationId
 */
public class ThirdBeautyByteDanceActivity extends TRTCBaseActivity implements View.OnClickListener{
//        UnzipTask.IUnzipViewCallback {

    private static final String TAG = ThirdBeautyByteDanceActivity.class.getSimpleName();

    private ImageView              mImageBack;
    private TextView               mTextTitle;
    private Button                 mButtonStartPush;
    private EditText               mEditRoomId;
    private EditText               mEditUserId;
    private SeekBar                mSeekBlurLevel;
    private TextView               mTextBlurLevel;
    private FrameLayout            mFrameMask;
    private TXCloudVideoView       mTXCloudPreviewView;
    private List<TXCloudVideoView> mRemoteVideoList;
    private TRTCCloud              mTRTCCloud;
    private List<String>           mRemoteUserIdList;
    private boolean                mStartPushFlag = false;
//    private EffectManager          mEffectManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_third_beauty_bytedance);
        getSupportActionBar().hide();
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(new TRTCCloudImplListener(ThirdBeautyByteDanceActivity.this));
        if (checkPermission()) {
            initView();
            initData();
//            checkResourceReady();
        }
    }

    private int getVersionCode() {
        Context context = getApplicationContext();
        try {
            return context.getPackageManager().getPackageInfo(context.getPackageName(), 0).versionCode;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
            return -1;
        }
    }

//    public void checkResourceReady() {
//        int savedVersionCode = UserData.getInstance(this).getVersion();
//        int currentVersionCode = getVersionCode();
//        if (savedVersionCode < currentVersionCode) {
//            UnzipTask task = new UnzipTask(this);
//            task.execute(UnzipTask.DIR);
//        }
//    }

    private void enterRoom(String roomId, String userId) {
        TRTCCloudDef.TRTCParams mTRTCParams = new TRTCCloudDef.TRTCParams();
        mTRTCParams.sdkAppId = GenerateTestUserSig.SDKAPPID;
        mTRTCParams.userId = userId;
        mTRTCParams.roomId = Integer.parseInt(roomId);
        mTRTCParams.userSig = GenerateTestUserSig.genTestUserSig(mTRTCParams.userId);
        mTRTCParams.role = TRTCCloudDef.TRTCRoleAnchor;

        mTRTCCloud.startLocalPreview(true, mTXCloudPreviewView);
        mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
        mTRTCCloud.enterRoom(mTRTCParams, TRTCCloudDef.TRTC_APP_SCENE_LIVE);
    }

    private void exitRoom() {
        if (mTRTCCloud != null) {
            mTRTCCloud.stopAllRemoteView();
            mTRTCCloud.stopLocalAudio();
            mTRTCCloud.stopLocalPreview();
            mTRTCCloud.exitRoom();
        }
    }

    private void destroyRoom() {
        if (mTRTCCloud != null) {
            exitRoom();
            mTRTCCloud.setListener(null);
        }
        mTRTCCloud = null;
        TRTCCloud.destroySharedInstance();
    }

    private void initView() {
        mRemoteUserIdList = new ArrayList<>();
        mRemoteVideoList = new ArrayList<>();

        mFrameMask = findViewById(R.id.fl_mask);
        mImageBack = findViewById(R.id.iv_back);
        mTextTitle = findViewById(R.id.tv_room_number);
        mButtonStartPush = findViewById(R.id.btn_start_push);
        mEditRoomId = findViewById(R.id.et_room_id);
        mEditUserId = findViewById(R.id.et_user_id);
        mSeekBlurLevel = findViewById(R.id.sb_blur_level);
        mTextBlurLevel = findViewById(R.id.tv_blur_level);
        mTXCloudPreviewView = findViewById(R.id.txcvv_main_local);

        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote1));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote2));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote3));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote4));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote5));
        mRemoteVideoList.add((TXCloudVideoView) findViewById(R.id.txcvv_video_remote6));

        mImageBack.setOnClickListener(this);
        mButtonStartPush.setOnClickListener(this);

        String time = String.valueOf(System.currentTimeMillis());
        String userId = time.substring(time.length() - 8);
        mEditUserId.setText(userId);
        mTextTitle.setText(getString(R.string.thirdbeauty_room_id) + ":" + mEditRoomId.getText().toString());
        mFrameMask.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                return true;
            }
        });
    }

    private void initData() {
////                  1. 设置 TRTCVideoFrameListener 回调, 详见API说明文档 {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a0b565dc8c77df7fb826f0c45d8ad2d85}
//        mTRTCCloud.setLocalVideoProcessListener(TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D, TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE, new TRTCCloudListener.TRTCVideoFrameListener() {
//            @Override
//            public void onGLContextCreated() {
////                  2. GLContext 创建，创建火山美颜的管理类
//                mEffectManager = new EffectManager(ThirdBeautyByteDanceActivity.this, new EffectResourceHelper(ThirdBeautyByteDanceActivity.this));
//                mEffectManager.setOnEffectListener(new EffectManager.OnEffectListener() {
//                    @Override
//                    public void onEffectInitialized() {
//                        // 设置火山美颜的初始化效果，默认80% 的美白效果
//                        boolean ret = mEffectManager.setComposeNodes(new String[]{"beauty_Android_live"});
//                        boolean ret1 = mEffectManager.updateComposerNodeIntensity("beauty_Android_live", "whiten", 0.8f);
//                        Log.d(TAG, "EffectManager.setComposeNodes() ret : " + ret);
//                        Log.d(TAG, "EffectManager.updateComposerNodeIntensity() ret : " + ret1);
//                    }
//                });
//                int ret = mEffectManager.init();
//                Log.d(TAG, "EffectManager.init() ret : " + ret);
//            }
//
//            @Override
//            public int onProcessVideoFrame(TRTCCloudDef.TRTCVideoFrame srcFrame, TRTCCloudDef.TRTCVideoFrame dstFrame) {
////                  3. 调用第三方美颜模块处理, 详见API说明文档 {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloudListener__android.html#a22afb08b2a1a18563c7be28c904b166a}
//                boolean ret = mEffectManager.process(srcFrame.texture.textureId, dstFrame.texture.textureId, srcFrame.width, srcFrame.height, BytedEffectConstants.Rotation.CLOCKWISE_ROTATE_0, System.currentTimeMillis());
//                Log.d(TAG, "EffectManager.process() ret : " + ret);
//                return 0;
//            }
//
//            @Override
//            public void onGLContextDestory() {
////                   4. GLContext 销毁
//                mEffectManager.destroy();
//            }
//        });

        mSeekBlurLevel.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (mStartPushFlag && fromUser) {
//                    5. 设置火山美颜的美白级别
//                    boolean ret = mEffectManager.updateComposerNodeIntensity("beauty_Android_live", "whiten", (progress * 1.0f) / 100.0f);
//                    Log.d(TAG, "updateComposerNodeIntensity beauty_Android_live:" + ret);
                }
                mTextBlurLevel.setText(String.valueOf(progress));
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.iv_back) {
            finish();
        } else if (id == R.id.btn_start_push) {
            String roomId = mEditRoomId.getText().toString();
            String userId = mEditUserId.getText().toString();
            if (!mStartPushFlag) {
                if (!TextUtils.isEmpty(roomId) && !TextUtils.isEmpty(userId)) {
                    mButtonStartPush.setText(R.string.thirdbeauty_stop_push);
                    enterRoom(roomId, userId);
                    mStartPushFlag = true;
                } else {
                    Toast.makeText(ThirdBeautyByteDanceActivity.this, getString(R.string.thirdbeauty_please_input_roomid_and_userid), Toast.LENGTH_SHORT).show();
                }
            } else {
                mButtonStartPush.setText(R.string.thirdbeauty_start_push);
                exitRoom();
                mStartPushFlag = false;
            }
        }
    }

//    @Override
//    public Context getContext() {
//        return getApplicationContext();
//    }
//
//    @Override
//    public void onStartTask() {
//        mFrameMask.setVisibility(View.VISIBLE);
//    }
//
//    @Override
//    public void onEndTask(boolean result) {
//        if (result) {
//            UserData.getInstance(this)
//                    .setVersion(getVersionCode());
//        }
//        if (!result) {
//            Toast.makeText(ThirdBeautyByteDanceActivity.this, "fail to copy resource, check your resource and re-open", Toast.LENGTH_SHORT).show();
//        } else {
//            mFrameMask.setVisibility(View.GONE);
//        }
//    }

    protected class TRTCCloudImplListener extends TRTCCloudListener {

        private WeakReference<ThirdBeautyByteDanceActivity> mContext;

        public TRTCCloudImplListener(ThirdBeautyByteDanceActivity activity) {
            super();
            mContext = new WeakReference<>(activity);
        }

        @Override
        public void onUserVideoAvailable(String userId, boolean available) {
            if (available) {
                mRemoteUserIdList.add(userId);
            } else {
                if (mRemoteUserIdList.contains(userId)) {
                    mRemoteUserIdList.remove(userId);
                    mTRTCCloud.stopRemoteView(userId);
                }
            }
            refreshRemoteVideo();
        }

        private void refreshRemoteVideo() {
            if (mRemoteUserIdList.size() > 0) {
                for (int i = 0; i < mRemoteUserIdList.size() || i < 6; i++) {
                    if (i < mRemoteUserIdList.size() && !TextUtils.isEmpty(mRemoteUserIdList.get(i))) {
                        mRemoteVideoList.get(i).setVisibility(View.VISIBLE);
                        mTRTCCloud.startRemoteView(mRemoteUserIdList.get(i), TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, mRemoteVideoList.get(i));
                    } else {
                        mRemoteVideoList.get(i).setVisibility(View.GONE);
                    }
                }
            } else {
                for (int i = 0; i < 6; i++) {
                    mRemoteVideoList.get(i).setVisibility(View.GONE);
                }
            }
        }

        @Override
        public void onExitRoom(int i) {
            mRemoteUserIdList.clear();
            refreshRemoteVideo();
        }

        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Log.d(TAG, "sdk callback onError");
            ThirdBeautyByteDanceActivity activity = mContext.get();
            if (activity != null) {
                Toast.makeText(activity, "onError: " + errMsg + "[" + errCode + "]", Toast.LENGTH_SHORT).show();
                if (errCode == TXLiteAVCode.ERR_ROOM_ENTER_FAIL) {
                    activity.exitRoom();
                }
            }
        }
    }

    @Override
    protected void onPermissionGranted() {
        initView();
        initData();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        destroyRoom();
    }
}
