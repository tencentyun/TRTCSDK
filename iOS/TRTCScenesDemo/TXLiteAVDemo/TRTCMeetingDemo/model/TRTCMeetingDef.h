//
//  TRTCMeetingDef.h
//  TRTCScenesDemo
//
//  Created by xcoderliu on 4/21/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if defined(ENTERPRISE) || defined(TRTC_APPSTORE)
#import <TXLiteAVSDK_Enterprise/TRTCCloud.h>
#elif defined(PROFESSIONAL)
#import <TXLiteAVSDK_Professional/TRTCCloud.h>
#elif defined(TRTC)
#import <TXLiteAVSDK_TRTC/TRTCCloud.h>
#endif


// 用户基本信息（IMSDK中获取）
@interface TXUserInfo : NSObject

@property (nonatomic, strong) NSString *userId;    // 用户ID
@property (nonatomic, strong) NSString *userName;  // 用户名称（昵称）
@property (nonatomic, strong) NSString *avatarURL; // 用户头像URL

@end


// 会议用户信息
@interface TRTCMeetingUserInfo : TXUserInfo

// 用户是否打开了视频
@property (nonatomic, assign) BOOL isVideoAvailable;

// 用户是否打开音频
@property (nonatomic, assign) BOOL isAudioAvailable;

// 是否对用户静画（不播放该用户的视频）
@property (nonatomic, assign) BOOL isMuteVideo;

// 是否对用户静音（不播放改用户的音频）
@property (nonatomic, assign) BOOL isMuteAudio;

@end
