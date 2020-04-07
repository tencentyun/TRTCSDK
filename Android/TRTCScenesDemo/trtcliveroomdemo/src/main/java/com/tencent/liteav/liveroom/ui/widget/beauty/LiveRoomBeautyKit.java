package com.tencent.liteav.liveroom.ui.widget.beauty;

import android.graphics.Bitmap;

import com.tencent.liteav.demo.beauty.IBeautyKit;
import com.tencent.liteav.liveroom.model.TRTCLiveRoom;

public class LiveRoomBeautyKit implements IBeautyKit {

    private TRTCLiveRoom mLiveRoom;

    public LiveRoomBeautyKit(TRTCLiveRoom liveRoom) {
        mLiveRoom = liveRoom;
    }


    @Override
    public void setFilter(Bitmap filterImage, int index) {
        if (mLiveRoom != null)
            mLiveRoom.setFilter(filterImage);
    }

    @Override
    public void setSpecialRatio(float specialRatio) {
        if (mLiveRoom != null)
            mLiveRoom.setFilterConcentration(specialRatio / 10.0f);
    }

    @Override
    public void setGreenScreenFile(String path, boolean isLoop) {
        if (mLiveRoom != null)
            mLiveRoom.setGreenScreenFile(path);
    }

    @Override
    public void setBeautyStyle(int beautyStyle) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setBeautyStyle(beautyStyle);
    }

    @Override
    public void setBeautyLevel(int beautyLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setBeautyLevel(beautyLevel);
    }

    @Override
    public void setWhitenessLevel(int whitenessLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setWhitenessLevel(whitenessLevel);
    }

    @Override
    public void setRuddyLevel(int ruddyLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setRuddyLevel(ruddyLevel);
    }

    @Override
    public void setEyeScaleLevel(int eyeScaleLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setEyeScaleLevel(eyeScaleLevel);
    }

    @Override
    public void setFaceSlimLevel(int faceSlimLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setFaceSlimLevel(faceSlimLevel);
    }

    @Override
    public void setFaceVLevel(int faceVLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setFaceVLevel(faceVLevel);
    }

    @Override
    public void setChinLevel(int chinLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setChinLevel(chinLevel);
    }

    @Override
    public void setFaceShortLevel(int faceShortLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setFaceShortLevel(faceShortLevel);
    }

    @Override
    public void setNoseSlimLevel(int noseSlimLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setNoseSlimLevel(noseSlimLevel);
    }

    @Override
    public void setEyeLightenLevel(int eyeLightenLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setEyeLightenLevel(eyeLightenLevel);
    }

    @Override
    public void setToothWhitenLevel(int toothWhitenLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setToothWhitenLevel(toothWhitenLevel);
    }

    @Override
    public void setWrinkleRemoveLevel(int wrinkleRemoveLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setWrinkleRemoveLevel(wrinkleRemoveLevel);
    }

    @Override
    public void setPounchRemoveLevel(int pounchRemoveLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setPounchRemoveLevel(pounchRemoveLevel);
    }

    @Override
    public void setSmileLinesRemoveLevel(int smileLinesRemoveLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setSmileLinesRemoveLevel(smileLinesRemoveLevel);
    }

    @Override
    public void setForeheadLevel(int foreheadLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setForeheadLevel(foreheadLevel);
    }

    @Override
    public void setEyeDistanceLevel(int eyeDistanceLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setEyeDistanceLevel(eyeDistanceLevel);
    }

    @Override
    public void setEyeAngleLevel(int eyeAngleLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setEyeAngleLevel(eyeAngleLevel);
    }

    @Override
    public void setMouthShapeLevel(int mouthShapeLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setMouthShapeLevel(mouthShapeLevel);
    }

    @Override
    public void setNoseWingLevel(int noseWingLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setNoseWingLevel(noseWingLevel);
    }

    @Override
    public void setNosePositionLevel(int nosePositionLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setNosePositionLevel(nosePositionLevel);
    }

    @Override
    public void setLipsThicknessLevel(int lipsThicknessLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setLipsThicknessLevel(lipsThicknessLevel);
    }

    @Override
    public void setFaceBeautyLevel(int faceBeautyLevel) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setFaceBeautyLevel(faceBeautyLevel);
    }

    @Override
    public void setMotionTmpl(String tmplPath) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setMotionTmpl(tmplPath);
    }

    @Override
    public void setMotionMute(boolean motionMute) {
        if (mLiveRoom != null)
            mLiveRoom.getBeautyManager().setMotionMute(motionMute);
    }
}
