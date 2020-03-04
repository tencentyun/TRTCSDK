package com.tencent.liteav.demo.trtc.sdkadapter.beauty;

import android.graphics.Bitmap;

import com.tencent.liteav.demo.beauty.IBeautyKit;
import com.tencent.trtc.TRTCCloud;

public class TRTCBeautyKit implements IBeautyKit {

    private TRTCCloud mTRTCCloud;

    public TRTCBeautyKit(TRTCCloud cloud) {
        mTRTCCloud = cloud;
    }

    @Override
    public void setFilter(Bitmap filterImage, int index) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setFilter(filterImage);
        }
    }

    @Override
    public void setSpecialRatio(float specialRatio) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setFilterConcentration(specialRatio / 10.0f);
        }
    }

    @Override
    public void setGreenScreenFile(String path, boolean isLoop) {
        if (mTRTCCloud != null) {
            mTRTCCloud.setGreenScreenFile(path);
        }
    }

    @Override
    public void setBeautyStyle(int beautyStyle) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setBeautyStyle(beautyStyle);
        }
    }

    @Override
    public void setBeautyLevel(int beautyLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setBeautyLevel(beautyLevel);
        }
    }

    @Override
    public void setWhitenessLevel(int whitenessLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setWhitenessLevel(whitenessLevel);
        }
    }

    @Override
    public void setRuddyLevel(int ruddyLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setRuddyLevel(ruddyLevel);
        }
    }

    @Override
    public void setEyeScaleLevel(int eyeScaleLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setEyeScaleLevel(eyeScaleLevel);
        }
    }

    @Override
    public void setFaceSlimLevel(int faceSlimLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setFaceSlimLevel(faceSlimLevel);
        }
    }

    @Override
    public void setFaceVLevel(int faceVLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setFaceVLevel(faceVLevel);
        }
    }

    @Override
    public void setChinLevel(int chinLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setChinLevel(chinLevel);
        }
    }

    @Override
    public void setFaceShortLevel(int faceShortLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setFaceShortLevel(faceShortLevel);
        }
    }

    @Override
    public void setNoseSlimLevel(int noseSlimLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setNoseSlimLevel(noseSlimLevel);
        }
    }

    @Override
    public void setEyeLightenLevel(int eyeLightenLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setEyeLightenLevel(eyeLightenLevel);
        }
    }

    @Override
    public void setToothWhitenLevel(int toothWhitenLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setToothWhitenLevel(toothWhitenLevel);
        }
    }

    @Override
    public void setWrinkleRemoveLevel(int wrinkleRemoveLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setWrinkleRemoveLevel(wrinkleRemoveLevel);
        }
    }

    @Override
    public void setPounchRemoveLevel(int pounchRemoveLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setPounchRemoveLevel(pounchRemoveLevel);
        }
    }

    @Override
    public void setSmileLinesRemoveLevel(int smileLinesRemoveLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setSmileLinesRemoveLevel(smileLinesRemoveLevel);
        }
    }

    @Override
    public void setForeheadLevel(int foreheadLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setForeheadLevel(foreheadLevel);
        }
    }

    @Override
    public void setEyeDistanceLevel(int eyeDistanceLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setEyeDistanceLevel(eyeDistanceLevel);
        }
    }

    @Override
    public void setEyeAngleLevel(int eyeAngleLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setEyeAngleLevel(eyeAngleLevel);
        }
    }

    @Override
    public void setMouthShapeLevel(int mouthShapeLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setMouthShapeLevel(mouthShapeLevel);
        }
    }

    @Override
    public void setNoseWingLevel(int noseWingLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setNoseWingLevel(noseWingLevel);
        }
    }

    @Override
    public void setNosePositionLevel(int nosePositionLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setNosePositionLevel(nosePositionLevel);
        }
    }

    @Override
    public void setLipsThicknessLevel(int lipsThicknessLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setLipsThicknessLevel(lipsThicknessLevel);
        }
    }

    @Override
    public void setFaceBeautyLevel(int faceBeautyLevel) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setFaceBeautyLevel(faceBeautyLevel);
        }
    }

    @Override
    public void setMotionTmpl(String tmplPath) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setMotionTmpl(tmplPath);
        }
    }

    @Override
    public void setMotionMute(boolean motionMute) {
        if (mTRTCCloud != null) {
            mTRTCCloud.getBeautyManager().setMotionMute(motionMute);
        }
    }
}
