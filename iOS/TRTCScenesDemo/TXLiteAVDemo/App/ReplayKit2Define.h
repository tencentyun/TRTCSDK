//
//  Replaykit2Define.h
//  TXLiteAVDemo
//
//  Created by rushanting on 2018/3/26.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#ifndef Replaykit2Define_h
#define Replaykit2Define_h

#define kReplayKitUseAppGroup                   0
#define kReplayKit2AppGroupId                   @"group.com.tencent.liteav.RPLiveStreamRelease"
#define kReplayKit2PasteboardName               @"group.com.tencent.replaykit2.pasteboard"
#define kReplayKitIPCPort                       31753

#define kDarvinNotificationNamePushStart        CFSTR("Darwin_ReplayKit2_Push_Start")
#define kDarvinNotificaiotnNamePushStop         CFSTR("Darwin_ReplayKit2_Push_Stop")
#define kDarvinNotificaiotnNameRotationChange   CFSTR("Darwin_ReplayKit2_Rotate_Change")

#define kCocoaNotificationNameReplayKit2Stop    @"Cocoa_ReplayKit2_Stop"

#define kLocalNotificationTypeKey               @"LocalNotificationType"
#define kLocalNotificationTypeReplaykit2        @"LocalNotificationReplaykit2"

#define kReplayKit2UploadingKey      @"replaykit2Uploading"
#define kReplayKit2Uploading                    @"uploading"
#define kReplayKit2Stop                         @"stop"


#define kReplayKit2PushUrlKey        @"replaykit2RtmpURL"

#define kReplayKit2RotateKey         @"replaykit2Rotation"
#define kReplayKit2Portrait                     @"replaykit2Portrait"
#define kReplayKit2Lanscape                     @"replaykit2Lanscape"

#define kReplayKit2ResolutionKey     @"replaykit2Resolution"
#define kResolutionSD                           @"SD"
#define kResolutionHD                           @"HD"
#define kResolutionFHD                          @"FHD"
#define kDarvinNotificaiotnNameResolutionChange   CFSTR("Darwin_ReplayKit2_Resolution_Change")


#define kReplayKit2UserDefaultRoomidKey                 @"roomID"

#endif /* Replaykit2Define_h */

