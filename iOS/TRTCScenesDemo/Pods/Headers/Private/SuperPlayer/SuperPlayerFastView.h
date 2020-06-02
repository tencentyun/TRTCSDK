//
//  SuperPlayerFastView.h
//  TXLiteAVDemo
//
//  Created by annidyfeng on 2018/8/24.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ImgWithProgress,    // 图片+进度，比如声音滑动
    TextWithProgress,   // 文字+进度，比如进度滑动
    ImgWithText,        // 图片+文字，比如缩略图滑动
    SnapshotImg,
} FastViewStyle;

@interface SuperPlayerFastView : UIView
/** 快进快退进度progress*/
@property (nonatomic, strong) UIProgressView          *progressView;
/** 快进快退时间*/
@property (nonatomic, strong) UILabel                 *textLabel;
/** 快进快退亮度图片*/
@property (nonatomic, strong) UIImageView             *imgView;

@property (nonatomic, strong) UIImageView             *thumbView;

@property (nonatomic, strong) UIImageView             *snapshotView;

@property CGFloat videoRatio;


@property (nonatomic) FastViewStyle style;

/// 亮度等
- (void)showImg:(UIImage *)img withProgress:(GLfloat)progress;
/// 快进
- (void)showThumbnail:(UIImage *)img withText:(NSString *)text;
- (void)showText:(NSString *)text withText:(GLfloat)progress;
/// 截图
- (void)showSnapshot:(UIImage *)img;

@end
