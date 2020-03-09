//
//  TRTCVideoCell.h
//  TXLiteAVMacDemo
//
//  Created by Xiaoya Liu on 2020/2/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class TXRenderView;

@interface TRTCVideoCell : NSTableCellView

- (void)configWithUserId:(NSString *)userId renderView:(TXRenderView * _Nullable)renderView;

@end

NS_ASSUME_NONNULL_END
