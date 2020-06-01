package com.tencent.liteav.meeting.ui.widget.page;

import android.util.Log;

public class PagerConfig {
    private static final String TAG = "MeetingPagerGrid";
    private static boolean sShowLog = false;
    private static int sFlingThreshold = 1000;          // Fling 阀值，滚动速度超过该阀值才会触发滚动
    private static float sMillisecondsPreInch = 60f;    // 每一个英寸滚动需要的微秒数，数值越大，速度越慢

    /**
     * 判断是否输出日志
     *
     * @return true 输出，false 不输出
     */
    public static boolean isShowLog() {
        return sShowLog;
    }

    /**
     * 设置是否输出日志
     *
     * @param showLog 是否输出
     */
    public static void setShowLog(boolean showLog) {
        sShowLog = showLog;
    }

    /**
     * 获取当前滚动速度阀值
     *
     * @return 当前滚动速度阀值
     */
    public static int getFlingThreshold() {
        return sFlingThreshold;
    }

    /**
     * 设置当前滚动速度阀值
     *
     * @param flingThreshold 滚动速度阀值
     */
    public static void setFlingThreshold(int flingThreshold) {
        sFlingThreshold = flingThreshold;
    }

    /**
     * 获取滚动速度 英寸/微秒
     *
     * @return 英寸滚动速度
     */
    public static float getMillisecondsPreInch() {
        return sMillisecondsPreInch;
    }

    /**
     * 设置像素滚动速度 英寸/微秒
     *
     * @param millisecondsPreInch 英寸滚动速度
     */
    public static void setMillisecondsPreInch(float millisecondsPreInch) {
        sMillisecondsPreInch = millisecondsPreInch;
    }

    //--- 日志 -------------------------------------------------------------------------------------

    public static void Logi(String msg) {
        if (!PagerConfig.isShowLog()) return;
        Log.i(TAG, msg);
    }

    public static void Loge(String msg) {
        if (!PagerConfig.isShowLog()) return;
        Log.e(TAG, msg);
    }
}
