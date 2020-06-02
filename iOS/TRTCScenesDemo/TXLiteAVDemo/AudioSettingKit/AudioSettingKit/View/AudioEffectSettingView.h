//
//  AudioEffectSettingView.h
//  TCAudioSettingKit
//
//  Created by abyyxwang on 2020/5/26.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AudioEffectSettingViewType) {
    AudioEffectSettingViewDefault, // 默认大小，在底部弹起
    AudioEffectSettingViewCustom, // 用户自定义大小，初始化frame为0
};

@class TXAudioEffectManager;
@interface AudioEffectSettingView : UIView

- (instancetype)initWithType:(AudioEffectSettingViewType)type;

- (void)setAudioEffectManager:(TXAudioEffectManager *)manager;

- (void)show;
- (void)hide;

- (void)resetAudioSetting;

@end

NS_ASSUME_NONNULL_END
