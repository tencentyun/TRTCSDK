//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#include "gl_yuv_widget.h"
#include <QOpenGLTexture>
#include <mutex>
#include <exception>

#ifdef __APPLE__
#include <glext.h>
#endif
#ifdef _WIN32
#include<GL/GL.h>
#include <GL/GLU.h>
#endif

#define VERTEXIN  0
#define TEXTUREIN 1

static std::mutex gl_mutex;

static GLfloat vertices[] {
    // Vertex coordinates
    -1.0f, -1.0f,
    1.0f, -1.0f,
    -1.0f, 1.0f,
    1.0f, 1.0f,
    // Texture coordinates
    0.0f, 1.0f - 0.0f,
    1.0f, 1.0f - 0.0f,
    0.0f, 1.0f - 1.0f,
    1.0f, 1.0f - 1.0f,
};

GLYuvWidget::GLYuvWidget(QWidget *parent) :
    QOpenGLWidget(parent) {
    yuvPtr = static_cast<uchar *>(malloc(sizeof(char) * 1920 * 1080 * 3 / 2));
    videoWH_max = 1920 * 1080;
}

GLYuvWidget::~GLYuvWidget() {
    makeCurrent();
    vbo.destroy();

    if (textureY != nullptr) textureY->destroy();
    if (textureU != nullptr) textureY->destroy();
    if (textureV != nullptr) textureY->destroy();

    if (yuvPtr != nullptr) free(yuvPtr);

    doneCurrent();
}

void GLYuvWidget::slotShowYuv(uchar *ptr, uint width, uint height) {
    if (width * height > videoWH_max) {
        if (yuvPtr != nullptr) {
            free(yuvPtr);
        }
        videoWH_max = width * height;
        yuvPtr = static_cast<uchar*>(malloc(sizeof(char) * videoWH_max * 3 / 2));
    }
    memcpy(yuvPtr, ptr, sizeof(char) * width * height * 3 / 2);
    videoW = static_cast<GLint>(width);
    videoH = static_cast<GLint>(height);
    update();
}

void GLYuvWidget::lock() {
    gl_mutex.lock();
}

void GLYuvWidget::unlock() {
    gl_mutex.unlock();
}

void GLYuvWidget::initializeGL() {
    initializeOpenGLFunctions();
    glEnable(GL_DEPTH_TEST);
    vbo.create();
    vbo.bind();
    vbo.allocate(vertices, sizeof(vertices));

    QOpenGLShader vshader(QOpenGLShader::Vertex);
    const char *vsrc =
   "attribute vec2 vertexIn; \
    attribute vec2 textureIn; \
    varying vec2 textureOut;  \
    void main(void)           \
    {                         \
        gl_Position = vec4(vertexIn, 0.0, 1.0); \
        textureOut = textureIn; \
    }";
    vshader.compileSourceCode(vsrc);

    QOpenGLShader fshader(QOpenGLShader::Fragment, this);
    const char *fsrc = "varying vec2 textureOut; \
    uniform sampler2D tex_y; \
    uniform sampler2D tex_u; \
    uniform sampler2D tex_v; \
    void main(void) \
    { \
        vec3 yuv; \
        vec3 rgb; \
        yuv.x = texture2D(tex_y, textureOut).r; \
        yuv.y = texture2D(tex_u, textureOut).r - 0.5; \
        yuv.z = texture2D(tex_v, textureOut).r - 0.5; \
        rgb = mat3(1, 1, 1, \
                    0, -0.39465, 2.03211, \
                    1.13983, -0.58060, 0) * yuv; \
        gl_FragColor = vec4(rgb, 1); \
    }";
    fshader.compileSourceCode(fsrc);

    QOpenGLShaderProgram program(this);
    program.addShader(&vshader);
    program.addShader(&fshader);
    program.bindAttributeLocation("vertexIn", VERTEXIN);
    program.bindAttributeLocation("textureIn", TEXTUREIN);
    program.link();
    program.bind();
    program.enableAttributeArray(VERTEXIN);
    program.enableAttributeArray(TEXTUREIN);

    program.setAttributeBuffer(VERTEXIN,
                               GL_FLOAT,
                               0,
                               2,
                               2 * sizeof(GLfloat));
    program.setAttributeBuffer(TEXTUREIN, GL_FLOAT,
                               8 * sizeof(GLfloat),
                               2,
                               2 * sizeof(GLfloat));

    textureUniformY = static_cast<GLint>(program.uniformLocation("tex_y"));
    textureUniformU = static_cast<GLint>(program.uniformLocation("tex_u"));
    textureUniformV = static_cast<GLint>(program.uniformLocation("tex_v"));
    textureY = new QOpenGLTexture(QOpenGLTexture::Target2D);
    textureU = new QOpenGLTexture(QOpenGLTexture::Target2D);
    textureV = new QOpenGLTexture(QOpenGLTexture::Target2D);
    textureY->create();
    textureU->create();
    textureV->create();
    idY = textureY->textureId();
    idU = textureU->textureId();
    idV = textureV->textureId();
    glClearColor(0.0, 0.0, 0.0, 0.0);
}

void GLYuvWidget::paintGL() {
    gl_mutex.lock();

    glUseProgram(program.programId());
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, idY);

    if (yuvPtr != nullptr) {
        glTexImage2D(GL_TEXTURE_2D, 0,
                     GL_RED,
                     videoW,
                     videoH,
                     0,
                     GL_RED,
                     GL_UNSIGNED_BYTE,
                     yuvPtr);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, idU);

        glTexImage2D(GL_TEXTURE_2D,
                     0,
                     GL_RED,
                     videoW >> 1,
                     videoH >> 1,
                     0,
                     GL_RED,
                     GL_UNSIGNED_BYTE,
                     yuvPtr + videoW * videoH);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, idV);

        double tmp = static_cast<double>(videoW * videoH * 5) / 4.0;
        const GLvoid* pixels = yuvPtr + static_cast<int>(tmp);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RED,
                     videoW >> 1,
                     videoH >> 1,
                     0,
                     GL_RED,
                     GL_UNSIGNED_BYTE,
                     pixels);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }

    glUniform1i(textureUniformY, 0);
    glUniform1i(textureUniformU, 1);
    glUniform1i(textureUniformV, 2);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    gl_mutex.unlock();
}
