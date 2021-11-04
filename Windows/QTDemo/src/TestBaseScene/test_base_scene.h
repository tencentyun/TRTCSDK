/**
 * TRTC 基础功能，包括进房、退房以及切换角色、展示用户画面语音等功能
 *
 * - 目前支持4种场景：
 * - 视频通话(TRTCAppSceneVideoCall)、在线直播互动(TRTCAppSceneLIVE)、语音通话(TRTCAppSceneAudioCall)，语音聊天室(TRTCAppSceneVoiceChatRoom)
 * - 当 scene 选择为 TRTCAppSceneLIVE 或 TRTCAppSceneVoiceChatRoom 时，您必须通过 TRTCParams 中的 role 字段指定当前用户的角色。
 * -
 * - 进房: 调用参考enterRoom方法实现，更详细的api说明参见：https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__ITRTCCloud__cplusplus.html#ac73c4ad51eda05cd2bcec820c847e84f
 * - 退房: 调用参考exitRoom方法实现，注意不管进房是否成功，enterRoom 都必须与 exitRoom 配对使用，在调用 exitRoom 前再次调用 enterRoom 函数会导致不可预期的错误问题。
 * -
 * - 切换角色：switchRole，切换角色，仅适用于直播场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom）
 * - 角色有两种：
 * - 1. TRTCRoleAnchor 主播，可以上行视频和音频，一个房间里最多支持50个主播同时上行音视频。
 * - 2. TRTCRoleAudience 观众，只能观看，不能上行视频和音频，一个房间里的观众人数没有上限。
 *
 * - 进房、退房行为所关注的用户状态回调与展示，参见test_user_video_group.h的实现
 */

/**
 * Basic features, including room entry, room exit, role switching, and video/volume display
 *
 * - There are four scenarios:
 * - Video call (TRTCAppSceneVideoCall), interactive live streaming (TRTCAppSceneLIVE), audio call (TRTCAppSceneAudioCall), and audio chat room (TRTCAppSceneVoiceChatRoom)
 * - If the parameter "scene" is set to "TRTCAppSceneLIVE" or "TRTCAppSceneVoiceChatRoom", you must select a role for the current user by specifying the "role" field in TRTCParams.
 * -
 * - Room entry:  Call enterRoom to enter a room. For details, see: https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__ITRTCCloud__cplusplus.html#ac73c4ad51eda05cd2bcec820c847e84f
 * - Room exit:  Call exitRoom to exit a room. Please note that after you call enterRoom, regardless of whether room entry is successful, you must call exitRoom before calling enterRoom again; otherwise, an unexpected error will occur.
 * -
 * - Role switching:  Call switchRole to switch roles. This feature is applicable only in live streaming scenarios (TRTCAppSceneLIVE and TRTCAppSceneVoiceChatRoom).
 * - There are two roles:
 * - 1. Anchor (TRTCRoleAnchor), who can send video and audio. Up to 50 anchors are allowed to send audio and video at the same time in a room.
 * - 2. Audience (TRTCRoleAudience), who can play but cannot send audio or video. There is no upper limit on the audience size in a room.
 *
 * - For the callbacks and display relevant to room entry and exit, see test_user_video_group.h.
 */

#ifndef TESTBASESCENE_H
#define TESTBAEESCENC_H

#include <QObject>
#include "ITRTCCloud.h"
#include "ui_MainWindow.h"
#include "test_user_video_group.h"
#include "trtc_cloud_callback_default_impl.h"

class TestBaseScene :public QObject,public TrtcCloudCallbackDefaultImpl
{
    Q_OBJECT
public:
    explicit TestBaseScene(std::shared_ptr<TestUserVideoGroup> testUserVideoGroup);
    ~TestBaseScene();

    void enterRoom(uint32_t roomId, std::string userId, trtc::TRTCAppScene appScene, trtc::TRTCRoleType roleType = trtc::TRTCRoleType::TRTCRoleAnchor);
    void exitRoom();
    void switchRole(trtc::TRTCRoleType roleType);

    //============= ITRTCCloudCallback start =================//
    void onEnterRoom(int result);
    void onExitRoom(int reason);
    void onSwitchRole(TXLiteAVError errCode, const char *errMsg);
    //============= ITRTCCloudCallback end ===================//

private:
    std::shared_ptr<TestUserVideoGroup> test_user_video_group_;
    uint32_t room_id_;
    std::string user_id_;
    trtc::TRTCAppScene app_scene_;
    trtc::TRTCRoleType role_type_;
    std::string stream_id_;

};

#endif //TESTBASESCENE_H
