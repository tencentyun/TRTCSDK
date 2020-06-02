/*
* Module:   TRTCAudioSettingsViewController
*
* Function: 音频设置页
*
*    1. 通过TRTCCloudManager来设置音频参数。
*
*    2. TRTCAudioRecordManager用来控制录音，demo录音停止后会弹出分享。
*
*/

#import "TRTCSettingsBaseViewController.h"
#import "TRTCCloudManager.h"
#import "TRTCAudioRecordManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCAudioSettingsViewController : TRTCSettingsBaseViewController

@property (strong, nonatomic) TRTCCloudManager *settingsManager;
@property (strong, nonatomic) TRTCAudioRecordManager *recordManager;

@end

NS_ASSUME_NONNULL_END
