/*
* Module:   TRTCCdnPlayerConfig
*
* Function: 保存CDN播放的控制项
*
*    1. 对象不会保存在本地
*
*/

#import "TRTCCdnPlayerConfig.h"

@implementation TRTCCdnPlayerConfig

- (instancetype)init {
    if (self = [super init]) {
        self.orientation = HOME_ORIENTATION_DOWN;
        self.renderMode = RENDER_MODE_FILL_EDGE;
        self.cacheType = TRTCCdnPlayerCacheTypeAuto;
    }
    return self;
}

@end
