//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include "ITRTCCloud.h"
#include "ui_mainwindow.h"
#include "base/VideoListView.h"
#include "base/AlertDialog.h"
#include "base/Defs.h"
#include <QSettings>
#include <mutex>

#include "TestGeneralSetting.h"
#include "TestAudioSetting.h"
#include "TestCdnSetting.h"
#include "TestAdvanceSetting.h"
#include "TestVideoSetting.h"
#include "TestScreenSharing.h"
#include "TestBGMSetting.h"

QT_BEGIN_NAMESPACE
namespace Ui {
class MainWindow;
}
QT_END_NAMESPACE

class MainWindow : public QMainWindow, public trtc::ITRTCLogCallback, public trtc::ITRTCCloudCallback {
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow() override;
    void closeEvent(QCloseEvent *event) override;

private slots:
    void on_userNameLineEdit_textChanged(const QString &arg1);
    void on_roomNameLineEdit_textChanged(const QString &arg1);

    void on_enterRoomButton_clicked();
    void on_leaveRoomButton_clicked();

    void on_roleComboBox_currentIndexChanged(int index);
    void on_appSceneComboBox_currentIndexChanged(int index);

    /// 功能设置按钮的点击事件
    void on_generalSettingButton_clicked();
    void on_audioSettingButton_clicked();
    void on_bgmSettingButton_clicked();
    void on_videoSettingButton_clicked();
    void on_advancedSettingButton_clicked();
    void on_cdnSettingButton_clicked();
    void on_screenShareSettingButton_clicked();
    void on_strRoomIdCheckBox_clicked(bool checked);

private:
    Ui::MainWindow *ui = nullptr;
    QSettings *m_settings = nullptr;
    const char *m_userid = nullptr;
    trtc::ITRTCCloud *m_trtcCloud = nullptr;

    // 本地登录的用户ID
    QString m_userId;
    // 字符串房间号
    QString m_strRoomId;

    AlertDialog m_alertDialog;
    VideoListView m_videoListView;

    TestCdnSetting m_cdnSetting;
    TestBGMSetting m_bgmSetting;
    TestVideoSetting m_videoSetting;
    TestAudioSetting m_audioSetting;
    TestScreenSharing m_screenSharing;
    TestGeneralSetting m_generalSetting;
    TestAdvanceSetting m_advanceSetting;

    // 是否开启字符串类型的房间号
    bool isStrRoomId();
    // 获取进房角色
    trtc::TRTCRoleType getRole();
    // 获取进房场景
    trtc::TRTCAppScene getScene();

    // 检查配置
    bool checkConfig();
    // 防止重复点击进房
    bool checkEnterRoomAbility();

    void setupSettings();
    void showVideoListView();
    void setupIcons();
    void setupIcons(QPushButton *button, const QString& fileName);
    // 初始化本地控件按钮的状态，比如进房enable，退房disable
    void setupSettingBtns(bool enabled);

    // 重置，退房时调用
    void reset();
    void failToEnterRoom(int result);
    void sendCloseEventToDialogView();

    void onExitRoom(int reason) override;
    void onEnterRoom(int result) override;
    void onUserVideoAvailable(const char *userId, bool available) override;
    void onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo) override;
    void onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *extraInfo) override;
    void onLog(const char* log, trtc::TRTCLogLevel level, const char* module) override;
};
#endif // MAINWINDOW_H
