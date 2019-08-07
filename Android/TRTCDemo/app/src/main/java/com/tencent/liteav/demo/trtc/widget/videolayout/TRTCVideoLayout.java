package com.tencent.liteav.demo.trtc.widget.videolayout;

import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.liteav.demo.R;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloudDef;

import java.lang.ref.WeakReference;
import java.util.HashMap;

/**
 * Module: TRTCVideoLayout
 *
 * Function:
 *
 * 此 TRTCVideoLayout 封装了{@link TXCloudVideoView} 以及业务逻辑 UI 控件
 * 作用：
 * 1. 实现了手势监听，配合 {@link TRTCVideoLayoutManager} 能够实现自由拖动 View。
 *    详情可见：{@link TRTCVideoLayout#initGestureListener()}
 *    实现原理：利用 RelativeLayout 的 margin 实现了能够在父容器自由定位的特性；需要注意，{@link TRTCVideoLayout} 不能增加约束规则，如 alignParentRight 等，否则无法自由定位。
 *
 * 2. 对{@link TXCloudVideoView} 与逻辑 UI 进行组合，在 muteLocal、音量回调等情况，能够进行 UI 相关的变化。若您的项目中，也相关的业务逻辑，可以参照 Demo 的相关实现。
 */
class TRTCVideoLayout extends RelativeLayout implements View.OnClickListener {
    private TXCloudVideoView mVideoView;
    private OnClickListener mClickListener;
    private GestureDetector mSimpleOnGestureListener;
    private ProgressBar mPbAudioVolume;
    private LinearLayout mLlController;
    private Button mBtnMuteVideo, mBtnMuteAudio, mBtnFill;
    private FrameLayout mLlNoVideo;
    private TextView mTvContent;
    private ImageView mIvNoS;
    private ViewGroup mVgFuc;
    private HashMap<Integer, Integer> mNoSMap = null;
    private boolean mMoveable;
    public WeakReference<IVideoLayoutListener> mWefListener;
    private boolean mEnableFill = false;
    private boolean mEnableAudio = true;
    private boolean mEnableVideo = true;


    public TXCloudVideoView getVideoView() {
        return mVideoView;
    }

    public void updateNetworkQuality(int quality) {
        if (quality < TRTCCloudDef.TRTC_QUALITY_Excellent) {
            quality = TRTCCloudDef.TRTC_QUALITY_Excellent;
        }
        if (quality > TRTCCloudDef.TRTC_QUALITY_Down) {
            quality = TRTCCloudDef.TRTC_QUALITY_Down;
        }

        if (mIvNoS != null) {
            mIvNoS.setImageResource(mNoSMap.get(Integer.valueOf(quality).intValue()));
        }
    }

    public void setBottomControllerVisibility(int visibility) {
        if (mLlController != null)
            mLlController.setVisibility(visibility);
    }

    public void updateNoVideoLayout(String text, int visibility) {
        if (mTvContent != null) {
            mTvContent.setText(text);
        }
        if (mLlNoVideo != null) {
            mLlNoVideo.setVisibility(visibility);
        }
    }

    public void setAudioVolumeProgress(int progress) {
        if (mPbAudioVolume != null) {
            mPbAudioVolume.setProgress(progress);
        }
    }

    public void setAudioVolumeProgressBarVisibility(int visibility) {
        if (mPbAudioVolume != null) {
            mPbAudioVolume.setVisibility(visibility);
        }
    }

    public TRTCVideoLayout(Context context) {
        this(context, null);
    }

    public TRTCVideoLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        initFuncLayout();
        initGestureListener();
        initNoS();
    }

    private void initNoS() {
        mNoSMap = new HashMap<>();
        mNoSMap.put(Integer.valueOf(TRTCCloudDef.TRTC_QUALITY_Down), Integer.valueOf(R.mipmap.signal1));
        mNoSMap.put(Integer.valueOf(TRTCCloudDef.TRTC_QUALITY_Vbad), Integer.valueOf(R.mipmap.signal2));
        mNoSMap.put(Integer.valueOf(TRTCCloudDef.TRTC_QUALITY_Bad), Integer.valueOf(R.mipmap.signal3));
        mNoSMap.put(Integer.valueOf(TRTCCloudDef.TRTC_QUALITY_Poor), Integer.valueOf(R.mipmap.signal4));
        mNoSMap.put(Integer.valueOf(TRTCCloudDef.TRTC_QUALITY_Good), Integer.valueOf(R.mipmap.signal5));
        mNoSMap.put(Integer.valueOf(TRTCCloudDef.TRTC_QUALITY_Excellent), Integer.valueOf(R.mipmap.signal6));
    }


    private void initFuncLayout() {
        mVgFuc = (ViewGroup) LayoutInflater.from(getContext()).inflate(R.layout.layout_trtc_func, this, true);
        mVideoView = (TXCloudVideoView) mVgFuc.findViewById(R.id.trtc_tc_cloud_view);
        mPbAudioVolume = (ProgressBar) mVgFuc.findViewById(R.id.trtc_pb_audio);
        mLlController = (LinearLayout) mVgFuc.findViewById(R.id.trtc_ll_controller);
        mBtnMuteVideo = (Button) mVgFuc.findViewById(R.id.trtc_btn_mute_video);
        mBtnMuteVideo.setOnClickListener(this);
        mBtnMuteAudio = (Button) mVgFuc.findViewById(R.id.trtc_btn_mute_audio);
        mBtnMuteAudio.setOnClickListener(this);
        mBtnFill = (Button) mVgFuc.findViewById(R.id.trtc_btn_fill);
        mBtnFill.setOnClickListener(this);
        mLlNoVideo = (FrameLayout) mVgFuc.findViewById(R.id.trtc_fl_no_video);
        mTvContent = (TextView) mVgFuc.findViewById(R.id.trtc_tv_content);
        mIvNoS = (ImageView) mVgFuc.findViewById(R.id.trtc_iv_nos);
    }


    private void initGestureListener() {
        mSimpleOnGestureListener = new GestureDetector(getContext(), new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onSingleTapUp(MotionEvent e) {
                if (mClickListener != null) {
                    mClickListener.onClick(TRTCVideoLayout.this);
                }
                return true;
            }

            @Override
            public boolean onDown(MotionEvent e) {
                return true;
            }

            @Override
            public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
                if (!mMoveable) return false;
                ViewGroup.LayoutParams params = TRTCVideoLayout.this.getLayoutParams();
                // 当 TRTCVideoView 的父容器是 RelativeLayout 的时候，可以实现拖动
                if (params instanceof LayoutParams) {
                    LayoutParams layoutParams = (LayoutParams) TRTCVideoLayout.this.getLayoutParams();
                    int newX = (int) (layoutParams.leftMargin + (e2.getX() - e1.getX()));
                    int newY = (int) (layoutParams.topMargin + (e2.getY() - e1.getY()));

                    layoutParams.leftMargin = newX;
                    layoutParams.topMargin = newY;

                    TRTCVideoLayout.this.setLayoutParams(layoutParams);
                }
                return true;
            }
        });
        this.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                return mSimpleOnGestureListener.onTouchEvent(event);
            }
        });
    }

    @Override
    public void setOnClickListener(@Nullable OnClickListener l) {
        mClickListener = l;
    }


    public void setMoveable(boolean enable) {
        mMoveable = enable;
    }

    @Override
    public void onClick(View v) {
        IVideoLayoutListener listener = mWefListener != null ? mWefListener.get() : null;
        if (listener == null) return;
        switch (v.getId()) {
            case R.id.trtc_btn_fill:
                mEnableFill = !mEnableFill;
                if (mEnableFill) {
                    v.setBackgroundResource(R.mipmap.fill_scale);
                } else {
                    v.setBackgroundResource(R.mipmap.fill_adjust);
                }
                listener.onClickFill(this, mEnableFill);
                break;
            case R.id.trtc_btn_mute_audio:
                mEnableAudio = !mEnableAudio;
                if (mEnableAudio) {
                    v.setBackgroundResource(R.mipmap.remote_audio_enable);
                } else {
                    v.setBackgroundResource(R.mipmap.remote_audio_disable);
                }
                listener.onClickMuteAudio(this, !mEnableAudio);
                break;
            case R.id.trtc_btn_mute_video:
                mEnableVideo = !mEnableVideo;
                if (mEnableVideo) {
                    v.setBackgroundResource(R.mipmap.remote_video_enable);
                } else {
                    v.setBackgroundResource(R.mipmap.remote_video_disable);
                }
                listener.onClickMuteVideo(this, !mEnableVideo);
                break;
        }
    }

    public void setIVideoLayoutListener(IVideoLayoutListener listener) {
        if (listener == null) {
            mWefListener = null;
        } else {
            mWefListener = new WeakReference<>(listener);
        }
    }

    public interface IVideoLayoutListener {
        void onClickFill(TRTCVideoLayout view, boolean enableFill);

        void onClickMuteAudio(TRTCVideoLayout view, boolean isMute);

        void onClickMuteVideo(TRTCVideoLayout view, boolean isMute);
    }
}
