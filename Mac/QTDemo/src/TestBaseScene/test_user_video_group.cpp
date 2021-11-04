#include "test_user_video_group.h"

#include <QRect>
#include <QGridLayout>
#include <QDebug>

#include "room_info_holder.h"

TestUserVideoGroup::TestUserVideoGroup(QWidget * parent) :QWidget(parent)
   ,ui_video_group_(new Ui::TestUserVideoGroup),
    user_screen_share_view_(new TestUserScreenShareView){
    ui_video_group_->setupUi(this);
    getTRTCShareInstance()->addCallback(this);
}

TestUserVideoGroup::~TestUserVideoGroup() {
    getTRTCShareInstance()->removeCallback(this);
    visible_user_video_items_.clear();
}

void TestUserVideoGroup::setNetworkQosParam(trtc::TRTCVideoQosPreference preference, trtc::TRTCQosControlMode controlMode) {
    trtc::TRTCNetworkQosParam param;
    param.controlMode = controlMode;
    param.preference = preference;
    getTRTCShareInstance()->setNetworkQosParam(param);
}

void TestUserVideoGroup::muteAllRemoteVideoStreams(bool mute){
    getTRTCShareInstance()->muteAllRemoteVideoStreams(mute);
}

void TestUserVideoGroup::muteAllRemoteAudio(bool mute){
    getTRTCShareInstance()->muteAllRemoteAudio(mute);
}

void TestUserVideoGroup::showDebugView(bool show){
    getTRTCShareInstance()->showDebugView(show);
}

//============= ITRTCCloudCallback start =================//
void TestUserVideoGroup::onRemoteUserEnterRoom(const char *userId){
    qDebug() << "RoomState: TestUserVideoGroup::onRemoteUserEnterRoom(userId:" << userId;
    if(RoomInfoHolder::GetInstance().getOtherRoomUserId().compare(userId) == 0){
         addUserVideoItem(getTRTCShareInstance(),RoomInfoHolder::GetInstance().getOtherRoomId(),userId,TEST_VIDEO_ITEM::RemoteView);
    }else{
         addUserVideoItem(getTRTCShareInstance(),main_room_id_,userId,TEST_VIDEO_ITEM::RemoteView);
    }

    RoomInfoHolder::GetInstance().addRemoteUser(userId);
}

void TestUserVideoGroup::onRemoteUserLeaveRoom(const char *userId, int reason) {
    qDebug() << "RoomState: TestUserVideoGroup::onRemoteUserLeaveRoom(userId:" << userId;
    RoomInfoHolder::GetInstance().removeRemoteUser(userId);
    if (visible_user_video_items_.size() == 0) {
        return;
    }

    // User in other room
    if(RoomInfoHolder::GetInstance().getOtherRoomUserId().compare(userId) == 0){
         removeUserVideoItem(RoomInfoHolder::GetInstance().getOtherRoomId(),userId);
    }else{
         removeUserVideoItem(main_room_id_,userId);
    }
}

void TestUserVideoGroup::onUserVideoAvailable(const char *userId, bool available)
{
    qDebug() << "RoomState: TestUserVideoGroup::onUserVideoAvailable(userId:" << userId << ",available:" << available;
    handleUserVideoAvailable(getTRTCShareInstance(), main_room_id_, userId, available);
}

void TestUserVideoGroup::onUserAudioAvailable(const char *userId, bool available)
{
    qDebug() << "RoomState: TestUserVideoGroup::onUserAudioAvailable(userId:" << userId << ",available:" << available;
    handleUserAudioAvailable(main_room_id_, userId, available);
}

void TestUserVideoGroup::onUserSubStreamAvailable(const char *userId, bool available)
{
    if (available) {
        current_screen_sharing_user_id_ = userId;
        getTRTCShareInstance()->startRemoteView(userId, trtc::TRTCVideoStreamTypeSub, (trtc::TXView)(user_screen_share_view_->winId()));
        user_screen_share_view_->setWindowTitle(QString("screen share from userId: %1").arg(userId));
        user_screen_share_view_->show();
        user_screen_share_view_->raise();
        ui_video_group_->pushButtonShowRemoteScreenShare->setEnabled(true);
    } else {
        getTRTCShareInstance()->stopRemoteView(userId, trtc::TRTCVideoStreamTypeSub);
        user_screen_share_view_->close();
        current_screen_sharing_user_id_ = "";
        ui_video_group_->pushButtonShowRemoteScreenShare->setEnabled(false);
    }
}

void TestUserVideoGroup::onUserVoiceVolume(trtc::TRTCVolumeInfo* userVolumes, uint32_t userVolumesCount, uint32_t totalVolume) {
    handleUserVolume(userVolumes, userVolumesCount, totalVolume);
}
//============= ITRTCCloudCallback end ==================//

trtc::TXView TestUserVideoGroup::getLocalVideoTxView() {
    if (visible_user_video_items_.size() > 0 && visible_user_video_items_[0]->getViewType() == TEST_VIDEO_ITEM::LocalView) {
        return reinterpret_cast<trtc::TXView>(visible_user_video_items_[0]->getVideoWId());
    }
    return NULL;
}

void TestUserVideoGroup::setMainRoomId(int mainRoomId)
{
    main_room_id_ = mainRoomId;
}

void TestUserVideoGroup::addUserVideoItem(trtc::ITRTCCloud* cloud,int roomId,const char *userId, const TEST_VIDEO_ITEM::ViewItemType type){
    std::vector<TestUserVideoItem*>::const_iterator iterator = visible_user_video_items_.begin();

    while (iterator != visible_user_video_items_.end()) {
        if (std::strcmp((*iterator)->getUserId().c_str(), userId) == 0) {
            return;
        }
        iterator++;
    }

    TestUserVideoItem* videoItem;

    videoItem = new TestUserVideoItem(ui_video_group_->mainVideoPlaceHolder,
                                            cloud,
                                            roomId,
                                            userId,
                                            type);
    int current_videos = visible_user_video_items_.size();
    int current_row = current_videos / TestUserVideoGroup::ROW_NUM;
    int current_colulum = current_videos % TestUserVideoGroup::ROW_NUM;
    QRect qrect = videoItem->geometry();
    QRect new_qrect(current_colulum * qrect.width(), current_row * qrect.height(), qrect.width(), qrect.height());
    videoItem->setParent(ui_video_group_->mainVideoPlaceHolder);
    videoItem->setGeometry(new_qrect);

    videoItem->show();
    videoItem->raise();
    ui_video_group_->mainVideoPlaceHolder->adjustSize();

    visible_user_video_items_.push_back(videoItem);
}

void TestUserVideoGroup::removeUserVideoItem(int roomId,const char * userId) {
    std::vector<TestUserVideoItem*>::iterator iter = visible_user_video_items_.begin();

    int position = 0;
    while (iter != visible_user_video_items_.end()) {
        if (std::strcmp(userId, (*iter)->getUserId().c_str()) == 0
                && roomId ==(*iter)->getRoomId()) {
            break;
        }
        position++;
        iter++;
    }

    if (iter == visible_user_video_items_.end()) {
        return;
    }
    (*iter)->close();
    (*iter)->deleteLater();
    visible_user_video_items_.erase(iter);

    iter = visible_user_video_items_.begin();
    iter += position;

    while (iter != visible_user_video_items_.end()) {
        QRect geometry = (*iter)->geometry();
        int current_left = geometry.left();
        int current_top = geometry.top();

        // row - 1
        if (current_left / geometry.width() == 0) {
            int row_num = current_top / geometry.height() - 1;
            int colum_num = 2;
            QRect new_rect(colum_num * geometry.width(), row_num * geometry.width(), geometry.width(), geometry.height());
            (*iter)->setGeometry(new_rect);
            iter++;
            continue;
        }

        int row_num = current_top / geometry.height();
        int colum_num = current_left / geometry.width() - 1;

        QRect new_rect(colum_num * geometry.width(), row_num * geometry.width(), geometry.width(), geometry.height());
        (*iter)->setGeometry(new_rect);
        iter++;
    }
}

void TestUserVideoGroup::removeAllUsers()
{
    for(std::vector<TestUserVideoItem*>::iterator iter = visible_user_video_items_.begin(); iter != visible_user_video_items_.end(); iter++) {
        (*iter)->close();
        (*iter)->deleteLater();
    }
    visible_user_video_items_.clear();
}

void TestUserVideoGroup::on_networkModeCb_currentIndexChanged(int index) {
    trtc::TRTCVideoQosPreference preference = trtc::TRTCVideoQosPreference::TRTCVideoQosPreferenceSmooth;
    switch (index) {
    case 0:
        preference = trtc::TRTCVideoQosPreference::TRTCVideoQosPreferenceClear;
        break;
    case 1:
        preference = trtc::TRTCVideoQosPreference::TRTCVideoQosPreferenceSmooth;
        break;
    }

    trtc::TRTCQosControlMode control_mode = trtc::TRTCQosControlMode::TRTCQosControlModeServer;
    setNetworkQosParam(preference, control_mode);
}

void TestUserVideoGroup::initView() {
    addUserVideoItem(getTRTCShareInstance(),main_room_id_,"myself", TEST_VIDEO_ITEM::LocalView);
    trtc::TRTCVideoQosPreference preference = trtc::TRTCVideoQosPreference::TRTCVideoQosPreferenceSmooth;
    int index = ui_video_group_->networkModeCb->currentIndex();
    switch (index) {
    case 0:
        preference = trtc::TRTCVideoQosPreference::TRTCVideoQosPreferenceClear;
        break;
    case 1:
        preference = trtc::TRTCVideoQosPreference::TRTCVideoQosPreferenceSmooth;
        break;
    }
    ui_video_group_->checkBoxVolumeEvaluation->setChecked(true);
    ui_video_group_->muteAllRemoteAudioCb->setChecked(false);
    ui_video_group_->muteAllRemoteVideoCb->setChecked(false);
    trtc::TRTCQosControlMode control_mode = trtc::TRTCQosControlMode::TRTCQosControlModeServer;
    setNetworkQosParam(preference, control_mode);
}

void TestUserVideoGroup::handleUserVideoAvailable(trtc::ITRTCCloud* cloud, int roomId, const char* userId, bool available)
{
    for(std::vector<TestUserVideoItem*>::const_iterator iterator = visible_user_video_items_.begin(); iterator != visible_user_video_items_.end(); iterator++) {
        if(std::strcmp(userId, (*iterator)->getUserId().c_str()) == 0 && roomId == (*iterator)->getRoomId()) {
            if(available && cloud != nullptr) {
                cloud->startRemoteView(userId, trtc::TRTCVideoStreamType::TRTCVideoStreamTypeBig, reinterpret_cast<trtc::TXView>((*iterator)->getVideoWId()));
            }
            bool mute_all_remote_video = ui_video_group_->muteAllRemoteVideoCb->isChecked();
            (*iterator)->updateAVAvailableStatus(available, mute_all_remote_video, TEST_VIDEO_ITEM::MuteVideo);
            break;
        }
    }
}

void TestUserVideoGroup::handleUserAudioAvailable(int roomId, const char *userId, bool available)
{
    for(std::vector<TestUserVideoItem*>::const_iterator iterator = visible_user_video_items_.begin(); iterator != visible_user_video_items_.end(); iterator++) {
        if(std::strcmp(userId, (*iterator)->getUserId().c_str()) == 0 && roomId == (*iterator)->getRoomId()) {
            bool mute_all_remote_audio = ui_video_group_->muteAllRemoteAudioCb->isChecked();
            (*iterator)->updateAVAvailableStatus(available, mute_all_remote_audio, TEST_VIDEO_ITEM::MuteAudio);
            break;
        }
    }
}

void TestUserVideoGroup::updateRemoteViewsMuteStatus(bool status, TEST_VIDEO_ITEM::MuteAllType muteType) {
    for (auto video_item : visible_user_video_items_) {
        if(video_item->getViewType() == TEST_VIDEO_ITEM::ViewItemType::RemoteView) {
            video_item->updateAVMuteStatus(status, muteType);
        }
    }
}

void TestUserVideoGroup::on_muteAllRemoteAudioCb_clicked(bool checked) {
    muteAllRemoteAudio(checked);
    updateRemoteViewsMuteStatus(checked, TEST_VIDEO_ITEM::MuteAudio);
}

void TestUserVideoGroup::on_muteAllRemoteVideoCb_clicked(bool checked) {
    muteAllRemoteVideoStreams(checked);
    updateRemoteViewsMuteStatus(checked, TEST_VIDEO_ITEM::MuteVideo);
}

void TestUserVideoGroup::on_openDashBoardCb_clicked(bool checked) {
    showDebugView(checked);
}

void TestUserVideoGroup::on_pushButtonShowRemoteScreenShare_clicked()
{
    if(!current_screen_sharing_user_id_.isEmpty() && !user_screen_share_view_->isVisible()) {
        std::string user_id = current_screen_sharing_user_id_.toStdString();
        user_screen_share_view_->stopUserScreenShare(user_id);
        getTRTCShareInstance()->startRemoteView(user_id.c_str(), trtc::TRTCVideoStreamTypeSub, (trtc::TXView)(user_screen_share_view_->winId()));
        user_screen_share_view_->show();
        user_screen_share_view_->raise();
    }
}

void TestUserVideoGroup::on_checkBoxVolumeEvaluation_stateChanged(int state)
{
    getTRTCShareInstance()->enableAudioVolumeEvaluation((state == Qt::CheckState::Checked)? 300:0);
    emit onVolumeEvaluationStateChanged(state == Qt::CheckState::Checked);
    if(state != Qt::CheckState::Checked) {
        for (auto video_item : visible_user_video_items_) {
            video_item->setVolume(0);
        }
    }
}

void TestUserVideoGroup::closeEvent(QCloseEvent* event)
{
    removeAllUsers();
    current_screen_sharing_user_id_ = "";
    user_screen_share_view_->close();
}

void TestUserVideoGroup::showEvent(QShowEvent* event)
{
    initView();
}

void TestUserVideoGroup::changeEvent(QEvent* event) {
    if (QEvent::LanguageChange == event->type()) {
        ui_video_group_->retranslateUi(this);
    }
    QWidget::changeEvent(event);
}

void TestUserVideoGroup::onSubRoomUserEnterRoom(trtc::ITRTCCloud* subCloud,int roomId, std::string userId){
    addUserVideoItem(subCloud,roomId,userId.c_str(),TEST_VIDEO_ITEM::RemoteView);
}

void TestUserVideoGroup::onSubRoomUserLeaveRoom(int roomId, std::string userId){
    removeUserVideoItem(roomId,userId.c_str());
}

void TestUserVideoGroup::onSubRoomUserVideoAvailable(trtc::ITRTCCloud* subCloud, int roomId, std::string userId, bool available)
{
    const char* user_id = userId.c_str();
    handleUserVideoAvailable(subCloud, roomId, user_id, available);
}

void TestUserVideoGroup::onSubRoomUserAudioAvailable(int roomId, std::string userId, bool available)
{
    const char* user_id = userId.c_str();
    handleUserAudioAvailable(roomId, user_id, available);
}

void TestUserVideoGroup::onSubRoomExit(int roomId){
    std::vector<TestUserVideoItem*>::iterator iter = visible_user_video_items_.begin();
    std::vector<std::string> subRoomUsers;

    while (iter != visible_user_video_items_.end()) {
        if (roomId ==(*iter)->getRoomId()) {
            subRoomUsers.push_back((*iter)->getUserId());
        }
        iter++;
    }

    if(visible_user_video_items_.size() == 0){
        return;
    }

    for(auto userItem : subRoomUsers){
        removeUserVideoItem(roomId, userItem.c_str());
    }
}

void TestUserVideoGroup::handleUserVolume(trtc::TRTCVolumeInfo* userVolumes, uint32_t userVolumesCount, uint32_t totalVolume) {
    for (auto video_item : visible_user_video_items_) {
        for (uint32_t user_volums_index = 0; user_volums_index < userVolumesCount; user_volums_index++) {
            auto user_volum_item = userVolumes + user_volums_index;

            // The userId for local volume (user_volum_item) is empty.
            if (video_item->getViewType() == TEST_VIDEO_ITEM::LocalView
                && strlen(user_volum_item->userId) == 0) {
                video_item->setVolume(user_volum_item->volume);
                break;
            }

            if (strcmp(user_volum_item->userId, video_item->getUserId().c_str()) != 0) {
                continue;
            }
            video_item->setVolume(user_volum_item->volume);
            break;
        }
    }
}