package com.tencent.liteav.demo.trtc.sdkadapter.feature;

import java.io.Serializable;

/**
 * 其他的一些设置项，不保存本地
 *
 * @author guanyifeng
 */
public class MoreConfig implements Serializable {
    // 是否开启闪光灯
    private boolean mEnableFlash = false;

    public boolean isEnableFlash() {
        return mEnableFlash;
    }

    public void setEnableFlash(boolean enableFlash) {
        mEnableFlash = enableFlash;
    }

    public void reset() {
        mEnableFlash = false;
    }
}
