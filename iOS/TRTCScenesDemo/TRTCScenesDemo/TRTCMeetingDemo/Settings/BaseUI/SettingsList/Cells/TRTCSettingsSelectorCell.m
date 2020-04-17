/*
* Module:   TRTCSettingsSelectorCell
*
* Function: 配置列表Cell，点击后弹出Alert Sheet，用于条目较多的选择
*
*/

#import "TRTCSettingsSelectorCell.h"
#import "Masonry.h"
#import "ColorMacro.h"
#import "UILabel+TRTC.h"
#import "UIView+Additions.h"

@interface TRTCSettingsSelectorCell ()

@property (strong, nonatomic) UILabel *itemLabel;

@end

@implementation TRTCSettingsSelectorCell

- (void)setupUI {
    [super setupUI];
    
    self.itemLabel = [UILabel trtc_contentLabel];
    [self.contentView addSubview:self.itemLabel];
    
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
    [self.contentView addSubview:arrowView];

    [self.itemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(arrowView).offset(-20);
    }];
    [arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-18);
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelect)];
    [self.contentView addGestureRecognizer:tapGesture];
}

- (void)didUpdateItem:(TRTCSettingsBaseItem *)item {
    if ([item isKindOfClass:[TRTCSettingsSelectorItem class]]) {
        TRTCSettingsSelectorItem *selectorItem = (TRTCSettingsSelectorItem *)item;
        if (selectorItem.selectedIndex < selectorItem.items.count) {
            self.itemLabel.text = selectorItem.items[selectorItem.selectedIndex];
        }
    }
}

- (void)didSelect {
    TRTCSettingsSelectorItem *selectorItem = (TRTCSettingsSelectorItem *)self.item;

    void (^actionHandler)(UIAlertAction * _Nonnull action) = ^(UIAlertAction * _Nonnull action) {
        self.itemLabel.text = action.title;
        [self onSelectItem:action.title];
    };
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:selectorItem.title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *item in selectorItem.items) {
        [alert addAction:[UIAlertAction actionWithTitle:item style:UIAlertActionStyleDefault handler:actionHandler]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self.tx_viewController presentViewController:alert animated:YES completion:nil];
}

- (void)onSelectItem:(NSString *)item {
    TRTCSettingsSelectorItem *selectorItem = (TRTCSettingsSelectorItem *)self.item;
    NSInteger index = [selectorItem.items indexOfObject:item];
    if (index != NSNotFound) {
        selectorItem.selectedIndex = index;
        selectorItem.action(index);
    }
}

@end


@implementation TRTCSettingsSelectorItem

- (instancetype)initWithTitle:(NSString *)title
                        items:(NSArray<NSString *> *)items
                selectedIndex:(NSInteger)index
                       action:(void (^)(NSInteger))action {
    if (self = [super init]) {
        self.title = title;
        _items = items;
        _selectedIndex = index;
        _action = action;
    }
    return self;
}

+ (Class)bindedCellClass {
    return [TRTCSettingsSelectorCell class];
}

- (NSString *)bindedCellId {
    return [TRTCSettingsSelectorItem bindedCellId];
}

@end

