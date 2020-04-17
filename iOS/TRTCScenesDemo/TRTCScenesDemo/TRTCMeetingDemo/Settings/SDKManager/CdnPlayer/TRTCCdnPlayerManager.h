/*
* Module:   TRTCCdnPlayerManager
*
* Function: CDN播放控制
*
*    1. 开始，暂停CDN播放
*
*    2. 控制播放画面的朝向、填充模式，以及是否显示Debug Log
*
*    3. 设置缓冲方式
*
*/

#import <Foundation/Foundation.h>
#import "TXLivePlayer.h"
#import "TRTCCdnPlayerConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCCdnPlayerManager : NSObject

@property (strong, nonatomic, readonly) TXLivePlayer *player;
@property (strong, nonatomic, readonly) TRTCCdnPlayerConfig *config;

- (instancetype)initWithContainerView:(UIView *)view delegate:(id<TXLivePlayListener>)delegate NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// 开始播放
/// @param url 主播的推流地址
- (void)startPlay:(NSString *)url;

/// 停止播放
- (void)stopPlay;

/// 正在播放
- (BOOL)isPlaying;

#pragma mark - Config

/// 设置是否显示Debug Log
/// @param isEnabled 显示Debug Log
- (void)setDebugLogEnabled:(BOOL)isEnabled;

/// 设置画面朝向
/// @param orientation 画面朝向
- (void)setOrientation:(TX_Enum_Type_HomeOrientation)orientation;

/// 设置画面填充方式
/// @param renderMode 画面填充方式
- (void)setRenderMode:(TX_Enum_Type_RenderMode)renderMode;

/// 设置CDN缓冲方式
/// @param cacheType CDN缓冲方式
- (void)setCacheType:(TRTCCdnPlayerCacheType)cacheType;

@end

NS_ASSUME_NONNULL_END
