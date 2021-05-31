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

#ifndef TESTAUDIOSETTING_H
#define TESTAUDIOSETTING_H

#include<QDialog>
#include<QVector>

#include "ui_TestAudioSettingDialog.h"
#include "ITRTCCloud.h"
#include "room_info_holder.h"

class TestAudioSetting:
        public QDialog
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
    void showEvent(QShowEvent *event) override;

private:
    //UI-related
    void initUIStatus();

private:
    std::unique_ptr<Ui::TestAudioSettingDialog> ui_audio_setting_;
    trtc::ITRTCCloud *trtccloud_;
    trtc::ITXDeviceManager *tx_device_manager_;
    trtc::ITXAudioEffectManager *tx_audio_effect_manager_;
    QString current_selected_remote_user_id_;

};

#endif // TESTAUDIOSETTING_H
