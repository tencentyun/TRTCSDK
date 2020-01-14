/*
* Module:   TRTCRemoteUserManager
*
* Function: TRTC SDK中，对房间内其它用户的设置功能
*
*    1. 房间内的其它用户信息，保存在users字典中
*
*    2. 对远端用户的操作，包括开关音视频，调整视频填充模式，旋转角度，音量大小。
*       这些设置只会影响本地的播放效果，不影响该远端用户的实际推流。
*
*/

#import "TRTCRemoteUserManager.h"

@interface TRTCRemoteUserManager()

@property (strong, nonatomic) TRTCCloud *trtc;
@property (strong, nonatomic) NSMutableDictionary<NSString *, TRTCRemoteUserConfig *> *users;
@property (nonatomic) BOOL autoReceivesAudio;

@end


@implementation TRTCRemoteUserManager

- (instancetype)initWithTrtc:(TRTCCloud *)trtc {
    if (self = [super init]) {
        _trtc = trtc;
        _users = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSDictionary *)remoteUsers {
    return [NSDictionary dictionaryWithDictionary:self.users];
}

- (void)addUser:(NSString *)userId roomId:(NSString *)roomId {
    if (self.users[userId]) {
        return;
    }
    TRTCRemoteUserConfig *config = [[TRTCRemoteUserConfig alloc] initWithRoomId:roomId];
    config.isAudioMuted = !self.autoReceivesAudio;
    self.users[userId] = config;
}

- (void)removeUser:(NSString *)userId {
    [self.users removeObjectForKey:userId];
}

- (void)enableAutoReceiveAudio:(BOOL)autoReceiveAudio
              autoReceiveVideo:(BOOL)autoReceiveVideo {
    self.autoReceivesAudio = autoReceiveAudio;
    [self.trtc setDefaultStreamRecvMode:autoReceiveAudio
                                  video:autoReceiveVideo];
}

- (void)updateUser:(NSString *)userId isVideoEnabled:(BOOL)isEnabled {
    self.users[userId].isVideoEnabled = isEnabled;
}

- (void)updateUser:(NSString *)userId isAudioEnabled:(BOOL)isEnabled {
    self.users[userId].isAudioEnabled = isEnabled;
}

- (void)setUser:(NSString *)userId isVideoMuted:(BOOL)isMuted {
    self.users[userId].isVideoMuted = isMuted;
    [self.trtc muteRemoteVideoStream:userId mute:isMuted];
}

- (void)setUser:(NSString *)userId isAudioMuted:(BOOL)isMuted {
    self.users[userId].isAudioMuted = isMuted;
    [self.trtc muteRemoteAudio:userId mute:isMuted];
}

- (void)setUser:(NSString *)userId fillMode:(TRTCVideoFillMode)fillMode {
    self.users[userId].fillMode = fillMode;
    [self.trtc setRemoteViewFillMode:userId mode:fillMode];
}

- (void)setUser:(NSString *)userId rotation:(TRTCVideoRotation)rotation {
    self.users[userId].rotation = rotation;
    [self.trtc setRemoteViewRotation:userId rotation:rotation];
}

- (void)setUser:(NSString *)userId volume:(NSInteger)volume {
    self.users[userId].volume = volume;
    [self.trtc setRemoteAudioVolume:userId volume:(int)volume];
}

@end
