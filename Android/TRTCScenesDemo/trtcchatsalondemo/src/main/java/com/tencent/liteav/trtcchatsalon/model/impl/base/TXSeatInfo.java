package com.tencent.liteav.trtcchatsalon.model.impl.base;

import java.io.Serializable;

public class TXSeatInfo implements Serializable {
    /// 【字段含义】座位是否静音
    public boolean mute;
    /// 【字段含义】存储用户userId
    public String  user;

    @Override
    public String toString() {
        return "TXSeatInfo{" +
                ", mute=" + mute +
                ", userInfo=" + user +
                '}';
    }
}