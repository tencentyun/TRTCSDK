package com.tencent.liteav.demo.beauty;

import android.annotation.TargetApi;
import android.graphics.Bitmap;

public interface IBeautyKit {
    /**
     * 设置指定素材滤镜特效
     *
     * @param filterImage : 指定素材，即颜色查找表图片。注意：一定要用png格式！！！
     *                    demo用到的滤镜查找表图片位于RTMPAndroidDemo/app/src/main/res/drawable-xxhdpi/目录下。
     */
    void setFilter(Bitmap filterImage, int index);

    /**
     * 设置滤镜效果程度
     *
     * @param strength : 从0到1，越大滤镜效果越明显，默认取值0.5
     */
    void setFilterStrength(float strength);

    /**
     * 设置绿幕文件（企业版有效，其它版本设置此参数无效）[API >= 18]
     * <p>
     * 此处的绿幕功能并非智能抠背，它需要被拍摄者的背后有一块绿色的幕布来辅助产生特效。
     *
     * @param path 视频文件路径。支持 MP4；null 表示关闭特效。
     */
    @TargetApi(18)
    void setGreenScreenFile(String path);

    /**
     * 设置美颜类型
     *
     * @param beautyStyle 美颜风格.三种美颜风格：0 ：光滑  1：自然  2：朦胧
     */
    void setBeautyStyle(int beautyStyle);

    /**
     * 设置美颜级别
     *
     * @param beautyLevel 美颜级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setBeautyLevel(int beautyLevel);

    /**
     * 设置美白级别
     *
     * @param whitenessLevel 美白级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setWhitenessLevel(int whitenessLevel);

    /**
     * 设置红润级别
     *
     * @param ruddyLevel 红润级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setRuddyLevel(int ruddyLevel);

    /**
     * 设置大眼级别（企业版有效，其它版本设置此参数无效）
     *
     * @param eyeScaleLevel 大眼级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setEyeScaleLevel(int eyeScaleLevel);

    /**
     * 设置瘦脸级别（企业版有效，其它版本设置此参数无效）
     *
     * @param faceSlimLevel 瘦脸级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setFaceSlimLevel(int faceSlimLevel);

    /**
     * 设置V脸级别（企业版有效，其它版本设置此参数无效）
     *
     * @param faceVLevel V脸级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setFaceVLevel(int faceVLevel);

    /**
     * 设置下巴拉伸或收缩（企业版有效，其它版本设置此参数无效）
     *
     * @param chinLevel 下巴拉伸或收缩级别，取值范围 -9 - 9；0 表示关闭，小于0表示收缩，大于0表示拉伸。
     */
    void setChinLevel(int chinLevel);

    /**
     * 设置短脸级别（企业版有效，其它版本设置此参数无效）
     *
     * @param faceShortLevel 短脸级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setFaceShortLevel(int faceShortLevel);

    /**
     * 设置瘦鼻级别（企业版有效，其它版本设置此参数无效）
     *
     * @param noseSlimLevel 瘦鼻级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setNoseSlimLevel(int noseSlimLevel);

    /**
     * 设置亮眼 （企业版有效，其它版本设置此参数无效）
     *
     * @param eyeLightenLevel 亮眼级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setEyeLightenLevel(int eyeLightenLevel);

    /**
     * 设置白牙 （企业版有效，其它版本设置此参数无效）
     *
     * @param toothWhitenLevel 白牙级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setToothWhitenLevel(int toothWhitenLevel);

    /**
     * 设置祛皱 （企业版有效，其它版本设置此参数无效）
     *
     * @param wrinkleRemoveLevel 祛皱级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setWrinkleRemoveLevel(int wrinkleRemoveLevel);

    /**
     * 设置祛眼袋 （企业版有效，其它版本设置此参数无效）
     *
     * @param pounchRemoveLevel 祛眼袋级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setPounchRemoveLevel(int pounchRemoveLevel);

    /**
     * 设置祛法令纹 （企业版有效，其它版本设置此参数无效）
     *
     * @param smileLinesRemoveLevel 祛法令纹级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setSmileLinesRemoveLevel(int smileLinesRemoveLevel);

    /**
     * 设置发际线 （企业版有效，其它版本设置此参数无效）
     *
     * @param foreheadLevel 发际线级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setForeheadLevel(int foreheadLevel);

    /**
     * 设置眼距 （企业版有效，其它版本设置此参数无效）
     *
     * @param eyeDistanceLevel 眼距级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setEyeDistanceLevel(int eyeDistanceLevel);

    /**
     * 设置眼角 （企业版有效，其它版本设置此参数无效）
     *
     * @param eyeAngleLevel 眼角级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setEyeAngleLevel(int eyeAngleLevel);

    /**
     * 设置嘴型 （企业版有效，其它版本设置此参数无效）
     *
     * @param mouthShapeLevel 嘴型级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setMouthShapeLevel(int mouthShapeLevel);

    /**
     * 设置鼻翼 （企业版有效，其它版本设置此参数无效）
     *
     * @param noseWingLevel 鼻翼级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setNoseWingLevel(int noseWingLevel);

    /**
     * 设置鼻子位置 （企业版有效，其它版本设置此参数无效）
     *
     * @param nosePositionLevel 鼻子位置级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setNosePositionLevel(int nosePositionLevel);

    /**
     * 设置嘴唇厚度 （企业版有效，其它版本设置此参数无效）
     *
     * @param lipsThicknessLevel 嘴唇厚度级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setLipsThicknessLevel(int lipsThicknessLevel);

    /**
     * 设置脸型 （企业版有效，其它版本设置此参数无效）
     *
     * @param faceBeautyLevel 脸型级别，取值范围0 - 9； 0表示关闭，1 - 9值越大，效果越明显。
     */
    void setFaceBeautyLevel(int faceBeautyLevel);

    /**
     * 选择使用哪一款 AI 动效挂件（企业版有效，其它版本设置此参数无效）
     */
    void setMotionTmpl(String tmplPath);

    /**
     * 设置动效静音（企业版有效，其它版本设置此参数无效）
     * <p>
     * 有些挂件本身会有声音特效，通过此 API 可以关闭这些特效播放时所带的声音效果。
     *
     * @param motionMute YES：静音；NO：不静音。
     */
    void setMotionMute(boolean motionMute);
}
