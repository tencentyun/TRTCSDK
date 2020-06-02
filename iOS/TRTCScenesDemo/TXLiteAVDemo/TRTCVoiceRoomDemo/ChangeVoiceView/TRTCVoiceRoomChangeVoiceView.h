//
//  TRTCVoiceRoomChangeVoiceView.h
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/21.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRTCVoiceRoomBgmManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCVoiceRoomChangeVoiceView : UIView

-(id)initWithBgmManager:(TRTCVoiceRoomBgmManager *)bgmManager;

@property (nonatomic,strong) TRTCVoiceRoomBgmManager *bgmManager;
@property (assign, nonatomic) bool isShow;            //是否显示
-(void)show;
-(void)dismiss;

//根据状态改变图标
@property (nonatomic,copy) void (^changeState)(NSString *state);
@end

NS_ASSUME_NONNULL_END
