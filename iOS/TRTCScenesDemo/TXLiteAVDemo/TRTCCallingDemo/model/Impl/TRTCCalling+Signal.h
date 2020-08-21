//
//  TRTCCall+Signal.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/3.
//

#import "TRTCCalling.h"

@protocol TRTCCallingDelegate;
@interface TRTCCalling (Signal)

///添加信令监听
- (void)addSignalListener;

///移除信令监听
- (void)removeSignalListener;

///通过信令发起通话邀请
- (NSString *)invite:(NSString *)receiver action:(CallAction)action model:(CallModel *)model;

///收到通话邀请推送通知
- (void)onReceiveGroupCallAPNs:(V2TIMSignalingInfo *)signalingInfo;

///检查是否满足自动挂断逻辑
- (void)checkAutoHangUp;
@end


/// TRTCCalling扩展参数
@interface TRTCCalling ()

@property(nonatomic,copy) NSString *curCallID;
@property(nonatomic,strong) NSMutableArray *curInvitingList;
@property(nonatomic,strong) NSMutableArray *curRoomList;
@property(nonatomic,strong) NSMutableArray *curRespList;
@property(nonatomic,strong) CallModel *curLastModel;
@property(nonatomic,copy) NSString *curGroupID;        //群邀请的群 ID
@property(nonatomic,copy) NSString *curSponsorForMe;   //对自己发起通话邀请的人
@property(nonatomic,assign) CallType curType;
@property(nonatomic,assign) UInt32 curRoomID;
@property(nonatomic,assign) BOOL isInRoom;
@property(nonatomic,assign) BOOL isOnCalling;
@property(nonatomic,assign) BOOL isFrontCamera;
@property(nonatomic,assign) UInt64 startCallTS;
@property(nonatomic,strong) NSString *callID;

@property(nonatomic,weak) id<TRTCCallingDelegate> delegate;

- (void)enterRoom;

- (void)quitRoom;

@end

