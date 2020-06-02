#import <UIKit/UIKit.h>
#import "SuperPlayer.h"
#import "SuperPlayerModel.h"
#import "SuperPlayerViewConfig.h"
#import "SPVideoFrameDescription.h"

@class SuperPlayerControlView;
@class SuperPlayerView;
@class TXImageSprite;
@protocol SuperPlayerDelegate <NSObject>
@optional
/// 返回事件
- (void)superPlayerBackAction:(SuperPlayerView *)player;
/// 全屏改变通知
- (void)superPlayerFullScreenChanged:(SuperPlayerView *)player;
/// 播放开始通知
- (void)superPlayerDidStart:(SuperPlayerView *)player;
/// 播放结束通知
- (void)superPlayerDidEnd:(SuperPlayerView *)player;
/// 播放错误通知
- (void)superPlayerError:(SuperPlayerView *)player errCode:(int)code errMessage:(NSString *)why;
// 需要通知到父view的事件在此添加
@end

/// 播放器的状态
typedef NS_ENUM(NSInteger, SuperPlayerState) {
    StateFailed,     // 播放失败
    StateBuffering,  // 缓冲中
    StatePlaying,    // 播放中
    StateStopped,    // 停止播放
    StatePause,      // 暂停播放
};


/// 播放器布局样式
typedef NS_ENUM(NSInteger, SuperPlayerLayoutStyle) {
    SuperPlayerLayoutStyleCompact, ///< 精简模式
    SuperPlayerLayoutStyleFullScreen ///< 全屏模式
};

@interface SuperPlayerView : UIView

/** 设置代理 */
@property (nonatomic, weak) id<SuperPlayerDelegate> delegate;

@property (nonatomic, assign) SuperPlayerLayoutStyle layoutStyle;

/// 设置播放器的父view。播放过程中调用可实现播放窗口转移
@property (nonatomic, weak) UIView *fatherView;

/// 播放器的状态
@property (nonatomic, assign) SuperPlayerState state;
/// 是否全屏
@property (nonatomic, assign, setter=setFullScreen:) BOOL isFullScreen;
/// 是否锁定旋转
@property (nonatomic, assign) BOOL isLockScreen;
/// 是否是直播流
@property (readonly) BOOL isLive;
/// 超级播放器控制层
@property (nonatomic) SuperPlayerControlView *controlView;
/// 是否允许竖屏手势
@property (nonatomic) BOOL disableGesture;
/// 是否在手势中
@property (readonly)  BOOL isDragging;
/// 是否加载成功
@property (readonly)  BOOL  isLoaded;
/// 设置封面图片
@property (nonatomic) UIImageView *coverImageView;
/// 重播按钮
@property (nonatomic, strong) UIButton *repeatBtn;
/// 全屏退出
@property (nonatomic, strong) UIButton *repeatBackBtn;
/// 是否自动播放（在playWithModel前设置)
@property BOOL autoPlay;
/// 视频总时长
@property (nonatomic) CGFloat playDuration;
/// 原始视频总时长，主要用于试看场景下显示总时长
@property (nonatomic) NSTimeInterval originalDuration;
/// 视频当前播放时间
@property (nonatomic) CGFloat playCurrentTime;
/// 起始播放时间，用于从上次位置开播
@property CGFloat startTime;
/// 播放的视频Model
@property (readonly) SuperPlayerModel       *playerModel;
/// 播放器配置
@property SuperPlayerViewConfig *playerConfig;
/// 循环播放
@property (nonatomic) BOOL loop;
/**
 * 视频雪碧图
 */
@property TXImageSprite *imageSprite;
/**
 * 打点信息
 */
@property NSArray<SPVideoFrameDescription *> *keyFrameDescList;
/**
 * 播放model
 */
- (void)playWithModel:(SuperPlayerModel *)playerModel;

/**
 * 重置player
 */
- (void)resetPlayer;

/**
 * 播放
 */
- (void)resume;

/**
 * 暂停
 * @warn isLoaded == NO 时暂停无效
 */
- (void)pause;

/**
 *  从xx秒开始播放视频跳转
 *
 *  @param dragedSeconds 视频跳转的秒数
 */
- (void)seekToTime:(NSInteger)dragedSeconds;

@end
