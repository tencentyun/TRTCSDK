#include "test_screen_share_setting.h"

TestScreenShareSetting::TestScreenShareSetting(std::shared_ptr<TestUserVideoGroup> testUserVideoGroup,QWidget*parent) :
    QDialog(parent)
  ,ui_screen_share_setting_(new Ui::TestScreenShareSettingDialog)
  ,test_user_video_group_(testUserVideoGroup){
    ui_screen_share_setting_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
}

TestScreenShareSetting::~TestScreenShareSetting(){
    if(test_screensharing_withwindow != nullptr){
        delete test_screensharing_withwindow;
        test_screensharing_withwindow = nullptr;
    }

    if (test_screensharing_withscreen != nullptr){
        delete test_screensharing_withscreen;
        test_screensharing_withscreen = nullptr;
    }
}

void TestScreenShareSetting::setSubStreamMixVolume(int volume) {
    getTRTCShareInstance()->setSubStreamMixVolume(volume);
}

void TestScreenShareSetting::setSubStreamEncoderParam(trtc::TRTCVideoStreamType streamType, trtc::TRTCVideoEncParam & videoEncParam){
    getTRTCShareInstance()->setSubStreamEncoderParam(videoEncParam);
}

void TestScreenShareSetting::updateScreenSharingParams() {

    trtc::TRTCVideoEncParam video_enc_param;
    video_enc_param.enableAdjustRes = enable_adjustres_;
    video_enc_param.minVideoBitrate = min_video_bitrate_;
    video_enc_param.resMode = res_mode_;
    video_enc_param.videoBitrate = video_bitrate_;
    video_enc_param.videoFps = videofps_;
    video_enc_param.videoResolution = video_resolution_;

    setSubStreamEncoderParam(video_stream_type, video_enc_param);
    setSubStreamMixVolume(mix_volume);

    trtc::TRTCScreenCaptureProperty property;
    property.enableCaptureMouse = enable_capturemouse_;
    property.enableHighLight = enable_highlight_;
    property.enableHighPerformance = enable_high_performance;

    if (test_screensharing_withscreen != nullptr
        && !test_screensharing_withscreen->isHidden())
        test_screensharing_withscreen->updateScreenSharingParams(
            property
            , video_enc_param
            , capture_rect_
            , video_stream_type
        );
    if (test_screensharing_withwindow != nullptr
        && !test_screensharing_withwindow->isHidden())
        test_screensharing_withwindow->updataScreenSharingParams(
            property
            , video_enc_param
            , capture_rect_
            , video_stream_type
        );
}
void TestScreenShareSetting::configViewParams(){

    video_resolution_ = indexConvertToVideoResolution(ui_screen_share_setting_->comBVideoResolution->currentIndex());
    res_mode_ = static_cast<trtc::TRTCVideoResolutionMode>(ui_screen_share_setting_->comBResMode->currentIndex());
    video_stream_type = ui_screen_share_setting_->comBPushStreamMode->currentIndex() == 0?trtc::TRTCVideoStreamTypeSub:trtc::TRTCVideoStreamTypeBig;
    mix_volume = ui_screen_share_setting_->sliderScreenCaptureMixVolume->value();

    videofps_ = ui_screen_share_setting_->lineEtvideoFps->text().toUInt();
    video_bitrate_ = ui_screen_share_setting_->lineEtVideoBitrate->text().toUInt();
    min_video_bitrate_ = ui_screen_share_setting_->lineEtMinVideoFps->text().toUInt();

    enable_adjustres_ = ui_screen_share_setting_->enableAdjustRes->isChecked();
    enable_highlight_ = ui_screen_share_setting_->cnEnableHighLight->isChecked();
    enable_capturemouse_ = ui_screen_share_setting_->cbEnableCaptureMouse->isChecked();
    enable_high_performance = ui_screen_share_setting_->cbEnableHighPerformance->isChecked();

    capture_rect_.left = ui_screen_share_setting_->lineEtLeft->text().toUInt();
    capture_rect_.top = ui_screen_share_setting_->lineEtTop->text().toUInt();
    capture_rect_.bottom = ui_screen_share_setting_->lineEtBottom->text().toUInt();
    capture_rect_.right = ui_screen_share_setting_->lineEtRight->text().toUInt();
}

trtc::TRTCVideoResolution TestScreenShareSetting::indexConvertToVideoResolution(int index){
    if(index < 4){
        return static_cast<trtc::TRTCVideoResolution> (trtc::TRTCVideoResolution_120_120+ index * 2);
    }

    if(index < 12){
        return static_cast<trtc::TRTCVideoResolution> (trtc::TRTCVideoResolution_160_120+ (index-4) * 2);
    }

    if(index < 20){
        return static_cast<trtc::TRTCVideoResolution> (trtc::TRTCVideoResolution_160_90+ (index - 12) * 2);
    }

    return trtc::TRTCVideoResolution_1280_720;
}

void TestScreenShareSetting::closeEvent(QCloseEvent *event)
{
    if (test_screensharing_withscreen != nullptr) {
        test_screensharing_withscreen->hide();
        delete test_screensharing_withscreen;
        test_screensharing_withscreen = nullptr;
    }

    if (test_screensharing_withwindow != nullptr) {
        test_screensharing_withwindow->hide();
        delete test_screensharing_withwindow;
        test_screensharing_withwindow = nullptr;
    }
}

void TestScreenShareSetting::on_btUpdateScreenSharing_clicked(){
    configViewParams();
    updateScreenSharingParams();
}

void TestScreenShareSetting::on_sliderScreenCaptureMixVolume_valueChanged(int value) {
    setSubStreamMixVolume(value);
}

void TestScreenShareSetting::on_btSharingAllScreen_clicked(){
    if (test_screensharing_withscreen != nullptr) {
        test_screensharing_withscreen->hide();
        delete test_screensharing_withscreen;
        test_screensharing_withscreen = nullptr;
    }

    configViewParams();

    trtc::TRTCVideoEncParam param;
    param.enableAdjustRes = enable_adjustres_;
    param.minVideoBitrate = min_video_bitrate_;
    param.resMode = res_mode_;
    param.videoBitrate = video_bitrate_;
    param.videoFps = videofps_;
    param.videoResolution = video_resolution_;

    trtc::TRTCScreenCaptureProperty property;
    property.enableCaptureMouse = enable_capturemouse_;
    property.enableHighLight = enable_highlight_;
    property.enableHighPerformance = enable_high_performance;


    test_screensharing_withscreen = new TestScreenShareSelectScreen(test_user_video_group_,property,param,capture_rect_,this,video_stream_type);
    test_screensharing_withscreen->show();
    test_screensharing_withscreen->raise();
}

void TestScreenShareSetting::on_btSharingSelectedWindow_clicked(){
    if (test_screensharing_withwindow != nullptr) {
        test_screensharing_withwindow->hide();
        delete test_screensharing_withwindow;
        test_screensharing_withwindow = nullptr;
    }

    configViewParams();

    trtc::TRTCVideoEncParam param;
    param.enableAdjustRes = enable_adjustres_;
    param.minVideoBitrate = min_video_bitrate_;
    param.resMode = res_mode_;
    param.videoBitrate = video_bitrate_;
    param.videoFps = videofps_;
    param.videoResolution = video_resolution_;

    trtc::TRTCScreenCaptureProperty property;
    property.enableCaptureMouse = enable_capturemouse_;
    property.enableHighLight = enable_highlight_;
    property.enableHighPerformance = enable_high_performance;


    test_screensharing_withwindow = new TestScreenShareSelectWindow(test_user_video_group_,property, param, capture_rect_,this, video_stream_type);
    test_screensharing_withwindow->show();
    test_screensharing_withwindow->raise();
}
