#include "test_custom_message.h"

#include <QMessageBox>
#include <string>

using namespace std;

TestCustomMessage::TestCustomMessage(QWidget *parent):
    QDialog(parent),
    ui_custom_message_(new Ui::TestCustomMessageDialog)
{
    ui_custom_message_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    trtccloud_ = getTRTCShareInstance();
    trtccloud_->addCallback(this);
}

TestCustomMessage::~TestCustomMessage()
{
    if(trtccloud_ != nullptr) {
        trtccloud_->removeCallback(this);
        trtccloud_ = nullptr;
    }
}

//============= ITRTCCloudCallback start ===================//
void TestCustomMessage::onRecvSEIMsg(const char *userId, const uint8_t *message, uint32_t messageSize)
{
    QString text("SEI: ");
    text = "userId: " + QString(userId) +
            ", message: " + QString(reinterpret_cast<const char *>(message)) +
            ", messageSize: " + QString(QString::number(messageSize));
    ui_custom_message_->textBrowserMsgDetail->setText(text);
}

void TestCustomMessage::onMissCustomCmdMsg(const char *userId, int32_t cmdID, int32_t errCode, int32_t missed)
{
    QString text("CMD: ");
    text = "userId: " + QString(userId) +
            ", cmdID: " + QString(QString::number(cmdID)) +
            ", errCode: " + QString(QString::number(errCode)) +
            ", missed: " + QString(QString::number(missed));
    ui_custom_message_->textBrowserMsgDetail->setText(text);
}

void TestCustomMessage::onRecvCustomCmdMsg(const char *userId, int32_t cmdID, uint32_t seq, const uint8_t *message, uint32_t messageSize)
{
    QString text("CMD: ");
    text = "userId: " + QString(userId) +
            ", cmdID: " + QString(QString::number(cmdID)) +
            ", seq: " + QString(QString::number(seq)) +
            ", message: " + QString(reinterpret_cast<const char *>(message)) +
            ", messageSize: " + QString(QString::number(messageSize));
    ui_custom_message_->textBrowserMsgDetail->setText(text);
}
//============= ITRTCCloudCallback end ===================//

void TestCustomMessage::sendCustomMessage()
{
    uint32_t cmd_id = ui_custom_message_->lineEditCmdId->text().toUInt();
    if(cmd_id < 1 || cmd_id > 10) {
        QMessageBox::warning(NULL, "ERROR", tr("please input valid cmd id!"));
        return;
    }

    bool ordered = ui_custom_message_->checkBoxReliableAndOrdered->isChecked();
    bool reliable = ordered;
    std::string msg_str = ui_custom_message_->lineEditMsg->text().toStdString();
    const char *msg = msg_str.c_str();
    const uint8_t *data = reinterpret_cast<const uint8_t *>(msg);
    if(trtccloud_->sendCustomCmdMsg(cmd_id, data, strlen(msg), reliable, ordered)) {
        QMessageBox::about(NULL, "TIPS", "send message success!");
    } else {
        QMessageBox::warning(NULL, "ERROR", "send message failed, please check if you have entered room");
    }
}

void TestCustomMessage::sendSEIMessage()
{
    int32_t repeatCount = ui_custom_message_->lineEditRepeatCount->text().toInt();
    std::string msg_str = ui_custom_message_->lineEditMsg->text().toStdString();

    if(repeatCount <= 0) {
        QMessageBox::warning(NULL, "ERROR", tr("msg send times must greater than 0!"));
        return;
    }

    const char *msg = msg_str.data();
    const uint8_t *data = reinterpret_cast<const uint8_t *>(msg);
    if(trtccloud_->sendSEIMsg(data, strlen(msg), repeatCount)) {
        QMessageBox::about(NULL, "TIPS", "send message success!");
    } else {
        QMessageBox::warning(NULL, "ERROR", "send message failed, please check if you have entered room");
    }
}

void TestCustomMessage::on_pushButtonSendCmdMsg_clicked()
{
    sendCustomMessage();
}

void TestCustomMessage::on_pushButtonSendSEIMsg_clicked()
{
    sendSEIMessage();
}

void TestCustomMessage::closeEvent(QCloseEvent *event)
{
    ui_custom_message_->textBrowserMsgDetail->setText("");
}
