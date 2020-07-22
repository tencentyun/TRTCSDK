package com.tencent.custom.customcapture.structs;

import android.opengl.EGLContext;

public class TextureFrame {
    public EGLContext eglContext;

    public int textureId;

    public int width;

    public int height;

    public long timestampMs;
}
