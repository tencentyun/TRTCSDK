package com.tencent.trtc.mediashare.helper.reader.exceptions;

import java.io.IOException;

public class ProcessException extends IOException {
    private static final long serialVersionUID = 7566826002677832701L;

    public ProcessException(String detailMessage) {
        super(detailMessage);
    }

    public ProcessException(String detailMessage, Throwable throwable) {
        super("ProcessException: " + detailMessage, throwable);
    }
}
