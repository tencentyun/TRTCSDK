package com.tencent.liteav.demo.trtcvoiceroom;

import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.constraint.Group;
import android.support.v4.app.DialogFragment;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.AppCompatImageButton;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.text.Html;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.demo.trtcvoiceroom.model.SettingConfig;
import com.tencent.liteav.demo.trtcvoiceroom.model.VoiceRoomConfig;
import com.tencent.liteav.demo.trtcvoiceroom.widgets.BGMSettingFragment;
import com.tencent.liteav.demo.trtcvoiceroom.widgets.EffectSettingFragment;
import com.tencent.liteav.demo.trtcvoiceroom.widgets.MoreSettingFragment;
import com.tencent.liteav.demo.trtcvoiceroom.widgets.VoiceChangerSettingFragment;
import com.tencent.liteav.demo.trtcvoiceroom.widgets.VoiceRoomSeatAdapter;
import com.tencent.liteav.demo.trtcvoiceroom.widgets.VoiceRoomSeatEntity;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import de.hdodenhof.circleimageview.CircleImageView;

public class VoiceRoomMainActivity extends AppCompatActivity implements VoiceRoomContract.IView, VoiceRoomSeatAdapter.OnItemClickListener {
    private static final int    MAX_SEAT_SIZE = 6;
    private static final String TAG           = VoiceRoomMainActivity.class.getName();

    /**
     *
     */
    private String                       mSelfUserId;     //进房用户ID
    private int                          mInitRole;       //用户初始角色
    private int                          mCurrentRole;    //用户当前角色
    private Set<String>                  mSeatUserSet; //在座位上的主播集合
    /**
     * 弹窗
     */
    private BGMSettingFragment           mBGMSettingFragment;
    private EffectSettingFragment        mEffectSettingFragment;
    private VoiceChangerSettingFragment  mVoiceChangerSettingFragment;
    private MoreSettingFragment          mMoreSettingFragment;
    /**
     * 界面元素
     */
    private VoiceRoomContract.IPresenter mPresenter;
    private TextView                     mTitleToolbar;
    private Toolbar                      mToolbar;
    private TextView                     mOnlineNumberTv;
    private CircleImageView              mHeadImg;
    private TextView                     mNameTv;
    private RecyclerView                 mSeatRv;
    private List<VoiceRoomSeatEntity>    mVoiceRoomSeatEntityList;
    private VoiceRoomSeatAdapter         mVoiceRoomSeatAdapter;
    private AppCompatImageButton         mMicBtn;
    private AppCompatImageButton         mAudioBtn;
    private AppCompatImageButton         mBgmBtn;
    private AppCompatImageButton         mEffectBtn;
    private AppCompatImageButton         mVoiceChangeBtn;
    private TextView                     mBgmTypeTv;
    private TextView                     mVoiceChangeTv;
    private ProgressDialog               mLoadingDialog;
    private AlertDialog                  mAlertDialog;
    private AppCompatImageButton         mMoreBtn;
    private TextView                     mReverbTv;
    private Group                        mLiveGp;
    private TextView                     mLiveStatusTv;
    private TextView                     mLiveSwitchBtn;

    // 用于loading超时处理
    private Handler  mMainHandler;
    private Runnable mLoadingTimeoutRunnable = new Runnable() {
        @Override
        public void run() {
            stopLoading();
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.voiceroom_activity_main);
        initView();
        initData();
        initListener();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mMainHandler.removeCallbacks(mLoadingTimeoutRunnable);
        if (mPresenter != null) {
            mPresenter.destroy();
        }
    }


    private void initListener() {
        mMicBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (checkButtonPermission()) {
                    boolean currentMode = !mMicBtn.isSelected();
                    mPresenter.enableMic(currentMode);
                    mMicBtn.setSelected(currentMode);
                    if (currentMode) {
                        ToastUtils.showLong("您已开启麦克风");
                    } else {
                        ToastUtils.showLong("您已关闭麦克风");
                    }
                }
            }
        });
        mAudioBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                boolean currentMode = !mAudioBtn.isSelected();
                mPresenter.enableAudio(currentMode);
                mAudioBtn.setSelected(currentMode);
                if (currentMode) {
                    ToastUtils.showLong("您已取消静音");
                } else {
                    ToastUtils.showLong("您已静音");
                }
            }
        });
        mBgmBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (checkButtonPermission()) {
                    if (mBGMSettingFragment == null) {
                        mBGMSettingFragment = new BGMSettingFragment();
                        mBGMSettingFragment.setMarginBottom(getResources().getDimensionPixelOffset(R.dimen.dialog_margin_bottom));
                        mBGMSettingFragment.setPresenter(mPresenter);
                    }
                    showDialogFragment(mBGMSettingFragment, "BGMSettingFragment");
                }
            }
        });
        mEffectBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (checkButtonPermission()) {
                    if (mEffectSettingFragment == null) {
                        mEffectSettingFragment = new EffectSettingFragment();
                        mEffectSettingFragment.setMarginBottom(getResources().getDimensionPixelOffset(R.dimen.dialog_margin_bottom));
                        mEffectSettingFragment.copyEffectFolder(VoiceRoomMainActivity.this);
                        mEffectSettingFragment.setPresenter(mPresenter);
                    }
                    showDialogFragment(mEffectSettingFragment, "EffectSettingFragment");
                }
            }
        });
        mVoiceChangeBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (checkButtonPermission()) {
                    if (mVoiceChangerSettingFragment == null) {
                        mVoiceChangerSettingFragment = new VoiceChangerSettingFragment();
                        mVoiceChangerSettingFragment.setMarginBottom(getResources().getDimensionPixelOffset(R.dimen.dialog_margin_bottom));
                        mVoiceChangerSettingFragment.setPresenter(mPresenter);
                    }
                    showDialogFragment(mVoiceChangerSettingFragment, "VoiceChangerSettingFragment");
                }
            }
        });
        mMoreBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (checkButtonPermission()) {
                    if (mMoreSettingFragment == null) {
                        mMoreSettingFragment = new MoreSettingFragment();
                        mMoreSettingFragment.setMarginBottom(getResources().getDimensionPixelOffset(R.dimen.dialog_margin_bottom));
                        mMoreSettingFragment.setPresenter(mPresenter);
                    }
                    showDialogFragment(mMoreSettingFragment, "MoreSettingFragment");
                }
            }
        });
        mHeadImg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onSwitchRole();
            }
        });
        mLiveSwitchBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mPresenter.switchLivePlay();
            }
        });
    }

    private void onSwitchRole() {
        //只有初始状态进来是观众才能操作上下麦
        if (mInitRole == TRTCCloudDef.TRTCRoleAudience) {
            showSwitchDialog();
        } else {
            ToastUtils.showLong("您需要以观众身份进房才能操作上下麦");
        }
    }

    private void showSwitchDialog() {
        if (mAlertDialog != null && mAlertDialog.isShowing()) {
            mAlertDialog.dismiss();
        }
        String msg = mCurrentRole == TRTCCloudDef.TRTCRoleAudience ? "确定上麦" : "确定下麦";
        mAlertDialog = new AlertDialog.Builder(this)
                .setMessage(msg)
                .setPositiveButton("确定", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        mCurrentRole = mPresenter.switchRole();
                        refreshView();
                    }
                }).setNegativeButton("取消", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {

                    }
                }).create();
        mAlertDialog.show();
    }

    /**
     * 判断是否为主播，有操作按钮的权限
     *
     * @return 是否有权限
     */
    private boolean checkButtonPermission() {
        boolean hasPermission = (mCurrentRole == TRTCCloudDef.TRTCRoleAnchor);
        if (!hasPermission) {
            ToastUtils.showLong("主播才能操作哦");
        }
        return hasPermission;
    }

    private void initData() {
        Intent          intent = getIntent();
        VoiceRoomConfig config = (VoiceRoomConfig) intent.getSerializableExtra(VoiceRoomConfig.DATA);
        if (config != null) {
            mPresenter = new VoiceRoomMainPresenter(this, config, this);
            mSeatUserSet = new HashSet<>();
            mSelfUserId = String.valueOf(config.userId);
            mCurrentRole = config.role;
            mInitRole = config.role;
            // 两个角色都共同拥有的角色
            mTitleToolbar.setText(getString(R.string.chat_room_title, config.roomId));
            refreshView();
            // 业务逻辑封装在presenter里面
            mPresenter.init(this);
        } else {
            finish();
        }
    }

    private void refreshView() {
        // 处理不同角色的界面的差异
        if (mCurrentRole == TRTCCloudDef.TRTCRoleAnchor) {
            //目前的状态是主播
            //设置激活状态
            mMicBtn.setActivated(true);
            mAudioBtn.setActivated(true);
            mBgmBtn.setActivated(true);
            mEffectBtn.setActivated(true);
            mVoiceChangeBtn.setActivated(true);
            mMoreBtn.setActivated(true);
            //设置选中态
            mMicBtn.setSelected(true);
            mAudioBtn.setSelected(true);
            //设置头像
            mHeadImg.setImageBitmap(Utils.getAvatar(mSelfUserId));
            mNameTv.setText(mSelfUserId);
            mNameTv.setTextColor(getResources().getColor(R.color.white));
            mLiveGp.setVisibility(View.GONE);
        } else {
            //目前的状态是观众
            //设置激活状态
            mMicBtn.setActivated(false);
            mAudioBtn.setActivated(true);
            mBgmBtn.setActivated(false);
            mEffectBtn.setActivated(false);
            mVoiceChangeBtn.setActivated(false);
            mMoreBtn.setActivated(false);
            //设置选中态
            mAudioBtn.setSelected(true);
            //重置界面状态
            mBgmTypeTv.setVisibility(View.GONE);
            mReverbTv.setVisibility(View.GONE);
            mVoiceChangeTv.setVisibility(View.GONE);
            mLiveStatusTv.setVisibility(View.GONE);
            //头像设置为上麦
            mHeadImg.setImageResource(R.drawable.ic_add);
            mNameTv.setText("虚位以待");
            mNameTv.setTextColor(getResources().getColor(R.color.colorWaitText));
            mLiveGp.setVisibility(View.VISIBLE);
            updateSelfTalk(false);
            updateLiveView(mPresenter.isCdnPlay());
        }
    }

    @Override
    public void updateLiveView(boolean isCdnPlay) {
        // cdn播放状态变化
        if (isCdnPlay) {
            mLiveStatusTv.setText("CDN直播中");
        } else {
            mLiveStatusTv.setText("低延时直播中");
        }
    }

    private void initView() {
        mTitleToolbar = (TextView) findViewById(R.id.toolbar_title);
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mOnlineNumberTv = (TextView) findViewById(R.id.tv_online_number);
        mHeadImg = (CircleImageView) findViewById(R.id.img_head);
        mNameTv = (TextView) findViewById(R.id.tv_name);
        mSeatRv = (RecyclerView) findViewById(R.id.rv_seat);

        GridLayoutManager gridLayoutManager = new GridLayoutManager(this, 3);
        mVoiceRoomSeatEntityList = new ArrayList<>();
        for (int i = 0; i < MAX_SEAT_SIZE; i++) {
            mVoiceRoomSeatEntityList.add(new VoiceRoomSeatEntity(true));
        }
        mVoiceRoomSeatAdapter = new VoiceRoomSeatAdapter(this, mVoiceRoomSeatEntityList, this);
        mSeatRv.setLayoutManager(gridLayoutManager);
        mSeatRv.setAdapter(mVoiceRoomSeatAdapter);
        mMicBtn = (AppCompatImageButton) findViewById(R.id.btn_mic);
        mAudioBtn = (AppCompatImageButton) findViewById(R.id.btn_audio);
        mBgmBtn = (AppCompatImageButton) findViewById(R.id.btn_bgm);
        mEffectBtn = (AppCompatImageButton) findViewById(R.id.btn_effect);
        mVoiceChangeBtn = (AppCompatImageButton) findViewById(R.id.btn_voice_change);
        mBgmTypeTv = (TextView) findViewById(R.id.tv_bgm_type);
        mVoiceChangeTv = (TextView) findViewById(R.id.tv_voice_change);
        // 设置loading对话框
        mLoadingDialog = new ProgressDialog(this, R.style.loading_dialog);
        mLoadingDialog.setCancelable(false);
        mLoadingDialog.setCanceledOnTouchOutside(false);
        // 在线主播暂时隐藏
        mOnlineNumberTv.setVisibility(View.GONE);
        mMoreBtn = (AppCompatImageButton) findViewById(R.id.btn_more);

        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        mReverbTv = (TextView) findViewById(R.id.tv_reverb);
        mLiveGp = (Group) findViewById(R.id.gp_live);
        mLiveStatusTv = (TextView) findViewById(R.id.tv_live_status);
        mLiveSwitchBtn = (TextView) findViewById(R.id.btn_live_switch);

        mMainHandler = new Handler();
    }

    /**
     * 展示dialog界面
     */
    private void showDialogFragment(DialogFragment dialogFragment, String tag) {
        if (dialogFragment != null) {
            if (dialogFragment.isVisible()) {
                try {
                    dialogFragment.dismissAllowingStateLoss();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            } else {
                dialogFragment.show(getSupportFragmentManager(), tag);
            }
        }
    }

    @Override
    public void updateOnlineNum(int number) {
        //        mOnlineNumberTv.setText(Html.fromHtml(getString(R.string.chat_room_online_number, number)));
    }

    @Override
    public void updateRemoteUserTalk(List<String> userIdList) {
        if (!CollectionUtils.isEmpty(userIdList)) {
            CharSequence t = ",";
            Log.d(TAG, "userIdList:" + TextUtils.join(t, userIdList.toArray()));
        }
        for (VoiceRoomSeatEntity entity : mVoiceRoomSeatEntityList) {
            if (!entity.isPlaceHolder && userIdList.contains(entity.userName)) {
                entity.isTalk = true;
            } else {
                entity.isTalk = false;
            }
        }
        mVoiceRoomSeatAdapter.notifyDataSetChanged();
    }

    @Override
    public void updateSelfTalk(boolean isTalk) {
        // 说话的人是自己
        if (isTalk) {
            mHeadImg.setBorderColor(getResources().getColor(R.color.colorUserTalk));
        } else {
            mHeadImg.setBorderColor(getResources().getColor(R.color.colorUserMute));
        }
    }

    @Override
    public void updateBGMView() {
        if (mBGMSettingFragment != null && mBGMSettingFragment.isVisible()) {
            mBGMSettingFragment.updateView();
        }
        SettingConfig config = SettingConfig.getInstance();
        if (config.isPlayingLocal || config.isPlayingOnline) {
            mBgmBtn.setSelected(true);
            mBgmTypeTv.setVisibility(View.VISIBLE);
            mBgmTypeTv.setText(Html.fromHtml(getString(R.string.voiceroom_bgm_type, config.isPlayingLocal ? "本地音乐" : "网络音乐")));
        } else {
            mBgmBtn.setSelected(false);
            mBgmTypeTv.setVisibility(View.GONE);
        }
    }

    @Override
    public void updateBGMProgress(boolean isLocal, int progress) {
        if (mBGMSettingFragment != null) {
            mBGMSettingFragment.updateProgress(isLocal, progress);
        }
    }

    @Override
    public void updateVoiceChangeView(int type, String name) {
        if (type == TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_0) {
            mVoiceChangeTv.setVisibility(View.GONE);
            mVoiceChangeBtn.setSelected(false);
        } else {
            mVoiceChangeBtn.setSelected(true);
            mVoiceChangeTv.setVisibility(View.VISIBLE);
            mVoiceChangeTv.setText(Html.fromHtml(getString(R.string.voiceroom_voice_changer, name)));
        }
    }

    @Override
    public void updateReverBView(int type, String name) {
        if (type == TRTCCloudDef.TRTC_REVERB_TYPE_0) {
            mReverbTv.setVisibility(View.GONE);
        } else {
            mReverbTv.setVisibility(View.VISIBLE);
            mReverbTv.setText(Html.fromHtml(getString(R.string.voiceroom_reverb, name)));
        }
    }

    @Override
    public void updateEffectView(boolean isPlay) {
        mEffectBtn.setSelected(isPlay);
    }

    @Override
    public void stopLoading() {
        Log.d(TAG, "dismissLoading");
        if (mLoadingDialog != null && mLoadingDialog.isShowing()) {
            mLoadingDialog.dismiss();
        }
    }

    @Override
    public void startLoading() {
        Log.d(TAG, "showLoading");
        mLoadingDialog.show();
        mMainHandler.removeCallbacks(mLoadingTimeoutRunnable);
        mMainHandler.postDelayed(mLoadingTimeoutRunnable, 6000);
    }


    @Override
    public void resetSeatView() {
        mSeatUserSet.clear();
        for (VoiceRoomSeatEntity entity : mVoiceRoomSeatEntityList) {
            entity.isPlaceHolder = true;
        }
        mVoiceRoomSeatAdapter.notifyDataSetChanged();
    }

    @Override
    public void updateAnchorEnter(String userId) {
        // 如果主播已经在座位上就不再坐进来了
        if (mSeatUserSet.contains(userId)) {
            return;
        }
        for (VoiceRoomSeatEntity entity : mVoiceRoomSeatEntityList) {
            if (entity.isPlaceHolder) {
                entity.isPlaceHolder = false;
                entity.userName = userId;
                mSeatUserSet.add(userId);
                break;
            }
        }
        mVoiceRoomSeatAdapter.notifyDataSetChanged();
    }

    @Override
    public void updateAnchorExit(String userId) {
        mSeatUserSet.remove(userId);
        for (VoiceRoomSeatEntity entity : mVoiceRoomSeatEntityList) {
            if (!entity.isPlaceHolder && userId.equals(entity.userName)) {
                entity.isPlaceHolder = true;
                break;
            }
        }
        mVoiceRoomSeatAdapter.notifyDataSetChanged();
    }

    /**
     * 座位上点击按钮的反馈
     *
     * @param position
     */
    @Override
    public void onItemClick(int position) {
        ToastUtils.showLong("功能开发中");
    }
}
