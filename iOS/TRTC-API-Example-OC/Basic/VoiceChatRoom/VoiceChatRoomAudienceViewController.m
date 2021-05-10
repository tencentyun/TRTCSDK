//
//  VoiceChatRoomAudienceViewController.m
//  TRTC-API-Example-OC
//
//  Created by adams on 2021/4/14.
//

/*
 语音互动直播功能 - 观众端示例
 TRTC APP 支持语音互动直播功能
 本文件展示如何集成语音互动直播功能
 1、进入TRTC房间。 API:[self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
 2、开启本地音频。  API:[self.trtcCloud startLocalAudio:TRTCAudioQualityMusic];
 3、静音远端：API：[self.trtcCloud muteRemoteAudio:userId mute:sender.selected];
 4、上下麦：API：[self.trtcCloud switchRole: TRTCRoleAudience];
 参考文档：https://cloud.tencent.com/document/product/647/45753
 */

/*
 Interactive Live Audio Streaming - Listener
 The TRTC app supports interactive live audio streaming.
 This document shows how to integrate the interactive live audio streaming feature.
 1. Enter a room: [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE]
 2. Enable local audio: [self.trtcCloud startLocalAudio:TRTCAudioQualityMusic]
 3. Mute a remote user: [self.trtcCloud muteRemoteAudio:userId mute:sender.selected]
 4. Become speaker/listener: [self.trtcCloud switchRole: TRTCRoleAudience]
 Documentation: https://cloud.tencent.com/document/product/647/45753
 */

#import "VoiceChatRoomAudienceViewController.h"

/// Demo中最大限制进房用户个数为6, 具体可根据需求来定最大进房人数。
static const NSInteger maxRemoteUserNum = 6;

@interface VoiceChatRoomAudienceViewController () <TRTCCloudDelegate>
@property (weak, nonatomic) IBOutlet UILabel *audienceLabel;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIButton *upMicButton;
@property (strong, nonatomic) TRTCCloud *trtcCloud;
@property (strong, nonatomic) NSMutableOrderedSet *anchorIdSet;
@end

@implementation VoiceChatRoomAudienceViewController

- (NSMutableOrderedSet *)anchorIdSet {
    if (!_anchorIdSet) {
        _anchorIdSet = [[NSMutableOrderedSet alloc] initWithCapacity:maxRemoteUserNum];
    }
    return _anchorIdSet;
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
    self.audienceLabel.text = Localize(@"TRTC-API-Example.VoiceChatRoomAudience.AudienceOperate");
    [self.muteButton setTitle:Localize(@"TRTC-API-Example.VoiceChatRoomAnchor.mute") forState:UIControlStateNormal];
    [self.muteButton setTitle:Localize(@"TRTC-API-Example.VoiceChatRoomAnchor.cancelmute") forState:UIControlStateSelected];
    [self.upMicButton setTitle:Localize(@"TRTC-API-Example.VoiceChatRoomAnchor.upMic") forState:UIControlStateNormal];
    [self.upMicButton setTitle:Localize(@"TRTC-API-Example.VoiceChatRoomAnchor.downMic") forState:UIControlStateSelected];
    
    self.muteButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.upMicButton.titleLabel.adjustsFontSizeToFitWidth = true;
}

- (void)onEnterRoom:(UInt32)roomId userId:(NSString *)userId {
    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = SDKAppID;
    params.roomId = roomId;
    params.userId = userId;
    params.userSig = [GenerateTestUserSig genTestUserSig:userId];
    params.role = TRTCRoleAudience;
    self.trtcCloud.delegate = self;
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneVoiceChatRoom];
}

#pragma mark - IBActions
- (IBAction)onMuteClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    NSInteger index = 0;
    for (NSString* userId in self.anchorIdSet) {
        if (index >= maxRemoteUserNum) { return; }
        [self.trtcCloud muteRemoteAudio:userId mute:sender.selected];
    }
}

- (IBAction)onUpMicClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.trtcCloud switchRole: TRTCRoleAnchor];
        [self.trtcCloud startLocalAudio:TRTCAudioQualityMusic];
    } else {
        [self.trtcCloud switchRole: TRTCRoleAudience];
        [self.trtcCloud stopLocalAudio];
    }
}

#pragma mark - TRTCCloudDelegate
- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available {
    NSInteger index = [self.anchorIdSet indexOfObject:userId];
    if (available) {
        if (index != NSNotFound) { return; }
        [self.anchorIdSet addObject:userId];
    } else {
        if (index) {
            [self.anchorIdSet removeObject:userId];
        }
    }
}

- (void)dealloc
{
    [self.trtcCloud stopLocalAudio];
    [self.trtcCloud exitRoom];
    [TRTCCloud destroySharedIntance];
}

@end
