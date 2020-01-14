//
//  TRTCStreamConfig.h
//  TXLiteAVDemo
//
//  Created by LiuXiaoya on 2019/12/9.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TRTCStreamConfig : NSObject

/// 开启云端混流，默认为NO，设置会保存到本地。
@property (nonatomic) BOOL isMixingInCloud;

@end

NS_ASSUME_NONNULL_END
