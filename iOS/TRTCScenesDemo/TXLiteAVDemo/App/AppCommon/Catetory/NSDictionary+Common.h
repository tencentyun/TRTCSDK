//
//  NSDictionary+Common.h
//  TXLiteAVDemo_Smart_No_VOD
//
//  Created by lijie on 2019/10/7.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Common)

- (NSInteger)integerForKey:(id)key;
- (NSString *)stringForKey:(id)key;
- (BOOL)boolForKey:(id)key;
- (float)floatForKey:(id)key;

@end

NS_ASSUME_NONNULL_END
