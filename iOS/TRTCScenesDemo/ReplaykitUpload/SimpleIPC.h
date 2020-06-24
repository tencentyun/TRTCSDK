//
//  SimpleIPC.h
//  TXLiteAVDemo
//
//  Created by cui on 2020/4/21.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SimpleIPC : NSObject
- (instancetype)initWithPort:(int)port;
- (void)startListenWithHandler:(void(^)(NSString *cmd, NSDictionary *info))handler;
- (void)sendCmd:(NSString*)cmd info:(NSDictionary *)info;
@end

NS_ASSUME_NONNULL_END
