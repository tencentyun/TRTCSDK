//
//  ThirdBeautyEntranceViewController.m
//  TRTC-API-Example-OC
//
//  Created by WesleyLei on 2021/8/17.
//

#import "ThirdBeautyBytedViewController.h"
#import "ThirdBeautyEntranceViewController.h"
#import "ThirdBeautyFaceunityViewController.h"
@interface ThirdBeautyEntranceViewController ()
@property(nonatomic, strong) UIButton *beautyButton;
@property(nonatomic, strong) UIButton *bytedButton;
@property(nonatomic, strong) UIButton *xMagicButton;
@end

@implementation ThirdBeautyEntranceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localize(@"TRTC-API-Example.Home.ThirdBeauty");
    [self setupUI];
}


- (void)setupUI{
    self.beautyButton.frame = CGRectMake(22,
                                         UIScreen.mainScreen.bounds.size.height * 0.5 - 90, UIScreen.mainScreen.bounds.size.width-44, 50);
    self.bytedButton.frame = CGRectMake(22,
                                        UIScreen.mainScreen.bounds.size.height * 0.5, UIScreen.mainScreen.bounds.size.width-44, 50);
    self.xMagicButton.frame = CGRectMake(22,
                                         UIScreen.mainScreen.bounds.size.height * 0.5 + 90, UIScreen.mainScreen.bounds.size.width-44, 50);
    [self.view addSubview:self.beautyButton];
    [self.view addSubview:self.bytedButton];
    [self.view addSubview:self.xMagicButton];
}

#pragma mark - Touch Even
- (void)clickBeautyButton {
    UIViewController *controller =
    [[ThirdBeautyFaceunityViewController alloc] initWithNibName:@"ThirdBeautyFaceunityViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:true];
}

#pragma mark - Touch Even
- (void)clickBytedButton {
    UIViewController *controller =
    [[ThirdBeautyBytedViewController alloc] initWithNibName:@"ThirdBeautyBytedViewController"
                                                     bundle:nil];
    [self.navigationController pushViewController:controller animated:true];
}

#pragma mark - Touch Even
- (void)clickXmagicButton {
    UIViewController *controller =
    [[ThirdBeautyBytedViewController alloc] initWithNibName:@"ThirdBeautyTencentEffectViewController"
                                                     bundle:nil];
    [self.navigationController pushViewController:controller animated:true];
}

#pragma mark - Gettter
- (UIButton *)beautyButton {
    if (!_beautyButton) {
        _beautyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _beautyButton.layer.cornerRadius = 5;
        [_beautyButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _beautyButton.backgroundColor = [UIColor greenColor];
        [_beautyButton setTitle:Localize(@"TRTC-API-Example.ThirdBeauty.faceunity") forState:UIControlStateNormal];
        [_beautyButton addTarget:self
                          action:@selector(clickBeautyButton)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _beautyButton;
}

- (UIButton *)bytedButton {
    if (!_bytedButton) {
        _bytedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bytedButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _bytedButton.layer.cornerRadius = 5;
        _bytedButton.backgroundColor = [UIColor greenColor];
        [_bytedButton setTitle:Localize(@"TRTC-API-Example.ThirdBeauty.bytedance") forState:UIControlStateNormal];
        [_bytedButton addTarget:self
                         action:@selector(clickBytedButton)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _bytedButton;
}

- (UIButton *)xMagicButton {
    if (!_xMagicButton) {
        _xMagicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_xMagicButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _xMagicButton.layer.cornerRadius = 5;
        _xMagicButton.backgroundColor = [UIColor greenColor];
        [_xMagicButton setTitle:Localize(@"TRTC-API-Example.ThirdBeauty.xmagic") forState:UIControlStateNormal];
        [_xMagicButton addTarget:self
                          action:@selector(clickXmagicButton)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _xMagicButton;
}



@end

