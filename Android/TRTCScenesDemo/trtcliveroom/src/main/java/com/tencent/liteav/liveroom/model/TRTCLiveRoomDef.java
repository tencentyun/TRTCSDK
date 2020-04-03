package com.tencent.liteav.liveroom.model;

public class TRTCLiveRoomDef {
    // 房间的状态
    public static final int ROOM_STATUS_NONE     = 0;
    public static final int ROOM_STATUS_SINGLE   = 1; //单人房间
    public static final int ROOM_STATUS_LINK_MIC = 2; //连麦
    public static final int ROOM_STATUS_PK       = 3; //PK

    public static final class TRTCLiveRoomConfig {
        /// 【字段含义】观众端使用CDN播放
        /// 【特殊说明】true: 默认进房使用CDN播放 false: 使用低延时播放
        public boolean useCDNFirst;
        /// 【字段含义】CDN播放的域名地址
        public String  cdnPlayDomain;

        public TRTCLiveRoomConfig(boolean useCDNFirst, String cdnPlayDomain) {
            this.useCDNFirst = useCDNFirst;
            this.cdnPlayDomain = cdnPlayDomain;
        }

        @Override
        public String toString() {
            return "TRTCLiveRoomConfig{" +
                    "useCDNFirst=" + useCDNFirst +
                    ", cdnPlayDomain='" + cdnPlayDomain + '\'' +
                    '}';
        }
    }

    public static final class TRTCLiveUserInfo {
        /// 【字段含义】用户唯一标识
        public String userId;
        /// 【字段含义】用户昵称
        public String userName;
        /// 【字段含义】用户头像
        public String userAvatar;

        @Override
        public String toString() {
            return "TRTCLiveUserInfo{" +
                    "userId='" + userId + '\'' +
                    ", userName='" + userName + '\'' +
                    ", userAvatar='" + userAvatar + '\'' +
                    '}';
        }
    }

    public static final class TRTCCreateRoomParam {
        /// 【字段含义】房间名称
        public String roomName;
        /// 【字段含义】房间封面图
        public String coverUrl;

        @Override
        public String toString() {
            return "TRTCCreateRoomParam{" +
                    "roomName='" + roomName + '\'' +
                    ", coverUrl='" + coverUrl + '\'' +
                    '}';
        }
    }

    public static final class TRTCLiveRoomInfo {
        /// 【字段含义】房间唯一标识
        public int    roomId;
        /// 【字段含义】房间名称
        public String roomName;
        /// 【字段含义】房间封面图
        public String coverUrl;
        /// 【字段含义】房主id
        public String ownerId;
        /// 【字段含义】房主昵称
        public String ownerName;
        /// 【字段含义】cdn模式下的播放流地址
        public String streamUrl;
        /// 【字段含义】房间的状态: 单人/连麦/PK
        public int    roomStatus;
        /// 【字段含义】房间人数
        public int    memberCount;

        @Override
        public String toString() {
            return "TRTCLiveRoomInfo{" +
                    "roomId=" + roomId +
                    ", roomName='" + roomName + '\'' +
                    ", coverUrl='" + coverUrl + '\'' +
                    ", ownerId='" + ownerId + '\'' +
                    ", ownerName='" + ownerName + '\'' +
                    ", streamUrl='" + streamUrl + '\'' +
                    ", memberCount=" + memberCount +
                    '}';
        }
    }
}