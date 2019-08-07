//
//  AppDelegate.m
//  TRTCDemo
//
//  Created by rushanting on 2018/12/21.
//  Copyright © 2018 rushanting. All rights reserved.
//

#import "AppDelegate.h"
#import "TRTCApp.h"

@interface AppDelegate ()
{
    TRTCApp* _trtcApp;
}
@end

@implementation AppDelegate
- (void)awakeFromNib {
    _trtcApp = [[TRTCApp alloc] init];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [_trtcApp start];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (!flag) {
        [_trtcApp awake];
    }
    return YES;
}

- (IBAction)onPreference:(id)sender {
    [_trtcApp showPreference];
}

@end
