/**
 * Module: TCAudienceToolbarView
 *
 * Function: 工具栏
 */

#import <UIKit/UIKit.h>
#import "TCMsgModel.h"
#import "TCMsgListTableView.h"

@class TRTCLiveRoom;

@protocol TCAudienceToolbarDelegate <NSObject>
- (void)closeVC:(BOOL)popViewController;
- (void)clickScreen:(CGPoint)position;
- (void)clickPlayVod;
- (void)clickLog;
- (void)onSeek:(UISlider *)slider;
- (void)onSeekBegin:(UISlider *)slider;
- (void)onDrag:(UISlider *)slider;
- (void)onRecvGroupDeleteMsg;
@end


/**
 *  播放模块逻辑view，里面展示了消息列表，弹幕动画，观众列表等UI，其中与SDK的逻辑交互需要交给主控制器处理
 */
@interface TCAudienceToolbarView : UIView <
    UITextFieldDelegate,
    UIAlertViewDelegate,
    TCAudienceListDelegate>

@property (nonatomic, weak) id <TCAudienceToolbarDelegate> delegate;

@property (nonatomic, retain)  UILabel            *playDuration;
@property (nonatomic, retain)  UISlider           *playProgress;
@property (nonatomic, retain)  UILabel            *playLabel;
@property (nonatomic, retain)  UIButton           *playBtn;
@property (nonatomic, retain)  UIButton           *closeBtn;
@property (nonatomic, retain)  UIButton           *btnChat;
@property (nonatomic, retain)  UIView             *cover;
@property (nonatomic, retain)  UITextView         *statusView;
@property (nonatomic, retain)  UITextView         *logViewEvt;
@property (nonatomic, weak) TRTCLiveRoom      *liveRoom;

- (instancetype)initWithFrame:(CGRect)frame liveInfo:(TRTCLiveRoomInfo *)liveInfo withLinkMic:(BOOL)linkmic;

- (void)setViewerCount:(int)viewerCount likeCount:(int)likeCount;

- (BOOL)isAlreadyInAudienceList:(TCMsgModel *)model;

- (void)initAudienceList:(NSArray *)audienceList;

- (void)keyboardFrameDidChange:(NSNotification*)notice;

- (void)handleIMMessage:(IMUserAble*)info msgText:(NSString*)msgText;

@end
