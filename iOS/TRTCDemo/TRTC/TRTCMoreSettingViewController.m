//
//  TRTCMoreSettingViewController.m
//  TXLiteAVDemo
//
//  Created by rushanting on 2019/3/6.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TRTCMoreSettingViewController.h"
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
#define CELL_AUDIO_CAPTURE           2
#define CELL_AUDIO_ROUTE             3
#define CELL_GSENSOR                 4
#define CELL_AUDIO_VOLUME            5
#define CELL_VIDEO_MIXING            6
#define CELL_SHARE_PLAYURL           7
#define CELL_PK                      8

#define TAG_CAMERA_SWITCH            1000
#define TAG_FILL_MODE                1001
#define TAG_AUDIO_CAPTURE            1002
#define TAG_AUDIO_ROUTE              1003
#define TAG_GSENSOR                  1004
#define TAG_AUDIO_VOLUME             1005
#define TAG_VIDEO_MIXING             1006
#define TAG_SHARE_PLAYURL            1007
#define TAG_PK                       1008

@interface TRTCMoreSettingViewController ()
@property (nonatomic, retain) TRTCCloud* trtcEngine;
@property (nonatomic, copy) NSString* roomId;
@property (nonatomic, copy) NSString* userId;
@end

@implementation TRTCMoreSettingViewController {
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
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.3];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.contentInset = UIEdgeInsetsMake(30, 0, 0, 30);
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
    return 9;
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
        }
            break;
        case CELL_FILL_MODE: {
            cell.textLabel.text = @"画面填充模式";
            UISegmentedControl* fillModeSeg = [[UISegmentedControl alloc] initWithItems:@[@"填充", @"适应"]];
            fillModeSeg.bounds = CGRectMake(0, 0, self.view.width * 0.3, fillModeSeg.height);
            fillModeSeg.tag = TAG_FILL_MODE;
            [fillModeSeg addTarget:self action:@selector(onSegmentTap:) forControlEvents:UIControlEventValueChanged];
            [fillModeSeg setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.whiteColor} forState:UIControlStateSelected];

            cell.accessoryView = fillModeSeg;
            fillModeSeg.selectedSegmentIndex = [[self class] getSettingWithKey:SETTING_FILL_MODE].integerValue;
        }
            break;
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
            [_trtcEngine enableAudioVolumeEvaluation:300 smooth:5];
        }
        else {
            [_trtcEngine enableAudioVolumeEvaluation:0 smooth:5];
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
        __weak TRTCMoreSettingViewController* weakSelf = self;
        [pkInputVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
            [button setTitle:@"结束" forState:UIControlStateNormal];

        }]];
        [self presentViewController:pkInputVC animated:YES completion:nil];
        
    }
}

@end
