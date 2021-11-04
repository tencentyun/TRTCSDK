/**
 * TRTC CDN混流（需要主播数anchor>=2）
 *
 * - 功能开启需要您在实时音视频控制台中的功能配置页开启了“启动自动旁路直播”功能，房间里的每一路画面都会有一个默认的直播 CDN 地址。
 * - 一个直播间中可能有不止一位主播，而且每个主播都有自己的画面和声音，但对于 CDN 观众来说，他们只需要一路直播流， 所以您需要将多路音视频流混成一路标准的直播流，这就需要混流转码。
 * - 当您调用 setMixTranscodingConfig() 接口时，SDK 会向腾讯云的转码服务器发送一条指令，目的是将房间里的多路音视频流混合为一路, 您可以通过 mixUsers 参数来调整每一路画面的位置，以及是否只混合声音，也可以通过 videoWidth、videoHeight、videoBitrate 等参数控制混合音视频流的编码参数。
 * -
 * - 支持的四种混流方式：
 * - 1.全手动 - startManualTemplate();
 * - 2.预排版 - startPresetLayoutTemplate();
 * - 3.屏幕分享 - startScreenSharingTemplate();
 * - 4.纯音频 - startPureAudioTemplate();
 *
 * - API使用方式细节参见：https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__ITRTCCloud__cplusplus.html#a8c835f1d49ab0f80a85569e030689850
 * - 混流场景及使用介绍见：https://cloud.tencent.com/document/product/647/16827
 */

/**
 * CDN stream mixing (2 or more anchors)
 *
 * - To use this feature, you must enable global auto-relayed push on the "Function Configuration" page of the TRTC console, so that each channel of video in the room has a default CDN address.
 * - There may be multiple anchors in a room, each sending their own video and audio, but CDN audience needs only one live stream. Therefore, you need to mix multiple audio/video streams into one standard live stream, which requires mixtranscoding.
 * - When you call the setMixTranscodingConfig() API, the SDK will send a command to the Tencent Cloud transcoding server to combine multiple audio/video streams in the room into one stream. You can use the "mixUsers" parameter to set the position of each channel of image and specify whether to mix only audio. You can also set the encoding parameters of the mixed stream, including "videoWidth", "videoHeight", and "videoBitrate".
 * -
 * - Supported stream mixing methods:
 * - 1. Manual - startManualTemplate()
 * - 2. Preset layout - startPresetLayoutTemplate()
 * - 3. Screen sharing - startScreenSharingTemplate()
 * - 4. Audio only - startPureAudioTemplate()
 *
 * - For details about the APIs, see: https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__ITRTCCloud__cplusplus.html#a8c835f1d49ab0f80a85569e030689850
 * - For more on stream mixing scenarios and instructions, see: https://intl.cloud.tencent.com/document/product/647/34618
 */

#ifndef TESTMIXSTREAMPUBLISH_H
#define TESTMIXSTREAMPUBLISH_H

#include <QButtonGroup>
#include <set>

#include "base_dialog.h"
#include "ui_TestMixStreamPublishDialog.h"
#include "trtc_cloud_callback_default_impl.h"

class TestMixStreamPublish:public BaseDialog, public TrtcCloudCallbackDefaultImpl
{
    Q_OBJECT
public:
    explicit TestMixStreamPublish(QWidget* parent = nullptr);
    ~TestMixStreamPublish();
private:
    void startManualTemplate();
    void startPresetLayoutTemplate();
    void startScreenSharingTemplate();
    void startPureAudioTemplate();

    //============= ITRTCCloudCallback start ===============//
    void onExitRoom(int reason) override;
    void onSetMixTranscodingConfig(int errCode, const char *errMsg) override;
    void onUserVideoAvailable(const char* userId, bool available) override;
    void onUserAudioAvailable(const char* userId, bool available) override;

    // In the manual mode, if screen sharing is enabled, you need to manually change the user’s stream to mix.
    void onScreenCaptureStarted() override;
    void onScreenCaptureStoped(int reason) override;
    //============= ITRTCCloudCallback end =================//


private slots:
    void on_streamIdLineEt_textChanged(const QString &arg1);
    void on_startMixStreamPublishBt_clicked();
    void on_config_mode_checked_change();

public:
    void closeEvent(QCloseEvent *event) override;
    void showEvent(QShowEvent *event) override;

private:
    void initUI();
    bool isStartMixStreamBtAvailable();
    bool getTranscodingConfig();
    void updateTranscodingConfig();
    void updatePublishButtonStatus();
    void retranslateUi() override;
    void updateDynamicTextUI() override;
private:
    struct RemoteUserInfo{
        std::string user_id_;
        bool video_available_ = false;
        bool audio_available_ = false;
    };

    static constexpr const int32_t kAudioSampleRate[]{
        12000,
        16000,
        22050,
        24000,
        32000,
        44100,
        48000,
    };
private:
    std::unique_ptr<Ui::TestMixStreamPublishDialog> ui_test_mix_stream_publish_;

    trtc::TRTCTranscodingConfig trtc_transcoding_config;
    //============= TRTCTranscodingConfig start ===============//
    trtc::TRTCTranscodingConfigMode mix_config_mode_ = trtc::TRTCTranscodingConfigMode_Unknown;
    uint32_t    video_width_      = 360;
    uint32_t    video_height_     = 640;
    uint32_t    video_bitrate_    = 64;
    uint32_t    video_framerate_  = 15;
    uint32_t    video_gop_        = 2;
    uint32_t    background_color_ = 0x000000;
    std::string background_imag_;
    uint32_t    audio_samplerate_ = 48000;
    uint32_t    audio_bitrate_    = 64;
    uint32_t    audio_channels_   = 1;
    //============= TRTCTranscodingConfig end =================//

    // Data lock, which can prevent data inconsistency
    std::vector<RemoteUserInfo*> remote_userinfos_;
    bool screen_shared_started_ = false;

    QButtonGroup config_mode_button_group;
    bool started_transcoding_ = false;
};

#endif // TESTMIXSTREAMPUBLISH_H
