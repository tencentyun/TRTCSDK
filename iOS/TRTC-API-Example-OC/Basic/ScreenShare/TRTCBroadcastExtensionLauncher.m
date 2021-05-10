//
//  TRTCBroadcastExtensionLauncher.m
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/15.
//
//


#import <UIKit/UIKit.h>
#import <ReplayKit/ReplayKit.h>

#import "TRTCBroadcastExtensionLauncher.h"

static TRTCBroadcastExtensionLauncher* launch;

API_AVAILABLE(ios(12.0))
@interface TRTCBroadcastExtensionLauncher()
@property (strong, nonatomic) RPSystemBroadcastPickerView* systemBroacastExtensionPicker;
@end

@implementation TRTCBroadcastExtensionLauncher

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        launch = [[self alloc] init];
    });
    return launch;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        RPSystemBroadcastPickerView* picker =
                [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        picker.showsMicrophoneButton = false;
        picker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        _systemBroacastExtensionPicker = picker;
        
        NSString *plugInPath = NSBundle.mainBundle.builtInPlugInsPath;
        if (!plugInPath) {
            return self;
        }
        
        NSArray* contents = [NSFileManager.defaultManager contentsOfDirectoryAtPath:plugInPath error:nil];
        for (NSString* content in contents) {
            NSURL* url = [NSURL fileURLWithPath:plugInPath];
            NSBundle* bundle = [NSBundle bundleWithPath:[url URLByAppendingPathComponent:content].path];
            
            NSDictionary* extension = [bundle.infoDictionary objectForKey:@"NSExtension"];
            if (extension == nil) { continue; }
            NSString* identifier = [extension objectForKey:@"NSExtensionPointIdentifier"];
            if ([identifier isEqualToString:@"com.apple.broadcast-services-upload"]) {
                picker.preferredExtension = bundle.bundleIdentifier;
                break;
            }
        }
    }
    return self;
}

+ (void)launch {
    [[TRTCBroadcastExtensionLauncher sharedInstance] launch];
}

- (void)launch {
    for (UIView* view in _systemBroacastExtensionPicker.subviews) {
        UIButton* button = (UIButton*)view;
        [button sendActionsForControlEvents:UIControlEventAllTouchEvents];
    }
}

@end
