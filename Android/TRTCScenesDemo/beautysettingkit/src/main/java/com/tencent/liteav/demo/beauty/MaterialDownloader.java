package com.tencent.liteav.demo.beauty;

import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.text.TextUtils;

import java.io.File;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

/**
 * 美颜模块素材下载
 */
public class MaterialDownloader {
    private Context mContext;
    public static final String DOWNLOAD_FILE_POSTFIX = ".zip";
    public static final String ONLINE_MATERIAL_FOLDER = "cameraVideoAnimal";
    private static final int CPU_COUNT = Runtime.getRuntime().availableProcessors();
    private static final int CORE_POOL_SIZE = CPU_COUNT + 1;
    private boolean mProcessing;

    private String mUrl;
    private Downloadlistener mListener;
    private DownloadThreadPool mDownloadThreadPool;
    private String mMaterialId;

    public MaterialDownloader(Context context, String materialId, String url) {
        mContext = context;
        mMaterialId = materialId;
        mUrl = url;
        mProcessing = false;
    }

    public void start(@Nullable Downloadlistener listener) {
        if (listener == null || TextUtils.isEmpty(mUrl) || mProcessing) {
            return;
        }
        mProcessing = true;
        mListener = listener;
        mListener.onDownloadProgress(0);
        HttpFileListener fileListener = new HttpFileListener() {
            @Override
            public void onSaveSuccess(@NonNull File file) {
                //删除该素材目录下的旧文件
                File path = new File(file.toString().substring(0, file.toString().indexOf(DOWNLOAD_FILE_POSTFIX)));
                if (path.exists() && path.isDirectory()) {
                    File[] oldFiles = path.listFiles();
                    if (oldFiles != null) {
                        for (File f : oldFiles) {
                            f.delete();
                        }
                    }
                }

                String dataDir = VideoUtil.unZip(file.getPath(), file.getParentFile().getPath());
                if (TextUtils.isEmpty(dataDir)) {
                    mListener.onDownloadFail(mContext.getString(R.string.video_material_download_progress_material_unzip_failed));
                    stop();
                    return;
                }
                file.delete();
                mListener.onDownloadSuccess(dataDir);
                stop();
            }

            @Override
            public void onSaveFailed(File file, Exception e) {
                mListener.onDownloadFail(mContext.getString(R.string.video_material_download_progress_download_failed));
                stop();
            }

            @Override
            public void onProgressUpdate(int progress) {
                mListener.onDownloadProgress(progress);
            }

            @Override
            public void onProcessEnd() {
                mProcessing = false;
            }

        };
        File onlineMaterialDir = VideoDeviceUtil.getExternalFilesDir(mContext, ONLINE_MATERIAL_FOLDER);
        if (onlineMaterialDir == null || onlineMaterialDir.getName().startsWith("null")) {
            mListener.onDownloadFail(mContext.getString(R.string.video_material_download_progress_no_enough_storage_space));
            stop();
            return;
        }
        if (!onlineMaterialDir.exists()) {
            onlineMaterialDir.mkdirs();
        }

        ThreadPoolExecutor threadPool = getThreadExecutor();
        threadPool.execute(new HttpFileUtil(mContext, mUrl, onlineMaterialDir.getPath(), mMaterialId + DOWNLOAD_FILE_POSTFIX, fileListener, true));
    }

    public void stop() {
        mListener = null;
    }

    public synchronized ThreadPoolExecutor getThreadExecutor() {
        if (mDownloadThreadPool == null || mDownloadThreadPool.isShutdown()) {
            mDownloadThreadPool = new DownloadThreadPool(CORE_POOL_SIZE);
        }
        return mDownloadThreadPool;
    }

    public static class DownloadThreadPool extends ThreadPoolExecutor {

        @TargetApi(Build.VERSION_CODES.GINGERBREAD)
        public DownloadThreadPool(int poolSize) {
            super(poolSize, poolSize, 0L, TimeUnit.MILLISECONDS,
                    new LinkedBlockingDeque<Runnable>(),
                    Executors.defaultThreadFactory(), new DiscardOldestPolicy());
        }
    }
}
