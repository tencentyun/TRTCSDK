package com.tencent.trtc.localrecord;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.os.Build;
import android.os.ParcelFileDescriptor;
import android.provider.MediaStore;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

/**
 * 操作相册相册工具类
 */
public class AlbumUtils {
    private static final String TAG = "AlbumUtils";

    private AlbumUtils(){

    }

    /**
     * 插入视频到本地相册
     *
     * @param videoPath 保存到相册的视频路径
     * @param coverPath 存储相册缩略图的路径
     */
    public static void saveVideoToDCIM(Context context, String videoPath, String coverPath) {
        if (Build.VERSION.SDK_INT >= 29) {
            saveVideoToDCIMOnAndroid10(context, videoPath);
        } else {
            saveVideoToDCIMBelowAndroid10(context, videoPath, coverPath);
        }
    }

    private static void saveVideoToDCIMBelowAndroid10(Context context, String videoPath, String coverPath) {
        MediaMetadataRetriever retriever = new MediaMetadataRetriever();
        retriever.setDataSource(videoPath);
        int duration = Integer
                .parseInt(retriever
                        .extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION));

        File file = new File(videoPath);
        if (file.exists()) {
            try {
                ContentValues values = initCommonContentValues(file);
                values.put(MediaStore.Video.VideoColumns.DATE_TAKEN, System.currentTimeMillis());
                values.put(MediaStore.MediaColumns.MIME_TYPE, "video/mp4");
                values.put(MediaStore.Video.VideoColumns.DURATION, duration);
                context.getContentResolver().insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values);
                if (coverPath != null) {
                    insertVideoThumb(context, file.getPath(), coverPath);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            Log.d(TAG, "file :" + videoPath + " is not exists");
        }
    }

    /**
     * Android 10(Q) 保存视频文件到本地的方法
     */
    private static void saveVideoToDCIMOnAndroid10(Context context, String videoPath) {
        MediaMetadataRetriever retriever = new MediaMetadataRetriever();
        retriever.setDataSource(videoPath);
        int duration = Integer
                .parseInt(retriever
                        .extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION));

        File file = new File(videoPath);
        if (file.exists()) {
            ContentValues values = new ContentValues();
            long currentTimeInSeconds = System.currentTimeMillis();
            values.put(MediaStore.MediaColumns.TITLE, file.getName());
            values.put(MediaStore.MediaColumns.DISPLAY_NAME, file.getName());
            values.put(MediaStore.MediaColumns.DATE_MODIFIED, currentTimeInSeconds);
            values.put(MediaStore.MediaColumns.DATE_ADDED, currentTimeInSeconds);
            values.put(MediaStore.MediaColumns.SIZE, file.length());
            values.put(MediaStore.MediaColumns.MIME_TYPE, "video/mp4");
            // 时长
            values.put(MediaStore.Video.VideoColumns.DURATION, duration);
            values.put(MediaStore.Video.VideoColumns.DATE_TAKEN, System.currentTimeMillis());
            // Android 10 插入到图库标志位
            values.put(MediaStore.MediaColumns.IS_PENDING, 1);

            Uri collection = MediaStore.Video.Media.getContentUri("external_primary");
            Uri item = context.getContentResolver().insert(collection, values);
            ParcelFileDescriptor pfd = null;
            FileOutputStream fos = null;
            FileInputStream fis = null;
            try {
                pfd = context.getContentResolver().openFileDescriptor(item, "w");
                // Write data into the pending image.
                fos = new FileOutputStream(pfd.getFileDescriptor());
                fis = new FileInputStream(file);
                byte[] data = new byte[1024];
                int length = -1;
                while ((length = fis.read(data)) != -1) {
                    fos.write(data, 0, length);
                }
                fos.flush();
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                if (pfd != null) {
                    try {
                        pfd.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
                if (fos != null) {
                    try {
                        fos.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
                if (fis != null) {
                    try {
                        fos.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
            values.clear();
            values.put(MediaStore.Video.VideoColumns.IS_PENDING, 0);
            context.getContentResolver().update(item, values, null, null);
        } else {
            Log.d(TAG, "file :" + videoPath + " is not exists");
        }
    }

    @NonNull
    private static ContentValues initCommonContentValues(@NonNull File saveFile) {
        ContentValues values = new ContentValues();
        long currentTimeInSeconds = System.currentTimeMillis();
        values.put(MediaStore.MediaColumns.TITLE, saveFile.getName());
        values.put(MediaStore.MediaColumns.DISPLAY_NAME, saveFile.getName());
        values.put(MediaStore.MediaColumns.DATE_MODIFIED, currentTimeInSeconds);
        values.put(MediaStore.MediaColumns.DATE_ADDED, currentTimeInSeconds);
        values.put(MediaStore.MediaColumns.DATA, saveFile.getAbsolutePath());
        values.put(MediaStore.MediaColumns.SIZE, saveFile.length());
        return values;
    }

    private static void insertVideoThumb(Context context, String videoPath, String coverPath) {
        Cursor cursor = context.getContentResolver().query(MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                new String[]{MediaStore.Video.Thumbnails._ID},//返回id列表
                String.format("%s = ?", MediaStore.Video.Thumbnails.DATA), //根据路径查询数据库
                new String[]{videoPath}, null);
        if (cursor != null) {
            if (cursor.moveToFirst()) {
                String videoId = cursor.getString(cursor.getColumnIndex(MediaStore.Video.Thumbnails._ID));
                //查询到了Video的id
                ContentValues thumbValues = new ContentValues();
                thumbValues.put(MediaStore.Video.Thumbnails.DATA, coverPath);//缩略图路径
                thumbValues.put(MediaStore.Video.Thumbnails.VIDEO_ID, videoId);//video的id 用于绑定
                //Video的kind一般为1
                thumbValues.put(MediaStore.Video.Thumbnails.KIND, MediaStore.Video.Thumbnails.MINI_KIND);
                //只返回图片大小信息，不返回图片具体内容
                BitmapFactory.Options options = new BitmapFactory.Options();
                options.inJustDecodeBounds = true;
                Bitmap bitmap = BitmapFactory.decodeFile(coverPath, options);
                if (bitmap != null) {
                    thumbValues.put(MediaStore.Video.Thumbnails.WIDTH, bitmap.getWidth());//缩略图宽度
                    thumbValues.put(MediaStore.Video.Thumbnails.HEIGHT, bitmap.getHeight());//缩略图高度
                    if (!bitmap.isRecycled()) {
                        bitmap.recycle();
                    }
                }
                context.getContentResolver().insert(MediaStore.Video.Thumbnails.EXTERNAL_CONTENT_URI, thumbValues);//缩略图数据库
            }
            cursor.close();
        }
    }

}
