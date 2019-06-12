//
//  TRTCMoreSettingViewController.h
//  TXLiteAVDemo
//
//  Created by rushanting on 2019/3/6.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRTCCloud.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TRTCMoreSettingDelegate <NSObject>

@optional
- (void)onAudioVolumeEnableChanged:(BOOL)enable;
- (void)onCloudMixingEnable:(BOOL)enable;
- (void)onClickedSwitch2Role:(BOOL)isAudience;

@end

@interface TRTCMoreViewController : UITableViewController

@property (nonatomic, weak) id<TRTCMoreSettingDelegate> delegate;

+ (BOOL)isFrontCamera;
+ (BOOL)isFitScaleMode;
+ (BOOL)isAudioCaptureEnable;
+ (BOOL)isSpeakphoneMode;
+ (BOOL)isGsensorEnable;
+ (BOOL)isAudioVolumeEnable;
+ (BOOL)isCloudMixingEnable;
+ (BOOL)isAudience;
+ (void)setRole:(TRTCRoleType)role;

- (instancetype)initWithTRTCEngine:(TRTCCloud*)engine roomId:(NSString*)roomId userId:(NSString*)userId;

- (NSMutableDictionary*)getPKInfo;
- (void)enableRoleSwitch:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
