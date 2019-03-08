#import <Foundation/Foundation.h>

@interface TXLivePlayConfig : NSObject

/// 播放器缓存时间 : 单位秒，取值需要大于0, 默认值为5
@property(nonatomic, assign) float cacheTime;

/**
 * 是否自动调整播放器缓存时间 : YES:启用自动调整，自动调整的最大值和最小值可以分别通过修改maxCacheTime和minCacheTime来设置；
 *                        NO:关闭自动调整，采用默认的指定缓存时间(1s)，可以通过修改cacheTime来调整缓存时间.
 *                          默认值为YES
 */
@property(nonatomic, assign) BOOL bAutoAdjustCacheTime;

/// 播放器缓存自动调整的最大时间 : 单位秒，取值需要大于0, 默认值为5
@property(nonatomic, assign) float maxAutoAdjustCacheTime;

/// 播放器缓存自动调整的最小时间 : 单位秒，取值需要大于0, 默认值为1
@property(nonatomic, assign) float minAutoAdjustCacheTime;

/// 播放器视频卡顿报警阈值，只有渲染间隔超过这个阈值的卡顿才会有PLAY_WARNING_VIDEO_PLAY_LAG通知
@property(nonatomic, assign) int videoBlockThreshold;

/// 播放器连接重试次数 : 最小值为 1， 最大值为 10, 默认值为 3
@property(nonatomic, assign) int connectRetryCount;

/// 播放器连接重试间隔 : 单位秒，最小值为 3, 最大值为 30， 默认值为 3
@property(nonatomic, assign) int connectRetryInterval;

/// 是否开启回声消除， 默认值为NO
@property(nonatomic, assign) BOOL enableAEC;

/// 是否开启消息通道， 默认值为NO
@property(nonatomic, assign) BOOL enableMessage;

/**
 视频渲染对象回调的视频格式. 仅支持 kCVPixelFormatType_420YpCbCr8Planar和kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, 默认值为kCVPixelFormatType_420YpCbCr8Planar
点播支持kCVPixelFormatType_32BGRA回调
点播支持kCVPixelFormatType_32BGRA回调
点播支持kCVPixelFormatType_32BGRA回调
 */
@property(nonatomic, assign) OSType playerPixelFormatType;

/**
 *  只对加速拉流生效，用于指定加速拉流是否开启就近选路 (当前版本不启用)
 */
@property(nonatomic, assign) BOOL enableNearestIP;

/**
 *  RTMP传输通道的类型，取值为枚举值：TX_Enum_Type_RTMPChannel, 默认值为RTMP_CHANNEL_TYPE_AUTO
 *  RTMP_CHANNEL_TYPE_AUTO          = 0,    //自动
 *  RTMP_CHANNEL_TYPE_STANDARD      = 1,    //标准的RTMP协议，网络层采用TCP协议
 *  RTMP_CHANNEL_TYPE_PRIVATE       = 2,    //标准的RTMP协议，网络层采用私有通道传输（在UDP上封装的一套可靠快速的传输通道），能够更好地抵抗网络抖动；对于播放来说，私有传输通道只有在拉取低时延加速流时才可以生效
 
 */
@property (nonatomic, assign) int rtmpChannelType;

#if TARGET_OS_IPHONE
/// 视频缓存目录，点播MP4、HLS有效
@property NSString *cacheFolderPath;
/// 最多缓存文件个数
@property int maxCacheItems;
/// 自定义HTTP Headers
@property NSDictionary *headers;
#endif
@end
