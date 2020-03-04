//
//  SEIMessageModel.h
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/28.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SEIMessageModel : NSObject
@property (nonatomic,strong) NSMutableArray<UserModel *> *regions;
@end

NS_ASSUME_NONNULL_END
