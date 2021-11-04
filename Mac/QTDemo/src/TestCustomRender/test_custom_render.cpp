#include "test_custom_render.h"
#include "room_info_holder.h"
TestCustomRender::TestCustomRender(QWidget *parent)
    :BaseDialog(parent)
    , ui_test_custom_render_(new Ui::TestCustomRenderDialog) {
    ui_test_custom_render_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    connect(this,&TestCustomRender::renderViewSize,this,&TestCustomRender::adapterRenderViewSize);
    initViews();
}
TestCustomRender::~TestCustomRender() {
    destroyCustomRender();
    this->disconnect();
}

void TestCustomRender::startLocalVideoRender(){
    getTRTCShareInstance()->startLocalPreview(nullptr);
    getTRTCShareInstance()->setLocalVideoRenderCallback(
                trtc::TRTCVideoPixelFormat_I420
                ,trtc::TRTCVideoBufferType_Buffer
                ,this);
}
void TestCustomRender::startRemoteVideoRender(std::string& userId){
    getTRTCShareInstance()->setRemoteVideoRenderCallback(
                userId.c_str()
                ,trtc::TRTCVideoPixelFormat_I420
                ,trtc::TRTCVideoBufferType_Buffer
                ,this);
}

void TestCustomRender::stopLocalVideoRender(){
    getTRTCShareInstance()->setLocalVideoRenderCallback(
                trtc::TRTCVideoPixelFormat_Unknown
                ,trtc::TRTCVideoBufferType_Unknown
                ,nullptr);

}
void TestCustomRender::stopRemoteVideoRender(std::string& userId){
    getTRTCShareInstance()->setRemoteVideoRenderCallback(
                userId.c_str()
                ,trtc::TRTCVideoPixelFormat_Unknown
                ,trtc::TRTCVideoBufferType_Unknown
                ,nullptr);
}

//============= ITRTCVideoRenderCallback start ===================//
void TestCustomRender::onRenderVideoFrame(const char *userId, trtc::TRTCVideoStreamType streamType, trtc::TRTCVideoFrame *frame){
    if(gl_yuv_widget_ == nullptr){
        return;
    }

    if(streamType == trtc::TRTCVideoStreamType::TRTCVideoStreamTypeBig){
        emit renderViewSize(frame->width,frame->height);
        gl_yuv_widget_->slotShowYuv(reinterpret_cast<uchar*>(frame->data),frame->width,frame->height);
    }
}
//=============  ITRTCVideoRenderCallback end  ===================//

void TestCustomRender::closeEvent(QCloseEvent* event){
    stopRender();
    BaseDialog::closeEvent(event);
}

void TestCustomRender::showEvent(QShowEvent* event){
    refrshUsers();
    BaseDialog::showEvent(event);
}

void TestCustomRender::on_btnStartCustomRender_clicked(){
    if(started_custom_render){
        stopRender();
        view_resized_ = false;
    }else{
        current_render_user_id = ui_test_custom_render_->combUserList->currentText().toStdString();
        startRender();
    }
}

void TestCustomRender::refrshUsers()
{
    std::vector<std::string> room_users;
    RoomInfoHolder::GetInstance().getRoomUsers(room_users);
    room_users.insert(room_users.begin(),"myself");
    ui_test_custom_render_->combUserList->clear();
    for (auto user : room_users) {
        ui_test_custom_render_->combUserList->addItem(QString::fromLocal8Bit(user.c_str()));
    }
}

void TestCustomRender::initViews()
{
    refrshUsers();
    gl_yuv_widget_ = new GLYuvWidget(ui_test_custom_render_->customRenderVideoPreview);
    gl_yuv_widget_->setHidden(true);
}

void TestCustomRender::adapterRenderViewSize(int width,int height){
    if(view_resized_){
        return;
    }

    if(gl_yuv_widget_ == nullptr){
        return;
    }
    int gl_yuv_width_ = width;
    int gl_yuv_height_ = height;

    int preview_view_width = ui_test_custom_render_->customRenderVideoPreview->width();
    int preview_view_height = ui_test_custom_render_->customRenderVideoPreview->height();
    if(width > preview_view_width){
        gl_yuv_height_ = preview_view_width * gl_yuv_height_ / gl_yuv_width_;
        gl_yuv_width_ = preview_view_width;
    }

    if(height >preview_view_height){
        gl_yuv_width_ = gl_yuv_width_ * preview_view_height / gl_yuv_height_;
        gl_yuv_height_ = preview_view_height;
    }

    gl_yuv_widget_->resize(gl_yuv_width_,gl_yuv_height_);
    view_resized_ = true;

}
void TestCustomRender::startRender()
{
    if(started_custom_render){
        return;
    }

    if(current_render_user_id.compare("myself") == 0){
        startLocalVideoRender();
    }else{
        startRemoteVideoRender(current_render_user_id);
    }
    gl_yuv_widget_->setHidden(false);
    started_custom_render = true;
    updateDynamicTextUI();
}

void TestCustomRender::stopRender()
{
    if(started_custom_render){
        if (current_render_user_id.compare("myself") == 0) {
            stopLocalVideoRender();
        } else {
            stopRemoteVideoRender(current_render_user_id);
        }
        gl_yuv_widget_->setHidden(true);
        started_custom_render = false;
        updateDynamicTextUI();
    }
}

void TestCustomRender::destroyCustomRender()
{
    if (started_custom_render) {
        stopRender();
    }
    if (gl_yuv_widget_ != nullptr) {
        delete gl_yuv_widget_;
        gl_yuv_widget_ = nullptr;
    }
}

void TestCustomRender::updateDynamicTextUI() {
    if (started_custom_render) {
        ui_test_custom_render_->btnStartCustomRender->setText(tr("结束自定义视频渲染"));
    } else {
        ui_test_custom_render_->btnStartCustomRender->setText(tr("开始自定义视频渲染"));
    }
}

void TestCustomRender::retranslateUi() {
    ui_test_custom_render_->retranslateUi(this);
}