/*
* Module:   TRTCEffectSettingsViewController
*
* Function: 音效设置页，包含一个全部音效的列表，以及音效的全局设置项
*
*    1. Demo的音效列表定义在TRTCCustomAudioEffectManager中
*
*    2. 音效Cell为TRTCSettingsEffectCell，
*       音效的循环次数设置在TRTCSettingsEffectLoopCountCell中
*
*/


#import "TRTCSettingsBaseViewController.h"
#import "TRTCCustomAudioEffectManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCEffectSettingsViewController : TRTCSettingsBaseViewController

@property (strong, nonatomic) TRTCCustomAudioEffectManager *manager;

@end

NS_ASSUME_NONNULL_END
