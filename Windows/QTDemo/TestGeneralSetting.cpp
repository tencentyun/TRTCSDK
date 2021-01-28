//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#include "TestGeneralSetting.h"
#include "ui_TestGeneralSetting.h"
#include <QFileDialog>
#include "base/Defs.h"
#include <QDebug>
#ifdef __APPLE__
#include "GenerateTestUserSig.h"
#endif
#ifdef _WIN32
#include "GenerateTestUsersig.h"
#endif

TestGeneralSetting::TestGeneralSetting(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::TestGeneralSetting) {
    ui->setupUi(this);
    m_trtcCloud = getTRTCShareInstance();
    if (m_trtcCloud != nullptr) m_trtcCloud->addCallback(this);

    // 设置SDK版本号信息
    setSDKVersion();
}

TestGeneralSetting::~TestGeneralSetting() {
    if (m_trtcCloud != nullptr) {
        m_trtcCloud->removeCallback(this);
        m_trtcCloud = nullptr;
    }
    delete ui;
}

void TestGeneralSetting::on_startSpeedTest_clicked(bool checked) {
    if (checked) {
        std::string uid = m_userId.toStdString();
        const char* userId = uid.c_str();
#ifdef __APPLE__
        GenerateTestUserSig gen;
        const char *userSig = gen.genTestUserSig(userId, static_cast<int>(SDKAppID), SECRETKEY);
#endif

#ifdef _WIN32
        std::string strToken = SECRETKEY;
        std::string str = GenerateTestUserSig::instance().genTestUserSig(SDKAppID, strToken,
            userId).c_str();
        const char* userSig = str.c_str();
#endif

        m_trtcCloud->startSpeedTest(SDKAppID, userId, userSig);
        ui->startSpeedTest->setEnabled(false);
    } else {
        m_trtcCloud->stopSpeedTest();
    }
}

void TestGeneralSetting::on_startCamTestButton_clicked(bool checked) {
    if (m_trtcCloud->getDeviceManager() == nullptr) return;

    if (checked) {
        int res = m_trtcCloud->getDeviceManager()->startCameraDeviceTest(reinterpret_cast<trtc::TXView>(ui->localView->winId()));
        qDebug() << "res = " << res;

    } else {
        int res = m_trtcCloud->getDeviceManager()->stopCameraDeviceTest();
        qDebug() << "res = " << res;
    }
}

void TestGeneralSetting::onSpeedTest(const trtc::TRTCSpeedTestResult& currentResult, uint32_t finishedCount, uint32_t totalCount) {
    QString progress("Progress: " + QString::number(finishedCount) + "/" + QString::number(totalCount));
    ui->speedTestLabel->setText(progress.toUtf8());
    bool isFinished = finishedCount == totalCount;
    ui->startSpeedTest->setEnabled(isFinished);
    if (isFinished) ui->startSpeedTest->setChecked(false);
}

void TestGeneralSetting::on_setLogLevelComboBox_currentIndexChanged(int index) {
    QLineEdit *logDirPathLineEdit = ui->logDirPathLineEdit;
    QString tempFile = logDirPathLineEdit->text();
    std::string stdFile;
    if (QFileInfo(tempFile).isExecutable()) {
        // 保存用户自定义的log缓存路径
        stdFile = tempFile.toStdString();
    } else {
        // 如果用户没选择，则使用默认路径
        const QString tempFile = m_tempDir.path() + "/log";
        stdFile = tempFile.toStdString();
    }
    m_trtcCloud->setLogDirPath(stdFile.c_str());

    // 设置 Log 输出级别
    trtc::TRTCLogLevel level = static_cast<trtc::TRTCLogLevel>(index);
    m_trtcCloud->setLogLevel(level);
}

void TestGeneralSetting::on_setConsoleEnabled_clicked(bool checked) {
    m_trtcCloud->setConsoleEnabled(checked);
}

void TestGeneralSetting::on_setLogCompressEnabled_clicked(bool checked) {
    m_trtcCloud->setLogCompressEnabled(checked);
}

void TestGeneralSetting::setUserId(QString &userId) {
    m_userId = userId;
}

void TestGeneralSetting::setUserIds(const QVector<QString> &userIds) {
    m_userIds = userIds;
    ui->smallButton->setEnabled(m_userIds.count() > 1);
}

void TestGeneralSetting::setLocalPreview(trtc::TXView localPreview) {
	m_localView = localPreview;
}

inline void TestGeneralSetting::setSDKVersion() {
    QString text("SDK Version: ");
    text.append(m_trtcCloud->getSDKVersion());
    ui->sdkVersionLabel->setText(text);
}

void TestGeneralSetting::on_setLogDirPathButton_clicked() {
    QString fileName = QFileDialog::getExistingDirectory(this, tr("Open Directory"), "/Desktop", QFileDialog::ShowDirsOnly | QFileDialog::DontResolveSymlinks);
    if (QFileInfo(fileName).isDir()) {
        QLineEdit *logDirPathLineEdit = ui->logDirPathLineEdit;
        logDirPathLineEdit->setText(fileName);
        ui->setLogLevelComboBox->setEnabled(true);
    }
}

void TestGeneralSetting::on_smoothButton_clicked(bool checked) {
    if (checked == false) ui->smoothButton->setChecked(true);
    ui->clearButton->setChecked(false);
    updateNetworkQosParam();
}

void TestGeneralSetting::on_clearButton_clicked(bool checked) {
    if (checked == false) ui->clearButton->setChecked(true);
    ui->smoothButton->setChecked(false);
    updateNetworkQosParam();
}

void TestGeneralSetting::on_userControlButton_clicked(bool checked) {
    if (checked == false) ui->userControlButton->setChecked(true);
    ui->cloudControlButton->setChecked(false);
    updateNetworkQosParam();
}

void TestGeneralSetting::on_cloudControlButton_clicked(bool checked) {
    if (checked == false) ui->cloudControlButton->setChecked(true);
    ui->userControlButton->setChecked(false);
    updateNetworkQosParam();
}

inline void TestGeneralSetting::updateNetworkQosParam() {
    trtc::TRTCNetworkQosParam param;
    param.preference = ui->smoothButton->isChecked() ? trtc::TRTCVideoQosPreferenceSmooth : trtc::TRTCVideoQosPreferenceClear;
    param.controlMode = ui->userControlButton->isChecked() ? trtc::TRTCQosControlModeClient : trtc::TRTCQosControlModeServer;
    m_trtcCloud->setNetworkQosParam(param);
}

void TestGeneralSetting::on_enableSmallVideoStream_clicked(bool checked) {
    trtc::TRTCVideoEncParam param;
    param.videoResolution = trtc::TRTCVideoResolution_160_160;
    param.videoBitrate = 100;
    m_trtcCloud->enableSmallVideoStream(checked, param);
}

void TestGeneralSetting::on_smallButton_clicked(bool checked) {
    for (int i = 1; i < m_userIds.count(); i++) {
        std::string uid = m_userIds.at(i).toStdString();
        // 选定观看指定 userId 的大画面还是小画面：即高清/低清
        m_trtcCloud->setRemoteVideoStreamType(uid.c_str(), checked ? trtc::TRTCVideoStreamTypeSmall : trtc::TRTCVideoStreamTypeBig);
    }
}

void TestGeneralSetting::closeEvent(QCloseEvent *event) {
    hide();
    ui->startCamTestButton->setChecked(false);
    m_trtcCloud->getDeviceManager()->stopCameraDeviceTest();

	m_trtcCloud->stopLocalPreview();
    if (m_localView != nullptr) {
        m_trtcCloud->startLocalPreview(m_localView);
    }

    if (ui->startSpeedTest->isChecked()) {
        m_trtcCloud->stopSpeedTest();
        ui->startSpeedTest->setEnabled(true);
        ui->startSpeedTest->setChecked(false);
        ui->speedTestLabel->setText("");
    }
}

void TestGeneralSetting::onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *extraInfo) { }
void TestGeneralSetting::onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo) { }
void TestGeneralSetting::onEnterRoom(int result) { }
void TestGeneralSetting::onExitRoom(int reason) { }
