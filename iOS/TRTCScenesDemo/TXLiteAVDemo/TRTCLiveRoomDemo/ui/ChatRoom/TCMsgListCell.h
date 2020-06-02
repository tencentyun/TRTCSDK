/**
 * Module: TCMsgListCell
 *
 * Function: 消息Cell
 */

#import <UIKit/UIKit.h>
#import "TCMsgModel.h"
@class TRTCLiveUserInfo;
typedef void (^TCLiveTopClick)(void);

/**
 *  TCMsgListCell 类说明：
 *  用户消息列表cell，用于展示消息信息
 */
@interface TCMsgListCell : UITableViewCell
/**
 *  刷新cell内容信息
 */
- (void)refreshWithModel:(TCMsgModel *)msgModel;

/**
 *  通过msgModel 获取消息列表每行的内容信息，通过返回的AttributedString计算cell的高度
 */
+ (NSAttributedString *)getAttributedStringFromModel:(TCMsgModel *)msgModel;

@end


@interface TCShowLiveTopView : UIView

- (instancetype)initWithFrame:(CGRect)frame isHost:(BOOL)isHost hostNickName:(NSString *)hostNickName audienceCount:(NSInteger)audienceCount likeCount:(NSInteger)likeCount hostFaceUrl:(NSString *)hostFaceUrl;

- (void)setViewerCount:(int)viewerCount likeCount:(int)likeCount;

- (void)startLive;
- (void)pauseLive;
- (void)resumeLive;

- (NSInteger)getViewerCount;       // 获取在线观看人数
- (NSInteger)getLikeCount;
- (NSInteger)getTotalViewerCount;  // 获取累计观看人数
- (NSInteger)getLiveDuration;

- (void)onUserEnterLiveRoom;
- (void)onUserExitLiveRoom;
- (void)onUserSendLikeMessage;
@property (nonatomic, copy) TCLiveTopClick clickHead;

@end

//观众列表
#define IMAGE_SIZE  35
#define IMAGE_SPACE 5
/**
 *  TCAudienceListCell 类说明：
 *  房间观众list cell，用于展示观众信息
 */
@interface TCAudienceListCell : UITableViewCell
/**
 *  通过msgModel刷新观众信息
 */
-(void)refreshWithModel:(TRTCLiveUserInfo *)msgModel;
@end
