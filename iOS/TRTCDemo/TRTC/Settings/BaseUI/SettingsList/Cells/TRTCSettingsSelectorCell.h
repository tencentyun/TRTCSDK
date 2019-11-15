/*
* Module:   TRTCSettingsSelectorCell
*
* Function: 配置列表Cell，点击后弹出Alert Sheet，用于条目较多的选择
*
*/

#import "TRTCSettingsBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCSettingsSelectorCell : TRTCSettingsBaseCell

@end


@interface TRTCSettingsSelectorItem : TRTCSettingsBaseItem

@property (strong, nonatomic) NSArray<NSString *> *items;
@property (nonatomic) NSInteger selectedIndex;

@property (copy, nonatomic, readonly) void (^action)(NSInteger);

- (instancetype)initWithTitle:(NSString *)title
                        items:(NSArray<NSString *> *)items
                selectedIndex:(NSInteger)index
                       action:(void (^)(NSInteger))action;

@end

NS_ASSUME_NONNULL_END
