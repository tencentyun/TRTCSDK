package com.tencent.liteav.meeting.ui.widget.settingitem;

import android.content.Context;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;

import java.util.Arrays;
import java.util.List;

/**
 * 通用设置项的基类
 *
 * @author guanyifeng
 */
public abstract class BaseSettingItem {
    protected Context        mContext;
    protected LayoutInflater mInflater;
    protected ItemText       mItemText;

    public BaseSettingItem(Context context,
                           @NonNull ItemText itemText) {
        mContext = context;
        mItemText = itemText;
        mInflater = LayoutInflater.from(context);
    }

    /**
     * 返回主view
     *
     * @return
     */
    public abstract View getView();

    public static class ItemText {
        public String       title;
        public List<String> contentText;

        public ItemText(String title, String... textList) {
            this.title = title;
            this.contentText = Arrays.asList(textList);
        }

        public ItemText(String title, List<String> textList) {
            this.title = title;
            this.contentText = textList;
        }
    }
}
