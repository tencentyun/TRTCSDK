//
//  QRCode.m
//  TXLiteAVDemo
//
//  Created by shengcui on 2018/6/14.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "QRCode.h"

@implementation QRCode
+ (UIImage *)qrCodeWithString:(NSString *)string size:(CGSize)outputSize
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:data forKey: @"inputMessage"];
    [filter setValue:@"Q" forKey: @"inputCorrectionLevel"];
    CIImage *qrCodeImage = filter.outputImage;
    CGRect imageSize = CGRectIntegral(qrCodeImage.extent);
    CIImage *ciImage = [qrCodeImage imageByApplyingTransform:CGAffineTransformMakeScale(outputSize.width/CGRectGetWidth(imageSize), outputSize.height/CGRectGetHeight(imageSize))];
    return [UIImage imageWithCIImage:ciImage];
}
@end
