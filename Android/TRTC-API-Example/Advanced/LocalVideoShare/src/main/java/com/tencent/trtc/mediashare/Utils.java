package com.tencent.trtc.mediashare;

import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.media.MediaFormat;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.provider.OpenableColumns;

import com.tencent.trtc.mediashare.helper.reader.exceptions.SetupException;
import com.tencent.trtc.mediashare.helper.reader.extractor.Extractor;
import com.tencent.trtc.mediashare.helper.reader.extractor.RangeExtractorAdvancer;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

public class Utils {

    public static MediaFormat retrieveMediaFormat(String videoPath, boolean selectVideo) throws SetupException {
        MediaFormat mediaFormat;
        Extractor extractor = new Extractor(selectVideo, videoPath, new RangeExtractorAdvancer());
        try {
            extractor.setup();
            mediaFormat = extractor.getMediaFormat();
        } finally {
            extractor.release();
        }
        return mediaFormat;
    }

    public static String getPathFromUri(final Context context, final Uri uri) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            try {
                Cursor returnCursor = context.getContentResolver().query(uri, null, null, null, null);
                int nameIndex = returnCursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
                returnCursor.moveToFirst();
                String name = (returnCursor.getString(nameIndex));
                File file = new File(context.getFilesDir(), name);
                InputStream inputStream = context.getContentResolver().openInputStream(uri);
                FileOutputStream outputStream = new FileOutputStream(file);
                int read = 0;
                int maxBufferSize = 1 * 1024 * 1024;
                int bytesAvailable = inputStream.available();

                int bufferSize = Math.min(bytesAvailable, maxBufferSize);

                final byte[] buffers = new byte[bufferSize];
                while ((read = inputStream.read(buffers)) != -1) {
                    outputStream.write(buffers, 0, read);
                }
                returnCursor.close();
                inputStream.close();
                outputStream.close();
                return file.getPath();
            } catch (Exception e) {
                e.printStackTrace();
            }
            return null;
        }

        if (DocumentsContract.isDocumentUri(context, uri)) {
            if (isExternalStorageDocument(uri)) {
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];

                if ("primary".equalsIgnoreCase(type)) {
                    return Environment.getExternalStorageDirectory() + "/" + split[1];
                }
            } else if (isDownloadsDocument(uri)) {
                final String id = DocumentsContract.getDocumentId(uri);
                if (id != null && id.startsWith("raw:")) {
                    return id.substring(4);
                }
                final Uri contentUri = ContentUris.withAppendedId(
                        Uri.parse("content://downloads/public_downloads"), Long.valueOf(id));

                return getDataColumn(context, contentUri, null, null);
            } else if (isMediaDocument(uri)) {
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];

                Uri contentUri = null;
                if ("image".equals(type)) {
                    contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                } else if ("video".equals(type)) {
                    contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                } else if ("audio".equals(type)) {
                    contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                }

                final String selection = "_id=?";
                final String[] selectionArgs = new String[]{split[1]};

                return getDataColumn(context, contentUri, selection, selectionArgs);
            }
        }
        return null;
    }

    private static String getDataColumn(Context context, Uri uri, String selection,
                                        String[] selectionArgs) {

        Cursor cursor = null;
        final String column = "_data";
        final String[] projection = {column};

        try {
            cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs,
                    null);
            if (cursor != null && cursor.moveToFirst()) {
                final int column_index = cursor.getColumnIndexOrThrow(column);
                return cursor.getString(column_index);
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }
        return null;
    }

    private static boolean isExternalStorageDocument(Uri uri) {
        return "com.android.externalstorage.documents".equals(uri.getAuthority());
    }

    private static boolean isDownloadsDocument(Uri uri) {
        return "com.android.providers.downloads.documents".equals(uri.getAuthority());
    }

    private static boolean isMediaDocument(Uri uri) {
        return "com.android.providers.media.documents".equals(uri.getAuthority());
    }

}
