/*
* Module:   TRTCCdnPlayerSettingsViewController
*
* Function: CDN播放置页
*
*/

#import "TRTCCdnPlayerSettingsViewController.h"

@implementation TRTCCdnPlayerSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"CDN设置";
    
    TRTCCdnPlayerConfig *config = self.manager.config;
    __weak __typeof(self) wSelf = self;

    self.items = @[
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"画面旋转（顺时针)"
                                                 items:@[@"0", @"90", @"180", @"270"]
                                         selectedIndex:[self indexOfOrientation:config.orientation]
                                                action:^(NSInteger index) {
            [wSelf onSelectRotationIndex:index];
        }],
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"填充模式"
                                                 items:@[@"填充", @"自适应"]
                                         selectedIndex:config.renderMode
                                                action:^(NSInteger index) {
            [wSelf onSelectRenderModeIndex:index];
        }],
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"缓冲方式"
                                                 items:@[@"快速", @"平滑", @"自动"]
                                         selectedIndex:config.cacheType
                                                action:^(NSInteger index) {
            [wSelf onSelectCacheTypeIndex:index];
        }]
    ];
}

#pragma mark - Action

- (void)onSelectRotationIndex:(NSInteger)index {
    [self.manager setOrientation:[self orientationOfIndex:index]];
}

- (void)onSelectRenderModeIndex:(NSInteger)index {
    [self.manager setRenderMode:index];
}

- (void)onSelectCacheTypeIndex:(NSInteger)index {
    [self.manager setCacheType:index];
}

#pragma mark - Private

- (NSInteger)indexOfOrientation:(TX_Enum_Type_HomeOrientation)orientation {
    switch (orientation) {
        case HOME_ORIENTATION_DOWN:
            return 0;
        case HOME_ORIENTATION_RIGHT:
            return 1;
        case HOME_ORIENTATION_UP:
            return 2;
        case HOME_ORIENTATION_LEFT:
            return 3;
    }
}

- (TX_Enum_Type_HomeOrientation)orientationOfIndex:(NSInteger)index {
    NSArray *orientations = @[
        @(HOME_ORIENTATION_DOWN),
        @(HOME_ORIENTATION_RIGHT),
        @(HOME_ORIENTATION_UP),
        @(HOME_ORIENTATION_LEFT)
    ];
    return [orientations[index] integerValue];
}

@end
