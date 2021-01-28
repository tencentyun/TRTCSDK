//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#include "TestVideoSetting.h"
#include "ui_TestVideoSetting.h"
#include <QFileDialog>

TestVideoSetting::TestVideoSetting(QWidget *parent) : QDialog(parent), ui(new Ui::TestVideoSetting) {
    ui->setupUi(this);

    m_trtcCloud = getTRTCShareInstance();
    if (m_trtcCloud == nullptr) return;

    setupVideoResMap();
}

TestVideoSetting::~TestVideoSetting() {
    delete ui;
}

void TestVideoSetting::on_setWaterMarkBtn_clicked(bool checked) {
    if (checked) {
        // Support: BMP、GIF、JPEG、PNG、TIFF、Exif、WMF、EMF
        QString fileName = QFileDialog::getOpenFileName(this, tr("Open File"), "/Desktop", tr("Images (*.png *.gif *.jpg *.jpeg *.bmp *.tiff *.exif *.wmf *.emf)"));
        if (QFileInfo(fileName).isFile()) {
            std::string stdName = fileName.toStdString();
            m_trtcCloud->setWaterMark(trtc::TRTCVideoStreamTypeBig, stdName.c_str(), trtc::TRTCWaterMarkSrcTypeFile, 400, 200,
                                      static_cast<float>(0.3),
                                      static_cast<float>(0.6),
                                      static_cast<float>(0.2));
        } else {
            ui->setWaterMarkBtn->setChecked(false);
        }
    } else {
        m_trtcCloud->setWaterMark(trtc::TRTCVideoStreamTypeBig, nullptr, trtc::TRTCWaterMarkSrcTypeFile, 0, 0, 0, 0, 0);
    }
}

void TestVideoSetting::setRenderView(QWidget *renderView) {
    m_renderView = renderView;
}

void TestVideoSetting::setUserIds(const QVector<QString> &userIds) {
    m_userIds = userIds;
}

void TestVideoSetting::on_localFillModeComboBox_currentIndexChanged(int index) {
    trtc::TRTCRenderParams params;
    params.mirrorType = trtc::TRTCVideoMirrorType_Enable;
    params.fillMode = index == 0 ? trtc::TRTCVideoFillMode_Fill : trtc::TRTCVideoFillMode_Fit;
    m_trtcCloud->setLocalRenderParams(params);
}

void TestVideoSetting::on_remoteFillModeComboBox_currentIndexChanged(int index) {
    for (int i = 1; i < m_userIds.count(); i++) {
        trtc::TRTCRenderParams params;
        params.mirrorType = trtc::TRTCVideoMirrorType_Enable;
        params.fillMode = index == 0 ? trtc::TRTCVideoFillMode_Fill : trtc::TRTCVideoFillMode_Fit;
        std::string stdUid = m_userIds.at(i).toStdString();
        m_trtcCloud->setRemoteRenderParams(stdUid.c_str(), trtc::TRTCVideoStreamTypeBig, params);
    }
}

void TestVideoSetting::on_camComboBox_currentIndexChanged(int index) {
    // 选择摄像头
    trtc::ITXDeviceManager *manager = m_trtcCloud->getDeviceManager ();
    if (manager == nullptr) return;

    const char *pid = "";
    trtc::ITXDeviceCollection *deviceCollection = manager->getDevicesList(trtc::TXMediaDeviceTypeCamera);
    for (uint32_t i = 0; i < deviceCollection->getCount(); i++) {
        if (index == static_cast<int>(i)) {
            pid = deviceCollection->getDevicePID(i);
        }
    }
    manager->setCurrentDevice(trtc::TXMediaDeviceTypeCamera, pid);
    deviceCollection->release();
}

void TestVideoSetting::on_videoResolution_currentIndexChanged(int index) {
    updateVideoEncoderParams();
}

void TestVideoSetting::on_fpsComboBox_currentIndexChanged(int index) {
    updateVideoEncoderParams();
}

void TestVideoSetting::on_resComboBox_currentIndexChanged(int index) {
    updateVideoEncoderParams();
}

void TestVideoSetting::on_bitrateSlider_valueChanged(int value) {
    updateVideoEncoderParams();
}

void TestVideoSetting::updateVideoEncoderParams() {
    QHash<int, trtc::TRTCVideoResolution> map = m_videoResMap;
    trtc::TRTCVideoResolution res  = m_videoResMap.value(ui->videoResolution->currentIndex());
    trtc::TRTCVideoResolutionMode resMode = static_cast<trtc::TRTCVideoResolutionMode>(ui->resComboBox->currentIndex());
    uint32_t videoFps = ui->fpsComboBox->currentIndex() == 0 ? 15 : 20;
    uint32_t bitrate = static_cast<uint32_t>(ui->bitrateSlider->value());

    QString bitrateText("Bitrate ");
    bitrateText = bitrateText.append(QString::number(bitrate));
    bitrateText = bitrateText.append("kbps: ");
    ui->videoBitrate->setText(bitrateText);

    trtc::TRTCVideoEncParam params;
    params.resMode = resMode;
    params.videoResolution = res;
    params.videoBitrate = bitrate;
    params.videoFps = videoFps;
    m_trtcCloud->setVideoEncoderParam(params);
}

void TestVideoSetting::on_beautyStyleComboBox_currentIndexChanged(int index) {
    updateBeautyStyle();
}

void TestVideoSetting::on_beautyLevelSlider_valueChanged(int value) {
    updateBeautyStyle();
}

void TestVideoSetting::on_whitenessLevelSlider_valueChanged(int value) {
    updateBeautyStyle();
}

void TestVideoSetting::on_ruddinessLevelSlider_valueChanged(int value) {
    updateBeautyStyle();
}

void TestVideoSetting::updateBeautyStyle() {
    int style = ui->beautyStyleComboBox->currentIndex();
    double beautyLevel = ui->beautyLevelSlider->value() / 11.2;
    double whitenessLevel = ui->whitenessLevelSlider->value() / 11.2;
    double ruddinessLevel = ui->ruddinessLevelSlider->value() / 11.2;
    m_trtcCloud->setBeautyStyle((trtc::TRTCBeautyStyle)style, (uint32_t)beautyLevel, (uint32_t)whitenessLevel, (uint32_t)ruddinessLevel);
}

void TestVideoSetting::showEvent(QShowEvent *) {
    setupCameraDevice();
    m_trtcCloud->startLocalPreview(reinterpret_cast<trtc::TXView>(ui->localVideoView->winId()));
}

void TestVideoSetting::setupCameraDevice() {
    trtc::ITXDeviceManager *manager = m_trtcCloud->getDeviceManager();
    if (manager == nullptr) return;
    ui->camComboBox->clear();
    // 枚举摄像头
    trtc::ITXDeviceCollection *deviceCollection = manager->getDevicesList(trtc::TXMediaDeviceTypeCamera);
    for (uint32_t i = 0; i < deviceCollection->getCount(); i++) {
        const char *dname = deviceCollection->getDeviceName(i);
        ui->camComboBox->addItem(dname);
    }
    deviceCollection->release();
}

void TestVideoSetting::setupVideoResMap() {
    // 宽高比1:1
    m_videoResMap.insert(0, trtc::TRTCVideoResolution_120_120);
    m_videoResMap.insert(1, trtc::TRTCVideoResolution_160_160);
    m_videoResMap.insert(2, trtc::TRTCVideoResolution_270_270);
    m_videoResMap.insert(3, trtc::TRTCVideoResolution_480_480);
    // 宽高比4:3
    m_videoResMap.insert(4, trtc::TRTCVideoResolution_160_120);
    m_videoResMap.insert(5, trtc::TRTCVideoResolution_240_180);
    m_videoResMap.insert(6, trtc::TRTCVideoResolution_280_210);
    m_videoResMap.insert(7, trtc::TRTCVideoResolution_320_240);
    m_videoResMap.insert(8, trtc::TRTCVideoResolution_400_300);
    m_videoResMap.insert(9, trtc::TRTCVideoResolution_480_360);
    m_videoResMap.insert(10, trtc::TRTCVideoResolution_640_480);
    m_videoResMap.insert(11, trtc::TRTCVideoResolution_960_720);
    // 宽高比16:9
    m_videoResMap.insert(12, trtc::TRTCVideoResolution_160_90);
    m_videoResMap.insert(13, trtc::TRTCVideoResolution_256_144);
    m_videoResMap.insert(14, trtc::TRTCVideoResolution_320_180);
    m_videoResMap.insert(15, trtc::TRTCVideoResolution_480_270);
    m_videoResMap.insert(16, trtc::TRTCVideoResolution_640_360);
    m_videoResMap.insert(17, trtc::TRTCVideoResolution_960_540);
    // [S] 屏幕分享   - 建议码率：低清：1000kbps 高清：1600kbps
    m_videoResMap.insert(18, trtc::TRTCVideoResolution_1280_720);
    // [S] 屏幕分享   - 建议码率2000kbps
    m_videoResMap.insert(19, trtc::TRTCVideoResolution_1920_1080);
}

void TestVideoSetting::closeEvent(QCloseEvent *event) {
    hide();
    if (m_renderView != nullptr) {
        m_trtcCloud->stopLocalPreview();
        m_trtcCloud->startLocalPreview(reinterpret_cast<trtc::TXView>(m_renderView->winId()));
    }
}
