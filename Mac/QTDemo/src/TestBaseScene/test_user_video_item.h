/**
 * TRTC 房间用户展示的子控件
 *
 * - 控制单个用户的音频、视频行为
 * -
 * - 静音：参见muteAudio实现，控制本地静音和远端用户静音
 * - 静画：参加muteVideo实现，控制本地静画和远端用户静画
 * - 设置图像渲染参数：参见setRenderParams，设置本地图像和远端图像的渲染参数，包含旋转，镜像，填充模式
 * - 设置显示远端画面的类型：支持主画面(TRTCVideoStreamTypeBig),小画面(TRTCVideoStreamTypeSmall),辅流(屏幕分享 TRTCVideoStreamTypeSub)
 */

/**
 * Sub-control for user display
 *
 * - Managing the audio/video status of a single user
 * -
 * - Muting/Unmuting local and remote users:  muteAudio
 * - Stopping/Starting video for local and remote users:  muteVideo
 * - Setting rendering parameters for local and remote videos, including rotation, mirror, and the fill mode:  setRenderParams
 * - Setting the type of remote image to display:  Three image types are supported: big image (TRTCVideoStreamTypeBig), small image (TRTCVideoStreamTypeSmall), and substream image (screen sharing, TRTCVideoStreamTypeSub)
 */

#ifndef USERVIDEOITEM_H
#define USERVIDEOITEM_H

#include <QWidget>
#include "trtc_cloud_callback_default_impl.h"

#include "ui_TestUserVideoItem.h"

namespace TEST_VIDEO_ITEM {
    // Image type
    enum ViewItemType
    {
        LocalView,
        RemoteView,
        ScreenSharingView
    };
    // Media to disable
    enum MuteAllType{
        MuteAudio,
        MuteVideo
    };
} // namespace TEST_VIDEO_ITEM

class TestUserVideoItem:public QWidget,public TrtcCloudCallbackDefaultImpl{
    Q_OBJECT

public:
    TestUserVideoItem(QWidget *parent = nullptr,
                      trtc::ITRTCCloud* cloud = nullptr,
                      int roomid = 0,
                      std::string userid = nullptr,
                      TEST_VIDEO_ITEM::ViewItemType type = TEST_VIDEO_ITEM::ViewItemType::RemoteView);
    ~TestUserVideoItem();
private:
    void muteAudio(bool mute);
    void muteVideo(bool mute);
    void setRenderParams();
    void setRemoteVideoStreamType();
    virtual void updateDynamicTextUI();
private slots:
    void on_audioMuteBt_clicked();
    void on_videoMuteBt_clicked();
    void on_fitScreenBt_clicked();
    void on_preSmallVideoBt_clicked();
    void on_mirrorBt_clicked();
    void on_roateBt_clicked();

public:
    void updateAVMuteView(TEST_VIDEO_ITEM::MuteAllType muteType);
    void setVolume(int volume);
    WId getVideoWId();
    std::string& getUserId();
    int getRoomId();
    bool getAudioMuteStatus();
    bool getVideoMuteStatus();
    TEST_VIDEO_ITEM::ViewItemType getViewType();
    void updateAVMuteStatus(bool mute, TEST_VIDEO_ITEM::MuteAllType muteType);
    void updateAVAvailableStatus(bool available, bool mute_all_remote, TEST_VIDEO_ITEM::MuteAllType muteType);
    void initViews();
    void changeEvent(QEvent* event);
private:
    std::unique_ptr<Ui::TestUserVideoItem> ui_video_item_;
    trtc::ITRTCCloud* trtccloud_;
    int room_id_;
    std::string user_id_;
    TEST_VIDEO_ITEM::ViewItemType viewtype_;

    bool audio_available_ = false;
    bool video_available_ = false;
    bool audio_mute_ = false;
    bool video_mute_ = false;

    trtc::TRTCVideoRotation rotation_ = trtc::TRTCVideoRotation0;
    trtc::TRTCVideoFillMode fill_mode_ = trtc::TRTCVideoFillMode_Fit;
    trtc::TRTCVideoMirrorType mirror_type_ = trtc::TRTCVideoMirrorType_Disable;
    trtc::TRTCVideoStreamType video_stream_type_ = trtc::TRTCVideoStreamType::TRTCVideoStreamTypeBig;
};

#endif // USERVIDEOITEM_H


