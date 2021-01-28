//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#include "TestScreenSharing.h"
#include "ui_TestScreenSharing.h"
#include <QLineEdit>
#include <QComboBox>
#include <QGuiApplication>
#include <QWindow>
#include <QElapsedTimer>

TestScreenSharing::TestScreenSharing(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::TestScreenSharing) {
    ui->setupUi(this);
    m_trtcCloud = getTRTCShareInstance();

#ifdef __APPLE__
    m_thumbSize.width = 300;
    m_thumbSize.height = 200;
#endif

#ifdef _WIN32
    m_thumbSize.cx = 300;
    m_thumbSize.cy = 200;
#endif

    setupVideoResMap();
}

TestScreenSharing::~TestScreenSharing() {
    delete ui;
}

void TestScreenSharing::on_startScreenCaptureButton_clicked(bool checked) {
    if (checked) {
        if (updateVideoEncParam() == false) {
            ui->startScreenCaptureButton->setChecked(false);
            return;
        }

        updateScreenCaptureTarget();
        m_trtcCloud->startScreenCapture(nullptr, trtc::TRTCVideoStreamTypeSub, &m_videoEncParam);
        ui->pauseScreenCaptureBox->setEnabled(true);
        ui->screenCaptureSourceType->setEnabled(false);
    } else {
        stopScreenCapture();
    }
}

void TestScreenSharing::updateScreenCaptureTarget() {
    if (ui->startScreenCaptureButton->isChecked() == false) return;

    updateRECT();
    updateScreenCaptureProperty();
    trtc::ITRTCScreenCaptureSourceList *sourceList = m_trtcCloud->getScreenCaptureSources(m_thumbSize, m_thumbSize);
    if (sourceList != nullptr) {
        trtc::TRTCScreenCaptureSourceInfo info =
                sourceList->getSourceInfo(static_cast<uint32_t>((ui->screenCaptureSources->currentIndex())));
        info.type = getScreenCaptureSourceType();
        m_trtcCloud->selectScreenCaptureTarget(info, m_rect, m_property);
    }
    sourceList->release();
}

void TestScreenSharing::updateScreenCaptureSources() {
    trtc::ITRTCScreenCaptureSourceList *sourceList = m_trtcCloud->getScreenCaptureSources(m_thumbSize, m_thumbSize);
    QComboBox *screenCaptureSources = ui->screenCaptureSources;
    screenCaptureSources->clear();
    uint32_t count = sourceList->getCount();
    for (uint32_t i = 0; i < count; i++) {
        trtc::TRTCScreenCaptureSourceInfo info = sourceList->getSourceInfo(i);
        const char *name = info.sourceName;
        trtc::TRTCImageBuffer iconBGRA = info.iconBGRA;
        QIcon icon = QIcon(iconBGRA.buffer);
        screenCaptureSources->addItem(icon, name);
    }
    sourceList->release();
}

void TestScreenSharing::on_selectScreenCaptureTarget_clicked() {
    if (ui->startScreenCaptureButton->isChecked()) {
        updateScreenCaptureTarget();
    } else {
        m_messageTipDialog.showMessageTip("请您确认已开始屏幕分享");
    }
}

void TestScreenSharing::on_pauseScreenCaptureBox_clicked(bool checked) {
    if (checked) {
        m_trtcCloud->pauseScreenCapture();
    } else {
        m_trtcCloud->resumeScreenCapture();
    }
}

void TestScreenSharing::on_addExcludedShareWindow_clicked(bool checked) {
    int index = ui->windowListBox->currentIndex();
    trtc::TXView viewId = m_windowList.at(index);
    QVector<trtc::TXView> windowList = m_windowList;
    m_trtcCloud->addExcludedShareWindow(viewId);
}

void TestScreenSharing::on_removeExcludedShareWindow_clicked(bool checked) {
    trtc::TXView viewId = m_windowList.at(ui->windowListBox->currentIndex());
    m_trtcCloud->removeExcludedShareWindow(viewId);
}

void TestScreenSharing::on_removeAllExcludedShareWindow_clicked(bool checked) {
    m_trtcCloud->removeAllExcludedShareWindow();
}

void TestScreenSharing::on_screenCaptureMixVolumeSlider_valueChanged(int value) {
    m_trtcCloud->setSubStreamMixVolume(static_cast<uint32_t>(value));
}

inline void TestScreenSharing::updateRECT() {
    m_rect.top = ui->top->text().toInt();
    m_rect.left = ui->left->text().toInt();
    m_rect.right = ui->right->text().toInt();
    m_rect.bottom = ui->bottom->text().toInt();
}

bool TestScreenSharing::updateVideoEncParam() {
    uint32_t videoFps = ui->videoFps->text().toUInt();
    uint32_t videoBitrate = ui->videoBitrate->text().toUInt();
    int minVideoBitrate = ui->minVideoBitrate->text().toInt();
    if (videoFps < 1) {
        m_messageTipDialog.showMessageTip("请您设置一个合理的视频采集帧率，单位fps");
        return false;
    } else if (videoBitrate == 0) {
        m_messageTipDialog.showMessageTip("请您设置一个合理的目标视频码率，单位kbps");
        return false;
    } else if (minVideoBitrate < 0) {
        m_messageTipDialog.showMessageTip("请您设置一个合理的最低视频码率，单位kbps");
        return false;
    }

    m_videoEncParam.videoFps = videoFps;
    m_videoEncParam.videoBitrate = videoBitrate;
    m_videoEncParam.minVideoBitrate = static_cast<uint32_t>(minVideoBitrate);

    bool enableAdjustRes = ui->enableAdjustRes->isChecked();
    int index = ui->videoResolution->currentIndex();
    int resMode = ui->resMode->currentIndex();
    m_videoEncParam.resMode = static_cast<trtc::TRTCVideoResolutionMode>(resMode);
    m_videoEncParam.videoResolution = getVideoResolutionFromMap(index);
    m_videoEncParam.enableAdjustRes = enableAdjustRes;

    // 设置屏幕分享的编码器参数
    m_trtcCloud->setSubStreamEncoderParam(m_videoEncParam);

    return true;
}

inline trtc::TRTCScreenCaptureSourceType TestScreenSharing::getScreenCaptureSourceType() {
    int index = ui->screenCaptureSourceType->currentIndex();
    return static_cast<trtc::TRTCScreenCaptureSourceType>(index);
}

inline void TestScreenSharing::updateScreenCaptureProperty() {
    m_property.enableHighPerformance = ui->enableHighPerformance->isChecked();
    m_property.enableCaptureMouse = ui->enableCaptureMouse->isChecked();
    m_property.enableHighLight = ui->enableHighLight->isChecked();
    if (m_property.enableHighLight) {
        m_property.highLightColor = 996996; // foo
        m_property.highLightWidth = 25;
    }
}

inline trtc::TRTCVideoResolution TestScreenSharing::getVideoResolutionFromMap(int index) {
    return m_videoResolutionMap.value(index);
}

void TestScreenSharing::setupVideoResMap() {
    // 宽高比1:1
    m_videoResolutionMap.insert(0, trtc::TRTCVideoResolution_120_120);
    m_videoResolutionMap.insert(1, trtc::TRTCVideoResolution_160_160);
    m_videoResolutionMap.insert(2, trtc::TRTCVideoResolution_270_270);
    m_videoResolutionMap.insert(3, trtc::TRTCVideoResolution_480_480);
    // 宽高比4:3
    m_videoResolutionMap.insert(4, trtc::TRTCVideoResolution_160_120);
    m_videoResolutionMap.insert(5, trtc::TRTCVideoResolution_240_180);
    m_videoResolutionMap.insert(6, trtc::TRTCVideoResolution_280_210);
    m_videoResolutionMap.insert(7, trtc::TRTCVideoResolution_320_240);
    m_videoResolutionMap.insert(8, trtc::TRTCVideoResolution_400_300);
    m_videoResolutionMap.insert(9, trtc::TRTCVideoResolution_480_360);
    m_videoResolutionMap.insert(10, trtc::TRTCVideoResolution_640_480);
    m_videoResolutionMap.insert(11, trtc::TRTCVideoResolution_960_720);
    // 宽高比16:9
    m_videoResolutionMap.insert(12, trtc::TRTCVideoResolution_160_90);
    m_videoResolutionMap.insert(13, trtc::TRTCVideoResolution_256_144);
    m_videoResolutionMap.insert(14, trtc::TRTCVideoResolution_320_180);
    m_videoResolutionMap.insert(15, trtc::TRTCVideoResolution_480_270);
    m_videoResolutionMap.insert(16, trtc::TRTCVideoResolution_640_360);
    m_videoResolutionMap.insert(17, trtc::TRTCVideoResolution_960_540);
    // [S] 屏幕分享   - 建议码率：低清：1000kbps 高清：1600kbps
    m_videoResolutionMap.insert(18, trtc::TRTCVideoResolution_1280_720);
    // [S] 屏幕分享   - 建议码率2000kbps
    m_videoResolutionMap.insert(19, trtc::TRTCVideoResolution_1920_1080);
}

void TestScreenSharing::updateScreenShareSources() {
    // FOO
    QElapsedTimer time;
    time.start();
    while (time.elapsed() < 100) {
        QCoreApplication::processEvents();
    }

    enumAllWindows();
    updateScreenCaptureSources();
}

void TestScreenSharing::enumAllWindows() {
    m_windowList.clear();
    ui->windowListBox->clear();

    trtc::ITRTCScreenCaptureSourceList *sourceList = m_trtcCloud->getScreenCaptureSources(m_thumbSize, m_thumbSize);
    QComboBox *windowListBox = ui->windowListBox;
    uint32_t count = sourceList->getCount();
    for (uint32_t i = 0; i < count; i++) {
        trtc::TRTCScreenCaptureSourceInfo info = sourceList->getSourceInfo(i);
        const char *name = info.sourceName;
        trtc::TRTCImageBuffer iconBGRA = info.iconBGRA;
        QIcon icon = QIcon(iconBGRA.buffer);
        windowListBox->addItem(icon, name);

        trtc::TXView sourceId = info.sourceId;
        m_windowList.push_back(sourceId);
    }
    sourceList->release();
}

void TestScreenSharing::closeEvent(QCloseEvent *event) {
    hide();
    stopScreenCapture();
}

void TestScreenSharing::stopScreenCapture() {
    m_trtcCloud->stopScreenCapture();
    ui->startScreenCaptureButton->setChecked(false);
    ui->pauseScreenCaptureBox->setEnabled(false);
    ui->pauseScreenCaptureBox->setChecked(false);
    ui->screenCaptureSourceType->setEnabled(true);
}

/// 更新：分享目标
void TestScreenSharing::on_screenCaptureSources_currentIndexChanged(int index) {
    updateScreenCaptureProperty();
    updateScreenCaptureTarget();
}

/// 更新：分享类型
void TestScreenSharing::on_screenCaptureSourceType_currentIndexChanged(int index) {
    bool isShareingScreen = index == 1;
    ui->windowListBox->setEnabled(isShareingScreen);
    ui->addExcludedShareWindow->setEnabled(isShareingScreen);
    ui->removeExcludedShareWindow->setEnabled(isShareingScreen);
    ui->removeAllExcludedShareWindow->setEnabled(isShareingScreen);
}
