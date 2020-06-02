//
//  SuperPlayerView+Private.h
//  TXLiteAVDemo
//
//  Created by annidyfeng on 2018/7/9.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#ifndef SuperPlayerView_Private_h
#define SuperPlayerView_Private_h
#import "SuperPlayer.h"

#import "SuperPlayerControlViewDelegate.h"
#import "NetWatcher.h"
#import <MediaPlayer/MediaPlayer.h>

#import "Masonry/Masonry.h"
#import "AFNetworking/AFNetworking.h"
//#import "SPResolutionDefination.h"
#import "SPSubStreamInfo.h"
#import <AVFoundation/AVFoundation.h>

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, // 横向移动
    PanDirectionVerticalMoved    // 纵向移动
};

typedef NS_ENUM(NSInteger, ButtonAction) {
    ActionNone,
    ActionRetry,
    ActionSwitch,
    ActionIgnore,
    ActionContinueReplay,
};

@class TXVodPlayer, TXLivePlayer;
@interface SuperPlayerView () <UIGestureRecognizerDelegate,UIAlertViewDelegate,
 SuperPlayerControlViewDelegate, AVAssetResourceLoaderDelegate>


/** 用来保存快进的总时长 */
@property (nonatomic, assign) CGFloat                sumTime;
@property (nonatomic, assign) CGFloat                startVeloctyPoint;

/** 定义一个实例变量，保存枚举值 */
@property (nonatomic, assign) PanDirection           panDirection;
/** 是否在调节音量*/
@property (nonatomic, assign) BOOL                   isVolume;
/** 是否被用户暂停 */
@property (nonatomic, assign) BOOL                   isPauseByUser;
/** 播放完了*/
@property (nonatomic, assign) BOOL                   playDidEnd;
/** 进入后台*/
@property (nonatomic, assign) BOOL                   didEnterBackground;
/** 单击 */
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
/** 双击 */
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
/** 快进快退、View*/
@property (nonatomic, strong) SuperPlayerFastView    *fastView;

@property (nonatomic, setter=setDragging:) BOOL isDragging;
/// 中间的提示按钮
@property (nonatomic, strong) UIButton               *middleBlackBtn;
@property ButtonAction                               middleBlackBtnAction;

/** 系统菊花 */
@property (nonatomic, strong) MMMaterialDesignSpinner *spinner;

@property (nonatomic, strong) UIButton               *lockTipsBtn;

@property (nonatomic, strong) SuperPlayerModel       *playerModel;

@property (class, readonly) UISlider *volumeViewSlider;

@property MPVolumeView *volumeView;

// add for txvodplayer
@property BOOL  isLoaded;

@property (nonatomic) BOOL  isShiftPlayback;

@property CGFloat maxLiveProgressTime;    // 直播最大进度/总时间
@property CGFloat liveProgressTime;       // 直播播放器回调过来的时间
@property CGFloat liveProgressBase;       // 直播播放器超出时移的最大时间
#define MAX_SHIFT_TIME  (2*60*60)
/** 是否是直播流 */
@property BOOL isLive;

/** 腾讯点播播放器 */
@property (nonatomic, strong) TXVodPlayer                *vodPlayer;
/** 腾讯直播播放器 */
@property (nonatomic, strong) TXLivePlayer               *livePlayer;

@property NSDate *reportTime;

@property NetWatcher *netWatcher;

@property (nonatomic) CGFloat videoRatio;

/// 由协议解析出分辨率定义表
@property (strong, nonatomic) NSArray<SPSubStreamInfo *> *resolutions;
/// 当前可用的分辨率列表
//@property (strong, nonatomic) NSArray<NSString *> *currentResolutionNames;
@end


// ---------------------------------------------------------------

@class AdaptiveStream;

@interface SuperPlayerModel()

//@property (nonatomic, strong) NSString *drmType;
@property NSMutableArray<AdaptiveStream *> *streams;

//- (BOOL)canSetDrmType:(NSString *)drmType;

@end

#endif /* SuperPlayerView_Private_h */
