/*
* Module:   TRTCRemoteUserSettingsViewController
*
* Function: 房间内其它用户（即远端用户）的设置页
*
*    1. 通过TRTCRemoteUserManager来管理各项设置
*
*/

#import "TRTCSettingsBaseViewController.h"
#import "TRTCRemoteUserManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCRemoteUserSettingsViewController : TRTCSettingsBaseViewController

@property (strong, nonatomic) TRTCRemoteUserManager *userManager;
@property (strong, nonatomic) NSString *userId;

@end

NS_ASSUME_NONNULL_END
