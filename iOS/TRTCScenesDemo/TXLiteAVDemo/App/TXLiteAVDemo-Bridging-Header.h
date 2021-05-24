//
//  TXLiteAVDemo-Bridging-Header.h
//  TXLiteAVDemo_TRTC_Scene
//
//  Created by abyyxwang on 2020/4/15.
//  Copyright © 2020 Tencent. All rights reserved.
//



/* TXLiteAVDemo_Bridging_Header_h */

// localized string usage
#import "AppLocalized.h"

#import "PortalViewController.h"

#import "TCAnchorViewController.h"
#import "TCAudienceViewController.h"
#import "TRTCMeeting.h"
// VocieRoom
#import "TRTCVoiceRoomDef.h"
#import "TRTCVoiceRoom.h"
// ChatSalon
#import "TRTCChatSalon.h"
#import "TRTCChatSalonDef.h"

#import "TRTCLiveRoom.h"
#import "TRTCCalling.h"

#import "AppDelegate.h"
#import <SDWebImage/SDWebImage.h>
#import <MJRefresh/MJRefresh.h>

#import <ImSDK/ImSDK.h>
#import "GenerateTestUserSig.h"

#if defined(TRTC) && !defined(TRTC_APPSTORE)
@import TXLiteAVSDK_TRTC;
#endif

#ifdef TRTC_APPSTORE
@import TXLiteAVSDK_TRTC;
#endif
