package com.tencent.trtc.mediashare.helper.render.opengl;

import android.opengl.GLES11Ext;
import android.opengl.GLES20;

public class OesInputFilter extends GPUImageFilter {
    private static final String OES_INPUT_VERTEX_SHADER = ""
            + "attribute vec4 position;\n"
            + "attribute vec4 inputTextureCoordinate;\n"
            + "uniform mat4 textureTransform;\n"
            + "\n"
            + "varying highp vec2 textureCoordinate;\n"
            + "void main()\n"
            + "{\n"
            + "    gl_Position = position;\n"
            + "    textureCoordinate = (textureTransform * inputTextureCoordinate).xy;\n"
            + "}\n";

    private static final String OES_INPUT_FRAGMENT_SHADER = ""
            + "#extension GL_OES_EGL_image_external : require\n"
            + "precision mediump float;\n"
            + "varying highp vec2 textureCoordinate;\n"
            + " \n"
            + "uniform samplerExternalOES inputImageTexture;\n"
            + " \n"
            + "void main()\n"
            + "{\n"
            + "   gl_FragColor = texture2D(inputImageTexture, textureCoordinate);\n"
            + "}";

    protected int mTextureTransform;

    public OesInputFilter() {
        super(OES_INPUT_VERTEX_SHADER, OES_INPUT_FRAGMENT_SHADER);
    }

    public OesInputFilter(final String vertexShader, final String fragmentShader) {
        super(vertexShader, fragmentShader);
    }

    @Override
    public int getTarget() {
        return GLES11Ext.GL_TEXTURE_EXTERNAL_OES;
    }

    @Override
    public void onInit() {
        super.onInit();
        mTextureTransform = GLES20.glGetUniformLocation(mProgram.getProgramId(), "textureTransform");
    }

    @Override
    protected void beforeDrawArrays(int textureId) {
        super.beforeDrawArrays(textureId);
        GLES20.glUniformMatrix4fv(mTextureTransform, 1, false, mTextureMatrix, 0);
    }
}
