package com.tencent.liteav.login.model;

public class IMUserInfo {
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
