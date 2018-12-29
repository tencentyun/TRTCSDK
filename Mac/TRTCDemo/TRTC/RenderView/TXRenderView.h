//
//  TXRenderView.h
//  TXLiteAVMacDemo
//
//  Created by cui on 2018/12/3.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface TXRenderView : NSView
- (void)addToolbarItem:(NSString *)title target:(id)target action:(SEL)action context:(id)context;
@end

NS_ASSUME_NONNULL_END
