/*
* Module:   TRTCSettingsEffectCell
*
* Function: 音效Cell, 包含音效的上传开关，音量调整，播放和停止操作。
*
*    1. TRTCSettingsEffectItem保存设置给Cell的音效数据TRTCAudioEffectConfig，
*       以及音效管理对象TRTCAudioEffectManager
*
*/

#import "TRTCSettingsEffectCell.h"
#import "Masonry.h"
#import "ColorMacro.h"
#import "UISlider+TRTC.h"
#import "UIButton+TRTC.h"

@interface TRTCSettingsEffectCell ()

@property (strong, nonatomic) UISwitch *switcher;
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *stopButton;

@end

@implementation TRTCSettingsEffectCell

- (void)setupUI {
    [super setupUI];
    
    self.switcher = [[UISwitch alloc] init];
    [self.switcher addTarget:self action:@selector(onClickSwitch:) forControlEvents:UIControlEventValueChanged];
    self.switcher.onTintColor = UIColorFromRGB(0x05a764);
    [self.contentView addSubview:self.switcher];
    
    self.slider = [UISlider trtc_slider];
    [self.slider addTarget:self action:@selector(onSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    self.slider.minimumValue = 0;
    self.slider.maximumValue = 100;
    [self.contentView addSubview:self.slider];
    
    self.playButton = [UIButton trtc_iconButtonWithImage:[UIImage imageNamed:@"audio_play"]];
    [self.playButton setImage:[UIImage imageNamed:@"audio_pause"] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(onClickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.playButton];

    self.stopButton = [UIButton trtc_iconButtonWithImage:[UIImage imageNamed:@"audio_stop"]];
    [self.stopButton addTarget:self action:@selector(onClickStopButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.stopButton];

    [self.switcher mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(80);
    }];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.switcher.mas_trailing).offset(18);
    }];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.slider.mas_trailing).offset(18);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.stopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.playButton.mas_trailing).offset(4);
        make.trailing.equalTo(self.contentView).offset(-18);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self removeObservers];
}

- (void)dealloc {
    [self removeObservers];
}

- (void)didUpdateItem:(TRTCSettingsBaseItem *)item {
    if ([item isKindOfClass:[TRTCSettingsEffectItem class]]) {
        TRTCSettingsEffectItem *effectItem = (TRTCSettingsEffectItem *)item;
        self.titleLabel.text = [NSString stringWithFormat:@"音效%@", @(effectItem.effect.params.effectId + 1)];
        self.switcher.on = effectItem.effect.params.publish;
        self.slider.value = effectItem.effect.params.volume;
        [self observeEffectItem];
    }
}

- (TRTCAudioEffectManager *)manager {
    TRTCSettingsEffectItem *effectItem = (TRTCSettingsEffectItem *)self.item;
    return effectItem.manager;
}

- (TRTCAudioEffectConfig *)effect {
    TRTCSettingsEffectItem *effectItem = (TRTCSettingsEffectItem *)self.item;
    return effectItem.effect;
}

#pragma mark - Observation

- (void)observeEffectItem {
    [self.effect addObserver:self
                        forKeyPath:@"playState"
                           options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                           context:nil];
    [self.effect.params addObserver:self
                         forKeyPath:@"volume"
                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                            context:nil];
}

- (void)removeObservers {
    [self.effect removeObserver:self forKeyPath:@"playState"];
    [self.effect.params removeObserver:self forKeyPath:@"volume"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"playState"]) {
        self.playButton.selected = self.effect.playState == TRTCPlayStatePlaying;
    } else if ([keyPath isEqualToString:@"volume"]) {
        self.slider.value = self.effect.params.volume;
    }
}

#pragma mark - Events

- (void)onClickSwitch:(id)sender {
    [self.manager toggleEffectPublish:self.effect.params.effectId];
}

- (void)onSliderValueChange:(UISlider *)slider {
    [self.manager updateEffect:self.effect.params.effectId volume:slider.value];
}

- (void)onClickPlayButton:(UIButton *)button {
    switch (self.effect.playState) {
        case TRTCPlayStateIdle:
            [self.manager playEffect:self.effect.params.effectId];
            break;
        case TRTCPlayStatePlaying:
            [self.manager pauseEffect:self.effect.params.effectId];
            break;
        case TRTCPlayStateOnPause:
            [self.manager resumeEffect:self.effect.params.effectId];
            break;
    }
}

- (void)onClickStopButton:(id)sender {
    [self.manager stopEffect:self.effect.params.effectId];
}

@end

#pragma mark - TRTCSettingsEffectItem

@implementation TRTCSettingsEffectItem

- (instancetype)initWithEffect:(TRTCAudioEffectConfig *)effect
                       manager:(TRTCAudioEffectManager *)manager {
    if (self = [super init]) {
        _effect = effect;
        _manager = manager;
    }
    return self;
}

+ (Class)bindedCellClass {
    return [TRTCSettingsEffectCell class];
}

- (NSString *)bindedCellId {
    return [TRTCSettingsEffectItem bindedCellId];
}

@end

