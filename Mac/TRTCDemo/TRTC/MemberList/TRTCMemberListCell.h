//
//  TRTCMemberListCell.h
//  TXLiteAVMacDemo
//
//  Created by Xiaoya Liu on 2020/2/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class TRTCUserConfig;
@class TRTCUserManager;

@interface TRTCMemberListCell : NSTableCellView

@property (nonatomic, strong, nullable) TRTCUserConfig *user;
@property (nonatomic, weak, nullable) TRTCUserManager *userManager;

@end

NS_ASSUME_NONNULL_END
