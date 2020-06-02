//
//  SPWeiboControlView.h
//  SuperPlayer
//
//  Created by annidyfeng on 2018/10/8.
//

#import "SuperPlayerControlView.h"

@interface SPWeiboControlView : SuperPlayerControlView
/** 分辨率的名称 */
@property (nonatomic, strong) NSArray<NSString *> *resolutionArray;
/** 开始播放按钮 */
@property (nonatomic, strong) UIButton                *startBtn;
/** 当前播放时长label */
@property (nonatomic, strong) UILabel                 *currentTimeLabel;
/** 视频总时长label */
@property (nonatomic, strong) UILabel                 *totalTimeLabel;
/** 全屏按钮 */
@property (nonatomic, strong) UIButton                *fullScreenBtn;
/** 滑杆 */
@property (nonatomic, strong) PlayerSlider            *videoSlider;

@property (nonatomic, strong) UIButton                *moreBtn;

@property (nonatomic, strong) UIButton                *backBtn;

@property (nonatomic, strong) UIButton                *muteBtn;

@property (nonatomic, assign,getter=isFullScreen)BOOL fullScreen;

/** 切换分辨率按钮 */
@property (nonatomic, strong) UIButton                *resolutionBtn;
@property (nonatomic, strong) UIButton                *resoultionCurrentBtn;
/** 分辨率的View */
@property (nonatomic, strong) UIView                  *resolutionView;
/** 更多设置View */
@property (nonatomic, strong) SuperPlayerSettingsView         *moreContentView;
@property (nonatomic, strong) UIButton               *pointJumpBtn;
@end
