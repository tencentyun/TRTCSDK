#include "test_mix_stream_publish.h"

#include <QMessageBox>

#include "defs.h"
#include "room_info_holder.h"

constexpr const int32_t TestMixStreamPublish::kAudioSampleRate[];

TestMixStreamPublish::TestMixStreamPublish(QWidget *parent):BaseDialog(parent),ui_test_mix_stream_publish_(new Ui::TestMixStreamPublishDialog){
    ui_test_mix_stream_publish_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    getTRTCShareInstance()->addCallback(this);
    initUI();
}

TestMixStreamPublish::~TestMixStreamPublish(){
    getTRTCShareInstance()->removeCallback(this);

    if (started_transcoding_) {
        getTRTCShareInstance()->setMixTranscodingConfig(nullptr);
        return;
    }

    remote_userinfos_.clear();
}

void TestMixStreamPublish::startPureAudioTemplate(){
    trtc_transcoding_config.mode = mix_config_mode_;
    trtc_transcoding_config.videoWidth = video_width_;
    trtc_transcoding_config.videoHeight = video_height_;

    // If 0 is passed in, the backend will calculate a bitrate based on videoWidth and videoHeight.
    trtc_transcoding_config.videoBitrate = video_bitrate_;
    trtc_transcoding_config.videoFramerate = video_framerate_;
    trtc_transcoding_config.videoGOP = video_gop_;
    trtc_transcoding_config.backgroundColor = background_color_;
    trtc_transcoding_config.backgroundImage = background_imag_.c_str();
    trtc_transcoding_config.audioSampleRate = audio_samplerate_;
    trtc_transcoding_config.audioBitrate = audio_bitrate_;
    trtc_transcoding_config.audioChannels = audio_channels_;

    std::string streamid_str = ui_test_mix_stream_publish_->streamIdLineEt->text().toStdString();
    trtc_transcoding_config.streamId = streamid_str.c_str();
    std::string roomid_str = std::to_string(RoomInfoHolder::GetInstance().getMainRoomId());

    trtc_transcoding_config.mixUsersArraySize = 0;
    getTRTCShareInstance()->setMixTranscodingConfig(&trtc_transcoding_config);
    started_transcoding_ = true;
}

void TestMixStreamPublish::startScreenSharingTemplate(){
    trtc_transcoding_config.mode = mix_config_mode_;
    trtc_transcoding_config.videoWidth = video_width_;
    trtc_transcoding_config.videoHeight = video_height_;

    trtc_transcoding_config.videoBitrate = video_bitrate_;
    trtc_transcoding_config.videoFramerate = video_framerate_;
    trtc_transcoding_config.videoGOP = video_gop_;
    trtc_transcoding_config.backgroundColor = background_color_;
    trtc_transcoding_config.backgroundImage = background_imag_.c_str();
    trtc_transcoding_config.audioSampleRate = audio_samplerate_;
    trtc_transcoding_config.audioBitrate = audio_bitrate_;
    trtc_transcoding_config.audioChannels = audio_channels_;

    std::string streamid_str = ui_test_mix_stream_publish_->streamIdLineEt->text().toStdString();
    trtc_transcoding_config.streamId = streamid_str.c_str();
    RoomInfoHolder::GetInstance().setMixTranscodingStreamId(streamid_str);

    trtc_transcoding_config.videoWidth = 0;
    trtc_transcoding_config.videoHeight = 0;
    trtc_transcoding_config.mixUsersArraySize = 0;
    std::string roomid_str = std::to_string(RoomInfoHolder::GetInstance().getMainRoomId());

    getTRTCShareInstance()->setMixTranscodingConfig(&trtc_transcoding_config);
    started_transcoding_ = true;
}

void TestMixStreamPublish::startPresetLayoutTemplate(){
    trtc_transcoding_config.mode = mix_config_mode_;
    trtc_transcoding_config.videoWidth = video_width_;
    trtc_transcoding_config.videoHeight = video_height_;

    trtc_transcoding_config.videoBitrate = video_bitrate_;
    trtc_transcoding_config.videoFramerate = video_framerate_;
    trtc_transcoding_config.videoGOP = video_gop_;
    trtc_transcoding_config.backgroundColor = background_color_;
    trtc_transcoding_config.backgroundImage = background_imag_.c_str();
    trtc_transcoding_config.audioSampleRate = audio_samplerate_;
    trtc_transcoding_config.audioBitrate = audio_bitrate_;
    trtc_transcoding_config.audioChannels = audio_channels_;

    std::string streamid_str = ui_test_mix_stream_publish_->streamIdLineEt->text().toStdString();
    trtc_transcoding_config.streamId = streamid_str.c_str();
    RoomInfoHolder::GetInstance().setMixTranscodingStreamId(streamid_str);

    std::string roomid_str = std::to_string(RoomInfoHolder::GetInstance().getMainRoomId());
    trtc::TRTCMixUser* mix_users_array = NULL;

    // The number of users whose streams are mixed. 4 is used in the demo.
    int current_mix_size = 4;

    int remote_item_height = video_height_ / 4;
    int remote_item_width = remote_item_height;

    mix_users_array = new trtc::TRTCMixUser[current_mix_size];

    mix_users_array[0].userId = "$PLACE_HOLDER_LOCAL_MAIN$";


    mix_users_array[0].zOrder = 0;
    mix_users_array[0].rect.left = 0;
    mix_users_array[0].rect.top = 0;
    mix_users_array[0].rect.right = video_width_;
    mix_users_array[0].rect.bottom = video_height_;

    mix_users_array[0].roomId = nullptr;

    for (int current_pos = 1; current_pos < current_mix_size; current_pos++){

        // The value is a placeholder, not the actual user ID.
        mix_users_array[current_pos].userId = "$PLACE_HOLDER_REMOTE$";
        mix_users_array[current_pos].roomId = roomid_str.c_str();
        mix_users_array[current_pos].streamType = trtc::TRTCVideoStreamTypeBig;
        mix_users_array[current_pos].inputType = trtc::TRTCMixInputTypeAudioVideo;
        mix_users_array[current_pos].zOrder = 1;

        // Start from 0 (left to right)
        mix_users_array[current_pos].rect.left = (current_pos - 1) * remote_item_width;
        mix_users_array[current_pos].rect.top = video_height_ - 4 * remote_item_width / 3;
        mix_users_array[current_pos].rect.bottom = mix_users_array[current_pos].rect.top + remote_item_height;
        mix_users_array[current_pos].rect.right = mix_users_array[current_pos].rect.left + remote_item_width;
    }

    trtc_transcoding_config.mixUsersArray = mix_users_array;
    trtc_transcoding_config.mixUsersArraySize = current_mix_size;

    getTRTCShareInstance()->setMixTranscodingConfig(&trtc_transcoding_config);
    started_transcoding_ = true;
    delete [] mix_users_array;
}

void TestMixStreamPublish::startManualTemplate(){
    trtc_transcoding_config.mode = mix_config_mode_;
    trtc_transcoding_config.videoWidth = video_width_;
    trtc_transcoding_config.videoHeight = video_height_;

    // If 0 is passed in, the backend will calculate a bitrate based on videoWidth and videoHeight.
    trtc_transcoding_config.videoBitrate = video_bitrate_;
    trtc_transcoding_config.videoFramerate = video_framerate_;
    trtc_transcoding_config.videoGOP = video_gop_;
    trtc_transcoding_config.backgroundColor = background_color_;
    trtc_transcoding_config.backgroundImage = background_imag_.c_str();
    trtc_transcoding_config.audioSampleRate = audio_samplerate_;
    trtc_transcoding_config.audioBitrate = audio_bitrate_;
    trtc_transcoding_config.audioChannels = audio_channels_;

    std::string streamid_str = ui_test_mix_stream_publish_->streamIdLineEt->text().toStdString();
    trtc_transcoding_config.streamId = streamid_str.c_str();
    RoomInfoHolder::GetInstance().setMixTranscodingStreamId(streamid_str);

    std::string roomid_str = std::to_string(RoomInfoHolder::GetInstance().getMainRoomId());
    trtc::TRTCMixUser* mix_users_array = NULL;

    // The number of users whose streams are mixed.
    int current_mix_size;
    std::string local_user_id = RoomInfoHolder::GetInstance().getUserId();
    const int  mix_usersarray_size = remote_userinfos_.size() + 1;

    int remote_item_height = video_height_ / 4;
    int remote_item_width = remote_item_height;

    int max_mix_size = remote_item_width == 0 ? 1 : (video_width_ / remote_item_width + 1);

    current_mix_size = mix_usersarray_size > max_mix_size ? max_mix_size : mix_usersarray_size;

    mix_users_array = new trtc::TRTCMixUser[current_mix_size];

    mix_users_array[0].userId = local_user_id.c_str();

    mix_users_array[0].zOrder = 0;
    mix_users_array[0].rect.left = 0;
    mix_users_array[0].rect.top = 0;
    mix_users_array[0].rect.right = video_width_;
    mix_users_array[0].rect.bottom = video_height_;
    mix_users_array[0].roomId = roomid_str.c_str();

    if (screen_shared_started_) {
        mix_users_array[0].streamType = trtc::TRTCVideoStreamTypeSub;
    } else {
        mix_users_array[0].streamType = trtc::TRTCVideoStreamTypeBig;
    }

    int current_pos = 1;
    for (auto remote_info : remote_userinfos_) {
        if (current_pos >= current_mix_size) {
            break;
        }

        mix_users_array[current_pos].userId = remote_info->user_id_.c_str();
        mix_users_array[current_pos].roomId = roomid_str.c_str();
        mix_users_array[current_pos].streamType = trtc::TRTCVideoStreamTypeBig;

        if (remote_info->video_available_) {
            mix_users_array[current_pos].inputType = trtc::TRTCMixInputTypePureVideo;
        }

        if (remote_info->audio_available_) {
            mix_users_array[current_pos].inputType = trtc::TRTCMixInputTypePureAudio;
        }

        if (remote_info->video_available_ && remote_info->audio_available_) {
            mix_users_array[current_pos].inputType = trtc::TRTCMixInputTypeAudioVideo;
        }

        mix_users_array[current_pos].inputType = trtc::TRTCMixInputTypeAudioVideo;
        mix_users_array[current_pos].zOrder = 1;

        // Start from 0 (left to right)
        mix_users_array[current_pos].rect.left = (current_pos - 1) * remote_item_width;
        mix_users_array[current_pos].rect.top = (current_pos - 1) * (video_height_ / max_mix_size - 1);
        mix_users_array[current_pos].rect.bottom = mix_users_array[current_pos].rect.top + remote_item_height;
        mix_users_array[current_pos].rect.right = mix_users_array[current_pos].rect.left + remote_item_width;
        current_pos++;
    }

    trtc_transcoding_config.mixUsersArray = mix_users_array;
    trtc_transcoding_config.mixUsersArraySize = current_mix_size;

    getTRTCShareInstance()->setMixTranscodingConfig(&trtc_transcoding_config);
    started_transcoding_ = true;
    delete[] mix_users_array;
}

void TestMixStreamPublish::on_startMixStreamPublishBt_clicked(){

    if (started_transcoding_) {
        getTRTCShareInstance()->setMixTranscodingConfig(nullptr);
        started_transcoding_ = false;
        updatePublishButtonStatus();
        return;
    } else {
        if (getTranscodingConfig()) {
            updateTranscodingConfig();
        }
    }
}

void TestMixStreamPublish::closeEvent(QCloseEvent *event) {
    BaseDialog::closeEvent(event);
}

void TestMixStreamPublish::showEvent(QShowEvent *event)
{
    ui_test_mix_stream_publish_->streamIdLineEt->setText(QString::fromStdString(RoomInfoHolder::GetInstance().getMixTranscodingStreamId()));
    BaseDialog::showEvent(event);
}

void TestMixStreamPublish::updatePublishButtonStatus()
{
    updateDynamicTextUI();
    ui_test_mix_stream_publish_->startMixStreamPublishBt->setEnabled(isStartMixStreamBtAvailable());
}

//============= ITRTCCloudCallback start ===============//
void TestMixStreamPublish::onExitRoom(int reason) {
    started_transcoding_ = false;
    updatePublishButtonStatus();
}

void TestMixStreamPublish::onSetMixTranscodingConfig(int errCode, const char *errMsg){
    if (errCode != 0) {
        QMessageBox::warning(this, "SetMixTranscodingConfig() failed", errMsg, QMessageBox::Ok);
        started_transcoding_ = false;
    }
    updatePublishButtonStatus();
}

void TestMixStreamPublish::onUserVideoAvailable(const char * userId, bool available){

    std::vector<RemoteUserInfo*>::const_iterator iter = remote_userinfos_.begin();
    while (iter != remote_userinfos_.end()) {
        if (strcmp((*iter)->user_id_.c_str(), userId) == 0) {
            break;
        }
        iter++;
    }

    if ((iter == remote_userinfos_.end()) && available) {
        RemoteUserInfo* new_user_info = new RemoteUserInfo();
        new_user_info->user_id_ = userId;
        new_user_info->video_available_ = true;
        remote_userinfos_.push_back(new_user_info);
    }else{
        (*iter)->video_available_ = available;
        if (!available && (*iter)->audio_available_ != true) {
            remote_userinfos_.erase(iter);
        }
    }

    if (mix_config_mode_ == trtc::TRTCTranscodingConfigMode_Manual && started_transcoding_){
        updateTranscodingConfig();
    }
}

void TestMixStreamPublish::onUserAudioAvailable(const char * userId, bool available){

    std::vector<RemoteUserInfo*>::const_iterator iter = remote_userinfos_.begin();
    std::vector<RemoteUserInfo*>::const_iterator find_iter = remote_userinfos_.end();
    while (iter != remote_userinfos_.end()) {
        if (strcmp((*iter)->user_id_.c_str(), userId) == 0) {
            break;
        }
        iter++;
    }

    // New user
    if ((iter == remote_userinfos_.end()) && available) {
        RemoteUserInfo* new_user_info = new RemoteUserInfo();
        new_user_info->user_id_ = userId;
        new_user_info->audio_available_ = true;
        remote_userinfos_.push_back(new_user_info);
    }else{
        (*iter)->audio_available_ = available;
        if (!available && (*iter)->video_available_ != true) {
            remote_userinfos_.erase(iter);
        }
    }

    if (mix_config_mode_ == trtc::TRTCTranscodingConfigMode_Manual && started_transcoding_) {
        updateTranscodingConfig();
    }
}

void TestMixStreamPublish::onScreenCaptureStarted(){
    screen_shared_started_ = true;
    if (mix_config_mode_ == trtc::TRTCTranscodingConfigMode_Manual && started_transcoding_) {
        updateTranscodingConfig();
    }
}

void TestMixStreamPublish::onScreenCaptureStoped(int reason){
    screen_shared_started_ = false;
    if (mix_config_mode_ == trtc::TRTCTranscodingConfigMode_Manual && started_transcoding_) {
        updateTranscodingConfig();
    }
}

//============= ITRTCCloudCallback end =================//

bool TestMixStreamPublish::isStartMixStreamBtAvailable(){
    return (!ui_test_mix_stream_publish_->streamIdLineEt->text().isEmpty()) || started_transcoding_;
}

void TestMixStreamPublish::initUI(){
    config_mode_button_group.addButton(ui_test_mix_stream_publish_->radioButtonManual, 0);
    config_mode_button_group.addButton(ui_test_mix_stream_publish_->radioButtonPresetLayout, 1);
    config_mode_button_group.addButton(ui_test_mix_stream_publish_->radioButtonScreenSharing, 2);
    config_mode_button_group.addButton(ui_test_mix_stream_publish_->radioButtonPureAudio, 3);
    ui_test_mix_stream_publish_->radioButtonManual->setChecked(true);
    connect(ui_test_mix_stream_publish_->radioButtonManual, SIGNAL(clicked(bool)), this, SLOT(on_config_mode_checked_change()));
    connect(ui_test_mix_stream_publish_->radioButtonPresetLayout, SIGNAL(clicked(bool)), this, SLOT(on_config_mode_checked_change()));
    connect(ui_test_mix_stream_publish_->radioButtonScreenSharing, SIGNAL(clicked(bool)), this, SLOT(on_config_mode_checked_change()));
    connect(ui_test_mix_stream_publish_->radioButtonPureAudio, SIGNAL(clicked(bool)), this, SLOT(on_config_mode_checked_change()));
    mix_config_mode_ = trtc::TRTCTranscodingConfigMode_Manual;
    ui_test_mix_stream_publish_->startMixStreamPublishBt->setEnabled(isStartMixStreamBtAvailable());
}

void TestMixStreamPublish::on_streamIdLineEt_textChanged(const QString &streamId){
    ui_test_mix_stream_publish_->startMixStreamPublishBt->setEnabled(isStartMixStreamBtAvailable());
}

void TestMixStreamPublish::updateTranscodingConfig()
{
    if (mix_config_mode_ == trtc::TRTCTranscodingConfigMode_Template_PureAudio) {
        startPureAudioTemplate();
    }

    if (mix_config_mode_ == trtc::TRTCTranscodingConfigMode_Template_ScreenSharing) {
        startScreenSharingTemplate();
    }

    if (mix_config_mode_ == trtc::TRTCTranscodingConfigMode_Template_PresetLayout) {
        startPresetLayoutTemplate();
    }

    if (mix_config_mode_ == trtc::TRTCTranscodingConfigMode_Manual) {
        startManualTemplate();
    }
}

void TestMixStreamPublish::on_config_mode_checked_change()
{
    switch(config_mode_button_group.checkedId()) {
    case 0: {
        mix_config_mode_ = trtc::TRTCTranscodingConfigMode_Manual;
        break;
    }
    case 1: {
        mix_config_mode_ = trtc::TRTCTranscodingConfigMode_Template_PresetLayout;
        break;
    }
    case 2: {
        mix_config_mode_ = trtc::TRTCTranscodingConfigMode_Template_ScreenSharing;
        break;
    }
    case 3: {
        mix_config_mode_ = trtc::TRTCTranscodingConfigMode_Template_PureAudio;
        break;
    }
    default: {
        break;
    }
    }
}

bool TestMixStreamPublish::getTranscodingConfig(){
    video_width_ = ui_test_mix_stream_publish_->videoWidthLineEt->text().toInt();
    video_height_ = ui_test_mix_stream_publish_->videoHeightLineEt->text().toInt();
    video_bitrate_ = ui_test_mix_stream_publish_->LineEtVideoBitrate->text().toInt();
    video_framerate_ = ui_test_mix_stream_publish_->videoFramerateEt->text().toInt();
    video_gop_ = ui_test_mix_stream_publish_->videoGopEt->text().toInt();
    background_color_ = ui_test_mix_stream_publish_->videoBackgrioundColorComB->currentIndex() == 0? 0x000000:0x0000FF;
    std::string backgroud_image_str = ui_test_mix_stream_publish_->videoBackgroundImageEt->text().toStdString();
    background_imag_ = backgroud_image_str;
    audio_samplerate_ = TestMixStreamPublish::kAudioSampleRate[ui_test_mix_stream_publish_->audioSampleRateComB->currentIndex()];
    audio_bitrate_ = ui_test_mix_stream_publish_->audioBitrateEt->text().toInt();
    audio_channels_ = (ui_test_mix_stream_publish_->audioChannelsComB->currentIndex() == 0)?1:2;

    if (mix_config_mode_ == trtc::TRTCTranscodingConfigMode_Unknown) {
        QMessageBox::warning(this, "Failed to publish mixed streams", "Select a layout mode.", QMessageBox::Ok);
        return false;
    }

    if (audio_bitrate_ < 32 || audio_bitrate_ > 192) {
        QMessageBox::warning(this, "Failed to publish mixed streams", "The audio bitrate must be in the range of [32, 192].", QMessageBox::Ok);
        return false;
    }

    if (video_gop_ < 1 || video_gop_ > 8) {
        QMessageBox::warning(this, "Failed to publish mixed streams", "The keyframe interval (GOP) must be in the range of [1, 8].", QMessageBox::Ok);
        return false;
    }

    if (video_framerate_ <= 0 || video_framerate_ > 30) {
        QMessageBox::warning(this, "Failed to publish mixed streams", "The frame rate must be in the range of (0, 30].", QMessageBox::Ok);
        return false;
    }

    return true;
}

void TestMixStreamPublish::updateDynamicTextUI() {
    if (started_transcoding_) {
        ui_test_mix_stream_publish_->startMixStreamPublishBt->setText(tr("停止发布"));
    } else {
        ui_test_mix_stream_publish_->startMixStreamPublishBt->setText(tr("开始发布"));
    }
    
}

void TestMixStreamPublish::retranslateUi() {
    ui_test_mix_stream_publish_->retranslateUi(this);
}