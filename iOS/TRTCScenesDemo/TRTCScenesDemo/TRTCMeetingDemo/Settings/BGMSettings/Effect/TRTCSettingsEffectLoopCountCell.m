/*
* Module:   TRTCSettingsEffectLoopCountCell
*
* Function: 全局设置音效循环次数，以及停止所有音效播放
*
*/

#import "TRTCSettingsEffectLoopCountCell.h"
#import "UIButton+TRTC.h"
#import "UITextField+TRTC.h"
#import "Masonry.h"

@interface TRTCSettingsEffectLoopCountCell ()<UITextFieldDelegate>

@property (strong, nonatomic) UITextField *loopCountText;
@property (strong, nonatomic) UIButton *stopButton;

@end

@implementation TRTCSettingsEffectLoopCountCell

- (void)setupUI {
    [super setupUI];
    
    self.loopCountText = [UITextField trtc_textFieldWithDelegate:self];
    self.loopCountText.textAlignment = NSTextAlignmentCenter;
    self.loopCountText.keyboardType = UIKeyboardTypeNumberPad;
    
    [self.contentView addSubview:self.loopCountText];
    [self.loopCountText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.titleLabel.mas_trailing).offset(20);
        make.width.mas_equalTo(40);
    }];

    self.stopButton = [UIButton trtc_cellButtonWithTitle:@"停止所有音效"];
    [self.stopButton addTarget:self action:@selector(onClickStopButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.stopButton];
    [self.stopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-18);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onTextChange)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.loopCountText];
}

- (void)didUpdateItem:(TRTCSettingsBaseItem *)item {
    if ([item isKindOfClass:[TRTCSettingsEffectLoopCountItem class]]) {
        self.loopCountText.text = [NSString stringWithFormat:@"%@", @(self.manager.loopCount)];
    }
}

- (void)onClickStopButton:(id)sender {
    [self.manager stopAllEffects];
}

- (void)onTextChange {
    NSInteger loopCount = [self.loopCountText.text integerValue];
    [self.manager setLoopCount:loopCount];
}

- (TRTCAudioEffectManager *)manager {
    TRTCSettingsEffectLoopCountItem *effectItem = (TRTCSettingsEffectLoopCountItem *)self.item;
    return effectItem.manager;
}

@end


@implementation TRTCSettingsEffectLoopCountItem

- (instancetype)initWithManager:(TRTCAudioEffectManager *)manager {
    if (self = [super init]) {
        self.title = @"循环次数";
        _manager = manager;
    }
    return self;
}

+ (Class)bindedCellClass {
    return [TRTCSettingsEffectLoopCountCell class];
}

- (NSString *)bindedCellId {
    return [TRTCSettingsEffectLoopCountItem bindedCellId];
}

@end

