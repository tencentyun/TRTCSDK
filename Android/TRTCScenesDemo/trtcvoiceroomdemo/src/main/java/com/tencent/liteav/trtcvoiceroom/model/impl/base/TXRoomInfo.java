package com.tencent.liteav.trtcvoiceroom.model.impl.base;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

public class TXRoomInfo implements Serializable {
    /// 这个变量仅仅在本地使用
    public transient String roomId;
    /// 这个变量仅仅在本地使用
    public transient int    memberCount;

    @SerializedName("ownerId")
    @Expose
    public String  ownerId;
    @SerializedName("ownerName")
    @Expose
    public String  ownerName;
    @SerializedName("roomName")
    @Expose
    public String  roomName;
    @SerializedName("cover")
    @Expose
    public String  cover;
    @SerializedName("seatSize")
    @Expose
    public Integer seatSize;
    @SerializedName("needRequest")
    @Expose
    public Integer needRequest;

    @Override
    public String toString() {
        return "TXRoomInfo{" +
                "roomId='" + roomId + '\'' +
                ", memberCount=" + memberCount +
                ", ownerId='" + ownerId + '\'' +
                ", ownerName='" + ownerName + '\'' +
                ", roomName='" + roomName + '\'' +
                ", cover='" + cover + '\'' +
                ", seatSize=" + seatSize +
                ", needRequest=" + needRequest +
                '}';
    }
}
