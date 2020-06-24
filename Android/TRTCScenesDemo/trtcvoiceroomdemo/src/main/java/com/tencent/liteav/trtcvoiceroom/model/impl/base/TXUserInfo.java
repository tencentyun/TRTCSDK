package com.tencent.liteav.trtcvoiceroom.model.impl.base;

import java.io.Serializable;

public class TXUserInfo implements Serializable {
    public String userId;
    public String userName;
    public String avatarURL;

    @Override
    public String toString() {
        return "TXUserInfo{" +
                "userId='" + userId + '\'' +
                ", userName='" + userName + '\'' +
                ", avatarURL='" + avatarURL + '\'' +
                '}';
    }
}
