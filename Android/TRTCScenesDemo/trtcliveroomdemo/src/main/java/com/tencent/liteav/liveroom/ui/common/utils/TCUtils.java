package com.tencent.liteav.liveroom.ui.common.utils;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.ContentUris;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.support.v4.app.ActivityCompat;
import android.text.TextUtils;
import android.util.TypedValue;
import android.widget.ImageView;

import com.squareup.picasso.Picasso;
import com.tencent.liteav.liveroom.R;

import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.List;

/**
 * Module:   TCUtils
 * <p>
 * Function: 工具函数的集合类
 */
public class TCUtils {

    /**
     * @param password 用户输入密码
     * @return 有效则返回true, 无效则返回false
     */
    public static boolean isPasswordValid(String password) {
        return password.length() >= 8 && password.length() <= 16;
    }

    public static String md5(String string) {
        byte[] hash;

        try {
            hash = MessageDigest.getInstance("MD5").digest(string.getBytes(StandardCharsets.UTF_8));
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Huh, MD5 should be supported?", e);
        }

        StringBuilder hex = new StringBuilder(hash.length * 2);

        for (byte b : hash) {
            int i = (b & 0xFF);
            if (i < 0x10) hex.append('0');
            hex.append(Integer.toHexString(i));
        }

        return hex.toString();
    }

    /**
     * @param username 用户名
     * @return 同上
     */
    public static boolean isUsernameVaild(String username) {
        return !username.matches("[0-9]+") && username.matches("^[a-z0-9_-]{4,24}$");
    }

    // 根据原图绘制圆形图片
    static public Bitmap createCircleImage(Bitmap source, int min) {
        final Paint paint = new Paint();
        paint.setAntiAlias(true);
        if (0 == min) {
            min = source.getHeight() > source.getWidth() ? source.getWidth() : source.getHeight();
        }
        Bitmap target = Bitmap.createBitmap(min, min, Bitmap.Config.ARGB_8888);
        // 创建画布
        Canvas canvas = new Canvas(target);
        // 绘圆
        canvas.drawCircle(min / 2, min / 2, min / 2, paint);
        // 设置交叉模式
        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
        // 绘制图片
        canvas.drawBitmap(source, 0, 0, paint);
        return target;
    }

    // 字符串截断
    public static String getLimitString(String source, int length) {
        if (null != source && source.length() > length) {
            //            int reallen = 0;
            return source.substring(0, length) + "...";
        }
        return source;
    }

    // 字符串截断
    public static String getLimitStringWithoutNode(String source, int length) {
        if (null != source && source.length() > length) {
            return source.substring(0, length);
        }
        return source;
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is ExternalStorageProvider.
     */
    public static boolean isExternalStorageDocument(Uri uri) {
        return "com.android.externalstorage.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is DownloadsProvider.
     */
    public static boolean isDownloadsDocument(Uri uri) {
        return "com.android.providers.downloads.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is MediaProvider.
     */
    public static boolean isMediaDocument(Uri uri) {
        return "com.android.providers.media.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is Google Photos.
     */
    public static boolean isGooglePhotosUri(Uri uri) {
        return "com.google.android.apps.photos.content".equals(uri.getAuthority());
    }

    /**
     * Get the value of the data column for this Uri. This is useful for
     * MediaStore Uris, and other file-based ContentProviders.
     *
     * @param context       The context.
     * @param uri           The Uri to query.
     * @param selection     (Optional) Filter used in the query.
     * @param selectionArgs (Optional) Selection arguments used in the query.
     * @return The value of the _data column, which is typically a file path.
     */
    public static String getDataColumn(Context context, Uri uri, String selection,
                                       String[] selectionArgs) {

        Cursor       cursor = null;
        final String column = "_data";
        final String[] projection = {
                column
        };

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
     * Get a file path from a Uri. This will get the the path for Storage Access
     * Framework Documents, as well as the _data field for the MediaStore and
     * other file-based ContentProviders.<br>
     * <br>
     * Callers should check whether the path is local before assuming it
     * represents a local file.
     *
     * @param context The context.
     * @param uri     The Uri to query.
     */
    @TargetApi(19)
    public static String getPath(final Context context, final Uri uri) {
        final boolean isKitKat = Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT;

        // DocumentProvider
        if (isKitKat && DocumentsContract.isDocumentUri(context, uri)) {
            // ExternalStorageProvider
            if (isExternalStorageDocument(uri)) {
                final String   docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String   type  = split[0];

                if ("primary".equalsIgnoreCase(type)) {
                    // FIXBUG：Android10此处Environment.getExternalStorageDirectory()不可以修改，不然从content://映射的路径则不正确
                    return Environment.getExternalStorageDirectory() + "/" + split[1];
                }

                // TODO handle non-primary volumes
            }
            // DownloadsProvider
            else if (isDownloadsDocument(uri)) {

                final String id = DocumentsContract.getDocumentId(uri);
                //FIXBUG：以raw:打头的，去掉raw:就是绝对路径
                if (id != null && id.startsWith("raw:")) {
                    return id.substring(4);
                }
                final Uri contentUri = ContentUris.withAppendedId(
                        Uri.parse("content://downloads/public_downloads"), Long.valueOf(id));

                return getDataColumn(context, contentUri, null, null);
            }
            // MediaProvider
            else if (isMediaDocument(uri)) {
                final String   docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String   type  = split[0];

                Uri contentUri = null;
                if ("image".equals(type)) {
                    contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                } else if ("video".equals(type)) {
                    contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                } else if ("audio".equals(type)) {
                    contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                }

                final String selection = "_id=?";
                final String[] selectionArgs = new String[]{
                        split[1]
                };

                return getDataColumn(context, contentUri, selection, selectionArgs);
            }
        }
        // MediaStore (and general)
        else if ("content".equalsIgnoreCase(uri.getScheme())) {

            // Return the remote address
            if (isGooglePhotosUri(uri))
                return uri.getLastPathSegment();

            return getDataColumn(context, uri, null, null);
        }
        // File
        else if ("file".equalsIgnoreCase(uri.getScheme())) {
            return uri.getPath();
        }

        return null;
    }

    /**
     * 时间格式化
     */
    public static String formattedTime(long second) {
        String hs, ms, ss, formatTime;

        long h, m, s;
        h = second / 3600;
        m = (second % 3600) / 60;
        s = (second % 3600) % 60;
        if (h < 10) {
            hs = "0" + h;
        } else {
            hs = "" + h;
        }

        if (m < 10) {
            ms = "0" + m;
        } else {
            ms = "" + m;
        }

        if (s < 10) {
            ss = "0" + s;
        } else {
            ss = "" + s;
        }
        //        if (hs.equals("00")) {
        //            formatTime = ms + ":" + ss;
        //        } else {
        formatTime = hs + ":" + ms + ":" + ss;
        //        }

        return formatTime;
    }

    public static String duration(long durationMs) {
        long duration = durationMs / 1000;
        long h        = duration / 3600;
        long m        = (duration - h * 3600) / 60;
        long s        = duration - (h * 3600 + m * 60);

        String durationValue;

        if (h == 0) {
            durationValue = asTwoDigit(m) + ":" + asTwoDigit(s);
        } else {
            durationValue = asTwoDigit(h) + ":" + asTwoDigit(m) + ":" + asTwoDigit(s);
        }
        return durationValue;
    }

    public static String asTwoDigit(long digit) {
        String value = "";

        if (digit < 10) {
            value = "0";
        }

        value += String.valueOf(digit);
        return value;
    }

    public static int dp2pxConvertInt(Context context, float dpValue) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dpValue, context.getResources().getDisplayMetrics());
    }

    public static float sp2px(Context context, float spValue) {
        return TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, spValue, context.getResources().getDisplayMetrics());
    }

    /**
     * 显示图片
     *
     * @param context  一般为activtiy
     * @param view     图片显示类
     * @param url      图片url
     * @param defResId 默认图 id
     */
    public static void showPicWithUrl(Context context, ImageView view, String url, int defResId) {
        if (context == null || view == null) {
            return;
        }
        try {
            if (TextUtils.isEmpty(url)) {
                view.setImageResource(defResId);
            } else {
                Picasso.get().load(url).placeholder(defResId).into(view);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /*
     * 获取网络类型
     */
    public static boolean isNetworkAvailable(Context context) {
        ConnectivityManager connectivity = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (connectivity != null) {
            NetworkInfo info = connectivity.getActiveNetworkInfo();
            if (info != null && info.isConnected()) {
                // 当前网络是连接的
                // 当前所连接的网络可用
                return info.getState() == NetworkInfo.State.CONNECTED;
            }
        }
        return false;
    }


    /**
     * 获取一段字符串的字符个数（包含中英文，一个中文算2个字符）
     */
    public static int getCharacterNum(final String content) {
        if (null == content || "".equals(content)) {
            return 0;
        } else {
            return (content.length() + getChineseNum(content));
        }
    }

    /**
     * 返回字符串里中文字或者全角字符的个数
     */
    public static int getChineseNum(String s) {
        int    num    = 0;
        char[] myChar = s.toCharArray();
        for (int i = 0; i < myChar.length; i++) {
            if ((char) (byte) myChar[i] != myChar[i]) {
                num++;
            }
        }
        return num;
    }

    /**
     * 根据比例转化实际数值为相对值
     *
     * @param gear 档位
     * @param max  最大值
     * @param curr 当前值
     * @return 相对值
     */
    public static int filtNumber(int gear, int max, int curr) {
        return curr / (max / gear);
    }

    /**
     * 滤镜定义
     */
    public static final int FILTERTYPE_NONE = 0;    //无特效滤镜

    public static final int FILTERTYPE_biaozhun = 1;    //标准滤镜
    public static final int FILTERTYPE_yinghong = 2;    //樱红滤镜
    public static final int FILTERTYPE_yunshang = 3;    //云裳滤镜
    public static final int FILTERTYPE_chunzhen = 4;    //纯真滤镜
    public static final int FILTERTYPE_bailan   = 5;    //白兰滤镜
    public static final int FILTERTYPE_yuanqi   = 6;    //元气滤镜
    public static final int FILTERTYPE_chaotuo  = 7;    //超脱滤镜
    public static final int FILTERTYPE_xiangfen = 8;    //香氛滤镜

    public static final int FILTERTYPE_langman   = 9;    //浪漫滤镜
    public static final int FILTERTYPE_qingxin   = 10;    //清新滤镜
    public static final int FILTERTYPE_weimei    = 11;    //唯美滤镜
    public static final int FILTERTYPE_fennen    = 12;    //粉嫩滤镜
    public static final int FILTERTYPE_huaijiu   = 13;    //怀旧滤镜
    public static final int FILTERTYPE_landiao   = 14;    //蓝调滤镜
    public static final int FILTERTYPE_qingliang = 15;    //清凉滤镜
    public static final int FILTERTYPE_rixi      = 16;    //日系滤镜

    private static Bitmap decodeResource(Resources resources, int id) {
        TypedValue value = new TypedValue();
        resources.openRawResource(id, value);
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inTargetDensity = value.density;
        return BitmapFactory.decodeResource(resources, id, opts);
    }

    public static Bitmap getFilterBitmap(Resources resources, int filterType) {
        Bitmap bmp = null;
        switch (filterType) {
            case FILTERTYPE_biaozhun:
                bmp = decodeResource(resources, R.drawable.beauty_filter_biaozhun);
                break;
            case FILTERTYPE_yinghong:
                bmp = decodeResource(resources, R.drawable.beauty_filter_yinghong);
                break;
            case FILTERTYPE_yunshang:
                bmp = decodeResource(resources, R.drawable.beauty_filter_yunshang);
                break;
            case FILTERTYPE_chunzhen:
                bmp = decodeResource(resources, R.drawable.beauty_filter_chunzhen);
                break;
            case FILTERTYPE_bailan:
                bmp = decodeResource(resources, R.drawable.beauty_filter_bailan);
                break;
            case FILTERTYPE_yuanqi:
                bmp = decodeResource(resources, R.drawable.beauty_filter_yuanqi);
                break;
            case FILTERTYPE_chaotuo:
                bmp = decodeResource(resources, R.drawable.beauty_filter_chaotuo);
                break;
            case FILTERTYPE_xiangfen:
                bmp = decodeResource(resources, R.drawable.beauty_filter_xiangfen);
                break;
            case FILTERTYPE_langman:
                bmp = decodeResource(resources, R.drawable.beauty_filter_langman);
                break;
            case FILTERTYPE_qingxin:
                bmp = decodeResource(resources, R.drawable.beauty_filter_qingxin);
                break;
            case FILTERTYPE_weimei:
                bmp = decodeResource(resources, R.drawable.beauty_filter_weimei);
                break;
            case FILTERTYPE_fennen:
                bmp = decodeResource(resources, R.drawable.beauty_filter_fennen);
                break;
            case FILTERTYPE_huaijiu:
                bmp = decodeResource(resources, R.drawable.beauty_filter_huaijiu);
                break;
            case FILTERTYPE_landiao:
                bmp = decodeResource(resources, R.drawable.beauty_filter_landiao);
                break;
            case FILTERTYPE_qingliang:
                bmp = decodeResource(resources, R.drawable.beauty_filter_qingliang);
                break;
            case FILTERTYPE_rixi:
                bmp = decodeResource(resources, R.drawable.beauty_filter_rixi);
                break;
            default:
                bmp = null;
                break;
        }
        return bmp;
    }

    /**
     * 绿幕定义
     *
     * @param index
     * @return
     */
    public static String getGreenFileName(int index) {
        String strGreenFileName;
        switch (index) {
            case 0:
                strGreenFileName = "";
                break;
            case 1:
                strGreenFileName = "green_1.mp4";
                break;
            case 2:
                strGreenFileName = "green_2.mp4";
                break;
            default:
                strGreenFileName = "";
                break;
        }
        return strGreenFileName;
    }

    /**
     * 录制权限检测：存储权限、摄像头权限、录音权限
     *
     * @param activity
     * @return
     */
    public static boolean checkRecordPermission(Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            List<String> permissions = new ArrayList<>();
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(activity, Manifest.permission.CAMERA)) {
                permissions.add(Manifest.permission.CAMERA);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(activity, Manifest.permission.RECORD_AUDIO)) {
                permissions.add(Manifest.permission.RECORD_AUDIO);
            }
            if (permissions.size() != 0) {
                ActivityCompat.requestPermissions(activity,
                        permissions.toArray(new String[0]),
                        100);
                return false;
            }
        }

        return true;
    }
}
