//
//  TRTCMemberListView.h
//  TXLiteAVMacDemo
//
//  Created by Xiaoya Liu on 2020/2/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class TRTCUserManager;

@interface TRTCMemberListView : NSView

- (void)observeUserManager:(TRTCUserManager *)userManager;

@end

NS_ASSUME_NONNULL_END
