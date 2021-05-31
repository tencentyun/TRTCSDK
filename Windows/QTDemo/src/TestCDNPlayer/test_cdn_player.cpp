#include "test_cdn_player.h"

#include <QMessageBox>
#include <QDebug>
#include <QUrl>
#include <QDesktopServices>
#include "defs.h"
#include "ITRTCCloud.h"

TestCdnPlayer::TestCdnPlayer(QWidget *parent):QDialog(parent),ui_test_cdn_player_(new Ui::TestCdnPlayerDialog){
    ui_test_cdn_player_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    ui_test_cdn_player_->lineEtDomain->setText(QString::fromLocal8Bit(DOMAIN_URL));
    live_player_ = new TXLivePlayerProxy();
    live_player_->setRenderMode(TXLIVEPLAYERPROXY_RENDER_MODE_ADAPT);
}

TestCdnPlayer::~TestCdnPlayer(){
    if (live_player_ != nullptr) {
        delete live_player_;
        live_player_ = nullptr;
    }
}

void TestCdnPlayer::on_btStart_clicked(){
    if(live_player_ == nullptr){
        return;
    }

    if (started_) {
        live_player_->stopPlay();
        ui_test_cdn_player_->btStart->setText(QString::fromLocal8Bit("开始").toUtf8());
        ui_test_cdn_player_->btPause->setText(QString::fromLocal8Bit("暂停").toUtf8());
    } else {
        QString stream_id = ui_test_cdn_player_->lineEtStreamId->text();
        QString domain = DOMAIN_URL;

        if (stream_id.isEmpty()) {
            QMessageBox::warning(this, "start failed", "stream_id is invalid", QMessageBox::Ok);
            return;
        }

        if (domain.isEmpty()) {
            QMessageBox::warning(this, "start failed", "domain is invalid", QMessageBox::Ok);
            return;
        }

        QString stream_url = QString("http://%1/live/%2.flv").arg(domain).arg(stream_id);

        std::string play_url = stream_url.toStdString();
        live_player_->setRenderFrame(reinterpret_cast<trtc::TXView>(ui_test_cdn_player_->videoPlaceHolder->winId()));
        live_player_->startPlay(play_url.c_str());
        ui_test_cdn_player_->btStart->setText(QString::fromLocal8Bit("结束").toUtf8());
        ui_test_cdn_player_->btPause->setText(QString::fromLocal8Bit("暂停").toUtf8());
    }

    paused_ = false;
    started_ = !started_;
}

void TestCdnPlayer::on_btPause_clicked(){
    if (!started_) {
        return;
    }

    if (paused_) {
        live_player_->resume();
        ui_test_cdn_player_->btPause->setText(QString::fromLocal8Bit("暂停").toUtf8());
    } else {
        live_player_->pause();
        ui_test_cdn_player_->btPause->setText(QString::fromLocal8Bit("恢复").toUtf8());
    }

    paused_ = !paused_;
}

void TestCdnPlayer::closeEvent(QCloseEvent* event){
    if(started_){
        live_player_->stopPlay();
        ui_test_cdn_player_->btStart->setText(QString::fromLocal8Bit("开始").toUtf8());
        started_ = false;
    }

    if(paused_){
        ui_test_cdn_player_->btPause->setText(QString::fromLocal8Bit("暂停").toUtf8());
        paused_ = false;
    }
}
