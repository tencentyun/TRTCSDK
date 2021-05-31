#include "test_user_screen_share_view.h"

TestUserScreenShareView::TestUserScreenShareView(QWidget *parent) :
    QDialog(parent),
    ui_test_user_screen_share_view_(new Ui::TestUserScreenShareViewDialog)
{
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    ui_test_user_screen_share_view_->setupUi(this);
}

TestUserScreenShareView::~TestUserScreenShareView()
{

}

void TestUserScreenShareView::stopUserScreenShare(std::string userId){
    getTRTCShareInstance()->stopRemoteView(userId.c_str(),trtc::TRTCVideoStreamTypeSub);
}
