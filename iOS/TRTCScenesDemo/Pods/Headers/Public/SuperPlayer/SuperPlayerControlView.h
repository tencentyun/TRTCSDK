//
//  SuperPlayerControlView.h
//  TXLiteAVDemo
//
//  Created by annidyfeng on 2018/6/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "SuperPlayerControlViewDelegate.h"
#import "PlayerSlider.h"
#import "SuperPlayerFastView.h"
#import "MMMaterialDesignSpinner.h"
#import "SuperPlayerSettingsView.h"
#import "SuperPlayerViewConfig.h"
#import "SPVideoFrameDescription.h"

@interface SuperPlayerControlView : UIView
@property (assign, nonatomic) BOOL compact;
/**
 * 点播放试看时间范围 0.0 - 1.0
 *
 * 用于试看场景，防止进度条拖动超过试看时长
 */
@property (assign, nonatomic) float maxPlayableRatio;
/**
 * 播放进度
 * @param currentTime 当前播放时长
 * @param totalTime   视频总时长
 * @param progress    value(0.0~1.0)
 * @param playable    value(0.0~1.0)
 */
- (void)setProgressTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime
          progressValue:(CGFloat)progress playableValue:(CGFloat)playable;

/**
 * 播放状态
 * @param isPlay YES播放，NO暂停
 */
- (void)setPlayState:(BOOL)isPlay;

/**
 * 重置播放控制面板
 * @param resolutionNames 清晰度名称
 * @param resolutionIndex 正在播放的清晰度的下标
 * @param isLive 是否为直播流，直播是有时移按钮，不支持镜像与播放速度修改
 * @param isTimeShifting 是否在直播时移
 * @param isPlaying 是否正在播放中，用于调整播放按钮状态
 */
- (void)resetWithResolutionNames:(NSArray<NSString *> *)resolutionNames
          currentResolutionIndex:(NSUInteger)resolutionIndex
                          isLive:(BOOL)isLive
                  isTimeShifting:(BOOL)isTimeShifting
                       isPlaying:(BOOL)isPlaying;

/// 标题
@property NSString *title;
/// 打点信息
@property NSArray<SPVideoFrameDescription *>  *pointArray;
/// 是否在拖动进度
@property BOOL  isDragging;
/// 是否显示二级菜单
@property BOOL  isShowSecondView;
/// 回调delegate
@property (nonatomic, weak) id<SuperPlayerControlViewDelegate> delegate;
/// 播放配置
@property SuperPlayerViewConfig *playerConfig;

- (void)setOrientationPortraitConstraint;
- (void)setOrientationLandscapeConstraint;

@end
