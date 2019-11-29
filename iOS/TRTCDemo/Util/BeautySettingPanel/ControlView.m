//
//  ControlView.m
//  BeautyDemo
//
//  Created by kennethmiao on 17/5/9.
//  Copyright © 2017年 kennethmiao. All rights reserved.
//

#import "ControlView.h"

#define ControlViewItemWidth 40
#define ControlViewItemHeight 20
#define ControlViewMargin 8
@interface ControlView ()
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *beautyButton;
@end

@implementation ControlView

- (id)init
{
    self = [super init];
    if(self){
        [self setupView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    self.cameraButton.frame = CGRectMake(ControlViewMargin, ControlViewMargin, ControlViewItemWidth, ControlViewItemHeight);
    [self addSubview:self.cameraButton];
    
    self.beautyButton.frame = CGRectMake(2 * ControlViewMargin + ControlViewItemWidth, ControlViewMargin, ControlViewItemWidth, ControlViewItemHeight);
    [self addSubview:self.beautyButton];
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
}

#pragma mark - event
- (void)onCamera:(id)sender
{
    if([self.delegate respondsToSelector:@selector(switchCamera)]){
        [self.delegate switchCamera];
    }
}

- (void)onBeauty:(id)sender
{
    if([self.delegate respondsToSelector:@selector(hiddenBeauty)]){
        [self.delegate hiddenBeauty];
    }
}

#pragma mark - size
+ (CGSize)getSize
{
    return CGSizeMake(ControlViewMargin * 3 + 2 * ControlViewItemWidth, ControlViewItemHeight + ControlViewMargin * 2);
}

#pragma mark - lazy load
- (UIButton *)cameraButton
{
    if(!_cameraButton){
        _cameraButton = [[UIButton alloc] init];
        [_cameraButton setTitle:@"相机" forState:UIControlStateNormal];
//        [_cameraButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [_cameraButton addTarget:self action:@selector(onCamera:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (UIButton *)beautyButton
{
    if(!_beautyButton){
        _beautyButton = [[UIButton alloc] init];
        [_beautyButton setTitle:@"美颜" forState:UIControlStateNormal];
//        [_beautyButton setImage:[UIImage imageNamed:@"beauty"] forState:UIControlStateNormal];
        [_beautyButton addTarget:self action:@selector(onBeauty:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beautyButton;
}
@end


