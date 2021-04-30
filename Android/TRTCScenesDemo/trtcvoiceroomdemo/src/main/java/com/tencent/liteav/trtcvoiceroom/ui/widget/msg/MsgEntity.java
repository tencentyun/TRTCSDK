package com.tencent.liteav.trtcvoiceroom.ui.widget.msg;

public class MsgEntity {
    public static final int TYPE_NORMAL      = 0;
    public static final int TYPE_WAIT_AGREE  = 1;
    public static final int TYPE_AGREED      = 2;
    public static final int TYPE_WELCOME     = 3;

    public String  userId;
    public String  userName;
    public String  content;
    public String  invitedId;
    public String  linkUrl;
    public int     type;
    public int     color;
    public boolean isChat;
}
