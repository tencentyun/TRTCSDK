/*
* Module:   TRTCVideoSettingsViewController
*
* Function: 视频设置页
*
*    1. 通过TRTCCloudManager来设置视频参数
*
*    2. 设置分辨率后，码率的设置范围以及默认值会根据分辨率进行调整
*
*/

#import "TRTCSettingsBaseViewController.h"
#import "TRTCCloudManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCVideoSettingsViewController : TRTCSettingsBaseViewController

@property (strong, nonatomic) TRTCCloudManager *settingsManager;

@end

NS_ASSUME_NONNULL_END
