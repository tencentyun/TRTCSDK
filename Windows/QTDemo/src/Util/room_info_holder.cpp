#include "room_info_holder.h"

RoomInfoHolder::RoomInfoHolder() {

}

RoomInfoHolder::~RoomInfoHolder() {
    room_users_.clear();
}

void RoomInfoHolder::addRemoteUser(std::string userId){
    room_users_.push_back(userId);
}
void RoomInfoHolder::removeRemoteUser(std::string userId){
    for (auto iter = room_users_.begin(); iter!= room_users_.end(); iter++) {
        if((*iter).compare(userId) == 0){
            room_users_.erase(iter);
            break;
        }
    }
}

void RoomInfoHolder::getRoomUsers(std::vector<std::string>& roomUsers){
    roomUsers.assign(room_users_.begin(),room_users_.end());
}

int RoomInfoHolder::getMainRoomId(){
    return main_room_id_;
}

void RoomInfoHolder::setMainRoomId(int mainRoomId){
    this->main_room_id_ = mainRoomId;
}

std::string RoomInfoHolder::getUserId(){
    return user_id_;
}

void RoomInfoHolder::setUserId(std::string userId){
    this->user_id_ = userId;
}

int RoomInfoHolder::getOtherRoomId()
{
    return this->other_room_id_;
}

void RoomInfoHolder::setOtherRoomId(int otherRooomID){
    this->other_room_id_ = otherRooomID;
}

void RoomInfoHolder::setOtherRoomUserId(std::string userId){
    this->other_room_userid_ = user_id_;
}

std::string RoomInfoHolder::getOtherRoomUserId(){
    return this->other_room_userid_;
}


int RoomInfoHolder::getSubRoomId(){
    return sub_room_id_;
}

void RoomInfoHolder::setSubRoomId(int subRooomID){
    this->sub_room_id_ = subRooomID;
}

std::string RoomInfoHolder::getCDNPushishStreamId(){
    return cdn_publish_stream_id_;
}

void RoomInfoHolder::setCDNPublishStreamId(std::string streamId){
    this->cdn_publish_stream_id_ = streamId;
}

std::string RoomInfoHolder::getMixTranscodingStreamId()
{
    return mix_transcoding_stream_id_;
}

void RoomInfoHolder::setMixTranscodingStreamId(std::string streamId)
{
    this->mix_transcoding_stream_id_ = streamId;
}

void RoomInfoHolder::resetData(){
    main_room_id_ = 0;
    other_room_id_ = 0;
    sub_room_id_ = 0;
    user_id_ = "";
    cdn_publish_stream_id_ = "";
    mix_transcoding_stream_id_ = "";
    other_room_userid_ = "";
    cdn_publish_stream_id_ = "";
    room_users_.clear();
}

RoomInfoHolder &RoomInfoHolder::GetInstance(){
    static RoomInfoHolder user_center;
    return user_center;
}
