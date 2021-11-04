#include "main_window.h"

#include <QMessageBox>
#include <QDebug>
#include <QTranslator>
#include <QLocale>

#include "base_dialog.h"
#include "translator.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui_mainwindow_(new Ui::MainWindow),
    test_user_video_group_(new TestUserVideoGroup),
    test_base_scene_(test_user_video_group_),
    test_subcloud_setting_(test_user_video_group_),
    test_custom_capture_(test_user_video_group_),
    test_screen_share_setting_(test_user_video_group_){

#ifdef _WIN32
    wndproc_setting::initAndSetWndProc(reinterpret_cast<HWND>(this->winId()));
#endif // _WIN32

    ui_mainwindow_->setupUi(this);
    getTRTCShareInstance()->addCallback(this);

    ui_mainwindow_->roomNumLineEdit->setValidator(new QRegularExpressionValidator(QRegularExpression("[0-9]+$"), ui_mainwindow_->roomNumLineEdit));
    ui_mainwindow_->lineetSubRoomId->setValidator(new QRegularExpressionValidator(QRegularExpression("[0-9]+$"), ui_mainwindow_->roomNumLineEdit));
    ui_mainwindow_->lineEtOtherRoomId->setValidator(new QRegularExpressionValidator(QRegularExpression("[0-9]+$"), ui_mainwindow_->roomNumLineEdit));
    ui_mainwindow_->trtcApiExample->setCurrentIndex(0);

    //init ui-relevant
    test_user_video_group_->setParent(ui_mainwindow_->videoListView);
    test_user_video_group_->hide();

    enter_room_based_widgets_.push_back(&test_cdn_publish_);
    enter_room_based_widgets_.push_back(&test_mixstream_publish_);
    enter_room_based_widgets_.push_back(&test_screen_share_setting_);
    enter_room_based_widgets_.push_back(&test_custom_capture_);
    enter_room_based_widgets_.push_back(&test_custom_render_);
    enter_room_based_widgets_.push_back(&test_bgm_setting_);
    enter_room_based_widgets_.push_back(&test_device_manager_);
    enter_room_based_widgets_.push_back(&test_beauty_watermark_);
    enter_room_based_widgets_.push_back(&test_audio_setting_);
    enter_room_based_widgets_.push_back(&test_video_setting_);
    enter_room_based_widgets_.push_back(&test_custom_message_);
    enter_room_based_widgets_.push_back(&test_audio_record_);

    module_widgets_.assign(enter_room_based_widgets_.begin(), enter_room_based_widgets_.end());
    module_widgets_.push_back(&test_cdn_player_);
    module_widgets_.push_back(&test_audio_detect_);
    module_widgets_.push_back(&test_video_detect_);
    module_widgets_.push_back(&test_network_check_);
    module_widgets_.push_back(&test_log_setting_);

    connect(&test_connect_other_room_, &TestConnectOtherRoom::onConnectOtherRoomResult, this, &MainWindow::onConnectOtherRoomResult);
    connect(&test_connect_other_room_, &TestConnectOtherRoom::onExitOtherRoomConnection, this, &MainWindow::onExitOtherRoomConnection);
    connect(&test_subcloud_setting_, &TestSubCloudSetting::onEnterSubRoom, this, &MainWindow::onEnterSubRoomResult);
    connect(&test_subcloud_setting_, &TestSubCloudSetting::onExitSubRoom, this, &MainWindow::onExitSubRoom);
    connect(test_user_video_group_.get(), &TestUserVideoGroup::onVolumeEvaluationStateChanged, &test_subcloud_setting_, &TestSubCloudSetting::volumeEvaluationStateChanged);

    Translator::getInstance()->initLanguage();
}

MainWindow::~MainWindow() {
    getTRTCShareInstance()->removeCallback(this);
}

//============= ITRTCCloudCallback start===================//

void MainWindow::onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo) {
    std::string msg("errCode:");
    msg.append(std::to_string(errCode)).append(" msg:").append(errMsg).append(" extraInfo:");

    qDebug() << "onError():" << "msg=" << msg.c_str();
}
void MainWindow::onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *extraInfo) {
    std::string msg("warningCode:");
    msg.append(std::to_string(warningCode)).append(" warningMsg:").append(warningMsg).append(" extraInfo:");

    qDebug() << "onWarning():" << "msg=" << msg.c_str();
}

void MainWindow::onEnterRoom(int result) {
    if (result > 0) {
        room_entered_ = true;
        updateModuleButtonStatus(true);
        updateModuleDialogStatus(true);
    }
}

void MainWindow::onExitRoom(int reason) {
    room_entered_ = false;
    updateModuleButtonStatus(false);
    updateModuleDialogStatus(false);
}
//============= ITRTCCloudCallback end===================//

void MainWindow::on_enterRoomButton_clicked() {
    trtc::TRTCAppScene app_scene = getCurrentSelectedAppScene();
    uint32_t room_id = ui_mainwindow_->roomNumLineEdit->text().toUInt();
    std::string user_id = ui_mainwindow_->userIdLineEdit->text().toStdString();
    if (app_scene == trtc::TRTCAppScene::TRTCAppSceneLIVE || app_scene == trtc::TRTCAppScene::TRTCAppSceneVoiceChatRoom) {
        int selelct_role_index = ui_mainwindow_->userRoleComB->currentIndex();
        if (selelct_role_index == -1){
            QMessageBox::warning(NULL, "Failed to enter the room", "You must select a role in live streaming scenarios.");
            return;
        }
        trtc::TRTCRoleType role_type = getCurrentSelectedRoleType();
        test_base_scene_.enterRoom(room_id, user_id, app_scene, role_type);
    } else {
        test_base_scene_.enterRoom(room_id, user_id, app_scene);
    }
}

void MainWindow::on_exitRoomButton_clicked() {
    test_subcloud_setting_.exitSubCloudRoom();
    test_connect_other_room_.disconnectOtherRoom();
    test_base_scene_.exitRoom();
}

void MainWindow::on_logSettingQbtn_clicked() {
    test_log_setting_.show();
    test_log_setting_.raise();
}

void MainWindow::on_cdnPublishBt_clicked() {
    test_cdn_publish_.show();
    test_cdn_publish_.raise();
}

void MainWindow::on_mixStreamPublish_clicked() {
    test_mixstream_publish_.show();
    test_mixstream_publish_.raise();
}

void MainWindow::closeEvent(QCloseEvent *event) {
    test_subcloud_setting_.exitSubCloudRoom();
    test_connect_other_room_.disconnectOtherRoom();
    test_base_scene_.exitRoom();
    for(auto module_widget : module_widgets_) {
        if(module_widget != nullptr) {
            module_widget->close();
        }
    }
}

void MainWindow::changeEvent(QEvent* event) {
    if (QEvent::LanguageChange == event->type()) {
        ui_mainwindow_->retranslateUi(this);
        updateDynamicTextUI();
    }
    QWidget::changeEvent(event);
}

void MainWindow::on_btnNetworkChecker_clicked() {
    test_network_check_.show();
    test_network_check_.raise();
}

void MainWindow::on_btScreenSharingSetting_clicked(){
    test_screen_share_setting_.show();
    test_screen_share_setting_.raise();
}

void MainWindow::on_btnCustomCapture_clicked(){
    test_custom_capture_.show();
    test_custom_capture_.raise();
}

void MainWindow::on_btnCustomRender_clicked(){
    test_custom_render_.show();
    test_custom_render_.raise();
}
void MainWindow::on_btnStartBGMSetting_clicked(){
    test_bgm_setting_.show();
    test_bgm_setting_.raise();
}

void MainWindow::on_btnEnterSubRoom_clicked(){
    if(subroom_entered_){
        test_subcloud_setting_.exitSubCloudRoom();
    }else{
    if (ui_mainwindow_->lineetSubRoomId->text().isEmpty()) {
            QMessageBox::warning(this, "Failed to enter the sub-room", "Enter a sub-room ID.", QMessageBox::Ok);
            return;
        }
        trtc::TRTCAppScene app_scene = getCurrentSelectedAppScene();
        uint32_t room_id = ui_mainwindow_->lineetSubRoomId->text().toUInt();
        std::string user_id = ui_mainwindow_->userIdLineEdit->text().toStdString();
        test_subcloud_setting_.enterSubCloudRoom(room_id, user_id, app_scene);
    }
}

void MainWindow::on_btnEnterOtherRoom_clicked() {
    if (cross_room_pk_entered_) {
        test_connect_other_room_.disconnectOtherRoom();
        return;
    }

    if (ui_mainwindow_->lineEtOtherRoomId->text().isEmpty()) {
        QMessageBox::warning(this, "Failed to start a cross-room call", "Enter a room ID.", QMessageBox::Ok);
        return;
    }

    if (ui_mainwindow_->lineEtOtherUserId->text().isEmpty()) {
        QMessageBox::warning(this, "Failed to start a cross-room call", "Enter a username.", QMessageBox::Ok);
        return;
    }

    uint32_t room_id = ui_mainwindow_->lineEtOtherRoomId->text().toUInt();
    std::string user_id = ui_mainwindow_->lineEtOtherUserId->text().toStdString();
    test_connect_other_room_.connectOtherRoom(room_id, user_id);
}


void MainWindow::on_userIdLineEdit_textChanged(const QString &userId) {
    bool enter_room_button_enabled = !room_entered_ && (!userId.isEmpty()) && (!ui_mainwindow_->roomNumLineEdit->text().isEmpty());
    ui_mainwindow_->enterRoomButton->setEnabled(enter_room_button_enabled);
}

void MainWindow::on_roomNumLineEdit_textChanged(const QString &roomNum) {
    bool enter_room_button_enabled = !room_entered_ && (!roomNum.isEmpty()) && (!ui_mainwindow_->userIdLineEdit->text().isEmpty());
    ui_mainwindow_->enterRoomButton->setEnabled(enter_room_button_enabled);
}

void MainWindow::on_appSceneComboBox_currentIndexChanged(int index) {
    switch (index)
    {
    case trtc::TRTCAppScene::TRTCAppSceneAudioCall:
    case trtc::TRTCAppScene::TRTCAppSceneVideoCall:
        ui_mainwindow_->userRoleComB->setEnabled(false);
        ui_mainwindow_->userRoleComB->setCurrentIndex(-1);
        break;
    case trtc::TRTCAppScene::TRTCAppSceneVoiceChatRoom:
    case trtc::TRTCAppScene::TRTCAppSceneLIVE:
        ui_mainwindow_->userRoleComB->setEnabled(true);
        break;
    default:
        break;
    }
}

void MainWindow::on_userRoleComB_currentIndexChanged(int index){
    if(room_entered_) {
        trtc::TRTCAppScene app_scene = getCurrentSelectedAppScene();

        // Only live streaming scenarios support role switching
        if (app_scene == trtc::TRTCAppScene::TRTCAppSceneLIVE || app_scene == trtc::TRTCAppScene::TRTCAppSceneVoiceChatRoom) {
            test_base_scene_.switchRole(getCurrentSelectedRoleType());
        }
    }
}

void MainWindow::on_languageComboBox_currentIndexChanged(int index) {
    changeLanguage(index);
}

void MainWindow::changeLanguage(int language) {
    Translator::getInstance()->changeLanguage(language);
}

void MainWindow::updateModuleButtonStatus(bool isEnteredRoom){
    ui_mainwindow_->enterRoomButton->setEnabled(!isEnteredRoom);
    ui_mainwindow_->exitRoomButton->setEnabled(isEnteredRoom);
    ui_mainwindow_->appSceneComboBox->setEnabled(!isEnteredRoom);
    ui_mainwindow_->roomNumLineEdit->setEnabled(!isEnteredRoom);
    ui_mainwindow_->userIdLineEdit->setEnabled(!isEnteredRoom);
    ui_mainwindow_->pushButtonDeviceManager->setEnabled(isEnteredRoom);
    ui_mainwindow_->pushButtonAudioSetting->setEnabled(isEnteredRoom);
    ui_mainwindow_->pushButtonVideoSetting->setEnabled(isEnteredRoom);
    ui_mainwindow_->cdnPublishBt->setEnabled(isEnteredRoom);
    ui_mainwindow_->mixStreamPublish->setEnabled(isEnteredRoom);
    ui_mainwindow_->btScreenSharingSetting->setEnabled(isEnteredRoom);
    ui_mainwindow_->btnEnterSubRoom->setEnabled(isEnteredRoom);
    ui_mainwindow_->btnEnterOtherRoom->setEnabled(isEnteredRoom);
    ui_mainwindow_->pushButtonAudioRecord->setEnabled(isEnteredRoom);
    ui_mainwindow_->btnStartBGMSetting->setEnabled(isEnteredRoom);
    ui_mainwindow_->pushButtonBeautyWaterMark->setEnabled(isEnteredRoom);
    ui_mainwindow_->btnCustomCapture->setEnabled(isEnteredRoom);
    ui_mainwindow_->btnCustomRender->setEnabled(isEnteredRoom);
    ui_mainwindow_->pushButtonCustomMessage->setEnabled(isEnteredRoom);
    updateDynamicTextUI();
}

void MainWindow::updateModuleDialogStatus(bool isEnteredRoom)
{
    if(!isEnteredRoom) {
        for(auto widget : enter_room_based_widgets_) {
            widget->resetUI();
            widget->close();
        }
    }
}

trtc::TRTCAppScene MainWindow::getCurrentSelectedAppScene()
{
    trtc::TRTCAppScene appScene = trtc::TRTCAppScene::TRTCAppSceneVideoCall;
    int current_index = ui_mainwindow_->appSceneComboBox->currentIndex();
    switch(current_index) {
    case 0:
        appScene = trtc::TRTCAppScene::TRTCAppSceneVideoCall;
        break;
    case 1:
        appScene = trtc::TRTCAppScene::TRTCAppSceneLIVE;
        break;
    case 2:
        appScene = trtc::TRTCAppScene::TRTCAppSceneAudioCall;
        break;
    case 3:
        appScene = trtc::TRTCAppScene::TRTCAppSceneVoiceChatRoom;
        break;
    default:
        break;
    }
    return appScene;
}

trtc::TRTCRoleType MainWindow::getCurrentSelectedRoleType()
{
    return ui_mainwindow_->userRoleComB->currentIndex() != 0? trtc::TRTCRoleType::TRTCRoleAudience : trtc::TRTCRoleType::TRTCRoleAnchor;
}

void MainWindow::on_pushButtonDeviceManager_clicked()
{
    test_device_manager_.show();
    test_device_manager_.raise();
}

void MainWindow::on_pushButtonAudioTest_clicked()
{
    test_audio_detect_.show();
    test_audio_detect_.raise();
}

void MainWindow::on_pushButtonVideoTest_clicked()
{
    test_video_detect_.show();
    test_video_detect_.raise();
}

void MainWindow::on_pushButtonBeautyWaterMark_clicked()
{
    test_beauty_watermark_.show();
    test_beauty_watermark_.raise();
}
void MainWindow::on_pushButtonAudioSetting_clicked()
{
    test_audio_setting_.show();
    test_audio_setting_.raise();
}

void MainWindow::on_pushButtonVideoSetting_clicked()
{
    test_video_setting_.show();
    test_video_setting_.raise();
}

void MainWindow::on_pushButtonCustomMessage_clicked()
{
    test_custom_message_.show();
    test_custom_message_.raise();
}

void MainWindow::on_pushButtonAudioRecord_clicked()
{
    test_audio_record_.show();
    test_audio_record_.raise();
}

void MainWindow::on_pushButtonCdnPlayer_clicked()
{
    test_cdn_player_.show();
    test_cdn_player_.raise();
}

void MainWindow::onConnectOtherRoomResult(bool result)
{
    cross_room_pk_entered_ = result;
    updateDynamicTextUI();
}

void MainWindow::onExitOtherRoomConnection()
{
    cross_room_pk_entered_ = false;
    updateDynamicTextUI();
}

void MainWindow::onEnterSubRoomResult(bool result)
{
    subroom_entered_ = result;
    updateDynamicTextUI();
}

void MainWindow::onExitSubRoom()
{
    subroom_entered_ = false;
    updateDynamicTextUI();
}

void MainWindow::updateDynamicTextUI() {
    if (subroom_entered_) {
        ui_mainwindow_->btnEnterSubRoom->setText(tr("退房", "dynamic"));
    } else {
        ui_mainwindow_->btnEnterSubRoom->setText(tr("进房", "dynamic"));
    }
    if (cross_room_pk_entered_) {
        ui_mainwindow_->btnEnterOtherRoom->setText(tr("退房", "dynamic"));
    } else {
        ui_mainwindow_->btnEnterOtherRoom->setText(tr("进房", "dynamic"));
    }
}
