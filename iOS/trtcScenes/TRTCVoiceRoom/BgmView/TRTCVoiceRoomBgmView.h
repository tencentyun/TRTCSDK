//
//  TRTCVoiceRoomBgmView.h
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/22.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRTCVoiceRoomBgmManager.h"

typedef enum : NSInteger {
    PLAY_STOP ,      //停止播放
    PLAY_LOCAL ,    //播放本地
    PLAY_NET     //播放网络
} PlayState;        //播放状态

NS_ASSUME_NONNULL_BEGIN

@interface TRTCVoiceRoomBgmView : UIView

-(id)initWithBgmManager:(TRTCVoiceRoomBgmManager *)bgmManager;

@property (nonatomic, strong) TRTCVoiceRoomBgmManager *bgmManager;
@property (nonatomic) bool isShow;            //是否显示
-(void)show;
-(void)dismiss;

//根据状态改变图标
@property (nonatomic, copy) void (^changeState)(PlayState state);

@end

NS_ASSUME_NONNULL_END
