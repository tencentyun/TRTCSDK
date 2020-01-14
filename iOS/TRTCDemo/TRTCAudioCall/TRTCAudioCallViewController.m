//
//  TRTCAudioCallViewController.m
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/18.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TRTCAudioCallViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <TRTCCloud.h>
#import "ColorMacro.h"
#import "TRTCAudioCallUserModel.h"

///内部类Cell
@interface TRTCAudioCallUserCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellImgView;
@property (weak, nonatomic) IBOutlet UILabel *cellUserLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *volumeProgress;

@end

@implementation TRTCAudioCallUserCell
@end


@interface TRTCAudioCallViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TRTCCloudDelegate,TRTCAudioFrameDelegate> {
    TRTCCloud *trtc;
    NSMutableArray<TRTCAudioCallUserModel *> *remoteUserArray;
}

@property (weak, nonatomic) IBOutlet UICollectionView *userColectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;

@property (weak, nonatomic) IBOutlet UIButton *micBtn;      //麦克风
@property (weak, nonatomic) IBOutlet UIButton *audioBtn;     //静音
@property (weak, nonatomic) IBOutlet UIButton *audioRouteBtn;      //切换扬声器

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end

@implementation TRTCAudioCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"房间号 %u",(unsigned int)self.param.roomId];
    self.micBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.audioBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.audioRouteBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    remoteUserArray = [NSMutableArray array];
    trtc = [TRTCCloud sharedInstance];
    trtc.delegate = self;
    
    self.audioCallCloudManager.audioConfig.isVolumeEvaluationEnabled = YES;
    [_micBtn setSelected:self.audioCallCloudManager.audioConfig.isMuteLocalAudio];
    [_audioBtn setSelected:self.audioCallCloudManager.audioConfig.isSilent];
    [_audioRouteBtn setSelected:self.audioCallCloudManager.audioConfig.route];
    
    [self enterRoom];
}

#pragma mark 进入房间
- (void)enterRoom {
    [self.loadingView startAnimating];
    [self.audioCallCloudManager enterRoom];
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

- (void)updateUserView {
    if (remoteUserArray.count < 3) {
        self.collectionViewHeight.constant = self.userColectionView.frame.size.width / 2;
    } else {
        self.collectionViewHeight.constant = self.userColectionView.frame.size.width;
    }
    [self.userColectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return remoteUserArray.count <= 4 ? remoteUserArray.count : 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TRTCAudioCallUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TRTCAudioCallUserCell" forIndexPath:indexPath];
    if (indexPath.row < remoteUserArray.count) {
        TRTCAudioCallUserModel *user = remoteUserArray[indexPath.row];
        cell.cellUserLabel.text = user.uid;
        cell.cellImgView.image = [UIImage imageNamed:[self getAvatarImg:user.uid]];
        cell.volumeProgress.hidden = NO;
        cell.volumeProgress.progress = user.volume/100.0;
    } else {
        cell.cellUserLabel.text = @"";
        cell.cellImgView.image = nil;
        cell.volumeProgress.hidden = YES;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (remoteUserArray.count <= 4) {
        CGFloat border = collectionView.frame.size.width / 2;
        if (remoteUserArray.count % 2 == 1 && indexPath.row == remoteUserArray.count - 1) {
            return CGSizeMake(collectionView.frame.size.width, border);
        } else {
            return CGSizeMake(border, border);
        }
    } else {
        CGFloat border = collectionView.frame.size.width / 3;
        return CGSizeMake(border, border);
    }
}

#pragma mark - Event

- (IBAction)clickMicBtn:(id)sender {
    _micBtn.selected = !_micBtn.selected;
    [self.audioCallCloudManager setMuteLocalAudio:_micBtn.selected];
    if (_micBtn.selected) {
        //避免未收到音量回调一直显示有声音状态
        [self setRemoteVoiceProgress:self.param.userId volume:0];
    }
    [self toastTip:[NSString stringWithFormat:@"%@",_micBtn.selected ? @"您已关闭麦克风" : @"您已开启麦克风"]];
}

#pragma mark 点击静音
- (IBAction)clickAudioBtn:(id)sender {
    _audioBtn.selected = !_audioBtn.selected;
    [self.audioCallCloudManager setSilent:_audioBtn.selected];
    [self toastTip:[NSString stringWithFormat:@"%@",_audioBtn.selected ? @"您已静音" : @"您已取消静音"]];
}

#pragma mark 切换扬声器
- (IBAction)clickaudioRouteBtn:(id)sender {
    _audioRouteBtn.selected = !_audioRouteBtn.selected;
    [self.audioCallCloudManager setAudioRoute:_audioRouteBtn.selected];
    [self toastTip:[NSString stringWithFormat:@"%@",
    _audioRouteBtn.selected ? @"您已开启听筒" : @"您已开启扬声器"]];
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
        if (user.userId == nil) {
            user.userId = self.param.userId;
        }
        [self setRemoteVoiceProgress:user.userId volume:(int)user.volume];
    }
}

/**
 * WARNING 大多是不可恢复的错误，需要通过 UI 提示用户
 */
- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(nullable NSDictionary *)extInfo {
    NSString *msg = [NSString stringWithFormat:@"didOccurError: %@[%d]", errMsg, errCode];
    [self toastTip:msg];
    [self.loadingView stopAnimating];
    
    BOOL isStartingRecordInBackgroundError =
    errCode == ERR_MIC_START_FAIL &&
    [UIApplication sharedApplication].applicationState != UIApplicationStateActive;
    if (!isStartingRecordInBackgroundError) {
          NSString *msg = [NSString stringWithFormat:@"发生错误: %@ [%d]", errMsg, errCode];
        __weak __typeof(self) weakSelf = self;
          UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"已退房"
                                                                                   message:msg
                                                                            preferredStyle:UIAlertControllerStyleAlert];
          [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
              [weakSelf.audioCallCloudManager exitRoom];
          }]];
          [self presentViewController:alertController animated:YES completion:nil];
      }
    
}

#pragma mark 进入房间回调
- (void)onEnterRoom:(NSInteger)result {
    [self.loadingView stopAnimating];           //取消loading动画
    if (result >= 0) {
        [self toastTip:[NSString stringWithFormat:@"进房成功"]];
        TRTCAudioCallUserModel *user = [[TRTCAudioCallUserModel alloc] initWithUid:self.param.userId volume:0];
        [remoteUserArray addObject:user];
        [self updateUserView];
    } else {
        [self.audioCallCloudManager exitRoom];
        [self toastTip:[NSString stringWithFormat:@"进房失败: [%ld]", (long)result]];
    }
    //同步静音状态
    [self.audioCallCloudManager setSilent:self.audioBtn.selected];
}

#pragma mark 有用户进入房间回调
- (void)onRemoteUserEnterRoom:(NSString *)userId {
    for (TRTCAudioCallUserModel *user in remoteUserArray) {
        if ([userId isEqualToString:user.uid]) {
            return;
        }
    }
    TRTCAudioCallUserModel *user = [[TRTCAudioCallUserModel alloc] initWithUid:userId volume:0];
    [remoteUserArray addObject:user];
    [self updateUserView];
}

#pragma mark 有用户离开当前房间回调
- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason {
    for (TRTCAudioCallUserModel *user in remoteUserArray) {
        if ([userId isEqualToString:user.uid]) {
            [remoteUserArray removeObject:user];
            [self updateUserView];
            return;
        }
    }
}

#pragma mark 是否有声音上行回调
- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available {
    if(!available){
        //远端麦克风关闭,避免未收到音量回调一直显示有声音状态
        [self setRemoteVoiceProgress:userId volume:0];
    }
}

#pragma mark 根据远端userid,设置背景声音效果
- (void)setRemoteVoiceProgress:(NSString *)userid volume:(int)volume {
    for (TRTCAudioCallUserModel *user in remoteUserArray) {
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
    int index = asciiCode%10;
    return [NSString stringWithFormat:@"avatar%d_100",index];
}

- (void)dealloc {
    if (self.audioCallCloudManager) {
        [self.audioCallCloudManager exitRoom];
    }
    [TRTCCloud destroySharedIntance];
    NSLog(@"dealloc --- %@",[self class]);
}

@end
