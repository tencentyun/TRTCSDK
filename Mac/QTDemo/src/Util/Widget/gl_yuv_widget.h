//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef QTMACDEMO_BASE_GLYUVWIDGET_H_
#define QTMACDEMO_BASE_GLYUVWIDGET_H_

#include <QOpenGLWidget>
#include <QOpenGLFunctions>
#include <QOpenGLBuffer>
#include <QOpenGLShaderProgram>

QT_FORWARD_DECLARE_CLASS(QOpenGLShaderProgram)
QT_FORWARD_DECLARE_CLASS(QOpenGLTexture)

class GLYuvWidget : public QOpenGLWidget, protected QOpenGLFunctions {
    Q_OBJECT

 public:
    explicit GLYuvWidget(QWidget *parent = nullptr);
    ~GLYuvWidget() override;

 public slots:
    // Display a frame of YUV image
    void slotShowYuv(uchar *ptr, uint width, uint height);
    static void lock();
    static void unlock();

 protected:
    void initializeGL() Q_DECL_OVERRIDE;
    void paintGL() Q_DECL_OVERRIDE;

 private:
    QOpenGLBuffer vbo;
    // The Y, U, and V values in OpenGL
    GLint textureUniformY, textureUniformU, textureUniformV;
    QOpenGLTexture *textureY = nullptr, *textureU = nullptr, *textureV = nullptr;
    // ID of the texture object created by yourself. 0 indicates creation error.
    GLuint idY, idU, idV;
    GLint videoW, videoH;
    GLuint videoWH_max;
    uchar *yuvPtr = nullptr;
    QOpenGLShaderProgram program;
};

#endif  // QTMACDEMO_BASE_GLYUVWIDGET_H_
