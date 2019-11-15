//
//  Header.h
//  TXLiteAVDemo_Enterprise
//
//  Created by xiang zhang on 2017/11/21.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#ifndef PituMotionManager_h
#define PituMotionManager_h

#import <Foundation/Foundation.h>
@interface PituMotion : NSObject
@property (readonly, nonatomic) NSString *identifier;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSURL *url;
- (instancetype)initWithId:(NSString *)identifier name:(NSString *)name url:(NSString *)address;
@end

@interface PituMotionManager : NSObject
@property (readonly, nonatomic) NSArray<PituMotion *> * motionPasters;
@property (readonly, nonatomic) NSArray<PituMotion *> * cosmeticPasters;
@property (readonly, nonatomic) NSArray<PituMotion *> * gesturePasters;
@property (readonly, nonatomic) NSArray<PituMotion *> * backgroundRemovalPasters;

+ (instancetype)sharedInstance;
- (PituMotion *)motionWithIdentifier:(NSString *)identifier;
@end

#endif /* Header_h */
