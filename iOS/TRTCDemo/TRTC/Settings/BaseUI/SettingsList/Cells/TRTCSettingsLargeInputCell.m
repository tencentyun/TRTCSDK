//
//  TRTCSettingsLargeInputCell.m
//  TXLiteAVDemo
//
//  Created by LiuXiaoya on 2019/12/5.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TRTCSettingsLargeInputCell.h"
#import "UITextField+TRTC.h"
#import "Masonry.h"

@implementation TRTCSettingsLargeInputCell

- (void)setupUI {
    [super setupUI];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 1)];
    self.contentText.leftView = paddingView;
    self.contentText.leftViewMode = UITextFieldViewModeAlways;
    self.contentText.borderStyle = UITextBorderStyleNone;

    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(18);
        make.top.equalTo(self.contentView);
        make.height.mas_equalTo(40);
    }];
    [self.contentText mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.height.mas_equalTo(40);
    }];
}

@end

#pragma mark - TRTCSettingsLargeInputItem

@implementation TRTCSettingsLargeInputItem

+ (Class)bindedCellClass {
    return [TRTCSettingsLargeInputCell class];
}

- (NSString *)bindedCellId {
    return [TRTCSettingsLargeInputItem bindedCellId];
}

- (CGFloat)height {
    return 40 + 40;
}

@end
