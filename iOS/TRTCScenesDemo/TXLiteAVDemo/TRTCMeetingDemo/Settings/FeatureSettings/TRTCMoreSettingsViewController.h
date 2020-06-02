/*
* Module:   TRTCMoreSettingsViewController
*
* Function: 其它设置页
*
*    1. 其它设置项包括: 流控方案、双路编码开关、默认观看低清、重力感应和闪光灯切换
*
*    2. 发送自定义消息和SEI消息，两种消息的说明可参见TRTC的文档或TRTCCloud.h中的接口注释。
*
*/

#import "TRTCSettingsBaseViewController.h"
#import "TRTCCloudManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCMoreSettingsViewController : TRTCSettingsBaseViewController

@property (strong, nonatomic) TRTCCloudManager *settingsManager;

@end

NS_ASSUME_NONNULL_END
