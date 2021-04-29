//
//  CustomCameraHelper.m
//  TRTC-API-Example-OC
//
//  Created by abyyxwang on 2021/4/22.
//

#import "CustomCameraHelper.h"
#import <AVFoundation/AVFoundation.h>


typedef NS_ENUM(NSInteger, AVCamSetupResult) {
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
};

@interface CustomCameraHelper () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic) AVCamSetupResult setupResult;
@property (nonatomic) dispatch_queue_t sessionQueue;

@property (atomic, strong) AVCaptureSession *captureSession;
@property (atomic, strong) AVCaptureDevice *inputCamera;
@property (atomic, strong) AVCaptureDeviceInput *videoInput;
@property (atomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (atomic, strong) AVCaptureDeviceInput *audioInput;
@property (atomic, strong) AVCaptureConnection *videoConnection;
@property (atomic, strong) AVCaptureMetadataOutput *metaOutput;

@property (nonatomic, strong) dispatch_queue_t cameraDelegateQueue;

@end

@implementation CustomCameraHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Communicate with the session and other session objects on this queue.
        self.sessionQueue = dispatch_queue_create("com.txc.SessionQueue", DISPATCH_QUEUE_SERIAL);
        self.cameraDelegateQueue = dispatch_queue_create("com.txc.CameraDelegateQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)checkPermission {
    /*
     Check video authorization status. Video access is required and audio
     access is optional. If audio access is denied, audio is not recorded
     during movie recording.
    */
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
    {
        case AVAuthorizationStatusAuthorized:
        {
            // The user has previously granted access to the camera.
            break;
        }
        case AVAuthorizationStatusNotDetermined:
        {
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
            */
            dispatch_suspend(self.sessionQueue);
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (!granted) {
                    self.setupResult = AVCamSetupResultCameraNotAuthorized;
                }
                dispatch_resume(self.sessionQueue);
            }];
            break;
        }
        default:
        {
            // The user has previously denied access.
            self.setupResult = AVCamSetupResultCameraNotAuthorized;
            break;
        }
    }
}

- (void)createSession {
    self.captureSession = [AVCaptureSession new];
    [self checkPermission];
    dispatch_async(self.sessionQueue, ^{
        [self configureSession];
    });
}

// Call this on the session queue.
- (void)configureSession {
    if (self.setupResult != AVCamSetupResultSuccess) {
        return;
    }
    NSError *error = nil;
    [self.captureSession beginConfiguration];
    
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    // Add video input.
    // Choose the front dual camera if available, otherwise default to a wide angle camera.
    AVCaptureDevice* videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    if (!videoDevice) {
        // If a rear dual camera is not available, default to the rear wide angle camera.
        videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    }
    AVCaptureDeviceInput* videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (!videoDeviceInput) {
        NSLog(@"Could not create video device input: %@", error);
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.captureSession commitConfiguration];
        return;
    }
    if ([self.captureSession canAddInput:videoDeviceInput]) {
        [self.captureSession addInput:videoDeviceInput];
        self.videoInput = videoDeviceInput;
        self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [self.videoOutput setSampleBufferDelegate:self queue:self.cameraDelegateQueue];
        NSDictionary *captureSettings = @{(NSString *) kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        self.videoOutput.videoSettings = captureSettings;
        self.videoOutput.alwaysDiscardsLateVideoFrames = YES;
        if ([self.captureSession canAddOutput:self.videoOutput]) {
            [self.captureSession addOutput:self.videoOutput];
        }
    } else {
        NSLog(@"Could not add video device input to the session");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.captureSession commitConfiguration];
        return;
    }
    
    // Add audio input.
    AVCaptureDevice* audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput* audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    if (!audioDeviceInput) {
        NSLog(@"Could not create audio device input: %@", error);
    }
    if ([self.captureSession canAddInput:audioDeviceInput]) {
        [self.captureSession addInput:audioDeviceInput];
        self.audioInput = audioDeviceInput;
    }
    else {
        NSLog(@"Could not add audio device input to the session");
    }
    [self.captureSession commitConfiguration];
    self.videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([self.videoConnection isVideoOrientationSupported]) {
        self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
}

- (void)startCameraCapture {
    if (!self.captureSession) {
        return;
    }
    dispatch_async(self.sessionQueue, ^{
        if (!self.captureSession.isRunning) {
            [self.captureSession startRunning];
        }
    });
}

- (void)stopCameraCapture {
    if (!self.captureSession) {
        return;
    }
    dispatch_async(self.sessionQueue, ^{
        if (self.captureSession.isRunning) {
            [self.captureSession stopRunning];
        }
    });
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (connection == self.videoConnection) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onVideoSampleBuffer:)]) {
            [self.delegate onVideoSampleBuffer:sampleBuffer];
        }
    }
}


@end
