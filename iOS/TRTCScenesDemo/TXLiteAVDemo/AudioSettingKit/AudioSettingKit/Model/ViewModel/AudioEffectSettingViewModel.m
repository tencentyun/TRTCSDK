//
//  AudioEffectSettingViewModel.m
//  TCAudioSettingKit
//
//  Created by abyyxwang on 2020/5/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "AudioEffectSettingViewModel.h"
#import "TCAudioScrollMenuCellModel.h"
#import "TCMusicSelectedModel.h"
#import "TCAudioSettingManager.h"

@interface AudioEffectSettingViewModel ()<TCAudioMusicPlayStatusDelegate>

@property (nonatomic, strong) TCASKitTheme *theme;
@property (nonatomic, strong) TCAudioSettingManager* manager;

@property (nonatomic, assign) NSInteger currentReverb;
@property (nonatomic, assign) NSInteger currentChangerType;

@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isPlayComplete;

@property (nonatomic, strong) NSString* currentMusicPath;
@property (nonatomic, assign) NSInteger bgmID;

@property (nonatomic, assign) NSInteger currentMusicVolum;
@property (nonatomic, assign) CGFloat currentPitchVolum;

@end

@implementation AudioEffectSettingViewModel

#define L(x) [self.theme localizedString:x]

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.theme = [[TCASKitTheme alloc] init];
        self.currentMusicVolum = 100;
        self.currentPitchVolum = 0;
        [self createDataSource];
    }
    return self;
}

- (TCAudioSettingManager *)manager {
    if (!_manager) {
        _manager = [[TCAudioSettingManager alloc] init];
        _manager.delegate = self;
    }
    return _manager;
}

- (void) setAudioEffectManager:(TXAudioEffectManager *)manager {
    [self.manager setAudioEffectManager:manager];
}

- (void)createDataSource {
    self.voiceChangeSources = [self createVoiceChangeDataSource];
    self.reverberationSources = [self createReverberationDataSource];
    self.musicSources = [self createMusicDataSources];
}

- (NSArray<TCAudioScrollMenuCellModel *> *)createVoiceChangeDataSource{
    NSArray *titleArray = @[
        L(@"ASKit.MenuItem.Original"),
        L(@"ASKit.MenuItem.Naughty boy"),
        L(@"ASKit.MenuItem.Little girl"),
        L(@"ASKit.MenuItem.Middle-aged man"),
        L(@"ASKit.MenuItem.Heavy metal"),
        L(@"ASKit.MenuItem.Being cold"),
        L(@"ASKit.MenuItem.Non-native speaker"),
        L(@"ASKit.MenuItem.Furious animal"),
        L(@"ASKit.MenuItem.Fat otaku"),
        L(@"ASKit.MenuItem.Strong electric current"),
        L(@"ASKit.MenuItem.Robot"),
        L(@"ASKit.MenuItem.Ethereal voice")
    ];
    NSArray *iconNameArray = @[@"voiceChange_normal_close", @"voiceChange_xionghaizi", @"voiceChange_luoli", @"voiceChange_dashu", @"voiceChange_zhongjinshu", @"voiceChange_ganmao", @"voiceChange_waiguo", @"voiceChange_kunshou", @"voiceChange_feizhai", @"voiceChange_qiangdianliu", @"voiceChange_jixie", @"voiceChange_konglin"];
    NSArray *iconSelectedNameArray = @[@"voiceChange_normal_open", @"voiceChange_xionghaizi", @"voiceChange_luoli", @"voiceChange_dashu", @"voiceChange_zhongjinshu", @"voiceChange_ganmao", @"voiceChange_waiguo", @"voiceChange_kunshou", @"voiceChange_feizhai", @"voiceChange_qiangdianliu", @"voiceChange_jixie", @"voiceChange_konglin"];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:2];
    for (int index = 0; index < titleArray.count; index += 1) {
        NSString *title = titleArray[index];
        NSString *normalIconName = iconNameArray[index];
        NSString *selectedIconName = iconSelectedNameArray[index];
        TCAudioScrollMenuCellModel *model = [[TCAudioScrollMenuCellModel alloc] init];
        model.title = title;
        model.actionID = index;
        if ([title isEqualToString:L(@"ASKit.MenuItem.Original")]) {
            model.selected = YES;
        } else {
            model.selected = NO;
        }
        model.icon = [self.theme imageNamed:normalIconName];
        model.selectedIcon = [self.theme imageNamed:selectedIconName];
        model.action = ^{
            [self.manager setVoiceChangerTypeWithValue:index];
            self.currentChangerType = index;
        };
        if (model.icon) {
            [result addObject:model];
        }
    }
    return result;
}

- (NSArray<TCAudioScrollMenuCellModel *> *)createReverberationDataSource{
    NSArray *titleArray = @[
        L(@"ASKit.MenuItem.No effect"),
        L(@"ASKit.MenuItem.Karaoke room"),
        L(@"ASKit.MenuItem.Small room"),
        L(@"ASKit.MenuItem.Big hall"),
        L(@"ASKit.MenuItem.Deep"),
        L(@"ASKit.MenuItem.Resonant"),
        L(@"ASKit.MenuItem.Metallic"),
        L(@"ASKit.MenuItem.Husky")
    ];
    NSArray *iconNameArray = @[@"Reverb_normal_close", @"Reverb_KTV", @"Reverb_literoom", @"Reverb_dahuitang", @"Reverb_dicheng", @"Reverb_hongliang", @"Reverb_zhongjinshu", @"Reverb_cixin"];
    NSArray *iconSelectedNameArray =  @[@"Reverb_normal_open", @"Reverb_KTV", @"Reverb_literoom", @"Reverb_dahuitang", @"Reverb_dicheng", @"Reverb_hongliang", @"Reverb_zhongjinshu", @"Reverb_cixin"];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:2];
    for (int index = 0; index < titleArray.count; index += 1) {
        NSString *title = titleArray[index];
        NSString *normalIconName = iconNameArray[index];
        NSString *selectedIconName = iconSelectedNameArray[index];
        TCAudioScrollMenuCellModel *model = [[TCAudioScrollMenuCellModel alloc] init];
        model.actionID = index;
        model.title = title;
        if ([title isEqualToString:L(@"ASKit.MenuItem.No effect")]) {
            model.selected = YES;
        } else {
            model.selected = NO;
        }
        model.icon = [self.theme imageNamed:normalIconName];
        model.selectedIcon = [self.theme imageNamed:selectedIconName];
        model.action = ^{
            [self.manager setReverbTypeWithValue:index];
            self.currentReverb = index;
        };
        if (model.icon) {
            [result addObject:model];
        }
    }
    return result;
}

- (NSArray<TCMusicSelectedModel *> *)createMusicDataSources {
    NSArray* musicsData = @[
        @{
            @"name": L(@"ASKit.MenuItem.Surround sound test 1"),
            @"singer": L(@"ASKit.MenuItem.Unknown"),
            @"url": @"https://liteav.sdk.qcloud.com/app/res/bgm/testmusic1.mp3"
        },
        @{
            @"name": L(@"ASKit.MenuItem.Surround sound test 2"),
            @"singer": L(@"ASKit.MenuItem.Unknown"),
            @"url": @"https://liteav.sdk.qcloud.com/app/res/bgm/testmusic2.mp3"
        },
        @{
            @"name": L(@"ASKit.MenuItem.Surround sound test 3"),
            @"singer": L(@"ASKit.MenuItem.Unknown"),
            @"url": @"https://liteav.sdk.qcloud.com/app/res/bgm/testmusic3.mp3"
        }
    ];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:2];
    __weak __typeof(self) weakSelf = self;
    for (int index = 0; index < musicsData.count; index += 1) {
        NSDictionary* dic = musicsData[index];
        TCMusicSelectedModel* model = [[TCMusicSelectedModel alloc] init];
        model.musicID = 1000 + index;
        model.musicName = dic[@"name"];
        model.singerName = dic[@"singer"];
        model.resourceURL = dic[@"url"];
        model.isLocal = NO;
        
        model.action = ^(BOOL isSelected){
            NSLog(@"选择了音乐%@", dic[@"name"]);
            [weakSelf stopPlay];
            [weakSelf playMusicWithPath:dic[@"url"] bgmID:1000 + index];
        };
        [result addObject:model];
    }
    
    return result;
}

- (NSInteger)getcurrentMusicTatolDurationInMs {
    return [self.manager getcurrentMusicTatolDurationInMs];
}

- (void)setMusicVolum:(NSInteger)volum {
    self.currentMusicVolum = volum;
    [self.manager setBGMVolume:volum];
}

- (void)setVoiceVolum:(NSInteger)volum {
    [self.manager setVoiceVolume:volum];
}

- (void)setPitchVolum:(CGFloat)volum {
    self.currentPitchVolum = volum;
    [self.manager setBGMPitch:volum];
}

/// 播放音乐
/// @param path 音乐路径
/// @param bgmID 音乐ID
- (void)playMusicWithPath:(NSString *)path bgmID:(NSInteger)bgmID {
    self.currentMusicPath = path;
    self.bgmID = bgmID;
    [self.manager playMusicWithPath:path bgmID:bgmID];
    [self.manager setBGMVolume:self.currentMusicVolum];
    [self.manager setBGMPitch:self.currentPitchVolum];
}

- (void)stopPlay {
    self.isPlaying = NO;
    [self.manager stopPlay];
}

- (void)pausePlay {
    self.isPlaying = NO;
    [self.manager pausePlay];
}

- (void)resumePlay {
    if (self.isPlayComplete) {
        if (self.currentMusicPath != nil && self.bgmID != -1) {
            [self.manager playMusicWithPath:self.currentMusicPath bgmID:self.bgmID];
        }
    } else {
        self.isPlaying = YES;
        [self.manager resumePlay];
    }
   
}

- (void)resetStatus {
    self.isPlaying = NO;
    self.isPlayComplete = YES;
    [self.manager clearStates];
}

-(void)onStartPlayMusic {
    self.isPlaying = YES;
    self.isPlayComplete = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onStartPlayMusic)]) {
        [self.delegate onStartPlayMusic];
    }
}

- (void)onPlayingWithCurrent:(NSInteger)currentSec total:(NSInteger)totalSec{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayingWithCurrent:total:)]) {
        [self.delegate onPlayingWithCurrent:currentSec total:totalSec];
    }
}

- (void)onStopPlayerMusic {
    self.currentMusicPath = nil;
    self.bgmID = -1;
    self.isPlaying = NO;
    self.isPlayComplete = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onStopPlayerMusic)]) {
        [self.delegate onStopPlayerMusic];
    }
}

- (void)onCompletePlayMusic {
    self.isPlaying = NO;
    self.isPlayComplete = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onCompletePlayMusic)]) {
        [self.delegate onCompletePlayMusic];
    }
}

- (void)recoveryVoiceSetting {
    [self.manager setReverbTypeWithValue:self.currentReverb];
    [self.manager setVoiceChangerTypeWithValue:self.currentChangerType];
}

@end
