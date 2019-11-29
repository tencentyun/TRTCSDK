/*
* Module:   TRTCSettingsEffectCell
*
* Function: 音效Cell, 包含音效的上传开关，音量调整，播放和停止操作。
*
*    1. TRTCSettingsEffectItem保存设置给Cell的音效数据TRTCAudioEffectParam，
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

- (void)didUpdateItem:(TRTCSettingsBaseItem *)item {
    if ([item isKindOfClass:[TRTCSettingsEffectItem class]]) {
        TRTCSettingsEffectItem *effectItem = (TRTCSettingsEffectItem *)item;
        self.titleLabel.text = [NSString stringWithFormat:@"音效%@", @(effectItem.effect.effectId + 1)];
        self.switcher.on = effectItem.effect.publish;
        self.slider.value = effectItem.effect.volume;
    }
}

- (TRTCAudioEffectManager *)manager {
    TRTCSettingsEffectItem *effectItem = (TRTCSettingsEffectItem *)self.item;
    return effectItem.manager;
}

- (TRTCAudioEffectParam *)effect {
    TRTCSettingsEffectItem *effectItem = (TRTCSettingsEffectItem *)self.item;
    return effectItem.effect;
}

#pragma mark - Events

- (void)onClickSwitch:(id)sender {
    [self.manager toggleEffectPublish:self.effect.effectId];
}

- (void)onSliderValueChange:(UISlider *)slider {
    [self.manager updateEffect:self.effect.effectId volume:slider.value];
}

- (void)onClickPlayButton:(UIButton *)button {
    [self.manager playEffect:self.effect.effectId];
}

- (void)onClickStopButton:(id)sender {
    [self.manager stopEffect:self.effect.effectId];
}

@end


@implementation TRTCSettingsEffectItem

- (instancetype)initWithEffect:(TRTCAudioEffectParam *)effect
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

