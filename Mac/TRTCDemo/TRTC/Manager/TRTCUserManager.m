//
//  TRTCUserManager.m
//  TXLiteAVMacDemo
//
//  Created by Xiaoya Liu on 2020/2/28.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TRTCUserManager.h"
#import "TXRenderView.h"
#import "TRTCSettingWindowController.h"

@interface TRTCUserManager()

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, strong) NSMutableDictionary<NSString *, TRTCUserConfig *> *userList;

@end

@implementation TRTCUserManager

- (instancetype)initWithUserId:(NSString *)userId {
    if (self = [super init]) {
        self.userId = userId;
        self.userList = [NSMutableDictionary dictionary];
        self.userList[userId] = [[TRTCUserConfig alloc] init];
    }
    return self;
}

- (void)addUser:(NSString *)userId {
    TRTCUserConfig *userInfo = [[TRTCUserConfig alloc] init];
    userInfo.userId = userId;
    userInfo.renderView = [self createRenderViewOfUser:userId];
    userInfo.renderView.userManager = self;
    
    self.userList[userId] = userInfo;
    self.userConfigs = self.userList.allValues;
}

- (void)removeUser:(NSString *)userId {
    [self.userList[userId].renderView removeFromSuperview];
    self.userList[userId] = nil;
    self.userConfigs = self.userList.allValues;
}

- (void)setUser:(NSString *)userId videoAvailable:(BOOL)videoAvailable {
    self.userList[userId].isVideoAvailable = videoAvailable;
    [self handleVideoStateOfUser:userId];
}

- (void)setUser:(NSString *)userId audioAvailable:(BOOL)audioAvailable {
    if ([self.userId isEqualToString:userId]) {
        if (audioAvailable) {
            [[TRTCCloud sharedInstance] startLocalAudio];
        } else {
            [[TRTCCloud sharedInstance] stopLocalAudio];
        }
    }
    self.userList[userId].isAudioAvailable = audioAvailable;
}

- (void)muteVideo:(BOOL)isMuted withUser:(NSString *)userId {
    self.userList[userId].isVideoMuted = isMuted;
    [self handleVideoStateOfUser:userId];
}

- (void)muteAudio:(BOOL)isMuted withUser:(NSString *)userId {
    if ([self.userId isEqualToString:userId]) {
        [[TRTCCloud sharedInstance] muteLocalAudio:isMuted];
    } else {
        [[TRTCCloud sharedInstance] muteRemoteAudio:userId mute:isMuted];
    }
    self.userList[userId].isAudioMuted = isMuted;
}

- (void)handleVideoStateOfUser:(NSString *)userId {
    if (self.userList[userId].isVideoOn) {
        TXRenderView *renderView = self.userList[userId].renderView;
        if ([self.userId isEqualToString:userId]) {
            [[TRTCCloud sharedInstance] startLocalPreview:renderView.contentView];
        } else {
            [[TRTCCloud sharedInstance] startRemoteView:userId view:renderView.contentView];
        }
    } else {
        if ([self.userId isEqualToString:userId]) {
            [[TRTCCloud sharedInstance] stopLocalPreview];
        } else {
            [[TRTCCloud sharedInstance] stopRemoteView:userId];
        }
    }
}

- (void)muteAllRemoteVideo:(BOOL)isMuted {
    for (TRTCUserConfig *user in self.userConfigs) {
        if (![self.userId isEqualToString:user.userId]) {
            [self muteVideo:isMuted withUser:user.userId];
        }
    }
}

- (void)muteAllRemoteAudio:(BOOL)isMuted {
    [[TRTCCloud sharedInstance] muteAllRemoteAudio:isMuted];
    for (TRTCUserConfig *user in self.userConfigs) {
        if (![self.userId isEqualToString:user.userId]) {
            user.isAudioMuted = isMuted;
        }
    }
}

- (void)setVolumes:(NSArray<TRTCVolumeInfo *> *)userVolumes {
    for (TRTCUserConfig *user in self.userConfigs) {
        [user.renderView setVolume:0];
    }
    
    for (TRTCVolumeInfo *info in userVolumes) {
        [self.userList[info.userId ?: self.userId].renderView setVolume:info.volume / 100.0f];
    }
}

- (void)setLocalNetQuality:(TRTCQualityInfo *)quality {
    [self.userList[self.userId].renderView setSignal:quality.quality];
}

- (void)setRemoteNetQuality:(NSArray<TRTCQualityInfo *> *)remoteQuality {
    for (TRTCQualityInfo *qualityInfo in remoteQuality) {
        [self.userList[qualityInfo.userId].renderView setSignal:qualityInfo.quality];
    }
}

- (void)hideRenderViewExceptUser:(NSString *)userId {
    for (TRTCUserConfig *user in self.userConfigs) {
        if (![user.userId isEqualToString:self.userId] && ![user.userId isEqualToString:userId]) {
            [[TRTCCloud sharedInstance] stopRemoteView:user.userId];
        }
    }
    [self handleVideoStateOfUser:userId];
}

- (void)recoverAllRenderViews {
    for (TRTCUserConfig *user in self.userConfigs) {
        if (![user.userId isEqualToString:self.userId]) {
            [self handleVideoStateOfUser:user.userId];
        }
    }
}

#pragma mark - Private

- (TXRenderView *)createRenderViewOfUser:(NSString *)userId {
    TXRenderView *view = [TXRenderView renderViewWithUserId:userId isMe:[userId isEqualToString:self.userId]];
    [view setVolumeHidden:![TRTCSettingWindowController showVolume]];
    return view;
}

@end


@implementation TRTCUserConfig

- (void)setIsAudioAvailable:(BOOL)isAudioAvailable {
    _isAudioAvailable = isAudioAvailable;
    self.isAudioOn = isAudioAvailable && !self.isAudioMuted;
    [self.renderView setAudioOn:self.isAudioOn];
}

- (void)setIsAudioMuted:(BOOL)isAudioMuted {
    _isAudioMuted = isAudioMuted;
    [self.renderView setAudioMuted:isAudioMuted];

    self.isAudioOn = self.isAudioAvailable && !isAudioMuted;
    [self.renderView setAudioOn:self.isAudioOn];
}

- (void)setIsVideoAvailable:(BOOL)isVideoAvailable {
    _isVideoAvailable = isVideoAvailable;
    self.isVideoOn = isVideoAvailable && !self.isVideoMuted;
    [self.renderView setVideoOn:self.isVideoOn];
}

- (void)setIsVideoMuted:(BOOL)isVideoMuted {
    _isVideoMuted = isVideoMuted;
    [self.renderView setVideoMuted:isVideoMuted];
    
    self.isVideoOn = self.isVideoAvailable && !isVideoMuted;
    [self.renderView setVideoOn:self.isVideoOn];
}

@end
