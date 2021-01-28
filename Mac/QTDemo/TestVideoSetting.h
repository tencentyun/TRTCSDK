//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef TESTVIDEOSETTING_H
#define TESTVIDEOSETTING_H

#include <QDialog>
#include "ITRTCCloud.h"

namespace Ui {
class TestVideoSetting;
}

/// 视频设置
class TestVideoSetting : public QDialog {
    Q_OBJECT

public:
    explicit TestVideoSetting(QWidget *parent = nullptr);
    ~TestVideoSetting() override;

    void setUserIds(const QVector<QString> &userIds);
    void setRenderView(QWidget *renderView);

    void showEvent(QShowEvent *) override;
    void closeEvent(QCloseEvent *event) override;

private slots:
    void on_camComboBox_currentIndexChanged(int index);
    void on_videoResolution_currentIndexChanged(int index);
    void on_fpsComboBox_currentIndexChanged(int index);
    void on_bitrateSlider_valueChanged(int value);
    void on_beautyStyleComboBox_currentIndexChanged(int index);
    void on_beautyLevelSlider_valueChanged(int value);
    void on_whitenessLevelSlider_valueChanged(int value);
    void on_ruddinessLevelSlider_valueChanged(int value);
    void on_resComboBox_currentIndexChanged(int index);
    void on_remoteFillModeComboBox_currentIndexChanged(int index);
    void on_localFillModeComboBox_currentIndexChanged(int index);
    void on_setWaterMarkBtn_clicked(bool checked);

private:
    Ui::TestVideoSetting *ui;
    trtc::ITRTCCloud *m_trtcCloud;
    QWidget *m_renderView = nullptr;

    QVector<QString> m_userIds;
    QHash<int, trtc::TRTCVideoResolution> m_videoResMap;

    void setupCameraDevice();
    void setupVideoResMap();
    void updateBeautyStyle();
    void updateVideoEncoderParams();
};

#endif // TESTVIDEOSETTING_H
