#ifndef ROOM_INFO_HOLDER_H
#define ROOM_INFO_HOLDER_H

#include <QtGlobal>
#include <string>
#include <vector>

class RoomInfoHolder {
private:
    RoomInfoHolder();
    ~RoomInfoHolder();
    RoomInfoHolder(const RoomInfoHolder&) = delete;
    RoomInfoHolder& operator=(const RoomInfoHolder&) = delete;

public:
    static RoomInfoHolder& GetInstance();
    void addRemoteUser(std::string userId);
    void removeRemoteUser(std::string userId);
    void getRoomUsers(std::vector<std::string>& roomUsers);
    int getMainRoomId();
    void setMainRoomId(int mainRoomId);

    std::string getUserId();
    void setUserId(std::string userId);

    int getOtherRoomId();
    void setOtherRoomId(int otherRooomID);

    void setOtherRoomUserId(std::string userId);
    std::string getOtherRoomUserId();

    int getSubRoomId();
    void setSubRoomId(int subRooomID);

    std::string getCDNPushishStreamId();
    void setCDNPublishStreamId(std::string streamId);

    std::string getMixTranscodingStreamId();
    void setMixTranscodingStreamId(std::string streamId);

    void resetData();

private:
    static RoomInfoHolder* instance;
    std::vector<std::string> room_users_;
    int main_room_id_;

    // Cross-room call
    int other_room_id_;
    std::string other_room_userid_;

    int sub_room_id_;

    std::string user_id_;
    std::string cdn_publish_stream_id_;
    std::string mix_transcoding_stream_id_;
};
#endif //ROOM_INFO_HOLDER_H

