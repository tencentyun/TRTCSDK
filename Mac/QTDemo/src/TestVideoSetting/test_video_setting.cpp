#include "test_video_setting.h"

TestVideoSetting::TestVideoSetting(QWidget *parent):
    BaseDialog(parent),
    ui_video_setting_(new Ui::TestVideoSettingDialog)
{
    ui_video_setting_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    setupVideoResolutionMap();
    trtccloud_ = getTRTCShareInstance();
}

TestVideoSetting::~TestVideoSetting() {
    if(trtccloud_ != nullptr) {
        trtccloud_ = nullptr;
    }
}

void TestVideoSetting::updateVideoEncoderParams()
{
    trtc::TRTCVideoResolution resolution  = video_resolution_hashmap_.value(ui_video_setting_->comboBoxVideoResolution->currentIndex());
    trtc::TRTCVideoResolutionMode resolution_mode = (ui_video_setting_->comboBoxResolutionMode->currentIndex() == 0)? trtc::TRTCVideoResolutionMode::TRTCVideoResolutionModeLandscape : trtc::TRTCVideoResolutionMode::TRTCVideoResolutionModePortrait;
    uint32_t video_fps = (ui_video_setting_->comboBoxVideoFps->currentIndex()) == 0 ? 15 : 20;
    uint32_t bitrate = (uint32_t)(ui_video_setting_->horizontalSliderVideoBitrate->value());
    bool enable_adjust_resolution = ui_video_setting_->checkBoxEnableAdjustRes->isChecked();

    QString bitrate_text(tr("上行码率 "));
    bitrate_text = bitrate_text.append(QString::number(bitrate));
    bitrate_text = bitrate_text.append(QString::fromUtf8("kbps: "));
    ui_video_setting_->labelBitrateDesc->setText(bitrate_text);

    trtc::TRTCVideoEncParam param;
    param.resMode = resolution_mode;
    param.videoResolution = resolution;
    param.videoBitrate = bitrate;
    param.videoFps = video_fps;
    param.enableAdjustRes = enable_adjust_resolution;
    trtccloud_->setVideoEncoderParam(param);
}

void TestVideoSetting::on_comboBoxVideoResolution_currentIndexChanged(int index)
{
    updateVideoEncoderParams();
}

void TestVideoSetting::on_comboBoxResolutionMode_currentIndexChanged(int index)
{
    updateVideoEncoderParams();
}

void TestVideoSetting::on_comboBoxVideoFps_currentIndexChanged(int index)
{
    updateVideoEncoderParams();
}

void TestVideoSetting::on_horizontalSliderVideoBitrate_valueChanged(int value)
{
    updateVideoEncoderParams();
}

void TestVideoSetting::on_checkBoxEnableAdjustRes_stateChanged(int arg1)
{
    updateVideoEncoderParams();
}

void TestVideoSetting::on_checkBoxEnableEncSmallVideoStream_stateChanged(int arg1)
{
    trtc::TRTCVideoEncParam param;
    param.resMode = (ui_video_setting_->comboBoxResolutionMode->currentIndex() == 0)? trtc::TRTCVideoResolutionMode::TRTCVideoResolutionModeLandscape : trtc::TRTCVideoResolutionMode::TRTCVideoResolutionModePortrait;
    param.videoResolution = trtc::TRTCVideoResolution_640_360;
    trtccloud_->enableSmallVideoStream(ui_video_setting_->checkBoxEnableEncSmallVideoStream->isChecked(), param);
}

void TestVideoSetting::setupVideoResolutionMap()
{
    video_resolution_hashmap_.insert(0, trtc::TRTCVideoResolution_120_120);
    video_resolution_hashmap_.insert(1, trtc::TRTCVideoResolution_160_160);
    video_resolution_hashmap_.insert(2, trtc::TRTCVideoResolution_270_270);
    video_resolution_hashmap_.insert(3, trtc::TRTCVideoResolution_480_480);
    video_resolution_hashmap_.insert(4, trtc::TRTCVideoResolution_160_120);
    video_resolution_hashmap_.insert(5, trtc::TRTCVideoResolution_240_180);
    video_resolution_hashmap_.insert(6, trtc::TRTCVideoResolution_280_210);
    video_resolution_hashmap_.insert(7, trtc::TRTCVideoResolution_320_240);
    video_resolution_hashmap_.insert(8, trtc::TRTCVideoResolution_400_300);
    video_resolution_hashmap_.insert(9, trtc::TRTCVideoResolution_480_360);
    video_resolution_hashmap_.insert(10, trtc::TRTCVideoResolution_640_480);
    video_resolution_hashmap_.insert(11, trtc::TRTCVideoResolution_960_720);
    video_resolution_hashmap_.insert(12, trtc::TRTCVideoResolution_160_90);
    video_resolution_hashmap_.insert(13, trtc::TRTCVideoResolution_256_144);
    video_resolution_hashmap_.insert(14, trtc::TRTCVideoResolution_320_180);
    video_resolution_hashmap_.insert(15, trtc::TRTCVideoResolution_480_270);
    video_resolution_hashmap_.insert(16, trtc::TRTCVideoResolution_640_360);
    video_resolution_hashmap_.insert(17, trtc::TRTCVideoResolution_960_540);
    video_resolution_hashmap_.insert(18, trtc::TRTCVideoResolution_1280_720);
    video_resolution_hashmap_.insert(19, trtc::TRTCVideoResolution_1920_1080);
}

void TestVideoSetting::retranslateUi() {
    ui_video_setting_->retranslateUi(this);
}

void TestVideoSetting::resetUI() {
    ui_video_setting_->checkBoxEnableEncSmallVideoStream->setChecked(false);
}