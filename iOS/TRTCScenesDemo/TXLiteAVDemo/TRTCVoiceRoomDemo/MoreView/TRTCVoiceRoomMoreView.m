//
//  TRTCVoiceRoomMoreView.m
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/21.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TRTCVoiceRoomMoreView.h"

#import "ColorMacro.h"

@interface TRTCVoiceRoomMoreView ()<UIPickerViewDelegate,UIPickerViewDataSource> {
    NSArray *reverbArray;
}
@property (weak, nonatomic) IBOutlet UIView *touchView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickView;
@property (nonatomic, readonly) TRTCReverbType oldReverb;
@end

@implementation TRTCVoiceRoomMoreView

- (id)initWithBgmManager:(TRTCVoiceRoomBgmManager *)bgmManager {
    self = [[[NSBundle mainBundle] loadNibNamed:@"TRTCVoiceRoomMoreView" owner:self options:nil] lastObject];
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [UIColor clearColor];
    self.bgmManager = bgmManager;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.touchView addGestureRecognizer:singleTap];
    reverbArray = [NSArray arrayWithObjects:@"关闭混响", @"KTV", @"小房间", @"大会堂", @"低沉", @"洪亮", @"金属声", @"磁性", nil];
    
    return self;
}

#pragma mark 显示
- (void)show {
    if (!self.isShow) {
        _oldReverb = _bgmManager.reverb;
        [self.pickView selectRow:_oldReverb inComponent:0 animated:NO];
        self.alpha = 1;
        UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
        [keywindow addSubview:self];
        self.isShow = YES;
        [self.superview endEditing:YES];
    }
}

#pragma mark 关闭
- (void)dismiss {
    if (self.isShow) {
        self.isShow = NO;
        
        if (self.changeState) {
            NSString *reverb = reverbArray[_bgmManager.reverb];
            self.changeState(reverb);
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
    [_bgmManager setReverb:_oldReverb];
    [self dismiss];
}

#pragma mark 点击确定
- (IBAction)clickYes:(id)sender {
    [self dismiss];
}

#pragma mark UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

//每一组多少行
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return reverbArray.count;
}

//显示每一行的文本
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return reverbArray[row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    //设置文字的属性
    UILabel *label = [UILabel new];
    label.text = reverbArray[row];
    label.font = [UIFont systemFontOfSize:20.0];
    label.textColor = UIColorFromRGB(0xafafaf);
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

//选择一行就会调用这个方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //    NSLog(@"选择的是第%ld行",(long)row);
    [_bgmManager setReverb:row];
}

- (void)dealloc {
    NSLog(@"dealloc --- %@",[self class]);
}

@end
