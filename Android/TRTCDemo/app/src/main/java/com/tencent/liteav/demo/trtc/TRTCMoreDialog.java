package com.tencent.liteav.demo.trtc;

import android.app.Dialog;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.RadioButton;
import android.widget.TextView;

import com.tencent.liteav.demo.R;
import com.tencent.trtc.TRTCCloudDef;

import java.lang.ref.WeakReference;

public class TRTCMoreDialog extends Dialog implements View.OnClickListener {
    private final static String TAG                                     = "TRTCMoreDialog";

    private final static String KEY_MORE_SETTING_DATA                   = "KEY_MORE_SETTING_DATA";

    private final static String KEY_CAMERA_FRONT                        = "KEY_CAMERA_FRONT";
    private final static String KEY_VIDEO_FILL_MODE                     = "KEY_VIDEO_FILL_MODE";
    private final static String KEY_VIDEO_VERTICAL                      = "KEY_VIDEO_VERTICAL";
    private final static String KEY_ENABLE_AUDIO_CAPTURE                = "KEY_ENABLE_AUDIO_CAPTURE";
    private final static String KEY_AUDIO_HAND_FREE_MODE                = "KEY_AUDIO_HAND_FREE_MODE";
    private final static String KEY_LOCAL_VIDEO_MIRROR                  = "KEY_LOCAL_VIDEO_MIRROR";
    private final static String KEY_REMOTE_VIDEO_MIRROR                 = "KEY_REMOTE_VIDEO_MIRROR";
    private final static String KEY_ENABLE_GSENSOR_MODE                 = "KEY_ENABLE_GSENSOR_MODE";
    private final static String KEY_AUDIO_VOLUME_EVALUATION             = "KEY_ENABLE_VOLUME_EVALUATION";
    private final static String KEY_ENABLE_CLOUD_MIXTURE                = "KEY_ENABLE_CLOUD_MIXTURE";

    private boolean mCameraFront                                        = true;
    private boolean mVideoFillMode                                      = true;
    private boolean mVideoVertical                                      = true;
    private boolean mEnableAudioCapture                                 = true;
    private boolean mAudioHandFreeMode                                  = true;
    private boolean mEnableGSensorMode                                  = false;
    private boolean mAudioVolumeEvaluation                              = true;
    private boolean mEnableCloudMixture                                 = true;
    private boolean mEnableVideoEncMirror                               = false;
    private int     mLocalVideoViewMirror                               = TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO;
    private int     mRole                                               = TRTCCloudDef.TRTCRoleAnchor;

    private RadioButton mRbCameraFront;
    private RadioButton mRbCameraBack;
    private RadioButton mRbVideoFill;
    private RadioButton mRbVideoAdjust;
    private RadioButton mRbVideoVertical;
    private RadioButton mRbVideoHorizontal;
    private RadioButton mRbLocalVideoMirrorAuto;
    private RadioButton mRbLocalVideoMirrorDisable;
    private RadioButton mRbRoleAnchor;
    private RadioButton mRbRoleAudience;

    private CheckBox    mCbEnableAudio;
    private CheckBox    mCbAudioHandFree;
    private CheckBox    mCbVideoEncMirror;
    private CheckBox    mCbEnableGSensor;
    private CheckBox    mCbAudioVolumeEvaluation;
    private CheckBox    mCbEnableCloudMixture;


    public interface IMoreListener {
        void onSwitchCamera(boolean bFrontCamera);
        void onFillModeChange(boolean bFillMode);
        void onVideoRotationChange(boolean bVertical);
        void onEnableAudioCapture(boolean bEnable);
        void onEnableAudioHandFree(boolean bEnable);
        void onMirrorLocalVideo(int mirrorType);
        void onMirrorRemoteVideo(boolean bMirror);
        void onEnableGSensor(boolean bEnable);
        void onEnableAudioVolumeEvaluation(boolean bEnable);
        void onEnableCloudMixture(boolean bEnable);
        void onClickButtonGetPlayUrl();
        void onClickButtonLinkMic();
        void onChangeRole(int role);
    }

    private WeakReference<IMoreListener> mMoreListener;

    public TRTCMoreDialog(Context context, IMoreListener listener) {
        super(context, R.style.room_more_dlg);
        mMoreListener = new WeakReference<>(listener);
        loadLocalCache(context);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.dlg_more);
        getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);

        initView();
    }

    private void initView() {
        mRbCameraFront           = (RadioButton)findViewById(R.id.camera_front);
        mRbCameraBack            = (RadioButton)findViewById(R.id.camera_back);
        mRbVideoFill             = (RadioButton)findViewById(R.id.mode_fill);
        mRbVideoAdjust           = (RadioButton)findViewById(R.id.mode_adjust);
        mRbVideoVertical         = (RadioButton)findViewById(R.id.mode_vertical);
        mRbVideoHorizontal       = (RadioButton)findViewById(R.id.mode_horizontal);
        mRbLocalVideoMirrorAuto  = (RadioButton)findViewById(R.id.mirror_auto);
        mRbLocalVideoMirrorDisable = (RadioButton)findViewById(R.id.mirror_disable);
        mRbRoleAnchor               = (RadioButton)findViewById(R.id.role_anchor);
        mRbRoleAudience             = (RadioButton)findViewById(R.id.role_audience);

        mCbEnableAudio           = (CheckBox)findViewById(R.id.enable_audio);
        mCbAudioHandFree         = (CheckBox)findViewById(R.id.audio_handfree);
        mCbVideoEncMirror        = (CheckBox)findViewById(R.id.video_enc_mirror);
        mCbEnableGSensor         = (CheckBox)findViewById(R.id.enable_gsensor);
        mCbAudioVolumeEvaluation = (CheckBox)findViewById(R.id.enable_audio_volume_evaluation);
        mCbEnableCloudMixture    = (CheckBox)findViewById(R.id.enable_cloud_mixture);

        mRbCameraFront.setChecked(mCameraFront);
        mRbCameraBack.setChecked(!mCameraFront);
        mRbVideoFill.setChecked(mVideoFillMode);
        mRbVideoAdjust.setChecked(!mVideoFillMode);
        mRbVideoVertical.setChecked(mVideoVertical);
        mRbVideoHorizontal.setChecked(!mVideoVertical);
        mRbLocalVideoMirrorAuto.setChecked(mLocalVideoViewMirror == TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO);
        mRbLocalVideoMirrorDisable.setChecked(mLocalVideoViewMirror == TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_DISABLE);
        mRbRoleAnchor.setChecked(mRole == TRTCCloudDef.TRTCRoleAnchor);
        mRbRoleAudience.setChecked(mRole == TRTCCloudDef.TRTCRoleAudience);

        mCbEnableAudio.setChecked(mEnableAudioCapture);
        mCbAudioHandFree.setChecked(mAudioHandFreeMode);
        mCbEnableGSensor.setChecked(mEnableGSensorMode);
        mCbAudioVolumeEvaluation.setChecked(mAudioVolumeEvaluation);
        mCbEnableCloudMixture.setChecked(mEnableCloudMixture);
        mCbVideoEncMirror.setChecked(mEnableVideoEncMirror);

        mRbCameraFront.setOnClickListener(this);
        mRbCameraBack.setOnClickListener(this);
        mRbVideoFill.setOnClickListener(this);
        mRbVideoAdjust.setOnClickListener(this);
        mRbVideoVertical.setOnClickListener(this);
        mRbVideoHorizontal.setOnClickListener(this);
        mRbLocalVideoMirrorAuto.setOnClickListener(this);
        mRbLocalVideoMirrorDisable.setOnClickListener(this);
        mRbRoleAnchor.setOnClickListener(this);
        mRbRoleAudience.setOnClickListener(this);

        mCbEnableAudio.setOnClickListener(this);
        mCbAudioHandFree.setOnClickListener(this);
        mCbVideoEncMirror.setOnClickListener(this);
        mCbVideoEncMirror.setOnClickListener(this);
        mCbEnableGSensor.setOnClickListener(this);
        mCbAudioVolumeEvaluation.setOnClickListener(this);
        mCbEnableCloudMixture.setOnClickListener(this);
        findViewById(R.id.btn_get_playurl).setOnClickListener(this);
        findViewById(R.id.btn_linkmic).setOnClickListener(this);
    }


    public boolean isCameraFront() {
        return mCameraFront;
    }

    public boolean isVideoFillMode() {
        return mVideoFillMode;
    }

    public boolean isVideoVertical() {
        return mVideoVertical;
    }

    public boolean isEnableAudioCapture() {
        return mEnableAudioCapture;
    }

    public boolean isAudioHandFreeMode() {
        return mAudioHandFreeMode;
    }

    public int getLocalVideoMirror() {
        return mLocalVideoViewMirror;
    }

    public boolean isRemoteVideoMirror() {
        return mEnableVideoEncMirror;
    }

    public boolean isEnableGSensorMode() {
        return mEnableGSensorMode;
    }

    public boolean isAudioVolumeEvaluation() {
        return mAudioVolumeEvaluation;
    }

    public boolean isEnableCloudMixture() {
        return mEnableCloudMixture;
    }

    public void setRole(int role) {
        mRole = role;
    }

    private void loadLocalCache(Context context) {
        try {
            SharedPreferences shareInfo = context.getSharedPreferences(KEY_MORE_SETTING_DATA, 0);

            mCameraFront            = shareInfo.getBoolean(KEY_CAMERA_FRONT,            mCameraFront);
            mVideoFillMode          = shareInfo.getBoolean(KEY_VIDEO_FILL_MODE,         mVideoFillMode);
            mVideoVertical          = shareInfo.getBoolean(KEY_VIDEO_VERTICAL,          mVideoVertical);
            mEnableAudioCapture     = shareInfo.getBoolean(KEY_ENABLE_AUDIO_CAPTURE,    mEnableAudioCapture);
            mAudioHandFreeMode      = shareInfo.getBoolean(KEY_AUDIO_HAND_FREE_MODE,    mAudioHandFreeMode);
            mLocalVideoViewMirror   = shareInfo.getInt(KEY_LOCAL_VIDEO_MIRROR,          mLocalVideoViewMirror);
            mEnableVideoEncMirror   = shareInfo.getBoolean(KEY_REMOTE_VIDEO_MIRROR,     mEnableVideoEncMirror);
            mEnableGSensorMode      = shareInfo.getBoolean(KEY_ENABLE_GSENSOR_MODE,     mEnableGSensorMode);
            mAudioVolumeEvaluation  = shareInfo.getBoolean(KEY_AUDIO_VOLUME_EVALUATION, mAudioVolumeEvaluation);
            mEnableCloudMixture     = shareInfo.getBoolean(KEY_ENABLE_CLOUD_MIXTURE,    mEnableCloudMixture);

        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void saveData(Context context) {
        try {
            SharedPreferences shareInfo = context.getSharedPreferences(KEY_MORE_SETTING_DATA, 0);
            SharedPreferences.Editor editor = shareInfo.edit();
            editor.putBoolean(KEY_CAMERA_FRONT,            mCameraFront);
            editor.putBoolean(KEY_VIDEO_FILL_MODE,         mVideoFillMode);
            editor.putBoolean(KEY_VIDEO_VERTICAL,          mVideoVertical);
            editor.putBoolean(KEY_ENABLE_AUDIO_CAPTURE,    mEnableAudioCapture);
            editor.putBoolean(KEY_AUDIO_HAND_FREE_MODE,    mAudioHandFreeMode);
            editor.putInt(KEY_LOCAL_VIDEO_MIRROR,          mLocalVideoViewMirror);
            editor.putBoolean(KEY_REMOTE_VIDEO_MIRROR,     mEnableVideoEncMirror);
            editor.putBoolean(KEY_ENABLE_GSENSOR_MODE,     mEnableGSensorMode);
            editor.putBoolean(KEY_AUDIO_VOLUME_EVALUATION, mAudioVolumeEvaluation);
            editor.putBoolean(KEY_ENABLE_CLOUD_MIXTURE,    mEnableCloudMixture);

            editor.commit();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onClick(View v) {
        IMoreListener listener = mMoreListener.get();

        int id = v.getId();
        switch (id) {
            case R.id.camera_front:
            case R.id.camera_back:
            {
                boolean cameraFront = (id == R.id.camera_front);
                if (cameraFront != mCameraFront) {
                    mCameraFront = cameraFront;
                    if (listener != null) {
                        listener.onSwitchCamera(mCameraFront);
                    }
                }
                break;
            }
            case R.id.mode_fill:
            case R.id.mode_adjust:
            {
                boolean videoFillMode = (id == R.id.mode_fill);
                if (videoFillMode != mVideoFillMode) {
                    mVideoFillMode = videoFillMode;
                    if (listener != null) {
                        listener.onFillModeChange(mVideoFillMode);
                    }
                }
                break;
            }
            case R.id.mode_vertical:
            case R.id.mode_horizontal:
            {
                boolean videoVertical = (id == R.id.mode_vertical);
                if (videoVertical != mVideoVertical) {
                    mVideoVertical = videoVertical;
                    if (listener != null) {
                        listener.onVideoRotationChange(mVideoVertical);
                    }
                }
                break;
            }
            case R.id.enable_audio:
            {
                boolean enableAudioCapture = mCbEnableAudio.isChecked();
                if (enableAudioCapture != mEnableAudioCapture) {
                    mEnableAudioCapture = enableAudioCapture;
                    if (listener != null) {
                        listener.onEnableAudioCapture(mEnableAudioCapture);
                    }
                }
                break;
            }
            case R.id.audio_handfree:
            {
                boolean audioHandFreeMode = mCbAudioHandFree.isChecked();
                if (audioHandFreeMode != mAudioHandFreeMode) {
                    mAudioHandFreeMode = audioHandFreeMode;
                    if (listener != null) {
                        listener.onEnableAudioHandFree(mAudioHandFreeMode);
                    }
                }
                break;
            }
            case R.id.mirror_auto:
            case R.id.mirror_disable:
            {
                int mirrorType = TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO;
                if (id == R.id.mirror_auto) {
                    mirrorType = TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO;
                } else if (id == R.id.mirror_disable) {
                    mirrorType = TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_DISABLE;
                }
                if (mirrorType != mLocalVideoViewMirror) {
                    mLocalVideoViewMirror = mirrorType;
                    if (listener != null) {
                        listener.onMirrorLocalVideo(mLocalVideoViewMirror);
                    }
                }
                break;
            }
            case R.id.video_enc_mirror:
            {
                boolean remoteVideoMirror = mCbVideoEncMirror.isChecked();
                if (remoteVideoMirror != mEnableVideoEncMirror) {
                    mEnableVideoEncMirror = remoteVideoMirror;
                    if (listener != null) {
                        listener.onMirrorRemoteVideo(mEnableVideoEncMirror);
                    }
                }
                break;
            }
            case R.id.enable_gsensor:
            {
                boolean enableGSensorMode = mCbEnableGSensor.isChecked();
                if (enableGSensorMode != mEnableGSensorMode) {
                    mEnableGSensorMode = enableGSensorMode;
                    if (listener != null) {
                        listener.onEnableGSensor(mEnableGSensorMode);
                    }
                }
                break;
            }
            case R.id.enable_audio_volume_evaluation:
            {
                boolean audioVolumeEvaluation = mCbAudioVolumeEvaluation.isChecked();
                if (audioVolumeEvaluation != mAudioVolumeEvaluation) {
                    mAudioVolumeEvaluation = audioVolumeEvaluation;
                    if (listener != null) {
                        listener.onEnableAudioVolumeEvaluation(mAudioVolumeEvaluation);
                    }
                }
                break;
            }
            case R.id.enable_cloud_mixture:
            {
                boolean enableCloudMixture = mCbEnableCloudMixture.isChecked();
                if (enableCloudMixture != mEnableCloudMixture) {
                    mEnableCloudMixture = enableCloudMixture;
                    if (listener != null) {
                        listener.onEnableCloudMixture(mEnableCloudMixture);
                    }
                }
                break;
            }
            case R.id.btn_get_playurl:
            {
                if (listener != null) {
                    listener.onClickButtonGetPlayUrl();
                }
                break;
            }
            case R.id.btn_linkmic:
            {
                if (listener != null) {
                    listener.onClickButtonLinkMic();
                }
                dismiss();
                break;
            }
            case R.id.role_anchor:
            {
                if(listener != null) {
                    listener.onChangeRole(TRTCCloudDef.TRTCRoleAnchor);
                }
                mRole = TRTCCloudDef.TRTCRoleAnchor;
                break;
            }
            case R.id.role_audience:
            {
                if(listener != null) {
                    listener.onChangeRole(TRTCCloudDef.TRTCRoleAudience);
                }
                mRole = TRTCCloudDef.TRTCRoleAudience;
                break;
            }
        }

        saveData(getContext());
    }

    public void show(boolean beingLinkMic, int appScene) {
        show();
        updateLinkMicState(beingLinkMic);
        updateAppScene(appScene);
    }

    public void updateLinkMicState(boolean beingLinkMic) {
        TextView textView = (TextView)findViewById(R.id.text_linkmic);
        if (textView != null) {
            textView.setText(beingLinkMic ? "结束跨房连麦" : "开始跨房连麦");
        }

        Button button = (Button)findViewById(R.id.btn_linkmic);
        if (button != null) {
            button.setText(beingLinkMic ? "结束" : "开始");
        }
    }

    public void updateVideoFillMode(boolean bFillMode) {
        if (mRbVideoFill != null) {
            mRbVideoFill.setChecked(bFillMode);
        }
        if (mRbVideoAdjust != null) {
            mRbVideoAdjust.setChecked(!bFillMode);
        }

        mVideoFillMode = bFillMode;

        saveData(getContext());
    }

    private void updateAppScene(int appScene) {
        View layout = findViewById(R.id.role_layout);
        if (appScene == TRTCCloudDef.TRTC_APP_SCENE_LIVE) {
            if (layout != null) layout.setVisibility(View.VISIBLE);
        } else {
            if (layout != null) layout.setVisibility(View.GONE);
        }
    }
}
