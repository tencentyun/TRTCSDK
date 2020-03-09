//
//  TRTCVideoListView.h
//  TXLiteAVMacDemo
//
//  Created by Xiaoya Liu on 2020/2/25.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TRTCUserManager.h"

NS_ASSUME_NONNULL_BEGIN

@class TRTCVideoListView;

@protocol TRTCVideoListViewDelegate <NSObject>

- (void)videoListView:(TRTCVideoListView *)videoListView onSelectUser:(TRTCUserConfig *)user;

@end

@interface TRTCVideoListView : NSScrollView

@property (nonatomic, readonly) CGFloat tableHeight;

@property (nonatomic, weak) id<TRTCVideoListViewDelegate> delegate;
@property (nonatomic, strong, nullable) TRTCUserConfig *mainUser;

- (void)observeUserManager:(TRTCUserManager *)userManager;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
