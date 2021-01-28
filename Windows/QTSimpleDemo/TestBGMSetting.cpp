//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#include "TestBGMSetting.h"
#include "ui_TestBGMSetting.h"
#include <QThread>

#define MUSICID_ID         9
#define SOUND1_ID          1
#define SOUND2_ID          2
#define SOUND3_ID          3

TestBGMSetting::TestBGMSetting(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::TestBGMSetting) {
    ui->setupUi(this);
    m_trtcCloud = getTRTCShareInstance();

    connectSlot();
    setupStyleSheet();
}

TestBGMSetting::~TestBGMSetting() {
    delete ui;
}

inline void TestBGMSetting::connectSlot() {
    // 使用信号槽确保Win和Mac的回调都在主线程
    connect(this, SIGNAL(start(int, int)), this, SLOT(handleStart(int, int)));
    connect(this, SIGNAL(complete(int, int)), this, SLOT(handleComplete(int, int)));
    connect(this, SIGNAL(playProgress(int, long, long)), this, SLOT(handlePlayProgress(int, long, long)));
}

inline void TestBGMSetting::setupStyleSheet() {
    ui->pauseBGM->setStyleSheet("QPushButton{border-image: url(:/bgm/image/bgm/bgm_pause.png);}");
    ui->playOrStopBGM->setStyleSheet("QPushButton{border-image: url(:/bgm/image/bgm/bgm_play.png);}");

    QPixmap pixmap(":/bgm/image/bgm/bgm_reset.png");
    QIcon icon(pixmap);
    ui->resetButton->setIcon(icon);
    ui->resetButton->setIconSize(QSize(15, 15));
}

void TestBGMSetting::on_setVoiceReverbTypeComboBox_currentIndexChanged(int index) {
    if (m_trtcCloud->getAudioEffectManager() == nullptr) return;
    m_trtcCloud->getAudioEffectManager()->setVoiceReverbType(static_cast<trtc::TXVoiceReverbType>(index));
}

void TestBGMSetting::on_pauseResumeMusicBox_clicked(bool checked) {
    if (m_trtcCloud->getAudioEffectManager() == nullptr) return;
    if (checked) {
        m_trtcCloud->getAudioEffectManager()->pausePlayMusic(MUSICID_ID);
    } else {
        m_trtcCloud->getAudioEffectManager()->resumePlayMusic(MUSICID_ID);
    }
}

void TestBGMSetting::onStart(int Id, int errCode) {
    emit start(Id, errCode);
}

void TestBGMSetting::onPlayProgress(int Id, long curPtsMS, long durationMS) {
    emit playProgress(Id, curPtsMS, durationMS);
}

void TestBGMSetting::onComplete(int Id, int errCode) {
    emit complete(Id, errCode);
}

void TestBGMSetting::handleStart(int Id, int errCode) {
    switch (Id) {
    case MUSICID_ID:
        ui->bgmSlider->setValue(0);
        break;
    default:
        break;
    }
}

void TestBGMSetting::handlePlayProgress(int Id, long curPtsMS, long durationMS) {
    switch (Id) {
    case MUSICID_ID: {
        ui->bgmSlider->setValue(static_cast<int>((static_cast<double>(curPtsMS / durationMS * 100))));
        updatePlayInfo();
        break;
    }
    default:
        break;
    }
}

void TestBGMSetting::handleComplete(int Id, int errCode) {
    switch (Id) {
    case MUSICID_ID:
        resetMusicPlayInfo();
        break;
    case SOUND1_ID:
        ui->soundPlay1->setChecked(false);
        ui->soundPush1->setChecked(false);
        ui->soundReplay1->setChecked(false);
        break;
    case SOUND2_ID:
        ui->soundPlay2->setChecked(false);
        ui->soundPush2->setChecked(false);
        ui->soundReplay2->setChecked(false);
        break;
    case SOUND3_ID:
        ui->soundPlay3->setChecked(false);
        ui->soundPush3->setChecked(false);
        ui->soundReplay3->setChecked(false);
        break;
    default:
        break;
    }
}

inline void TestBGMSetting::resetMusicPlayInfo() {
    m_isStarted = true;
    ui->bgmSlider->setValue(0);
    ui->getMusicDurationInMS->setText("00 ms / 00 ms");
    ui->playOrStopBGM->setStyleSheet("QPushButton{border-image: url(:/bgm/image/bgm/bgm_play.png);}");
}

inline void TestBGMSetting::updatePlayInfo() {
    if (m_trtcCloud->getAudioEffectManager() == nullptr) return;
    // 获取播放进度；curPtsMS 等于 postion
    long position = m_trtcCloud->getAudioEffectManager()->getMusicCurrentPosInMS(MUSICID_ID);
    QString text;
    text.append(QString::number(position)).append(" ms / ");
    text.append(QString::number(m_longBgmDuration)).append(" ms");
    ui->getMusicDurationInMS->setText(text);
}

void TestBGMSetting::on_setMusicPublishVolume_valueChanged(int value) {
    m_trtcCloud->getAudioEffectManager()->setMusicPublishVolume(MUSICID_ID, value);
}

void TestBGMSetting::on_setMusicPlayoutVolume_valueChanged(int value) {
    m_trtcCloud->getAudioEffectManager()->setMusicPlayoutVolume(MUSICID_ID, value);
}

void TestBGMSetting::on_setAllMusicVolume_valueChanged(int value) {
    ui->setMusicPlayoutVolume->setValue(value);
    ui->setMusicPublishVolume->setValue(value);
    m_trtcCloud->getAudioEffectManager()->setAllMusicVolume(value);
}

void TestBGMSetting::on_setMusicPitchSlider_valueChanged(int value) {
    int ratio = value - 50;
    m_trtcCloud->getAudioEffectManager()->setMusicPitch(MUSICID_ID, static_cast<float>(ratio * 1.0 / 50.0));
}

void TestBGMSetting::on_setMusicSpeedRateSlider_valueChanged(int value) {
    double ratio = value * 1.0 / 10.0;
    m_trtcCloud->getAudioEffectManager()->setMusicSpeedRate(MUSICID_ID, static_cast<float>(ratio));
}

void TestBGMSetting::on_playOrStopBGM_clicked() {
    static bool flag = true;
    if (m_isStarted) {
        // 第一次播放
        QString tempFile = m_tempDir.path() + "/audio_long.mp3";
        QByteArray tempFileByteArray = tempFile.toLatin1();
        bool copySuccess = QFile::copy(":/bgm/audio/bgm/audio_long.mp3", tempFile);
        bool isFile = QFileInfo(tempFile).isFile();
        if (copySuccess || isFile) {
            trtc::AudioMusicParam param = trtc::AudioMusicParam(MUSICID_ID, tempFileByteArray.data());
            param.publish = true;
            param.isShortFile = true;
            param.loopCount = ui->loopCountEdit->text().toInt();
            m_trtcCloud->getAudioEffectManager()->startPlayMusic(param);
            m_trtcCloud->getAudioEffectManager()->setMusicObserver(MUSICID_ID, this);
            m_longBgmDuration = static_cast<int>(m_trtcCloud->getAudioEffectManager()->getMusicDurationInMS(param.path));
            m_isStarted = false;
        }
        ui->playOrStopBGM->setStyleSheet("QPushButton{border-image: url(:/bgm/image/bgm/bgm_stop.png);}");
    } else if (flag) {

        m_trtcCloud->getAudioEffectManager()->pausePlayMusic(MUSICID_ID);
        ui->playOrStopBGM->setStyleSheet("QPushButton{border-image: url(:/bgm/image/bgm/bgm_play.png);}");
        flag = !flag;
    } else {
        m_trtcCloud->getAudioEffectManager()->resumePlayMusic(MUSICID_ID);
        ui->playOrStopBGM->setStyleSheet("QPushButton{border-image: url(:/bgm/image/bgm/bgm_stop.png);}");

        flag = !flag;
    }
}

void TestBGMSetting::on_pauseBGM_clicked() {
    m_trtcCloud->getAudioEffectManager()->stopPlayMusic(MUSICID_ID);
    resetMusicPlayInfo();
}

void TestBGMSetting::on_soundPlay1_clicked(bool checked) {
    if (checked) {
        soundPlay1();
    } else {
        m_trtcCloud->getAudioEffectManager()->stopPlayMusic(SOUND1_ID);
        ui->soundReplay1->setChecked(false);
        ui->soundPush1->setChecked(false);
        ui->soundPlay1->setChecked(false);
    }
}

void TestBGMSetting::on_soundReplay1_clicked(bool checked) {
    soundPlay1();
}

void TestBGMSetting::on_soundPush1_clicked(bool checked) {
    soundPlay1();
}

void TestBGMSetting::on_soundPlay2_clicked(bool checked) {
    if (checked) {
        soundPlay2();
    } else {
        m_trtcCloud->getAudioEffectManager()->stopPlayMusic(SOUND2_ID);
        ui->soundReplay2->setChecked(false);
        ui->soundPush2->setChecked(false);
        ui->soundPlay2->setChecked(false);
    }
}

void TestBGMSetting::on_soundReplay2_clicked(bool checked) {
    soundPlay2();
}

void TestBGMSetting::on_soundPush2_clicked(bool checked) {
    soundPlay2();
}

void TestBGMSetting::on_soundPlay3_clicked(bool checked) {
    if (checked) {
        soundPlay3();
    } else {
        m_trtcCloud->getAudioEffectManager()->stopPlayMusic(SOUND3_ID);
        ui->soundReplay3->setChecked(false);
        ui->soundPush3->setChecked(false);
        ui->soundPlay3->setChecked(false);
    }
}

void TestBGMSetting::on_soundReplay3_clicked(bool checked) {
    soundPlay3();
}

void TestBGMSetting::on_soundPush3_clicked(bool checked) {
    soundPlay3();
}

void TestBGMSetting::soundPlay1() {
    ui->soundPlay1->setChecked(true);
    m_trtcCloud->getAudioEffectManager()->stopPlayMusic(SOUND1_ID);
    startPlayMusic(SOUND1_ID, "didi.aac", ui->soundPush1->isChecked(), ui->soundReplay1->isChecked() ? 10000 : 0);
}

void TestBGMSetting::soundPlay2() {
    ui->soundPlay2->setChecked(true);
    m_trtcCloud->getAudioEffectManager()->stopPlayMusic(SOUND2_ID);
    startPlayMusic(SOUND2_ID, "bianpao.m4a", ui->soundPush2->isChecked(), ui->soundReplay2->isChecked() ? 10000 : 0);
}

void TestBGMSetting::soundPlay3() {
    ui->soundPlay3->setChecked(true);
    m_trtcCloud->getAudioEffectManager()->stopPlayMusic(SOUND3_ID);
    startPlayMusic(SOUND3_ID, "qingcui.aac", ui->soundPush3->isChecked(), ui->soundReplay3->isChecked() ? 10000 : 0);
}

void TestBGMSetting::startPlayMusic(int musicId, const char* path, bool publish, int loopCount) {
    m_trtcCloud->getAudioEffectManager()->stopPlayMusic(musicId);

    QString tempFile = m_tempDir.path() + path;
    QByteArray tempFileByteArray = tempFile.toLatin1();
    bool copySuccess = QFile::copy(QString(":/sound/audio/sound/") + path, tempFile);
    bool isFile = QFileInfo(tempFile).isFile();
    if (copySuccess || isFile) {
        trtc::AudioMusicParam param = trtc::AudioMusicParam(musicId, tempFileByteArray.data());
        param.publish = publish;
        param.isShortFile = true;
        param.loopCount = loopCount;
        m_trtcCloud->getAudioEffectManager()->startPlayMusic(param);
        m_trtcCloud->getAudioEffectManager()->setMusicObserver(musicId, this);
    }
}

void TestBGMSetting::on_resetButton_clicked() {
    m_trtcCloud->getAudioEffectManager()->setAllMusicVolume(100);
    m_trtcCloud->getAudioEffectManager()->setMusicPitch(MUSICID_ID, 0.0);
    m_trtcCloud->getAudioEffectManager()->setMusicSpeedRate(MUSICID_ID, 1.0f);
    m_trtcCloud->getAudioEffectManager()->setMusicPublishVolume(MUSICID_ID, 100);
    m_trtcCloud->getAudioEffectManager()->setMusicPlayoutVolume(MUSICID_ID, 100);

    ui->setAllMusicVolume->setValue(100);
    ui->setMusicPitchSlider->setValue(50);
    ui->setMusicPublishVolume->setValue(100);
    ui->setMusicPlayoutVolume->setValue(100);
    ui->setMusicSpeedRateSlider->setValue(10);
}

void TestBGMSetting::closeEvent(QCloseEvent *) {
    hide();
    on_pauseBGM_clicked();
    on_resetButton_clicked();
    on_soundPlay1_clicked(false);
    on_soundPlay2_clicked(false);
    on_soundPlay3_clicked(false);
}
