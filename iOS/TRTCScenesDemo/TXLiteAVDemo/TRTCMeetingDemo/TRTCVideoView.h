//
//  TRTCVideoView.h
//  TXLiteAVDemo
//
//  Created by rushanting on 2019/3/5.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VideoViewType) {
    VideoViewType_Local,
    VideoViewType_Remote,
};

@class TRTCVideoView;

@protocol TRTCVideoViewDelegate <NSObject>

@optional
- (void)onMuteVideoBtnClick:(TRTCVideoView*)view stateChanged:(BOOL)stateChanged;
- (void)onMuteAudioBtnClick:(TRTCVideoView*)view stateChanged:(BOOL)stateChanged;
- (void)onScaleModeBtnClick:(TRTCVideoView*)view stateChanged:(BOOL)stateChanged;
- (void)onViewTap:(TRTCVideoView*)view touchCount:(NSInteger)touchCount;
@end

@interface TRTCVideoView : UIImageView

@property (nonatomic, weak) id<TRTCVideoViewDelegate> delegate;
@property (nonatomic, readonly) NSString* userId;
@property (nonatomic, readonly) VideoViewType type;
@property (nonatomic, assign) BOOL enableMove;

@property (nonatomic, retain) UIButton* btnMuteVideo;
@property (nonatomic, retain) UIButton* btnMuteAudio;
@property (nonatomic, retain) UIButton* btnScaleMode;
@property (nonatomic, assign) int streamType;


+ (instancetype)newVideoViewWithType:(VideoViewType)type userId:( NSString * _Nullable )userId;

- (void)hideButtons:(BOOL)hide;
- (void)setNetworkIndicatorImage:(UIImage*)image;
- (void)setAudioVolumeRadio:(float)volumeRadio;
- (void)showVideoCloseTip:(BOOL)show;
- (void)showAudioVolume:(BOOL)show;
- (void)showNetworkIndicatorImage:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
