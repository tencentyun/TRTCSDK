package com.tencent.liteav.demo.trtcvoiceroom.model;


import java.io.Serializable;

public class VoiceRoomConfig implements Serializable {
    public static final String DATA = "data";

    public int    sdkAppId;
    public String userSig;
    public int    role;
    public int    roomId;
    public String userId;
    public boolean isHighQuality;
}
