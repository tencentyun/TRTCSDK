//
//  CustomCameraHelper.h
//  TRTC-API-Example-OC
//
//  Created by abyyxwang on 2021/4/22.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

@protocol CustomCameraHelperSampleBufferDelegate <NSObject>

- (void)onVideoSampleBuffer:(CMSampleBufferRef)videoBuffer;

@end

@interface CustomCameraHelper : NSObject

@property (weak, nonatomic)id<CustomCameraHelperSampleBufferDelegate>delegate;
// set this property before start capture;
@property (assign, nonatomic)UIInterfaceOrientation windowOrientation;

- (void)checkPermission;

- (void)createSession;

- (void)startCameraCapture;

- (void)stopCameraCapture;

@end

NS_ASSUME_NONNULL_END
