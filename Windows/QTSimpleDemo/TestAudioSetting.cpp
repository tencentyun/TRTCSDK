//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#include "TestAudioSetting.h"
#include "ui_TestAudioSetting.h"
#include <QtDebug>
#include <QLineEdit>
#include <QFileDialog>
#include <QDateTime>

#define RECORD_ID          100

TestAudioSetting::TestAudioSetting(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::TestAudioSetting) {
    ui->setupUi(this);
    m_trtcCloud = getTRTCShareInstance();
    if (m_trtcCloud != nullptr) m_trtcCloud->addCallback(this);
}

TestAudioSetting::~TestAudioSetting() {
    if (m_trtcCloud != nullptr) {
        m_trtcCloud->removeCallback(this);
        m_trtcCloud = nullptr;
    }
    delete ui;
}

void TestAudioSetting::setupDevice() {
    // 麦克风
    trtc::ITXDeviceManager *manager = m_trtcCloud->getDeviceManager ();
    if (manager == nullptr) return;

    ui->micComboBox->clear();
    trtc::ITXDeviceCollection *micdeviceCollection = manager->getDevicesList(trtc::TXMediaDeviceTypeMic);
    for (uint32_t i = 0; i < micdeviceCollection->getCount(); i++) {
        const char *dname = micdeviceCollection->getDeviceName(i);
        ui->micComboBox->addItem(dname);
    }
    // 扬声器
    ui->speakerComboBox->clear();
    trtc::ITXDeviceCollection *speakerdeviceCollection = manager->getDevicesList(trtc::TXMediaDeviceTypeSpeaker);
    uint32_t count = speakerdeviceCollection->getCount();
    for (uint32_t i = 0; i < count; i++) {
        const char *dname = speakerdeviceCollection->getDeviceName(i);
        ui->speakerComboBox->addItem(dname);
    }
    micdeviceCollection->release();
    speakerdeviceCollection->release();
}

void TestAudioSetting::on_micButton_clicked(bool checked) {
    trtc::ITXDeviceManager *manager = m_trtcCloud->getDeviceManager ();
    if (manager == nullptr) return;

    if (checked) {
        manager->startMicDeviceTest(300);
    } else {
        manager->stopMicDeviceTest();
        ui->micProgressBar->setValue(0);
    }
}

void TestAudioSetting::on_micComboBox_currentIndexChanged(int index) {
    trtc::ITXDeviceManager *manager = m_trtcCloud->getDeviceManager ();
    if (manager == nullptr) return;

    const char *pid = nullptr;
    trtc::ITXDeviceCollection *deviceCollection = manager->getDevicesList(trtc::TXMediaDeviceTypeMic);
    for (uint32_t i = 0; i < deviceCollection->getCount(); i++) {
        if ((uint32_t)index == i) {
            pid = deviceCollection->getDevicePID(i);
        }
    }
    if (pid != nullptr) {
        manager->setCurrentDevice(trtc::TXMediaDeviceTypeMic, pid);
    }
    deviceCollection->release();
}

void TestAudioSetting::on_micVolumeSlider_valueChanged(int value) {
    trtc::ITXDeviceManager *manager = m_trtcCloud->getDeviceManager ();
    if (manager == nullptr) return;

    manager->setCurrentDeviceVolume(trtc::TXMediaDeviceTypeMic, (uint32_t)value);
}

void TestAudioSetting::on_speakerComboBox_currentIndexChanged(int index) {
    trtc::ITXDeviceManager *manager = m_trtcCloud->getDeviceManager ();
    if (manager == nullptr) return;

    const char *pid = nullptr;
    trtc::ITXDeviceCollection *deviceCollection = manager->getDevicesList(trtc::TXMediaDeviceTypeSpeaker);
    for (uint32_t i = 0; i < deviceCollection->getCount(); i++) {
        if ((uint32_t)index == i) {
            pid = deviceCollection->getDevicePID(i);
        }
    }
    if (pid != nullptr) {
        manager->setCurrentDevice(trtc::TXMediaDeviceTypeSpeaker, pid);
    }
    deviceCollection->release();
}

void TestAudioSetting::on_speakerSlider_valueChanged(int value) {
    trtc::ITXDeviceManager *manager = m_trtcCloud->getDeviceManager ();
    if (manager == nullptr) return;

    manager->setCurrentDeviceVolume(trtc::TXMediaDeviceTypeSpeaker, (uint32_t)value);
}

void TestAudioSetting::on_speakerButton_clicked(bool checked) {
    trtc::ITXDeviceManager *manager = m_trtcCloud->getDeviceManager ();
    if (manager == nullptr) return;

    if (checked) {
        const QString tempFile = m_tempDir.path() + "/audio_short.m4a";
        QByteArray tempFileByteArray = tempFile.toLatin1();
        QFile::copy(":/bgm/audio/bgm/audio_short.m4a", tempFile);
        const char *filePath = tempFileByteArray.data();
        manager->startSpeakerDeviceTest(filePath);
    } else {
        manager->stopSpeakerDeviceTest();
        ui->speakerProgressBar->setValue(0);
    }
}

void TestAudioSetting::onTestMicVolume(uint32_t volume) {
    ui->micProgressBar->setValue(static_cast<int>(volume));
}

void TestAudioSetting::onTestSpeakerVolume(uint32_t volume) {
    ui->speakerProgressBar->setValue(static_cast<int>(volume));
}

void TestAudioSetting::on_setVoiceCaptureVolumeSlider_valueChanged(int value) {
    trtc::ITXAudioEffectManager *manager = m_trtcCloud->getAudioEffectManager();
    if (manager == nullptr) return;

    manager->setVoiceCaptureVolume(value);
}

void TestAudioSetting::on_sdkAudioPlayoutVolumeSlider_valueChanged(int value) {
    m_trtcCloud->setAudioPlayoutVolume(value);

    int sdkVolume = m_trtcCloud->getAudioPlayoutVolume();
    // 更新label上的音量数据
    QString text(QString::number(sdkVolume));
    ui->playVolumeLabel->setText(text);
}

void TestAudioSetting::on_sdkAudioCaptureVolumeSlider_valueChanged(int value) {
    m_trtcCloud->setAudioCaptureVolume(value);

    int sdkVolume = m_trtcCloud->getAudioCaptureVolume();
    QString text(QString::number(sdkVolume));
    ui->capVolumeLabel->setText(text);
}

void TestAudioSetting::on_switchAudioRecordBox_clicked(bool checked) {
    if (checked == true && m_tempDir.isValid()) {
        QString fileName;
        if (QFileInfo(ui->filePath->text()).isDir()) {
            fileName = ui->filePath->text();
        } else {
            fileName = QFileDialog::getExistingDirectory(this, tr("Open Directory"), "/Desktop", QFileDialog::ShowDirsOnly | QFileDialog::DontResolveSymlinks);
        }
        if (QFileInfo(fileName).isDir()) {
            ui->filePath->setText(fileName);
            m_recordAudioTime = (int)QDateTime::currentDateTime().toTime_t();
            fileName = fileName + "/" + QString::number(m_recordAudioTime) + ".aac";
        } else {
            ui->switchAudioRecordBox->setChecked(false);
            return;
        }

        trtc::TRTCAudioRecordingParams params;
        QByteArray tempFileByteArray = fileName.toLatin1();
        char *filePath = tempFileByteArray.data();
        params.filePath = filePath;
        int res = m_trtcCloud->startAudioRecording(params);
        if (res == 0) {
            ui->startPlayAudioRecord->setEnabled(true);
        }
    } else {
        m_trtcCloud->stopAudioRecording();
        ui->switchAudioRecordBox->setChecked(false);
    }
}

void TestAudioSetting::onComplete(int Id, int errCode) {
     switch (Id) {
     case RECORD_ID:
         resetRecordPlayInfo();
         break;
     default:
         break;
     }
}

inline void TestAudioSetting::resetRecordPlayInfo() {
    ui->startPlayAudioRecord->setChecked(false);
    ui->switchAudioRecordBox->setChecked(false);
    ui->switchAudioRecordBox->setEnabled(true);
}

void TestAudioSetting::on_startPlayAudioRecord_clicked(bool checked) {
    trtc::ITXAudioEffectManager *manager = m_trtcCloud->getAudioEffectManager ();
    if (manager == nullptr) return;

    if (checked && m_tempDir.isValid()) {
        ui->switchAudioRecordBox->setEnabled(false);
        on_switchAudioRecordBox_clicked(false);

        QString tempFile = ui->filePath->text();
        tempFile = tempFile + "/" + QString::number(m_recordAudioTime) + ".aac";
        QByteArray tempFileByteArray = tempFile.toLatin1();
        char *path = tempFileByteArray.data();
        trtc::AudioMusicParam param = trtc::AudioMusicParam(RECORD_ID, path);
        manager->startPlayMusic(param);
        manager->setMusicObserver(RECORD_ID, this);
    } else {
        manager->stopPlayMusic(RECORD_ID);
        ui->switchAudioRecordBox->setEnabled(true);
    }
}

void TestAudioSetting::closeEvent(QCloseEvent *event) {
    resetRecordPlayInfo();
    hide();
}

void TestAudioSetting::showEvent(QShowEvent *) {
    setupDevice();
}

void TestAudioSetting::onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *extraInfo) { qDebug() << "warningCode: " << warningCode << "  warningMsg: " << warningMsg << "  extraInfo: " << extraInfo; }
void TestAudioSetting::onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo) { qDebug() << "errCode: " << errCode << "  errMsg: " << errMsg << "  extraInfo: " << extraInfo; }
void TestAudioSetting::onPlayProgress(int Id, long curPtsMS, long durationMS) { qDebug() << Id << curPtsMS << durationMS; }
void TestAudioSetting::onStart(int Id, int errCode) { qDebug() << Id << errCode; }
void TestAudioSetting::onEnterRoom(int result) { qDebug() << result; }
void TestAudioSetting::onExitRoom(int reason) { qDebug() << reason; }
