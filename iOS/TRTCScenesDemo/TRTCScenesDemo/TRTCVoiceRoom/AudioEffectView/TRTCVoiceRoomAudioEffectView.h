//
//  TRTCVoiceRoomAudioEffectView.h
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/22.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRTCVoiceRoomAudioEffectManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCVoiceRoomAudioEffectView : UIView

@property (assign, nonatomic) bool isShow;            //是否显示
-(void)show;
-(void)dismiss;

-(id)initWithManager:(TRTCVoiceRoomAudioEffectManager *)manager;

@property (nonatomic,strong) TRTCVoiceRoomAudioEffectManager *manager;

-(void)playFinished:(int)effectId;

//根据状态改变图标
@property (nonatomic,copy) void (^changeState)(BOOL flag);
@end

NS_ASSUME_NONNULL_END
