//
//  StrUtils.h
//  Pods
//
//  Created by annidyfeng on 2018/9/28.
//

#import <Foundation/Foundation.h>

@interface StrUtils : NSObject

+ (NSString *)timeFormat:(NSInteger)totalTime;
@end

extern NSString *kStrLoadFaildRetry;
extern NSString *kStrBadNetRetry;
extern NSString *kStrTimeShiftFailed;
extern NSString *kStrHDSwitchFailed;
extern NSString *kStrWeakNet;
