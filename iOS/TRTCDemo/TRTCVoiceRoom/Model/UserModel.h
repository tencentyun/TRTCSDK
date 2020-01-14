//
//  UserModel.h
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/28.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserModel : NSObject
- (id)initWithUid:(NSString *)uid volume:(int)volume;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic) int volume;
@end

NS_ASSUME_NONNULL_END
