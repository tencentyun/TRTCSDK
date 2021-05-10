//
//  JoinMultipleRoomViewController.m
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/22.
//

/*
 加入多个房间功能
 TRTC 加入多个房间
 
 本文件展示如何集成加入多个房间
 因为SDK中没有给subCloud定义标识，用户需要自行标识以区分不同的subCloud。该demo中使用subId进行标识。
 因为每个子subCloud都需要设置delegate回调，所以使用SubCloudHelper来进行delegate的转发，并加入subId来区分
 
 1、创建子对象 API: [self.trtcCloud createSubCloud]
 2、加入房间 API: [[_subCloudHelperArr[subId] getCloud] enterRoom:params appScene:TRTCAppSceneLIVE];
 3、退出房间 API: [[_subCloudHelperArr[subId] getCloud] exitRoom];
 
 参考文档：https://cloud.tencent.com/document/product/647/32258
 */
/*
 Entering Multiple Rooms
TRTC Multiple Room Entry

This document shows how to integrate the multiple room entry feature.
The SDK does not assign identifiers to TRTCCloud instances. You need to identify and distinguish instances by yourself. In the demo, subId is used to identify instances.
Because a delegate callback must be set for each instance, SubCloudHelper is used to forward delegates, and subId is used for identification.

1. Create an instance: [self.trtcCloud createSubCloud]
2. Enter a room: [[_subCloudHelperArr[subId] getCloud] enterRoom:params appScene:TRTCAppSceneLIVE] enterRoom:params appScene:TRTCAppSceneLIVE];
3. Exit a room: [[_subCloudHelperArr[subId] getCloud] exitRoom]

Documentation: https://cloud.tencent.com/document/product/647/32258

 */

#import "JoinMultipleRoomViewController.h"
#import "SubCloudHelper.h"

static const NSInteger maxRoom = 4;

@interface JoinMultipleRoomViewController () <SubCloudHelperDelegate>

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *roomNumLabelArr;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *remoteViewArr;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *roomIdArr;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *startButtonArr;

@property (strong, nonatomic) TRTCCloud *trtcCloud;
@property (strong, nonatomic) NSMutableArray *subCloudHelperArr;
@end

@implementation JoinMultipleRoomViewController

- (TRTCCloud*)trtcCloud {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
    }
    return _trtcCloud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupRandomRoomId];
    [self setupDefaultUIConfig];
    [self setupSubCloud];
}

- (void)setupDefaultUIConfig {
    self.title = Localize(@"TRTC-API-Example.JoinMultipleRoom.title");
    for (UILabel *label in _roomNumLabelArr) {
        label.text = Localize(@"TRTC-API-Example.JoinMultipleRoom.roomNum");
        label.adjustsFontSizeToFitWidth = true;
    }
    for (UIButton *button in _startButtonArr) {
        [button setTitle:Localize(@"TRTC-API-Example.JoinMultipleRoom.start")
                forState:UIControlStateNormal];
        [button setTitle:Localize(@"TRTC-API-Example.JoinMultipleRoom.stop")
                forState:UIControlStateSelected];
        button.titleLabel.adjustsFontSizeToFitWidth = true;
    }
}

- (void)setupRandomRoomId {
    for (UITextField *roomId in _roomIdArr) {
        roomId.text = [NSString generateRandomRoomNumber];
    }
}

- (void)setupSubCloud {
    _subCloudHelperArr = [[NSMutableArray alloc] init];
    
    for (NSInteger index = 0; index < maxRoom; index++) {
        SubCloudHelper *subCloudHelper = [[SubCloudHelper alloc]
                                         initWithSubId:index cloud: [self.trtcCloud createSubCloud]];
        [subCloudHelper setDelegate:self];
        [_subCloudHelperArr addObject:subCloudHelper];
    }
}

- (void)destroyTRTCCloud {
    [TRTCCloud destroySharedIntance];
    _trtcCloud = nil;
}

- (void)dealloc {
    for (SubCloudHelper *subCloud in _subCloudHelperArr) {
        [self.trtcCloud destroySubCloud: [subCloud getCloud]];
    }
    [self destroyTRTCCloud];
}

- (void)enterRoomWithSubId:(NSInteger)subId {
    TRTCParams *params = [TRTCParams new];
    params.sdkAppId = SDKAppID;
    
    UITextField* roomIdTextField = _roomIdArr[subId];
    params.roomId = [roomIdTextField.text intValue];
    params.userId = @"1345736";
    params.role = TRTCRoleAnchor;
    params.userSig = [GenerateTestUserSig genTestUserSig:params.userId];

    [[_subCloudHelperArr[subId] getCloud] enterRoom:params appScene:TRTCAppSceneLIVE];
}

- (void)exitRoomWithSubId:(NSInteger)subId {
    [[_subCloudHelperArr[subId] getCloud] exitRoom];
}

#pragma mark - IBActions

- (IBAction)onStartButtonAClick:(UIButton*)sender {
    sender.selected = !sender.selected;
    if ([sender isSelected]) {
        [self enterRoomWithSubId:0];
    } else {
        [self exitRoomWithSubId:0];
    }
}

- (IBAction)onStartButtonBClick:(UIButton*)sender {
    sender.selected = !sender.selected;
    if ([sender isSelected]) {
        [self enterRoomWithSubId:1];
    } else {
        [self exitRoomWithSubId:1];
    }
}

- (IBAction)onStartButtonCClick:(UIButton*)sender {
    sender.selected = !sender.selected;
    if ([sender isSelected]) {
        [self enterRoomWithSubId:2];
    } else {
        [self exitRoomWithSubId:2];
    }
}

- (IBAction)onStartButtonDClick:(UIButton*)sender {
    sender.selected = !sender.selected;
    if ([sender isSelected]) {
        [self enterRoomWithSubId:3];
    } else {
        [self exitRoomWithSubId:3];
    }
}

#pragma mark - TRTCCloud Delegate

- (void)onUserVideoAvailableWithSubId:(NSInteger)subId userId:(NSString *)userId available:(BOOL)available {
    if (available) {
        [[_subCloudHelperArr[subId] getCloud] startRemoteView:userId streamType:TRTCVideoStreamTypeSmall view:_remoteViewArr[subId]];
    } else {
        [[_subCloudHelperArr[subId] getCloud] stopRemoteView:userId streamType:TRTCVideoStreamTypeSmall];
    }
}

@end
