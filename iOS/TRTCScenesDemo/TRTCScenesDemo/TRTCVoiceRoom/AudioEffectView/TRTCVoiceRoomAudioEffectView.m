//
//  TRTCVoiceRoomAudioEffectView.m
//  TXLiteAVDemo_Professional
//
//  Created by Melody on 2019/11/22.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TRTCVoiceRoomAudioEffectView.h"

@interface TRTCVoiceRoomAudioEffectView ()

@property (weak, nonatomic) IBOutlet UIView *touchView;
@property (weak, nonatomic) IBOutlet UIButton *previewBtn1;
@property (weak, nonatomic) IBOutlet UIButton *playBtn1;
@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel1;
@property (weak, nonatomic) IBOutlet UIButton *previewBtn2;
@property (weak, nonatomic) IBOutlet UIButton *playBtn2;
@property (weak, nonatomic) IBOutlet UISlider *slider2;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel2;
@property (weak, nonatomic) IBOutlet UIButton *previewBtn3;
@property (weak, nonatomic) IBOutlet UIButton *playBtn3;
@property (weak, nonatomic) IBOutlet UISlider *slider3;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel3;
@property (weak, nonatomic) IBOutlet UISlider *slider4;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel4;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHight;
@property (weak, nonatomic) IBOutlet UITextField *cyclesField;
@property (weak, nonatomic) IBOutlet UIButton *hideBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopAllBtn;

@end

@implementation TRTCVoiceRoomAudioEffectView

- (id)initWithManager:(TRTCVoiceRoomAudioEffectManager *)manager {
    self = [[[NSBundle mainBundle] loadNibNamed:@"TRTCVoiceRoomAudioEffectView" owner:self options:nil] lastObject];
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [UIColor clearColor];
    self.manager = manager;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.touchView addGestureRecognizer:singleTap];
    
    //增加监听，当键盘出现或改变时调用
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    return self;
}

#pragma mark 显示
- (void)show {
    if (!self.isShow) {
        self.alpha = 1;
        UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
        [keywindow addSubview:self];
        self.isShow = YES;
        [self.superview endEditing:YES];
        
        if (self.changeState) {
            self.changeState(YES);
        }
    }
}
#pragma mark 关闭
- (void)dismiss {
    if (self.isShow) {
        self.isShow = NO;
        [UIView animateWithDuration:0.2 // 动画时长
                         animations:^{
            self.alpha = 0;
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
        
        if (self.changeState) {
            self.changeState(NO);
        }
    }
}

#pragma mark 点击预览
- (IBAction)clickPreviewBtn:(UIButton *)sender {
    //    sender.selected = !sender.selected;
    int i = 0;
    if (sender == _previewBtn1) {
        i = 0;
    }else if (sender == _previewBtn2){
        i = 1;
    }else if(sender == _previewBtn3){
        i = 2;
    }
    //    if (sender.selected) {
    //        [_manager stopAllEffects];          //停止所有音效
    _manager.effects[i].publish = NO;  //关闭音效上行
    [_manager playEffect:i];
    //    }else{
    //        [_manager stopEffect:i];
    //    }
}

#pragma mark 点击使用
- (IBAction)clickPlayBtn:(UIButton *)sender {
    //    sender.selected = !sender.selected;
    int i = 0;
    if (sender == _playBtn1) {
        i = 0;
    }else if (sender == _playBtn2){
        i = 1;
    }else if(sender == _playBtn3){
        i = 2;
    }
    //    if (sender.selected) {
    //        [_manager stopAllEffects];          //停止所有音效
    _manager.effects[i].publish = YES;  //开启音效上行
    [_manager playEffect:i];
    //    }else{
    //        [_manager stopEffect:i];
    //    }
}

#pragma mark 收到播放结束信息,改变状态
- (void)playFinished:(int)effectId {
    //    if (effectId == 0) {
    //        _playBtn1.selected = NO;
    //        _previewBtn1.selected = NO;
    //    }else if (effectId == 1){
    //        _playBtn2.selected = NO;
    //        _previewBtn2.selected = NO;
    //    }else if(effectId == 2){
    //        _playBtn3.selected = NO;
    //        _previewBtn3.selected = NO;
    //    }
}

#pragma mark 音量改变
- (IBAction)sliderChanged:(UISlider *)sender {
    if (sender == _slider1) {
        [_manager updateEffect:0 volume:(int)sender.value];
        self.volumeLabel1.text = [NSString stringWithFormat:@"%d",(int)sender.value];
    }else if (sender == _slider2){
        [_manager updateEffect:1 volume:(int)sender.value];
        self.volumeLabel2.text = [NSString stringWithFormat:@"%d",(int)sender.value];
    }else if (sender == _slider3){
        [_manager updateEffect:2 volume:(int)sender.value];
        self.volumeLabel3.text = [NSString stringWithFormat:@"%d",(int)sender.value];
    }else if (sender == _slider4){
        [_manager setGlobalVolume:(int)sender.value];
        self.volumeLabel4.text = [NSString stringWithFormat:@"%d",(int)sender.value];
    }
}

#pragma mark 停止所有音效
- (IBAction)clickStopAllBtn:(id)sender {
    [_manager stopAllEffects];
    //    _playBtn1.selected = NO;
    //    _playBtn2.selected = NO;
    //    _playBtn3.selected = NO;
}

#pragma mark 点击隐藏键盘
- (IBAction)clickHideBtn:(id)sender {
    [self endEditing:YES];
}

#pragma mark 当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification {
    if ([self.cyclesField isFirstResponder]) {
        self.cyclesField.text = @"0";
        [self bringSubviewToFront:self.hideBtn];        //将hideBtn置于View顶部
        self.hideBtn.hidden = NO;                       //显示hideBtn
        [UIView animateWithDuration:0.3 animations:^{
            //获取键盘的高度
            NSDictionary *userInfo = [aNotification userInfo];
            NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
            CGRect keyboardRect = [aValue CGRectValue];
            int keyBoard_h = keyboardRect.size.height;
            self.bottomHight.constant = keyBoard_h;
            [self layoutIfNeeded];
        }];
    }
}

#pragma mark 当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification {
    if ([self.cyclesField isFirstResponder]) {
        if (self.cyclesField.text.length == 0) {
            self.cyclesField.text = @"0";
        }
        //设置循环次数
        int count = [self.cyclesField.text intValue];
        [_manager setLoopCount:count];
        
        [self sendSubviewToBack:self.hideBtn];          //将hideBtn置于View底部
        self.hideBtn.hidden = YES;                      //隐藏hideBtn
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomHight.constant = 50;
            [self layoutIfNeeded];
        }];
    }
}

- (void)dealloc {
    NSLog(@"dealloc --- %@", [self class]);
}

@end
