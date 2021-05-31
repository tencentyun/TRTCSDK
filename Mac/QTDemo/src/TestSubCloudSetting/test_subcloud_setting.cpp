#include "test_subcloud_setting.h"
#include <QMessageBox>
#include <QObject>
#include <QDebug>
#include "GenerateTestUserSig.h"
#include "defs.h"

TestSubCloudSetting::TestSubCloudSetting(std::shared_ptr<TestUserVideoGroup> testUserVideoGroup) :
    test_user_video_group_(testUserVideoGroup) {
}

TestSubCloudSetting::~TestSubCloudSetting(){
    exitSubCloudRoom();
}

void TestSubCloudSetting::enterSubCloudRoom(uint32_t roomId, std::string userId, trtc::TRTCAppScene appScene) {
    sub_cloud_ = getTRTCShareInstance()->createSubCloud();

    trtc::TRTCParams params;
    params.role = trtc::TRTCRoleAudience;
    room_id_ = roomId;
    params.roomId = room_id_;
    params.sdkAppId = SDKAppID;
    params.userId = userId.c_str();
    /** @note: 请不要将如下代码发布到您的线上正式版本的 App 中，原因如下：
     * 本文件中的代码虽然能够正确计算出 UserSig，但仅适合快速调通 SDK 的基本功能，不适合线上产品，
     * 这是因为客户端代码中的 SECRETKEY 很容易被反编译逆向破解，尤其是 Web 端的代码被破解的难度几乎为零。
     * 一旦您的密钥泄露，攻击者就可以计算出正确的 UserSig 来盗用您的腾讯云流量。
     * 正确的做法是将 UserSig 的计算代码和加密密钥放在您的业务服务器上，然后由 App 按需向您的服务器获取实时算出的 UserSig。
     * 由于破解服务器的成本要高于破解客户端 App，所以服务器计算的方案能够更好地保护您的加密密钥。
     * 文档：https://cloud.tencent.com/document/product/269/32688#Server
     */
    params.userSig = GenerateTestUserSig::genTestUserSig(params.userId, SDKAppID, SECRETKEY);

    sub_cloud_->addCallback(this);
    sub_cloud_->enterRoom(params, appScene);
}

void TestSubCloudSetting::exitSubCloudRoom() {
    if (sub_cloud_ != nullptr) {
        sub_cloud_->exitRoom();
    }
}

//============= ITRTCCloudCallback start ===============//
void TestSubCloudSetting::onEnterRoom(int result){
    if(result > 0) {
        QMessageBox::about(NULL, "TIPS", QString("Enter Sub Room Successfully!").arg(result));
        emit onEnterSubRoom(true);
    } else {
        QMessageBox::warning(NULL, "TIPS", QString("Enter Sub Room Failed! errCode=%1").arg(result),QMessageBox::Ok);
    }
}

void TestSubCloudSetting::onExitRoom(int reason){
    test_user_video_group_->onSubRoomExit(room_id_);
    room_id_ = 0;
    user_id_ = "";
//    sub_cloud_->removeCallback(this);
    getTRTCShareInstance()->destroySubCloud(sub_cloud_);
    sub_cloud_ = nullptr;
    emit onExitSubRoom();
}

void TestSubCloudSetting::onUserVideoAvailable(const char *userId, bool available)
{
    qDebug() << "RoomState: TestSubCloudSetting onUserVideoAvailable(userId:" << userId << ",available:" << available;
    test_user_video_group_->onSubRoomUserVideoAvailable(sub_cloud_, room_id_, userId, available);
}

void TestSubCloudSetting::onUserAudioAvailable(const char *userId, bool available)
{
    qDebug() << "RoomState: TestSubCloudSetting onUserAudioAvailable(userId:" << userId << ",available:" << available;
    test_user_video_group_->onSubRoomUserAudioAvailable(room_id_, userId, available);
}

void TestSubCloudSetting::onRemoteUserEnterRoom(const char *userId){
    qDebug() << "RoomState: TestSubCloudSetting onRemoteUserEnterRoom(userId:" << userId;
    test_user_video_group_->onSubRoomUserEnterRoom(sub_cloud_, room_id_, userId);
}

void TestSubCloudSetting::onRemoteUserLeaveRoom(const char *userId, int reason){
    qDebug() << "RoomState: TestSubCloudSetting onRemoteUserLeaveRoom(userId:" << userId;
    test_user_video_group_->onSubRoomUserLeaveRoom(room_id_, userId);
}

//============= ITRTCCloudCallback end =================//
