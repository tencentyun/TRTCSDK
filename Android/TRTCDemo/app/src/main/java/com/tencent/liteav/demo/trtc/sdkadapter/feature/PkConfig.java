package com.tencent.liteav.demo.trtc.sdkadapter.feature;

import java.io.Serializable;

/**
 * pk房间的设置，默认不保存本地
 *
 * @author guanyifeng
 */
public class PkConfig implements Serializable {
    /**
     * 需要连麦的房间号
     */
    private String  mConnectRoomId   = "";
    /**
     * 需要连麦的用户名
     */
    private String  mConnectUserName = "";
    /**
     * 连麦状态，false 连接断开 true 连接成功
     */
    private boolean mIsConnected     = false;

    public void reset() {
        mConnectRoomId = "";
        mConnectUserName = "";
        mIsConnected = false;
    }

    public String getConnectRoomId() {
        return mConnectRoomId;
    }

    public void setConnectRoomId(String connectRoomId) {
        mConnectRoomId = connectRoomId;
    }

    public String getConnectUserName() {
        return mConnectUserName;
    }

    public void setConnectUserName(String connectUserName) {
        mConnectUserName = connectUserName;
    }

    public boolean isConnected() {
        return mIsConnected;
    }

    public void setConnected(boolean connected) {
        mIsConnected = connected;
    }
}
