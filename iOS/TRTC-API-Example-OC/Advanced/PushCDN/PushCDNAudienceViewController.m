//
//  PushCDNAudienceViewController.m
//  TRTC-API-Example-OC
//
//  Created by abyyxwang on 2021/4/20.
//

/*
 CDN发布功能 - 观众端
 TRTC APP CDN发布功能
 本文件展示如何集成CDN发布功能
 1、设置播放器代理。 API:[self.livePlayer setDelegate:self];
 2、设置播放容器视图。 API: [self.livePlayer setupVideoWidget:CGRectZero containView:self.playerView insertIndex:0];
 2、开始播放。 API: [self.livePlayer startPlay:streamUrl type:PLAY_TYPE_LIVE_FLV];
 参考文档：https://cloud.tencent.com/document/product/647/16827
 */
/*
 CDN Publishing - Audience
 TRTC CDN Publishing
 This document shows how to integrate the CDN publishing feature.
 1. Set the player delegate: [self.livePlayer setDelegate:self]
 2. Set the player container view: [self.livePlayer setupVideoWidget:CGRectZero containView:self.playerView insertIndex:0]
 3. Start playback: [self.livePlayer startPlay:streamUrl type:PLAY_TYPE_LIVE_FLV]
 Documentation: https://cloud.tencent.com/document/product/647/16827
 */

#import "PushCDNAudienceViewController.h"

@interface PushCDNAudienceViewController ()<V2TXLivePlayerObserver>

@property (weak, nonatomic) IBOutlet UILabel *streamIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIButton *startPlayButton;

@property (strong, nonatomic) V2TXLivePlayer *livePlayer;

@end

@implementation PushCDNAudienceViewController

- (V2TXLivePlayer *)livePlayer {
    if (!_livePlayer) {
        _livePlayer = [[V2TXLivePlayer alloc] init];
    }
    return _livePlayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
}

- (void)setupDefaultUIConfig {
    self.streamIDLabel.text = Localize(@"TRTC-API-Example.PushCDNAudience.pushStreamAddress");
    [self.startPlayButton setTitle:Localize(@"TRTC-API-Example.PushCDNAudience.startPlay") forState:UIControlStateNormal];
    [self.startPlayButton setTitle:Localize(@"TRTC-API-Example.PushCDNAudience.stopPlay") forState:UIControlStateSelected];
    [self.startPlayButton setBackgroundColor: UIColor.themeGreenColor];
    self.streamIDTextField.placeholder = Localize(@"TRTC-API-Example.PushCDNAudience.inputStreamId");
    self.streamIDLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)startPlay {
    NSString *streamUrl = [NSString stringWithFormat:@"%@/%@.flv",kCDN_URL,self.streamIDTextField.text];
    [self.livePlayer setObserver:self];
    [self.livePlayer setRenderView:self.playerView];
    V2TXLiveCode ret = [self.livePlayer startPlay:streamUrl];
    if (ret != 0) {
        NSLog(@"play error. code: %ld", ret);
    }
}

- (void)stopPlay {
    [self.livePlayer setObserver:nil];
    [self.livePlayer setRenderView:nil];
    [self.livePlayer stopPlay];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.streamIDTextField.isFirstResponder) {
        [self.streamIDTextField resignFirstResponder];
    }
}

#pragma mark - IBActions
- (IBAction)onPlayClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self startPlay];
    } else {
        [self stopPlay];
    }
}

#pragma mark - V2TXLivePlayerObserver
- (void)onVideoPlaying:(id<V2TXLivePlayer>)player firstPlay:(BOOL)firstPlay extraInfo:(NSDictionary *)extraInfo {
    NSLog(@"onVideoPlaying");
}

- (void)onError:(id<V2TXLivePlayer>)player code:(V2TXLiveCode)code message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo {
    NSLog(@"onError: message: %@",msg);
}


- (void)dealloc {
    [self stopPlay];
}

@end
