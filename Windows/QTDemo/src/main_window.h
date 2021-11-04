//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//
#pragma once

#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QSettings>

#include "defs.h"
#include "ITRTCCloud.h"
#include "trtc_cloud_callback_default_impl.h"

#include "ui_MainWindow.h"

#include "test_log_setting.h"
#include "test_network_check.h"
#include "test_base_scene.h"
#include "test_cdn_publish.h"
#include "test_mix_stream_publish.h"
#include "test_cdn_player.h"
#include "test_screen_share_setting.h"
#include "test_custom_capture.h"
#include "test_custom_render.h"
#include "test_bgm_setting.h"
#include "test_subcloud_setting.h"
#include "test_connect_other_room.h"
#include "test_device_manager.h"
#include "test_audio_detect.h"
#include "test_video_detect.h"
#include "test_beauty_and_watermark.h"
#include "test_audio_setting.h"
#include "test_video_setting.h"
#include "test_custom_message.h"
#include "test_audio_record.h"
#include "test_user_video_group.h"

class MainWindow : public QMainWindow,public TrtcCloudCallbackDefaultImpl{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow() override;

private:
    //============= ITRTCCloudCallback  start ===================//
    void onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo) override;
    void onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *extraInfo) override;

    void onEnterRoom(int result) override;  //For updating UI only
    void onExitRoom(int reason) override;   //For updating UI only
    //============= ITRTCCloudCallback end===================//

private slots :
    void on_logSettingQbtn_clicked();

    void on_btnNetworkChecker_clicked();

    void on_userIdLineEdit_textChanged(const QString &userId);
    void on_roomNumLineEdit_textChanged(const QString &roomNum);

    void on_enterRoomButton_clicked();
    void on_exitRoomButton_clicked();

    void on_appSceneComboBox_currentIndexChanged(int index);
    void on_userRoleComB_currentIndexChanged(int index);
    void on_languageComboBox_currentIndexChanged(int index);

    void on_cdnPublishBt_clicked();
    void on_mixStreamPublish_clicked();

    void on_btScreenSharingSetting_clicked();

    void on_btnCustomCapture_clicked();
    void on_btnCustomRender_clicked();

    void on_btnStartBGMSetting_clicked();

    void on_btnEnterSubRoom_clicked();

    void on_btnEnterOtherRoom_clicked();

    void on_pushButtonDeviceManager_clicked();

    void on_pushButtonAudioTest_clicked();
    void on_pushButtonVideoTest_clicked();

    void on_pushButtonBeautyWaterMark_clicked();

    void on_pushButtonAudioSetting_clicked();
    void on_pushButtonVideoSetting_clicked();

    void on_pushButtonCustomMessage_clicked();

    void on_pushButtonAudioRecord_clicked();

    void on_pushButtonCdnPlayer_clicked();

    void onConnectOtherRoomResult(bool result);
    void onExitOtherRoomConnection();

    void onEnterSubRoomResult(bool result);
    void onExitSubRoom();
public:
    void closeEvent(QCloseEvent *event) override;
    void changeEvent(QEvent* event);
private:
    void updateModuleButtonStatus(bool isEnteredRoom);
    void updateModuleDialogStatus(bool isEnteredRoom);
    trtc::TRTCAppScene getCurrentSelectedAppScene();
    trtc::TRTCRoleType getCurrentSelectedRoleType();
    void changeLanguage(int language);
    void updateDynamicTextUI();
private:
    std::unique_ptr<Ui::MainWindow> ui_mainwindow_;

    std::shared_ptr<TestUserVideoGroup> test_user_video_group_;

    TestBaseScene test_base_scene_;

    TestSubCloudSetting test_subcloud_setting_;

    TestLogSetting test_log_setting_;

    TestNetworkCheck test_network_check_;

    TestCdnPublish test_cdn_publish_;

    TestMixStreamPublish test_mixstream_publish_;

    TestCdnPlayer test_cdn_player_;

    TestScreenShareSetting test_screen_share_setting_;

    TestCustomCapture test_custom_capture_;

    TestCustomRender test_custom_render_;

    TestBGMSetting test_bgm_setting_;

    TestConnectOtherRoom test_connect_other_room_;

    TestDeviceManager test_device_manager_;

    TestAudioDetect test_audio_detect_;

    TestVideoDetect test_video_detect_;

    TestBeautyAndWaterMark test_beauty_watermark_;

    TestAudioSetting test_audio_setting_;

    TestVideoSetting test_video_setting_;

    TestCustomMessage test_custom_message_;

    TestAudioRecord test_audio_record_;

    std::vector<BaseDialog*> module_widgets_;
    std::vector<BaseDialog*> enter_room_based_widgets_;
    bool room_entered_ = false;
    bool subroom_entered_ = false;
    bool cross_room_pk_entered_ = false;
};
#endif // MAINWINDOW_H
