package com.tencent.liteav.meeting.ui;

import android.graphics.Bitmap;

import com.tencent.liteav.demo.beauty.IBeautyKit;
import com.tencent.liteav.meeting.model.TRTCMeeting;

public class MeetingRoomBeautyKit implements IBeautyKit {

    private TRTCMeeting mTRTCMeeting;

    public MeetingRoomBeautyKit(TRTCMeeting TRTCMeeting) {
        mTRTCMeeting = TRTCMeeting;
    }

    @Override
    public void setFilter(Bitmap filterImage, int index) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setFilter(filterImage);
        }
    }

    @Override
    public void setFilterStrength(float strength) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setFilterStrength(strength / 10.0f);
        }
    }

    @Override
    public void setGreenScreenFile(String path) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setGreenScreenFile(path);
        }
    }

    @Override
    public void setBeautyStyle(int beautyStyle) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setBeautyStyle(beautyStyle);
        }
    }

    @Override
    public void setBeautyLevel(int beautyLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setBeautyLevel(beautyLevel);
        }
    }

    @Override
    public void setWhitenessLevel(int whitenessLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setWhitenessLevel(whitenessLevel);
        }
    }

    @Override
    public void setRuddyLevel(int ruddyLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setRuddyLevel(ruddyLevel);
        }
    }

    @Override
    public void setEyeScaleLevel(int eyeScaleLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setEyeScaleLevel(eyeScaleLevel);
        }
    }

    @Override
    public void setFaceSlimLevel(int faceSlimLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setFaceSlimLevel(faceSlimLevel);
        }
    }

    @Override
    public void setFaceVLevel(int faceVLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setFaceVLevel(faceVLevel);
        }
    }

    @Override
    public void setChinLevel(int chinLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setChinLevel(chinLevel);
        }
    }

    @Override
    public void setFaceShortLevel(int faceShortLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setFaceShortLevel(faceShortLevel);
        }
    }

    @Override
    public void setNoseSlimLevel(int noseSlimLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setNoseSlimLevel(noseSlimLevel);
        }
    }

    @Override
    public void setEyeLightenLevel(int eyeLightenLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setEyeLightenLevel(eyeLightenLevel);
        }
    }

    @Override
    public void setToothWhitenLevel(int toothWhitenLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setToothWhitenLevel(toothWhitenLevel);
        }
    }

    @Override
    public void setWrinkleRemoveLevel(int wrinkleRemoveLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setWrinkleRemoveLevel(wrinkleRemoveLevel);
        }
    }

    @Override
    public void setPounchRemoveLevel(int pounchRemoveLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setPounchRemoveLevel(pounchRemoveLevel);
        }
    }

    @Override
    public void setSmileLinesRemoveLevel(int smileLinesRemoveLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setSmileLinesRemoveLevel(smileLinesRemoveLevel);
        }
    }

    @Override
    public void setForeheadLevel(int foreheadLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setForeheadLevel(foreheadLevel);
        }
    }

    @Override
    public void setEyeDistanceLevel(int eyeDistanceLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setEyeDistanceLevel(eyeDistanceLevel);
        }
    }

    @Override
    public void setEyeAngleLevel(int eyeAngleLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setEyeAngleLevel(eyeAngleLevel);
        }
    }

    @Override
    public void setMouthShapeLevel(int mouthShapeLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setMouthShapeLevel(mouthShapeLevel);
        }
    }

    @Override
    public void setNoseWingLevel(int noseWingLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setNoseWingLevel(noseWingLevel);
        }
    }

    @Override
    public void setNosePositionLevel(int nosePositionLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setNosePositionLevel(nosePositionLevel);
        }
    }

    @Override
    public void setLipsThicknessLevel(int lipsThicknessLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setLipsThicknessLevel(lipsThicknessLevel);
        }
    }

    @Override
    public void setFaceBeautyLevel(int faceBeautyLevel) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setFaceBeautyLevel(faceBeautyLevel);
        }
    }

    @Override
    public void setMotionTmpl(String tmplPath) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setMotionTmpl(tmplPath);
        }
    }

    @Override
    public void setMotionMute(boolean motionMute) {
        if (mTRTCMeeting != null) {
            mTRTCMeeting.getBeautyManager().setMotionMute(motionMute);
        }
    }
}
