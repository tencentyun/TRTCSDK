/*
* Module:   TRTCSettingsSegmentCell
*
* Function: 配置列表Cell，右侧是SegmentedControl
*
*/

#import "TRTCSettingsBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCSettingsSegmentCell : TRTCSettingsBaseCell

@end


@interface TRTCSettingsSegmentItem : TRTCSettingsBaseItem

@property (strong, nonatomic) NSArray<NSString *> *items;
@property (nonatomic) NSInteger selectedIndex;
@property (copy, nonatomic, readonly, nullable) void (^action)(NSInteger);

- (instancetype)initWithTitle:(NSString *)title
                        items:(NSArray<NSString *> *)items
                selectedIndex:(NSInteger)index
                       action:(void(^ _Nullable)(NSInteger index))action;

@end

NS_ASSUME_NONNULL_END
