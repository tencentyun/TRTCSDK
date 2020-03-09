package com.tencent.liteav.demo;

public class TRTCItemEntity {
    public String mTitle;
    public String mContent;
    public int    mIconId;
    public Class  mTargetClass;
    public int    mType;

    public TRTCItemEntity(String title, String content, int iconId, int type, Class targetClass) {
        mTitle = title;
        mContent = content;
        mIconId = iconId;
        mTargetClass = targetClass;
        mType = type;
    }
}
