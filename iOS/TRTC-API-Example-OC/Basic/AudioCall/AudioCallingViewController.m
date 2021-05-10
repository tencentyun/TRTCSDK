//
//  AudioCallingViewController.m
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/14.
//

/*
实时语音通话功能 
 TRTC APP 实时语音通话功能
 本文件展示如何集成实时语音通话功能
 1、切换听筒与扬声器 API:[[_trtcCloud getDeviceManager] setAudioRoute:TXAudioRouteSpeakerphone];
 2、静音当前设备，其他人将无法听到该设备的声音 API: [_trtcCloud muteLocalAudio:true];
 3、显示其他的网络信息和音量信息 API：delegate -> onNetworkQuality, onUserVoiceVolume
 参考文档：https://cloud.tencent.com/document/product/647/42046
 */

/*
Real-Time Audio Call
 TRTC Audio Call
 This document shows how to integrate the real-time audio call feature.
 1. Switch between the speaker and receiver: [[_trtcCloud getDeviceManager] setAudioRoute:TXAudioRouteSpeakerphone]
 2. Mute the device so that others won’t hear the audio of the device: [_trtcCloud muteLocalAudio:true]
 3. Display other network and volume information: delegate -> onNetworkQuality, onUserVoiceVolume
 Documentation: https://cloud.tencent.com/document/product/647/42046
*/


#import "AudioCallingViewController.h"

static const NSInteger maxRemoteUserNum = 6;

@interface CustomRemoteInfo : NSObject
@property (nonatomic, assign)  NSInteger volume;
@property (nonatomic, assign)  TRTCQuality quality;
@end

@interface AudioCallingViewController ()<TRTCCloudDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *userStatusTableView;
@property (weak, nonatomic) IBOutlet UIButton *hansFreeButton;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIButton *hangUpButton;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardLabel;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *remoteViewArr;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *remoteLabelArr;

@property (assign, nonatomic) UInt32 roomId;
@property (strong, nonatomic) NSString* userId;
@property (strong, nonatomic) TRTCCloud *trtcCloud;
@property (strong, nonatomic) NSMutableOrderedSet *remoteUidSet;
@property (strong, nonatomic) NSMutableDictionary<NSString*, CustomRemoteInfo*> *remoteInfoDictionary;
@end

@implementation AudioCallingViewController

- (TRTCCloud*)trtcCloud {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
    }
    return _trtcCloud;
}

- (NSMutableOrderedSet *)remoteUidSet {
    if (!_remoteUidSet) {
        _remoteUidSet = [[NSMutableOrderedSet alloc] initWithCapacity:maxRemoteUserNum];
    }
    return _remoteUidSet;
}

- (instancetype)initWithRoomId:(UInt32)roomId userId:(NSString *)userId {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _roomId = roomId;
        _userId = userId;
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trtcCloud.delegate = self;
    [self setupDefaultUIConfig];
    [self setupTRTCCloud];

    _remoteInfoDictionary = [NSMutableDictionary dictionary];
    _userStatusTableView.allowsSelection = NO;
    [_userStatusTableView setDataSource:self];
    [_userStatusTableView setDelegate:self];
}

- (void)setupDefaultUIConfig {
    self.title = [Localize(@"TRTC-API-Example.AudioCalling.Title") stringByAppendingString:[@(_roomId) stringValue]];
    [_hansFreeButton setTitle:Localize(@"TRTC-API-Example.AudioCalling.speaker") forState:UIControlStateNormal];
    [_muteButton setTitle:Localize(@"TRTC-API-Example.AudioCalling.mute") forState:UIControlStateNormal];
    [_hangUpButton setTitle:Localize(@"TRTC-API-Example.AudioCalling.hangup") forState:UIControlStateNormal];
    [_hansFreeButton setTitle:Localize(@"TRTC-API-Example.AudioCalling.earPhone") forState:UIControlStateNormal];
    [_hansFreeButton setTitle:Localize(@"TRTC-API-Example.AudioCalling.speaker") forState:UIControlStateSelected];
    [_muteButton setTitle:Localize(@"TRTC-API-Example.AudioCalling.cancelMute") forState:UIControlStateSelected];
    [_muteButton setTitle:Localize(@"TRTC-API-Example.AudioCalling.mute") forState:UIControlStateNormal];

    _dashBoardLabel.text = Localize(@"TRTC-API-Example.AudioCalling.dashBorad");
    _hansFreeButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _muteButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _hangUpButton.titleLabel.adjustsFontSizeToFitWidth = true;
    _dashBoardLabel.adjustsFontSizeToFitWidth = true;

    for (UIView *remoteView in _remoteViewArr) {
        remoteView.hidden = true;
    }
    
    for (UILabel *remoteLabel in _remoteLabelArr) {
        remoteLabel.adjustsFontSizeToFitWidth = true;
    }
}

- (void)setupTRTCCloud {
    TRTCParams *params = [TRTCParams new];
    params.sdkAppId = SDKAppID;
    params.roomId = _roomId;
    params.userId = _userId;
    params.role = TRTCRoleAnchor;
    params.userSig = [GenerateTestUserSig genTestUserSig:params.userId];
    
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneVideoCall];
    [self.trtcCloud startLocalAudio:TRTCAudioQualityMusic];
    [self.trtcCloud enableAudioVolumeEvaluation:1000];
}

- (void)dealloc {
    [self.trtcCloud exitRoom];
    [TRTCCloud destroySharedIntance];
    _trtcCloud = nil;
}

#pragma mark - IBActions

- (IBAction)onSwitchSpeakerClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([sender isSelected]) {
        [[_trtcCloud getDeviceManager] setAudioRoute:TXAudioRouteSpeakerphone];
    } else {
        [[_trtcCloud getDeviceManager] setAudioRoute:TXAudioRouteEarpiece];
    }
}

- (IBAction)onMicCaptureClick:(UIButton*)sender {
    sender.selected = !sender.selected;
    if ([sender isSelected]) {
        [_trtcCloud muteLocalAudio:true];
    } else {
        [_trtcCloud muteLocalAudio:false];
    }
}

- (IBAction)onAudioCallStopClick:(UIButton *)sender {
    [self.trtcCloud stopLocalAudio];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TRTCCloud Delegate

- (void)onRemoteUserEnterRoom:(NSString *)userId {
    [self.remoteUidSet addObject:userId];
    [_remoteInfoDictionary setObject:[CustomRemoteInfo new] forKey:userId];
    [self refreshRemoteAudioViews];

}

- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason {
    NSInteger index = [_remoteUidSet indexOfObject:userId];
    if (index != NSNotFound) {
        [[_remoteViewArr objectAtIndex:index] setHidden:true];
    }
    [self.remoteUidSet removeObject:userId];
    [_remoteInfoDictionary removeObjectForKey:userId];
    [self refreshRemoteAudioViews];
}

- (void)refreshRemoteAudioViews {
    NSInteger index = 0;
    for (UIView *remoteView in _remoteViewArr) {
        remoteView.hidden = true;
    }
    
    for (NSString* userId in _remoteUidSet) {
        if (index >= maxRemoteUserNum) { return; }
        [_remoteViewArr[index] setHidden:false];
        [_remoteLabelArr[index++] setText:userId];
    }
}

- (void)onNetworkQuality:(TRTCQualityInfo *)localQuality remoteQuality:(NSArray<TRTCQualityInfo *> *)remoteQuality {
    for (NSString *userId in _remoteUidSet) {
        for (TRTCQualityInfo *info in remoteQuality) {
            if ([userId isEqualToString:info.userId]) {
                _remoteInfoDictionary[userId].quality = info.quality;
            }
        }
    }
    
    [_userStatusTableView reloadData];
}

- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume {
    for (NSString *userId in _remoteUidSet) {
        for (TRTCVolumeInfo *info in userVolumes) {
            if ([userId isEqualToString:info.userId]) {
                _remoteInfoDictionary[userId].volume = info.volume;
            }
        }
    }
    
    [_userStatusTableView reloadData];
}

#pragma mark - tableView Delegate

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.textColor = [UIColor colorWithRed:52.0/255 green:184.0/255 blue:97.0/255 alpha:1];
    cell.backgroundColor = [UIColor clearColor];
    
    NSString *userId = [_remoteUidSet objectAtIndex:indexPath.row];
    if (userId == nil) { return cell; }

    if (indexPath.section == 0) {
        NSString *volume = [[NSString alloc] initWithFormat:@"%ld", (long)_remoteInfoDictionary[userId].volume];
        cell.textLabel.text = [[userId stringByAppendingString:@": "] stringByAppendingString:volume];
    } else {
        NSString *quality;
        switch (_remoteInfoDictionary[userId].quality) {
            case TRTCQuality_Excellent:
                quality = Localize(@"TRTC-API-Example.AudioCalling.best");
                break;
            case TRTCQuality_Good:
                quality = Localize(@"TRTC-API-Example.AudioCalling.good");
                break;
            case TRTCQuality_Poor:
                quality = Localize(@"TRTC-API-Example.AudioCalling.normal");
                break;
            case TRTCQuality_Bad:
                quality = Localize(@"TRTC-API-Example.AudioCalling.wrong");
                break;
            case TRTCQuality_Vbad:
                quality = Localize(@"TRTC-API-Example.AudioCalling.bad");
                break;
            case TRTCQuality_Down:
                quality = Localize(@"TRTC-API-Example.AudioCalling.noUse");
                break;
            default:
                quality = Localize(@"TRTC-API-Example.AudioCalling.unknow");
                break;
        }
        cell.textLabel.text = [[userId stringByAppendingString:@": "] stringByAppendingString:quality];
    }
    
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return Localize(@"TRTC-API-Example.AudioCalling.volumInfo");
    } else {
        return Localize(@"TRTC-API-Example.AudioCalling.network");
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRed:52.0/255 green:184.0/255 blue:97.0/255 alpha:1]];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _remoteUidSet.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

@end

@implementation CustomRemoteInfo : NSObject
@end
