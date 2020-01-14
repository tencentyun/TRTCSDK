//
//  TRTCVoiceRoomViewController.m
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/18.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TRTCVoiceRoomViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <TRTCCloud.h>
#import <TXLivePlayer.h>
#import "TRTCVoiceRoomBgmManager.h"
#import "TRTCVoiceRoomAudioEffectManager.h"
#import "TRTCVoiceRoomChangeVoiceView.h"
#import "TRTCVoiceRoomBgmView.h"
#import "TRTCVoiceRoomAudioEffectView.h"
#import "TRTCVoiceRoomMoreView.h"
#import "ColorMacro.h"
#import "MJExtension.h"
#import "SEIMessageModel.h"

#define TRTC_VOLUME_MAX     100
#define SEI_VOLUME_MAX      255

///内部类Cell
@interface UserCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cellImgView;
@property (weak, nonatomic) IBOutlet UIView *cellVoiceBgView;
@property (weak, nonatomic) IBOutlet UILabel *cellUserLabel;
@end

@implementation UserCell
#pragma mark 设置高亮颜色   说话状态
- (void)setHighlighted:(BOOL)highlighted {
}
@end

@interface TRTCVoiceRoomViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TRTCCloudDelegate,TRTCAudioFrameDelegate,TXLivePlayListener> {
    TRTCCloud *trtc;
    TXLivePlayer *txLivePlayer;
    NSMutableArray<UserModel *> *remoteUserArray;
}

@property (weak, nonatomic) IBOutlet UILabel *userCountLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *userColectionView;
@property (weak, nonatomic) IBOutlet UIView *voiceBgView;
@property (weak, nonatomic) IBOutlet UIImageView *userImg;
@property (weak, nonatomic) IBOutlet UIButton *switchRoleBtn;
@property (weak, nonatomic) IBOutlet UILabel *user1Label;
@property (weak, nonatomic) IBOutlet UIButton *micBtn;      //麦克风
@property (weak, nonatomic) IBOutlet UIButton *audioBtn;     //静音
@property (weak, nonatomic) IBOutlet UIButton *bgmBtn;      //背景音
@property (weak, nonatomic) IBOutlet UIButton *effectBtn;       //音效
@property (weak, nonatomic) IBOutlet UIButton *voiceChangeBtn;      //变声
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;         //更多
@property (weak, nonatomic) IBOutlet UIView *voiceChangeStateView;
@property (weak, nonatomic) IBOutlet UILabel *voiceChangeLabel;
@property (weak, nonatomic) IBOutlet UIView *bgmStateView;
@property (weak, nonatomic) IBOutlet UILabel *bgmLabel;
@property (weak, nonatomic) IBOutlet UIView *reverbStateView;
@property (weak, nonatomic) IBOutlet UILabel *reverbLabel;
@property (weak, nonatomic) IBOutlet UILabel *playStateLabel;
@property (weak, nonatomic) IBOutlet UIButton *switchPlayStateBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@property (strong,nonatomic) TRTCVoiceRoomBgmManager *bgmManager;
@property (strong,nonatomic) TRTCVoiceRoomChangeVoiceView *changeVoiceView;
@property (strong,nonatomic) TRTCVoiceRoomBgmView *bgmView;
@property (assign,nonatomic) PlayState nowPlayState;
@property (strong,nonatomic) TRTCVoiceRoomAudioEffectManager *audioEffectManager;
@property (strong,nonatomic) TRTCVoiceRoomAudioEffectView *audioEffectView;
@property (strong,nonatomic) TRTCVoiceRoomMoreView *moreView;
@end

@implementation TRTCVoiceRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"房间号 %u",(unsigned int)self.param.roomId];
    self.micBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.audioBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.bgmBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.effectBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.voiceChangeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.moreBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    remoteUserArray = [NSMutableArray array];
    trtc = [TRTCCloud sharedInstance];
    trtc.delegate = self;

    txLivePlayer = [[TXLivePlayer alloc] init];
    txLivePlayer.delegate = self;
    [txLivePlayer setupVideoWidget:CGRectZero containView:nil insertIndex:0];
    TXLivePlayConfig *config = [[TXLivePlayConfig alloc] init];
    config.enableMessage = YES;
    [txLivePlayer setConfig:config];

    self.voiceRoomCloudManager.audioConfig.isVolumeEvaluationEnabled = YES;
    _bgmManager = [[TRTCVoiceRoomBgmManager alloc] initWithTrtc:trtc];
    _audioEffectManager = [[TRTCVoiceRoomAudioEffectManager alloc] initWithTrtc:trtc];
    [_micBtn setSelected:self.voiceRoomCloudManager.audioConfig.isMuteLocalAudio];
    [_audioBtn setSelected:self.voiceRoomCloudManager.audioConfig.isSilent];
    
    if (self.param.role == TRTCRoleAnchor) {
        self.switchRoleBtn.enabled = NO;        //主播不能切换身份
    }
    [self refreshView:self.param.role];
    [self enterRoom];
}

#pragma mark 进入房间
- (void)enterRoom {
    [self.loadingView startAnimating];
    [self.voiceRoomCloudManager enterRoom];
}

#pragma mark 观众以CDN方式播放
- (void)playWithCDN {
    [txLivePlayer startPlay:[self.voiceRoomCloudManager getCdnUrl] type:PLAY_TYPE_LIVE_FLV];
    [txLivePlayer setMute:_audioBtn.selected];
    [self.loadingView startAnimating];
}

#pragma mark 更新在线主播数
- (void)refreshUserCount {
    self.userCountLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)remoteUserArray.count+1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    //屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
#if !TARGET_IPHONE_SIMULATOR
    //是否有麦克风权限
    AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (statusAudio == AVAuthorizationStatusDenied) {
        [self toastTip:@"获取麦克风权限失败，请前往隐私-麦克风设置里面打开应用权限"];
        return;
    }
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark mark -UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

#pragma mark mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((collectionView.frame.size.width-40)/3, (collectionView.frame.size.height-10)/2);
}

#pragma mark mark 每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"userCell" forIndexPath:indexPath];
    if (indexPath.row < remoteUserArray.count) {
        UserModel *user = remoteUserArray[indexPath.row];
        cell.cellUserLabel.text = user.uid;
        cell.cellImgView.image = [UIImage imageNamed:[self getAvatarImg:user.uid]];
        NSLog(@"TEST - volume: %@", @(user.volume));
        cell.cellVoiceBgView.alpha = user.volume < 30 ? 0 : 1;
    }else{
        cell.cellUserLabel.text = @"虚位以待";
        cell.cellImgView.image = nil;
        cell.cellVoiceBgView.alpha = 0;
    }
    return cell;
}

#pragma mark 选择播放模式
- (IBAction)switchPlayState:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    self.voiceBgView.alpha = 0;
    
    if (sender.selected) {          //切换为CDN播放
        [self.voiceRoomCloudManager exitRoom];
        self.playStateLabel.text = @"CDN播放中";
        [remoteUserArray removeAllObjects];
        [_userColectionView reloadData];
        [self refreshUserCount];
        [self playWithCDN];
    } else {      //低延时播放
        self.playStateLabel.text = @"低延时播放中";
        self.user1Label.text = @"虚位以待";
        self.userImg.image = nil;
        [remoteUserArray removeAllObjects];
        [_userColectionView reloadData];
        [self refreshUserCount];
        [txLivePlayer stopPlay];
        [self enterRoom];
    }
}

#pragma mark 点击切换角色
- (IBAction)clickSwitchRoleBtn:(id)sender {
    [self popAlert];
}

#pragma mark 切换角色弹出框
- (void)popAlert {
    NSString *str = @"";
    if (self.param.role == TRTCRoleAudience) {
        str = @"上麦";
    }else{
        str = @"下麦";
    }
    __weak __typeof(self) weakself = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:str style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself switchRole];
    }]];
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alertController animated:true completion:nil];
}

#pragma mark 切换角色
- (void)switchRole {
    if (self.param.role == TRTCRoleAudience) {
        //切换为主播
        self.param.role = TRTCRoleAnchor;
        [self refreshView:TRTCRoleAnchor];
        //处理切换回主播后的变声效果 显示状态
        if (self.bgmManager.voiceChanger != TRTCVoiceChangerType_0) {
            [self.bgmManager setVoiceChanger:self.bgmManager.voiceChanger];
            self.voiceChangeBtn.selected = YES;
            self.voiceChangeStateView.hidden = NO;
        }
        if (self.bgmManager.reverb != TRTCReverbType_0) {
            [self.bgmManager setReverb:self.bgmManager.reverb];
            //        self.moreBtn.selected = YES;
            self.reverbStateView.hidden = NO;
        }
        if (txLivePlayer.isPlaying) {
            [txLivePlayer stopPlay];
            [self enterRoom];
        }else{
            [self.voiceRoomCloudManager switchRole:TRTCRoleAnchor];
        }
        
    }else{
        //切换为观众
        self.param.role = TRTCRoleAudience;
        [self refreshView:TRTCRoleAudience];
        //停止bgm 音效
        if (_bgmManager.isPlaying) {
            [_bgmManager stopBgm];
        }
        [_audioEffectManager stopAllEffects];
        
        [self.voiceRoomCloudManager switchRole:TRTCRoleAudience];
    }
    [self toastTip:[NSString stringWithFormat:@"切换到%@身份",
                    self.param.role == TRTCRoleAnchor ? @"主播" : @"观众"]];
}

#pragma mark 根据角色刷新view
- (void)refreshView:(TRTCRoleType)type {
    if (type == TRTCRoleAnchor) {
        self.userImg.image = [UIImage imageNamed:[self getAvatarImg:self.param.userId]];
        self.user1Label.text = self.param.userId;
        self.playStateLabel.hidden = YES;
        self.switchPlayStateBtn.hidden = YES;
        
        [_micBtn setImage:[UIImage imageNamed:@"mic_on"] forState:UIControlStateNormal];
        [_micBtn setImage:[UIImage imageNamed:@"mic_off"] forState:UIControlStateSelected];
        [_bgmBtn setImage:[UIImage imageNamed:@"music_off"] forState:UIControlStateNormal];
        [_effectBtn setImage:[UIImage imageNamed:@"voice_effector_off"] forState:UIControlStateNormal];
        [_voiceChangeBtn setImage:[UIImage imageNamed:@"voice_changer_off"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"more_off"] forState:UIControlStateNormal];
    } else if (type == TRTCRoleAudience){
        self.userImg.image = nil;
        self.user1Label.text = @"虚位以待";
        self.playStateLabel.hidden = NO;
        self.playStateLabel.text = @"低延时播放中";
        self.switchPlayStateBtn.hidden = NO;
        self.switchPlayStateBtn.selected = NO;
        
        self.voiceBgView.alpha = 0;
        self.bgmBtn.selected = NO;
        self.voiceChangeBtn.selected = NO;
        self.effectBtn.selected = NO;
        self.bgmStateView.hidden = YES;
        self.bgmLabel.text = @"";
        self.voiceChangeStateView.hidden = YES;
        self.reverbStateView.hidden = YES;
        
        [_micBtn setImage:[UIImage imageNamed:@"mic_dissable"] forState:UIControlStateNormal];
        [_micBtn setImage:[UIImage imageNamed:@"mic_dissable"] forState:UIControlStateSelected];
        [_bgmBtn setImage:[UIImage imageNamed:@"music_dissable"] forState:UIControlStateNormal];
        [_effectBtn setImage:[UIImage imageNamed:@"voice_effector_dissable"] forState:UIControlStateNormal];
        [_voiceChangeBtn setImage:[UIImage imageNamed:@"voice_changer_disable"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"more_disable"] forState:UIControlStateNormal];
    }
}

#pragma mark 点击禁麦
- (IBAction)clickMicBtn:(id)sender {
    
    if (_param.role == TRTCRoleAnchor) {
        _micBtn.selected = !_micBtn.selected;
        [self.voiceRoomCloudManager setMuteLocalAudio:_micBtn.selected];
        if (_micBtn.selected) {
            //避免未收到音量回调一直显示有声音状态
            self.voiceBgView.alpha = 0;
        }
        [self toastTip:[NSString stringWithFormat:@"%@",
                        _micBtn.selected ? @"您已关闭麦克风" : @"您已开启麦克风"]];
    }else{
        [self toastTip:@"主播才能操作哦!"];
    }
}

#pragma mark 点击静音
- (IBAction)clickAudioBtn:(id)sender {
    _audioBtn.selected = !_audioBtn.selected;
    if (_param.role == TRTCRoleAnchor) {
        [self.voiceRoomCloudManager setSilent:_audioBtn.selected];
    }else{
        if (self.switchPlayStateBtn.selected) {
            self.voiceRoomCloudManager.audioConfig.isSilent = _audioBtn.selected;
            [txLivePlayer setMute:self.voiceRoomCloudManager.audioConfig.isSilent];
        }else{
            [self.voiceRoomCloudManager setSilent:_audioBtn.selected];
        }
    }
    [self toastTip:[NSString stringWithFormat:@"%@",
                    self.voiceRoomCloudManager.audioConfig.isSilent ? @"您已静音" : @"您已取消静音"]];
}

#pragma mark 点击背景音乐设置
- (IBAction)clickBgmBtn:(id)sender {
    if (_param.role == TRTCRoleAnchor) {
        [self.bgmView show];
        self.bgmBtn.selected = YES;
    }else{
        [self toastTip:@"主播才能操作哦!"];
    }
}

#pragma mark 设置BGMView
- (TRTCVoiceRoomBgmView *)bgmView {
    if (!_bgmView) {
        _bgmView = [[TRTCVoiceRoomBgmView alloc] initWithBgmManager:_bgmManager];
        
        __weak TRTCVoiceRoomViewController *weakSelf = self;
        _bgmView.changeState = ^(PlayState state) {
            if (state == PLAY_STOP || state != weakSelf.nowPlayState) {
                weakSelf.nowPlayState = state;
                if (state == PLAY_STOP) {
                    weakSelf.bgmBtn.selected = NO;
                    weakSelf.bgmStateView.hidden = YES;
                    weakSelf.bgmLabel.text = @"";
                }else{
                    weakSelf.bgmBtn.selected = YES;
                    weakSelf.bgmStateView.hidden = NO;
                    if (state == PLAY_LOCAL) {
                        weakSelf.bgmLabel.text = @"本地音乐";
                    }else if (state == PLAY_NET){
                        weakSelf.bgmLabel.text = @"网络音乐";
                    }
                }
            }
        };
    }
    return _bgmView;
}

#pragma mark 点击音效
- (IBAction)clickEffectBtn:(id)sender {
    if (_param.role == TRTCRoleAnchor) {
        [self.audioEffectView show];
    }else{
        [self toastTip:@"主播才能操作哦!"];
    }
}

#pragma mark 设置音效View
- (TRTCVoiceRoomAudioEffectView *)audioEffectView {
    if (!_audioEffectView) {
        _audioEffectView = [[TRTCVoiceRoomAudioEffectView alloc] initWithManager:_audioEffectManager];
        __weak TRTCVoiceRoomViewController *weakSelf = self;
        _audioEffectView.changeState = ^(BOOL flag) {
            weakSelf.effectBtn.selected = flag;
        };
    }
    return _audioEffectView;
}


#pragma mark 点击变声
- (IBAction)clickVoiceChangeBtn:(id)sender {
    if (_param.role == TRTCRoleAnchor) {
        [self.changeVoiceView show];
        self.voiceChangeBtn.selected = YES;
    }else{
        [self toastTip:@"主播才能操作哦!"];
    }
}

#pragma mark 设置特效
- (TRTCVoiceRoomChangeVoiceView *)changeVoiceView {
    if (!_changeVoiceView) {
        _changeVoiceView = [[TRTCVoiceRoomChangeVoiceView alloc]initWithBgmManager:_bgmManager];
        
        __weak TRTCVoiceRoomViewController *weakSelf = self;
        _changeVoiceView.changeState = ^(NSString * _Nonnull state) {
            if (weakSelf.bgmManager.voiceChanger == TRTCVoiceChangerType_0) {
                weakSelf.voiceChangeBtn.selected = NO;
                weakSelf.voiceChangeLabel.text = @"";
                weakSelf.voiceChangeStateView.hidden = YES;
            }else{
                weakSelf.voiceChangeBtn.selected = YES;
                if ( ![weakSelf.voiceChangeLabel.text isEqualToString:state]) {
                    [weakSelf toastTip:[NSString stringWithFormat:@"变声器已启用 %@ 特效",state]];
                    weakSelf.voiceChangeLabel.text = state;
                    weakSelf.voiceChangeStateView.hidden = NO;
                }
            }
        };
    }
    return _changeVoiceView;
}

#pragma mark 点击更多
- (IBAction)clickMoreBtn:(id)sender {
    if (_param.role == TRTCRoleAnchor) {
        [self.moreView show];
        self.moreBtn.selected = YES;
    }else{
        [self toastTip:@"主播才能操作哦!"];
    }
}

#pragma mark 更多View
- (TRTCVoiceRoomMoreView *)moreView {
    if (!_moreView) {
        _moreView = [[TRTCVoiceRoomMoreView alloc] initWithBgmManager:_bgmManager];
        __weak TRTCVoiceRoomViewController *weakSelf = self;
        _moreView.changeState = ^(NSString * _Nonnull state) {
            weakSelf.moreBtn.selected = NO;
            if (weakSelf.bgmManager.reverb == TRTCReverbType_0) {
                //                weakSelf.moreBtn.selected = NO;
                weakSelf.reverbLabel.text = @"";
                weakSelf.reverbStateView.hidden = YES;
            }else{
                //                weakSelf.moreBtn.selected = YES;
                if ( ![weakSelf.reverbLabel.text isEqualToString:state]) {
                    [weakSelf toastTip:[NSString stringWithFormat:@"混响已开启 %@ 效果",state]];
                    weakSelf.reverbLabel.text = state;
                    weakSelf.reverbStateView.hidden = NO;
                }
            }
        };
    }
    return _moreView;
}

#pragma mark Toast
- (void)toastTip:(NSString *)toastInfo {
    
    __block UILabel *toastLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-100, self.view.frame.size.width-40, 40)];
    
    toastLabel.textAlignment = NSTextAlignmentCenter;
    toastLabel.userInteractionEnabled = NO;
    toastLabel.text = toastInfo;
    toastLabel.textColor = UIColorFromRGB(0xafafaf);
    toastLabel.backgroundColor = [UIColor blackColor];
    toastLabel.alpha = 1;
    toastLabel.layer.cornerRadius = 10;
    toastLabel.layer.masksToBounds = YES;
    
    [self.view addSubview:toastLabel];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [toastLabel removeFromSuperview];
    });
}

#pragma mark 音量大小的回调
- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume {
    for (TRTCVolumeInfo *user in userVolumes) {
        user.volume = user.volume / (TRTC_VOLUME_MAX / 100.0);

        if (user.userId == nil) {
            [UIView animateWithDuration:0.3 animations:^{
                self.voiceBgView.alpha = (user.volume < 30 || self.micBtn.selected) ? 0 : 1;
            }];
            
        }else{
            [self setRemoteVoiceBg:user.userId volume:(int)user.volume];
        }
    }
}

- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(nullable NSDictionary *)extInfo {
    // 有些手机在后台时无法启动音频，这种情况下，TRTC会在恢复到前台后尝试重启音频，不应调用exitRoom。
    BOOL isStartingRecordInBackgroundError =
        errCode == ERR_MIC_START_FAIL &&
        [UIApplication sharedApplication].applicationState != UIApplicationStateActive;
    
    if (!isStartingRecordInBackgroundError) {
        NSString *msg = [NSString stringWithFormat:@"发生错误: %@ [%d]", errMsg, errCode];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"已退房"
                                                                                 message:msg
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
            [self.voiceRoomCloudManager exitRoom];
            [self.loadingView stopAnimating];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark 进入房间回调
- (void)onEnterRoom:(NSInteger)result {
    [self.loadingView stopAnimating];           //取消loading动画
    if (result >= 0) {
        [self toastTip:[NSString stringWithFormat:@"进房成功"]];
    } else {
        [self.voiceRoomCloudManager exitRoom];
        [self toastTip:[NSString stringWithFormat:@"进房失败: [%ld]", (long)result]];
    }
    [self.voiceRoomCloudManager setSilent:self.audioBtn.selected];
}

#pragma mark 有用户进入房间回调
- (void)onRemoteUserEnterRoom:(NSString *)userId {
    for (UserModel *user in remoteUserArray) {
        if ([userId isEqualToString:user.uid]) {
            return;
        }
    }
    UserModel *user = [[UserModel alloc] initWithUid:userId volume:0];
    [remoteUserArray addObject:user];
    [_userColectionView reloadData];
    [self refreshUserCount];
}

#pragma mark 有用户离开当前房间回调
- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason {
    for (UserModel *user in remoteUserArray) {
        if ([userId isEqualToString:user.uid]) {
            [remoteUserArray removeObject:user];
            [_userColectionView reloadData];
            [self refreshUserCount];
            return;
        }
    }
}

#pragma mark 是否有声音上行回调
- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available {
    if(!available){
        //远端麦克风关闭,避免未收到音量回调一直显示有声音状态
        [self setRemoteVoiceBg:userId volume:0];
    }
}

#pragma mark 音效播放完成回调
- (void)onAudioEffectFinished:(int)effectId code:(int)code {
    //    [self toastTip:[NSString stringWithFormat:@"%d 播放完成",effectId]];
    [self.audioEffectView playFinished:effectId];
}

#pragma mark 根据远端userid,设置背景声音效果
- (void)setRemoteVoiceBg:(NSString *)userid volume:(int)volume {
    for (UserModel *user in remoteUserArray) {
        if ([userid isEqualToString:user.uid]) {
            user.volume = volume;
            [_userColectionView reloadData];
            return;
        }
    }
}

#pragma mark 根据userid 选择图片
- (NSString *)getAvatarImg:(NSString *)userid {
    int asciiCode = [userid characterAtIndex:userid.length-1];
    //    NSLog(@"getAvatarImg------- %d",asciiCode);
    int index = asciiCode%10;
    //    int index = [userid hash]%10;
    return [NSString stringWithFormat:@"avatar%d_100",index];
}

#pragma mark TXLivePlayListener
- (void)onPlayEvent:(int)EvtID withParam:(NSDictionary *)param {
    if (EvtID == PLAY_EVT_PLAY_BEGIN) {
        [self.loadingView stopAnimating];
        [self toastTip:@"CDN播放"];
    } else if (EvtID == PLAY_EVT_PLAY_END){
        [self.loadingView stopAnimating];
        [self toastTip:@"播放结束"];
    } else if (EvtID < 0 ){
        [self.loadingView stopAnimating];
        [self toastTip:[NSString stringWithFormat:@"播放失败  %d",EvtID]];
        [remoteUserArray removeAllObjects];
        [_userColectionView reloadData];
        [self refreshUserCount];
    } else if (EvtID == PLAY_EVT_GET_MESSAGE){
        NSString *strMsg = [[NSString alloc] initWithData:param[EVT_GET_MSG] encoding:NSUTF8StringEncoding];
        [self handleSEIMessage:strMsg];
    }
}

#pragma mark CDN播放接收到SEI消息
- (void)handleSEIMessage:(NSString *)msg{
    SEIMessageModel *msgModel = [SEIMessageModel mj_objectWithKeyValues:msg];
    if (msgModel) {
        if (msgModel.regions) {
            remoteUserArray = msgModel.regions;
            for (UserModel *user in remoteUserArray) {
                user.volume = user.volume / (SEI_VOLUME_MAX / 100.0);
                
                if ([user.uid isEqualToString:self.param.userId]) {
                    [remoteUserArray removeObject:user];
                }
            }
            [_userColectionView reloadData];
            [self refreshUserCount];
        }
    }
}
//TXLivePlayListener 网络状态通知
- (void)onNetStatus:(NSDictionary *)param {
    
}

- (void)dealloc {
    if (txLivePlayer.isPlaying) {
        [txLivePlayer stopPlay];
    }
    if (self.voiceRoomCloudManager) {
        [self.voiceRoomCloudManager exitRoom];
    }
    [TRTCCloud destroySharedIntance];
    NSLog(@"dealloc --- %@",[self class]);
}

@end
