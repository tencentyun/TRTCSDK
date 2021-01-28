//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#include "TestAdvanceSetting.h"
#include "ui_TestAdvanceSetting.h"
#include <QFileDialog>

static uint CMDCount = 0;
static uint SEICount = 0;

TestAdvanceSetting::TestAdvanceSetting(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::TestAdvanceSetting) {
    ui->setupUi(this);

    m_trtcCloud = getTRTCShareInstance();
    if (m_trtcCloud != nullptr) m_trtcCloud->addCallback(this);
}

TestAdvanceSetting::~TestAdvanceSetting() {
    if (m_trtcCloud != nullptr) {
        m_trtcCloud->removeCallback(this);
        m_trtcCloud = nullptr;
    }
    delete ui;
}

void TestAdvanceSetting::setLocalPreview(trtc::TXView localPreview) {
    m_localPreview = localPreview;
}

void TestAdvanceSetting::initYuvWidgetView() {
    static bool isFirstInit = true;
    if (isFirstInit == false) return;
    isFirstInit = false;

    m_yuvWidgetView.setGeometry(ui->dialogLocalView->geometry());
    m_yuvWidgetView.hide();
}

void TestAdvanceSetting::on_customRender_clicked(bool checked) {
    if (checked) {
        initYuvWidgetView();
#ifdef _WIN32
        m_trtcCloud->stopLocalPreview();
#endif
        m_trtcCloud->startLocalPreview(nullptr);
        m_trtcCloud->setLocalVideoRenderCallback(trtc::TRTCVideoPixelFormat_I420, trtc::TRTCVideoBufferType_Buffer, this);

        QWidget *dialogLocalView = ui->dialogLocalView;
        dialogLocalView->lower();
        m_yuvWidgetView.show();
        m_yuvWidgetView.raise();
    } else {
        stopCustomRender();
#ifdef _WIN32
		m_trtcCloud->stopLocalPreview();
		m_trtcCloud->startLocalPreview(m_localPreview);
#endif
    }
}

void TestAdvanceSetting::onRenderVideoFrame(const char *userId, trtc::TRTCVideoStreamType streamType, trtc::TRTCVideoFrame *frame) {
    m_yuvWidgetView.slotShowYuv(reinterpret_cast<uchar *>(frame->data), frame->width, frame->height);
}

void TestAdvanceSetting::on_sendCustomCmdMsg_clicked() {
    bool ordered = ui->ordered->checkState();
    bool reliable = ui->reliable->checkState();
    // cmdId取值范围：[1 ~ 10]
    uint32_t cmdId = ui->cmdId->text().toUInt();
    cmdId = cmdId < 1  ? 1  : cmdId;
    cmdId = cmdId > 10 ? 10 : cmdId;
    QLineEdit *msgLineEdit = ui->msgLineEdit;
    std::string text = msgLineEdit->text().toStdString();
    const char *msg = text.c_str();
    const uint8_t *data = reinterpret_cast<const uint8_t *>(msg);
    m_trtcCloud->sendCustomCmdMsg(cmdId, data, strlen(msg), reliable, ordered);
}

void TestAdvanceSetting::on_sendSEIMsg_clicked() {
    int32_t repeatCount = ui->repeatCount->text().toInt();
    std::string text = ui->msgLineEdit->text().toStdString();
    const char *msg = text.c_str();
    const uint8_t *data = reinterpret_cast<const uint8_t *>(msg);
    m_trtcCloud->sendSEIMsg(data, strlen(msg), repeatCount);
}

void TestAdvanceSetting::closeEvent(QCloseEvent *event) {
    reset();
    hide();
    stopCustomRender();
}

inline void TestAdvanceSetting::stopCustomRender() {
    m_trtcCloud->setLocalVideoRenderCallback(trtc::TRTCVideoPixelFormat_Unknown, trtc::TRTCVideoBufferType_Unknown, nullptr);
    m_yuvWidgetView.hide();
    ui->customRender->setChecked(false);
}

inline void TestAdvanceSetting::reset() {
    SEICount = 0;
    CMDCount = 0;
    ui->res->setText("");
}

void TestAdvanceSetting::onRecvCustomCmdMsg(const char* userId, int32_t cmdID, uint32_t seq, const uint8_t* message, uint32_t messageSize) {
    CMDCount ++;
    QString text("CMD: ");
    text = "userId: " + QString(userId) +
            ", cmdID: " + QString(QString::number(cmdID)) +
            ", seq: " + QString(QString::number(seq)) +
            ", message: " + QString(reinterpret_cast<const char *>(message)) +
            ", messageSize: " + QString(QString::number(messageSize)) +
            ", CMDCount: " + QString(QString::number(CMDCount));
    ui->res->setText(text);
}

void TestAdvanceSetting::onMissCustomCmdMsg(const char* userId, int32_t cmdID, int32_t errCode, int32_t missed) {
    QString text("SEI: ");
    text = "userId: " + QString(userId) +
            ", cmdID: " + QString(QString::number(cmdID)) +
            ", errCode: " + QString(QString::number(errCode)) +
            ", missed: " + QString(QString::number(missed));
    ui->res->setText(text);
}

void TestAdvanceSetting::onRecvSEIMsg(const char* userId, const uint8_t* message, uint32_t messageSize) {
    SEICount ++;
    QString text("");
    text = "userId: " + QString(userId) +
            ", message: " + QString(reinterpret_cast<const char *>(message)) +
            ", messageSize: " + QString(QString::number(messageSize)) +
            ", SEICount: " + QString(QString::number(SEICount));
    ui->res->setText(text);
}

void TestAdvanceSetting::onConnectOtherRoom(const char* userId, TXLiteAVError errCode, const char* errMsg) {
    if (errCode != ERR_NULL) {
        // 跨房失败
        ui->connectOtherRoomBox->setChecked(false);
        QString msgTip = QString("ConnectOtherRoom fail, error code: ");
        msgTip.append(QString::number(errCode));
        msgTip.append(", errMsg: ");
        msgTip.append(errMsg);
        msgTip.append(", userId: ");
        msgTip.append(userId);
        std::string msg = msgTip.toStdString();
        m_messageTipDialog.showMessageTip(msg.c_str());
    }
}

void TestAdvanceSetting::on_otherRoomNameLineEdit_textChanged(const QString &arg1) {
    if (arg1.length() < 1) {
        ui->connectOtherRoomBox->setEnabled(false);
        return;
    }
    QString userName = ui->otherUserNameLineEdit->text();
    ui->connectOtherRoomBox->setEnabled(userName.length() > 0);
}

void TestAdvanceSetting::on_otherUserNameLineEdit_textChanged(const QString &arg1) {
    if (arg1.length() < 1) {
        ui->connectOtherRoomBox->setEnabled(false);
        return;
    }
    QString roomId = ui->otherRoomNameLineEdit->text();
    ui->connectOtherRoomBox->setEnabled(roomId.length() > 0);
}

void TestAdvanceSetting::on_connectOtherRoomBox_clicked(bool checked) {
    if (checked) {
        // 发起跨房
        QLineEdit *otherRoomNameLineEdit = ui->otherRoomNameLineEdit;
        std::string otherRoomStr = otherRoomNameLineEdit->text().toStdString();
        QLineEdit *otherUserNameLineEdit = ui->otherUserNameLineEdit;
        std::string otherUserNameStrStr = otherUserNameLineEdit->text().toStdString();
        // 获取参数信息
        std::string params = "{\"strRoomId\":\"";
        params = params + otherRoomStr;
        params = params + "\",";
        params = params + "\"userId\":\"";
        params = params + otherUserNameStrStr;
        params = params + "\"}";
        // 开始跨房PK
        m_trtcCloud->connectOtherRoom(params.c_str());
    } else {
        disconnectOtherRoom();
    }
}

inline void TestAdvanceSetting::disconnectOtherRoom() {
    // 取消跨房PK
    m_trtcCloud->disconnectOtherRoom();
}

void TestAdvanceSetting::onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *extraInfo) { }
void TestAdvanceSetting::onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo) { }
void TestAdvanceSetting::showEvent(QShowEvent *) { }
void TestAdvanceSetting::onEnterRoom(int result) { }
void TestAdvanceSetting::onExitRoom(int reason) { }

