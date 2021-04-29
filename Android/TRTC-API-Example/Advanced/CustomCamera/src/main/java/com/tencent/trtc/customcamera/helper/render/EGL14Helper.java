package com.tencent.trtc.customcamera.helper.render;

import android.annotation.TargetApi;
import android.opengl.EGL14;
import android.opengl.EGLConfig;
import android.opengl.EGLContext;
import android.opengl.EGLDisplay;
import android.opengl.EGLExt;
import android.opengl.EGLSurface;
import android.util.Log;
import android.view.Surface;

@TargetApi(17)
public class EGL14Helper implements EGLHelper<EGLContext> {
    private static final String TAG = "EGL14Helper";

    private static final int        EGL_RECORDABLE_ANDROID               = 0x3142;
    private static final int        GLES_VERSION                         = 2;
    private static final int[]      ATTRIBUTE_LIST_FOR_SURFACE           = {
            EGL14.EGL_RED_SIZE, 8,
            EGL14.EGL_GREEN_SIZE, 8,
            EGL14.EGL_BLUE_SIZE, 8,
            EGL14.EGL_ALPHA_SIZE, 8,
            EGL14.EGL_DEPTH_SIZE, 0,
            EGL14.EGL_STENCIL_SIZE, 0,
            EGL14.EGL_RENDERABLE_TYPE, GLES_VERSION == 2 ? EGL14.EGL_OPENGL_ES2_BIT : EGL14.EGL_OPENGL_ES2_BIT | EGLExt.EGL_OPENGL_ES3_BIT_KHR,
            EGL_RECORDABLE_ANDROID, 1,
            EGL14.EGL_NONE
    };
    private static final int[]      ATTRIBUTE_LIST_FOR_OFFSCREEN_SURFACE = {
            EGL14.EGL_SURFACE_TYPE, EGL14.EGL_PBUFFER_BIT,//前台显示Surface这里EGL10.EGL_WINDOW_BIT
            EGL14.EGL_RED_SIZE, 8,
            EGL14.EGL_GREEN_SIZE, 8,
            EGL14.EGL_BLUE_SIZE, 8,
            EGL14.EGL_ALPHA_SIZE, 8,
            EGL14.EGL_DEPTH_SIZE, 0,
            EGL14.EGL_STENCIL_SIZE, 0,
            EGL14.EGL_RENDERABLE_TYPE, GLES_VERSION == 2 ? EGL14.EGL_OPENGL_ES2_BIT : EGL14.EGL_OPENGL_ES2_BIT | EGLExt.EGL_OPENGL_ES3_BIT_KHR,
            EGL_RECORDABLE_ANDROID, 1,
            EGL14.EGL_NONE
    };
    private final        int        mWidth;
    private final        int        mHeight;
    private              EGLConfig  mEGLConfig                           = null;
    private              EGLDisplay mEGLDisplay                          = EGL14.EGL_NO_DISPLAY;
    private              EGLContext mEGLContext                          = EGL14.EGL_NO_CONTEXT;
    private              EGLSurface mEGLSurface;

    private EGL14Helper(int width, int height) {
        mWidth = width;
        mHeight = height;
    }

    public static EGL14Helper createEGLSurface(EGLConfig config, EGLContext context, Surface surface, int width, int height) {
        EGL14Helper egl = new EGL14Helper(width, height);
        if (egl.initialize(config, context, surface)) {
            return egl;
        } else {
            return null;
        }
    }

    @Override
    public void makeCurrent() {
        if (mEGLDisplay == EGL14.EGL_NO_DISPLAY) {
            // called makeCurrent() before create?
            Log.d(TAG, "NOTE: makeCurrent w/o display");
        }
        if (!EGL14.eglMakeCurrent(mEGLDisplay, mEGLSurface, mEGLSurface, mEGLContext)) {
            throw new RuntimeException("eglMakeCurrent failed");
        }
    }

    @Override
    public void destroy() {
        if (mEGLDisplay != EGL14.EGL_NO_DISPLAY) {
            // Android is unusual in that it uses a reference-counted EGLDisplay.  So for
            // every eglInitialize() we need an eglTerminate().
            EGL14.eglMakeCurrent(mEGLDisplay, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT);
            if (mEGLSurface != EGL14.EGL_NO_SURFACE) {
                EGL14.eglDestroySurface(mEGLDisplay, mEGLSurface);
                mEGLSurface = EGL14.EGL_NO_SURFACE;
            }
            if (mEGLContext != EGL14.EGL_NO_CONTEXT) {
                EGL14.eglDestroyContext(mEGLDisplay, mEGLContext);
                mEGLContext = EGL14.EGL_NO_CONTEXT;
            }
            EGL14.eglReleaseThread();
            EGL14.eglTerminate(mEGLDisplay);
        }
        mEGLDisplay = EGL14.EGL_NO_DISPLAY;
    }

    @Override
    public boolean swapBuffers() {
        return EGL14.eglSwapBuffers(mEGLDisplay, mEGLSurface);
    }

    private boolean initialize(EGLConfig config, EGLContext context, Surface surface) {
        mEGLDisplay = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY);
        if (mEGLDisplay == EGL14.EGL_NO_DISPLAY) {
            throw new RuntimeException("unable to get EGL14 display");
        }

        int[] version = new int[2];
        if (!EGL14.eglInitialize(mEGLDisplay, version, 0, version, 1)) {
            mEGLDisplay = null;
            throw new RuntimeException("unable to initialize EGL14");
        }

        if (config != null) {
            mEGLConfig = config;
        } else {
            EGLConfig[] configs    = new EGLConfig[1];
            int[]       numConfigs = new int[1];
            int[]       attribList = surface == null ? ATTRIBUTE_LIST_FOR_OFFSCREEN_SURFACE : ATTRIBUTE_LIST_FOR_SURFACE;
            if (!EGL14.eglChooseConfig(mEGLDisplay, attribList, 0, configs, 0, configs.length, numConfigs, 0)) {
                return false;
            }
            mEGLConfig = configs[0];
        }

        if (context == null) {
            context = EGL14.EGL_NO_CONTEXT;
        }
        int[] attrib_list = {
                EGL14.EGL_CONTEXT_CLIENT_VERSION, GLES_VERSION,
                EGL14.EGL_NONE
        };
        mEGLContext = EGL14.eglCreateContext(mEGLDisplay, mEGLConfig, context, attrib_list, 0);
        if (mEGLContext == EGL14.EGL_NO_CONTEXT) {
            checkEGLError();
            return false;
        }

        if (surface == null) {
            int[] attribListPbuffer = {
                    EGL14.EGL_WIDTH, mWidth,
                    EGL14.EGL_HEIGHT, mHeight,
                    EGL14.EGL_NONE
            };
            mEGLSurface = EGL14.eglCreatePbufferSurface(mEGLDisplay, mEGLConfig, attribListPbuffer, 0);
        } else {
            int[] surfaceAttribs = {EGL14.EGL_NONE};
            mEGLSurface = EGL14.eglCreateWindowSurface(mEGLDisplay, mEGLConfig, surface, surfaceAttribs, 0);
        }

        checkEGLError();
        if (!EGL14.eglMakeCurrent(mEGLDisplay, mEGLSurface, mEGLSurface, mEGLContext)) {
            checkEGLError();
            return false;
        }
        return true;
    }

    @Override
    public void unmakeCurrent() {
        if (mEGLDisplay != EGL14.EGL_NO_DISPLAY) {
            EGL14.eglMakeCurrent(mEGLDisplay, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT);
        }
    }

    public void setPresentationTime(long nsecs) {
        EGLExt.eglPresentationTimeANDROID(mEGLDisplay, mEGLSurface, nsecs);
    }

    @Override
    public EGLContext getContext() {
        return mEGLContext;
    }

    public EGLConfig getConfig() {
        return mEGLConfig;
    }

    private void checkEGLError() {
        int ec = EGL14.eglGetError();
        if (ec != EGL14.EGL_SUCCESS) {
            Log.e(TAG, "EGL error:" + ec);
            throw new RuntimeException(": EGL error: 0x" + Integer.toHexString(ec));
        }
    }
}
