//
//  TRTCAudioCallViewController.h
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/18.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TRTCCloud.h>
#import "TRTCAudioCallCloudManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCAudioCallViewController : UIViewController

@property (nonatomic) TRTCParams *param;    /// TRTC SDK 视频通话房间进入所必须的参数
@property (nonatomic) TRTCAppScene scene;  //场景
@property (strong, nonatomic) TRTCAudioCallCloudManager *audioCallCloudManager;

@end

NS_ASSUME_NONNULL_END
