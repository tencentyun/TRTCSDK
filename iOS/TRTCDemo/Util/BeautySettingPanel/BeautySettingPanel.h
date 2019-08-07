//
//  BeautySettingPanel.h
//  RTMPiOSDemo
//
//  Created by rushanting on 2017/5/5.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 美颜类型
 */
typedef NS_ENUM(NSInteger, PanelBeautyStyle) {
    /// 光滑
    PanelBeautyStyle_STYLE_SMOOTH     = 0,
    /// 自然
    PanelBeautyStyle_STYLE_NATURE     = 1,
    /// pitu美颜
    PanelBeautyStyle_STYLE_PITU       = 2,
};


typedef NS_ENUM(NSUInteger, PanelMenuIndex) {
    PanelMenuIndexBeauty,
    PanelMenuIndexFilter,
    PanelMenuIndexMotion,
    PanelMenuIndexKoubei,
    PanelMenuIndexGreen
};

typedef NS_ENUM(NSInteger, FilterType) {
    FilterType_None         = 0,
    FilterType_normal,
    FilterType_yinghong,
    FilterType_yunshang,
    FilterType_chunzhen,
    FilterType_bailan,
    FilterType_yuanqi,
    FilterType_chaotuo,
    FilterType_xiangfen,
    FilterType_white        ,   //美白滤镜
    FilterType_langman      ,   //浪漫滤镜
    FilterType_qingxin      ,   //清新滤镜
    FilterType_weimei       ,   //唯美滤镜
    FilterType_fennen       ,   //粉嫩滤镜
    FilterType_huaijiu      ,   //怀旧滤镜
    FilterType_landiao      ,   //蓝调滤镜
    FilterType_qingliang    ,   //清凉滤镜
    FilterType_rixi         ,   //日系滤镜
};

@protocol BeautySettingPanelDelegate <NSObject>
- (void)onSetBeautyStyle:(NSUInteger)beautyStyle beautyLevel:(float)beautyLevel whitenessLevel:(float)whitenessLevel ruddinessLevel:(float)ruddinessLevel;
- (void)onSetMixLevel:(float)mixLevel;
- (void)onSetEyeScaleLevel:(float)eyeScaleLevel;
- (void)onSetFaceScaleLevel:(float)faceScaleLevel;
- (void)onSetFaceBeautyLevel:(float)beautyLevel;
- (void)onSetFaceVLevel:(float)vLevel;
- (void)onSetChinLevel:(float)chinLevel;
- (void)onSetFaceShortLevel:(float)shortLevel;
- (void)onSetNoseSlimLevel:(float)slimLevel;
- (void)onSetFilter:(UIImage*)filterImage;
- (void)onSetGreenScreenFile:(NSURL *)file;
- (void)onSelectMotionTmpl:(NSString *)tmplName inDir:(NSString *)tmplDir;

@end

@protocol BeautyLoadPituDelegate <NSObject>
@optional
- (void)onLoadPituStart;
- (void)onLoadPituProgress:(CGFloat)progress;
- (void)onLoadPituFinished;
- (void)onLoadPituFailed;
@end

@interface BeautySettingPanel : UIView
@property (nonatomic, assign) NSInteger currentFilterIndex;
@property (nonatomic, readonly) NSString* currentFilterName;

@property (nonatomic, weak) id<BeautySettingPanelDelegate> delegate;
@property (nonatomic, weak) id<BeautyLoadPituDelegate> pituDelegate;

- (void)resetValues;
- (void)trigglerValues;
+ (NSUInteger)getHeight;
- (void)changeFunction:(PanelMenuIndex)i;
- (UIImage*)filterImageByIndex:(NSInteger)index;
- (float)filterMixLevelByIndex:(NSInteger)index;

@end
