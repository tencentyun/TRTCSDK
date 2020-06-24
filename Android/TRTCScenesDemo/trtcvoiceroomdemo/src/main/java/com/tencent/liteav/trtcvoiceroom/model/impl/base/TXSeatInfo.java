package com.tencent.liteav.trtcvoiceroom.model.impl.base;

import java.io.Serializable;

public class TXSeatInfo implements Serializable {
    public static final transient int STATUS_UNUSED = 0;
    public static final transient int STATUS_USED   = 1;
    public static final transient int STATUS_CLOSE  = 2;

    /// 【字段含义】座位状态 0(unused)/1(used)/2(close)
    public int     status;
    /// 【字段含义】座位是否禁言
    public boolean mute;
    /// 【字段含义】座位状态为1，存储user
    public String  user;

    @Override
    public String toString() {
        return "TXSeatInfo{" +
                "status=" + status +
                ", mute=" + mute +
                ", userInfo=" + user +
                '}';
    }
}