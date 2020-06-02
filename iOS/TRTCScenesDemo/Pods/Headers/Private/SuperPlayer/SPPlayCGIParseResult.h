//
//  SPPlayCGIParseResult.h
//  SuperPlayer
//
//  Created by cui on 2019/12/25.
//  Copyright © 2019 annidy. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SPResolutionDefination.h"
#import "SPSubStreamInfo.h"
#import "AdaptiveStream.h"
#import "SuperPlayerSprite.h"
#import "SPVideoFrameDescription.h"
#import "SuperPlayerUrl.h"

@class TXImageSprite;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SPDrmType) {
    SPDrmTypeNone,
    SPDrmTypeSimpleAES
};

@interface SPPlayCGIParseResult : NSObject
/// 视频播放url
@property (strong, nonatomic) NSString *url;
/// 视频名称
@property (strong, nonatomic) NSString *name;
/// 雪略图对象
@property (strong, nonatomic) TXImageSprite *imageSprite;
/// 雪略图打点帧信息
@property (strong, nonatomic) NSArray<SPVideoFrameDescription *> *keyFrameDescList;
/// 字流画质信息
@property (strong, nonatomic) NSArray<SPSubStreamInfo *> *resolutionArray;
/// 原视频时长
@property (assign, nonatomic) NSTimeInterval originalDuration;

/// 预留字段，暂不使用
@property (strong, nonatomic) NSArray<AdaptiveStream *> *adaptiveStreamArray;

/// V2协议的多码率URL列表
@property (strong, nonatomic) NSArray<SuperPlayerUrl *> *multiVideoURLs;

/// 加密类型，用于 Drm
@property (assign, nonatomic) SPDrmType drmType;

/// 加密令牌，用于 Drm
@property (copy, nonatomic) NSString *drmToken;
+ (SPDrmType)drmTypeFromString:(NSString *)typeString;
/**
 * 获取画质信息
 *
 * @return 画质信息数组

List<TCVideoQuality> getVideoQualityList();


 * 获取默认画质信息
 *
 * @return 默认画质信息对象

TCVideoQuality getDefaultVideoQuality();
 */

@end

NS_ASSUME_NONNULL_END
