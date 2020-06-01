package com.tencent.liteav.meeting.model.impl.base;

import com.tencent.liteav.basic.log.TXCLog;

public class TRTCLogger {

    public static void e(String tag, String message) {
        TXCLog.e(tag, message);
        callback("e", tag, message);
    }

    public static void w(String tag, String message) {
        TXCLog.w(tag, message);
        callback("w", tag, message);
    }

    public static void i(String tag, String message) {
        TXCLog.i(tag, message);
        callback("i", tag, message);
    }

    public static void d(String tag, String message) {
        TXCLog.d(tag, message);
        callback("d", tag, message);
    }

    private static void callback(String level, String tag, String message) {
    }
}
