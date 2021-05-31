/**
 * TRTC 设备管理
 *
 * - 需要通过getDeviceManager()获取ITXDeviceManager实例，获取当前设备列表，设置当前使用设备
 * - 获取当前视频采集设备/麦克风/扬声器设备列表的调用方式参考：
 * - refreshMicDevices()
 * - refreshCameraDevices()
 * - refreshSpeakerDevices()
 * -
 * - 设置当前使用设备：
 * - setCurrentDevice(); API文档参见https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__ITXDeviceManager__cplusplus.html#abedb16669f004919730e9c027b71808c
 */

#ifndef TESTDEVICEMANAGER_H
#define TESTDEVICEMANAGER_H

#include <QDialog>
#include <QVector>
#include <QString>
#include <string>

#include "trtc_cloud_callback_default_impl.h"
#include "ui_TestDeviceManagerDialog.h"

class TestDeviceManager:public QDialog, public TrtcCloudCallbackDefaultImpl
{
    Q_OBJECT
public:
    explicit TestDeviceManager(QWidget *parent = nullptr);
    ~TestDeviceManager();

    //============= ITRTCCloudCallback start =================//
    void onDeviceChange(const char* deviceId, trtc::TRTCDeviceType type, trtc::TRTCDeviceState state) override;
    //============= ITRTCCloudCallback end ===================//

private:
    void refreshMicDevices();
    void refreshCameraDevices();
    void refreshSpeakerDevices();

private:
    struct DeviceInfoItem {

    std::string device_name_;
    std::string device_id_;
    trtc::TXMediaDeviceType device_type_;

    DeviceInfoItem(){}
    DeviceInfoItem(std::string device_name, std::string device_id, trtc::TXMediaDeviceType device_type) :
            device_name_(device_name), device_id_(device_id), device_type_(device_type) {}

    };

public:
    //UI-related
    void showEvent(QShowEvent *event) override;

private:
    void setupDeviceRelatedElements();

    bool device_info_ready_;

    std::unique_ptr<Ui::TestDeviceMangerDialog> ui_device_manager_;
    trtc::ITXDeviceManager *tx_device_manager_;
    QVector<DeviceInfoItem> qvector_device_info_camera_;
    QVector<DeviceInfoItem> qvector_device_info_microphone_;
    QVector<DeviceInfoItem> qvector_device_info_loudspeaker_;

private slots:
    void on_cameraChooseComboBox_currentIndexChanged(int index);
    void on_microphoneChooseComboBox_currentIndexChanged(int index);
    void on_loudspeakerChooseComboBox_currentIndexChanged(int index);


};

#endif // TESTDEVICEMANAGER_H
