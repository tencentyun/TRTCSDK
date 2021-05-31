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
    // 显示一帧Yuv图像
    void slotShowYuv(uchar *ptr, uint width, uint height);
    static void lock();
    static void unlock();

 protected:
    void initializeGL() Q_DECL_OVERRIDE;
    void paintGL() Q_DECL_OVERRIDE;

 private:
    QOpenGLBuffer vbo;
    // opengl中y、u、v分量位置
    GLint textureUniformY, textureUniformU, textureUniformV;
    QOpenGLTexture *textureY = nullptr, *textureU = nullptr, *textureV = nullptr;
    // 自己创建的纹理对象ID，创建错误返回0
    GLuint idY, idU, idV;
    GLint videoW, videoH;
    uchar *yuvPtr = nullptr;
    QOpenGLShaderProgram program;
};

#endif  // QTMACDEMO_BASE_GLYUVWIDGET_H_
