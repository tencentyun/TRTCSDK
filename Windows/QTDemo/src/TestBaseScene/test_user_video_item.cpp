#include "test_user_video_item.h"

TestUserVideoItem::TestUserVideoItem(QWidget * parent,trtc::ITRTCCloud* cloud, int roomid, std::string userid, TEST_VIDEO_ITEM::ViewItemType type)
    :QWidget(parent), ui_video_item_(new Ui::TestUserVideoItem), viewtype_(type) {
    this->room_id_ = roomid;
    this->user_id_ = userid;
    this->trtccloud_ = cloud;
    ui_video_item_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    initViews();
    if(this->trtccloud_ != nullptr) {
        setRenderParams();
        setRemoteVideoStreamType();
    }
}

TestUserVideoItem::~TestUserVideoItem() {
    if(trtccloud_ != nullptr){
       trtccloud_ = nullptr;
    }
}

void TestUserVideoItem::muteAudio(bool mute) {
    if (viewtype_ == TEST_VIDEO_ITEM::LocalView) {
        trtccloud_->muteLocalAudio(mute);
        return;
    }

    if (viewtype_ == TEST_VIDEO_ITEM::RemoteView) {
        trtccloud_->muteRemoteAudio(user_id_.c_str(), mute);
        return;
    }

}
void TestUserVideoItem::muteVideo(bool mute) {
    if (viewtype_ == TEST_VIDEO_ITEM::LocalView) {
        trtccloud_->muteLocalVideo(mute);
        return;
    }

    if (viewtype_ == TEST_VIDEO_ITEM::RemoteView) {
        trtccloud_->muteRemoteVideoStream(user_id_.c_str(), mute);
        return;
    }
}

void TestUserVideoItem::setRenderParams() {
    trtc::TRTCRenderParams param;
    param.rotation = rotation_;
    param.fillMode = fill_mode_;
    param.mirrorType = mirror_type_;

    if (viewtype_ == TEST_VIDEO_ITEM::LocalView) {
        trtccloud_->setLocalRenderParams(param);
        return;
    }

    if (viewtype_ == TEST_VIDEO_ITEM::RemoteView) {
        trtccloud_->setRemoteRenderParams(user_id_.c_str(), trtc::TRTCVideoStreamTypeBig, param);
        return;
    }

}
void TestUserVideoItem::setRemoteVideoStreamType() {
    trtccloud_->setRemoteVideoStreamType(user_id_.c_str(), video_stream_type_);
}

void TestUserVideoItem::changeEvent(QEvent* event) {
    if (QEvent::LanguageChange == event->type()) {
        ui_video_item_->retranslateUi(this);
        updateDynamicTextUI();
    }
    QWidget::changeEvent(event);
}

void TestUserVideoItem::initViews() {
    updateDynamicTextUI();
    switch (viewtype_)
    {
    case TEST_VIDEO_ITEM::LocalView:
        audio_available_ = true;
        video_available_ = true;
        ui_video_item_->preSmallVideoBt->setHidden(true);
        break;
    case TEST_VIDEO_ITEM::RemoteView:
        ui_video_item_->audioMuteBt->setEnabled(false);
        ui_video_item_->videoMuteBt->setEnabled(false);
        updateAVMuteView(TEST_VIDEO_ITEM::MuteVideo);
        updateAVMuteView(TEST_VIDEO_ITEM::MuteAudio);
        break;
    case TEST_VIDEO_ITEM::ScreenSharingView:
        break;
    default:
        break;
    }
}

void TestUserVideoItem::updateAVMuteStatus(bool mute, TEST_VIDEO_ITEM::MuteAllType muteType) {
    if(muteType == TEST_VIDEO_ITEM::MuteAudio){
        audio_mute_ = mute;
    }

    if(muteType == TEST_VIDEO_ITEM::MuteVideo){
        video_mute_ = mute;
    }

    updateAVMuteView(muteType);
}

void TestUserVideoItem::updateAVAvailableStatus(bool available, bool mute_all_remote, TEST_VIDEO_ITEM::MuteAllType muteType) {
    if (muteType == TEST_VIDEO_ITEM::MuteAudio) {
        if (mute_all_remote) {
            audio_mute_ = true;
        }
        ui_video_item_->audioMuteBt->setEnabled(true);
        audio_available_ = available;
        updateAVMuteView(TEST_VIDEO_ITEM::MuteAudio);
        ui_video_item_->audioMuteBt->setEnabled(available);
    }

    if (muteType == TEST_VIDEO_ITEM::MuteVideo) {
        if (mute_all_remote) {
            video_mute_ = true;
        }
        ui_video_item_->videoMuteBt->setEnabled(true);
        video_available_ = available;
        updateAVMuteView(TEST_VIDEO_ITEM::MuteVideo);
        ui_video_item_->videoMuteBt->setEnabled(available);
    }
}

void TestUserVideoItem::on_audioMuteBt_clicked() {
    audio_mute_ = !audio_mute_;
    muteAudio(audio_mute_);
    updateAVMuteView(TEST_VIDEO_ITEM::MuteAudio);
}

void TestUserVideoItem::on_videoMuteBt_clicked() {
    video_mute_ = !video_mute_;
    muteVideo(video_mute_);
    updateAVMuteView(TEST_VIDEO_ITEM::MuteVideo);
}

void TestUserVideoItem::on_fitScreenBt_clicked() {
    QString fill_mode_bt_stylesheet;
    if (fill_mode_ == trtc::TRTCVideoFillMode_Fill) {
        fill_mode_ = trtc::TRTCVideoFillMode_Fit;
        fill_mode_bt_stylesheet = "QPushButton{border-image: url(:/switch/image/switch/fit_open.png);}";

    } else if (fill_mode_ == trtc::TRTCVideoFillMode_Fit) {
        fill_mode_ = trtc::TRTCVideoFillMode_Fill;
        fill_mode_bt_stylesheet = "QPushButton{border-image: url(:/switch/image/switch/fill_open.png);}";
    }
    ui_video_item_->fitScreenBt->setStyleSheet(fill_mode_bt_stylesheet);
    setRenderParams();
}

void TestUserVideoItem::on_preSmallVideoBt_clicked() {
    QString small_pre__bt_stylesheet;
    if (video_stream_type_ == trtc::TRTCVideoStreamTypeBig) {
        video_stream_type_ = trtc::TRTCVideoStreamTypeSmall;
        small_pre__bt_stylesheet = "QPushButton{border-image: url(:/switch/image/switch/small_open.png);}";
    } else if (video_stream_type_ == trtc::TRTCVideoStreamTypeSmall) {
        video_stream_type_ = trtc::TRTCVideoStreamTypeBig;
        small_pre__bt_stylesheet = "QPushButton{border-image: url(:/switch/image/switch/big_open.png);}";
    }
    ui_video_item_->preSmallVideoBt->setStyleSheet(small_pre__bt_stylesheet);
    setRemoteVideoStreamType();
}

void TestUserVideoItem::on_mirrorBt_clicked() {
    QString mirror_bt_stylesheet;
    if (mirror_type_ == trtc::TRTCVideoMirrorType_Enable) {
        mirror_bt_stylesheet = "QPushButton{border-image: url(:/switch/image/switch/mirror_close.png);}";
        mirror_type_ = trtc::TRTCVideoMirrorType_Disable;
    } else if (mirror_type_ == trtc::TRTCVideoMirrorType_Disable) {
        mirror_type_ = trtc::TRTCVideoMirrorType_Enable;
        mirror_bt_stylesheet = "QPushButton{border-image: url(:/switch/image/switch/mirror_open.png);}";
    }
    ui_video_item_->mirrorBt->setStyleSheet(mirror_bt_stylesheet);
    setRenderParams();
}

void TestUserVideoItem::on_roateBt_clicked() {
    int roate_index = rotation_;
    rotation_ = static_cast<trtc::TRTCVideoRotation>((++roate_index) % 4);
    setRenderParams();
}

void TestUserVideoItem::updateAVMuteView(TEST_VIDEO_ITEM::MuteAllType muteType){
    if (muteType == TEST_VIDEO_ITEM::MuteAudio) {
        QString audio_mutebt_stylesheet = !audio_available_ || audio_mute_
            ? "QPushButton{border-image: url(:/switch/image/switch/audio_close.png);}"
            : "QPushButton{border-image: url(:/switch/image/switch/audio_normal.png);}";
        ui_video_item_->audioMuteBt->setStyleSheet(audio_mutebt_stylesheet);

        if (audio_mute_) {
            ui_video_item_->volumePb->setValue(0);
        }

    } else if (muteType == TEST_VIDEO_ITEM::MuteVideo) {
        QString video_mutebt_stylesheet = !video_available_ || video_mute_
            ? "QPushButton{border-image: url(:/switch/image/switch/video_close.png);}"
            : "QPushButton{border-image: url(:/switch/image/switch/video_normal.png);}";
        ui_video_item_->videoMuteBt->setStyleSheet(video_mutebt_stylesheet);
    }
}

void TestUserVideoItem::setVolume(int volume)
{
    ui_video_item_->volumePb->setValue(volume);
}

WId TestUserVideoItem::getVideoWId()
{
    return ui_video_item_->videoPlaceHolder->winId();
}

std::string& TestUserVideoItem::getUserId()
{
    return user_id_;
}

int TestUserVideoItem::getRoomId() {
    return room_id_;
}

bool TestUserVideoItem::getAudioMuteStatus() {
    return audio_mute_;
}

bool TestUserVideoItem::getVideoMuteStatus() {
    return video_mute_;
}

TEST_VIDEO_ITEM::ViewItemType TestUserVideoItem::getViewType()
{
    return viewtype_;
}

void TestUserVideoItem::updateDynamicTextUI() {
    ui_video_item_->userInfoLabel->setText(QString("roomid: %1 / userid: %2").arg(room_id_).arg(user_id_.c_str()));
}