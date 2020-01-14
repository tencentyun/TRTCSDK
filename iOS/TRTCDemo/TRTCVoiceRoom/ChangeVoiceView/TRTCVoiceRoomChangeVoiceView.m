//
//  TRTCVoiceRoomChangeVoiceView.m
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/21.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TRTCVoiceRoomChangeVoiceView.h"

#import "ColorMacro.h"

@interface TRTCVoiceRoomChangeVoiceView ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSArray *voiceArray;
}
@property (weak, nonatomic) IBOutlet UIView *touchView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickView;
@property (nonatomic, readonly) TRTCVoiceChangerType oldvoiceChanger;
@end

@implementation TRTCVoiceRoomChangeVoiceView

- (id)initWithBgmManager:(TRTCVoiceRoomBgmManager *)bgmManager {
    self = [[[NSBundle mainBundle] loadNibNamed:@"TRTCVoiceRoomChangeVoiceView" owner:self options:nil] lastObject];
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [UIColor clearColor];
    self.bgmManager = bgmManager;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.touchView addGestureRecognizer:singleTap];
    voiceArray = [NSArray arrayWithObjects:@"关闭变声", @"熊孩子", @"萝莉", @"大叔", @"重金属", @"感冒",@"外国人", @"困兽", @"死肥仔", @"强电流", @"重机械", @"空灵", nil];
    return self;
}

#pragma mark 显示
- (void)show {
    if (!self.isShow) {
        _oldvoiceChanger = _bgmManager.voiceChanger;
        [self.pickView selectRow:_oldvoiceChanger inComponent:0 animated:NO];
        
        self.alpha = 1;
        UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
        [keywindow addSubview:self];
        self.isShow = YES;
        [self.superview endEditing:YES];
    }
}

#pragma mark mark 关闭
- (void)dismiss {
    if (self.isShow) {
        self.isShow = NO;
        
        if (self.changeState) {
            NSString *voice = voiceArray[_bgmManager.voiceChanger];
            self.changeState(voice);
        }
        
        [UIView animateWithDuration:0.2 // 动画时长
                         animations:^{
            self.alpha = 0;
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

#pragma mark 点击取消
- (IBAction)clickCancel:(id)sender {
    [_bgmManager setVoiceChanger:_oldvoiceChanger];
    [self dismiss];
}

#pragma mark 点击确定
- (IBAction)clickYes:(id)sender {
    [self dismiss];
}

#pragma mark argumentsUIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

//每一组多少行
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return voiceArray.count;
}

//显示每一行的文本
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return voiceArray[row];
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    //设置文字的属性
    UILabel *label = [UILabel new];
    label.text = voiceArray[row];
    label.font = [UIFont systemFontOfSize:20.0];
    label.textColor = UIColorFromRGB(0xafafaf);
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

#pragma mark 选择一行回调
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //    NSLog(@"选择的是第%ld行",(long)row);
    [_bgmManager setVoiceChanger:row];
}

- (void)dealloc {
    NSLog(@"dealloc --- %@",[self class]);
}

@end
