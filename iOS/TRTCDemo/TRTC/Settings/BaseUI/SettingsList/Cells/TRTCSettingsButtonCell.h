/*
* Module:   TRTCSettingsButtonCell
*
* Function: 配置列表Cell，右侧是一个Button
*
*/

#import "TRTCSettingsBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCSettingsButtonCell : TRTCSettingsBaseCell

@end


@interface TRTCSettingsButtonItem : TRTCSettingsBaseItem

@property (copy, nonatomic, readonly) void (^action)();
@property (copy, nonatomic) NSString *buttonTitle;

- (instancetype)initWithTitle:(NSString *)title buttonTitle:(NSString *)buttonTitle action:(void (^)())action;

@end

NS_ASSUME_NONNULL_END
