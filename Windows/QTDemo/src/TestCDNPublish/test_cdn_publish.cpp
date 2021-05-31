#include "test_cdn_publish.h"

#include <QMessageBox>
#include <QDebug>

#include "room_info_holder.h"

TestCdnPublish::TestCdnPublish(QWidget *parent):QDialog(parent),ui(new Ui::TestCdnPublishDialog){
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
        ui->switchPublishStatus->setText(QString::fromLocal8Bit("停止发布"));
    }else{
        QMessageBox::warning(this,"start publish failed",errMsg,QMessageBox::Yes);
    }
    ui->switchPublishStatus->setEnabled(true);
    ui->streamIdLineEt->setEnabled(true);
}
void TestCdnPublish::onStopPublishing (int err, const char *errMsg){
    if(err == 0){
        is_publishing_ = false;
        ui->switchPublishStatus->setText(QString::fromLocal8Bit("开始发布"));
    }else if(is_manual_closing_ && std::strstr(errMsg,"-102069") != NULL){
        QMessageBox::warning(this,QString::fromUtf8("全局自动旁路不支持关闭"),QString::fromUtf8("如需手动控制旁路推流, 控制台->应用管理->功能配置->修改旁路推送方式为<指定流旁路>"));
        qDebug() << "err:" << err << "errMsg:" << errMsg;
    }

    is_manual_closing_ = false;
    ui->switchPublishStatus->setEnabled(true);
    ui->streamIdLineEt->setEnabled(true);
}
//============= ITRTCCloudCallback end =================//

void TestCdnPublish::showEvent(QShowEvent *event){
    ui->streamIdLineEt->setText(QString::fromStdString(RoomInfoHolder::GetInstance().getCDNPushishStreamId()));
}

void TestCdnPublish::on_switchPublishStatus_clicked(){
    if(is_publishing_) {
        ui->streamIdLineEt->setEnabled(true);
        is_manual_closing_ = true;
        stopPublishing();
    } else {
        std::string streamid_str = ui->streamIdLineEt->text().toStdString();
        if(streamid_str.empty()){
            QMessageBox::warning(this,"WARNING","must input streamid",QMessageBox::Yes);
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

    //修改stream_id 可重新开始发布
    is_publishing_ = false;
    ui->switchPublishStatus->setText(QString::fromLocal8Bit("开始发布"));
}
