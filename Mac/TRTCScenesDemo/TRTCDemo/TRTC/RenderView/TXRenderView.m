//
//  TXRenderView.m
//  TXLiteAVMacDemo
//
//  Created by cui on 2018/12/3.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "TXRenderView.h"
#import "TRTCUserManager.h"

@interface TXRenderView ()

// 视频页面
@property (weak) IBOutlet NSView *contentView;

// 左下角的用户信息
@property (weak) IBOutlet NSView *userInfoView;
@property (weak) IBOutlet NSTextField *nameLabel;
@property (weak) IBOutlet NSImageView *audioStateView;
@property (weak) IBOutlet NSLevelIndicator *volumeView;
@property (weak) IBOutlet NSImageView *signalView;

// 右上角的功能栏
@property (weak) IBOutlet NSStackView *functionBar;
@property (weak) IBOutlet NSButton *rotateButton;
@property (weak) IBOutlet NSButton *streamButton;
@property (weak) IBOutlet NSButton *muteVideoButton;
@property (weak) IBOutlet NSButton *muteAudioButton;
@property (weak) IBOutlet NSButton *toggleFillModeButton;

// 无画面时显示的用户信息
@property (weak) IBOutlet NSImageView *avatarView;

@property (nonatomic) TRTCVideoRotation rotation;

@end

@implementation TXRenderView

+ (instancetype)renderViewWithUserId:(NSString *)userId isMe:(BOOL)isMe {
    NSArray *views;
    if ([[NSBundle mainBundle] loadNibNamed:@"TXRenderView" owner:self topLevelObjects:&views]) {
        NSUInteger index = [views indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [obj isKindOfClass:[TXRenderView class]];
        }];
        TXRenderView *view = (TXRenderView *)views[index];
        view.userId = userId;
        view.isMe = isMe;
        
        view.avatarView.image = [NSImage imageNamed:[NSString stringWithFormat:@"avatar%@", @(userId.hash % 10)]];
        view.nameLabel.stringValue = userId;

        return view;
    }
    return nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.wantsLayer = YES;
    self.layer.backgroundColor = [NSColor blackColor].CGColor;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [NSColor whiteColor].CGColor;
    
    self.functionBar.wantsLayer = YES;
    self.functionBar.layer.backgroundColor = [NSColor darkGrayColor].CGColor;
    if (@available(macOS 10.13, *)) {
        self.functionBar.layer.masksToBounds = YES;
        self.functionBar.layer.cornerRadius = 4;
        self.functionBar.layer.maskedCorners = kCALayerMinXMinYCorner;
    }

    self.userInfoView.wantsLayer = YES;
    self.userInfoView.layer.backgroundColor = [NSColor darkGrayColor].CGColor;
    if (@available(macOS 10.13, *)) {
        self.userInfoView.layer.masksToBounds = YES;
        self.userInfoView.layer.cornerRadius = 8;
        self.userInfoView.layer.maskedCorners = kCALayerMaxXMaxYCorner;
    }
    
    self.avatarView.layer.borderWidth = 1.0;
    self.avatarView.layer.borderColor = [NSColor whiteColor].CGColor;
}

- (void)viewWillDraw {
    [super viewWillDraw];
    self.volumeView.layer.position = CGPointMake(CGRectGetMidX(self.volumeView.layer.frame), CGRectGetMidY(self.volumeView.layer.frame));
    self.volumeView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.volumeView.layer.transform = CATransform3DMakeRotation(M_PI / 2, 0, 0, 1);
}

- (IBAction)onClickRotateButton:(id)sender {
    self.rotation = (self.rotation + 1) % 4;
    if (self.isMe) {
        [[TRTCCloud sharedInstance] setLocalViewRotation:self.rotation];
    } else {
        [[TRTCCloud sharedInstance] setRemoteViewRotation:self.userId rotation:self.rotation];
    }
}

- (IBAction)onToggleStreamButton:(NSButton *)button {
    TRTCVideoStreamType type = button.state == NSControlStateValueOn
        ? TRTCVideoStreamTypeSmall
        : TRTCVideoStreamTypeBig;
    [[TRTCCloud sharedInstance] setRemoteVideoStreamType:self.userId type:type];
}

- (IBAction)onClickMuteVideoButton:(NSButton *)button {
    [self.userManager muteVideo:button.state == NSControlStateValueOn withUser:self.userId];
}

- (IBAction)onClickMuteAudioButton:(NSButton *)button {
    [self.userManager muteAudio:button.state == NSControlStateValueOn withUser:self.userId];
}

- (IBAction)onClickToggleFillModeButton:(NSButton *)button {
    TRTCVideoFillMode mode = button.state == NSControlStateValueOn
        ? TRTCVideoFillMode_Fill
        : TRTCVideoFillMode_Fit;
    if (self.isMe) {
        [[TRTCCloud sharedInstance] setLocalViewFillMode:mode];
    } else {
        [[TRTCCloud sharedInstance] setRemoteViewFillMode:self.userId mode:mode];
    }
}

#pragma mark - Public Methods

- (void)setIsMe:(BOOL)isMe {
    _isMe = isMe;
    self.streamButton.hidden = isMe;
    self.muteVideoButton.hidden = isMe;
    self.muteAudioButton.hidden = isMe;
}

- (void)setVolumeHidden:(BOOL)volumeHidden {
    self.volumeView.hidden = volumeHidden;
}

- (void)setVolume:(double)volume {
    self.volumeView.doubleValue = volume;
}

- (void)setSignal:(TRTCQuality)volume {
    self.signalView.image = [NSImage imageNamed:[NSString stringWithFormat:@"signal%@", @(volume)]];
}

- (void)setPlaysSmallStream:(BOOL)playsSmallStream {
    self.streamButton.state = playsSmallStream ? NSControlStateValueOn : NSControlStateValueOff;
    TRTCVideoStreamType type = playsSmallStream ? TRTCVideoStreamTypeSmall : TRTCVideoStreamTypeBig;
    [[TRTCCloud sharedInstance] setRemoteVideoStreamType:self.userId type:type];
}

- (void)setVideoOn:(BOOL)isVideoOn {
    self.avatarView.hidden = isVideoOn;
}

- (void)setAudioOn:(BOOL)isAudioOn {
    self.audioStateView.image = [NSImage imageNamed:isAudioOn ? @"main_tool_audio_on" : @"main_tool_audio_off"];
}

- (void)setVideoMuted:(BOOL)isMuted {
    self.muteVideoButton.state = isMuted ? NSControlStateValueOn : NSControlStateValueOff;
    self.muteVideoButton.image = [NSImage imageNamed:isMuted ? @"main_tool_video_off" : @"main_tool_video_on"];
}

- (void)setAudioMuted:(BOOL)isMuted {
    self.muteAudioButton.state = isMuted ? NSControlStateValueOn : NSControlStateValueOff;
    self.muteAudioButton.image = [NSImage imageNamed:isMuted ? @"main_tool_audio_off" : @"main_tool_audio_on"];
}

@end
