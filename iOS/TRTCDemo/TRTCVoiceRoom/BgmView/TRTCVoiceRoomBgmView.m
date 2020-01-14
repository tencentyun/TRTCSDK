//
//  TRTCVoiceRoomBgmView.m
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/22.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TRTCVoiceRoomBgmView.h"

@interface TRTCVoiceRoomBgmView ()

@property (weak, nonatomic) IBOutlet UIView *touchView;

@property (weak, nonatomic) IBOutlet UIButton *playLocalBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *playLocalProgress;
@property (weak, nonatomic) IBOutlet UIButton *playNetBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *playNetProgress;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *micVolumeSlider;
@property (weak, nonatomic) IBOutlet UILabel *micVolumeLabel;
@property (nonatomic) PlayState state;


@end

@implementation TRTCVoiceRoomBgmView

- (id)initWithBgmManager:(TRTCVoiceRoomBgmManager *)bgmManager {
    self = [[[NSBundle mainBundle] loadNibNamed:@"TRTCVoiceRoomBgmView" owner:self options:nil] lastObject];
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [UIColor clearColor];
    self.bgmManager = bgmManager;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.touchView addGestureRecognizer:singleTap];
    
    return self;
}

#pragma mark 显示
- (void)show {
    if (!self.isShow) {
        self.volumeSlider.value = _bgmManager.bgmVolume;
        self.volumeLabel.text = [NSString stringWithFormat:@"%ld",(long)_bgmManager.bgmVolume];
        self.micVolumeSlider.value = _bgmManager.micVolume;
        self.micVolumeLabel.text = [NSString stringWithFormat:@"%ld",(long)_bgmManager.micVolume];
        
        self.alpha = 1;
        UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
        [keywindow addSubview:self];
        self.isShow = YES;
        [self.superview endEditing:YES];
    }
}

#pragma mark 关闭
- (void)dismiss {
    if (self.isShow) {
        self.isShow = NO;
        
        if (self.changeState) {
            self.changeState(_state);
        }
        
        [UIView animateWithDuration:0.2 // 动画时长
                         animations:^{
            self.alpha = 0;
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

#pragma mark 点击播放按钮
- (IBAction)clickBtn:(UIButton *)sender {
    if (_bgmManager.isPlaying) {    //播放中
        if (_bgmManager.isOnPause) {    //暂停中
            if (sender == _playLocalBtn) {
                if (_playLocalProgress.progress > 0 ) {
                    //本地继续播放
                    [_bgmManager resumeBgm];
                    _state = PLAY_LOCAL;
                    sender.selected = YES;
                }else{
                    [self playBgm:sender];
                }
            }else{
                if (_playNetProgress.progress > 0) {
                    //网络继续播放
                    [_bgmManager resumeBgm];
                    _state = PLAY_NET;
                    sender.selected = YES;
                }else{
                    [self playBgm:sender];
                }
            }
        }else{
            if (sender.selected) {//播放中
                [_bgmManager pauseBgm];         //暂停
                _state = PLAY_STOP;
                sender.selected = NO;////////////
            }else{      //放另一个
                [self playBgm:sender];
            }
        }
    }else{
        [self playBgm:sender];
    }
}

#pragma mark 播放
- (void)playBgm:(UIButton *)sender {
    if(_bgmManager.isPlaying){
        [_bgmManager stopBgm];
    }
    _playLocalProgress.progress = 0;
    _playNetProgress.progress = 0;
    BOOL isLocal = sender == _playLocalBtn;
    _playLocalBtn.selected = isLocal;
    _playNetBtn.selected = !isLocal;
    NSString *path;
    UIButton *btn;
    UIProgressView *progressView;
    PlayState local_net;
    if (isLocal) {
        path = [[NSBundle mainBundle] pathForResource:@"bgm_demo" ofType:@"mp3"];
        btn = _playLocalBtn;
        progressView = _playLocalProgress;
        local_net = PLAY_LOCAL;
    }else{
        path = @"https://bgm-1252463788.cos.ap-guangzhou.myqcloud.com/keluodiya.mp3";
        btn = _playNetBtn;
        progressView = _playNetProgress;
        local_net = PLAY_NET;
    }
    __weak TRTCVoiceRoomBgmView *weakSelf = self;
    [_bgmManager playBgm:path onProgress:^(float progress) {
        progressView.progress = progress;
        weakSelf.state = local_net;
        //播放中的歌曲切换导致一首播放完成显示停止状态,另一首在播放状态不对
        //所以一直调用更新状态
        if (!self.isShow) {
            if (self.changeState) {
                self.changeState(local_net);
            }
        }
    } onComplete:^{
        btn.selected = NO;
        progressView.progress = 0;
        weakSelf.state = PLAY_STOP;
        if (!self.isShow) {
            if (weakSelf.changeState) {
                weakSelf.changeState(PLAY_STOP);
            }
        }
    }];
}


#pragma mark 设置音量
- (IBAction)changeVolume:(UISlider *)sender {
    self.volumeLabel.text = [NSString stringWithFormat:@"%d",(int)sender.value];
    [_bgmManager setBgmVolume:(int)sender.value];
}

#pragma mark 设置麦克风音量
-(IBAction)changeMicVolume:(UISlider *)sender {
    self.micVolumeLabel.text = [NSString stringWithFormat:@"%d",(int)sender.value];
    [_bgmManager setMicVolume:(int)sender.value];
}

- (void)dealloc {
    NSLog(@"dealloc --- %@",[self class]);
}
@end
