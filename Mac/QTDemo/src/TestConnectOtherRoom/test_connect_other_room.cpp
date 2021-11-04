#include "test_connect_other_room.h"
#include <QJsonObject>
#include <QJsonDocument>
#include <QMessageBox>
#include "defs.h"
#include "room_info_holder.h"

TestConnectOtherRoom::TestConnectOtherRoom() {
    getTRTCShareInstance()->addCallback(this);
}

TestConnectOtherRoom::~TestConnectOtherRoom() {
    getTRTCShareInstance()->removeCallback(this);
}

void TestConnectOtherRoom::connectOtherRoom(uint32_t roomId, std::string userId){
    QJsonObject json;
    json.insert("roomId", static_cast<int>(roomId));
    json.insert("userId", userId.c_str());

    QJsonDocument document;
    document.setObject(json);
    QByteArray byteArray = document.toJson(QJsonDocument::Compact);
    QString strJson(byteArray);

    std::string params = strJson.toStdString();
    getTRTCShareInstance()->connectOtherRoom(params.c_str());
}
void TestConnectOtherRoom::disconnectOtherRoom() {
    getTRTCShareInstance()->disconnectOtherRoom();
}


//============= ITRTCCloudCallback start ===============//
void TestConnectOtherRoom::onDisconnectOtherRoom(TXLiteAVError errCode, const char* errMsg) {
    RoomInfoHolder::GetInstance().setOtherRoomId(0);
    RoomInfoHolder::GetInstance().setOtherRoomUserId("");
    emit onExitOtherRoomConnection();
}

void TestConnectOtherRoom::onConnectOtherRoom(const char* userId, TXLiteAVError errCode, const char* errMsg) {
    bool success = true;
    if (errCode == ERR_NULL) {
        RoomInfoHolder::GetInstance().setOtherRoomId(std::atoi(room_id_.c_str()));
        RoomInfoHolder::GetInstance().setOtherRoomUserId(user_id_);
    }else {
        success = false;
        QMessageBox::warning(NULL, "Failed to start a cross-room call", QString("errCode = %1, errMsg = %2").arg(errCode).arg(errMsg),QMessageBox::Ok);
    }
    emit onConnectOtherRoomResult(success);
}
//============= ITRTCCloudCallback end =================//

