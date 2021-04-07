//
//  ReplayKitLocalized.h
//  TXLiteAVDemo
//
//  Created by adams on 2021/3/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
#pragma mark - Base

extern NSString *ReplayKitLocalizeFromTable(NSString *key, NSString *table);
extern NSString *ReplayKitLocalizeFromTableAndCommon(NSString *key, NSString *common, NSString *table);

#pragma mark - Replace String
extern NSString *ReplayKitLocalizeReplaceXX(NSString *origin, NSString *xxx_replace);
extern NSString *ReplayKitLocalizeReplace(NSString *origin, NSString *xxx_replace, NSString *yyy_replace);
extern NSString *ReplayKitLocalizeReplaceThreeCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace);
extern NSString *ReplayKitLocalizeReplaceFourCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace, NSString *mmm_replace);
extern NSString *ReplayKitLocalizeReplaceFiveCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace, NSString *mmm_replace, NSString *nnn_replace);

#pragma mark - ReplayKit
extern NSString *const ReplayKit_Localize_TableName;
extern NSString *ReplayKitLocalize(NSString *key);


NS_ASSUME_NONNULL_END
