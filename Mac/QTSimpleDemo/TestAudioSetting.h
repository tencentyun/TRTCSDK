//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef TESTAUDIOSETTING_H
#define TESTAUDIOSETTING_H

#include <QDialog>
#include "ITRTCCloud.h"
#include <QTemporaryDir>
#include <QString>

namespace Ui {
class TestAudioSetting;
}

/// 声音设置
class TestAudioSetting : public QDialog, public trtc::ITRTCCloudCallback, public trtc::ITXMusicPlayObserver {
    Q_OBJECT

public:
    explicit TestAudioSetting(QWidget *parent = nullptr);
    ~TestAudioSetting() override;

    // 关闭窗口
    void closeEvent(QCloseEvent *event) override;
    void showEvent(QShowEvent *) override;

    // ITXMusicPlayObserver
    void onStart(int Id, int errCode) override;
    void onComplete(int Id, int errCode) override;
    void onPlayProgress(int Id, long curPtsMS, long durationMS) override;

    void onTestSpeakerVolume(uint32_t volume) override;
    void onTestMicVolume(uint32_t volume) override;

    void onEnterRoom(int result) override;
    void onExitRoom(int reason) override;
    void onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo) override;
    void onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *extraInfo) override;

private slots:
    // 采集音量
    void on_setVoiceCaptureVolumeSlider_valueChanged(int value);
    // 录音
    void on_switchAudioRecordBox_clicked(bool checked);
    void on_startPlayAudioRecord_clicked(bool checked);

    void on_sdkAudioPlayoutVolumeSlider_valueChanged(int value);
    void on_sdkAudioCaptureVolumeSlider_valueChanged(int value);
    void on_micComboBox_currentIndexChanged(int index);
    void on_micVolumeSlider_valueChanged(int value);
    void on_micButton_clicked(bool checked);
    void on_speakerComboBox_currentIndexChanged(int index);
    void on_speakerSlider_valueChanged(int value);
    void on_speakerButton_clicked(bool checked);

private:
    Ui::TestAudioSetting *ui;
    trtc::ITRTCCloud *m_trtcCloud;
    QTemporaryDir m_tempDir;
    int m_recordAudioTime = 0;

    void setupDevice();
    void resetRecordPlayInfo();
};

#endif // TESTAUDIOSETTING_H
