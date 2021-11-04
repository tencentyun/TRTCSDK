#include "test_video_detect.h"

TestVideoDetect::TestVideoDetect(QWidget *parent) :
    BaseDialog(parent),
    ui_video_test_(new Ui::TestVideoDetectDialog)
{
    ui_video_test_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    tx_device_manager_ = getTRTCShareInstance()->getDeviceManager();
}

TestVideoDetect::~TestVideoDetect() {
}

void TestVideoDetect::startCameraTest()
{
    tx_device_manager_->startCameraDeviceTest(reinterpret_cast<void*>(ui_video_test_->videoview->winId()));
    camera_test_started_ = true;
    updateDynamicTextUI();
}

void TestVideoDetect::stopCameraTest()
{
    ui_video_test_->pushButtonStartCameraTest->setChecked(false);
    tx_device_manager_->stopCameraDeviceTest();
    camera_test_started_ = false;
    updateDynamicTextUI();
}

void TestVideoDetect::on_pushButtonStartCameraTest_clicked(bool checked)
{
    if (checked) {
        startCameraTest();
    } else {
        stopCameraTest();
    }
}

void TestVideoDetect::on_comboBoxCameraDevices_currentIndexChanged(int index)
{
    if(device_info_ready_ && index >= 0 && qvector_device_info_camera_.size() > index) {
        const DeviceInfoItem &item = qvector_device_info_camera_.at(index);
        tx_device_manager_->setCurrentDevice(item.device_type_, item.device_id_.data());
    }
}

void TestVideoDetect::showEvent(QShowEvent *event)
{
    initUIStatus();
    BaseDialog::showEvent(event);
}

void TestVideoDetect::closeEvent(QCloseEvent *event)
{
    stopCameraTest();
    BaseDialog::closeEvent(event);
}

void TestVideoDetect::initUIStatus()
{
    device_info_ready_ = false;
    refreshCameraDevices();
    ui_video_test_->pushButtonStartCameraTest->setChecked(false);
}

void TestVideoDetect::refreshCameraDevices()
{
    if(tx_device_manager_ == nullptr) {
        return;
    }
    qvector_device_info_camera_.clear();
    trtc::ITXDeviceCollection *device_collection_camera = tx_device_manager_->getDevicesList(trtc::TXMediaDeviceType::TXMediaDeviceTypeCamera);
    uint32_t camera_device_count = device_collection_camera->getCount();
    if(camera_device_count != 0) {

        trtc::ITXDeviceInfo *current_camera_device = tx_device_manager_->getCurrentDevice(trtc::TXMediaDeviceType::TXMediaDeviceTypeCamera);
        ui_video_test_->comboBoxCameraDevices->clear();
        uint32_t current_selected_camera_device_index = 0;

        for(uint32_t index = 0; index < camera_device_count; index++) {

            const DeviceInfoItem item = DeviceInfoItem(device_collection_camera->getDeviceName(index), device_collection_camera->getDevicePID(index), trtc::TXMediaDeviceType::TXMediaDeviceTypeCamera);
            qvector_device_info_camera_.append(item);
            ui_video_test_->comboBoxCameraDevices->addItem(QString::fromStdString(item.device_name_));

            if(strcmp(item.device_id_.data(), current_camera_device->getDevicePID()) == 0) {
                current_selected_camera_device_index = index;
            }
        }
        ui_video_test_->comboBoxCameraDevices->setCurrentIndex(current_selected_camera_device_index);
    }

    device_collection_camera->release();
    device_info_ready_ = true;
}

void TestVideoDetect::updateDynamicTextUI() {
    if (camera_test_started_) {
        ui_video_test_->pushButtonStartCameraTest->setText(tr("停止测试"));
    } else {
        ui_video_test_->pushButtonStartCameraTest->setText(tr("开始测试"));
    }
}

void TestVideoDetect::retranslateUi() {
    ui_video_test_->retranslateUi(this);
}