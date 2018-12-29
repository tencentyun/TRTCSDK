//
//  AppDelegate.h
//  TRTCDemo
//
//  Created by rushanting on 2018/12/21.
//  Copyright © 2018 rushanting. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TRTCSettingWindowController.h"
#import "TRTCCloud.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
- (void)showPreferenceWithTabIndex:(TXAVSettingTabIndex)index;
- (TRTCCloud*)getTRTCEngine;
- (void)closePreference;

@end

