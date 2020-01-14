/*
* Module:   TRTCBgmSettingsCell
*
* Function: BGM Cell, 包含播放、暂停、继续、停止操作，以及播放进度的显示
*
*    1. playButton根据BGM的播放状态，来切换播放、暂停和继续操作。
*
*    2. progressView用来显示BGM的播放进度
*
*/

#import "TRTCBgmSettingsCell.h"
#import "UIButton+TRTC.h"
#import "Masonry.h"
#import "ColorMacro.h"

@interface TRTCBgmSettingsCell ()

@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *stopButton;
@property (strong, nonatomic) UIProgressView *progressView;

@end

@implementation TRTCBgmSettingsCell

- (void)setupUI {
    [super setupUI];
    
    self.playButton = [UIButton trtc_iconButtonWithImage:[UIImage imageNamed:@"audio_play"]];
    [self.playButton setImage:[UIImage imageNamed:@"audio_pause"] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(onClickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.playButton];

    self.stopButton = [UIButton trtc_iconButtonWithImage:[UIImage imageNamed:@"audio_stop"]];
    [self.stopButton addTarget:self action:@selector(onClickStopButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.stopButton];

    self.progressView = [[UIProgressView alloc] init];
    self.progressView.progressTintColor = UIColorFromRGB(0x05a764);
    [self.contentView addSubview:self.progressView];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.stopButton.mas_leading).offset(-10);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.stopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.progressView.mas_leading).offset(-4);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-18);
        make.width.mas_equalTo(200);
    }];
}

- (void)didUpdateItem:(TRTCSettingsBaseItem *)item {
    if ([item isKindOfClass:[TRTCBgmSettingsItem class]]) {
        self.playButton.selected = self.manager.isPlaying;
        self.progressView.progress = self.manager.progress;
    }
}

- (TRTCBgmManager *)manager {
    TRTCBgmSettingsItem *bgmItem = (TRTCBgmSettingsItem *)self.item;
    return bgmItem.bgmManager;
}

#pragma mark - Events

- (void)onClickPlayButton:(UIButton *)button {
    if (self.manager.isOnPause) {
        [self.manager resumeBgm];
    } else if (self.manager.isPlaying) {
        [self.manager pauseBgm];
    } else {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"bgm_demo" ofType:@"mp3"];
        __weak __typeof(self) wSelf = self;
        [self.manager playBgm:path onProgress:^(float progress) {
            wSelf.progressView.progress = progress;
        } onCompleted:^{
            wSelf.playButton.selected = NO;
            wSelf.progressView.progress = 0;
        }];
    }
    button.selected = self.manager.isPlaying && !self.manager.isOnPause;
}

- (void)onClickStopButton:(id)sender {
    if (self.manager.isPlaying) {
        [self.manager stopBgm];
        self.playButton.selected = NO;
        self.progressView.progress = 0;
    }
}

@end


@implementation TRTCBgmSettingsItem

- (instancetype)initWithTitle:(NSString *)title bgmManager:(TRTCBgmManager *)bgmManager {
    if (self = [super init]) {
        self.title = title;
        self.bgmManager = bgmManager;
    }
    return self;
}

+ (Class)bindedCellClass {
    return [TRTCBgmSettingsCell class];
}

- (NSString *)bindedCellId {
    return [TRTCBgmSettingsItem bindedCellId];
}

@end

