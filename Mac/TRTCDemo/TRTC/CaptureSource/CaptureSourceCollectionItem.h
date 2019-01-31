//
//  CaptureSourceCollectionItem.h
//  TXLiteAVMacDemo
//
//  Created by shengcui on 2018/10/24.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface CaptureSourceCollectionItem : NSCollectionViewItem
@property (strong, nonatomic, readonly) NSImage *image;
@property (strong, nonatomic, readonly) NSImage *icon;
@property (strong, nonatomic) TRTCScreenCaptureSourceInfo *source;
@end

NS_ASSUME_NONNULL_END
