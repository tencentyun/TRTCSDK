/**
 * Module: TCAudienceViewController
 *
 * Function: 观众播放模块主控制器，里面承载了渲染view，逻辑view，以及播放相关逻辑，同时也是SDK层事件通知的接收者
 */

#import "TCAudienceToolbarView.h"
#import "TXLiveRecordListener.h"
#import "TCUtil.h"

#define FULL_SCREEN_PLAY_VIDEO_VIEW     10000

@class TRTCLiveRoomInfo;
@class TRTCLiveRoom;
@class UserModel;

@interface TCAudienceViewController : UIViewController

@property (nonatomic, retain) TRTCLiveRoomInfo  *liveInfo;
@property (nonatomic, copy)   videoIsReadyBlock   videoIsReady;
@property (nonatomic, copy)  void(^onPlayError)(void);
@property (nonatomic, retain) TCAudienceToolbarView *logicView;
@property (nonatomic, retain) TRTCLiveRoom* liveRoom;
@property (nonatomic, assign) BOOL  log_switch;
@property (nonatomic, strong) UIView  *videoParentView;
@property (nonatomic, assign) NSInteger  roomStatus;
@property (nonatomic, assign)  BOOL isOwnerEnter;

- (id)initWithPlayInfo:(TRTCLiveRoomInfo *)info videoIsReady:(videoIsReadyBlock)videoIsReady;
- (void)onAnchorEnter:(NSString *)userID;
- (void)onAnchorExit:(NSString *)userID;
- (void)switchPKMode;
- (void)linkFrameRestore;
- (void)stopLocalPreview;
- (void)onKickoutJoinAnchor;
- (void)onLiveEnd;
- (BOOL)startRtmp;
- (void)stopRtmp;
- (void)clickScreen:(CGPoint)position;
@end
