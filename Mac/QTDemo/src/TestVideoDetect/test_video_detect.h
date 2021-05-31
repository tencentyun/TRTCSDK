/**
 * TRTC 视频采集设备检测
 *
 * - 需要通过getDeviceManager()获取ITXDeviceManager实例执行视频采集设备检测
 * - 调用方式参见：startCameraTest()/stopCameraTest();
 * -
 * - 获取可用设备方式参见：
 * - refreshCameraDevices()
 */

#ifndef TESTVIDEODETECT_H
#define TESTVIDEODETECT_H

#include<QDialog>
#include<QVector>
#include<QString>
#include<string>

#include "trtc_cloud_callback_default_impl.h"
#include "ui_TestVideoDetectDialog.h"

class TestVideoDetect:
        public QDialog,
        public TrtcCloudCallbackDefaultImpl
{
    Q_OBJECT
public:
    explicit TestVideoDetect(QWidget *parent = nullptr);
    ~TestVideoDetect();

private:
    void startCameraTest();
    void stopCameraTest();
    void refreshCameraDevices();

private slots:
    void on_pushButtonStartCameraTest_clicked(bool checked);

    void on_comboBoxCameraDevices_currentIndexChanged(int index);

public:
    //UI-related
    void showEvent(QShowEvent *) override;
    void closeEvent(QCloseEvent *event) override;

private:
    void initUIStatus();

private:
    struct DeviceInfoItem {

    std::string device_name_;
    std::string device_id_;
    trtc::TXMediaDeviceType device_type_;

    DeviceInfoItem(){}
    DeviceInfoItem(std::string device_name, std::string device_id, trtc::TXMediaDeviceType device_type) :
            device_name_(device_name), device_id_(device_id), device_type_(device_type) {}

    };

private:
    std::unique_ptr<Ui::TestVideoDetectDialog> ui_video_test_;
    trtc::ITXDeviceManager *tx_device_manager_;
    QVector<DeviceInfoItem> qvector_device_info_camera_;
    bool device_info_ready_;
};

#endif // TESTVIDEODETECT_H
