//
//  UIColor+Hex.h
//  TRTCSimpleDemo-OC
//
//  Created by adams on 2021/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Hex)

+ (UIColor *)hexColor:(NSString *)hexString;

+ (UIColor *)themeGreenColor;

+ (UIColor *)themeGrayColor;

- (UIImage *)trans2Image:(CGSize)imageSize;

@end

NS_ASSUME_NONNULL_END
