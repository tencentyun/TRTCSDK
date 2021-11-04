#include "test_cdn_publish.h"

#include <QMessageBox>
#include <QDebug>

#include "room_info_holder.h"

TestCdnPublish::TestCdnPublish(QWidget *parent):BaseDialog(parent),ui(new Ui::TestCdnPublishDialog){
    ui->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    getTRTCShareInstance()->addCallback(this);
}
TestCdnPublish::~TestCdnPublish(){
    getTRTCShareInstance()->removeCallback(this);

    if(is_publishing_){
        stopPublishing();
    }

    if(ui != nullptr){
        delete  ui;
        ui = nullptr;
    }
}

void TestCdnPublish::stopPublishing(){
    if(is_publishing_) {
        getTRTCShareInstance()->stopPublishing();
    }
}

void TestCdnPublish::startPublishing(std::string streamId){
    if(!is_publishing_) {
        getTRTCShareInstance()->startPublishing(streamId.c_str(),trtc::TRTCVideoStreamTypeBig);
    }
}

//============= ITRTCCloudCallback start ===============//
void TestCdnPublish::onStartPublishing (int err, const char *errMsg){
    if(err == 0){
        is_publishing_ = true;
        std::string publish_streamid = ui->streamIdLineEt->text().toStdString();
        RoomInfoHolder::GetInstance().setCDNPublishStreamId(publish_streamid);
        updateDynamicTextUI();
    } else {
        QMessageBox::warning(this,"CDN publishing failed",errMsg,QMessageBox::Yes);
    }
    ui->switchPublishStatus->setEnabled(true);
    ui->streamIdLineEt->setEnabled(true);
}

void TestCdnPublish::onStopPublishing (int err, const char *errMsg){
    if(err == 0){
        is_publishing_ = false;
        updateDynamicTextUI();
    } else if (is_manual_closing_ && std::strstr(errMsg,"-102069") != NULL){
        QMessageBox::warning(this,QString::fromUtf8("Cannot disable global auto-relayed push"),QString::fromUtf8("To manually control relayed push, go to Application Management > Function Configuration in the console, and set \"Relayed Push Mode\" to \"Specified stream for relayed push\"."));
        qDebug() << "err:" << err << "errMsg:" << errMsg;
    }

    is_manual_closing_ = false;
    ui->switchPublishStatus->setEnabled(true);
    ui->streamIdLineEt->setEnabled(true);
}
//============= ITRTCCloudCallback end =================//

void TestCdnPublish::showEvent(QShowEvent *event){
    ui->streamIdLineEt->setText(QString::fromStdString(RoomInfoHolder::GetInstance().getCDNPushishStreamId()));
    BaseDialog::showEvent(event);
}

void TestCdnPublish::on_switchPublishStatus_clicked(){
    if(is_publishing_) {
        ui->streamIdLineEt->setEnabled(true);
        is_manual_closing_ = true;
        stopPublishing();
    } else {
        std::string streamid_str = ui->streamIdLineEt->text().toStdString();
        if(streamid_str.empty()){
            QMessageBox::warning(this,"CDN publishing failed","Enter a stream ID.",QMessageBox::Yes);
            return;
        }
        startPublishing(streamid_str);
        ui->streamIdLineEt->setEnabled(false);
    }
}

void TestCdnPublish::on_streamIdLineEt_textChanged(const QString &streamId){
    if(streamId.isEmpty()){
        ui->switchPublishStatus->setEnabled(false);
    }else {
        ui->switchPublishStatus->setEnabled(true);
    }

    // Modify stream_id and publish again.
    is_publishing_ = false;
    updateDynamicTextUI();
}

void TestCdnPublish::updateDynamicTextUI() {
    if (is_publishing_) {
        ui->switchPublishStatus->setText(tr("停止发布"));
    } else {
        ui->switchPublishStatus->setText(tr("开始发布"));
    }
}

void TestCdnPublish::retranslateUi() {
    ui->retranslateUi(this);
}