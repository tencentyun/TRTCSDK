#include "test_audio_setting.h"

TestAudioSetting::TestAudioSetting(QWidget *parent):
    BaseDialog(parent),
    ui_audio_setting_(new Ui::TestAudioSettingDialog)
{
    ui_audio_setting_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    trtccloud_ = getTRTCShareInstance();
    tx_device_manager_ = trtccloud_->getDeviceManager();
    tx_audio_effect_manager_ = trtccloud_->getAudioEffectManager();
    initUIStatus();
}

TestAudioSetting::~TestAudioSetting() {
    if(trtccloud_ != nullptr) {
        trtccloud_ = nullptr;
    }
}

void TestAudioSetting::on_comboBoxRemoteUsers_currentIndexChanged(const QString &value)
{
    current_selected_remote_user_id_ = value;
}

void TestAudioSetting::on_horizontalSliderRemoteUserVolume_valueChanged(int value)
{
    trtccloud_->setRemoteAudioVolume(current_selected_remote_user_id_.toStdString().data(), value);
}

void TestAudioSetting::on_horizontalSliderAudioPlayoutVolume_valueChanged(int value)
{
    trtccloud_->setAudioPlayoutVolume(value);
}

void TestAudioSetting::on_horizontalSliderApplicationVolume_valueChanged(int value)
{
#ifdef _WIN32
    tx_device_manager_->setApplicationPlayVolume(value);
#endif
}

void TestAudioSetting::on_checkBoxApplicationMute_stateChanged(int state)
{
#ifdef _WIN32
    tx_device_manager_->setApplicationMuteState(state == Qt::CheckState::Checked);
#endif
}

void TestAudioSetting::on_horizontalSliderCurrentDeviceVolume_valueChanged(int value)
{
    tx_device_manager_->setCurrentDeviceVolume(trtc::TRTCDeviceType::TXMediaDeviceTypeSpeaker, value);
}

void TestAudioSetting::on_checkBoxCurrentDeviceMute_stateChanged(int state)
{
    tx_device_manager_->setCurrentDeviceMute(trtc::TRTCDeviceType::TXMediaDeviceTypeSpeaker, state == Qt::CheckState::Checked);
}

void TestAudioSetting::on_horizontalSliderAudioCaptureVolume_valueChanged(int value)
{
    trtccloud_->setAudioCaptureVolume(value);
}

void TestAudioSetting::on_horizontalSliderSystemAudioLoopbackVolume_valueChanged(int value)
{
    trtccloud_->setSystemAudioLoopbackVolume(value);
}

void TestAudioSetting::on_checkBoxSytemAudioLoopbak_stateChanged(int state)
{
    if(state == Qt::CheckState::Checked) {
        trtccloud_->startSystemAudioLoopback(nullptr);
    } else {
        trtccloud_->stopSystemAudioLoopback();
    }
}

void TestAudioSetting::showEvent(QShowEvent* event) {
    updateRemoteUsersList();
    BaseDialog::showEvent(event);
}

void TestAudioSetting::initUIStatus()
{
    ui_audio_setting_->horizontalSliderAudioPlayoutVolume->setValue(trtccloud_->getAudioPlayoutVolume());
#ifdef _WIN32
    ui_audio_setting_->horizontalSliderApplicationVolume->setValue(tx_device_manager_->getApplicationPlayVolume());
    ui_audio_setting_->checkBoxApplicationMute->setChecked(tx_device_manager_->getApplicationMuteState());
#elif (__APPLE__ && TARGET_OS_MAC && !TARGET_OS_IPHONE)
    ui_audio_setting_->horizontalSliderApplicationVolume->setEnabled(false);
    ui_audio_setting_->checkBoxApplicationMute->setEnabled(false);
#endif
    ui_audio_setting_->horizontalSliderSystemAudioLoopbackVolume->setValue(100);
    ui_audio_setting_->checkBoxSytemAudioLoopbak->setChecked(false);

    ui_audio_setting_->horizontalSliderCurrentDeviceVolume->setValue(tx_device_manager_->getCurrentDeviceVolume(trtc::TXMediaDeviceType::TXMediaDeviceTypeSpeaker));
    ui_audio_setting_->checkBoxCurrentDeviceMute->setChecked(tx_device_manager_->getCurrentDeviceMute(trtc::TRTCDeviceType::TXMediaDeviceTypeSpeaker));
    ui_audio_setting_->horizontalSliderAudioCaptureVolume->setValue(trtccloud_->getAudioCaptureVolume());
    updateRemoteUsersList();
}

void TestAudioSetting::updateRemoteUsersList() {
    std::vector<std::string> room_users;
    RoomInfoHolder::GetInstance().getRoomUsers(room_users);
    ui_audio_setting_->comboBoxRemoteUsers->clear();
    for (std::string user : room_users) {
        ui_audio_setting_->comboBoxRemoteUsers->addItem(QString::fromLocal8Bit(user.c_str()));
    }
}

void TestAudioSetting::resetUI() {
    initUIStatus();
}

void TestAudioSetting::retranslateUi() {
    ui_audio_setting_->retranslateUi(this);
}