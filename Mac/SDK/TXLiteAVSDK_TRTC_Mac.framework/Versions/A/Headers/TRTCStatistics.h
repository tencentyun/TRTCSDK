
/*
 * Module:   TRTCStatistics @ TXLiteAVSDK
 *
 * Function: 腾讯云视频通话功能的质量统计相关接口
 *
 */


/// 自己本地的音视频统计信息
@interface TRTCLocalStatistics : NSObject

///视频宽度
@property (nonatomic, assign) uint32_t  width;

///视频高度
@property (nonatomic, assign) uint32_t  height;

///帧率（fps）
@property (nonatomic, assign) uint32_t  frameRate;

///视频发送码率（Kbps）
@property (nonatomic, assign) uint32_t  videoBitrate;

///音频采样率（Hz）
@property (nonatomic, assign) uint32_t  audioSampleRate;

///音频发送码率（Kbps）
@property (nonatomic, assign) uint32_t  audioBitrate;

///流类型（大画面 | 小画面 | 辅路画面）
@property (nonatomic, assign) TRTCVideoStreamType  streamType;
@end


/// 远端成员的音视频统计信息
@interface TRTCRemoteStatistics : NSObject

///用户ID，指定是哪个用户的视频流
@property (nonatomic, retain) NSString* userId;

/** 该线路的总丢包率(%)
 *
 * 这个值越小越好，比如： 0% 的丢包率代表网络很好
 * 这个丢包率是该线路的 userid 从上行到服务器再到下行的总丢包率
 * 如果 downLoss 为 0%, 但是 finalLoss 不为 0%，说明该 userId 在上行就出现了无法恢复的丢包
 */
@property (nonatomic, assign) uint32_t  finalLoss;

///视频宽度
@property (nonatomic, assign) uint32_t  width;

///视频高度
@property (nonatomic, assign) uint32_t  height;

///接收帧率（fps）
@property (nonatomic, assign) uint32_t  frameRate;

///视频码率（Kbps）
@property (nonatomic, assign) uint32_t  videoBitrate;

///音频采样率（Hz）
@property (nonatomic, assign) uint32_t  audioSampleRate;

///音频码率（Kbps）
@property (nonatomic, assign) uint32_t  audioBitrate;

///流类型（大画面 | 小画面 | 辅路画面）
@property (nonatomic, assign) TRTCVideoStreamType  streamType;
@end


/// 统计数据
@interface TRTCStatistics : NSObject

/** C -> S 上行丢包率(%)
 *
 * 这个值越小越好，比如： 0% 的丢包率代表网络很好，
 * 而 30% 的丢包率则意味着 SDK 向服务器发送的每 10 个数据包中就会有 3 个会在上行传输中丢失
 */
@property (nonatomic, assign) uint32_t  upLoss;

/** S -> C 下行丢包率(%)
 *
 * 这个值越小越好，比如： 0% 的丢包率代表网络很好，
 * 而 30% 的丢包率则意味着服务器向 SDK 发送的每 10 个数据包中就会有 3 个会在下行传输中丢失
 */
@property (nonatomic, assign) uint32_t  downLoss;

///当前 App 的 CPU 使用率 (%)
@property (nonatomic, assign) uint32_t  appCpu;

///当前系统的 CPU 使用率 (%)
@property (nonatomic, assign) uint32_t  systemCpu;

///延迟（毫秒）：代表 SDK 跟服务器一来一回之间所消耗的时间，这个值越小越好
///一般低于 50ms 的 rtt 是比较理想的情况，而高于 100ms 的 rtt 会引入较大的通话延时
///由于数据上下行共享一条网络连接，所以 local 和 remote 的 rtt 相同
@property (nonatomic, assign) uint32_t  rtt;

/// 总接收字节数(包含信令及音视频)
@property (nonatomic, assign) uint64_t  receivedBytes;

/// 总发送字节数(包含信令及音视频)
@property (nonatomic, assign) uint64_t  sentBytes;

///自己本地的音视频统计信息，由于可能有大画面、小画面以及辅路画面等多路的情况，所以是一个数组
@property (nonatomic, strong) NSArray<TRTCLocalStatistics*>*  localStatistics;

///远端成员的音视频统计信息，由于可能有大画面、小画面以及辅路画面等多路的情况，所以是一个数组
@property (nonatomic, strong) NSArray<TRTCRemoteStatistics*>* remoteStatistics;
@end
