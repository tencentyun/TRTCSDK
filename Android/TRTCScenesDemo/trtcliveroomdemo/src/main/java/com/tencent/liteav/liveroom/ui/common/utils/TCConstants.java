package com.tencent.liteav.liveroom.ui.common.utils;


/**
 * Module:   TCConstants
 * <p>
 * Function: 定义常量的类
 */
public class TCConstants {
    /**
     * 用于请求该分类下的列表
     */
    public static final String TYPE_LIVE_ROOM = "liveRoom";

    /**
     * 直播端右下角listview显示type
     */
    public static final int TEXT_TYPE    = 0;
    public static final int MEMBER_ENTER = 1;
    public static final int MEMBER_EXIT  = 2;
    public static final int PRAISE       = 3;

    public static final String ROOM_TITLE      = "room_title";
    public static final String COVER_PIC       = "cover_pic";
    public static final String GROUP_ID        = "group_id";
    public static final String PLAY_URL        = "play_url";
    public static final String PLAY_TYPE       = "play_type";
    public static final String PUSHER_AVATAR   = "pusher_avatar";
    public static final String PUSHER_ID       = "pusher_id";
    public static final String PUSHER_NAME     = "pusher_name";
    public static final String MEMBER_COUNT    = "member_count";
    public static final String HEART_COUNT     = "heart_count";
    public static final String FILE_ID         = "file_id";
    public static final String TIMESTAMP       = "timestamp";
    public static final String ACTIVITY_RESULT = "activity_result";
    public static final String USE_CDN_PLAY    = "use_cdn_play";

    /**
     * IM 互动消息类型
     */
    public static final int IMCMD_PRAISE = 4;   // 点赞消息
    public static final int IMCMD_DANMU  = 5;   // 弹幕消息

    /**
     * 腾讯云视频互动直播文档URL
     */
    public static final String TRTC_LIVE_ROOM_DOCUMENT_URL = "https://cloud.tencent.com/document/product/647/35428";

}

