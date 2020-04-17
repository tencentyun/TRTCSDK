/*
* Module:   TRTCSettingsBaseCell, TRTCSettingsBaseItem
*
* Function: 基础框架类。TRTCSettingsBaseViewController的Cell基类
*
*    1. TRTCSettingsBaseItem用于存储cell中的数据，以及传导cell中的控件action
*
*    2. TRTCSettingsBaseCell定义了左侧的titleLabel，子类中可重载setupUI来添加其它控件
*
*/

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TRTCSettingsBaseItem;

@interface TRTCSettingsBaseCell : UITableViewCell

@property (strong, nonatomic) TRTCSettingsBaseItem *item;
@property (strong, nonatomic, readonly) UILabel *titleLabel;

#pragma mark - To be overriden

- (void)setupUI;

- (void)didUpdateItem:(TRTCSettingsBaseItem *)item;

- (void)didSelect;

@end


@interface TRTCSettingsBaseItem : NSObject

@property (strong, nonatomic) NSString *title;
@property (nonatomic, readonly) CGFloat height;

@property (class, nonatomic, readonly) NSString *bindedCellId;

#pragma mark - To be overriden
@property (class, nonatomic, readonly) Class bindedCellClass;
@property (nonatomic, readonly) NSString *bindedCellId;

@end

NS_ASSUME_NONNULL_END
