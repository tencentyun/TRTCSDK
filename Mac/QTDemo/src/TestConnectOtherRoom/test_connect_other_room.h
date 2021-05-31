/**
 * TRTC 跨房通话（主播PK）
 *
 * TRTC 中两个不同音视频房间中的主播，可以通过“跨房通话”功能拉通连麦通话功能。使用此功能时， 两个主播无需退出各自原来的直播间即可进行“连麦 PK”。
 * - 例如：当房间“001”中的主播 A 通过 connectOtherRoom() 跟房间“002”中的主播 B 拉通跨房通话后， 房间“001”中的用户都会收到主播 B 的 onUserEnter(B) 回调和 onUserVideoAvailable(B,true) 回调。 房间“002”中的用户都会收到主播 A 的 onUserEnter(A) 回调和 onUserVideoAvailable(A,true) 回调。
 * - 调用方式参见connectOtherRoom()/disconnectOtherRoom()
 */

#ifndef TESTCONNECTOTHERROOM_H
#define TESTCONNECTOTHERROOM_H

#include <QDialog>
#include "trtc_cloud_callback_default_impl.h"
#include "ui_MainWindow.h"

class TestConnectOtherRoom: public QObject, public TrtcCloudCallbackDefaultImpl
{
    Q_OBJECT

public:
    TestConnectOtherRoom();
    ~TestConnectOtherRoom();

    void connectOtherRoom(uint32_t roomId, std::string userId);
    void disconnectOtherRoom();

    //============= ITRTCCloudCallback start ===============//
    void onDisconnectOtherRoom(TXLiteAVError errCode, const char* errMsg) override;
    void onConnectOtherRoom(const char* userId, TXLiteAVError errCode, const char* errMsg) override;
    //============= ITRTCCloudCallback end =================/

signals:
    void onConnectOtherRoomResult(bool success);
    void onExitOtherRoomConnection();
private:
    std::string room_id_;
    std::string user_id_;
};

#endif // TESTCONNECTOTHERROOM_H
