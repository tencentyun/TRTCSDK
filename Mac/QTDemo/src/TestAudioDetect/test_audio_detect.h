/**
 * TRTC 音频检测
 *
 * - 需要通过getDeviceManager()获取ITXDeviceManager实例执行音频检测
 * - 调用方式参见：
 * - 1.麦克风检测 - startMicTest();stopMicTest();
 * - 2.扬声器检测 - startSpeakerTest();stopSpeakerTest();
 * -
 * - 获取可用设备方式参见：
 * - refreshMicDevices()/refreshSpeakerDevices();
 * -
 * - 需要关注的回调方法：
 * - onTestMicVolume(uint32_t volume);void onTestSpeakerVolume(uint32_t volume);
 */

/**
 * Audio testing
 *
 * - Call getDeviceManager() to get an ITXDeviceManager instance for audio testing.
 * - For the specific method, please refer to:
 * - 1. Mic testing - startMicTest(); stopMicTest()
 * - 2. Speaker testing - startSpeakerTest(); stopSpeakerTest()
 * -
 * - Getting available devices:
 * - refreshMicDevices()/refreshSpeakerDevices()
 * -
 * - Relevant callback APIs:
 * - onTestMicVolume(uint32_t volume); void onTestSpeakerVolume(uint32_t volume)
 */

#ifndef TESTAUDIODETECT_H
#define TESTAUDIODETECT_H

#include<QVector>
#include<QTemporaryDir>
#include<QString>
#include<string>

#include "trtc_cloud_callback_default_impl.h"
#include "ui_TestAudioDetectDialog.h"
#include "base_dialog.h"

class TestAudioDetect:
        public BaseDialog,
        public TrtcCloudCallbackDefaultImpl
{
    Q_OBJECT
public:
    explicit TestAudioDetect(QWidget *parent = nullptr);
    ~TestAudioDetect();

    //============= ITRTCCloudCallback start ===================//
    void onTestMicVolume (uint32_t volume) override;
    void onTestSpeakerVolume (uint32_t volume) override;
    //============= ITRTCCloudCallback end ===================//

private:
    void startMicTest();
    void stopMicTest();
    void startSpeakerTest();
    void stopSpeakerTest();
    void refreshMicDevices();
    void refreshSpeakerDevices();

private slots:
    void on_comboBoxMic_currentIndexChanged(int index);

    void on_comboBoxSpeaker_currentIndexChanged(int index);

    void on_sliderSpeakerVolume_valueChanged(int value);

    void on_sliderMicVolume_valueChanged(int value);

    void on_pushButtonStartMicTest_clicked(bool checked);

    void on_pushButtonStartSpeakerTest_clicked(bool checked);

public:
    //UI-related
    void showEvent(QShowEvent *event) override;
    void closeEvent(QCloseEvent *event) override;
private:
    void initUIStatus();
    void retranslateUi() override;
    void updateDynamicTextUI() override;
private:
    struct DeviceInfoItem {
    std::string device_name_;
    std::string device_id_;
    trtc::TXMediaDeviceType device_type_;

    DeviceInfoItem() {}
    DeviceInfoItem(std::string device_name, std::string device_id, trtc::TXMediaDeviceType device_type) :
        device_name_(device_name), device_id_(device_id), device_type_(device_type) {}
    };

private:
    bool device_info_ready_ = false;
    QTemporaryDir qtemp_dir_;
    std::unique_ptr<Ui::TestAudioDetectDialog> ui_audio_test_;
    trtc::ITXDeviceManager *tx_device_manager_;
    QVector<DeviceInfoItem> qvector_device_info_mic_;
    QVector<DeviceInfoItem> qvector_device_info_speaker_;
    bool mic_test_started_ = false;
    bool speaker_test_started_ = false;
};

#endif // TESTAUDIODETECT_H
