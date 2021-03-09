package com.tencent.liteav.trtcchatsalon.model;

import java.util.List;

public class TRTCChatSalonCallback {
    /**
     * 通用回调
     */
    public interface ActionCallback {
        void onCallback(int code, String msg);
    }

    /**
     * 获取房间信息回调
     */
    public interface RoomInfoCallback {
        void onCallback(int code, String msg, List<TRTCChatSalonDef.RoomInfo> list);
    }

    /**
     * 获取成员信息回调
     */
    public interface UserListCallback {
        void onCallback(int code, String msg, List<TRTCChatSalonDef.UserInfo> list);
    }
}
