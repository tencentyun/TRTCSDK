/**
 * Module: TCAnchorViewController
 *
 * Function: 主播推流模块主控制器，里面承载了渲染view，逻辑view，以及推流相关逻辑，同时也是SDK层事件通知的接收者
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TCAnchorToolbarView.h"
#import "MediaPlayer/MediaPlayer.h"
#import "TCUtil.h"

@class TRTCLiveRoom;
@class TRTCLiveRoomInfo;

@interface TCAnchorViewController : UIViewController<UITextFieldDelegate>
- (instancetype) init;
@property (nonatomic, strong) UIView                *videoParentView;
@property (nonatomic, strong)  TCAnchorToolbarView  *logicView;
@property (nonatomic, strong)  TRTCLiveRoom     *liveRoom;
@property (nonatomic, strong)  TRTCLiveRoomInfo     *liveInfo;
@property (nonatomic, assign)  BOOL log_switch;
@property (nonatomic, strong)  NSMutableSet         *setLinkMemeber;
@property (nonatomic, strong)  TRTCLiveRoomInfo     *curPkRoom;
@property (nonatomic, assign) NSInteger  roomStatus;
- (void)onAnchorEnter:(NSString *)userID;
- (void)onAnchorExit:(NSString *)userID;
- (void)onRequestJoinAnchor:(TRTCLiveUserInfo *)user reason:(NSString *)reason timeout: (double)timeout;
- (void)onRequestRoomPK:(TRTCLiveUserInfo *)user timeout: (double)timeout;
- (void)linkFrameRestore;
- (void)switchPKMode;
@end
