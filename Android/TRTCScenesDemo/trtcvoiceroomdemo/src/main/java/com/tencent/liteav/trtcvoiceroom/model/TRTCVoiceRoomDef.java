package com.tencent.liteav.trtcvoiceroom.model;

import java.util.List;

public class TRTCVoiceRoomDef {
    public static class SeatInfo {
        public static final transient int STATUS_UNUSED = 0;
        public static final transient int STATUS_USED   = 1;
        public static final transient int STATUS_CLOSE  = 2;

        /// 【字段含义】座位状态 0(unused)/1(used)/2(close)
        public int     status;
        /// 【字段含义】座位是否禁言
        public boolean mute;
        /// 【字段含义】座位状态为1，存储userInfo
        public String  userId;

        @Override
        public String toString() {
            return "TXSeatInfo{" +
                    "status=" + status +
                    ", mute=" + mute +
                    ", userId=" + userId +
                    '}';
        }
    }


    public static class RoomParam {
        /// 【字段含义】房间名称
        public String         roomName;
        /// 【字段含义】房间封面图
        public String         coverUrl;
        /// 【字段含义】是否需要房主确认上麦
        public boolean        needRequest;
        /// 【字段含义】座位数
        public int            seatCount;
        /// 【字段含义】初始化的座位表，可以为null
        public List<SeatInfo> seatInfoList;

        @Override
        public String toString() {
            return "RoomParam{" +
                    "roomName='" + roomName + '\'' +
                    ", coverUrl='" + coverUrl + '\'' +
                    ", needRequest=" + needRequest +
                    ", seatInfoList=" + seatInfoList +
                    '}';
        }
    }

    public static class UserInfo {
        /// 【字段含义】用户唯一标识
        public String userId;
        /// 【字段含义】用户昵称
        public String userName;
        /// 【字段含义】用户头像
        public String userAvatar;

        @Override
        public String toString() {
            return "UserInfo{" +
                    "userId='" + userId + '\'' +
                    ", userName='" + userName + '\'' +
                    ", userAvatar='" + userAvatar + '\'' +
                    '}';
        }
    }

    public static class RoomInfo {
        /// 【字段含义】房间唯一标识
        public int     roomId;
        /// 【字段含义】房间名称
        public String  roomName;
        /// 【字段含义】房间封面图
        public String  coverUrl;
        /// 【字段含义】房主id
        public String  ownerId;
        /// 【字段含义】房主昵称
        public String  ownerName;
        /// 【字段含义】房间人数
        public int     memberCount;
        /// 【字段含义】是否需要房主确认上麦
        public boolean needRequest;

        @Override
        public String toString() {
            return "TXRoomInfo{" +
                    "roomId=" + roomId +
                    ", roomName='" + roomName + '\'' +
                    ", coverUrl='" + coverUrl + '\'' +
                    ", ownerId='" + ownerId + '\'' +
                    ", ownerName='" + ownerName + '\'' +
                    ", memberCount=" + memberCount +
                    '}';
        }
    }
}
