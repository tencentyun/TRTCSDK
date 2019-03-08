
#import <Foundation/Foundation.h>
#import "TXLiveSDKTypeDef.h"

/// 直播通知
@protocol TXLivePlayListener <NSObject>

/**
 * 直播事件通知
 *
 * @param EvtID 参见TXLiveSDKTypeDef.h
 * @param param 参见TXLiveSDKTypeDef.h
 */
-(void) onPlayEvent:(int)EvtID withParam:(NSDictionary*)param;

/**
 * 网络状态通知
 *
 * @param param 参见TXLiveSDKTypeDef.h
 */
-(void) onNetStatus:(NSDictionary*) param;


/**
 * SDK内部使用：通知FLV、VOD底层播放器初始化成功，FLV、VOD可以发起网络连接了；
 * 底层播放器在SDK逻辑线程异步初始化，如果FLV、VOD先发起网络连接，会出现网络连接成功且收到音视频包后，底层播放器还没有初始化的问题
 *
 */
@optional
-(void) onRecvConnectNofity;

@end
