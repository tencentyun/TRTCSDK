package com.tencent.liteav.demo.trtc.customCapture.openGLBaseModule;

import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.opengl.Matrix;
import android.util.Log;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

/**
 * 将外部纹理转为普通纹理，需要在OpenGL环境中使用
 */
public class GLTextureOESFilter {

    private static final String TAG = "GLTextureOESFilter";
    private int mOutputWidth = 0;
    private int mOutputHeight = 0;
    private float[] mProjectionMatrix = new float[16];
    private float[] mModeMatrix = new float[16];

    private static final int FLOAT_SIZE_BYTES = 4;
    private static final int TRIANGLE_VERTICES_DATA_STRIDE_BYTES = 5 * FLOAT_SIZE_BYTES;
    private static final int TRIANGLE_VERTICES_DATA_POS_OFFSET = 0;
    private static final int TRIANGLE_VERTICES_DATA_UV_OFFSET = 3;
    private static final int INVALID_TEXTURE_ID = -12345;
    private final float[] mTriangleVerticesData = {
            // X, Y, Z, U, V
            -1.0f, -1.0f, 0, 0.f, 0.f,
            1.0f, -1.0f, 0, 1.f, 0.f,
            -1.0f,  1.0f, 0, 0.f, 1.f,
            1.0f,  1.0f, 0, 1.f, 1.f,
    };

    private FloatBuffer mTriangleVertices;

    private static final String VERTEX_SHADER =
            "uniform mat4 uMVPMatrix;\n" +
                    "uniform mat4 uSTMatrix;\n" +
                    "attribute vec4 aPosition;\n" +
                    "attribute vec4 aTextureCoord;\n" +
                    "varying vec2 vTextureCoord;\n" +
                    "void main() {\n" +
                    "  gl_Position = uMVPMatrix * aPosition;\n" +
                    "  vTextureCoord = (uSTMatrix * aTextureCoord).xy;\n" +
                    "}\n";

    private static final String FRAGMENT_SHADER_OESTEX =
            "#extension GL_OES_EGL_image_external : require\n" +
                    "precision mediump float;\n" +      // highp here doesn't seem to matter
                    "varying vec2 vTextureCoord;\n" +
                    "uniform samplerExternalOES sTexture;\n" +
                    "void main() {\n" +
                    "  gl_FragColor = texture2D(sTexture, vTextureCoord);\n" +
                    "}\n";

    private float[] mMVPMatrix = new float[16];
    private float[] mSTMatrix = new float[16];

    private int mProgram;
    private int mFrameBufferTextureID = INVALID_TEXTURE_ID;
    private int mFrameBufferID = INVALID_TEXTURE_ID;
    private int muMVPMatrixHandle;
    private int muSTMatrixHandle;
    private int maPositionHandle;
    private int maTextureHandle;

    public GLTextureOESFilter() {
        mTriangleVertices = ByteBuffer.allocateDirect(
                mTriangleVerticesData.length * FLOAT_SIZE_BYTES)
                .order(ByteOrder.nativeOrder()).asFloatBuffer();
        mTriangleVertices.put(mTriangleVerticesData).position(0);

        Matrix.setIdentityM(mSTMatrix, 0);

        create();
    }

    public void setMatrix(float[] mtx) {
        mSTMatrix = mtx;
    }

    public int drawToTexture(int textureId) {

        if (mFrameBufferID == INVALID_TEXTURE_ID) {
            Log.d(TAG, "invalid frame buffer id");
            return textureId;
        }
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, mFrameBufferID);

        draw(textureId);

        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);

        return  mFrameBufferTextureID;
    }

    public void release() {
        if (mProgram != -1) {
            GLES20.glDeleteProgram(mProgram);
            mProgram = -1;
        }

        destroyFrameBuffer();
    }

    /**
     * Initializes GL state.
     */
    private void create() {
        mProgram = EglCore.createProgram(VERTEX_SHADER, FRAGMENT_SHADER_OESTEX);
        if (mProgram == 0) {
            throw new RuntimeException("failed creating program");
        }
        maPositionHandle = GLES20.glGetAttribLocation(mProgram, "aPosition");
        EglCore.checkGlError("glGetAttribLocation aPosition");
        if (maPositionHandle == -1) {
            throw new RuntimeException("Could not get attrib location for aPosition");
        }
        maTextureHandle = GLES20.glGetAttribLocation(mProgram, "aTextureCoord");
        EglCore.checkGlError("glGetAttribLocation aTextureCoord");
        if (maTextureHandle == -1) {
            throw new RuntimeException("Could not get attrib location for aTextureCoord");
        }

        muMVPMatrixHandle = GLES20.glGetUniformLocation(mProgram, "uMVPMatrix");
        EglCore.checkGlError("glGetUniformLocation uMVPMatrix");
        if (muMVPMatrixHandle == -1) {
            throw new RuntimeException("Could not get attrib location for uMVPMatrix");
        }

        muSTMatrixHandle = GLES20.glGetUniformLocation(mProgram, "uSTMatrix");
        EglCore.checkGlError("glGetUniformLocation uSTMatrix");
        if (muSTMatrixHandle == -1) {
            throw new RuntimeException("Could not get attrib location for uSTMatrix");
        }
    }

    public void setOutputResolution(int width, int height) {
        if (width == mOutputWidth && height == mOutputHeight) {
            return;
        }
        Log.d(TAG, "Output resolution change: " + mOutputWidth + "*" + mOutputHeight + " -> " + width + "*" + height);
        mOutputWidth = width;
        mOutputHeight = height;

        if (width > height) {
            Matrix.orthoM(mProjectionMatrix, 0, - 1.f, 1.f, -1f, 1f, -1f, 1f);
        } else {
            Matrix.orthoM(mProjectionMatrix, 0, -1f, 1f, -1.f, 1.f, -1f, 1f);
        }

        reloadFrameBuffer();
    }

    private void draw(int textureId) {

        GLES20.glViewport(0, 0, mOutputWidth, mOutputHeight);
        GLES20.glClearColor(0.F, 0.F, 0.F, 1.F);
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_DEPTH_BUFFER_BIT);

        GLES20.glUseProgram(mProgram);
        EglCore.checkGlError("glUseProgram");


        GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureId);

        mTriangleVertices.position(TRIANGLE_VERTICES_DATA_POS_OFFSET);
        GLES20.glVertexAttribPointer(maPositionHandle, 3, GLES20.GL_FLOAT, false,
                TRIANGLE_VERTICES_DATA_STRIDE_BYTES, mTriangleVertices);
        EglCore.checkGlError("glVertexAttribPointer maPosition");
        GLES20.glEnableVertexAttribArray(maPositionHandle);
        EglCore.checkGlError("glEnableVertexAttribArray maPositionHandle");

        mTriangleVertices.position(TRIANGLE_VERTICES_DATA_UV_OFFSET);
        GLES20.glVertexAttribPointer(maTextureHandle, 2, GLES20.GL_FLOAT, false,
                TRIANGLE_VERTICES_DATA_STRIDE_BYTES, mTriangleVertices);
        EglCore.checkGlError("glVertexAttribPointer maTextureHandle");
        GLES20.glEnableVertexAttribArray(maTextureHandle);
        EglCore.checkGlError("glEnableVertexAttribArray maTextureHandle");

        Matrix.setIdentityM(mMVPMatrix, 0);
        Matrix.setIdentityM(mModeMatrix, 0);
        Matrix.scaleM(mModeMatrix, 0, -1, 1, 1);
        Matrix.rotateM(mModeMatrix, 0, 180, 0, 0, -1);

        Matrix.multiplyMM(mMVPMatrix, 0, mProjectionMatrix, 0, mModeMatrix, 0);

        GLES20.glUniformMatrix4fv(muMVPMatrixHandle, 1, false, mMVPMatrix, 0);
        GLES20.glUniformMatrix4fv(muSTMatrixHandle, 1, false, mSTMatrix, 0);
        EglCore.checkGlError("glDrawArrays");
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);
        EglCore.checkGlError("glDrawArrays");

        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, 0);

//        GLES20.glFinish();
    }

    private void reloadFrameBuffer() {

        Log.d(TAG, "reloadFrameBuffer. size = " + mOutputWidth + "*" + mOutputHeight);
        destroyFrameBuffer();

        int[] textures = new int[1];
        int[] frameBuffers = new int[1];
        GLES20.glGenTextures(1, textures, 0);
        GLES20.glGenFramebuffers(1, frameBuffers, 0);

        mFrameBufferTextureID = textures[0];
        mFrameBufferID = frameBuffers[0];
        Log.d(TAG, "frameBuffer id = " + mFrameBufferID + ", texture id = " + mFrameBufferTextureID);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mFrameBufferTextureID);
        EglCore.checkGlError("glBindTexture mFrameBufferTextureID");
        GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, mOutputWidth, mOutputHeight, 0,
                GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, null);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER,
                GLES20.GL_LINEAR);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER,
                GLES20.GL_LINEAR);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S,
                GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T,
                GLES20.GL_CLAMP_TO_EDGE);
        EglCore.checkGlError("glTexParameter");

        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, mFrameBufferID);
        GLES20.glFramebufferTexture2D(GLES20.GL_FRAMEBUFFER, GLES20.GL_COLOR_ATTACHMENT0,
                GLES20.GL_TEXTURE_2D, mFrameBufferTextureID, 0);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);

    }

    private void destroyFrameBuffer() {
        if (mFrameBufferID != INVALID_TEXTURE_ID) {
            int[] frameID = new int[1];
            frameID[0] = mFrameBufferID;
            GLES20.glDeleteFramebuffers(1, frameID,0);
            mFrameBufferID = INVALID_TEXTURE_ID;
        }
        if (mFrameBufferTextureID != INVALID_TEXTURE_ID) {
            int[] textureID = new int[1];
            textureID[0] = mFrameBufferTextureID;
            GLES20.glDeleteTextures(1, textureID, 0);
            mFrameBufferTextureID = INVALID_TEXTURE_ID;
        }
    }

}
