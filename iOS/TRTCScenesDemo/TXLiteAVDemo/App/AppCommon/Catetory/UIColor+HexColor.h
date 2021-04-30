//
//  UIColor+HexColor.h
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/6.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (HexColor)
+ (UIColor *)hexColor:(NSString *)hexString;
@end

NS_ASSUME_NONNULL_END
