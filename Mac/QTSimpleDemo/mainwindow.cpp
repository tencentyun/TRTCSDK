//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#include "mainwindow.h"
#include <QtDebug>
#include "ITXDeviceManager.h"
#include <QVBoxLayout>
#include "ui_TestVideoSetting.h"
#ifdef __APPLE__
#include "GenerateTestUserSig.h"
#endif
#ifdef _WIN32
#include "GenerateTestUsersig.h"
#endif

#define PREFERENCES_PATH "/Documents/TRTCCache/Config/UserPreferences.ini"

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent), ui(new Ui::MainWindow) {
    ui->setupUi(this);

    m_trtcCloud = getTRTCShareInstance();
    if (m_trtcCloud == nullptr) return;

    m_trtcCloud->addCallback(this);
    m_trtcCloud->setLogCallback(this);

    setupIcons();
    setupSettings();
    showVideoListView();

    // Auto enter room
//    on_enterRoomButton_clicked();
}

MainWindow::~MainWindow() {
    if (m_trtcCloud) {
        m_trtcCloud->removeCallback(this);
        m_trtcCloud = nullptr;
    }
    if (m_settings) {
        delete m_settings;
        m_settings = nullptr;
    }
    if (ui) {
        delete ui;
        ui = nullptr;
    }
}

void MainWindow::on_enterRoomButton_clicked() {
    if (!checkConfig() || !checkEnterRoomAbility()) return;

    // 构造进房参数
    trtc::TRTCParams params;
    params.role = getRole();
    params.sdkAppId = SDKAppID;
    std::string uid = m_userId.toStdString();
    params.userId = uid.c_str();
    std::string strRoomId;
    if (isStrRoomId()) {
        params.roomId = 0;
        strRoomId = m_strRoomId.toStdString();
        params.strRoomId = strRoomId.c_str();
    } else {
        params.roomId = m_strRoomId.toUInt();
    }

#ifdef __APPLE__
    std::string userSig = GenerateTestUserSig().genTestUserSig(uid.c_str(), SDKAppID, SECRETKEY);
#endif
#ifdef _WIN32
	std::string strKey = SECRETKEY;
    std::string userSig = GenerateTestUserSig::instance().genTestUserSig(SDKAppID, strKey, params.userId).c_str();
#endif
    params.userSig = userSig.c_str();

    /* 可以不填写, "321123"只是简单测试使用
     * 推荐方案是：进房时使用 “sdkappid_roomid_userid_main” 作为 streamid，这样比较好辨认且不会在您的多个应用中发生冲突 */
    params.streamId = "321123";
    m_cdnSetting.setUserId(m_userId);
    m_cdnSetting.setRoomId(m_strRoomId);

    // 进房
    m_videoListView.enterRoom(params, getScene());
}

void MainWindow::on_leaveRoomButton_clicked() {
    m_trtcCloud->exitRoom();
}

void MainWindow::onEnterRoom(int result) {
    if (result > 0) {
        // 进房成功
        setupSettingBtns(true);
    } else {
        // 进房失败
        failToEnterRoom(result);
    }
}

void MainWindow::onExitRoom(int reason) {
    reset();
    m_screenSharing.stopScreenCapture();
}

void  MainWindow::onUserVideoAvailable(const char *userId, bool available) {
    m_generalSetting.setUserIds(m_videoListView.m_userIds);
}

void MainWindow::on_userNameLineEdit_textChanged(const QString &arg1) {
    if (arg1.length() < 1) {
        ui->enterRoomButton->setEnabled(false);
        return;
    }
    if (m_settings) {
        m_settings->setValue("userName", arg1);
    }
    QString roomId = ui->roomNameLineEdit->text();
    ui->enterRoomButton->setEnabled(roomId.length() > 0);
    m_userId = arg1;
}

void MainWindow::on_roomNameLineEdit_textChanged(const QString &arg1) {
    if (arg1.length() < 1) {
        ui->enterRoomButton->setEnabled(false);
        return;
    }
    if (m_settings) {
        m_settings->setValue("roomName", arg1);
    }
    QString userName = ui->userNameLineEdit->text();
    ui->enterRoomButton->setEnabled(userName.length() > 0);
    m_strRoomId = arg1;
}

void MainWindow::on_strRoomIdCheckBox_clicked(bool checked) {
    if (m_settings) {
        m_settings->setValue("isStrRoom", checked);
    }
}

void MainWindow::on_roleComboBox_currentIndexChanged(int index) {
    // 切换角色，仅适用于直播场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom）
    m_trtcCloud->switchRole(getRole());
}

void MainWindow::on_appSceneComboBox_currentIndexChanged(int index) {
    bool enable = (index == 1 || index== 3) ? true : false;
    ui->roleComboBox->setEnabled(enable);
}

void MainWindow::on_audioSettingButton_clicked() {
    m_audioSetting.show();
    m_audioSetting.raise();
}

void MainWindow::on_cdnSettingButton_clicked() {
    m_cdnSetting.show();
    m_cdnSetting.raise();
}

void MainWindow::on_screenShareSettingButton_clicked() {
    m_screenSharing.show();
    m_screenSharing.raise();
    m_screenSharing.updateScreenShareSources();
	// 关闭高级设置弹框
	m_advanceSetting.closeEvent(nullptr);
}

void MainWindow::on_videoSettingButton_clicked() {
    m_trtcCloud->stopLocalPreview();
    m_videoSetting.show();
    m_videoSetting.raise();
    m_videoSetting.setUserIds(m_videoListView.m_userIds);
    m_videoSetting.setRenderView(m_videoListView.getLocalView());
}

void MainWindow::on_generalSettingButton_clicked() {
    m_generalSetting.setLocalPreview(reinterpret_cast<trtc::TXView>(m_videoListView.getLocalView()->winId()));
    m_generalSetting.setUserIds(m_videoListView.m_userIds);
    m_generalSetting.setUserId(m_userId);
    m_generalSetting.show();
    m_generalSetting.raise();
}

void MainWindow::on_advancedSettingButton_clicked() {
    m_advanceSetting.setLocalPreview(reinterpret_cast<trtc::TXView>(m_videoListView.getLocalView()->winId()));
    m_advanceSetting.show();
    m_advanceSetting.raise();
	// 关闭屏幕分享弹框
    m_screenSharing.stopScreenCapture();
    m_screenSharing.closeEvent(nullptr);
}

void MainWindow::on_bgmSettingButton_clicked() {
    m_bgmSetting.show();
    m_bgmSetting.raise();
}

inline bool MainWindow::checkConfig() {
    bool isInvalidConfig = SDKAppID == 0 || strlen(SECRETKEY) == 0;
    if (isInvalidConfig) {
        // 非法配置
        m_alertDialog.showMessageTip("请检查您【Headers/base/Defs.h】头文件中的\n【SDKAppID || SECRETKEY】\n配置是否正确");
    }
    return !isInvalidConfig;
}

inline trtc::TRTCRoleType MainWindow::getRole() {
    int index = ui->roleComboBox->currentIndex();
    trtc::TRTCRoleType type = static_cast<trtc::TRTCRoleType>(index + 20); // TRTCRoleType is begin with 20
    return type;
}

inline trtc::TRTCAppScene MainWindow::getScene() {
    int style = ui->appSceneComboBox->currentIndex();
    return static_cast<trtc::TRTCAppScene>(style);
}

inline bool MainWindow::isStrRoomId() {
    return ui->strRoomIdCheckBox->checkState() == Qt::Checked;
}

inline void MainWindow::showVideoListView() {
    m_videoListView.setGeometry(ui->widget->geometry());
    m_videoListView.setParent(this);
    m_videoListView.show();

    ui->strRoomIdCheckBox->setStyleSheet("QCheckBox{color:rgb(100,150,255)}");
}

void MainWindow::setupSettings() {
    QString filename = QDir::homePath() + PREFERENCES_PATH;
    m_settings = new QSettings(filename, QSettings::IniFormat);
    m_settings->setIniCodec("UTF-8");

    QString userName = m_settings->value("userName").toString();
    QString roomName = m_settings->value("roomName").toString();
    bool isStrRoom = m_settings->value("isStrRoom").toBool();

    on_userNameLineEdit_textChanged(userName);
    on_roomNameLineEdit_textChanged(roomName);
    ui->userNameLineEdit->setText(userName);
    ui->roomNameLineEdit->setText(roomName);
    ui->strRoomIdCheckBox->setChecked(isStrRoom);
}

void MainWindow::setupIcons() {
    setupIcons(ui->advancedSettingButton, "advance_setting");
    setupIcons(ui->generalSettingButton, "general_setting");
    setupIcons(ui->audioSettingButton, "audio_setting");
    setupIcons(ui->videoSettingButton, "video_setting");
    setupIcons(ui->cdnSettingButton, "cdn_setting");
    setupIcons(ui->bgmSettingButton, "music_setting");
    setupIcons(ui->screenShareSettingButton, "screen_share_setting");
}

inline void MainWindow::setupIcons(QPushButton *button, const QString& fileName) {
    QPixmap pixmap(":/setting/image/setting/" + fileName + ".png");
    QIcon icon(pixmap);
    button->setIcon(icon);
    button->setIconSize(QSize(20, 20));
}

inline void MainWindow::reset() {
    setupSettingBtns(false);
    sendCloseEventToDialogView();
}

void MainWindow::setupSettingBtns(bool enabled) {
    ui->screenShareSettingButton->setEnabled(enabled);
    ui->leaveRoomButton->setEnabled(enabled);
    ui->bgmSettingButton->setEnabled(enabled);
    ui->videoSettingButton->setEnabled(enabled);
    ui->cdnSettingButton->setEnabled(enabled);
    ui->audioSettingButton->setEnabled(enabled);
    ui->advancedSettingButton->setEnabled(enabled);
}

inline void MainWindow::failToEnterRoom(int result) {
    // 进房失败
    QString errorTip("进房失败，错误码：");
    errorTip.append(QString::number(result));
    errorTip.append("。请您检查\n【房间号、用户ID、SDKAppID、SECRETKEY】\n是否合法");
    std::string msg = errorTip.toStdString();
    m_alertDialog.showMessageTip(msg.c_str());
}

inline bool MainWindow::checkEnterRoomAbility() {
    bool hasEnterRoom = ui->leaveRoomButton->isEnabled();
    if (hasEnterRoom) {
        m_alertDialog.showMessageTip("您已进房~");
    }
    return !hasEnterRoom;
}

void MainWindow::closeEvent(QCloseEvent *event) {
    sendCloseEventToDialogView();
    on_leaveRoomButton_clicked();
}

void MainWindow::sendCloseEventToDialogView() {
    m_bgmSetting.closeEvent(nullptr);
    m_cdnSetting.closeEvent(nullptr);
    m_videoSetting.closeEvent(nullptr);
    m_audioSetting.closeEvent(nullptr);
    m_screenSharing.closeEvent(nullptr);
    m_advanceSetting.closeEvent(nullptr);
    m_generalSetting.closeEvent(nullptr);
}

void MainWindow::onLog(const char* log, trtc::TRTCLogLevel level, const char* module)
{ qDebug() << "log: " << log << "  level: " << level << "  module: " << module; }
void MainWindow::onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo)
{ qDebug() << "errCode: " << errCode << "  errMsg: " << errMsg << "  extraInfo: " << extraInfo; }
void MainWindow::onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *extraInfo)
{ qDebug() << "warningCode: " << warningCode << "  warningMsg: " << warningMsg << "  extraInfo: " << extraInfo; }
