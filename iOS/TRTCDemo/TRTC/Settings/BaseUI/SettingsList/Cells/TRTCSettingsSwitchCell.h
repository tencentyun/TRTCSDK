/*
* Module:   TRTCSettingsSwitchCell
*
* Function: 配置列表Cell，右侧是一个Switcher
*
*/

#import "TRTCSettingsBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCSettingsSwitchCell : TRTCSettingsBaseCell

@end


@interface TRTCSettingsSwitchItem : TRTCSettingsBaseItem

@property (nonatomic) BOOL isOn;
@property (copy, nonatomic, readonly, nullable) void (^action)(BOOL);

- (instancetype)initWithTitle:(NSString *)title isOn:(BOOL)isOn action:(void (^ _Nullable)(BOOL))action;

@end

NS_ASSUME_NONNULL_END
