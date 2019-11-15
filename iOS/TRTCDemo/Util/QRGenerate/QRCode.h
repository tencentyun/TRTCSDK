//
//  QRCode.h
//  TXLiteAVDemo
//
//  Created by shengcui on 2018/6/14.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCode : NSObject
+ (UIImage *)qrCodeWithString:(NSString *)string size:(CGSize)outputSize;
@end
