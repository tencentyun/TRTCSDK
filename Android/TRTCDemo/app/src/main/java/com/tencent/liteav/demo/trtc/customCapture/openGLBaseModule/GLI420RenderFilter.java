package com.tencent.liteav.demo.trtc.customCapture.openGLBaseModule;

import android.opengl.GLES20;
import android.opengl.Matrix;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.ShortBuffer;

/**
 * 渲染I420数据到EGLSurface上，如果EGLSurface绑定TextureView的SurfaceTexture，就可以在TextureView上显示出来
 */
public class GLI420RenderFilter {
    private static final String TAG = GLI420RenderFilter.class.getSimpleName();

    private static final String mVertexShaderCode =
            "uniform mat4 uMatrix;" +
                    "uniform mat4 uTextureMatrix;" +
                    "attribute vec2 position;" +
                    "attribute vec2 inputTextureCoordinate;" +
                    "varying vec2 textureCoordinate;" +
                    "void main() {" +
                    "vec4 pos  = vec4(position, 0.0, 1.0);" +
                    "gl_Position = uMatrix * pos;" +
                    "textureCoordinate = (uTextureMatrix*vec4(inputTextureCoordinate, 0.0, 0.0)).xy;" +
                    "}";

    private static final String mFragmentShaderCode =
            "precision highp float;\n" +
                    "varying vec2 textureCoordinate;\n" +
                    "uniform sampler2D yTexture;\n" +
                    "uniform sampler2D uTexture;\n" +
                    "uniform mat3 convertMatrix;\n" +
                    "uniform vec3 offset;\n" +
                    "\n" +
                    "void main()\n" +
                    "{\n" +
                    "    highp vec3 yuvColor;\n" +
                    "    highp vec3 rgbColor;\n" +
                    "\n" +
                    "    // Get the YUV values\n" +
                    "    yuvColor.x = texture2D(yTexture, textureCoordinate).r;\n" +
                    "    yuvColor.y = texture2D(uTexture, vec2(textureCoordinate.x * 0.5, textureCoordinate.y * 0.5)).r;\n" +
                    "    yuvColor.z = texture2D(uTexture, vec2(textureCoordinate.x * 0.5, textureCoordinate.y * 0.5 + 0.5)).r;\n" +
                    "\n" +
                    "    // Do the color transform   \n" +
                    "    yuvColor += offset;\n" +
                    "    rgbColor = convertMatrix * yuvColor; \n" +
                    "\n" +
                    "    gl_FragColor = vec4(rgbColor, 1.0);\n" +
                    "}\n";

    private static final int BYTES_PER_FLOAT = 4;
    private static final int POSITION_COMPONENT_COUNT = 2;
    private static final int TEXTURE_COORDINATES_COMPONENT_COUNT = 2;

    private float[] mVerticesCoordinates;
    private float[] mTextureCoordinates;
    private short[] mIndices;

    private FloatBuffer mVertexBuffer;
    private FloatBuffer mTextureBuffer;
    private ShortBuffer mIndicesBuffer;


    private float[] mMVPMatrix = new float[16];
    private float[] mTextureMatrix = new float[16];
    private float[] mModeMatrix = new float[16];
    private float[] mProjectionMatrix = new float[16];

    private int[] mTextureIds;
    private int mProgram;

    private int mVertexMatrixHandle;
    private int mTextureMatrixHandle;
    private int mPositionHandle;
    private int mTextureCoordinatesHandle;
    private int mTextureUnitHandle0;
    private int mTextureUnitHandle1;

    private int mConvertMatrixUniform = -1;
    private int mConvertOffsetUniform = -1;

    // YUV offset
    float[] bt601_fullrange_ffmpeg_offset = {
            0f, -0.501960814f, -0.501960814f
    };

    // RGB coefficients
    float[] bt601_fullrage_ffmpeg_matrix = {
            1f, 1f, 1f,
            0f,  -0.3441f,   1.772f,
            1.402f,  -0.7141f,   0f
    };

    public GLI420RenderFilter() {
        mTextureCoordinates = new float[]{
                0.0f, 1f,
                1f, 1f,
                0.0f, 0.0f,
                1f, 0.0f};

        mIndices = new short[]{0, 1, 2, 1, 3, 2};

        mVerticesCoordinates = new float[]{
                -1f, -1f,
                1f, -1f,
                -1f, 1f,
                1f, 1f,
        };

        mTextureBuffer = ByteBuffer.allocateDirect(mTextureCoordinates.length * 4).order(ByteOrder.nativeOrder()).asFloatBuffer();
        mTextureBuffer.put(mTextureCoordinates);
        mTextureBuffer.position(0);

        mVertexBuffer = ByteBuffer.allocateDirect(mVerticesCoordinates.length * 4).order(ByteOrder.nativeOrder()).asFloatBuffer();
        mVertexBuffer.put(mVerticesCoordinates);
        mVertexBuffer.position(0);

        mIndicesBuffer = ByteBuffer.allocateDirect(mIndices.length * 2).order(ByteOrder.nativeOrder()).asShortBuffer();
        mIndicesBuffer.put(mIndices);
        mIndicesBuffer.position(0);

        createTexture();
    }

    private void createTexture() {
        int vertexShader = GLES20.glCreateShader(GLES20.GL_VERTEX_SHADER);
        checkError();
        GLES20.glShaderSource(vertexShader, mVertexShaderCode);
        checkError();
        GLES20.glCompileShader(vertexShader);
        checkError();

        int fragmentShader = GLES20.glCreateShader(GLES20.GL_FRAGMENT_SHADER);
        checkError();
        GLES20.glShaderSource(fragmentShader, mFragmentShaderCode);
        checkError();
        GLES20.glCompileShader(fragmentShader);

        mProgram = GLES20.glCreateProgram();
        checkError();
        GLES20.glAttachShader(mProgram, vertexShader);
        checkError();
        GLES20.glAttachShader(mProgram, fragmentShader);
        checkError();
        GLES20.glLinkProgram(mProgram);
        checkError();

        GLES20.glDeleteShader(vertexShader);
        GLES20.glDeleteShader(fragmentShader);

        mVertexMatrixHandle = GLES20.glGetUniformLocation(mProgram, "uMatrix");
        checkError();
        mTextureMatrixHandle = GLES20.glGetUniformLocation(mProgram, "uTextureMatrix");
        checkError();
        mPositionHandle = GLES20.glGetAttribLocation(mProgram, "position");
        checkError();
        mTextureCoordinatesHandle = GLES20.glGetAttribLocation(mProgram, "inputTextureCoordinate");
        checkError();
        mTextureUnitHandle0 = GLES20.glGetUniformLocation(mProgram, "yTexture");
        checkError();
        mTextureUnitHandle1 = GLES20.glGetUniformLocation(mProgram, "uTexture");
        checkError();
        mConvertOffsetUniform = GLES20.glGetUniformLocation(mProgram, "offset");
        GLES20.glUniform3fv(mConvertOffsetUniform, 1, FloatBuffer.wrap(bt601_fullrange_ffmpeg_offset));

        mConvertMatrixUniform = GLES20.glGetUniformLocation(mProgram, "convertMatrix");
        GLES20.glUniformMatrix3fv(mConvertMatrixUniform, 1, false, bt601_fullrage_ffmpeg_matrix, 0);

        mTextureIds = new int[2];
        GLES20.glGenTextures(2, mTextureIds, 0);
//        checkError();
    }

    public void release() {
        if (mTextureIds != null) {
            GLES20.glDeleteTextures(2, mTextureIds, 0);
            mTextureIds = null;
        }

        GLES20.glDeleteProgram(mProgram);
    }


    public void drawFrame(ByteBuffer yData, ByteBuffer uvData, int videoWidth, int videoHeight, int viewWidth, int viewHeight) {

        GLES20.glViewport(0, 0, viewWidth, viewHeight);
        GLES20.glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        GLES20.glClear(GLES20.GL_DEPTH_BUFFER_BIT | GLES20.GL_COLOR_BUFFER_BIT);

        Matrix.setIdentityM(mMVPMatrix, 0);
        //纹理坐标
        Matrix.setIdentityM(mTextureMatrix, 0);

        GLES20.glUseProgram(mProgram);
        checkError();

        GLES20.glEnableVertexAttribArray(mPositionHandle);
        checkError();
        mVertexBuffer.position(0);
        GLES20.glVertexAttribPointer(mPositionHandle, POSITION_COMPONENT_COUNT, GLES20.GL_FLOAT, false, POSITION_COMPONENT_COUNT * BYTES_PER_FLOAT, mVertexBuffer);
        checkError();

        GLES20.glEnableVertexAttribArray(mTextureCoordinatesHandle);
        checkError();
        mTextureBuffer.position(0);
        GLES20.glVertexAttribPointer(mTextureCoordinatesHandle, TEXTURE_COORDINATES_COMPONENT_COUNT, GLES20.GL_FLOAT, false, TEXTURE_COORDINATES_COMPONENT_COUNT * BYTES_PER_FLOAT, mTextureBuffer);
        checkError();

        Matrix.setIdentityM(mMVPMatrix, 0);
        fill(mMVPMatrix, videoWidth, videoHeight, viewWidth, viewHeight);

        GLES20.glUniformMatrix4fv(mVertexMatrixHandle, 1, false, mMVPMatrix, 0);
        checkError();

        GLES20.glUniformMatrix4fv(mTextureMatrixHandle, 1, false, mTextureMatrix, 0);
        checkError();

        GLES20.glUniform3fv(mConvertOffsetUniform, 1, FloatBuffer.wrap(bt601_fullrange_ffmpeg_offset));
        GLES20.glUniformMatrix3fv(mConvertMatrixUniform, 1, false, bt601_fullrage_ffmpeg_matrix, 0);

        GLES20.glUniform1i(mTextureUnitHandle0, 0);
        checkError();

        GLES20.glUniform1i(mTextureUnitHandle1, 1);
        checkError();

        GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mTextureIds[0]);

        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_LUMINANCE, videoWidth, videoHeight, 0, GLES20.GL_LUMINANCE, GLES20.GL_UNSIGNED_BYTE, yData);

        GLES20.glActiveTexture(GLES20.GL_TEXTURE1);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mTextureIds[1]);

        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_LUMINANCE, videoWidth, videoHeight/2, 0, GLES20.GL_LUMINANCE, GLES20.GL_UNSIGNED_BYTE, uvData);

        GLES20.glDrawElements(GLES20.GL_TRIANGLES, mIndices.length,
                GLES20.GL_UNSIGNED_SHORT, mIndicesBuffer);

        GLES20.glDisableVertexAttribArray(mPositionHandle);
        GLES20.glDisableVertexAttribArray(mTextureCoordinatesHandle);
    }

    public int checkError() {
        int error = GLES20.glGetError();
        if (error != GLES20.GL_NO_ERROR) {
            throw new IllegalStateException("gl error=" + error);
        }
        return error;
    }

    private void fill(float[] MVPMatrix, int videoWidth, int videoHeight, int viewWidth, int viewHeight) {

        int scaleWidth  = videoWidth;
        int scaleHeight = videoHeight;

        float ratioWidth  =  viewWidth  * 1.0f / scaleWidth;
        float ratioHeight =  viewHeight * 1.0f / scaleHeight;

        float ratio;
        if (ratioWidth * scaleHeight > viewHeight) {
            ratio = ratioHeight;
        } else {
            ratio = ratioWidth;
        }

        Matrix.setIdentityM(mModeMatrix, 0);
        Matrix.scaleM(mModeMatrix, 0, scaleWidth * ratio / viewWidth * 1.0f , scaleHeight * ratio / viewHeight * 1.0f, 1);

        if (viewWidth > viewHeight) {
            Matrix.orthoM(mProjectionMatrix, 0, - 1f, 1f, -1f, 1f, -1f, 1f);
        } else {
            Matrix.orthoM(mProjectionMatrix, 0, -1f, 1f, -1f, 1f, -1f, 1f);
        }
        Matrix.multiplyMM(MVPMatrix, 0, mProjectionMatrix, 0, mModeMatrix, 0);
    }

}
