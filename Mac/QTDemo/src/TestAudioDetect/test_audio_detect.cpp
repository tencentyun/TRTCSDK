#include "test_audio_detect.h"

TestAudioDetect::TestAudioDetect(QWidget *parent) :
    BaseDialog(parent),
    ui_audio_test_(new Ui::TestAudioDetectDialog)
{
    ui_audio_test_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    getTRTCShareInstance()->addCallback(this);
    tx_device_manager_ = getTRTCShareInstance()->getDeviceManager();
    initUIStatus();
}

TestAudioDetect::~TestAudioDetect() {
    getTRTCShareInstance()->removeCallback(this);
}

//============= ITRTCCloudCallback start ===================//
void TestAudioDetect::onTestMicVolume(uint32_t volume)
{
    ui_audio_test_->progressBarMicTestResult->setValue(static_cast<int>(volume));
}

void TestAudioDetect::onTestSpeakerVolume(uint32_t volume)
{
    ui_audio_test_->progressBarSpeakerTestResult->setValue(static_cast<int>(volume));
}
//============= ITRTCCloudCallback end ===================//


void TestAudioDetect::startMicTest()
{
    getTRTCShareInstance()->muteLocalAudio(false);
    mic_test_started_ = true;
    tx_device_manager_->startMicDeviceTest(300);
    updateDynamicTextUI();
}

void TestAudioDetect::stopMicTest()
{
    ui_audio_test_->pushButtonStartMicTest->setChecked(false);
    mic_test_started_ = false;
    tx_device_manager_->stopMicDeviceTest();
    ui_audio_test_->progressBarMicTestResult->setValue(0);
    updateDynamicTextUI();
}

void TestAudioDetect::startSpeakerTest()
{
    const QString qtmp_file = qtemp_dir_.path() + "/test.mp3";
    QByteArray qtmp_file_bytearray = qtmp_file.toLatin1();
    QFile::copy(":sound/audio/sound/test.mp3", qtmp_file);
    const char *file_path = qtmp_file_bytearray.data();
    tx_device_manager_->startSpeakerDeviceTest(file_path);
    speaker_test_started_ = true;
    updateDynamicTextUI();
}

void TestAudioDetect::stopSpeakerTest()
{
    ui_audio_test_->pushButtonStartSpeakerTest->setChecked(false);
    tx_device_manager_->stopSpeakerDeviceTest();
    ui_audio_test_->progressBarSpeakerTestResult->setValue(0);
    speaker_test_started_ = false;
    updateDynamicTextUI();
}

void TestAudioDetect::initUIStatus()
{
    device_info_ready_ = false;
    if(tx_device_manager_ != nullptr) {
        refreshMicDevices();
        refreshSpeakerDevices();
        device_info_ready_ = true;
    }
    ui_audio_test_->pushButtonStartMicTest->setEnabled(device_info_ready_);
    ui_audio_test_->pushButtonStartSpeakerTest->setChecked(device_info_ready_);
    if(device_info_ready_) {
        ui_audio_test_->pushButtonStartMicTest->setChecked(false);
        ui_audio_test_->pushButtonStartSpeakerTest->setChecked(false);
    }
}

void TestAudioDetect::refreshMicDevices()
{
    if(tx_device_manager_ == nullptr) {
        return;
    }
    //microphone
    qvector_device_info_mic_.clear();
    trtc::ITXDeviceCollection *device_collection_microphone = tx_device_manager_->getDevicesList(trtc::TXMediaDeviceType::TXMediaDeviceTypeMic);
    uint32_t microphone_device_count = device_collection_microphone->getCount();
    if(microphone_device_count != 0) {

        trtc::ITXDeviceInfo *current_microphone_device = tx_device_manager_->getCurrentDevice(trtc::TXMediaDeviceType::TXMediaDeviceTypeMic);
        ui_audio_test_->comboBoxMic->clear();
        uint32_t current_selected_microphone_device_index = 0;

        for(uint32_t index = 0; index < microphone_device_count; index++) {

            const DeviceInfoItem item = DeviceInfoItem(device_collection_microphone->getDeviceName(index), device_collection_microphone->getDevicePID(index), trtc::TXMediaDeviceType::TXMediaDeviceTypeMic);
            qvector_device_info_mic_.append(item);
            ui_audio_test_->comboBoxMic->addItem(QString::fromStdString(item.device_name_));

            if(strcmp(item.device_id_.data(), current_microphone_device->getDevicePID()) == 0) {
                current_selected_microphone_device_index = index;
            }
        }
        ui_audio_test_->comboBoxMic->setCurrentIndex(current_selected_microphone_device_index);
    }

    device_collection_microphone->release();
}

void TestAudioDetect::refreshSpeakerDevices()
{
    if(tx_device_manager_ == nullptr) {
        return;
    }
    //loudspeaker
    qvector_device_info_speaker_.clear();
    trtc::ITXDeviceCollection *device_collection_loudspeaker = tx_device_manager_->getDevicesList(trtc::TXMediaDeviceType::TXMediaDeviceTypeSpeaker);
    uint32_t loudspeaker_device_count = device_collection_loudspeaker->getCount();
    if(loudspeaker_device_count != 0) {

        trtc::ITXDeviceInfo *current_loudspeaker_device = tx_device_manager_->getCurrentDevice(trtc::TXMediaDeviceType::TXMediaDeviceTypeSpeaker);
        ui_audio_test_->comboBoxSpeaker->clear();
        uint32_t current_selected_loudspeaker_device_index = 0;

        for(uint32_t index = 0; index < loudspeaker_device_count; index++) {

            const DeviceInfoItem item = DeviceInfoItem(device_collection_loudspeaker->getDeviceName(index), device_collection_loudspeaker->getDevicePID(index), trtc::TXMediaDeviceType::TXMediaDeviceTypeSpeaker);
            qvector_device_info_speaker_.append(item);
            ui_audio_test_->comboBoxSpeaker->addItem(QString::fromStdString(item.device_name_));

            if(strcmp(item.device_id_.data(), current_loudspeaker_device->getDevicePID()) == 0) {
                current_selected_loudspeaker_device_index = index;
            }
        }
        ui_audio_test_->comboBoxSpeaker->setCurrentIndex(current_selected_loudspeaker_device_index);
    }

    device_collection_loudspeaker->release();
}

void TestAudioDetect::on_comboBoxMic_currentIndexChanged(int index)
{
    if(device_info_ready_ && index >= 0 && qvector_device_info_mic_.size() > index) {
        const DeviceInfoItem &item = qvector_device_info_mic_.at(index);
        tx_device_manager_->setCurrentDevice(item.device_type_, item.device_id_.data());
    }
}

void TestAudioDetect::on_comboBoxSpeaker_currentIndexChanged(int index)
{
    if(device_info_ready_ && index >= 0 && qvector_device_info_speaker_.size() > index) {
        const DeviceInfoItem &item = qvector_device_info_speaker_.at(index);
        tx_device_manager_->setCurrentDevice(item.device_type_, item.device_id_.data());
    }
}

void TestAudioDetect::on_sliderSpeakerVolume_valueChanged(int value)
{
    tx_device_manager_->setCurrentDeviceVolume(trtc::TXMediaDeviceTypeSpeaker, (uint32_t)value);
}

void TestAudioDetect::on_sliderMicVolume_valueChanged(int value)
{
    tx_device_manager_->setCurrentDeviceVolume(trtc::TXMediaDeviceTypeMic, (uint32_t)value);
}

void TestAudioDetect::on_pushButtonStartMicTest_clicked(bool checked)
{
    if (checked) {
        startMicTest();
    } else {
        stopMicTest();
    }
}

void TestAudioDetect::on_pushButtonStartSpeakerTest_clicked(bool checked)
{
    if(checked && qtemp_dir_.isValid()) {
        startSpeakerTest();
    } else {
        stopSpeakerTest();
    }
}

void TestAudioDetect::showEvent(QShowEvent *event)
{
    initUIStatus();
    BaseDialog::showEvent(event);
}

void TestAudioDetect::closeEvent(QCloseEvent *event)
{
    stopMicTest();
    stopSpeakerTest();
    BaseDialog::closeEvent(event);
}

void TestAudioDetect::updateDynamicTextUI() {
    if (mic_test_started_) {
        ui_audio_test_->pushButtonStartMicTest->setText(tr("停止测试"));
    } else {
        ui_audio_test_->pushButtonStartMicTest->setText(tr("开始测试"));
    }
    if (speaker_test_started_) {
        ui_audio_test_->pushButtonStartSpeakerTest->setText(tr("停止测试"));
    } else {
        ui_audio_test_->pushButtonStartSpeakerTest->setText(tr("开始测试"));
    }
}

void TestAudioDetect::retranslateUi() {
    ui_audio_test_->retranslateUi(this);
}