//
//  VoiceChatRoomAnchorViewController.m
//  TRTC-API-Example-OC
//
//  Created by adams on 2021/4/14.
//

/*
 语音互动直播功能 - 主播端示例
 TRTC APP 支持语音互动直播功能
 本文件展示如何集成语音互动直播功能
 1、进入TRTC房间。 API:[self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
 2、开启本地音频。  API:[self.trtcCloud startLocalAudio:TRTCAudioQualityMusic];
 3、静音远端：API：[self.trtcCloud muteRemoteAudio:userId mute:sender.selected];
 4、上下麦：API：[self.trtcCloud switchRole: TRTCRoleAudience];
 5、 Demo中最大限制进房用户个数为6, 具体可根据需求来定最大进房人数。
 参考文档：https://cloud.tencent.com/document/product/647/45753
 */

/*
 Interactive Live Audio Streaming - Room Owner
 The TRTC app supports interactive live audio streaming.
 This document shows how to integrate the interactive live audio streaming feature.
 1. Enter a room: [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE]
 2. Enable local audio: [self.trtcCloud startLocalAudio:TRTCAudioQualityMusic]
 3. Mute a remote user: [self.trtcCloud muteRemoteAudio:userId mute:sender.selected]
 4. Become speaker/listener: [self.trtcCloud switchRole: TRTCRoleAudience]
 5. In the demo, a maximum of 6 users can enter a room. The number can be modified as needed.
 Documentation: https://cloud.tencent.com/document/product/647/45753
*/

#import "VoiceChatRoomAnchorViewController.h"


static const NSInteger maxRemoteUserNum = 6;

@interface VoiceChatRoomAnchorViewController () <TRTCCloudDelegate>
@property (weak, nonatomic) IBOutlet UILabel *anchorLabel;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIButton *downMicButton;
@property (strong, nonatomic) TRTCCloud *trtcCloud;
@property (strong, nonatomic) NSMutableOrderedSet *anchorIdSet;
@end

@implementation VoiceChatRoomAnchorViewController

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

- (void)onEnterRoom:(UInt32)roomId userId:(NSString *)userId {
    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = SDKAppID;
    params.roomId = roomId;
    params.userId = userId;
    params.userSig = [GenerateTestUserSig genTestUserSig:userId];
    params.role = TRTCRoleAnchor;
    
    self.trtcCloud.delegate = self;
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneVoiceChatRoom];
    [self.trtcCloud startLocalAudio:TRTCAudioQualityMusic];
}

- (void)setupDefaultUIConfig {
    self.anchorLabel.text = Localize(@"TRTC-API-Example.VoiceChatRoomAnchor.AnchorOperate");
    [self.muteButton setTitle:Localize(@"TRTC-API-Example.VoiceChatRoomAnchor.mute") forState:UIControlStateNormal];
    [self.muteButton setTitle:Localize(@"TRTC-API-Example.VoiceChatRoomAnchor.cancelmute") forState:UIControlStateSelected];
    [self.downMicButton setTitle:Localize(@"TRTC-API-Example.VoiceChatRoomAnchor.downMic") forState:UIControlStateNormal];
    [self.downMicButton setTitle:Localize(@"TRTC-API-Example.VoiceChatRoomAnchor.upMic") forState:UIControlStateSelected];
    
    self.muteButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.downMicButton.titleLabel.adjustsFontSizeToFitWidth = true;
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

- (IBAction)onDownMicClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.trtcCloud switchRole: TRTCRoleAudience];
        [self.trtcCloud stopLocalAudio];
    } else {
        [self.trtcCloud switchRole: TRTCRoleAnchor];
        [self.trtcCloud startLocalAudio:TRTCAudioQualityMusic];
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
