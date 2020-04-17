/*
* Module:   TRTCPKSettingsViewController
*
* Function: 跨房PK页
*
*    1. 通过TRTCCloudManager来开启或关闭跨房连麦。
*
*/

#import <UIKit/UIKit.h>
#import "TRTCCloudManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCPKSettingsViewController : UIViewController

@property (strong, nonatomic) TRTCCloudManager *manager;

@end

NS_ASSUME_NONNULL_END
