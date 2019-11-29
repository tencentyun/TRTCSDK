//
//  BeautySettingsSetter.h
//  TXLiteAVDemo
//
//  Created by cui on 2019/9/26.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BeautySettingsSetter <NSObject>

/**
  设置大眼级别（增值版本有效，普通版本设置此参数无效） [仅限商业版Pro]
  @param eyeScaleLevel 大眼级别取值范围 0 ~ 9； 0 表示关闭 1 ~ 9值越大 效果越明显。
 */
-(void)setEyeScaleLevel:(float)eyeScaleLevel;

/**
  设置瘦脸级别（增值版本有效，普通版本设置此参数无效）[仅限商业版Pro]
  @param faceScaleLevel 瘦脸级别取值范围 0 ~ 9； 0 表示关闭 1 ~ 9值越大 效果越明显。
 */
-(void)setFaceSlimLevel:(float)faceScaleLevel;

/**
  设置V脸（增值版本有效，普通版本设置此参数无效）[仅限商业版Pro]
  @param faceVLevel V脸级别取值范围 0 ~ 9； 0 表示关闭 1 ~ 9值越大 效果越明显。
 */
- (void)setFaceVLevel:(float)faceVLevel;

/** 设置下巴拉伸或收缩（增值版本有效，普通版本设置此参数无效）[仅限商业版Pro]
 * @param chinLevel 下巴拉伸或收缩取值范围 -9 ~ 9； 0 表示关闭 -9收缩 ~ 9拉伸。
 */
- (void)setChinLevel:(float)chinLevel;

/** 设置短脸（增值版本有效，普通版本设置此参数无效）[仅限商业版Pro]
 * @param faceShortlevel 短脸级别取值范围 0 ~ 9； 0 表示关闭 1 ~ 9值越大 效果越明显。
 */
- (void)setFaceShortLevel:(float)faceShortlevel;

/** 设置瘦鼻（增值版本有效，普通版本设置此参数无效）[仅限商业版Pro]
 * @param noseSlimLevel 瘦鼻级别取值范围 0 ~ 9； 0 表示关闭 1 ~ 9值越大 效果越明显。
 */
- (void)setNoseSlimLevel:(float)noseSlimLevel;

/// 设置亮眼 （增值版本有效，普通版本设置此参数无效） [仅限商业版Pro]
/// @param level 亮眼级别，取值范围 0 ~ 9； 0 表示关闭 1 - 9 值越大，效果越明显。
- (void)setEyeLightenLevel:(float)level;

/// 设置白牙 （增值版本有效，普通版本设置此参数无效） [仅限商业版Pro]
/// @param level 白牙级别，取值范围 0 ~ 9； 0 表示关闭 1 - 9 值越大，效果越明显。
- (void)setToothWhitenLevel:(float)level;

/// 设置祛皱 （增值版本有效，普通版本设置此参数无效） [仅限商业版Pro]
/// @param level 祛皱级别，取值范围 0 ~ 9； 0 表示关闭 1 - 9 值越大，效果越明显。
- (void)setWrinkleRemoveLevel:(float)level;

/// 设置祛眼袋 （增值版本有效，普通版本设置此参数无效） [仅限商业版Pro]
/// @param level 祛眼袋级别，取值范围 0 ~ 9； 0 表示关闭 1 - 9 值越大，效果越明显。
- (void)setPounchRemoveLevel:(float)level;

/// 设置法令纹 （增值版本有效，普通版本设置此参数无效） [仅限商业版Pro]
/// @param level 法令纹级别，取值范围 0 ~ 9； 0 表示关闭 1 - 9 值越大，效果越明显。
- (void)setSmileLinesRemoveLevel:(float)level;

/// 设置发际线 （增值版本有效，普通版本设置此参数无效） [仅限商业版Pro]
/// @param level 发际线级别，取值范围 0 ~ 9； 0 表示关闭 1 - 9 值越大，效果越明显。
- (void)setForeheadLevel:(float)level;

/// 设置眼距 （增值版本有效，普通版本设置此参数无效） [仅限商业版Pro]
/// @param level 眼距级别，取值范围 0 ~ 9； 0 表示关闭 1 - 9 值越大，效果越明显。
- (void)setEyeDistanceLevel:(float)level;

/// 设置眼角 （增值版本有效，普通版本设置此参数无效） [仅限商业版Pro]
/// @param level 眼角级别，取值范围 0 ~ 9； 0 表示关闭 1 - 9 值越大，效果越明显。
- (void)setEyeAngleLevel:(float)level;

/// 设置嘴型 （增值版本有效，普通版本设置此参数无效） [仅限商业版Pro]
/// @param level 嘴型级别，取值范围 0 ~ 9； 0 表示关闭 1 - 9 值越大，效果越明显。
- (void)setMouthShapeLevel:(float)level;

/// 设置鼻翼 （增值版本有效，普通版本设置此参数无效） [仅限商业版Pro]
/// @param level 鼻翼级别，取值范围 0 ~ 9； 0 表示关闭 1 - 9 值越大，效果越明显。
- (void)setNoseWingLevel:(float)level;

/// 设置鼻子位置 （增值版本有效，普通版本设置此参数无效） [仅限商业版Pro]
/// @param level 鼻子位置级别，取值范围 0 ~ 9； 0 表示关闭 1 - 9 值越大，效果越明显。
- (void)setNosePositionLevel:(float)level;

/// 设置嘴唇厚度 （增值版本有效，普通版本设置此参数无效） [仅限商业版Pro]
/// @param level 嘴唇厚度级别，取值范围 0 ~ 9； 0 表示关闭 1 - 9 值越大，效果越明显。
- (void)setLipsThicknessLevel:(float)level;

/// 设置美型（增值版本有效，普通版本设置此参数无效） [仅限商业版Pro]
/// @param  level 美型级别，取值范围 0 ~ 9； 0 表示关闭 1 - 9 值越大，效果越明显。
- (void)setFaceBeautyLevel:(float)level;

@end

NS_ASSUME_NONNULL_END
