//
//  SuperPlayerUrl.h
//  SuperPlayer
//
//  Created by cui on 2019/12/25.
//  Copyright © 2019 annidy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 多码率地址
 * 用于有多个播放地址的多清晰度视频的播放
 */
@interface SuperPlayerUrl : NSObject
/// 播放器展示的对应标题，如“高清”、“低清”等
@property NSString *title;
/// 播放地址
@property NSString *url;
@end

NS_ASSUME_NONNULL_END
