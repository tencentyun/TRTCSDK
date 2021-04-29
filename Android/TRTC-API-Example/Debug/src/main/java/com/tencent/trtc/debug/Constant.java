package com.tencent.trtc.debug;

public class Constant {

    public static final String ROOM_ID = "room_id";
    public static final String USER_ID = "user_id";
    public static final String ROLE_TYPE = "role_type";
    public static final String CUSTOM_VIDEO = "custom_video";

    // 美颜风格.三种美颜风格：0 ：光滑  1：自然  2：朦胧
    public static final int     BEAUTY_STYLE_SMOOTH              = 0;
    public static final int     BEAUTY_STYLE_NATURE              = 1;

    public static final int     VIDEO_FPS                        = 15;
    // RTC 通话场景：640*360，15fps，550kbps
    public static final int     RTC_VIDEO_BITRATE                = 550;

    // 直播场景：连麦小主播：270*480, 15pfs, 400kbps
    public static final int LIVE_270_480_VIDEO_BITRATE           = 400;
    public static final int     LIVE_360_640_VIDEO_BITRATE       = 800;
    // 直播场景：大主播：默认 540*960, 15fps，1200kbps
    public static final int     LIVE_540_960_VIDEO_BITRATE       = 900;
    public static final int     LIVE_720_1280_VIDEO_BITRATE      = 1500;

}
