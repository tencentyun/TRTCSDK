package com.tencent.liteav.trtcchatsalon.ui.base;

import android.support.annotation.NonNull;

public class ChatSalonMemberEntity implements Comparable<ChatSalonMemberEntity> {
    public String  userId;
    public String  userName;
    public String  userAvatar;
    public boolean isTalk;
    public boolean isMute = true;
    public boolean isManager;
    public String  invitedId;
    public long    enterTime;

    @Override
    public int compareTo(@NonNull ChatSalonMemberEntity o) {
        return (int) (this.enterTime - o.enterTime);
    }
}