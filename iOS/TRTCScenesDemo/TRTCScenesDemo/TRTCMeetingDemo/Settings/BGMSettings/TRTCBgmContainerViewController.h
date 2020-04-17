/*
* Module:   TRTCBgmContainerViewController
*
* Function: BGM设置弹出页，包含两个子页面：BGM和音效
*
*/

#import "TRTCSettingsContainerViewController.h"
#import "TRTCBgmManager.h"
#import "TRTCAudioEffectManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCBgmContainerViewController : TRTCSettingsContainerViewController

@property (strong, nonatomic) TRTCBgmManager *bgmManager;
@property (strong, nonatomic) TRTCAudioEffectManager *effectManager;

@end

NS_ASSUME_NONNULL_END
