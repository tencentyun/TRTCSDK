package com.tencent.trtc.customcamera.helper.render.opengl;

import android.opengl.GLES20;

import com.tencent.trtc.customcamera.helper.basic.Size;

import java.nio.ByteBuffer;
import java.nio.FloatBuffer;

public class GpuImageI420Filter extends GPUImageFilter {
    private static final String I420_RENDER_SHADE = ""
            + "precision highp float;\n"
            + "varying vec2 textureCoordinate;\n"
            + "uniform sampler2D inputImageTexture;\n"
            + "uniform sampler2D uTexture;\n"
            + "uniform mat3 convertMatrix;\n"
            + "uniform vec3 offset;\n"
            + "\n"
            + "void main()\n"
            + "{\n"
            + "    highp vec3 yuvColor;\n"
            + "    highp vec3 rgbColor;\n"
            + "\n"
            + "    // Get the YUV values\n"
            + "    yuvColor.x = texture2D(inputImageTexture, textureCoordinate).r;\n"
            + "    yuvColor.y = texture2D(uTexture, vec2(textureCoordinate.x * 0.5, textureCoordinate.y * 0.5)).r;\n"
            + "    yuvColor.z = texture2D(uTexture, vec2(textureCoordinate.x * 0.5, textureCoordinate.y * 0.5 + 0.5)).r;\n"
            + "\n"
            + "    // Do the color transform   \n"
            + "    yuvColor += offset;\n"
            + "    rgbColor = convertMatrix * yuvColor; \n"
            + "\n"
            + "    gl_FragColor = vec4(rgbColor, 1.0);\n"
            + "}\n";

    // YUV offset
    private static final float[] BT601_FULLRANGE_FFMPEG_OFFSET = {
            0f, -0.501960814f, -0.501960814f
    };

    // RGB coefficients
    private static final float[] BT601_FULLRAGE_FFMPEG_MATRIX = {
            1f, 1f, 1f,
            0f, -0.3441f, 1.772f,
            1.402f, -0.7141f, 0f
    };

    private int mGLUniformTextureUv;
    private int mConvertMatrixUniform;
    private int mConvertOffsetUniform;

    private int    mYTextureId  = OpenGlUtils.NO_TEXTURE;
    private int    mUvTextureId = OpenGlUtils.NO_TEXTURE;
    private Size   mTextureSize = null;
    private byte[] mYData;
    private byte[] mUvData;

    public GpuImageI420Filter() {
        super(NO_FILTER_VERTEX_SHADER, I420_RENDER_SHADE);
    }

    @Override
    public void onInit() {
        super.onInit();
        mGLUniformTextureUv = GLES20.glGetUniformLocation(mProgram.getProgramId(), "uTexture");
        mConvertMatrixUniform = GLES20.glGetUniformLocation(mProgram.getProgramId(), "convertMatrix");
        mConvertOffsetUniform = GLES20.glGetUniformLocation(mProgram.getProgramId(), "offset");
    }

    public void loadYuvDataToTexture(byte[] yuvData, int width, int height) {
        // 纹理大小发生变化，需要重新创建纹理
        if (mTextureSize == null || mTextureSize.width != width || mTextureSize.height != height) {
            mYData = new byte[width * height];
            OpenGlUtils.deleteTexture(mYTextureId);
            mYTextureId = OpenGlUtils.NO_TEXTURE;

            mUvData = new byte[width * height / 2];
            OpenGlUtils.deleteTexture(mUvTextureId);
            mUvTextureId = OpenGlUtils.NO_TEXTURE;
        }

        // 可以使用其他方式，去除这两句拷贝。比如：在JNI加载数据。
        System.arraycopy(yuvData, 0, mYData, 0, mYData.length);
        System.arraycopy(yuvData, mYData.length, mUvData, 0, mUvData.length);
        mYTextureId = OpenGlUtils.loadTexture(GLES20.GL_LUMINANCE, ByteBuffer.wrap(mYData), width, height, mYTextureId);
        mUvTextureId = OpenGlUtils.loadTexture(GLES20.GL_LUMINANCE, ByteBuffer.wrap(mUvData), width, height / 2, mUvTextureId);
    }

    @Override
    public void onDraw(int textureId, FloatBuffer cubeBuffer, FloatBuffer textureBuffer) {
        super.onDraw(mYTextureId, cubeBuffer, textureBuffer);
    }

    @Override
    protected void beforeDrawArrays(int textureId) {
        super.beforeDrawArrays(textureId);
        GLES20.glActiveTexture(GLES20.GL_TEXTURE1);
        OpenGlUtils.bindTexture(getTarget(), mUvTextureId);
        GLES20.glUniform1i(mGLUniformTextureUv, 1);

        GLES20.glUniform3fv(mConvertOffsetUniform, 1, FloatBuffer.wrap(BT601_FULLRANGE_FFMPEG_OFFSET));
        GLES20.glUniformMatrix3fv(mConvertMatrixUniform, 1, false, BT601_FULLRAGE_FFMPEG_MATRIX, 0);
    }

    @Override
    protected void onUninit() {
        OpenGlUtils.deleteTexture(mYTextureId);
        OpenGlUtils.deleteTexture(mUvTextureId);
        super.onUninit();
    }
}
