//
//  SuperPlayerModelInternal.h
//  SuperPlayer
//
//  Created by Steven Choi on 2020/2/12.
//  Copyright © 2020 annidy. All rights reserved.
//

#import "SuperPlayerModel.h"
#import "AFNetworking/AFNetworking.h"
#import "SPVideoFrameDescription.h"

@class TXImageSprite;

NS_ASSUME_NONNULL_BEGIN

@interface SuperPlayerModel()
/// 播放配置, 为 nil 时为 "default"
@property (copy, nonatomic) NSString *pcfg;

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
// 以下为 PlayCGI V4 协议解析结果

/// 正在播放的清晰度
@property (nonatomic) NSString *playingDefinition;

/// 正在播放的清晰度URL
@property (readonly) NSString *playingDefinitionUrl;

/// 正在播放的清晰度索引
@property (readonly) NSInteger playingDefinitionIndex;

/// 清晰度列表
@property (readonly) NSArray *playDefinitions;

/// 打点信息
@property (strong, nonatomic) NSArray<SPVideoFrameDescription *> *keyFrameDescList;

/// 视频雪碧图
@property  (strong, nonatomic) TXImageSprite *imageSprite;

/// 视频原时长（用于试看时返回完整视频时长）
@property  (assign, nonatomic) NSTimeInterval originalDuration;

/// 加载播放信息
- (NSURLSessionTask *)requestWithCompletion:
        (void(^)(NSError *err, SuperPlayerModel *model))completion;

/// DRM Token
@property (strong, nonatomic) NSString *drmToken;

@end

NS_ASSUME_NONNULL_END
