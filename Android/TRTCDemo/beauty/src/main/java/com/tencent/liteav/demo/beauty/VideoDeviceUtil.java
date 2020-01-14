package com.tencent.liteav.demo.beauty;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;

import java.io.File;

public class VideoDeviceUtil {
    private static final String TAG = "VideoDeviceUtil";

    public VideoDeviceUtil() {
    }

    public static boolean isNetworkAvailable(@NonNull Context context) {
        ConnectivityManager connectivity = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (connectivity == null) {
            return false;
        } else {
            NetworkInfo networkInfo = connectivity.getActiveNetworkInfo();
            return networkInfo != null && networkInfo.isConnectedOrConnecting();
        }
    }

    @Nullable
    public static File getExternalFilesDir(@NonNull Context context, String folder) {
        if (context == null) {
            Log.e(TAG, "getExternalFilesDir context is null");
            return null;
        }
        File sdcardDir = context.getApplicationContext().getExternalFilesDir(null);
        if (sdcardDir == null) {
            Log.e(TAG, "sdcardDir is null");
            return null;
        }
        String path = sdcardDir.getPath();

        File file = new File(path + File.separator + folder);

        try {
            if (file.exists() && file.isFile()) {
                file.delete();
            }

            if (!file.exists()) {
                file.mkdirs();
            }
        } catch (Exception var5) {
            var5.printStackTrace();
        }

        return file;
    }

}
