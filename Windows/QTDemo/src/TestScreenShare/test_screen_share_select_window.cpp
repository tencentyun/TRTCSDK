#include "test_screen_share_select_window.h"
#include <QMessageBox>
#include <QDebug>
TestScreenShareSelectWindow::TestScreenShareSelectWindow(
    std::shared_ptr<TestUserVideoGroup> testUserVideoGroup, QWidget* parent)
    : BaseDialog(parent)
    , ui_screen_share_select_window_(new Ui::TestScreenShareSelectWindowDialog)
    , test_user_video_group_(testUserVideoGroup)
{
    ui_screen_share_select_window_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    getTRTCShareInstance()->addCallback(this);
}

TestScreenShareSelectWindow::~TestScreenShareSelectWindow() {
    exitScreenSharing();
    getTRTCShareInstance()->removeCallback(this);
}

void TestScreenShareSelectWindow::initScreenSharingWindowSelections() {
    initScreenCaptureSources();
    if (screen_capture_list_ == nullptr){
        return;
    }

    int screen_capture_size = screen_capture_list_->getCount();
    trtc::TRTCScreenCaptureSourceInfo screen_capture_source_info;
    int child_window_item_index = 0;
    for (int screen_index = 0; screen_index < screen_capture_size; screen_index++) {
        screen_capture_source_info = screen_capture_list_->getSourceInfo(screen_index);
        if(screen_capture_source_info.type != trtc::TRTCScreenCaptureSourceTypeWindow){
            continue;
        }

        addScreenSharingWindowItem(screen_capture_source_info, child_window_item_index);
        child_window_item_index++;
    }
    ui_screen_share_select_window_->scrrenSharingWindows->adjustSize();
}

void TestScreenShareSelectWindow::stopScreenSharing(){
    getTRTCShareInstance()->stopScreenCapture();
    if(test_user_video_group_){
        getTRTCShareInstance()->startLocalPreview(test_user_video_group_->getLocalVideoTxView());
    }
}

void TestScreenShareSelectWindow::startScreenSharing(){
    getTRTCShareInstance()->startScreenCapture(reinterpret_cast<trtc::TXView>(ui_screen_share_select_window_->screenSharedPreview->winId()),
        stream_type_,
        &enc_param_);
}

void TestScreenShareSelectWindow::resumeScreenCapture(){
    getTRTCShareInstance()->resumeScreenCapture();
}

void TestScreenShareSelectWindow::pauseScreenCapture(){
    getTRTCShareInstance()->pauseScreenCapture();
}

void TestScreenShareSelectWindow::releaseScreenCaptureSourceList(){
    if (screen_capture_list_ != nullptr) {
        screen_capture_list_->release();
        screen_capture_list_ = nullptr;
    }
}

void TestScreenShareSelectWindow::selectScreenCaptureTarget(trtc::TRTCScreenCaptureSourceInfo sourceInfo){
    getTRTCShareInstance()->selectScreenCaptureTarget(
        sourceInfo
        , sharing_rect_
        , capture_property_);
}

void TestScreenShareSelectWindow::initScreenCaptureSources(){
    SIZE thumb_size;
#ifdef __APPLE__
    thumb_size.width = 300;
    thumb_size.height = 300;
#else
    thumb_size.cx = 300;
    thumb_size.cy = 300;
#endif
    SIZE icon_size = thumb_size;
    screen_capture_list_ = getTRTCShareInstance()->getScreenCaptureSources(thumb_size, icon_size);
}

//============= ITRTCCloudCallback start ===============//
#ifdef _WIN32
void TestScreenShareSelectWindow::onScreenCaptureCovered() {
    // QMessageBox::warning(this,"Warning","The window to be shared is covered, please move the window.",QMessageBox::Ok);
}
#endif
void TestScreenShareSelectWindow::onScreenCaptureStarted() {
    started_ = true;
    paused_ = false;
    ui_screen_share_select_window_->btPauseScreenCapture->setEnabled(true);
    ui_screen_share_select_window_->btnStartScreenCapture->setEnabled(true);
    updateDynamicTextUI();
}
void TestScreenShareSelectWindow::onScreenCapturePaused(int reason) {
    paused_ = true;
    ui_screen_share_select_window_->btPauseScreenCapture->setEnabled(true);
    updateDynamicTextUI();
}
void TestScreenShareSelectWindow::onScreenCaptureResumed(int reason) {
    paused_ = false;
    ui_screen_share_select_window_->btPauseScreenCapture->setEnabled(true);
    updateDynamicTextUI();
}
void TestScreenShareSelectWindow::onScreenCaptureStoped(int reason) {
    started_ = false;
    paused_ = false;
    ui_screen_share_select_window_->btPauseScreenCapture->setEnabled(false);
    ui_screen_share_select_window_->btnStartScreenCapture->setEnabled(true);
    updateDynamicTextUI();
}
//============= ITRTCCloudCallback end =================//

void TestScreenShareSelectWindow::closeEvent(QCloseEvent * closeEvent){
    exitScreenSharing();
    for (auto sharing_item : all_sharing_items_) {
        sharing_item->close();
        delete sharing_item;
    }
    all_sharing_items_.clear();
    BaseDialog::closeEvent(closeEvent);
}

void TestScreenShareSelectWindow::addScreenSharingWindowItem(trtc::TRTCScreenCaptureSourceInfo screen_capture_source_info, int child_window_item_index) {
    ScreenShareSelectionItem* test_screensharing_item = new ScreenShareSelectionItem(screen_capture_source_info
        , ui_screen_share_select_window_->scrrenSharingWindows);

    if(child_window_item_index == 0) {
        test_screensharing_item->setSelected(true);
        selected_sharing_source_item_ = test_screensharing_item;
    }

    connect(test_screensharing_item
        , &ScreenShareSelectionItem::onCheckStatusChanged
        , this
        , &TestScreenShareSelectWindow::onScreenSharingItemStatusChanged);
    test_screensharing_item->setGeometry((child_window_item_index % 4) * test_screensharing_item->width()
        , (child_window_item_index / 4) * test_screensharing_item->height()
        , test_screensharing_item->width()
        , test_screensharing_item->height());
    test_screensharing_item->show();
    test_screensharing_item->raise();

    all_sharing_items_.push_back(test_screensharing_item);
}

void TestScreenShareSelectWindow::init(trtc::TRTCScreenCaptureProperty captureProperty
    , trtc::TRTCVideoEncParam params
    , RECT rect
    , trtc::TRTCVideoStreamType type) {
    sharing_rect_ = rect;
    enc_param_ = params;
    capture_property_ = captureProperty;
    stream_type_ = type;
    initScreenSharingWindowSelections();
}

void TestScreenShareSelectWindow::updateScreenSharingParams(
    trtc::TRTCScreenCaptureProperty& captureProperty
    , trtc::TRTCVideoEncParam& params
    , RECT& rect
    , trtc::TRTCVideoStreamType type) {
    sharing_rect_ = rect;
    enc_param_ = params;
    capture_property_ = captureProperty;
    if(!started_){
        stream_type_ = type;
        return;
    }
    stopScreenSharing();
    selectScreenCaptureTarget(selected_sharing_source_item_->getScreenCaptureSourceinfo());
    startScreenSharing();
}

void TestScreenShareSelectWindow::onScreenSharingItemStatusChanged(ScreenShareSelectionItem* item, bool status) {
    if(!started_){
        if(selected_sharing_source_item_ != nullptr && selected_sharing_source_item_ != item && status){
            selected_sharing_source_item_->setSelected(false);
        }
        if(status){
            selected_sharing_source_item_ = item;
        }
        return;
    }

    if(item == selected_sharing_source_item_){
        selected_sharing_source_item_->setSelected(true);
        return;
    }else{
        if(selected_sharing_source_item_ != nullptr){
            selected_sharing_source_item_->setSelected(false);
        }
        selectScreenCaptureTarget(item->getScreenCaptureSourceinfo());
        selected_sharing_source_item_ = item;
    }
}

void TestScreenShareSelectWindow::exitScreenSharing() {
    if (started_) {
        stopScreenSharing();
    }
    releaseScreenCaptureSourceList();
}

void TestScreenShareSelectWindow::on_btPauseScreenCapture_clicked() {
    if (!started_) {
        return;
    }

    if (paused_) {
        resumeScreenCapture();
    } else {
        pauseScreenCapture();
    }
}

void TestScreenShareSelectWindow::on_btnStartScreenCapture_clicked() {
    if (started_) {
        stopScreenSharing();
    }else {
        if (selected_sharing_source_item_ == nullptr) {
            QMessageBox::warning(this, "Failed to share the screen", "Select a window to share.");
            return;
        }

        selectScreenCaptureTarget(
            selected_sharing_source_item_->getScreenCaptureSourceinfo());
        startScreenSharing();
    }
}

void TestScreenShareSelectWindow::updateDynamicTextUI() {
    if (started_) {
        ui_screen_share_select_window_->btnStartScreenCapture->setText(tr("结束分享").toUtf8());
    } else {
        ui_screen_share_select_window_->btnStartScreenCapture->setText(tr("开始分享").toUtf8());
    }
    if (paused_) {
        ui_screen_share_select_window_->btPauseScreenCapture->setText(tr("恢复分享").toUtf8());
    } else {
        ui_screen_share_select_window_->btPauseScreenCapture->setText(tr("暂停分享").toUtf8());
    }
}

void TestScreenShareSelectWindow::retranslateUi() {
    ui_screen_share_select_window_->retranslateUi(this);
}