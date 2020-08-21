package com.tencent.liteav.trtccalling.ui.videocall;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.support.annotation.Nullable;
import android.support.constraint.Group;
import android.support.v7.app.AppCompatActivity;
import android.text.TextUtils;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.blankj.utilcode.util.ToastUtils;
import com.squareup.picasso.Picasso;
import com.tencent.liteav.trtccalling.R;
import com.tencent.liteav.trtccalling.model.TRTCCalling;
import com.tencent.liteav.trtccalling.model.TRTCCallingDelegate;
import com.tencent.liteav.trtccalling.model.impl.TRTCCallingImpl;
import com.tencent.liteav.trtccalling.ui.videocall.videolayout.TRTCVideoLayout;
import com.tencent.liteav.trtccalling.ui.videocall.videolayout.TRTCVideoLayoutManager;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 用于展示视频通话的主界面，通话的接听和拒绝就是在这个界面中完成的。
 *
 * @author guanyifeng
 */
public class TRTCVideoCallActivity extends AppCompatActivity {
    public static final int TYPE_BEING_CALLED = 1;
    public static final int TYPE_CALL         = 2;

    public static final  String PARAM_TYPE                = "type";
    public static final  String PARAM_SELF_INFO           = "self_info";
    public static final  String PARAM_USER                = "user_model";
    public static final  String PARAM_BEINGCALL_USER      = "beingcall_user_model";
    public static final  String PARAM_OTHER_INVITING_USER = "other_inviting_user_model";
    private static final int    MAX_SHOW_INVITING_USER    = 4;

    private ImageView              mMuteImg;
    private LinearLayout           mMuteLl;
    private ImageView              mHangupImg;
    private LinearLayout           mHangupLl;
    private ImageView              mHandsfreeImg;
    private LinearLayout           mHandsfreeLl;
    private ImageView              mDialingImg;
    private LinearLayout           mDialingLl;
    private TRTCVideoLayoutManager mLayoutManagerTrtc;
    private Group                  mInvitingGroup;
    private LinearLayout           mImgContainerLl;
    private TextView               mTimeTv;
    private ImageView              mSponsorAvatarImg;
    private TextView               mSponsorUserNameTv;
    private Group                  mSponsorGroup;
    private Runnable               mTimeRunnable;
    private int                    mTimeCount;
    private Handler                mTimeHandler;
    private HandlerThread          mTimeHandlerThread;

    /**
     * 拨号相关成员变量
     */
    private UserInfo              mSelfModel;
    private List<UserInfo>        mCallUserInfoList = new ArrayList<>(); // 呼叫方
    private Map<String, UserInfo> mCallUserModelMap = new HashMap<>();
    private UserInfo              mSponsorUserInfo;                      // 被叫方
    private List<UserInfo>        mOtherInvitingUserInfoList;
    private int                   mCallType;
    private TRTCCalling           mTRTCCalling;
    private boolean               isHandsFree       = true;
    private boolean               isMuteMic         = false;

    /**
     * 拨号的回调
     */
    private TRTCCallingDelegate mTRTCCallingDelegate = new TRTCCallingDelegate() {
        @Override
        public void onError(int code, String msg) {
            //发生了错误，报错并退出该页面
            ToastUtils.showLong(getString(R.string.trtccalling_toast_call_error_msg, code, msg));
            stopCameraAndFinish();
        }

        @Override
        public void onInvited(String sponsor, List<String> userIdList, boolean isFromGroup, int callType) {
        }

        @Override
        public void onGroupCallInviteeListUpdate(List<String> userIdList) {
        }

        @Override
        public void onUserEnter(final String userId) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    showCallingView();
                    //1.先造一个虚拟的用户添加到屏幕上
                    UserInfo model = new UserInfo();
                    model.userId = userId;
                    model.userName = userId;
                    model.userAvatar = "";
                    mCallUserInfoList.add(model);
                    mCallUserModelMap.put(model.userId, model);
                    TRTCVideoLayout videoLayout = addUserToManager(model);
                    if (videoLayout == null) {
                        return;
                    }
                    videoLayout.setVideoAvailable(false);
                }
            });
        }

        @Override
        public void onUserLeave(final String userId) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    //1. 回收界面元素
                    mLayoutManagerTrtc.recyclerCloudViewView(userId);
                    //2. 删除用户model
                    UserInfo userInfo = mCallUserModelMap.remove(userId);
                    if (userInfo != null) {
                        mCallUserInfoList.remove(userInfo);
                    }
                }
            });
        }

        @Override
        public void onReject(final String userId) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (mCallUserModelMap.containsKey(userId)) {
                        // 进入拒绝环节
                        //1. 回收界面元素
                        mLayoutManagerTrtc.recyclerCloudViewView(userId);
                        //2. 删除用户model
                        UserInfo userInfo = mCallUserModelMap.remove(userId);
                        if (userInfo != null) {
                            mCallUserInfoList.remove(userInfo);
                            ToastUtils.showLong(getString(R.string.trtccalling_toast_user_reject_call, userInfo.userName));
                        }
                    }
                }
            });
        }

        @Override
        public void onNoResp(final String userId) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (mCallUserModelMap.containsKey(userId)) {
                        // 进入无响应环节
                        //1. 回收界面元素
                        mLayoutManagerTrtc.recyclerCloudViewView(userId);
                        //2. 删除用户model
                        UserInfo userInfo = mCallUserModelMap.remove(userId);
                        if (userInfo != null) {
                            mCallUserInfoList.remove(userInfo);
                            ToastUtils.showLong(getString(R.string.trtccalling_toast_user_not_response, userInfo.userName));
                        }
                    }
                }
            });
        }

        @Override
        public void onLineBusy(String userId) {
            if (mCallUserModelMap.containsKey(userId)) {
                // 进入无响应环节
                //1. 回收界面元素
                mLayoutManagerTrtc.recyclerCloudViewView(userId);
                //2. 删除用户model
                UserInfo userInfo = mCallUserModelMap.remove(userId);
                if (userInfo != null) {
                    mCallUserInfoList.remove(userInfo);
                    ToastUtils.showLong(getString(R.string.trtccalling_toast_user_busy, userInfo.userName));
                }
            }
        }

        @Override
        public void onCallingCancel() {
            if (mSponsorUserInfo != null) {
                ToastUtils.showLong(getString(R.string.trtccalling_toast_user_cancel_call, mSponsorUserInfo.userName));
            }
            stopCameraAndFinish();
        }

        @Override
        public void onCallingTimeout() {
            if (mSponsorUserInfo != null) {
                ToastUtils.showLong(getString(R.string.trtccalling_toast_user_timeout, mSponsorUserInfo.userName));
            }
            stopCameraAndFinish();
        }

        @Override
        public void onCallEnd() {
            if (mSponsorUserInfo != null) {
                ToastUtils.showLong(getString(R.string.trtccalling_toast_user_end, mSponsorUserInfo.userName));
            }
            stopCameraAndFinish();
        }

        @Override
        public void onUserVideoAvailable(final String userId, final boolean isVideoAvailable) {
            //有用户的视频开启了
            TRTCVideoLayout layout = mLayoutManagerTrtc.findCloudViewView(userId);
            if (layout != null) {
                layout.setVideoAvailable(isVideoAvailable);
                if (isVideoAvailable) {
                    mTRTCCalling.startRemoteView(userId, layout.getVideoView());
                } else {
                    mTRTCCalling.stopRemoteView(userId);
                }
            } else {

            }
        }

        @Override
        public void onUserAudioAvailable(String userId, boolean isVideoAvailable) {

        }

        @Override
        public void onUserVoiceVolume(Map<String, Integer> volumeMap) {
            for (Map.Entry<String, Integer> entry : volumeMap.entrySet()) {
                String          userId = entry.getKey();
                TRTCVideoLayout layout = mLayoutManagerTrtc.findCloudViewView(userId);
                if (layout != null) {
                    layout.setAudioVolumeProgress(entry.getValue());
                }
            }
        }
    };

    /**
     * 主动拨打给某个用户
     *
     * @param context
     * @param selfInfo
     * @param callUserInfoList
     */
    public static void startCallSomeone(Context context, UserInfo selfInfo, List<UserInfo> callUserInfoList) {
        Intent starter = new Intent(context, TRTCVideoCallActivity.class);
        starter.putExtra(PARAM_TYPE, TYPE_CALL);
        starter.putExtra(PARAM_SELF_INFO, selfInfo);
        starter.putExtra(PARAM_USER, new IntentParams(callUserInfoList));
        context.startActivity(starter);
    }

    /**
     * 作为用户被叫
     *
     * @param context
     * @param beingCallUserInfo
     */
    public static void startBeingCall(Context context, UserInfo selfUserInfo, UserInfo beingCallUserInfo, List<UserInfo> otherInvitingUserInfo) {
        Intent starter = new Intent(context, TRTCVideoCallActivity.class);
        starter.putExtra(PARAM_TYPE, TYPE_BEING_CALLED);
        starter.putExtra(PARAM_SELF_INFO, selfUserInfo);
        starter.putExtra(PARAM_BEINGCALL_USER, beingCallUserInfo);
        starter.putExtra(PARAM_OTHER_INVITING_USER, new IntentParams(otherInvitingUserInfo));
        starter.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(starter);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 应用运行时，保持不锁屏、全屏化
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.trtccalling_videocall_activity_call_main);

        initView();
        initData();
        initListener();
    }

    @Override
    public void onBackPressed() {
        mTRTCCalling.hangup();
        stopCameraAndFinish();
        super.onBackPressed();
    }

    private void stopCameraAndFinish() {
        mTRTCCalling.closeCamera();
        mTRTCCalling.removeDelegate(mTRTCCallingDelegate);
        finish();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        stopTimeCount();
        mTimeHandlerThread.quit();
    }

    private void initListener() {
        mMuteLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isMuteMic = !isMuteMic;
                mTRTCCalling.setMicMute(isMuteMic);
                mMuteImg.setActivated(isMuteMic);
                ToastUtils.showLong(isMuteMic ? R.string.trtccalling_toast_enable_mute : R.string.trtccalling_toast_disable_mute);
            }
        });
        mHandsfreeLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isHandsFree = !isHandsFree;
                mTRTCCalling.setHandsFree(isHandsFree);
                mHandsfreeImg.setActivated(isHandsFree);
                ToastUtils.showLong(isHandsFree ? R.string.trtccalling_toast_use_speaker : R.string.trtccalling_toast_use_handset);
            }
        });
        mMuteImg.setActivated(isMuteMic);
        mHandsfreeImg.setActivated(isHandsFree);
    }

    private void initData() {
        // 初始化成员变量
        mTRTCCalling = TRTCCallingImpl.sharedInstance(this);
        mTRTCCalling.addDelegate(mTRTCCallingDelegate);
        mTimeHandlerThread = new HandlerThread("time-count-thread");
        mTimeHandlerThread.start();
        mTimeHandler = new Handler(mTimeHandlerThread.getLooper());
        // 初始化从外界获取的数据
        Intent intent = getIntent();
        //自己的资料
        mSelfModel = (UserInfo) intent.getSerializableExtra(PARAM_SELF_INFO);
        mCallType = intent.getIntExtra(PARAM_TYPE, TYPE_BEING_CALLED);
        if (mCallType == TYPE_BEING_CALLED) {
            // 作为被叫
            mSponsorUserInfo = (UserInfo) intent.getSerializableExtra(PARAM_BEINGCALL_USER);
            IntentParams params = (IntentParams) intent.getSerializableExtra(PARAM_OTHER_INVITING_USER);
            if (params != null) {
                mOtherInvitingUserInfoList = params.mUserInfos;
            }
            showWaitingResponseView();
        } else {
            // 主叫方
            IntentParams params = (IntentParams) intent.getSerializableExtra(PARAM_USER);
            if (params != null) {
                mCallUserInfoList = params.mUserInfos;
                for (UserInfo userInfo : mCallUserInfoList) {
                    mCallUserModelMap.put(userInfo.userId, userInfo);
                }
                startInviting();
                showInvitingView();
            }
        }

    }

    private void startInviting() {
        List<String> list = new ArrayList<>();
        for (UserInfo userInfo : mCallUserInfoList) {
            list.add(userInfo.userId);
        }
        mTRTCCalling.groupCall(list, TRTCCalling.TYPE_VIDEO_CALL, "");
    }

    private void initView() {
        mMuteImg = (ImageView) findViewById(R.id.iv_mute);
        mMuteLl = (LinearLayout) findViewById(R.id.ll_mute);
        mHangupImg = (ImageView) findViewById(R.id.iv_hangup);
        mHangupLl = (LinearLayout) findViewById(R.id.ll_hangup);
        mHandsfreeImg = (ImageView) findViewById(R.id.iv_handsfree);
        mHandsfreeLl = (LinearLayout) findViewById(R.id.ll_handsfree);
        mDialingImg = (ImageView) findViewById(R.id.iv_dialing);
        mDialingLl = (LinearLayout) findViewById(R.id.ll_dialing);
        mLayoutManagerTrtc = (TRTCVideoLayoutManager) findViewById(R.id.trtc_layout_manager);
        mInvitingGroup = (Group) findViewById(R.id.group_inviting);
        mImgContainerLl = (LinearLayout) findViewById(R.id.ll_img_container);
        mTimeTv = (TextView) findViewById(R.id.tv_time);
        mSponsorAvatarImg = (ImageView) findViewById(R.id.iv_sponsor_avatar);
        mSponsorUserNameTv = (TextView) findViewById(R.id.tv_sponsor_user_name);
        mSponsorGroup = (Group) findViewById(R.id.group_sponsor);
    }


    /**
     * 等待接听界面
     */
    public void showWaitingResponseView() {
        //1. 展示自己的画面
        mLayoutManagerTrtc.setMySelfUserId(mSelfModel.userId);
        TRTCVideoLayout videoLayout = addUserToManager(mSelfModel);
        if (videoLayout == null) {
            return;
        }
        videoLayout.setVideoAvailable(true);
        mTRTCCalling.openCamera(true, videoLayout.getVideoView());

        //2. 展示对方的头像和蒙层
        mSponsorGroup.setVisibility(View.VISIBLE);
        Picasso.get().load(mSponsorUserInfo.userAvatar).into(mSponsorAvatarImg);
        mSponsorUserNameTv.setText(mSponsorUserInfo.userName);

        //3. 展示电话对应界面
        mHangupLl.setVisibility(View.VISIBLE);
        mDialingLl.setVisibility(View.VISIBLE);
        mHandsfreeLl.setVisibility(View.GONE);
        mMuteLl.setVisibility(View.GONE);
        //3. 设置对应的listener
        mHangupLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCalling.reject();
                stopCameraAndFinish();
            }
        });
        mDialingLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //2.接听电话
                mTRTCCalling.accept();
                showCallingView();
            }
        });
        //4. 展示其他用户界面
        showOtherInvitingUserView();
    }

    /**
     * 展示邀请列表
     */
    public void showInvitingView() {
        //1. 展示自己的界面
        mLayoutManagerTrtc.setMySelfUserId(mSelfModel.userId);
        TRTCVideoLayout videoLayout = addUserToManager(mSelfModel);
        if (videoLayout == null) {
            return;
        }
        videoLayout.setVideoAvailable(true);
        mTRTCCalling.openCamera(true, videoLayout.getVideoView());
        //        for (UserInfo userModel : mCallUserInfoList) {
        //            TRTCVideoLayout layout = addUserToManager(userModel);
        //            layout.getShadeImg().setVisibility(View.VISIBLE);
        //        }
        //2. 设置底部栏
        mHangupLl.setVisibility(View.VISIBLE);
        mHangupLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCalling.hangup();
                stopCameraAndFinish();
            }
        });
        mDialingLl.setVisibility(View.GONE);
        mHandsfreeLl.setVisibility(View.VISIBLE);
        mMuteLl.setVisibility(View.VISIBLE);
        //3. 隐藏中间他们也在界面
        hideOtherInvitingUserView();
        //4. sponsor画面也隐藏
        mSponsorGroup.setVisibility(View.GONE);
    }

    /**
     * 展示通话中的界面
     */
    public void showCallingView() {
        //1. 蒙版消失
        mSponsorGroup.setVisibility(View.GONE);
        //2. 底部状态栏
        mHangupLl.setVisibility(View.VISIBLE);
        mDialingLl.setVisibility(View.GONE);
        mHandsfreeLl.setVisibility(View.VISIBLE);
        mMuteLl.setVisibility(View.VISIBLE);

        mHangupLl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTRTCCalling.hangup();
                stopCameraAndFinish();
            }
        });
        showTimeCount();
        hideOtherInvitingUserView();
    }

    private void showTimeCount() {
        if (mTimeRunnable != null) {
            return;
        }
        mTimeCount = 0;
        mTimeTv.setText(getShowTime(mTimeCount));
        if (mTimeRunnable == null) {
            mTimeRunnable = new Runnable() {
                @Override
                public void run() {
                    mTimeCount++;
                    if (mTimeTv != null) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                mTimeTv.setText(getShowTime(mTimeCount));
                            }
                        });
                    }
                    mTimeHandler.postDelayed(mTimeRunnable, 1000);
                }
            };
        }
        mTimeHandler.postDelayed(mTimeRunnable, 1000);
    }

    private void stopTimeCount() {
        mTimeHandler.removeCallbacks(mTimeRunnable);
        mTimeRunnable = null;
    }

    private String getShowTime(int count) {
        return getString(R.string.trtccalling_called_time_format, count / 60, count % 60);
    }

    private void showOtherInvitingUserView() {
        if (mOtherInvitingUserInfoList == null || mOtherInvitingUserInfoList.size() == 0) {
            return;
        }
        mInvitingGroup.setVisibility(View.VISIBLE);
        int squareWidth = getResources().getDimensionPixelOffset(R.dimen.trtccalling_small_image_size);
        int leftMargin  = getResources().getDimensionPixelOffset(R.dimen.trtccalling_small_image_left_margin);
        for (int index = 0; index < mOtherInvitingUserInfoList.size() && index < MAX_SHOW_INVITING_USER; index++) {
            UserInfo                  userInfo     = mOtherInvitingUserInfoList.get(index);
            ImageView                 imageView    = new ImageView(this);
            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(squareWidth, squareWidth);
            if (index != 0) {
                layoutParams.leftMargin = leftMargin;
            }
            imageView.setLayoutParams(layoutParams);
            Picasso.get().load(userInfo.userAvatar).into(imageView);
            mImgContainerLl.addView(imageView);
        }
    }

    private void hideOtherInvitingUserView() {
        mInvitingGroup.setVisibility(View.GONE);
    }

    private TRTCVideoLayout addUserToManager(UserInfo userInfo) {
        TRTCVideoLayout layout = mLayoutManagerTrtc.allocCloudVideoView(userInfo.userId);
        if (layout == null) {
            return null;
        }
        layout.getUserNameTv().setText(userInfo.userName);
        if (!TextUtils.isEmpty(userInfo.userAvatar)) {
            Picasso.get().load(userInfo.userAvatar).into(layout.getHeadImg());
        }
        return layout;
    }

    private static class IntentParams implements Serializable {
        public List<UserInfo> mUserInfos;

        public IntentParams(List<UserInfo> userInfos) {
            mUserInfos = userInfos;
        }
    }

    public static class UserInfo implements Serializable {
        public String userId;
        public String userAvatar;
        public String userName;
    }
}
