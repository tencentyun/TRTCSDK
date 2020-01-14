package com.tencent.liteav.demo.trtcvoiceroom.widgets;

public class VoiceRoomSeatEntity {
    public String userName;
    public boolean isTalk;
    public boolean isPlaceHolder;

    public VoiceRoomSeatEntity(boolean isPlaceHolder) {
        this.isPlaceHolder = isPlaceHolder;
    }
}
