//
//  TRTCSettingsInputCell.h
//  TXLiteAVDemo
//
//  Created by LiuXiaoya on 2019/12/5.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TRTCSettingsBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCSettingsInputCell : TRTCSettingsBaseCell

@property (strong, nonatomic, readonly) UITextField *contentText;

@end


@interface TRTCSettingsInputItem : TRTCSettingsBaseItem

@property (copy, nonatomic) NSString *placeHolder;
@property (copy, nonatomic) NSString *content;

- (instancetype)initWithTitle:(NSString *)title
                  placeHolder:(NSString *)placeHolder
                      content:(NSString * _Nullable)content NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithTitle:(NSString *)title placeHolder:(NSString *)placeHolder;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
