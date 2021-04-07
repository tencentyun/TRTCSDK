//
//  AppLocalized.m
//  TXLiteAVDemo
//
//  Created by gg on 2021/3/17.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "AppLocalized.h"

#pragma mark - Base
NSString *LocalizeFromTable(NSString *key, NSString *table) {
    return [NSBundle.mainBundle localizedStringForKey:key value:@"" table:table];
}

NSString *LocalizeFromTableAndCommon(NSString *key, NSString *common, NSString *table) {
    return LocalizeFromTable(key, table);
}

#pragma mark - Replace String
NSString *LocalizeReplaceXX(NSString *origin, NSString *xxx_replace) {
    if (xxx_replace == nil) { xxx_replace = @"";}
    return [origin stringByReplacingOccurrencesOfString:@"xxx" withString:xxx_replace];
}

NSString *LocalizeReplace(NSString *origin, NSString *xxx_replace, NSString *yyy_replace) {
    if (xxx_replace == nil) { xxx_replace = @"";}
    if (yyy_replace == nil) { yyy_replace = @"";}
    return [[origin stringByReplacingOccurrencesOfString:@"xxx" withString:xxx_replace] stringByReplacingOccurrencesOfString:@"yyy" withString:yyy_replace];
}

NSString *LocalizeReplaceThreeCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace) {
    if (xxx_replace == nil) { xxx_replace = @"";}
    if (yyy_replace == nil) { yyy_replace = @"";}
    if (zzz_replace == nil) { zzz_replace = @"";}
    return [[[origin stringByReplacingOccurrencesOfString:@"xxx" withString:xxx_replace] stringByReplacingOccurrencesOfString:@"yyy" withString:yyy_replace]
        stringByReplacingOccurrencesOfString:@"zzz" withString:zzz_replace];
}

NSString *LocalizeReplaceFourCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace, NSString *mmm_replace) {
    if (xxx_replace == nil) { xxx_replace = @"";}
    if (yyy_replace == nil) { yyy_replace = @"";}
    if (zzz_replace == nil) { zzz_replace = @"";}
    if (mmm_replace == nil) { mmm_replace = @"";}
    return [[[[origin stringByReplacingOccurrencesOfString:@"xxx" withString:xxx_replace] stringByReplacingOccurrencesOfString:@"yyy" withString:yyy_replace]
        stringByReplacingOccurrencesOfString:@"zzz" withString:zzz_replace]
            stringByReplacingOccurrencesOfString:@"mmm" withString:mmm_replace];
}

NSString *LocalizeReplaceFiveCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace, NSString *mmm_replace, NSString *nnn_replace) {
    if (xxx_replace == nil) { xxx_replace = @"";}
    if (yyy_replace == nil) { yyy_replace = @"";}
    if (zzz_replace == nil) { zzz_replace = @"";}
    if (mmm_replace == nil) { mmm_replace = @"";}
    if (nnn_replace == nil) { nnn_replace = @"";}
    return [[[[[origin stringByReplacingOccurrencesOfString:@"xxx" withString:xxx_replace] stringByReplacingOccurrencesOfString:@"yyy" withString:yyy_replace]
        stringByReplacingOccurrencesOfString:@"zzz" withString:zzz_replace]
            stringByReplacingOccurrencesOfString:@"mmm" withString:mmm_replace]
            stringByReplacingOccurrencesOfString:@"nnn" withString:nnn_replace];
}


#pragma mark - TRTC
NSString *const TRTC_Localize_TableName = @"TRTCDemoLocalized";

NSString *TRTCLocalize(NSString *key) {
    return LocalizeFromTable(key, TRTC_Localize_TableName);
}

#pragma mark - V2
NSString *const V2_Localize_TableName = @"V2LiveLocalized";

NSString *V2Localize(NSString *key) {
    return LocalizeFromTable(key, V2_Localize_TableName);
}

#pragma mark - LivePlayer
NSString *const LivePlayer_Localize_TableName = @"LivePlayerLocalized";

NSString *LivePlayerLocalize(NSString *key) {
    return LocalizeFromTable(key, LivePlayer_Localize_TableName);
}

#pragma mark - UGC
NSString *const UGC_Localize_TableName = @"UGCLocalized";
NSString *UGCLocalize(NSString *key) {
    return LocalizeFromTable(key, UGC_Localize_TableName);
}

#pragma mark - LoginNetwork
NSString *const LoginNetwork_Localize_TableName = @"LoginNetworkLocalized";
NSString *LoginNetworkLocalize(NSString *key) {
    return LocalizeFromTable(key, LoginNetwork_Localize_TableName);
}

#pragma mark - AppPortal
NSString *const AppPortal_Localize_TableName = @"AppPortalLocalized";
NSString *AppPortalLocalize(NSString *key) {
    return LocalizeFromTable(key, AppPortal_Localize_TableName);
}
