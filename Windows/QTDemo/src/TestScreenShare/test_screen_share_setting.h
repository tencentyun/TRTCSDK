/**
 * TRTC 屏幕分享（参数设置）
 *
 * - 核心逻辑实现参考：
 * - 1. setSubStreamEncoderParam()  :设置屏幕分享的编码器参数，具体参见：https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__ITRTCCloud__cplusplus.html#abdc3d6339afd741bd8d3ed88ea551282
 * - 2. setSubStreamMixVolume()     :设置屏幕分享的混音音量大小，这个数值越高，屏幕分享音量的占比就越高，麦克风音量占比就越小
 * - 3. updateScreenSharingParams() :设置屏幕分享的captureRECT(捕获区域)，设置屏幕分享的TRTCScreenCaptureProperty(包含是否捕获鼠标，高亮捕获窗口等特性)，具体可参考：https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__ITRTCCloud__cplusplus.html#adc372b21294cd36bf4f4af0d1ac6624a
 */

/**
 * Screen sharing (parameter setting)
 *
 * - Implementation logic:
 * - 1. setSubStreamEncoderParam(): set encoder parameters for screen sharing. For details, see: https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__ITRTCCloud__cplusplus.html#abdc3d6339afd741bd8d3ed88ea551282
 * - 2. setSubStreamMixVolume(): set the volume of screen sharing in audio mixing. The higher the volume, the louder screen sharing is in relation to mic-captured audio.
 * - 3. updateScreenSharingParams(): set captureRECT (capturing area) and TRTCScreenCaptureProperty (whether to capture the mouse pointer, show a bright border around the shared content, etc.) for screen sharing. For details, see: https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__ITRTCCloud__cplusplus.html#adc372b21294cd36bf4f4af0d1ac6624a
 */

#ifndef TESTSCREENSHARESETTING_H
#define TESTSCREENSHARESETTING_H

#include "base_dialog.h"
#include "trtc_cloud_callback_default_impl.h"
#include "ui_TestScreenShareSettingDialog.h"
#include "test_screen_share_select_screen.h"
#include "test_screen_share_select_window.h"
#include "test_user_video_group.h"

class TestScreenShareSetting:public BaseDialog,public TrtcCloudCallbackDefaultImpl
{
    Q_OBJECT
public:
    explicit TestScreenShareSetting(std::shared_ptr<TestUserVideoGroup> testUserVideoGroup, QWidget* parent = nullptr);
    ~TestScreenShareSetting();

private :
    void updateScreenSharingParams();
    void setSubStreamMixVolume(int volume);
    void setSubStreamEncoderParam(trtc::TRTCVideoStreamType streamType,trtc::TRTCVideoEncParam& videoEncParam);
private slots:
    void on_btUpdateScreenSharing_clicked();
    void on_btSharingAllScreen_clicked();
    void on_btSharingSelectedWindow_clicked();
    void on_sliderScreenCaptureMixVolume_valueChanged(int value);

private:
    void configViewParams();
    inline trtc::TRTCVideoResolution indexConvertToVideoResolution(int index);
    void retranslateUi() override;
public:
    void closeEvent(QCloseEvent *event) override;

private:
    std::unique_ptr<Ui::TestScreenShareSettingDialog> ui_screen_share_setting_;
    std::shared_ptr<TestUserVideoGroup> test_user_video_group_;
    TestScreenShareSelectScreen test_screensharing_withscreen;
    TestScreenShareSelectWindow test_screensharing_withwindow;

    trtc::TRTCVideoResolution video_resolution_ = trtc::TRTCVideoResolution_1280_720;
    trtc::TRTCVideoResolutionMode res_mode_ = trtc::TRTCVideoResolutionModeLandscape;
    trtc::TRTCVideoStreamType video_stream_type = trtc::TRTCVideoStreamTypeSub;
    uint32_t mix_volume = 50;
    uint32_t videofps_ = 15;
    uint32_t video_bitrate_ = 1200;
    uint32_t min_video_bitrate_ = 50;

    bool enable_adjustres_ = false;
    bool enable_highlight_ = true;
    bool enable_capturemouse_ = true;
    bool enable_high_performance = true;

    // Default value. The value can be modified.
    int high_light_color_ = 0x8CBF26;
    int high_light_width_ = 5;
    bool enable_capture_childwindow = false;

    RECT capture_rect_;
};

#endif // TESTSCREENSHARESETTING_H
