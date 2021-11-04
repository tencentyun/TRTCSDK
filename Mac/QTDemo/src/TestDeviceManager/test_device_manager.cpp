#include "test_device_manager.h"

TestDeviceManager::TestDeviceManager(QWidget *parent) :
    BaseDialog(parent),
    ui_device_manager_(new Ui::TestDeviceMangerDialog)
{
    ui_device_manager_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    getTRTCShareInstance()->addCallback(this);
    tx_device_manager_ = getTRTCShareInstance()->getDeviceManager();
}

TestDeviceManager::~TestDeviceManager() {
    getTRTCShareInstance()->removeCallback(this);
}

void TestDeviceManager::showEvent(QShowEvent *event)
{
    device_info_ready_ = false;
    setupDeviceRelatedElements();
    BaseDialog::showEvent(event);
}

void TestDeviceManager::setupDeviceRelatedElements()
{
    if(tx_device_manager_ != nullptr) {
        refreshCameraDevices();
        refreshMicDevices();
        refreshSpeakerDevices();
        device_info_ready_ = true;
    }
}

void TestDeviceManager::refreshMicDevices()
{
    qvector_device_info_microphone_.clear();
    if(tx_device_manager_ == nullptr) {
        return;
    }
    trtc::ITXDeviceCollection* device_collection_microphone = tx_device_manager_->getDevicesList(trtc::TXMediaDeviceType::TXMediaDeviceTypeMic);
    uint32_t microphone_device_count = device_collection_microphone->getCount();
    if(microphone_device_count != 0) {
        trtc::ITXDeviceInfo *current_microphone_device = tx_device_manager_->getCurrentDevice(trtc::TXMediaDeviceType::TXMediaDeviceTypeMic);
        ui_device_manager_->microphoneChooseComboBox->clear();
        uint32_t current_selected_microphone_device_index = 0;
        for(uint32_t index = 0; index < microphone_device_count; index++) {
            const DeviceInfoItem item = DeviceInfoItem(device_collection_microphone->getDeviceName(index), device_collection_microphone->getDevicePID(index), trtc::TXMediaDeviceType::TXMediaDeviceTypeMic);
            qvector_device_info_microphone_.append(item);
            ui_device_manager_->microphoneChooseComboBox->addItem(QString::fromStdString(item.device_name_));
            if(strcmp(item.device_id_.data(), current_microphone_device->getDevicePID()) == 0) {
                current_selected_microphone_device_index = index;
            }
        }
        ui_device_manager_->microphoneChooseComboBox->setCurrentIndex(current_selected_microphone_device_index);
    }

    device_collection_microphone->release();
}

void TestDeviceManager::refreshCameraDevices()
{
    qvector_device_info_camera_.clear();
    if(tx_device_manager_ == nullptr) {
        return;
    }
    trtc::ITXDeviceCollection* device_collection_camera = tx_device_manager_->getDevicesList(trtc::TXMediaDeviceType::TXMediaDeviceTypeCamera);
    uint32_t camera_device_count = device_collection_camera->getCount();
    if(camera_device_count != 0) {
        trtc::ITXDeviceInfo *current_camera_device = tx_device_manager_->getCurrentDevice(trtc::TXMediaDeviceType::TXMediaDeviceTypeCamera);
        ui_device_manager_->cameraChooseComboBox->clear();
        uint32_t current_selected_camera_device_index = 0;
        for(uint32_t index = 0; index < camera_device_count; index++) {
            const DeviceInfoItem item = DeviceInfoItem(device_collection_camera->getDeviceName(index), device_collection_camera->getDevicePID(index), trtc::TXMediaDeviceType::TXMediaDeviceTypeCamera);
            qvector_device_info_camera_.append(item);
            ui_device_manager_->cameraChooseComboBox->addItem(QString::fromStdString(item.device_name_));
            if(strcmp(item.device_id_.data(), current_camera_device->getDevicePID()) == 0) {
                current_selected_camera_device_index = index;
            }
        }
        ui_device_manager_->cameraChooseComboBox->setCurrentIndex(current_selected_camera_device_index);
    }

    device_collection_camera->release();
}

void TestDeviceManager::refreshSpeakerDevices()
{
    qvector_device_info_loudspeaker_.clear();
    if(tx_device_manager_ == nullptr) {
        return;
    }
    trtc::ITXDeviceCollection* device_collection_loudspeaker = tx_device_manager_->getDevicesList(trtc::TXMediaDeviceType::TXMediaDeviceTypeSpeaker);
    uint32_t loudspeaker_device_count = device_collection_loudspeaker->getCount();
    if(loudspeaker_device_count != 0) {
        trtc::ITXDeviceInfo *current_loudspeaker_device = tx_device_manager_->getCurrentDevice(trtc::TXMediaDeviceType::TXMediaDeviceTypeSpeaker);
        ui_device_manager_->loudspeakerChooseComboBox->clear();
        uint32_t current_selected_loudspeaker_device_index = 0;
        for(uint32_t index = 0; index < loudspeaker_device_count; index++) {
            const DeviceInfoItem item = DeviceInfoItem(device_collection_loudspeaker->getDeviceName(index), device_collection_loudspeaker->getDevicePID(index), trtc::TXMediaDeviceType::TXMediaDeviceTypeSpeaker);
            qvector_device_info_loudspeaker_.append(item);
            ui_device_manager_->loudspeakerChooseComboBox->addItem(QString::fromStdString(item.device_name_));
            if(strcmp(item.device_id_.data(), current_loudspeaker_device->getDevicePID()) == 0) {
                current_selected_loudspeaker_device_index = index;
            }
        }
        ui_device_manager_->loudspeakerChooseComboBox->setCurrentIndex(current_selected_loudspeaker_device_index);
    }

    device_collection_loudspeaker->release();
}

void TestDeviceManager::on_cameraChooseComboBox_currentIndexChanged(int index)
{
    if(device_info_ready_ && index >= 0 && qvector_device_info_camera_.size() > index) {
        const DeviceInfoItem &item = qvector_device_info_camera_.at(index);
        tx_device_manager_->setCurrentDevice(item.device_type_, item.device_id_.data());
    }
}

void TestDeviceManager::on_microphoneChooseComboBox_currentIndexChanged(int index)
{
    if(device_info_ready_ && index >= 0 && qvector_device_info_microphone_.size() > index) {
        const DeviceInfoItem &item = qvector_device_info_microphone_.at(index);
        tx_device_manager_->setCurrentDevice(item.device_type_, item.device_id_.data());
    }
}

void TestDeviceManager::on_loudspeakerChooseComboBox_currentIndexChanged(int index)
{
    if(device_info_ready_ && index >= 0 && qvector_device_info_loudspeaker_.size() > index) {
        const DeviceInfoItem &item = qvector_device_info_loudspeaker_.at(index);
        tx_device_manager_->setCurrentDevice(item.device_type_, item.device_id_.data());
    }
}

void TestDeviceManager::retranslateUi() {
    ui_device_manager_->retranslateUi(this);
}