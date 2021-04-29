package com.tencent.trtc.customcamera.helper.render;

import android.annotation.TargetApi;
import android.view.Surface;

/**
 * 在eglMakeCurrent时，需要关联Context和窗口（或Surface），因此将两者合在一起。
 */
public class EglCore {
    private EGLHelper mEglHelper;

    /**
     * 创建一个EglCore，其中窗口为离屏Surface，且不共享其他的EGLContext
     *
     * @param width  离屏Surface的宽
     * @param height 离屏Surface的高
     */
    public EglCore(int width, int height) {
        this((android.opengl.EGLContext) null, width, height);
    }

    /**
     * 创建一个EglCore，窗口为传入的Surface，不共享其他的EGLContext
     *
     * @param surface 新创建的EGLContext的渲染目标
     */
    public EglCore(Surface surface) {
        this((android.opengl.EGLContext) null, surface);
    }

    /**
     * 创建一个EglCore，关联一个离屏surface
     *
     * @param sharedContext 用于共享的OpenGL Context，可为null
     * @param width         离屏surface的宽
     * @param height        离屏surface的高
     */
    public EglCore(android.opengl.EGLContext sharedContext, int width, int height) {
        mEglHelper = EGL14Helper.createEGLSurface(null, sharedContext, null, width, height);
    }

    /**
     * 创建一个EglCore，关联一个离屏surface
     *
     * @param sharedContext 用于共享的OpenGL Context，可为null
     * @param width         离屏surface的宽
     * @param height        离屏surface的高
     */
    public EglCore(javax.microedition.khronos.egl.EGLContext sharedContext, int width, int height) {
        mEglHelper = EGL10Helper.createEGLSurface(null, sharedContext, null, width, height);
    }

    /**
     * 创建一个EglCore，并关联到传入的surface
     *
     * @param sharedContext 用于共享的OpenGL Context，可为null
     * @param surface       渲染的目标
     */
    public EglCore(android.opengl.EGLContext sharedContext, Surface surface) {
        mEglHelper = EGL14Helper.createEGLSurface(null, sharedContext, surface, 0, 0);
    }

    /**
     * 创建一个EglCore，并关联到传入的surface
     *
     * @param sharedContext 用于共享的OpenGL Context，可为null
     * @param surface       渲染的目标
     */
    public EglCore(javax.microedition.khronos.egl.EGLContext sharedContext, Surface surface) {
        mEglHelper = EGL10Helper.createEGLSurface(null, sharedContext, surface, 0, 0);
    }

    public void makeCurrent() {
        mEglHelper.makeCurrent();
    }

    public void unmakeCurrent() {
        mEglHelper.unmakeCurrent();
    }

    public void swapBuffer() {
        mEglHelper.swapBuffers();
    }

    public Object getEglContext() {
        return mEglHelper.getContext();
    }

    public void destroy() {
        mEglHelper.destroy();
        mEglHelper = null;
    }

    @TargetApi(18)
    public void setPresentationTime(long nsecs) {
        if (mEglHelper instanceof EGL14Helper) {
            ((EGL14Helper) mEglHelper).setPresentationTime(nsecs);
        }
    }
}

