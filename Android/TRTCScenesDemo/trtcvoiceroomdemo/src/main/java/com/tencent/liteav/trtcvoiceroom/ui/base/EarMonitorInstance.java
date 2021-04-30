package com.tencent.liteav.trtcvoiceroom.ui.base;

import android.content.Context;

public class EarMonitorInstance {
    private static EarMonitorInstance sInstance;
    private boolean mIsEarMonitorOpen;

    public static synchronized EarMonitorInstance getInstance() {
        if (sInstance == null) {
            sInstance = new EarMonitorInstance();
        }
        return sInstance;
    }

    public boolean ismEarMonitorOpen() {
        return mIsEarMonitorOpen;
    }

    public void updateEarMonitorState(boolean isOpen) {
        mIsEarMonitorOpen = isOpen;
    }
}
