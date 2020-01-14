package com.tencent.liteav.demo.beauty;

public interface Downloadlistener {
    void onDownloadFail(String errorMsg);

    void onDownloadProgress(final int progress);

    void onDownloadSuccess(String filePath);
}
