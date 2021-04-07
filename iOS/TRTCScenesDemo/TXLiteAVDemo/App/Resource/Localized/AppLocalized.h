//
//  AppLocalized.h
//  TXLiteAVDemo
//
//  Created by gg on 2021/3/17.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


#pragma mark - Base

extern NSString *LocalizeFromTable(NSString *key, NSString *table);
extern NSString *LocalizeFromTableAndCommon(NSString *key, NSString *common, NSString *table);

#pragma mark - Replace String
extern NSString *LocalizeReplaceXX(NSString *origin, NSString *xxx_replace);
extern NSString *LocalizeReplace(NSString *origin, NSString *xxx_replace, NSString *yyy_replace);
extern NSString *LocalizeReplaceThreeCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace);
extern NSString *LocalizeReplaceFourCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace, NSString *mmm_replace);
extern NSString *LocalizeReplaceFiveCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace, NSString *mmm_replace, NSString *nnn_replace);

#pragma mark - TRTC
extern NSString *const TRTC_Localize_TableName;
extern NSString *TRTCLocalize(NSString *key);

#pragma mark - V2
extern NSString *const V2_Localize_TableName;
extern NSString *V2Localize(NSString *key);

#pragma mark - LivePlayer
extern NSString *const LivePlayer_Localize_TableName;
extern NSString *LivePlayerLocalize(NSString *key);

#pragma mark - UGC
extern NSString *const UGC_Localize_TableName;
extern NSString *UGCLocalize(NSString *key);

#pragma mark - LoginNetwork
extern NSString *const LoginNetwork_Localize_TableName;
extern NSString *LoginNetworkLocalize(NSString *key);

#pragma mark - AppPortal
extern NSString *const AppPortal_Localize_TableName;
extern NSString *AppPortalLocalize(NSString *key);

NS_ASSUME_NONNULL_END
