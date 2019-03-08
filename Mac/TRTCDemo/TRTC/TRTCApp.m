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

@interface TRTCApp ()
@property (strong, nonatomic) TRTCSettingWindowController *settingsWindowController;
@property (strong, nonatomic) TRTCMainWindowController *mainWindowController;
@property (strong, nonatomic) TRTCNewWindowController *loginWindowController;
@end

@implementation TRTCApp
{
    TRTCCloud *_engine;
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
            [wself enterRoom:param];
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
    self.onQuit();
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
        _settingsWindowController = [[TRTCSettingWindowController alloc] initWithWindowNibName:NSStringFromClass([TRTCSettingWindowController class]) engine:_engine];
    }
    [_settingsWindowController showWindow:self];
}

- (void)showPreferenceWithTabIndex:(TXAVSettingTabIndex)index
{
    [self showPreference];
    _settingsWindowController.tabIndex = index;
}

- (void)enterRoom:(TRTCParams *)params {
    if (_mainWindowController) {
        [_mainWindowController close];
    }
    _mainWindowController = [[TRTCMainWindowController alloc] initWithEngine:_engine params:params scene:TRTCSettingWindowController.scene];
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
