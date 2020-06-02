/*
* Module:   TRTCRemoteUserListViewController
*
* Function: 房间内其它用户（即远端用户）的列表页
*
*    1. 列表中显示每个用户的ID，以及该用户的视频、音频开启状态
*
*    2. 点击用户项，将跳转到远端用户设置页
*
*/

#import "TRTCSettingsBaseViewController.h"
#import "TRTCRemoteUserManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCRemoteUserListViewController : TRTCSettingsBaseViewController

@property (strong, nonatomic) TRTCRemoteUserManager *userManager;

@end

NS_ASSUME_NONNULL_END
