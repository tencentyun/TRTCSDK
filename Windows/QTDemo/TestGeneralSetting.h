//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef TESTGENERALSETTING_H
#define TESTGENERALSETTING_H

#include <QDialog>
#include "ITRTCCloud.h"
#include <QTemporaryDir>
#include <string>

namespace Ui {
class TestGeneralSetting;
}

/// 常规设置
class TestGeneralSetting : public QDialog, public trtc::ITRTCCloudCallback {
    Q_OBJECT

public:
    explicit TestGeneralSetting(QWidget *parent = nullptr);
    ~TestGeneralSetting() override;


    // 用户ID
    void setUserId(QString &userId);
    void setUserIds(const QVector<QString> &userIds);
    void setLocalPreview(trtc::TXView localPreview);

    void closeEvent(QCloseEvent *event) override;

    void onEnterRoom(int result) override;
    void onExitRoom(int reason) override;
    void onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo) override;
    void onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *extraInfo) override;
    void onSpeedTest(const trtc::TRTCSpeedTestResult& currentResult, uint32_t finishedCount, uint32_t totalCount) override;

private slots:
    void on_startSpeedTest_clicked(bool checked);
    void on_setConsoleEnabled_clicked(bool checked);
    void on_setLogCompressEnabled_clicked(bool checked);
    void on_setLogLevelComboBox_currentIndexChanged(int index);
    void on_setLogDirPathButton_clicked();
    void on_startCamTestButton_clicked(bool checked);

    void on_smoothButton_clicked(bool checked);
    void on_clearButton_clicked(bool checked);
    void on_userControlButton_clicked(bool checked);
    void on_cloudControlButton_clicked(bool checked);
    void on_enableSmallVideoStream_clicked(bool checked);
    // 选定观看指定 userId 的大画面还是小画面
    void on_smallButton_clicked(bool checked);

private:
    Ui:: TestGeneralSetting *ui;
    trtc::ITRTCCloud *m_trtcCloud;
    trtc::TXView m_localView;
    QTemporaryDir m_tempDir;

    QString m_userId;
    QVector<QString> m_userIds;

    // 设置SDK版本号
    void setSDKVersion();
    void updateBeautyStyle();
    void updateNetworkQosParam();
};

#endif // TESTGENERALSETTING_H
