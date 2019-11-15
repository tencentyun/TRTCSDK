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

#import "TRTCCdnPlayerManager.h"

@interface TRTCCdnPlayerManager()

@property (strong, nonatomic) TRTCCdnPlayerConfig *config;
@property (strong, nonatomic) TXLivePlayer *player;

@end

@implementation TRTCCdnPlayerManager

- (instancetype)initWithContainerView:(UIView *)view delegate:(id<TXLivePlayListener>)delegate {
    if (self = [super init]) {
        self.config = [[TRTCCdnPlayerConfig alloc] init];
        self.player = [[TXLivePlayer alloc] init];
        [self.player setupVideoWidget:CGRectZero containView:view insertIndex:0];
        self.player.delegate = delegate;
    }
    return self;
}

- (void)dealloc {
    if (self.player.isPlaying) {
        [self.player stopPlay];
    }
}

- (void)applyConfigToPlayer {
    [self.player showVideoDebugLog:self.config.isDebugOn];
    [self.player setRenderRotation:self.config.orientation];
    [self.player setRenderMode:self.config.renderMode];
    [self updatePlayerCache];
}

- (void)startPlay:(NSString *)url {
    [self applyConfigToPlayer];
    [self.player startPlay:url type:PLAY_TYPE_LIVE_FLV];
}

- (void)stopPlay {
    [self.player stopPlay];
}

- (BOOL)isPlaying {
    return self.player.isPlaying;
}

#pragma mark - Config

- (void)setDebugLogEnabled:(BOOL)isEnabled {
    self.config.isDebugOn = isEnabled;
    [self.player showVideoDebugLog:isEnabled];
}

- (void)setOrientation:(TX_Enum_Type_HomeOrientation)orientation {
    self.config.orientation = orientation;
    [self.player setRenderRotation:orientation];
}

- (void)setRenderMode:(TX_Enum_Type_RenderMode)renderMode {
    self.config.renderMode = renderMode;
    [self.player setRenderMode:renderMode];
}

- (void)setCacheType:(TRTCCdnPlayerCacheType)cacheType {
    self.config.cacheType = cacheType;
    [self updatePlayerCache];
}

#pragma mark - Private

- (void)updatePlayerCache {
    TXLivePlayConfig *config = self.player.config;
    const float cacheTimeFast = 1.0;
    const float cacheTimeSmooth = 5.0;
    
    switch (self.config.cacheType) {
        case TRTCCdnPlayerCacheTypeFast:
            config.bAutoAdjustCacheTime = YES;
            config.minAutoAdjustCacheTime = cacheTimeFast;
            config.maxAutoAdjustCacheTime = cacheTimeFast;
            break;
            
        case TRTCCdnPlayerCacheTypeSmooth:
            config.bAutoAdjustCacheTime = NO;
            config.minAutoAdjustCacheTime = cacheTimeSmooth;
            config.maxAutoAdjustCacheTime = cacheTimeSmooth;
            break;
            
        case TRTCCdnPlayerCacheTypeAuto:
            config.bAutoAdjustCacheTime = YES;
            config.minAutoAdjustCacheTime = cacheTimeFast;
            config.maxAutoAdjustCacheTime = cacheTimeSmooth;
            break;
    }
    [self.player setConfig:config];
}

@end
