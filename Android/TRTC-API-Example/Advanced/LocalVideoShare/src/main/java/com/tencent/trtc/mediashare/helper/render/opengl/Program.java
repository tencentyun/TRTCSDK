package com.tencent.trtc.mediashare.helper.render.opengl;

import android.opengl.GLES20;
import android.util.Log;

public class Program {
    private static final String TAG                = "Program";
    private static final int    INVALID_PROGRAM_ID = -1;

    private final String mVertexShader;
    private final String mFragmentShader;
    private       int    mProgramId;

    public Program(String vertexShader, String fragmentShader) {
        mVertexShader = vertexShader;
        mFragmentShader = fragmentShader;
        mProgramId = INVALID_PROGRAM_ID;
    }

    public void build() {
        int   vertexShaderId, fragmentShaderId, programId;
        int[] link = new int[1];

        vertexShaderId = loadShader(mVertexShader, GLES20.GL_VERTEX_SHADER);
        if (vertexShaderId == 0) {
            Log.e(TAG, "load vertex shader failed.");
            return;
        }

        fragmentShaderId = loadShader(mFragmentShader, GLES20.GL_FRAGMENT_SHADER);
        if (fragmentShaderId == 0) {
            Log.e(TAG, "load fragment shader failed.");
            return;
        }

        programId = GLES20.glCreateProgram();
        GLES20.glAttachShader(programId, vertexShaderId);
        GLES20.glAttachShader(programId, fragmentShaderId);
        GLES20.glLinkProgram(programId);

        GLES20.glGetProgramiv(programId, GLES20.GL_LINK_STATUS, link, 0);
        if (link[0] <= 0) {
            Log.e(TAG, "link program failed. status: " + link[0]);
            return;
        }

        GLES20.glDeleteShader(vertexShaderId);
        GLES20.glDeleteShader(fragmentShaderId);
        mProgramId = programId;
    }

    public int getProgramId() {
        return mProgramId;
    }

    public void destroy() {
        GLES20.glDeleteProgram(mProgramId);
        mProgramId = INVALID_PROGRAM_ID;
    }

    private int loadShader(final String strSource, final int iType) {
        int[] compiled = new int[1];
        int   iShader  = GLES20.glCreateShader(iType);
        GLES20.glShaderSource(iShader, strSource);
        GLES20.glCompileShader(iShader);
        GLES20.glGetShaderiv(iShader, GLES20.GL_COMPILE_STATUS, compiled, 0);
        if (compiled[0] == 0) {
            OpenGlUtils.checkGlError("glCompileShader");
            return 0;
        }
        return iShader;
    }
}
