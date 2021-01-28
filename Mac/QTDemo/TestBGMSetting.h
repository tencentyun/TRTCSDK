//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef TESTBGMSETTING_H
#define TESTBGMSETTING_H

#include <QDialog>
#include "ITRTCCloud.h"
#include <QTemporaryDir>

namespace Ui {
class TestBGMSetting;
}

/// BGM设置
class TestBGMSetting : public QDialog, public trtc::ITXMusicPlayObserver {
    Q_OBJECT

public:
    explicit TestBGMSetting(QWidget *parent = nullptr);
    ~TestBGMSetting() override;

    void closeEvent(QCloseEvent *) override;

    // ITXMusicPlayObserver
    void onStart(int Id, int errCode) override;
    void onComplete(int Id, int errCode) override;
    void onPlayProgress(int Id, long curPtsMS, long durationMS) override;

signals:
    void start(int Id, int errCode);
    void complete(int Id, int errCode);
    void playProgress(int Id, long curPtsMS, long durationMS);

private slots:
    void handleStart(int Id, int errCode);
    void handleComplete(int Id, int errCode);
    void handlePlayProgress(int Id, long curPtsMS, long durationMS);

    void on_playOrStopBGM_clicked();
    void on_pauseBGM_clicked();

    // 恢复/暂停播放背景音乐
    void on_pauseResumeMusicBox_clicked(bool checked);
    // 调整背景音乐的音调高低: [-1 ~ 1]
    void on_setMusicPitchSlider_valueChanged(int value);
    // 调整背景音乐的变速效果 [0.5 ~ 2] 之间的浮点数；
    void on_setMusicSpeedRateSlider_valueChanged(int value);
    // 设置人声的混响效果（KTV、小房间、大会堂、低沉、洪亮...）
    void on_setVoiceReverbTypeComboBox_currentIndexChanged(int index);
    void on_resetButton_clicked();
    void on_setMusicPublishVolume_valueChanged(int value);
    void on_setMusicPlayoutVolume_valueChanged(int value);
    void on_setAllMusicVolume_valueChanged(int value);

    void on_soundPlay1_clicked(bool checked);
    void on_soundReplay1_clicked(bool checked);
    void on_soundPush1_clicked(bool checked);
    void on_soundPlay2_clicked(bool checked);
    void on_soundReplay2_clicked(bool checked);
    void on_soundPush2_clicked(bool checked);
    void on_soundPlay3_clicked(bool checked);
    void on_soundReplay3_clicked(bool checked);
    void on_soundPush3_clicked(bool checked);

private:
    Ui::TestBGMSetting *ui;
    trtc::ITRTCCloud *m_trtcCloud;

    QTemporaryDir m_tempDir;
    int m_longBgmDuration = 0;
    bool m_isStarted = true;

    void connectSlot();
    void setupStyleSheet();
    // 更新播放信息，如进度 & 时长
    void updatePlayInfo();
    void resetMusicPlayInfo();
    void startPlayMusic(int musicId, const char* path, bool publish, int loopCount);

    void soundPlay1();
    void soundPlay2();
    void soundPlay3();
};

#endif // TESTBGMSETTING_H
