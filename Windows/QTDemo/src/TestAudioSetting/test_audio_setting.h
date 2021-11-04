/**
 * TRTC 音频设置
 *
 * - 此功能模块中，可以参考并调用如下功能
 * - setRemoteAudioVolume -> 设置某个远程用户的播放音量
 * - setAudioPlayoutVolume -> 设置 SDK 播放音量
 * - setApplicationPlayVolume -> 设置 Windows 系统音量合成器中当前进程的音量
 * - setApplicationMuteState -> 设置 Windows 系统音量合成器中当前进程的静音状态
 * - setCurrentDeviceVolume -> 设置当前设备的音量
 * - setCurrentDeviceMute -> 设置当前设备是否静音
 * - setAudioCaptureVolume -> 设置 SDK 采集音量
 * - setSystemAudioLoopbackVolume -> 设置系统声音采集的音量
 * - startSystemAudioLoopback -> 打开系统声音采集(开启后可以采集整个操作系统的播放声音（参数path 为空）或某一个播放器（参数path 不为空）的声音， 并将其混入到当前麦克风采集的声音中一起发送到云端。)
 */

/**
 * Audio settings
 *
 * - In this module, you can do the following by calling the corresponding APIs.
 * - setRemoteAudioVolume -> set the playback volume of a remote user
 * - setAudioPlayoutVolume -> set the SDK playback volume
 * - setApplicationPlayVolume -> set the volume of the current process in the Windows volume mixer
 * - setApplicationMuteState -> mute/unmute the current process in the Windows volume mixer
 * - setCurrentDeviceVolume -> set the volume of the current device
 * - setCurrentDeviceMute -> mute/unmute the current device
 * - setAudioCaptureVolume -> set the SDK capturing volume
 * - setSystemAudioLoopbackVolume -> set the system audio capturing volume
 * - startSystemAudioLoopback -> enable system audio capturing. After system audio capturing is enabled, the audio played by the entire system (if the parameter "path" is empty) or a specific player (if "path" is not empty) will be captured, mixed into the audio captured by the current mic, and sent to the cloud.
 */

#ifndef TESTAUDIOSETTING_H
#define TESTAUDIOSETTING_H

#include<QVector>

#include "ui_TestAudioSettingDialog.h"
#include "ITRTCCloud.h"
#include "room_info_holder.h"
#include "base_dialog.h"

class TestAudioSetting:
        public BaseDialog
{
    Q_OBJECT
public:
    explicit TestAudioSetting(QWidget *parent = nullptr);
    ~TestAudioSetting();

private slots:
    void on_comboBoxRemoteUsers_currentIndexChanged(const QString &value);

    void on_horizontalSliderRemoteUserVolume_valueChanged(int value);

    void on_horizontalSliderAudioPlayoutVolume_valueChanged(int value);

    void on_horizontalSliderApplicationVolume_valueChanged(int value);

    void on_checkBoxApplicationMute_stateChanged(int state);

    void on_horizontalSliderCurrentDeviceVolume_valueChanged(int value);

    void on_checkBoxCurrentDeviceMute_stateChanged(int state);

    void on_horizontalSliderAudioCaptureVolume_valueChanged(int value);

    void on_horizontalSliderSystemAudioLoopbackVolume_valueChanged(int value);

    void on_checkBoxSytemAudioLoopbak_stateChanged(int state);

public:
    //UI-related
    void resetUI() override;

private:
    //UI-related
    void showEvent(QShowEvent* event) override;
    void initUIStatus();
    void updateRemoteUsersList();
    void retranslateUi() override;

private:
    std::unique_ptr<Ui::TestAudioSettingDialog> ui_audio_setting_;
    trtc::ITRTCCloud *trtccloud_;
    trtc::ITXDeviceManager *tx_device_manager_;
    trtc::ITXAudioEffectManager *tx_audio_effect_manager_;
    QString current_selected_remote_user_id_;

};

#endif // TESTAUDIOSETTING_H
