//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef TESTADVANCESETTING_H
#define TESTADVANCESETTING_H

#include <QDialog>
#include "ITRTCCloud.h"
#include "base/GLYuvWidget.h"
#include "base/AlertDialog.h"

namespace Ui {
class TestAdvanceSetting;
}

/// 高级功能
class TestAdvanceSetting : public QDialog, public trtc::ITRTCVideoRenderCallback, public trtc::ITRTCCloudCallback
{
    Q_OBJECT

public:
    explicit TestAdvanceSetting(QWidget *parent = nullptr);
    ~TestAdvanceSetting() override;

    void setLocalPreview(trtc::TXView localPreview);

    // 关闭窗口
    void closeEvent(QCloseEvent *event) override;
    void showEvent(QShowEvent *) override;
    // 房间事件回调
    void onEnterRoom(int result) override;
    void onExitRoom(int reason) override;
    void onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo) override;
    void onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *extraInfo) override;
    void onConnectOtherRoom(const char* userId, TXLiteAVError errCode, const char* errMsg) override;
    // 自定义视频渲染回调
    void onRenderVideoFrame(const char *userId, trtc::TRTCVideoStreamType streamType, trtc::TRTCVideoFrame *frame) override;
    // 自定义消息回调
    void onRecvSEIMsg(const char* userId, const uint8_t* message, uint32_t messageSize) override;
    void onMissCustomCmdMsg(const char* userId, int32_t cmdID, int32_t errCode, int32_t missed) override;
    void onRecvCustomCmdMsg(const char* userId, int32_t cmdID, uint32_t seq, const uint8_t* message, uint32_t messageSize) override;

private slots:
    void on_sendSEIMsg_clicked();
    void on_sendCustomCmdMsg_clicked();
    void on_customRender_clicked(bool checked);

    void on_connectOtherRoomBox_clicked(bool checked);
    void on_otherRoomNameLineEdit_textChanged(const QString &arg1);
    void on_otherUserNameLineEdit_textChanged(const QString &arg1);

private:
    Ui::TestAdvanceSetting *ui;
    trtc::ITRTCCloud *m_trtcCloud;
    trtc::TXView m_localPreview;
    GLYuvWidget m_yuvWidgetView;
    trtc::TRTCRenderParams m_localRenderParams;
    AlertDialog m_messageTipDialog;

    void reset();
    void stopCustomRender();
    void initYuvWidgetView();
    void disconnectOtherRoom();
};

#endif // TESTADVANCESETTING_H
