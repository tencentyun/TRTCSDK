//
//  SubTRTCCloudHelper.h
//  TRTC-API-Example-OC
//
//  Created by bluedang on 2021/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SubCloudHelperDelegate <NSObject>

- (void)onUserVideoAvailableWithSubId:(NSInteger)subId userId:(NSString *)userId available:(BOOL)available;

@end

@interface SubCloudHelper : NSObject

- (instancetype)initWithSubId:(NSInteger)subId cloud:(TRTCCloud*) cloud;
- (TRTCCloud*)getCloud;

@property (weak, nonatomic) id<SubCloudHelperDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
