/*
* Module:   TRTCBgmSettingsViewController
*
* Function: BGM设置页，用于控制BGM的播放，以及设置混响和变声效果
*
*    1. 通过TRTCBgmManager来管理BGM播放，以及混响和变声的设置
*
*    2. BGM的操作定义在TRTCBgmSettingsCell中
*
*/

#import "TRTCBgmSettingsViewController.h"
#import "TRTCBgmSettingsCell.h"

@interface TRTCBgmSettingsViewController()

@property (nonatomic, strong) TRTCSettingsSliderItem *bgmPlayoutVolumeItem;

@property (nonatomic, strong) TRTCSettingsSliderItem *bgmPublishVolumeItem;

@end

@implementation TRTCBgmSettingsViewController

- (NSString *)title {
    return @"BGM";
}

- (void)makeCustomRegistrition {
    [self.tableView registerClass:TRTCBgmSettingsItem.bindedCellClass
           forCellReuseIdentifier:TRTCBgmSettingsItem.bindedCellId];
}

- (NSArray<NSString *> *)voiceChanger {
    return @[
        @"关闭变声",
        @"熊孩子",
        @"萝莉",
        @"大叔",
        @"重金属",
        @"感冒",
        @"外国人",
        @"困兽",
        @"死肥仔",
        @"强电流",
        @"重机械",
        @"空灵",
    ];
}

- (NSArray<NSString *> *)reverbs {
    return @[
        @"关闭混响",
        @"KTV",
        @"小房间",
        @"大会堂",
        @"低沉",
        @"洪亮",
        @"金属声",
        @"磁性",
    ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof(self) wSelf = self;
    
    self.bgmPlayoutVolumeItem = [[TRTCSettingsSliderItem alloc] initWithTitle:@"本地音量"
                                            value:self.manager.bgmPlayoutVolume
                                              min:0
                                              max:100
                                             step:1
                                       continuous:YES
                                           action:^(float value) {
        [wSelf onChangeBgmPlayoutVolume:(NSInteger) value];
    }];
    
    self.bgmPublishVolumeItem = [[TRTCSettingsSliderItem alloc] initWithTitle:@"远程音量"
                                            value:self.manager.bgmPublishVolume
                                              min:0
                                              max:100
                                             step:1
                                       continuous:YES
                                           action:^(float value) {
        [wSelf onChangeBgmPublishVolume:(NSInteger) value];
    }];
    
    self.items = @[
        [[TRTCBgmSettingsItem alloc] initWithTitle:@"BGM" bgmManager:self.manager],
        [[TRTCSettingsSliderItem alloc] initWithTitle:@"BGM音量"
                                                value:self.manager.bgmVolume
                                                  min:0
                                                  max:100
                                                 step:1
                                           continuous:YES
                                               action:^(float value) {
            [wSelf onChangeBgmVolume:(NSInteger) value];
        }],
        self.bgmPlayoutVolumeItem,
        self.bgmPublishVolumeItem,
        [[TRTCSettingsSliderItem alloc] initWithTitle:@"MIC音量"
                                                value:self.manager.micVolume
                                                  min:0
                                                  max:100
                                                 step:1
                                           continuous:YES
                                               action:^(float value) {
            [wSelf onChangeMicVolume:(NSInteger) value];
        }],
        [[TRTCSettingsSelectorItem alloc] initWithTitle:@"混响设置"
                                                  items:[self reverbs]
                                          selectedIndex:self.manager.reverb
                                                 action:^(NSInteger index) {
            [wSelf onSelectReverbIndex:index];
        }],
        [[TRTCSettingsSelectorItem alloc] initWithTitle:@"变声设置"
                                                  items:[self voiceChanger]
                                          selectedIndex:self.manager.voiceChanger
                                                 action:^(NSInteger index) {
            [wSelf onSelectVoiceChangerIndex:index];
        }],
    ];
}

#pragma mark - Actions

- (void)onChangeBgmVolume:(NSInteger)volume {
    [self.manager setBgmVolume:volume];
    self.bgmPlayoutVolumeItem.sliderValue = volume;
    self.bgmPublishVolumeItem.sliderValue = volume;
}

- (void)onChangeBgmPlayoutVolume:(NSInteger)volume {
    [self.manager setBgmPlayoutVolume:volume];
}

- (void)onChangeBgmPublishVolume:(NSInteger)volume {
    [self.manager setBgmPublishVolume:volume];
}

- (void)onChangeMicVolume:(NSInteger)volume {
    [self.manager setMicVolume:volume];
}

- (void)onSelectReverbIndex:(NSInteger)index {
    [self.manager setReverb:index];
}

- (void)onSelectVoiceChangerIndex:(NSInteger)index {
    [self.manager setVoiceChanger:index];
}

@end
