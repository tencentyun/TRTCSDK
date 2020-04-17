/*
* Module:   TRTCCdnPlayerConfig
*
* Function: 保存CDN播放的控制项
*
*    1. 对象不会保存在本地
*
*/

#import <Foundation/Foundation.h>
#import "TXLivePlayer.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TRTCCdnPlayerCacheType) {
    TRTCCdnPlayerCacheTypeFast,
    TRTCCdnPlayerCacheTypeSmooth,
    TRTCCdnPlayerCacheTypeAuto,
};

@interface TRTCCdnPlayerConfig : NSObject

/// 日志开关
@property (nonatomic) BOOL isDebugOn;

/// 画面朝向，默认为竖屏
@property (nonatomic) TX_Enum_Type_HomeOrientation orientation;

/// 画面填充方式，默认为RENDER_MODE_FILL_EDGE，即图像适应屏幕
@property (nonatomic) TX_Enum_Type_RenderMode renderMode;

/// 设置CDN缓冲方式
@property (nonatomic) TRTCCdnPlayerCacheType cacheType;

@end

NS_ASSUME_NONNULL_END
