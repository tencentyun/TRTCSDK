package com.tencent.liteav.demo.beauty;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;

/**
 * 属性管理
 */
public class UIAttributeUtil {
    /**
     * 获取主题设置的图片资源的drawable
     *
     * @param context           context
     * @param attrId            style-attr对应的id
     * @param defaultResourceId 默认的图片id
     * @return Drawable
     */
    public static Drawable getDrawableResources(Context context, int attrId, int defaultResourceId) {
        TypedArray a = context.obtainStyledAttributes(new int[]{attrId});
        int resourceId = a.getResourceId(0, defaultResourceId);
        Drawable drawable = context.getResources().getDrawable(resourceId);
        a.recycle();
        return drawable;
    }

    public static int getColorRes(Context context, int attrId, int defaultColorId) {
        TypedArray a = context.obtainStyledAttributes(new int[]{attrId});
        int color = a.getColor(0, context.getResources().getColor(defaultColorId));
        a.recycle();
        return color;
    }

    public static int getTextSizeResources(Context context, int attrId, int defaultTextSize) {
        TypedArray a = context.obtainStyledAttributes(new int[]{attrId});
        int textSize = a.getDimensionPixelOffset(0, defaultTextSize);
        a.recycle();
        return textSize;
    }

    public static int getResResources(Context context, int attrId, int defaultResourceId) {
        TypedArray a = context.obtainStyledAttributes(new int[]{attrId});
        int resourceId = a.getResourceId(0, defaultResourceId);
        a.recycle();
        return resourceId;
    }

    public static int[] getResResourcsArray(Context context, int[] attrId, int[] defaultResourceId) {
        int[] resourceIdArray = new int[attrId.length];

        TypedArray a = context.obtainStyledAttributes(attrId);
        for (int i = 0; i < attrId.length; i++) {
            resourceIdArray[i] = a.getResourceId(i, defaultResourceId[i]);
        }
        a.recycle();
        return resourceIdArray;
    }

}
