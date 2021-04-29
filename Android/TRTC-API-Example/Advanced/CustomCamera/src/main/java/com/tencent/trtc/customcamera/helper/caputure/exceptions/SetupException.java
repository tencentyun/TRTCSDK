package com.tencent.trtc.customcamera.helper.caputure.exceptions;

import java.io.IOException;

public class SetupException extends IOException {
    private static final long serialVersionUID = 5408828566884638165L;

    public SetupException(String detailMessage) {
        super(detailMessage);
    }

    public SetupException(String detailMessage, Throwable throwable) {
        super("SetupException: " + detailMessage, throwable);
    }
}
