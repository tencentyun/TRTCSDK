//
//  NSDictionary+Common.m
//  TXLiteAVDemo_Smart_No_VOD
//
//  Created by lijie on 2019/10/7.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "NSDictionary+Common.h"

@implementation NSDictionary (Common)

- (NSInteger)integerForKey:(id)key {
    return [[self objectForKey:key] integerValue];
}

- (NSString *)stringForKey:(id)key {
    return [self objectForKey:key];
}

- (BOOL)boolForKey:(id)key {
    return [[self objectForKey:key] boolValue];
}

- (float)floatForKey:(id)key {
    return [[self objectForKey:key] floatValue];
}

@end
