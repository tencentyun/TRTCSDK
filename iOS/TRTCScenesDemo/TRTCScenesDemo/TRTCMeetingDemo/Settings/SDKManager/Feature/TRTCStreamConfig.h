//
//  TRTCStreamConfig.h
//  TXLiteAVDemo
//
//  Created by LiuXiaoya on 2019/12/9.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRTCCloudDef.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCStreamConfig : NSObject

/// 云端混流模式，默认为Unknown，设置会保存到本地。
@property (nonatomic) TRTCTranscodingConfigMode mixMode;

@end

NS_ASSUME_NONNULL_END
