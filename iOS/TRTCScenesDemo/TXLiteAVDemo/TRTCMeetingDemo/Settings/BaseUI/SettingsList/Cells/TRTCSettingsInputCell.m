//
//  TRTCSettingsInputCell.m
//  TXLiteAVDemo
//
//  Created by LiuXiaoya on 2019/12/5.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TRTCSettingsInputCell.h"

#import "UITextField+TRTC.h"
#import "Masonry.h"

@interface TRTCSettingsInputCell ()<UITextFieldDelegate>

@property (strong, nonatomic) UITextField *contentText;

@end

@implementation TRTCSettingsInputCell

- (void)setupUI {
    [super setupUI];
    
    self.contentText = [UITextField trtc_textFieldWithDelegate:self];
    
    [self.contentView addSubview:self.contentText];
    [self.contentText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-18);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onTextChange)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.contentText];
}

- (void)didUpdateItem:(TRTCSettingsBaseItem *)item {
    if ([item isKindOfClass:[TRTCSettingsInputItem class]]) {
        TRTCSettingsInputItem *inputItem = (TRTCSettingsInputItem *)item;
        self.contentText.text = inputItem.content;
        self.contentText.attributedPlaceholder = [UITextField trtc_textFieldPlaceHolderFor:inputItem.placeHolder];
    }
}

- (void)onTextChange {
    TRTCSettingsInputItem *inputItem = (TRTCSettingsInputItem *)self.item;
    inputItem.content = self.contentText.text;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end

#pragma mark - TRTCSettingsInputItem

@implementation TRTCSettingsInputItem

- (instancetype)initWithTitle:(NSString *)title
                  placeHolder:(NSString *)placeHolder
                      content:(NSString * _Nullable)content {
    if (self = [super init]) {
        self.title = title;
        self.placeHolder = placeHolder;
        self.content = content;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title placeHolder:(NSString *)placeHolder {
    return [self initWithTitle:title placeHolder:placeHolder content:nil];
}

+ (Class)bindedCellClass {
    return [TRTCSettingsInputCell class];
}

- (NSString *)bindedCellId {
    return [TRTCSettingsInputItem bindedCellId];
}

@end
