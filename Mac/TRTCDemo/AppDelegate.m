//
//  AppDelegate.m
//  TRTCDemo
//
//  Created by rushanting on 2018/12/21.
//  Copyright © 2018 rushanting. All rights reserved.
//

#import "AppDelegate.h"
#import "TRTCNewWindowController.h"
#import "TRTCSettingWindowController.h"

@interface AppDelegate ()
{
    TRTCNewWindowController *_loginWindowController;
    TRTCSettingWindowController *_settingWindowController;
    TRTCCloud* _trtcEngine;
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWindowClose:) name:NSWindowWillCloseNotification object:nil];
    _loginWindowController = [[TRTCNewWindowController alloc] initWithWindowNibName:NSStringFromClass([TRTCNewWindowController class])];
    [_loginWindowController showWindow:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (!flag) {
        [self showLoginWindow];
    }
    return YES;
}

- (IBAction)onPreference:(id)sender {
    [self showPreferenceWithTabIndex:TXAVSettingTabIndexVideo];
}

- (void)showPreferenceWithTabIndex:(TXAVSettingTabIndex)index
{
    if (nil ==_settingWindowController) {
        _settingWindowController = [[TRTCSettingWindowController alloc] initWithWindowNibName:@"TRTCSettingWindowController" engine:[self getTRTCEngine]];
    }
    _settingWindowController.tabIndex = index;
    [_settingWindowController showWindow:self];
}

- (void)closePreference{
    [_settingWindowController close];
    _settingWindowController = nil;
}

- (void)onWindowClose:(NSNotification *)notification {
    if ([[notification.object nextResponder] isKindOfClass:[TRTCMainWindowController class]]) {
        _trtcEngine = nil;
        [self showLoginWindow];
    }
}

- (void)showLoginWindow {
    [_loginWindowController showWindow:nil];
}

// Menu Actions
//- (IBAction)onShowCameraWindow:(id)sender {
//    if (_cameraPreviewController == nil) {
//        _cameraPreviewController = [[TXCameraPreviewWindowController alloc] initWithWindowNibName:@"TXCameraPreviewWindowController"];
//    }
//    [_cameraPreviewController showWindow:nil];
//}

- (TRTCCloud*)getTRTCEngine
{
    if (!_trtcEngine) {
        _trtcEngine = [TRTCCloud new];
    }
    
    return _trtcEngine;
}


@end
