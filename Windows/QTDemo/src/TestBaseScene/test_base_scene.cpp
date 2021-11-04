#include "test_base_scene.h"

#include <QMessageBox>
#include <QObject>
#include <sstream>

#include "defs.h"
#include "GenerateTestUserSig.h"

#include "room_info_holder.h"

TestBaseScene::TestBaseScene(std::shared_ptr<TestUserVideoGroup> testUserVideoGroup)
    : test_user_video_group_(testUserVideoGroup){
    getTRTCShareInstance()->addCallback(this);
}

TestBaseScene::~TestBaseScene() {
    getTRTCShareInstance()->removeCallback(this);
}

void TestBaseScene::enterRoom(uint32_t roomId, std::string userId, trtc::TRTCAppScene appScene, trtc::TRTCRoleType roleType) {

    room_id_ = roomId;
    user_id_ = userId;
    app_scene_ = appScene;
    role_type_ = roleType;

    // Stream ID for CDN live streaming, which is optional and cannot be longer than 64 bytes. 
    // To avoid application conflicts, we recommend that you set it to "sdkappid_roomid_userid_main".
    std::ostringstream streamid_os;
    streamid_os << SDKAppID << "_" << room_id_ << "_" << user_id_ << "_" << "main";
    stream_id_ = streamid_os.str();

    trtc::TRTCParams params;
    params.sdkAppId = SDKAppID;
    params.userId = user_id_.c_str();
    /** @note: 请不要将如下代码发布到您的线上正式版本的 App 中，原因如下：
     * 本文件中的代码虽然能够正确计算出 UserSig，但仅适合快速调通 SDK 的基本功能，不适合线上产品，
     * 这是因为客户端代码中的 SECRETKEY 很容易被反编译逆向破解，尤其是 Web 端的代码被破解的难度几乎为零。
     * 一旦您的密钥泄露，攻击者就可以计算出正确的 UserSig 来盗用您的腾讯云流量。
     * 正确的做法是将 UserSig 的计算代码和加密密钥放在您的业务服务器上，然后由 App 按需向您的服务器获取实时算出的 UserSig。
     * 由于破解服务器的成本要高于破解客户端 App，所以服务器计算的方案能够更好地保护您的加密密钥。
     * 文档：https://cloud.tencent.com/document/product/647/17275#Server
     */

    /** @note:  Do not use the code below in your commercial application. This is because:
     * The code may be able to calculate UserSig correctly, but it is only for quick testing of the SDK’s basic features, not for commercial applications.
     * SECRETKEY in client code can be easily decompiled and reversed, especially on web.
     * Once your key is disclosed, attackers will be able to steal your Tencent Cloud traffic.
     * The correct method is to deploy the UserSig calculation code and encryption key on your project server so that your application can request from your server a UserSig that is calculated whenever one is needed.
     * Given that it is more difficult to hack a server than a client application, server-end calculation can better protect your key.
     * Documentation:  https://intl.cloud.tencent.com/document/product/647/35166#Server
     */
    params.userSig = GenerateTestUserSig::genTestUserSig(params.userId, SDKAppID, SECRETKEY);
    params.role = role_type_;
    params.roomId = room_id_;
    params.streamId = stream_id_.c_str();

    getTRTCShareInstance()->enterRoom(params, appScene);
}

void TestBaseScene::exitRoom() {
    getTRTCShareInstance()->exitRoom();
}

void TestBaseScene::switchRole(trtc::TRTCRoleType roleType){
    getTRTCShareInstance()->switchRole(roleType);
}

//============= ITRTCCloudCallback start===================//

void TestBaseScene::onEnterRoom(int result) {
    if (result > 0) {
        test_user_video_group_->setMainRoomId(room_id_);
        test_user_video_group_->show();

        // Enable audio
        getTRTCShareInstance()->enableAudioVolumeEvaluation(300); // Effective before the calling of startLocalAudio
        getTRTCShareInstance()->startLocalAudio(trtc::TRTCAudioQualityDefault);

        // Enable video
        if(app_scene_ == trtc::TRTCAppScene::TRTCAppSceneVideoCall || app_scene_ == trtc::TRTCAppScene::TRTCAppSceneLIVE){
            getTRTCShareInstance()->setBeautyStyle(trtc::TRTCBeautyStyleSmooth, 6, 6, 6);
            getTRTCShareInstance()->startLocalPreview(test_user_video_group_->getLocalVideoTxView());
        }

        RoomInfoHolder::GetInstance().setMainRoomId(room_id_);
        RoomInfoHolder::GetInstance().setUserId(user_id_);
        RoomInfoHolder::GetInstance().setCDNPublishStreamId(stream_id_);
        RoomInfoHolder::GetInstance().setMixTranscodingStreamId(stream_id_);
    } else {
        getTRTCShareInstance()->exitRoom();
    }
}

void TestBaseScene::onExitRoom(int reason) {
    test_user_video_group_->close();
    RoomInfoHolder::GetInstance().resetData();
}

void TestBaseScene::onSwitchRole(TXLiteAVError errCode, const char * errMsg){
    if (errCode == TXLiteAVError::ERR_NULL){
        QMessageBox::about(NULL, "Successfully", "Role changed successfully.");
    }else{
        QMessageBox::warning(NULL, "Failed to change the role",errMsg);
    }
}
//============= ITRTCCloudCallback end===================//

