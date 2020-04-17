/*
* Module:   TRTCSettingsContainerViewController
*
* Function: 基础框架类。包含多个子ViewController，标题栏为segmentControl，对应各页面的title
*
*/

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TRTCSettingsContainerViewController : UIViewController

@property (strong, nonatomic) NSArray<UIViewController *> *settingVCs;

@end

NS_ASSUME_NONNULL_END
