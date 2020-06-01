package com.tencent.liteav.meeting.model;

import java.util.List;

public class TRTCMeetingCallback {
    public interface ActionCallback {
        void onCallback(int code, String msg);
    }

    /**
     * 获取成员信息回调
     */
    public interface UserListCallback {
        void onCallback(int code, String msg, List<TRTCMeetingDef.UserInfo> list);
    }
}
