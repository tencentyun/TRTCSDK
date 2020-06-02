//
//  SPSubStreamInfo.h
//  SuperPlayer
//
//  Created by Steven Choi on 2020/2/11.
//  Copyright © 2020 annidy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

/// 自适应码流子流信息
@interface SPSubStreamInfo : NSObject
@property (assign, nonatomic) CGSize    size;
@property (copy, nonatomic)   NSString *resolutionName;
@property (copy, nonatomic)   NSString *type;
+ (instancetype)infoWithDictionary:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
