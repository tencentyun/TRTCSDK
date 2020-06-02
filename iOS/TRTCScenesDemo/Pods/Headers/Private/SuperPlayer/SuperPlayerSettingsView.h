//
//  SuperPlayerSettingsView.h
//  TXLiteAVDemo
//
//  Created by annidyfeng on 2018/7/4.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperPlayerViewConfig.h"

#define MoreViewWidth 330

@class SuperPlayerControlView;

@interface SuperPlayerSettingsView : UIView

@property (weak) SuperPlayerControlView *controlView;

@property UISlider *soundSlider;

@property UISlider *lightSlider;

/**
 * 是否显示播放速度和镜像
 *
 * 目前仅点播放支持修改播放速度与设置画面镜像
 */
@property (nonatomic) BOOL enableSpeedAndMirrorControl;

@property SuperPlayerViewConfig *playerConfig;
- (void)update;

@end
