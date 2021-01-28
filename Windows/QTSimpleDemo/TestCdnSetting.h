//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef TESTCDNSETTING_H
#define TESTCDNSETTING_H

#include <QDialog>
#include "ITRTCCloud.h"
#include "base/AlertDialog.h"

namespace Ui {
class TestCdnSetting;
}

/// 混流设置
class TestCdnSetting : public QDialog, public trtc::ITRTCCloudCallback {
    Q_OBJECT

public:
    explicit TestCdnSetting(QWidget *parent = nullptr);
    ~TestCdnSetting() override;
    void closeEvent(QCloseEvent *) override;
    void setUserId(QString &userId);
    void setRoomId(QString &roomId);

    void onExitRoom(int reason) override;
    void onEnterRoom(int result) override;
    void onUserVideoAvailable(const char *userId, bool available) override;
    void onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo) override;
    void onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *extraInfo) override;

private slots:
    void on_startPublishingBtn_clicked(bool checked);
    void on_videoBitrate_valueChanged(int value);
    void on_updateMixTranscodingConfigBtn_clicked();

private:
    Ui::TestCdnSetting *ui;
    trtc::ITRTCCloud *m_trtcCloud;
    AlertDialog m_messageTipDialog;
    trtc::TRTCTranscodingConfig m_transcodingConfig;

    std::string m_userId;
    std::string m_roomId;
    QVector<QString> m_userIds;
    trtc::TRTCMixUser *m_mixUsersArray = nullptr;
    std::string m_backgroundImage;
    std::string m_streamId;

    void cancleMixTranscodingConfig();
    bool checkMixTranscodingAbility();
};

#endif // TESTCDNSETTING_H
