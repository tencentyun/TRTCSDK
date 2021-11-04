/**
 * TRTC 远端用户共享屏幕的展示窗口
 */

/**
 * Screen sharing view for remote users
 */

#ifndef TEST_USER_SCREEN_SHARE_VIEW_H
#define TEST_USER_SCREEN_SHARE_VIEW_H

#include "base_dialog.h"
#include "ITRTCCloud.h"
#include <ui_TestUserScreenShareViewDialog.h>

class TestUserScreenShareView : public BaseDialog
{
    Q_OBJECT

public:
    explicit TestUserScreenShareView(QWidget *parent = nullptr);
    ~TestUserScreenShareView();
    void stopUserScreenShare(std::string userId);
private:
    void retranslateUi() override;
private:
    std::unique_ptr<Ui::TestUserScreenShareViewDialog> ui_test_user_screen_share_view_;
};

#endif // TEST_USER_SCREEN_SHARE_VIEW_H
