/*
* Module:   TRTCRemoteUserConfig
*
* Function: 保存对远端用户的设置项
*
*    1. 对象无需保存到本地
*
*/

#import "TRTCRemoteUserConfig.h"

@implementation TRTCRemoteUserConfig

- (instancetype)initWithRoomId:(NSString *)roomId {
    if (self = [super init]) {
        self.roomId = roomId;
        self.isAudioEnabled = YES;
        self.isVideoEnabled = YES;
        self.fillMode = TRTCVideoFillMode_Fit;
        self.volume = 100;
    }
    return self;
}

@end
