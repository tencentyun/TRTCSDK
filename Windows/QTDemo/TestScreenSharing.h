//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef TESTSCREENSHARING_H
#define TESTSCREENSHARING_H

#include <QDialog>
#include "ITRTCCloud.h"
#include "base/GLYuvWidget.h"
#include "base/AlertDialog.h"

using namespace trtc;

namespace Ui {
class TestScreenSharing;
}

/// 屏幕分享
class TestScreenSharing : public QDialog {
    Q_OBJECT

public:
    explicit TestScreenSharing(QWidget *parent = nullptr);
    ~TestScreenSharing() override;

    void updateScreenShareSources();
    void stopScreenCapture();
    void closeEvent(QCloseEvent *event) override;

private slots:
    void on_startScreenCaptureButton_clicked(bool checked);
    void on_selectScreenCaptureTarget_clicked();
    void on_pauseScreenCaptureBox_clicked(bool checked);
    void on_screenCaptureMixVolumeSlider_valueChanged(int value);
    void on_screenCaptureSources_currentIndexChanged(int index);

    void on_addExcludedShareWindow_clicked(bool checked);
    void on_removeExcludedShareWindow_clicked(bool checked);
    void on_removeAllExcludedShareWindow_clicked(bool checked);
    void on_screenCaptureSourceType_currentIndexChanged(int index);

private:
    Ui::TestScreenSharing *ui;
    trtc::ITRTCCloud *m_trtcCloud;

    SIZE m_thumbSize;
    RECT m_rect;
    trtc::TRTCScreenCaptureProperty m_property;
    AlertDialog m_messageTipDialog;
    trtc::TRTCVideoEncParam m_videoEncParam;

    QHash<int, trtc::TRTCVideoResolution> m_videoResolutionMap;
    QVector<trtc::TXView> m_windowList;

    void setupVideoResMap();
    trtc::TRTCScreenCaptureSourceType getScreenCaptureSourceType();
    trtc::TRTCVideoResolution getVideoResolutionFromMap(int index);

    // 枚举所有的窗口
    void enumAllWindows();
    void updateRECT();
    bool updateVideoEncParam();
    void updateScreenCaptureProperty();
    void updateScreenCaptureSources(void);
    void updateScreenCaptureTarget(void);
};

#endif // TESTSCREENSHARING_H
