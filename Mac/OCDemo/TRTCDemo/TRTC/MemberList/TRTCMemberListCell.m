//
//  TRTCMemberListCell.m
//  TXLiteAVMacDemo
//
//  Created by Xiaoya Liu on 2020/2/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TRTCMemberListCell.h"
#import "TRTCUserManager.h"

@interface TRTCMemberListCell ()

@property (weak) IBOutlet NSImageView *avatarImageView;
@property (weak) IBOutlet NSTextField *userIdLabel;
@property (weak) IBOutlet NSButton *muteAudioButton;
@property (weak) IBOutlet NSButton *muteVideoButton;

@end

@implementation TRTCMemberListCell

- (void)dealloc {
    if (self.user) {
        [self.user removeObserver:self forKeyPath:@"isAudioAvailable"];
        [self.user removeObserver:self forKeyPath:@"isAudioMuted"];
        [self.user removeObserver:self forKeyPath:@"isVideoAvailable"];
        [self.user removeObserver:self forKeyPath:@"isVideoMuted"];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    if (self.user) {
        [self.user removeObserver:self forKeyPath:@"isAudioAvailable"];
        [self.user removeObserver:self forKeyPath:@"isAudioMuted"];
        [self.user removeObserver:self forKeyPath:@"isVideoAvailable"];
        [self.user removeObserver:self forKeyPath:@"isVideoMuted"];
    }
}

- (void)setUser:(TRTCUserConfig *)user {
    _user = user;
    [user addObserver:self forKeyPath:@"isAudioAvailable" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    [user addObserver:self forKeyPath:@"isAudioMuted" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    [user addObserver:self forKeyPath:@"isVideoAvailable" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    [user addObserver:self forKeyPath:@"isVideoMuted" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];

    self.avatarImageView.image = [NSImage imageNamed:[NSString stringWithFormat:@"avatar%@", @(user.userId.hash % 10)]];
    self.userIdLabel.stringValue = user.userId;
}

- (IBAction)onClickAudioMuteButton:(NSButton *)button {
    [self.userManager muteAudio:button.state == NSControlStateValueOn withUser:self.user.userId];
}

- (IBAction)onClickVideoMuteButton:(NSButton *)button {
    [self.userManager muteVideo:button.state == NSControlStateValueOn withUser:self.user.userId];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isAudioAvailable"] ||
        [keyPath isEqualToString:@"isAudioMuted"]) {
        self.muteAudioButton.enabled = self.user.isAudioAvailable;
        self.muteAudioButton.image = [NSImage imageNamed:self.user.isAudioOn
                                      ? @"sound" : @"sound_dis"];
        self.muteAudioButton.state = self.user.isAudioOn ? NSControlStateValueOff : NSControlStateValueOn;
    } else if ([keyPath isEqualToString:@"isVideoAvailable"] ||
               [keyPath isEqualToString:@"isVideoMuted"]) {
        self.muteVideoButton.enabled = self.user.isVideoAvailable;
        self.muteVideoButton.image = [NSImage imageNamed:self.user.isVideoOn
                                      ? @"camera" : @"camera_dis"];
        self.muteVideoButton.state = self.user.isVideoOn ? NSControlStateValueOff : NSControlStateValueOn;
    }
}

- (IBAction)muteAudioButton:(id)sender {
}
@end
