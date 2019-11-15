package com.tencent.liteav.demo.trtc.utils;

import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.text.TextUtils;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;
import com.tencent.liteav.TXLiteAVCode;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.Map;

/**
 * 工具类
 */
public class Utils {


    /**
     * 判断错误码是否为进房错误码
     *
     * @param errorCode
     * @return
     */
    public static boolean isEnterRoomError(int errorCode) {
        switch (errorCode) {
            case TXLiteAVCode.ERR_ROOM_ENTER_FAIL:
            case TXLiteAVCode.ERR_ROOM_REQUEST_IP_FAIL:
            case TXLiteAVCode.ERR_ROOM_CONNECT_FAIL:
            case TXLiteAVCode.ERR_ROOM_REQUEST_TOKEN_HTTPS_TIMEOUT:
            case TXLiteAVCode.ERR_ROOM_REQUEST_IP_TIMEOUT:
            case TXLiteAVCode.ERR_ROOM_REQUEST_ENTER_ROOM_TIMEOUT:
            case TXLiteAVCode.ERR_ROOM_REQUEST_TOKEN_INVALID_PARAMETER:
            case TXLiteAVCode.ERR_ENTER_ROOM_PARAM_NULL:
            case TXLiteAVCode.ERR_SDK_APPID_INVALID:
            case TXLiteAVCode.ERR_ROOM_ID_INVALID:
            case TXLiteAVCode.ERR_USER_ID_INVALID:
            case TXLiteAVCode.ERR_USER_SIG_INVALID:
            case TXLiteAVCode.ERR_ROOM_REQUEST_AES_TOKEN_RETURN_ERROR:
            case TXLiteAVCode.ERR_ACCIP_LIST_EMPTY:
            case TXLiteAVCode.ERR_SERVER_INFO_UNPACKING_ERROR:
            case TXLiteAVCode.ERR_SERVER_INFO_TOKEN_ERROR:
            case TXLiteAVCode.ERR_SERVER_INFO_ALLOCATE_ACCESS_FAILED:
            case TXLiteAVCode.ERR_SERVER_INFO_GENERATE_SIGN_FAILED:
            case TXLiteAVCode.ERR_SERVER_INFO_TOKEN_TIMEOUT:
            case TXLiteAVCode.ERR_SERVER_INFO_INVALID_COMMAND:
            case TXLiteAVCode.ERR_SERVER_INFO_PRIVILEGE_FLAG_ERROR:
            case TXLiteAVCode.ERR_SERVER_INFO_GENERATE_KEN_ERROR:
            case TXLiteAVCode.ERR_SERVER_INFO_GENERATE_TOKEN_ERROR:
            case TXLiteAVCode.ERR_SERVER_INFO_DATABASE:
            case TXLiteAVCode.ERR_SERVER_INFO_BAD_ROOMID:
            case TXLiteAVCode.ERR_SERVER_INFO_BAD_SCENE_OR_ROLE:
            case TXLiteAVCode.ERR_SERVER_INFO_ROOMID_EXCHANGE_FAILED:
            case TXLiteAVCode.ERR_SERVER_INFO_SERVICE_SUSPENDED:
            case TXLiteAVCode.ERR_SERVER_INFO_STRGROUP_HAS_INVALID_CHARS:
            case TXLiteAVCode.ERR_SERVER_INFO_LACK_SDKAPPID:
            case TXLiteAVCode.ERR_SERVER_INFO_INVALID:
            case TXLiteAVCode.ERR_SERVER_INFO_ECDH_GET_KEY:
            case TXLiteAVCode.ERR_SERVER_INFO_ECDH_GET_TINYID:
            case TXLiteAVCode.ERR_SERVER_ACC_TOKEN_TIMEOUT:
            case TXLiteAVCode.ERR_SERVER_ACC_SIGN_ERROR:
            case TXLiteAVCode.ERR_SERVER_ACC_SIGN_TIMEOUT:
            case TXLiteAVCode.ERR_SERVER_ACC_ROOM_NOT_EXIST:
            case TXLiteAVCode.ERR_SERVER_ACC_ROOMID:
            case TXLiteAVCode.ERR_SERVER_ACC_LOCATIONID:
            case TXLiteAVCode.ERR_SERVER_CENTER_SYSTEM_ERROR:
            case TXLiteAVCode.ERR_SERVER_CENTER_INVALID_ROOMID:
            case TXLiteAVCode.ERR_SERVER_CENTER_CREATE_ROOM_FAILED:
            case TXLiteAVCode.ERR_SERVER_CENTER_SIGN_ERROR:
            case TXLiteAVCode.ERR_SERVER_CENTER_SIGN_TIMEOUT:
            case TXLiteAVCode.ERR_SERVER_CENTER_ROOM_NOT_EXIST:
            case TXLiteAVCode.ERR_SERVER_CENTER_ADD_USER_FAILED:
            case TXLiteAVCode.ERR_SERVER_CENTER_FIND_USER_FAILED:
            case TXLiteAVCode.ERR_SERVER_CENTER_SWITCH_TERMINATION_FREQUENTLY:
            case TXLiteAVCode.ERR_SERVER_CENTER_LOCATION_NOT_EXIST:
            case TXLiteAVCode.ERR_SERVER_CENTER_NO_PRIVILEDGE_CREATE_ROOM:
            case TXLiteAVCode.ERR_SERVER_CENTER_NO_PRIVILEDGE_ENTER_ROOM:
            case TXLiteAVCode.ERR_SERVER_CENTER_INVALID_PARAMETER:
            case TXLiteAVCode.ERR_SERVER_CENTER_INVALID_ROOM_ID:
            case TXLiteAVCode.ERR_SERVER_CENTER_ROOM_ID_TOO_LONG:
            case TXLiteAVCode.ERR_SERVER_CENTER_ROOM_FULL:
            case TXLiteAVCode.ERR_SERVER_CENTER_DECODE_JSON_FAIL:
            case TXLiteAVCode.ERR_SERVER_CENTER_REACH_PROXY_MAX:
            case TXLiteAVCode.ERR_SERVER_CENTER_RECORDID_STORE:
            case TXLiteAVCode.ERR_SERVER_CENTER_PB_SERIALIZE:
            case TXLiteAVCode.ERR_SERVER_SSO_SIG_EXPIRED:
            case TXLiteAVCode.ERR_SERVER_SSO_SIG_VERIFICATION_FAILED_1:
            case TXLiteAVCode.ERR_SERVER_SSO_SIG_VERIFICATION_FAILED_2:
            case TXLiteAVCode.ERR_SERVER_SSO_SIG_VERIFICATION_FAILED_3:
            case TXLiteAVCode.ERR_SERVER_SSO_SIG_VERIFICATION_FAILED_4:
            case TXLiteAVCode.ERR_SERVER_SSO_SIG_VERIFICATION_FAILED_5:
            case TXLiteAVCode.ERR_SERVER_SSO_SIG_VERIFICATION_FAILED_6:
            case TXLiteAVCode.ERR_SERVER_SSO_SIG_VERIFICATION_FAILED_7:
            case TXLiteAVCode.ERR_SERVER_SSO_SIG_VERIFICATION_FAILED_8:
            case TXLiteAVCode.ERR_SERVER_SSO_SIG_VERIFICATION_ID_NOT_MATCH:
            case TXLiteAVCode.ERR_SERVER_SSO_APPID_NOT_MATCH:
            case TXLiteAVCode.ERR_SERVER_SSO_VERIFICATION_EXPIRED:
            case TXLiteAVCode.ERR_SERVER_SSO_VERIFICATION_FAILED:
            case TXLiteAVCode.ERR_SERVER_SSO_APPID_NOT_FOUND:
            case TXLiteAVCode.ERR_SERVER_SSO_ACCOUNT_IN_BLACKLIST:
            case TXLiteAVCode.ERR_SERVER_SSO_SIG_INVALID:
            case TXLiteAVCode.ERR_SERVER_SSO_LIMITED_BY_SECURITY:
            case TXLiteAVCode.ERR_SERVER_SSO_INVALID_LOGIN_STATUS:
            case TXLiteAVCode.ERR_SERVER_SSO_APPID_ERROR:
            case TXLiteAVCode.ERR_SERVER_SSO_TICKET_VERIFICATION_FAILED:
            case TXLiteAVCode.ERR_SERVER_SSO_TICKET_EXPIRED:
            case TXLiteAVCode.ERR_SERVER_SSO_ACCOUNT_EXCEED_PURCHASES:
            case TXLiteAVCode.ERR_SERVER_SSO_INTERNAL_ERROR:
                return true;
        }
        return false;
    }

    /**
     * 计算 MD5
     *
     * @param string
     * @return
     */
    public static String md5(String string) {
        if (TextUtils.isEmpty(string)) {
            return "";
        }
        MessageDigest md5 = null;
        try {
            md5 = MessageDigest.getInstance("MD5");
            byte[] bytes = md5.digest(string.getBytes());
            String result = "";
            for (byte b : bytes) {
                String temp = Integer.toHexString(b & 0xff);
                if (temp.length() == 1) {
                    temp = "0" + temp;
                }
                result += temp;
            }
            return result;
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        return "";
    }


    /**
     * 根据 Uri 转换到真实的路径
     *
     * @param context
     * @param contentUri
     * @return
     */
    public static String getRealPathFromURI(Context context, Uri contentUri) {
        String res = null;
        String[] proj = {MediaStore.Images.Media.DATA};
        Cursor cursor = context.getContentResolver().query(contentUri, proj, null, null, null);
        if (null != cursor && cursor.moveToFirst()) {
            ;
            int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
            res = cursor.getString(column_index);
            cursor.close();
        }
        return res;
    }

    /**
     * 专为Android4.4设计的从Uri获取文件绝对路径，以前的方法已不好使
     */
    public static String getPath(final Context context, final Uri uri) {

        final boolean isKitKat = Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT;

        // DocumentProvider
        if (isKitKat && DocumentsContract.isDocumentUri(context, uri)) {
            // ExternalStorageProvider
            if (isExternalStorageDocument(uri)) {
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];

                if ("primary".equalsIgnoreCase(type)) {
                    return Environment.getExternalStorageDirectory() + "/" + split[1];
                }
            }
            // DownloadsProvider
            else if (isDownloadsDocument(uri)) {

                final String id = DocumentsContract.getDocumentId(uri);
                final Uri contentUri = ContentUris.withAppendedId(
                        Uri.parse("content://downloads/public_downloads"), Long.valueOf(id));

                return getDataColumn(context, contentUri, null, null);
            }
            // MediaProvider
            else if (isMediaDocument(uri)) {
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
        // MediaStore (and general)
        else if ("content".equalsIgnoreCase(uri.getScheme())) {
            return getDataColumn(context, uri, null, null);
        }
        // File
        else if ("file".equalsIgnoreCase(uri.getScheme())) {
            return uri.getPath();
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

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is ExternalStorageProvider.
     */
    private static boolean isExternalStorageDocument(Uri uri) {
        return "com.android.externalstorage.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is DownloadsProvider.
     */
    private static boolean isDownloadsDocument(Uri uri) {
        return "com.android.providers.downloads.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is MediaProvider.
     */
    private static boolean isMediaDocument(Uri uri) {
        return "com.android.providers.media.documents".equals(uri.getAuthority());
    }


    /**
     * 利用 QRCode 生成 Bitmap的工具函数
     *
     * @param content
     * @param widthPix
     * @param heightPix
     * @return
     */
    public static Bitmap createQRCodeBitmap(String content, int widthPix, int heightPix) {
        try {
            if (content == null || "".equals(content)) {
                return null;
            }
            //配置参数
            Map<EncodeHintType, Object> hints = new HashMap<>();
            hints.put(EncodeHintType.CHARACTER_SET, "utf-8");
            //容错级别
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H);

            // 图像数据转换，使用了矩阵转换
            BitMatrix bitMatrix = new QRCodeWriter().encode(content, BarcodeFormat.QR_CODE, widthPix, heightPix, hints);
            int[] pixels = new int[widthPix * heightPix];
            // 下面这里按照二维码的算法，逐个生成二维码的图片，
            // 两个for循环是图片横列扫描的结果
            for (int y = 0; y < heightPix; y++) {
                for (int x = 0; x < widthPix; x++) {
                    if (bitMatrix.get(x, y)) {
                        pixels[y * widthPix + x] = 0xff000000;
                    } else {
                        pixels[y * widthPix + x] = 0xffffffff;
                    }
                }
            }
            // 生成二维码图片的格式，使用ARGB_8888
            Bitmap bitmap = Bitmap.createBitmap(widthPix, heightPix, Bitmap.Config.ARGB_8888);
            bitmap.setPixels(pixels, 0, widthPix, 0, 0, widthPix, heightPix);
            return bitmap;
        } catch (WriterException e) {
            e.printStackTrace();
        }
        return null;
    }


}
