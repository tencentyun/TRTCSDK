/*
* Module:   TRTCSettingsBaseViewController
*
* Function: 基础框架类。用作包含各种配置项的列表页
*
*    1. 列表的各种配置Cell定义在Cells目录中，也可继承
*
*    2. 通过继承TRTCSettingsBaseCell，可自定义Cell，需要在TRTCSettingsBaseViewController
*       子类中重载makeCustomRegistrition，并调用registerClass将Cell注册到tableView中。
*
*/

#import <UIKit/UIKit.h>
#import "TRTCSettingsBaseCell.h"
#import "TRTCSettingsSwitchCell.h"
#import "TRTCSettingsSegmentCell.h"
#import "TRTCSettingsMessageCell.h"
#import "TRTCSettingsButtonCell.h"
#import "TRTCSettingsSliderCell.h"
#import "TRTCSettingsSelectorCell.h"
#import "TRTCSettingsInputCell.h"
#import "TRTCSettingsLargeInputCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCSettingsBaseViewController : UIViewController

@property (strong, nonatomic) NSArray<TRTCSettingsBaseItem *> *items;
@property (strong, nonatomic, readonly) UITableView *tableView;

#pragma mark - To be overriden

- (void)makeCustomRegistrition;

- (void)onSelectItem:(TRTCSettingsBaseItem *)item;

@end

NS_ASSUME_NONNULL_END
