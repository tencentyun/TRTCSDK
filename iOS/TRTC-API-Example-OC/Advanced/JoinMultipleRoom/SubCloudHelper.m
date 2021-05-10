//
//  SubTRTCCloudHelper.m
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/22.
//

#import "SubCloudHelper.h"
#import <objc/runtime.h>

@interface SubCloudHelper() <TRTCCloudDelegate>
@property (assign, nonatomic) NSInteger subId;
@property (strong, nonatomic) TRTCCloud *trtcCloud;
@end

@implementation SubCloudHelper

- (instancetype)initWithSubId:(NSInteger)subId cloud:(TRTCCloud*) cloud {
    self = [super init];
    _subId = subId;
    _trtcCloud = cloud;
    [_trtcCloud setDelegate:self];
    return self;
}

- (TRTCCloud *)getCloud {
    return _trtcCloud;
}


#pragma mark - TRTCCloud Delegate

- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available {
    if ([self.delegate respondsToSelector:@selector(onUserVideoAvailableWithSubId:userId:available:)]) {
        [self.delegate onUserVideoAvailableWithSubId:self.subId userId:userId available:available];
    }
}


@end
