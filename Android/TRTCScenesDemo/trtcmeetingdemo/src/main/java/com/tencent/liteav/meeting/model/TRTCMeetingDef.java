package com.tencent.liteav.meeting.model;

public class TRTCMeetingDef {
    public static class UserInfo {
        public String  userId;
        public String  userName;
        public String  userAvatar;
        // 用户是否打开了视频
        public boolean isVideoAvailable;
        // 用户是否打开音频
        public boolean isAudioAvailable;
        // 是否对用户静画
        public boolean isMuteVideo;
        // 是否对用户静音
        public boolean isMuteAudio;

        public UserInfo() {
            userId = "";
            isVideoAvailable = false;
            isAudioAvailable = false;
            isMuteVideo = false;
            isMuteAudio = false;
        }
    }
}
