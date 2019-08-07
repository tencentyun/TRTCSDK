//
//  TRTCMoreSettingViewController.m
//  TXLiteAVDemo
//
//  Created by rushanting on 2019/3/6.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TRTCMoreViewController.h"
#import "UIView+Additions.h"
#import "NSString+Common.h"

#define SETTING_CAMERA               @"MORE_SETTING_CAMERA"
#define SETTING_FILL_MODE            @"MORE_SETTING_FILL_MODE"
#define SETTING_AUDIO_CAPTURE        @"MORE_SETTING_AUDIO_CAPTURE"
#define SETTING_AUDIO_ROUTE          @"MORE_SETTING_AUDIO_ROYTE"
#define SETTING_GSENSOR              @"MORE_SETTING_GSENSOR"
#define SETTING_AUDIO_VOLUME         @"MORE_SETTING_AUDIO_VOLUME"
#define SETTING_VIDEO_MIXING         @"MORE_SETTING_VIDEO_MIXING"


#define CELL_CAMERA_SWITCH           0
#define CELL_FILL_MODE               1
#define CELL_LOCAL_MIRROR            2
#define CELL_REMOTE_MIRROR           3
#define CELL_AUDIO_CAPTURE           4
#define CELL_AUDIO_ROUTE             5
#define CELL_GSENSOR                 6
#define CELL_AUDIO_VOLUME            7
#define CELL_VIDEO_MIXING            8
#define CELL_SHARE_PLAYURL           9
#define CELL_PK                      10
#define CELL_AUDIO_RECORDING         11

#define TAG_CAMERA_SWITCH            1000
#define TAG_FILL_MODE                1001
#define TAG_AUDIO_CAPTURE            1002
#define TAG_AUDIO_ROUTE              1003
#define TAG_GSENSOR                  1004
#define TAG_AUDIO_VOLUME             1005
#define TAG_VIDEO_MIXING             1006
#define TAG_SHARE_PLAYURL            1007
#define TAG_PK                       1008
#define TAG_LOCAL_MIRROR             1009
#define TAG_REMOTE_MIRROR            1010
#define TAG_AUDIO_RECORDING          1011
#define TAG_AUDIO_PLAY_BUTTON        1012

static NSString * const RecordFileNameKey = @"TRTC_RecordFilename";

@interface TRTCMoreViewController ()
@property (nonatomic, retain) TRTCCloud* trtcEngine;
@property (nonatomic, copy) NSString* roomId;
@property (nonatomic, copy) NSString* userId;
@property (nonatomic, retain) NSMutableDictionary* pkInfos;
@end

@implementation TRTCMoreViewController {
    UISegmentedControl* _cameraSegment;
}


+ (BOOL)isFrontCamera
{
    return [[self class] getSettingWithKey:SETTING_CAMERA].boolValue;
}

+ (BOOL)isFitScaleMode
{
    return [[self class] getSettingWithKey:SETTING_FILL_MODE].boolValue;
}

+ (BOOL)isAudioCaptureEnable
{
    return [[self class] getSettingWithKey:SETTING_AUDIO_CAPTURE].boolValue;
}

+ (BOOL)isSpeakphoneMode
{
    return [[self class] getSettingWithKey:SETTING_AUDIO_ROUTE].boolValue;
}

+ (BOOL)isGsensorEnable
{
    return [[self class] getSettingWithKey:SETTING_GSENSOR].boolValue;
}

+ (BOOL)isAudioVolumeEnable
{
    return [[self class] getSettingWithKey:SETTING_AUDIO_VOLUME].boolValue;
}

+ (BOOL)isCloudMixingEnable
{
    return [[self class] getSettingWithKey:SETTING_VIDEO_MIXING].boolValue;
}

- (instancetype)initWithTRTCEngine:(TRTCCloud *)engine roomId:(nonnull NSString *)roomId userId:(nonnull NSString *)userId
{
    if (self = [super init]) {
        _trtcEngine = engine;
        _roomId = roomId;
        _userId = userId;
        _pkInfos = [NSMutableDictionary new];
    }
    
    return self;
}

- (NSMutableDictionary*)getPKInfo
{
    return self.pkInfos;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.3];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.contentInset = UIEdgeInsetsMake(30, 0, 30, 0);
    self.tableView.bounces = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
}


+ (NSNumber*)getSettingWithKey:(NSString*)key
{
    NSUserDefaults* db = [NSUserDefaults standardUserDefaults];
    NSNumber* value = (NSNumber*)[db objectForKey:key];
    if (!value) {
        value = @(1);
        if ([key isEqualToString:SETTING_VIDEO_MIXING] || [key isEqualToString:SETTING_FILL_MODE]) {
            value = @(0);
        }
    }
    
    return value;
}

+ (void)setSettingValue:(NSNumber*)value key:(NSString*)key
{
    NSUserDefaults* db = [NSUserDefaults standardUserDefaults];
    [db setObject:value forKey:key];
    [db synchronize];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 13;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, self.tableView.height / 9)];
    cell.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case CELL_CAMERA_SWITCH: {
            cell.textLabel.text = @"前后镜头切换";
            _cameraSegment = [[UISegmentedControl alloc] initWithItems:@[@"前置", @"后置"]];
            _cameraSegment.bounds = CGRectMake(0, 0, self.view.width * 0.3, _cameraSegment.height);
            _cameraSegment.tag = TAG_CAMERA_SWITCH;
            [_cameraSegment addTarget:self action:@selector(onSegmentTap:) forControlEvents:UIControlEventValueChanged];
            [_cameraSegment setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.whiteColor} forState:UIControlStateSelected];
            
            cell.accessoryView = _cameraSegment;
            _cameraSegment.selectedSegmentIndex = [[self class] getSettingWithKey:SETTING_CAMERA].integerValue ? 0 : 1;
            break;
        }
        case CELL_FILL_MODE: {
            cell.textLabel.text = @"画面填充模式";
            UISegmentedControl* fillModeSeg = [[UISegmentedControl alloc] initWithItems:@[@"填充", @"适应"]];
            fillModeSeg.bounds = CGRectMake(0, 0, self.view.width * 0.3, fillModeSeg.height);
            fillModeSeg.tag = TAG_FILL_MODE;
            [fillModeSeg addTarget:self action:@selector(onSegmentTap:) forControlEvents:UIControlEventValueChanged];
            [fillModeSeg setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.whiteColor} forState:UIControlStateSelected];

            cell.accessoryView = fillModeSeg;
            fillModeSeg.selectedSegmentIndex = [[self class] getSettingWithKey:SETTING_FILL_MODE].integerValue;
            break;

        }
        case CELL_LOCAL_MIRROR: {
            cell.textLabel.text = @"本地镜像模式";
            UISegmentedControl* localMirrorSeg = [[UISegmentedControl alloc] initWithItems:@[@"自动", @"开启", @"关闭"]];
            localMirrorSeg.bounds = CGRectMake(0, 0, self.view.width * 0.3, localMirrorSeg.height);
            localMirrorSeg.tag = TAG_LOCAL_MIRROR;
            [localMirrorSeg addTarget:self action:@selector(onSegmentTap:) forControlEvents:UIControlEventValueChanged];
            [localMirrorSeg setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.whiteColor} forState:UIControlStateSelected];
            localMirrorSeg.selectedSegmentIndex = 0;
            cell.accessoryView = localMirrorSeg;
            break;

        }
        case CELL_REMOTE_MIRROR: {
            cell.textLabel.text = @"开启远程镜像";
            UISwitch*  remoteMirrorSwitch = [[UISwitch alloc] init];
            remoteMirrorSwitch.tag = TAG_REMOTE_MIRROR;
            [remoteMirrorSwitch addTarget:self action:@selector(onSwitchTap:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = remoteMirrorSwitch;
            remoteMirrorSwitch.tintColor = _cameraSegment.tintColor;
            remoteMirrorSwitch.onTintColor = _cameraSegment.tintColor;
            remoteMirrorSwitch.on = NO;
            break;
        }
        case CELL_AUDIO_CAPTURE: {
            cell.textLabel.text = @"开启声音采集";
            UISwitch*  audioCapSwitch = [[UISwitch alloc] init];
            audioCapSwitch.tag = TAG_AUDIO_CAPTURE;
            [audioCapSwitch addTarget:self action:@selector(onSwitchTap:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = audioCapSwitch;
            audioCapSwitch.tintColor = _cameraSegment.tintColor;
            audioCapSwitch.onTintColor = _cameraSegment.tintColor;
            audioCapSwitch.on = [[self class] getSettingWithKey:SETTING_AUDIO_CAPTURE].boolValue;
            break;
        }
        case CELL_AUDIO_ROUTE: {
            cell.textLabel.text = @"声音免提模式";
            UISwitch*  audioRouteSwitch = [[UISwitch alloc] init];
            audioRouteSwitch.tag = TAG_AUDIO_ROUTE;
            [audioRouteSwitch addTarget:self action:@selector(onSwitchTap:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = audioRouteSwitch;
            audioRouteSwitch.tintColor = _cameraSegment.tintColor;
            audioRouteSwitch.onTintColor = _cameraSegment.tintColor;
            audioRouteSwitch.on = [[self class] getSettingWithKey:SETTING_AUDIO_ROUTE].boolValue;
            break;
        }
        case CELL_GSENSOR: {
            cell.textLabel.text = @"开启重力感应";
            UISwitch*  gsensorSwitch = [[UISwitch alloc] init];
            gsensorSwitch.tag = TAG_GSENSOR;
            [gsensorSwitch addTarget:self action:@selector(onSwitchTap:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = gsensorSwitch;
            gsensorSwitch.tintColor = _cameraSegment.tintColor;
            gsensorSwitch.onTintColor = _cameraSegment.tintColor;
            gsensorSwitch.on = [[self class] getSettingWithKey:SETTING_GSENSOR].boolValue;
            break;
        }
        case CELL_AUDIO_VOLUME: {
            cell.textLabel.text = @"开启音量提示";
            UISwitch*  audioVolumeSwitch = [[UISwitch alloc] init];
            audioVolumeSwitch.tag = TAG_AUDIO_VOLUME;
            [audioVolumeSwitch addTarget:self action:@selector(onSwitchTap:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = audioVolumeSwitch;
            audioVolumeSwitch.tintColor = _cameraSegment.tintColor;
            audioVolumeSwitch.onTintColor = _cameraSegment.tintColor;
            audioVolumeSwitch.on = [[self class] getSettingWithKey:SETTING_AUDIO_VOLUME].boolValue;
            break;
        }
        case CELL_VIDEO_MIXING: {
            cell.textLabel.text = @"云端画面混合";
            UISwitch*  mixingSwitch = [[UISwitch alloc] init];
            mixingSwitch.tag = TAG_VIDEO_MIXING;
            [mixingSwitch addTarget:self action:@selector(onSwitchTap:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = mixingSwitch;
            mixingSwitch.tintColor = _cameraSegment.tintColor;
            mixingSwitch.onTintColor = _cameraSegment.tintColor;
            mixingSwitch.on = [[self class] getSettingWithKey:SETTING_VIDEO_MIXING].boolValue;
            break;
        }
        case CELL_SHARE_PLAYURL: {
            cell.textLabel.text = @"分享播放地址";
            UIButton* btnShare = [UIButton new];
            btnShare.bounds = CGRectMake(0, 0, 50, 30);
            btnShare.tag = TAG_SHARE_PLAYURL;
            btnShare.layer.cornerRadius = 5;
            btnShare.layer.shadowOffset =  CGSizeMake(1, 1);
            btnShare.layer.shadowOpacity = 0.8;
            btnShare.layer.shadowColor =  [UIColor whiteColor].CGColor;
            btnShare.backgroundColor = [_cameraSegment.tintColor colorWithAlphaComponent:0.6];
            [btnShare setTitle:@"分享" forState:UIControlStateNormal];
            btnShare.titleLabel.font = [UIFont systemFontOfSize:14];

            [btnShare addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = btnShare;
            break;
        }
        case CELL_PK: {
            cell.textLabel.text = @"请求跨房通话";
            UIButton* btnPK = [UIButton new];
            btnPK.bounds = CGRectMake(0, 0, 50, 30);
            btnPK.tag = TAG_PK;
            btnPK.layer.cornerRadius = 5;
            btnPK.layer.shadowOffset =  CGSizeMake(1, 1);
            btnPK.layer.shadowOpacity = 0.8;
            btnPK.layer.shadowColor =  [UIColor whiteColor].CGColor;
            btnPK.backgroundColor = [_cameraSegment.tintColor colorWithAlphaComponent:0.6];
            [btnPK setTitle:@"开始" forState:UIControlStateNormal];
            btnPK.titleLabel.font = [UIFont systemFontOfSize:14];
            [btnPK addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = btnPK;

            break;
        }
        case CELL_AUDIO_RECORDING:{
            cell.textLabel.text = @"开启音频录制";

            UISwitch*  audioCapSwitch = [[UISwitch alloc] init];
            audioCapSwitch.tag = TAG_AUDIO_RECORDING;
            [audioCapSwitch addTarget:self action:@selector(onSwitchTap:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = audioCapSwitch;
            audioCapSwitch.tintColor = _cameraSegment.tintColor;
            audioCapSwitch.onTintColor = _cameraSegment.tintColor;
            audioCapSwitch.on = NO;

            NSString *filename = [[NSUserDefaults standardUserDefaults] valueForKey:RecordFileNameKey];
            if (access(filename.UTF8String,F_OK) == 0) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.tag = TAG_AUDIO_PLAY_BUTTON;
                [button setTitle:@"分享播放文件" forState:UIControlStateNormal];
                [button sizeToFit];
                button.center = CGPointMake(CGRectGetMaxX(cell.contentView.bounds) - CGRectGetMidX(button.bounds) - 5, CGRectGetMidY(cell.contentView.frame));
                [cell.contentView addSubview:button];
                [button addTarget:self action:@selector(onShareRecordAudio:) forControlEvents:UIControlEventTouchUpInside];
            }

            break;
        }
        default:
            break;
    }
    cell.textLabel.textColor = UIColor.whiteColor;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    return cell;
}

- (void)onSegmentTap:(UISegmentedControl*)segment
{
    if (segment.tag == TAG_CAMERA_SWITCH) {
        BOOL index = segment.selectedSegmentIndex;
        [_trtcEngine switchCamera];
        [[self class] setSettingValue:@(!index) key:SETTING_CAMERA];
    }
    else if (segment.tag == TAG_FILL_MODE) {
        NSInteger idx = segment.selectedSegmentIndex;
        if (idx == 0) {
            [_trtcEngine setLocalViewFillMode:TRTCVideoFillMode_Fill];
        }
        else {
            [_trtcEngine setLocalViewFillMode:TRTCVideoFillMode_Fit];
        }
        [[self class] setSettingValue:@(idx) key:SETTING_FILL_MODE];
    }
    else if (segment.tag == TAG_LOCAL_MIRROR) {
        NSInteger idx = segment.selectedSegmentIndex;
        [_trtcEngine setLocalViewMirror:(TRTCLocalVideoMirrorType)idx];
    }
}

- (void)onSwitchTap:(UISwitch*)switchBtn
{
    if (switchBtn.tag == TAG_AUDIO_CAPTURE) {
        if (switchBtn.isOn) {
            [_trtcEngine startLocalAudio];
        }
        else {
            [_trtcEngine stopLocalAudio];
        }
        [[self class] setSettingValue:@(switchBtn.isOn) key:SETTING_AUDIO_CAPTURE];
    }
    else if (switchBtn.tag == TAG_REMOTE_MIRROR) {
        [_trtcEngine setVideoEncoderMirror:switchBtn.isOn];
    }
    else if (switchBtn.tag == TAG_AUDIO_ROUTE) {
        if (switchBtn.isOn) {
            [_trtcEngine setAudioRoute:TRTCAudioModeSpeakerphone];
        }
        else {
            [_trtcEngine setAudioRoute:TRTCAudioModeEarpiece];
        }
        [[self class] setSettingValue:@(switchBtn.isOn) key:SETTING_AUDIO_ROUTE];

    }
    else if (switchBtn.tag == TAG_GSENSOR) {
        if (switchBtn.isOn) {
            //如App支持自动旋转，请使用UIAutoLayout模式
            [_trtcEngine setGSensorMode:TRTCGSensorMode_UIFixLayout];
        }
        else {
            [_trtcEngine setGSensorMode:TRTCGSensorMode_Disable];
        }
        [[self class] setSettingValue:@(switchBtn.isOn) key:SETTING_GSENSOR];

    }
    else if (switchBtn.tag == TAG_AUDIO_VOLUME) {
        if (switchBtn.isOn) {
            [_trtcEngine enableAudioVolumeEvaluation:300];
        }
        else {
            [_trtcEngine enableAudioVolumeEvaluation:0];
        }
        [[self class] setSettingValue:@(switchBtn.isOn) key:SETTING_AUDIO_VOLUME];
        if ([self.delegate respondsToSelector:@selector(onAudioVolumeEnableChanged:)]) {
            [self.delegate onAudioVolumeEnableChanged:switchBtn.isOn];
        }

    }
    else if (switchBtn.tag == TAG_VIDEO_MIXING) {

        [[self class] setSettingValue:@(switchBtn.isOn) key:SETTING_VIDEO_MIXING];

        if ([self.delegate respondsToSelector:@selector(onCloudMixingEnable:)]) {
            [self.delegate onCloudMixingEnable:switchBtn.isOn];
        }
    }
    else if(switchBtn.tag == TAG_AUDIO_RECORDING){
        if (switchBtn.isOn) {
            NSString* docPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            docPath = [docPath stringByAppendingString:@"/"];
            NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval time=[date timeIntervalSince1970]*1000;
            NSString* filename = [NSString stringWithFormat:@"%.0f.aac", time];
            NSString* filePath = [docPath stringByAppendingString:filename];
            TRTCAudioRecordingParams* audioRecordingParams = [TRTCAudioRecordingParams new];
            audioRecordingParams.filePath = filePath;
            __weak TRTCCloud *cloud = _trtcEngine;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否播放测试背景音乐" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            void (^startRecord)(void) = ^{
                NSString *prev = [[NSUserDefaults standardUserDefaults] valueForKey: RecordFileNameKey];
                if (prev.length > 0) {
                    unlink(prev.UTF8String);
                }
                [[NSUserDefaults standardUserDefaults] setValue:filePath forKey:RecordFileNameKey];
                [cloud startAudioRecording:audioRecordingParams];
            };
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"播放" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSString *path = [[NSBundle mainBundle] pathForResource:@"record_test_background" ofType:@"mp3"];
                [cloud playBGM:path
                     withBeginNotify:^(NSInteger errCode) {
                         startRecord();
                     } withProgressNotify:^(NSInteger progressMS, NSInteger durationMS) {

                     } andCompleteNotify:^(NSInteger errCode) {

                     }];
            }];
            UIAlertAction *deny  = [UIAlertAction actionWithTitle:@"不播放" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                startRecord();
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                switchBtn.on = NO;
            }];
            [alertController addAction:confirm];
            [alertController addAction:deny];
            [alertController addAction:cancel];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else {
            [_trtcEngine stopBGM];
            [_trtcEngine stopAudioRecording];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否分享录音" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self onShareRecordAudio:nil];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:confirm];
            [alertController addAction:cancel];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (void)onBtnClick:(UIButton*)button
{
    if (button.tag == TAG_SHARE_PLAYURL) {
        NSString* md5streamId = [[NSString stringWithFormat:@"%@_%@_main", _roomId, _userId] md5];
        NSString* playUrl = [NSString stringWithFormat:@"http://3891.liveplay.myqcloud.com/live/3891_%@.flv", md5streamId];
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[playUrl] applicationActivities:nil];
        [self presentViewController:activityView animated:YES completion:^{
        }];
    }
    else if (button.tag == TAG_PK) {
        if ([button.titleLabel.text isEqualToString:@"结束"]) {
            [self.trtcEngine disconnectOtherRoom];
            [self.pkInfos removeAllObjects];
            [button setTitle:@"开始" forState:UIControlStateNormal];
            return;
        }
        UIAlertController* pkInputVC = [UIAlertController alertControllerWithTitle:@"PK输入" message:@"请输入相关信息" preferredStyle:UIAlertControllerStyleAlert];
        [pkInputVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"RoomId(必填)";
        }];
        [pkInputVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"userId(必填)";
        }];
        [pkInputVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"sign(选填)";
        }];
        [pkInputVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        __weak TRTCMoreViewController* weakSelf = self;
        [pkInputVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            TRTCMoreViewController* strongSelf = weakSelf;
            NSArray<UITextField*>* textFields = pkInputVC.textFields;
            NSString* roomIdStr = textFields[0].text;
            NSString* userIdStr = textFields[1].text;
            NSString* signStr = textFields[2].text;
            
            if (!roomIdStr.length || !userIdStr.length) {
                UIAlertController* tipVC = [UIAlertController alertControllerWithTitle:@"输入有误" message:@"请填写完整的roomId与userId值" preferredStyle:UIAlertControllerStyleAlert];
                [tipVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
                [pkInputVC presentViewController:tipVC animated:YES completion:nil];
                return;
            }
            //
            NSDictionary* pkParams = @{@"strRoomId":roomIdStr, @"userId":userIdStr, @"sign":signStr};
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:pkParams options:NSJSONWritingPrettyPrinted error:nil];
            NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [weakSelf.trtcEngine connectOtherRoom:jsonString];
            [weakSelf.pkInfos setObject:roomIdStr forKey:userIdStr];
            [button setTitle:@"结束" forState:UIControlStateNormal];

        }]];
        [self presentViewController:pkInputVC animated:YES completion:nil];
        
    }
}
- (void)onShareRecordAudio:(id)sender {
    NSString *filePath = [[NSUserDefaults standardUserDefaults] valueForKey: RecordFileNameKey];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
        [self presentViewController:activityView animated:YES completion:^{
    }];

}
@end
