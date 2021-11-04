/**
 * TRTC 屏幕分享（选择窗口）
 *
 * - 核心逻辑实现参考：
 * - 1. initScreenCaptureSources()          : 通过getScreenCaptureSources()获取可分享的屏幕窗口，包含屏幕和应用窗口两种类型，在返回值中，仅保留TRTCScreenCaptureSourceType为TRTCScreenCaptureSourceTypeWindow的窗口
 * - 2. initScreenSharingWindowSelections() : 将获取到的TRTCScreenCaptureSourceInfo列表展示到UI上，供用户选择
 * - 3. selectScreenCaptureTarget()         : 设置屏幕分享参数，具体参数可参考test_screen_share_setting.h
 * - 4. startScreenSharing()                : 开始屏幕分享
 * - 5. pauseScreenCapture()                : 暂停屏幕分享
 * - 6. resumeScreenCapture()               : 恢复屏幕分享
 * - 7. stopScreenSharing()                 : 停止屏幕分享
 * - 8. releaseScreenCaptureSourceList()    : 遍历完窗口列表后，需要调用release释放资源。
 */

/**
 * Screen sharing (window)
 *
 * - Implementation logic:
 * - 1. initScreenCaptureSources():  call getScreenCaptureSources() to get the shareable screens and windows. Retain only windows (TRTCScreenCaptureSourceType = TRTCScreenCaptureSourceTypeWindow) from the results returned.
 * - 2. initScreenSharingWindowSelections():  display the TRTCScreenCaptureSourceInfo list obtained on the UI for users to choose from.
 * - 3. selectScreenCaptureTarget():  set screen sharing parameters. For details, see test_screen_share_setting.h.
 * - 4. startScreenSharing():  start screen sharing
 * - 5. pauseScreenCapture():  pause screen sharing
 * - 6. resumeScreenCapture():  resume screen sharing
 * - 7. stopScreenSharing():  stop screen sharing
 * - 8. releaseScreenCaptureSourceList(): call release to release the resources after traversing the list
 */

#ifndef TESTSCREENSHARSELECTWINDOW_H
#define TESTSCREENSHARSELECTWINDOW_H

#include "ITRTCCloud.h"
#include "base_dialog.h"
#include "trtc_cloud_callback_default_impl.h"
#include "ui_TestScreenShareSelectWindowDialog.h"
#include "screen_share_selection_item.h"
#include "test_user_video_group.h"

#ifndef _WIN32
    #define RECT trtc::RECT
    #define SIZE trtc::SIZE
#endif

class TestScreenShareSelectWindow:
        public BaseDialog,
        public TrtcCloudCallbackDefaultImpl
{
    Q_OBJECT
public:
    TestScreenShareSelectWindow(std::shared_ptr<TestUserVideoGroup> testUserVideoGroup, QWidget* parent = nullptr);
    ~TestScreenShareSelectWindow();

private:
    void stopScreenSharing();
    void startScreenSharing();

    void resumeScreenCapture();
    void pauseScreenCapture();
    void releaseScreenCaptureSourceList();

    void selectScreenCaptureTarget(trtc::TRTCScreenCaptureSourceInfo sourceInfo);

    void initScreenCaptureSources();
    void initScreenSharingWindowSelections();

public:
    void init(trtc::TRTCScreenCaptureProperty captureProperty
        , trtc::TRTCVideoEncParam params
        , RECT rect
        , trtc::TRTCVideoStreamType type);
    void updateScreenSharingParams(trtc::TRTCScreenCaptureProperty& captureProperty
        , trtc::TRTCVideoEncParam& params
        , RECT& rect
        , trtc::TRTCVideoStreamType type);

private:
    //============= ITRTCCloudCallback start ===============//
#ifdef _WIN32
    void onScreenCaptureCovered() override;
#endif
    void onScreenCaptureStarted() override;
    void onScreenCapturePaused(int reason) override;
    void onScreenCaptureResumed(int reason) override;
    void onScreenCaptureStoped(int reason) override;
    //============= ITRTCCloudCallback end =================//

    void addScreenSharingWindowItem(trtc::TRTCScreenCaptureSourceInfo screen_capture_source_info
        , int child_window_item_index);
    void closeEvent(QCloseEvent * closeEvent) override;
    void exitScreenSharing();
    void retranslateUi() override;
    void updateDynamicTextUI() override;
private slots:
    void on_btPauseScreenCapture_clicked();
    void on_btnStartScreenCapture_clicked();
    void onScreenSharingItemStatusChanged(ScreenShareSelectionItem* item, bool status);

private:
    std::unique_ptr<Ui::TestScreenShareSelectWindowDialog> ui_screen_share_select_window_;
    std::shared_ptr<TestUserVideoGroup> test_user_video_group_;
    trtc::TRTCVideoStreamType stream_type_;
    trtc::TRTCVideoEncParam enc_param_;
    RECT sharing_rect_;
    trtc::TRTCScreenCaptureProperty capture_property_;
    trtc::ITRTCScreenCaptureSourceList* screen_capture_list_ = nullptr;

    std::vector<ScreenShareSelectionItem*> all_sharing_items_;
    ScreenShareSelectionItem*  selected_sharing_source_item_ = nullptr;

    bool started_ = false;
    bool paused_ = false;

};

#endif // TESTSCREENSHARSELECTWINDOW_H
