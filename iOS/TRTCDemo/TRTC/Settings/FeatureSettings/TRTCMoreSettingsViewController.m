/*
* Module:   TRTCMoreSettingsViewController
*
* Function: 其它设置页
*
*    1. 其它设置项包括: 流控方案、双路编码开关、默认观看低清、重力感应和闪光灯切换
*
*    2. 发送自定义消息和SEI消息，两种消息的说明可参见TRTC的文档或TRTCCloud.h中的接口注释。
*
*/

#import "TRTCMoreSettingsViewController.h"

@interface TRTCMoreSettingsViewController ()

@end

@implementation TRTCMoreSettingsViewController

- (NSString *)title {
    return @"其它";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TRTCVideoConfig *config = self.settingsManager.videoConfig;
    __weak __typeof(self) wSelf = self;
    self.items = @[
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"流控方案"
                                                 items:@[@"客户端控", @"云端流控"]
                                         selectedIndex:config.qosConfig.controlMode
                                                action:^(NSInteger index) {
            [wSelf onSelectQosControlModeIndex:index];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"开启双路编码"
                                                 isOn:config.isSmallVideoEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableSmallVideo:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"默认观看低清"
                                                 isOn:config.prefersLowQuality
                                               action:^(BOOL isOn) {
            [wSelf onEnablePrefersLowQuality:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"开启重力感应"
                                                 isOn:config.isGSensorEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableGSensor:isOn];
        }],
        [[TRTCSettingsButtonItem alloc] initWithTitle:@"切换闪光灯" buttonTitle:@"切换" action:^{
            [wSelf onToggleTorchLight];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"开启自动对焦"
                                                 isOn:config.isAutoFocusOn
                                               action:^(BOOL isOn) {
            [wSelf onEnableAutoFocus:isOn];
        }],
        [[TRTCSettingsMessageItem alloc] initWithTitle:@"自定义消息" placeHolder:@"测试消息" action:^(NSString *message) {
            [wSelf sendMessage:message];
        }],
        [[TRTCSettingsMessageItem alloc] initWithTitle:@"SEI消息" placeHolder:@"测试SEI消息" action:^(NSString *message) {
            [wSelf sendSeiMessage:message];
        }],
    ];
}

#pragma mark - Actions

- (void)onSelectQosControlModeIndex:(NSInteger)index {
    [self.settingsManager setQosControlMode:index];
}

- (void)onEnableSmallVideo:(BOOL)isOn {
    [self.settingsManager setSmallVideoEnabled:isOn];
}

- (void)onEnablePrefersLowQuality:(BOOL)isOn {
    [self.settingsManager setPrefersLowQuality:isOn];
}

- (void)onEnableGSensor:(BOOL)isOn {
    [self.settingsManager setGSensorEnabled:isOn];
}

- (void)onEnableAutoFocus:(BOOL)isOn {
    [self.settingsManager setAutoFocusEnabled:isOn];
}

- (void)onToggleTorchLight {
    [self.settingsManager switchTorch];
}

- (void)sendMessage:(NSString *)message {
    [self.settingsManager sendCustomMessage:message];
}

- (void)sendSeiMessage:(NSString *)message {
    [self.settingsManager sendSEIMessage:message repeatCount:1];
}

@end
