//
//  TRTCApp.m
//  TXLiteAVMacDemo
//
//  Created by cui on 2019/3/7.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TRTCApp.h"
#import "SDKHeader.h"
#import "TRTCNewWindowController.h"
#import "TRTCMainWindowController.h"
#import "TRTCSettingWindowController.h"

static NSString * const SDKAppID = @"";
static NSString * const ConfigFile = @"config";

@interface TRTCApp ()
@property (strong, nonatomic) TRTCSettingWindowController *settingsWindowController;
@property (strong, nonatomic) TRTCMainWindowController *mainWindowController;
@property (strong, nonatomic) TRTCNewWindowController *loginWindowController;
@end

@implementation TRTCApp
{
    TRTCCloud *_engine;
    NSString *_roomID;
    NSString *_userID;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _engine = [TRTCCloud sharedInstance];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWindowWillClose:) name:NSWindowWillCloseNotification object:nil];
        self.settingsWindowController = [[TRTCSettingWindowController alloc] initWithWindowNibName:NSStringFromClass(TRTCSettingWindowController.class) engine:_engine];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TRTCCloud destroySharedIntance];
}

- (void)start
{
    if (!self.loginWindowController) {
        self.loginWindowController = [[TRTCNewWindowController alloc] initWithWindowNibName:NSStringFromClass([TRTCNewWindowController class])];
        __weak TRTCApp *wself = self;
        self.loginWindowController.onLogin = ^(TRTCParams *param) {
            [wself enterRoom:param audioOnly:wself.loginWindowController.audioOnly];
        };
    }
    [self.loginWindowController showWindow:nil];
}

- (void)stop
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_mainWindowController close];
    [_loginWindowController close];
    [_settingsWindowController close];
    if (self.onQuit) {
        self.onQuit();
    }
}

- (void)awake {
    if (_mainWindowController) {
        [_mainWindowController.window orderFront:nil];
    } else {
        [_loginWindowController.window orderFront:nil];
    }
}

- (void)showPreference {
    if (nil ==_settingsWindowController) {
        _settingsWindowController = [[TRTCSettingWindowController alloc] initWithWindowNibName:@"TRTCSettingWindowController" engine:_engine];
        _settingsWindowController.roomID = _roomID;
        _settingsWindowController.userID = _userID;
    }
    [_settingsWindowController showWindow:self];
}

- (void)showPreferenceWithTabIndex:(TXAVSettingTabIndex)index
{
    [self showPreference];
    _settingsWindowController.tabIndex = index;
}

- (void)enterRoom:(TRTCParams *)params audioOnly:(BOOL)audioOnly {
    if (_mainWindowController) {
        [_mainWindowController close];
    }
    _userID = params.userId;
    _roomID = @(params.roomId).stringValue;
    _settingsWindowController.roomID = _roomID;
    _settingsWindowController.userID = _userID;

    _mainWindowController = [[TRTCMainWindowController alloc] initWithEngine:_engine params:params scene:TRTCSettingWindowController.scene audioOnly:audioOnly];
    [_mainWindowController.window orderFront:nil];
    __weak TRTCApp *wself = self;
    _mainWindowController.onAudioSettingsButton = ^{
        [wself showPreferenceWithTabIndex:TXAVSettingTabIndexAudio];
    };
    _mainWindowController.onVideoSettingsButton = ^{
        [wself showPreferenceWithTabIndex:TXAVSettingTabIndexVideo];
    };
    [self.loginWindowController close];
}

- (void)onWindowWillClose:(NSNotification *)notification {
    if (notification.object == _mainWindowController.window) {
        _userID = nil;
        _roomID = nil;
        _settingsWindowController.roomID = nil;
        _settingsWindowController.userID = nil;
        [self start];
        self.mainWindowController = nil;
    } else if (notification.object == _loginWindowController.window && _mainWindowController == nil) {
        if (self.onQuit) {
            self.onQuit();
        }
    }
}

- (void)updateTranscodingConfig:(TRTCTranscodingConfig *)config {
    if (config == nil) {
        [_engine setMixTranscodingConfig:config];
    }
}

@end
