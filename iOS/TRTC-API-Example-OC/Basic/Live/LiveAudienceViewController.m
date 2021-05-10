//
//  LiveAudienceViewController.m
//  TRTC-API-Example-OC
//
//  Created by adams on 2021/4/14.
//

/*
 视频互动直播功能 - 观众端示例
 TRTC APP 支持视频互动直播功能
 本文件展示如何集成视频互动直播功能
 1、进入TRTC房间。 API:[self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
 2、开启远程用户直播。API:[self.trtcCloud startRemoteView:userId streamType:TRTCVideoStreamTypeBig view:self.view];
 3、静音远端：API:[self.trtcCloud muteRemoteAudio:userId mute:sender.selected];
 参考文档：https://cloud.tencent.com/document/product/647/43181
 */

/*
 Interactive Live Video Streaming - Audience
 The TRTC app supports interactive live video streaming.
 This document shows how to integrate the interactive live video streaming feature.
 1. Enter a room: [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE]
 2. Display the video of a remote user: [self.trtcCloud startRemoteView:userId streamType:TRTCVideoStreamTypeBig view:self.view]
 3. Mute a remote user: [self.trtcCloud muteRemoteAudio:userId mute:sender.selected]
 Documentation: https://cloud.tencent.com/document/product/647/43181
*/

#import "LiveAudienceViewController.h"
static const NSInteger maxRemoteUserNum = 6;

@interface LiveAudienceViewController () <TRTCCloudDelegate>
@property (weak, nonatomic) IBOutlet UILabel *audienceLabel;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (nonatomic, strong) TRTCCloud *trtcCloud;
@property (nonatomic, strong) NSMutableOrderedSet *anchorUserIdSet;
@end

@implementation LiveAudienceViewController

- (NSMutableOrderedSet *)anchorUserIdSet {
    if (!_anchorUserIdSet) {
        _anchorUserIdSet = [[NSMutableOrderedSet alloc] initWithCapacity:maxRemoteUserNum];
    }
    return _anchorUserIdSet;
}

- (TRTCCloud *)trtcCloud {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
    }
    return _trtcCloud;
}

- (instancetype)initWithRoomId:(UInt32)roomId userId:(NSString *)userId {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        [self onEnterRoom:roomId userId:userId];
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
}

- (void)setupDefaultUIConfig {
    self.audienceLabel.text = Localize(@"TRTC-API-Example.LiveAudience.Operating");
    [self.muteButton setTitle:Localize(@"TRTC-API-Example.LiveAudience.mute") forState:UIControlStateNormal];
    [self.muteButton setTitle:Localize(@"TRTC-API-Example.LiveAudience.muteoff") forState:UIControlStateSelected];
    self.audienceLabel.adjustsFontSizeToFitWidth = true;
    self.muteButton.titleLabel.adjustsFontSizeToFitWidth = true;
}

- (void)onEnterRoom:(UInt32)roomId userId:(NSString *)userId {
    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = SDKAppID;
    params.roomId = roomId;
    params.userId = userId;
    params.userSig = [GenerateTestUserSig genTestUserSig:userId];
    params.role = TRTCRoleAudience;
    self.trtcCloud.delegate = self;
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
}

#pragma mark - IBActions
- (IBAction)onMuteClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    NSInteger index = 0;
    for (NSString* userId in self.anchorUserIdSet) {
        if (index >= maxRemoteUserNum) { return; }
        [self.trtcCloud muteRemoteAudio:userId mute:sender.selected];
    }
}

#pragma mark - TRTCCloudDelegate
- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available {
    NSInteger index = [self.anchorUserIdSet indexOfObject:userId];
    if (available) {
        [self.trtcCloud startRemoteView:userId streamType:TRTCVideoStreamTypeBig view:self.view];
        if (index != NSNotFound) { return; }
        [self.anchorUserIdSet addObject:userId];
    } else {
        [self.trtcCloud stopRemoteView:userId streamType:TRTCVideoStreamTypeBig];
        if (index) {
            [self.anchorUserIdSet removeObject:userId];
        }
    }
}

- (void)dealloc
{
    [self.trtcCloud stopLocalPreview];
    [self.trtcCloud stopLocalAudio];
    [self.trtcCloud exitRoom];
    [TRTCCloud destroySharedIntance];
}

@end
