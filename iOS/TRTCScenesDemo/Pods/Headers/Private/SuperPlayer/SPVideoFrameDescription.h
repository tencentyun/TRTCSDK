//
//  SPVideoFrameDescription.h
//  SuperPlayer
//
//  Created by cui on 2019/12/25.
//  Copyright © 2019 annidy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SPVideoFrameDescription : NSObject
// updates in SuperPlayerView
@property double where;
@property NSString *text;
@property double time;
+ (instancetype)instanceFromDictionary:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
