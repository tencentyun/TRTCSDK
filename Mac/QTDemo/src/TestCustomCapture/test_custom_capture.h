/**
 * TRTC 自定义采集模块，演示如何自定义采集音频/视频上行
 *
 * - 核心用法即需要用 sendCustomVideoData() /sendCustomAudioData() 不断地向 SDK 塞入自己采集的视频/音频画面。
 * -
 * - 音频采集 : 参考startCustomAudioData()/stopCustomAudioData()
 * - 视频采集 : 参考startCustomVideoData()/stopCustomVideoData()
 * - 具体API说明可参见：https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__ITRTCCloud__cplusplus.html#aeeff994b8a298fa4948a11225312f629
 */

/**
 * Custom capturing, i.e., capturing custom audio/video to send to the cloud
 *
 * - The key is using sendCustomVideoData()/sendCustomAudioData() to keep feeding video/audio captured by yourself into the SDK.
 * -
 * - Audio capturing:  startCustomAudioData()/stopCustomAudioData()
 * - Video capturing:  startCustomVideoData()/stopCustomVideoData()
 * - For details about the APIs, see: https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__ITRTCCloud__cplusplus.html#aeeff994b8a298fa4948a11225312f629
 */

#ifndef TESTCUSTOMCAPTURE_H
#define TESTCUSTOMCAPTURE_H

#include <QFile>
#include <QDir>
#include <functional>
#include <thread>

#include "test_user_video_group.h"
#include "ui_TestCustomCaptureDialog.h"
#include "gl_yuv_widget.h"
#include "base_dialog.h"

class CustomCaptureWorker;
class TestCustomCapture :public BaseDialog
{
    Q_OBJECT
public:
    explicit TestCustomCapture(std::shared_ptr<TestUserVideoGroup> testUserVideoGroup, QWidget* parent = nullptr);
    ~TestCustomCapture();

private:
    void startCustomAudioData(QString path);
    void startCustomVideoData(QString path);
    void stopCustomAudioData();
    void stopCustomVideoData();


private slots:
    void on_btnAudioCustomCapture_clicked();
    void on_btnVideoCustomCapture_clicked();

public:
    void closeEvent(QCloseEvent* event) override;

private:
    void destroyCustomCapture();
    void retranslateUi() override;
    void updateDynamicTextUI() override;
private:
    std::shared_ptr<TestUserVideoGroup> test_user_video_group_ = nullptr;
    std::unique_ptr<Ui::TestCustomCaptureDialog> ui_test_custom_capture_;
    GLYuvWidget* gl_yuv_widget_ = nullptr;
    std::thread* custom_audio_thread_ = nullptr;
    std::thread* custom_video_thread_ = nullptr;

    bool custom_videocapture_started = false;
    bool custom_audiocapture_started = false;
    bool stop_custom_audio_sender = true;
    bool stop_custom_video_sender = true;
};

#endif // TESTCUSTOMCAPTURE_H
