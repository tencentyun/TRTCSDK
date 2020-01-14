package com.tencent.liteav.trtcaudiocalldemo.demo;

import android.graphics.Bitmap;
import android.text.TextUtils;

import com.blankj.utilcode.util.ImageUtils;
import com.blankj.utilcode.util.ResourceUtils;

public class Utils {
    public static Bitmap getAvatar(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return null;
        }
        byte[] bytes      = userId.getBytes();
        int    index      = bytes[bytes.length - 1] % 10;
        String avatarName = "avatar" + index + "_100";
        int    id         = ResourceUtils.getDrawableIdByName(avatarName);
        return ImageUtils.getBitmap(id);
    }
}
