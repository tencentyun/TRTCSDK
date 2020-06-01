/*
* Module:   TRTCBgmSettingsViewController
*
* Function: BGM设置页，用于控制BGM的播放，以及设置混响和变声效果
*
*    1. 通过TRTCBgmManager来管理BGM播放，以及混响和变声的设置
*
*    2. BGM的操作定义在TRTCBgmSettingsCell中
*
*/

#import "TRTCSettingsBaseViewController.h"
#import "TRTCBgmManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCBgmSettingsViewController : TRTCSettingsBaseViewController

@property (strong, nonatomic) TRTCBgmManager *manager;

@end

NS_ASSUME_NONNULL_END
