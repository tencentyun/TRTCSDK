//
//  TXLiteAVDemo-Bridging-Header.h
//  TXLiteAVDemo_TRTC_Scene
//
//  Created by abyyxwang on 2020/4/15.
//  Copyright © 2020 Tencent. All rights reserved.
//



/* TXLiteAVDemo_Bridging_Header_h */
#ifdef TRTC
#import "PortalViewController.h"
#endif

#ifdef ENABLE_TRTC
#import "TCAnchorViewController.h"
#import "TCAudienceViewController.h"
#import "TRTCMeeting.h"
#endif
#import "AppDelegate.h"
#import <SDWebImage/SDWebImage.h>
#import <MJRefresh/MJRefresh.h>

#if !defined(UGC) && !defined(PLAYER)
#import <ImSDK/ImSDK.h>
#import "GenerateTestUserSig.h"
#endif

#ifdef ENTERPRISE
@import TXLiteAVSDK_TRTC;
#endif

#ifdef PROFESSIONAL
@import TXLiteAVSDK_Professional;
#endif

#ifdef SMART
@import TXLiteAVSDK_Smart;
#endif

#ifdef PLAYER
@import TXLiteAVSDK_Player;
#endif

#ifdef UGC
@import TXLiteAVSDK_UGC;
#endif

#if defined(TRTC) && !defined(TRTC_APPSTORE)
@import TXLiteAVSDK_TRTC;
#endif

#ifdef TRTC_APPSTORE
@import TXLiteAVSDK_TRTC;
#endif
