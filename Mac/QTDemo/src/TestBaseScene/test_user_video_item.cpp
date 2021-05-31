#include "test_user_video_item.h"

TestUserVideoItem::TestUserVideoItem(QWidget * parent,trtc::ITRTCCloud* cloud, int roomid, std::string userid, TEST_VIDEO_ITEM::ViewItemType type)
    :QWidget(parent), ui_video_item_(new Ui::TestUserVideoItem), viewtype_(type) {
    ui_video_item_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    this->room_id_ = roomid;
    this->user_id_ = userid;
    this->trtccloud_ = cloud;

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


void TestUserVideoItem::initViews() {
    ui_video_item_->userInfoLabel->setText(tr("roomid:%1 / userid:%2").arg(room_id_).arg(user_id_.c_str()));
    // 无法解决闪烁问题
  //    setAttribute(Qt::WA_PaintOnScreen);
//    setAttribute(Qt::WA_StaticContents);
//    setAttribute(Qt::WA_NoSystemBackground);
//    setAttribute(Qt::WA_OpaquePaintEvent);
//    setAttribute(Qt::WA_DontCreateNativeAncestors);
//    setAttribute(Qt::WA_NativeWindow);

    switch (viewtype_)
    {
    case TEST_VIDEO_ITEM::LocalView:
        ui_video_item_->preSmallVideoBt->setHidden(true);
        break;
    case TEST_VIDEO_ITEM::RemoteView:
        ui_video_item_->audioMuteBt->setEnabled(false);
        ui_video_item_->videoMuteBt->setEnabled(false);
        updateAVMuteView(true,TEST_VIDEO_ITEM::MuteVideo);
        updateAVMuteView(true,TEST_VIDEO_ITEM::MuteAudio);
        break;
    case TEST_VIDEO_ITEM::ScreenSharingView:
        break;
    default:
        break;
    }
}

void TestUserVideoItem::setVideoMuteEnabled(bool enabled)
{
    ui_video_item_->videoMuteBt->setEnabled(enabled);
}

void TestUserVideoItem::setAudioMuteEnabled(bool enabled)
{
    ui_video_item_->audioMuteBt->setEnabled(enabled);
}

void TestUserVideoItem::updateAVMuteItems(bool mute, TEST_VIDEO_ITEM::MuteAllType muteType) {
    if(muteType == TEST_VIDEO_ITEM::MuteAudio){
        if(!ui_video_item_->audioMuteBt->isEnabled()){
            return;
        }

        audio_mute_ = mute;
    }

    if(muteType == TEST_VIDEO_ITEM::MuteVideo){
        if(!ui_video_item_->videoMuteBt->isEnabled()){
            return;
        }
        video_mute_ = mute;
    }

    updateAVMuteView(mute,muteType);
}

void TestUserVideoItem::on_audioMuteBt_clicked() {
    muteAudio(!audio_mute_);
    updateAVMuteView(!audio_mute_, TEST_VIDEO_ITEM::MuteAudio);
    audio_mute_ = !audio_mute_;
}

void TestUserVideoItem::on_videoMuteBt_clicked() {
    muteVideo(!video_mute_);
    updateAVMuteView(!video_mute_, TEST_VIDEO_ITEM::MuteVideo);
    video_mute_ = !video_mute_;
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

void TestUserVideoItem::updateAVMuteView(bool mute, TEST_VIDEO_ITEM::MuteAllType muteType){
    if (muteType == TEST_VIDEO_ITEM::MuteAudio) {
        QString audio_mutebt_stylesheet = mute
            ? "QPushButton{border-image: url(:/switch/image/switch/audio_close.png);}"
            : "QPushButton{border-image: url(:/switch/image/switch/audio_normal.png);}";
        ui_video_item_->audioMuteBt->setStyleSheet(audio_mutebt_stylesheet);

        if (mute) {
            ui_video_item_->volumePb->setValue(0);
        }

    } else if (muteType == TEST_VIDEO_ITEM::MuteVideo) {
        QString video_mutebt_stylesheet = mute
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

TEST_VIDEO_ITEM::ViewItemType TestUserVideoItem::getViewType()
{
    return viewtype_;
}
