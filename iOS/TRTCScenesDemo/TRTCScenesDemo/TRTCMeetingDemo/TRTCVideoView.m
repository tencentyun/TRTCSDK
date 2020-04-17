//
//  TRTCVideoView.m
//  TXLiteAVDemo
//
//  Created by rushanting on 2019/3/5.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TRTCVideoView.h"
#import "UIView+Additions.h"
#import "Masonry.h"

@interface TRTCVideoView ()
@property (nonatomic, retain) UIProgressView* audioVolumeIndicator;
@property (nonatomic, retain) UIImageView* networkIndicator;
@property (nonatomic, copy) NSString* userId;
@property (nonatomic, assign) VideoViewType type;

@property (nonatomic, assign) CGPoint touchPoint;

@property (nonatomic, retain) UIView* tipBgView;
@property (nonatomic, weak) UIImageView* faceImageView;
@property (nonatomic, weak) UILabel*  uidLabel;
@property (nonatomic, weak) UILabel* tipLabel;
@end

@implementation TRTCVideoView
{
    BOOL _muteVideo;
    BOOL _muteAudio;
    BOOL _fillMode;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

#pragma mark - public func
+ (instancetype)newVideoViewWithType:(VideoViewType)type userId:( NSString  * _Nullable )userId
{
    TRTCVideoView* videoView = [TRTCVideoView new];
    videoView.type = type;
    videoView.userId = userId;

    if (type == VideoViewType_Local) {
        [videoView hideButtons:YES];
        videoView.audioVolumeIndicator.hidden = YES;
    }
    return videoView;
}

- (void)hideButtons:(BOOL)hide
{
    _btnMuteVideo.hidden = hide;
    _btnMuteAudio.hidden = hide;
    _btnScaleMode.hidden = hide;
}

- (void)setNetworkIndicatorImage:(UIImage *)image
{
    [_networkIndicator setImage:image];
}

- (void)setAudioVolumeRadio:(float)volumeRadio
{
    _audioVolumeIndicator.progress = volumeRadio;
}

- (void)showVideoCloseTip:(BOOL)show
{
    if (show) {
        if (!_tipBgView) {
            _tipBgView = [[UIView alloc] initWithFrame:self.bounds];
            _tipBgView.backgroundColor = UIColor.darkGrayColor;
            UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VideoClosed"]];
            imageView.center = CGPointMake(_tipBgView.width / 2, _tipBgView.height / 2 - 20);
            UILabel* uidLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bottom + 10, _tipBgView.width, 30)];
            NSString* uidText = _userId;
            if (_type == VideoViewType_Local) {
                uidText = [uidText stringByAppendingString:@"(您自己)"];
            }
            uidLabel.numberOfLines = 0;
            [uidLabel sizeToFit];
            uidLabel.textAlignment = NSTextAlignmentCenter;
            uidLabel.text = uidText;
            uidLabel.textColor = UIColor.whiteColor;
            UILabel* closeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, uidLabel.bottom, uidLabel.width, uidLabel.height)];
            closeLabel.text = @"视频已关闭";
            closeLabel.textAlignment = NSTextAlignmentCenter;
            closeLabel.textColor = UIColor.lightTextColor;
            [_tipBgView addSubview:imageView];
            [_tipBgView addSubview:uidLabel];
            [_tipBgView addSubview:closeLabel];
            
            _faceImageView = imageView;
            _uidLabel = uidLabel;
            _tipLabel = closeLabel;
        }
        [self addSubview:_tipBgView];
        [self relayout];
    }
    else {
        [_tipBgView removeFromSuperview];
        _tipBgView = nil;
    }
}

- (void)showAudioVolume:(BOOL)show
{
    self.audioVolumeIndicator.hidden = !show;
}

- (void)showNetworkIndicatorImage:(BOOL)show
{
    self.networkIndicator.hidden = !show;
}

- (NSString*)userId
{
    return _userId;
}

- (VideoViewType)type
{
    return _type;
}

#pragma mark - internal func

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self relayout];
}

- (void)relayout
{
    CGSize size = self.frame.size;
    int ICON_SIZE = 50;
    
    float startSpace = 5;
    float centerInterVal = (size.width - 2 * startSpace - ICON_SIZE) / 2  - ICON_SIZE;
    float iconY = size.height - ICON_SIZE / 2  - 10;
    
    _btnMuteVideo.center = CGPointMake(startSpace + ICON_SIZE / 2, iconY);
    _btnMuteAudio.center = CGPointMake(_btnMuteVideo.center.x + ICON_SIZE + centerInterVal, iconY);
    _btnScaleMode.center = CGPointMake(_btnMuteAudio.center.x + ICON_SIZE + centerInterVal, iconY);
    _audioVolumeIndicator.frame = CGRectMake(0, size.height - 2, size.width, 2);
    
    if (_tipBgView) {
        _tipBgView.frame = self.bounds;
        _faceImageView.center = CGPointMake(size.width / 2, size.height / 2 - 20);
        _faceImageView.bounds = CGRectMake(0, 0, 75, 75);
        
        [_uidLabel sizeToFit];
        [_tipLabel sizeToFit];
        _uidLabel.center = CGPointMake(_faceImageView.center.x, _faceImageView.bottom + 20);
        _tipLabel.center = CGPointMake(_faceImageView.center.x, _uidLabel.bottom + 20);
    }
}

- (void)setup
{
    self.userInteractionEnabled = YES;
    _enableMove = YES;
    _streamType = 0;
    int ICON_SIZE = 50;
    
    _btnMuteVideo = [self createBottomBtnIcon:@"muteVideo"
                                          Action:@selector(onBtnMuteVideoClicked:)
                                            Size:ICON_SIZE];
    
    _btnMuteAudio = [self createBottomBtnIcon:@"muteAudio"
                                       Action:@selector(onBtnMuteAudioClicked:)
                                         Size:ICON_SIZE];
    
    _btnScaleMode = [self createBottomBtnIcon:@"scaleFill"
                                       Action:@selector(onBtnScaleModeClicked:)
                                         Size:ICON_SIZE];
    
    _audioVolumeIndicator = [UIProgressView new];
//    _audioVolumeIndicator.width = 3;
    _audioVolumeIndicator.progressTintColor = UIColor.yellowColor;
    _audioVolumeIndicator.progress = 0.0;
    
    _networkIndicator = [[UIImageView alloc] init];
    _networkIndicator.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_networkIndicator];
    [_networkIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(self.mas_top).offset(0);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideTop).priorityLow();
        } else {
            make.top.equalTo(self.mas_top).offset(20);
        }
        make.trailing.equalTo(self.mas_trailing).offset(-10);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(20);
    }];

    [self addSubview:_audioVolumeIndicator];
}

- (UIButton*)createBottomBtnIcon:(NSString*)icon Action:(SEL)action Size:(int)size
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.bounds = CGRectMake(0, 0, size, size);
    [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    return btn;
}

#pragma mark - click handle
- (void)onBtnMuteVideoClicked:(UIButton*)button
{
    _muteVideo = !_muteVideo;
    if (_muteVideo) {
        [button setImage:[UIImage imageNamed:@"unmuteVideo"] forState:UIControlStateNormal];
    }
    else
        [button setImage:[UIImage imageNamed:@"muteVideo"] forState:UIControlStateNormal];

    if ([self.delegate respondsToSelector:@selector(onMuteVideoBtnClick:stateChanged:)]) {
        [self.delegate onMuteVideoBtnClick:self stateChanged:_muteVideo];
    }
}

- (void)onBtnMuteAudioClicked:(UIButton*)button
{
    _muteAudio = !_muteAudio;
    if (_muteAudio) {
        [button setImage:[UIImage imageNamed:@"unmuteAudio"] forState:UIControlStateNormal];
        self.audioVolumeIndicator.progress = 0.f;
    }
    else
        [button setImage:[UIImage imageNamed:@"muteAudio"] forState:UIControlStateNormal];
    
    if ([self.delegate respondsToSelector:@selector(onMuteAudioBtnClick:stateChanged:)]) {
        [self.delegate onMuteAudioBtnClick:self stateChanged:_muteAudio];
    }
}

- (void)onBtnScaleModeClicked:(UIButton*)button
{
    _fillMode = !_fillMode;
    if (_fillMode) {
        [button setImage:[UIImage imageNamed:@"scaleFit"] forState:UIControlStateNormal];
    }
    else
        [button setImage:[UIImage imageNamed:@"scaleFill"] forState:UIControlStateNormal];
    
    if ([self.delegate respondsToSelector:@selector(onScaleModeBtnClick:stateChanged:)]) {
        [self.delegate onScaleModeBtnClick:self stateChanged:_fillMode];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _touchPoint = self.center;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (!_enableMove)
        return;
    
    UITouch *touch = [touches anyObject];
    
    // 当前触摸点
    CGPoint currentPoint = [touch locationInView:self.superview];
    // 上一个触摸点
    CGPoint previousPoint = [touch previousLocationInView:self.superview];
    
    // 当前view的中点
    CGPoint center = self.center;
    
    center.x += (currentPoint.x - previousPoint.x);
    center.y += (currentPoint.y - previousPoint.y);
    
    if (center.x < self.width / 2)
        center.x = self.width / 2;
    
    if (center.x > self.superview.frame.size.width - self.width / 2) {
        center.x = self.superview.frame.size.width - self.width / 2;
    }
    
    if (center.y < self.height / 2)
        center.y = self.height / 2;
    
    if (center.y > self.superview.frame.size.height - self.height / 2) {
        center.y = self.superview.frame.size.height - self.height / 2;
    }
    
    // 修改当前view的中点(中点改变view的位置就会改变)
    self.center = center;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint center = self.center;
    
    if (fabs(center.x - _touchPoint.x) > 0.000001f || fabs(center.y - _touchPoint.y) > 0.0000001f)
        return;
    
    if ([self.delegate respondsToSelector:@selector(onViewTap:touchCount:)]) {
        [self.delegate onViewTap:self touchCount:touches.anyObject.tapCount];
    }
}

@end
