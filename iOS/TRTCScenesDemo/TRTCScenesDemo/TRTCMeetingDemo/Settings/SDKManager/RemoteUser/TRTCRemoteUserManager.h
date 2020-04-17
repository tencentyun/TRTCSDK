/*
* Module:   TRTCRemoteUserManager
*
* Function: TRTC SDK中，对房间内其它用户的设置功能
*
*    1. 房间内的其它用户信息，保存在users字典中
*
*    2. 对远端用户的操作，包括开关音视频，调整视频填充模式，旋转角度，音量大小。
*       这些设置只会影响本地对该用户的播放效果，不会影响到其它人。
*
*/

#import <Foundation/Foundation.h>
#import "TRTCCloud.h"
#import "TRTCCloudDef.h"
#import "TRTCRemoteUserConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCRemoteUserManager : NSObject

@property (strong, nonatomic, readonly) NSDictionary<NSString *, TRTCRemoteUserConfig *> *remoteUsers;
@property (strong, nonatomic, readonly) TRTCCloud *trtc;

- (instancetype)initWithTrtc:(TRTCCloud *)trtc NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)addUser:(NSString *)userId roomId:(NSString *)roomId;

- (void)removeUser:(NSString *)userId;

/// 设置是否自动接收远端音视频
/// @param autoReceiveAudio 自动接收音频
/// @param autoReceiveVideo 自动接收视频
- (void)enableAutoReceiveAudio:(BOOL)autoReceiveAudio
              autoReceiveVideo:(BOOL)autoReceiveVideo;

/// 更新远端用户视频开启状态
/// @param userId 用户ID
/// @param isEnabled 视频开启
- (void)updateUser:(NSString *)userId isVideoEnabled:(BOOL)isEnabled;

/// 更新远端用户视频开启状态
/// @param userId 用户ID
/// @param isEnabled 音频开启
- (void)updateUser:(NSString *)userId isAudioEnabled:(BOOL)isEnabled;

/// 设置接收远端视频流
/// @param userId 用户ID
/// @param isMuted 静音视频流
- (void)setUser:(NSString *)userId isVideoMuted:(BOOL)isMuted;

/// 设置接收远端音频流
/// @param userId 用户ID
/// @param isMuted 静音音频流
- (void)setUser:(NSString *)userId isAudioMuted:(BOOL)isMuted;

/// 设置远端图像的填充模式
/// @param userId 用户ID
/// @param fillMode 填充模式，类型为TRTCVideoFillMode
- (void)setUser:(NSString *)userId fillMode:(TRTCVideoFillMode)fillMode;

/// 设置远端图像的旋转角度
/// @param userId 用户ID
/// @param rotation 旋转角度，类型为TRTCVideoRotation
- (void)setUser:(NSString *)userId rotation:(TRTCVideoRotation)rotation;

/// 设置远端音量
/// @param userId 用户ID
/// @param volume 音量，取值范围为0 - 100
- (void)setUser:(NSString *)userId volume:(NSInteger)volume;

@end

NS_ASSUME_NONNULL_END
