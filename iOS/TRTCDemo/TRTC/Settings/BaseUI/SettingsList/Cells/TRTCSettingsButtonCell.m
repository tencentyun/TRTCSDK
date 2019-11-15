/*
* Module:   TRTCSettingsButtonCell
*
* Function: 配置列表Cell，右侧是一个Button
*
*/

#import "TRTCSettingsButtonCell.h"
#import "UIButton+TRTC.h"
#import "Masonry.h"

@interface TRTCSettingsButtonCell ()

@property (strong, nonatomic) UIButton *button;

@end

@implementation TRTCSettingsButtonCell

- (void)setupUI {
    [super setupUI];
    
    self.button = [UIButton trtc_cellButtonWithTitle:@"发送"];
    [self.button addTarget:self action:@selector(onClickSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-18);
    }];
}

- (void)didUpdateItem:(TRTCSettingsBaseItem *)item {
    if ([item isKindOfClass:[TRTCSettingsButtonItem class]]) {
        TRTCSettingsButtonItem *buttonItem = (TRTCSettingsButtonItem *)item;
        [self.button setTitle:buttonItem.buttonTitle forState:UIControlStateNormal];
    }
}

- (void)onClickSendButton:(id)sender {
    TRTCSettingsButtonItem *buttonItem = (TRTCSettingsButtonItem *)self.item;
    buttonItem.action();
}

@end


@implementation TRTCSettingsButtonItem

- (instancetype)initWithTitle:(NSString *)title buttonTitle:(NSString *)buttonTitle action:(void (^)())action {
    if (self = [super init]) {
        self.title = title;
        _buttonTitle = buttonTitle;
        _action = action;
    }
    return self;
}

+ (Class)bindedCellClass {
    return [TRTCSettingsButtonCell class];
}

- (NSString *)bindedCellId {
    return [TRTCSettingsButtonItem bindedCellId];
}

@end

