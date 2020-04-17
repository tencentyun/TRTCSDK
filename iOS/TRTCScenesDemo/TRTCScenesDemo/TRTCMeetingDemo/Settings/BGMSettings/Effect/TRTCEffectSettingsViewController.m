/*
* Module:   TRTCEffectSettingsViewController
*
* Function: 音效设置页，包含一个全部音效的列表，以及音效的全局设置项
*
*    1. Demo的音效列表定义在TRTCAudioEffectManager中
*
*    2. 音效Cell为TRTCSettingsEffectCell，
*       音效的循环次数设置在TRTCSettingsEffectLoopCountCell中
*
*/

#import "TRTCEffectSettingsViewController.h"
#import "TRTCSettingsEffectCell.h"
#import "TRTCSettingsEffectLoopCountCell.h"

@interface TRTCEffectSettingsViewController ()

@end

@implementation TRTCEffectSettingsViewController

- (NSString *)title {
    return @"音效";
}

- (void)makeCustomRegistrition {
    [self.tableView registerClass:TRTCSettingsEffectItem.bindedCellClass
           forCellReuseIdentifier:TRTCSettingsEffectItem.bindedCellId];
    [self.tableView registerClass:TRTCSettingsEffectLoopCountItem.bindedCellClass
           forCellReuseIdentifier:TRTCSettingsEffectLoopCountItem.bindedCellId];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof(self) wSelf = self;
    NSArray *otherItems = @[
        [[TRTCSettingsSliderItem alloc] initWithTitle:@"全局音量"
                                                value:100 min:0 max:100 step:1
                                           continuous:YES
                                               action:^(float value) {
            [wSelf onChangeGlobalVolume:(NSInteger)value];
        }],
        [[TRTCSettingsEffectLoopCountItem alloc] initWithManager:self.manager],
    ];
    self.items = [[self buildEffectItems] arrayByAddingObjectsFromArray:otherItems];
}

- (NSArray *)buildEffectItems {
    NSMutableArray *items = [NSMutableArray array];
    for (TRTCAudioEffectParam *effect in self.manager.effects) {
        [items addObject:[[TRTCSettingsEffectItem alloc] initWithEffect:effect manager:self.manager]];
    }
    return items;
}

#pragma mark - Actions

- (void)onChangeGlobalVolume:(NSInteger)volume {
    [self.manager setGlobalVolume:volume];
}

@end
