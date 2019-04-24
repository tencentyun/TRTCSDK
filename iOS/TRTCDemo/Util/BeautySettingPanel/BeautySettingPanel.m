//
//  BeautySettingPanel.m
//  RTMPiOSDemo
//
//  Created by rushanting on 2017/5/5.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "BeautySettingPanel.h"
#import "PituMotionAddress.h"
#import "TextCell.h"
#import "AFNetworking.h"
#ifdef PITU
#import "ZipArchive.h"
#endif
#import "ColorMacro.h"

#define BeautyViewMargin 8
#define BeautyViewSliderHeight 30
#define BeautyViewCollectionHeight 50
#define BeautyViewTitleWidth 40

#define L(x) NSLocalizedString((x), nil)

typedef NS_ENUM(NSUInteger, BeautyMenuItem) {
    BeautyMenuItemSmooth,
    BeautyMenuItemNature,
#ifdef UGC_SMART
    BeautyMenuItemLastBeautyTypeItem = BeautyMenuItemNature,
#else
    BeautyMenuItemPiTu,
    BeautyMenuItemLastBeautyTypeItem = BeautyMenuItemPiTu,
#endif
    BeautyMenuItemWhite,
    BeautyMenuItemRed,
    BeautyMenuItemLastBeautyValueItem = BeautyMenuItemRed,
    BeautyMenuItemEye,
    BeautyMenuItemFaceScale,
    BeautyMenuItemVFace,
    BeautyMenuItemChin,
    BeautyMenuItemShortFace,
    BeautyMenuItemNose
};

@interface BeautySettingPanel() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSArray<NSArray *> *_optionsContainer;
    NSMutableDictionary<NSNumber*, NSIndexPath*> *_selectedIndexMap;
    NSDictionary *_motionNameMap;
}
@property (nonatomic, assign) PanelMenuIndex currentMenuIndex;
@property (nonatomic, strong) UICollectionView *menuCollectionView;
@property (nonatomic, strong) UICollectionView *optionsCollectionView;

/// 美颜数值存储
@property (nonatomic, strong) NSMutableDictionary *beautyValueMap;

/// 滤镜数值存储
@property (nonatomic, strong) NSMutableDictionary *filterMap;
@property (nonatomic, strong) UILabel *filterLabel;
@property (nonatomic, strong) UISlider *filterSlider;
@property (nonatomic, strong) UILabel *beautyLabel;
@property (nonatomic, strong) UISlider *beautySlider;
@property (nonatomic, strong) NSArray *menuArray;
@property (nonatomic, strong) NSDictionary *motionAddressDic;
@property (nonatomic, strong) NSDictionary *koubeiAddressDic;
@property (nonatomic, strong) NSURLSessionDownloadTask *operation;
@property (nonatomic, assign) CGFloat beautyLevel;
@property (nonatomic, assign) CGFloat whiteLevel;
@property (nonatomic, assign) CGFloat ruddyLevel;
@property (nonatomic, assign) PanelBeautyStyle beautyStyle;
@end

@implementation BeautySettingPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _beautyValueMap = [[NSMutableDictionary alloc] init];
    _filterMap      = [[NSMutableDictionary alloc] init];

    self.beautySlider.frame = CGRectMake(BeautyViewMargin * 4, BeautyViewMargin, self.frame.size.width - 10 * BeautyViewMargin - BeautyViewSliderHeight, BeautyViewSliderHeight);
    [self addSubview:self.beautySlider];
    self.beautySlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    self.beautyLabel.frame = CGRectMake(self.beautySlider.frame.size.width + self.beautySlider.frame.origin.x + BeautyViewMargin, BeautyViewMargin, BeautyViewSliderHeight, BeautyViewSliderHeight);
    self.beautyLabel.layer.cornerRadius = self.beautyLabel.frame.size.width / 2;
    self.beautyLabel.layer.masksToBounds = YES;
    [self addSubview:self.beautyLabel];
    self.beautyLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    self.filterSlider.frame = CGRectMake(BeautyViewMargin * 4, BeautyViewMargin, self.frame.size.width - 10 * BeautyViewMargin - BeautyViewSliderHeight, BeautyViewSliderHeight);
    self.filterSlider.hidden = YES;
    [self addSubview:self.filterSlider];
    self.filterSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    self.filterLabel.frame = CGRectMake(self.filterSlider.frame.size.width + self.filterSlider.frame.origin.x + BeautyViewMargin, BeautyViewMargin, BeautyViewSliderHeight, BeautyViewSliderHeight);
    self.filterLabel.layer.cornerRadius = self.filterLabel.frame.size.width / 2;
    self.filterLabel.layer.masksToBounds = YES;
    self.filterLabel.hidden = YES;
    [self addSubview:self.filterLabel];
    self.filterLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    _menuArray = @[/*L(@"原图"),*/
                   /*L(@"风格"),*/
                   L(@"美颜"),
                   L(@"滤镜"),
#ifndef UGC_SMART
                   L(@"动效"),
                   L(@"抠背"),
                   L(@"绿幕")
#endif
                   ];

    NSArray *effectArray = @[L(@"清除"),
                             L(@"标准"),
                             L(@"樱红"),
                             L(@"云裳"),
                             L(@"纯真"),
                             L(@"白兰"),
                             L(@"元气"),
                             L(@"超脱"),
                             L(@"香氛"),
                             L(@"美白"),
                             L(@"浪漫"),
                             L(@"清新"),
                             L(@"唯美"),
                             L(@"粉嫩"),
                             L(@"怀旧"),
                             L(@"蓝调"),
                             L(@"清亮"),
                             L(@"日系")];

    NSArray *beautyArray = @[L(@"美颜(光滑)"),
                             L(@"美颜(自然)"),
#ifndef UGC_SMART
                             L(@"美颜(P图)"),
#endif
                             L(@"美白"),
                             L(@"红润"),
#ifndef UGC_SMART
                             L(@"大眼"),
                             L(@"瘦脸"),
                             L(@"V脸"),
                             L(@"下巴"),
                             L(@"短脸"),
                             L(@"瘦鼻")
#endif
                             ];
    //    NSArray *beautyStyleArray = @[L(@"BeautySettingPanel.BeautyTypeArray1"),
    //                                  L(@"BeautySettingPanel.BeautyTypeArray2"),
    //                                  L(@"BeautySettingPanel.BeautyTypeArray3")];

    NSArray *motionArray = @[L(@"清除"), @"video_boom" , @"video_nihongshu",    @"video_3DFace_dogglasses2",
                             @"video_fengkuangdacall", @"video_Qxingzuo_iOS", @"video_caidai_iOS",
                             @"video_liuhaifadai",     @"video_rainbow",      @"video_purplecat",
                             @"video_huaxianzi",       @"video_baby_agetest"];

    _motionAddressDic = NSDictionaryOfVariableBindings(video_3DFace_dogglasses2, video_baby_agetest, video_caidai_iOS, video_huaxianzi,
                                                       video_liuhaifadai, video_nihongshu, video_rainbow, video_boom, video_fengkuangdacall,
                                                       video_purplecat, video_Qxingzuo_iOS);

    NSArray *koubeiArray = @[L(@"清除"), @"video_xiaofu"];
    _koubeiAddressDic = NSDictionaryOfVariableBindings(video_xiaofu);

    NSArray *greenArray = @[L(@"清除"), @"goodluck"];

    _optionsContainer = @[ beautyArray, effectArray, motionArray, koubeiArray, greenArray];
    _selectedIndexMap = [NSMutableDictionary dictionaryWithCapacity:_optionsContainer.count];

    self.optionsCollectionView.frame = CGRectMake(0, self.beautySlider.frame.size.height + self.beautySlider.frame.origin.y + BeautyViewMargin, self.frame.size.width, BeautyViewSliderHeight * 2 + 2 * BeautyViewMargin);
    self.optionsCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.optionsCollectionView];

    self.menuCollectionView.frame = CGRectMake(0, self.optionsCollectionView.frame.size.height + self.optionsCollectionView.frame.origin.y, self.frame.size.width, BeautyViewCollectionHeight);
    self.menuCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.menuCollectionView];
}

#pragma mark - collection
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.menuCollectionView) {
        return self.menuArray.count;
    }
    return [_optionsContainer[_currentMenuIndex] count];
}

- (NSIndexPath *)selectedIndexPath {
    return [self selectedIndexPathForMenu:_currentMenuIndex];
}

- (NSIndexPath *)selectedIndexPathForMenu:(PanelMenuIndex)index {
    return _selectedIndexMap[@(index)] ?: [NSIndexPath indexPathForItem:0 inSection:0];
}

- (void)setSelectedIndexPath:(NSIndexPath *)indexPath {
    [self setSelectedIndexPath:indexPath forMenu:_currentMenuIndex];
}

- (void)setSelectedIndexPath:(NSIndexPath *)indexPath forMenu:(PanelMenuIndex)menuIndex {
    _selectedIndexMap[@(menuIndex)] = indexPath;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == _menuCollectionView){
        TextCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[TextCell reuseIdentifier] forIndexPath:indexPath];
        cell.label.font = [UIFont systemFontOfSize: [UIFont buttonFontSize]];
        cell.label.text = self.menuArray[indexPath.row];
        cell.selected = indexPath.row == _currentMenuIndex;
        return cell;
    } else {
        TextCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[TextCell reuseIdentifier] forIndexPath:indexPath];
        cell.label.font = [UIFont systemFontOfSize: [UIFont buttonFontSize]];
        NSString *text = [self textAtIndex:indexPath.row inMenu:_currentMenuIndex];
        cell.label.text = text;
        cell.selected = [indexPath isEqual: [self selectedIndexPath]];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    TextCell *cell = (TextCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    [collectionView deselectItemAtIndexPath: [collectionView indexPathsForSelectedItems].lastObject animated:NO];

    if(collectionView == _menuCollectionView){
        if(indexPath.row != _currentMenuIndex){
            [self changeFunction:indexPath.row];
            //            if([self.delegate respondsToSelector:@selector(reset:)]){
            //                [self.delegate reset:(indexPath.row == 0? YES : NO)];
            //            }
        }
    } else {
        // select options
        NSIndexPath *prevSelectedIndexPath = [self selectedIndexPath];
        [collectionView cellForItemAtIndexPath:prevSelectedIndexPath].selected = NO;

        if([indexPath isEqual:prevSelectedIndexPath]){
            // 和上次选的一样
            return;
        }
        [self setSelectedIndexPath:indexPath];
        switch (_currentMenuIndex) {
            case PanelMenuIndexBeauty: {
                float value = [[self.beautyValueMap objectForKey:[NSNumber numberWithInteger:indexPath.row]] floatValue];

                if (indexPath.row < 3) {
                    self.beautyStyle = indexPath.item;
                    _beautyLevel = value;
                }

                if(indexPath.row == 8){
                    //下巴
                    self.beautySlider.minimumValue = -10;
                    self.beautySlider.maximumValue = 10;
                } else {
                    self.beautySlider.minimumValue = 0;
                    self.beautySlider.maximumValue = 10;
                }
                self.beautyLabel.text = [NSString stringWithFormat:@"%d",(int)value];
                [self.beautySlider setValue:value];
                [self _applyBeautySettings];
            } break;
            case PanelMenuIndexFilter: {
                float value = [self filterMixLevelByIndex:[self selectedIndexPathForMenu:PanelMenuIndexFilter].item];
                self.filterSlider.value = value;
                self.filterLabel.text = @(value).stringValue;
                [self onSetEffectWithIndex:indexPath.row];
                [self onValueChanged:self.filterSlider];
            }   break;
            case PanelMenuIndexMotion:
                [self onSetMotionWithIndex:indexPath.row];
                break;
            case PanelMenuIndexKoubei:
                [self onSetKoubeiWithIndex:indexPath.row];
                break;
            case PanelMenuIndexGreen:
                [self onSetGreenWithIndex:indexPath.row];
                break;

            default:
                break;
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = nil;
    if(collectionView == _menuCollectionView){
        text = self.menuArray[indexPath.row];
    } else {
        text = [self textAtIndex:indexPath.row inMenu:_currentMenuIndex];;
    }

    UIFont *font = [UIFont systemFontOfSize: [UIFont buttonFontSize]];
    NSDictionary *attrs = @{NSFontAttributeName : font};
    CGSize size=[text sizeWithAttributes:attrs];
    return CGSizeMake(size.width + 2 * BeautyViewMargin, collectionView.frame.size.height);
}

#pragma mark - layout

- (void)changeFunction:(PanelMenuIndex)index
{
    self.beautyLabel.hidden  = index != PanelMenuIndexBeauty;
    self.beautySlider.hidden = self.beautyLabel.hidden;

    self.filterLabel.hidden  = index != PanelMenuIndexFilter;
    self.filterSlider.hidden = self.filterLabel.hidden;

    NSAssert(index < _optionsContainer.count, @"index out of range");
    [self.menuCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentMenuIndex inSection:0]].selected = NO;
    _currentMenuIndex = index;
    [self.optionsCollectionView reloadData];
}

- (void)_applyBeautySettings {
    if([self.delegate respondsToSelector:@selector(onSetBeautyStyle:beautyLevel:whitenessLevel:ruddinessLevel:)]){
        [self.delegate onSetBeautyStyle:self.beautyStyle beautyLevel:_beautyLevel whitenessLevel:_whiteLevel ruddinessLevel:_ruddyLevel];
    }
}

#pragma mark - value changed
- (void)onValueChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    float value = slider.value;
    if(slider == self.filterSlider){
        float value = self.filterSlider.value;
        self.filterLabel.text = [NSString stringWithFormat:@"%.0f",value];
        NSUInteger filterIndex = [self selectedIndexPathForMenu:PanelMenuIndexFilter].item;
        self.filterMap[@(filterIndex)] = @(value);
        if([self.delegate respondsToSelector:@selector(onSetMixLevel:)]){
            [self.delegate onSetMixLevel:value];
        }
    } else {
        // 判断选择了哪个二级菜单
        int beautyIndex = (int)[self selectedIndexPathForMenu:PanelMenuIndexBeauty].row;

        [self.beautyValueMap setObject:[NSNumber numberWithFloat:self.beautySlider.value] forKey:@(beautyIndex)];
        self.beautyLabel.text = [NSString stringWithFormat:@"%d",(int)self.beautySlider.value];

        if(beautyIndex <= BeautyMenuItemLastBeautyValueItem) {
            if (beautyIndex <= BeautyMenuItemLastBeautyTypeItem) {
                _beautyLevel = slider.value;
            } else if (beautyIndex == BeautyMenuItemWhite) {
                _whiteLevel = value;
            } else if (beautyIndex == BeautyMenuItemRed) {
                _ruddyLevel = value;
            }
            [self _applyBeautySettings];
        }

        if(beautyIndex == BeautyMenuItemEye) {
            if([self.delegate respondsToSelector:@selector(onSetEyeScaleLevel:)]){
                [self.delegate onSetEyeScaleLevel:value];
            }
        }
        else if(beautyIndex == BeautyMenuItemFaceScale){
            if([self.delegate respondsToSelector:@selector(onSetFaceScaleLevel:)]){
                [self.delegate onSetFaceScaleLevel:value];
            }
        }
        //        else if(beautyIndex == 5){
        //            if([self.delegate respondsToSelector:@selector(onSetFaceBeautyLevel:)]){
        //                [self.delegate onSetFaceBeautyLevel:self.beautySlider.value];
        //            }
        //        }
        else if(beautyIndex == BeautyMenuItemVFace){
            if([self.delegate respondsToSelector:@selector(onSetFaceVLevel:)]){
                [self.delegate onSetFaceVLevel:value];
            }
        }
        else if(beautyIndex == BeautyMenuItemChin){
            if([self.delegate respondsToSelector:@selector(onSetChinLevel:)]){
                [self.delegate onSetChinLevel:value];
            }
        }
        else if(beautyIndex == BeautyMenuItemShortFace){
            if([self.delegate respondsToSelector:@selector(onSetFaceShortLevel:)]){
                [self.delegate onSetFaceShortLevel:value];
            }
        }
        else if(beautyIndex == BeautyMenuItemNose){
            if([self.delegate respondsToSelector:@selector(onSetNoseSlimLevel:)]){
                [self.delegate onSetNoseSlimLevel:value];
            }
        }
    }
}

- (void)onSetEffectWithIndex:(FilterType)index
{
    if ([self.delegate respondsToSelector:@selector(onSetFilter:)]) {
        UIImage *image = [self filterImageByIndex:index];
        [self.delegate onSetFilter:image];
    }
}

- (void)onSetGreenWithIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(onSetGreenScreenFile:)]) {
        if (index == 0) {
            [self.delegate onSetGreenScreenFile:nil];
        }
        if (index == 1) {
            [self.delegate onSetGreenScreenFile:[[NSBundle mainBundle] URLForResource:@"goodluck" withExtension:@"mp4"]];

        }
    }
}

- (void)onSetMotionWithIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(onSelectMotionTmpl:inDir:)]) {
        NSString *localPackageDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/packages"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:localPackageDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:localPackageDir withIntermediateDirectories:NO attributes:nil error:nil];
        }
        if (index == 0){
            [self.delegate onSelectMotionTmpl:nil inDir:localPackageDir];
        }
        else{
            NSArray *motionAray = _optionsContainer[PanelMenuIndexMotion];
            NSString *tmp = [motionAray objectAtIndex:index];
            NSString *pituPath = [NSString stringWithFormat:@"%@/%@", localPackageDir, tmp];
            if ([[NSFileManager defaultManager] fileExistsAtPath:pituPath]) {
                [self.delegate onSelectMotionTmpl:tmp inDir:localPackageDir];
            }else{
                [self startLoadPitu:localPackageDir pituName:tmp packageURL:[NSURL URLWithString:[_motionAddressDic objectForKey:tmp]]];
            }
        }
    }
}

- (void)onSetKoubeiWithIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(onSelectMotionTmpl:inDir:)]) {
        NSString *localPackageDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/packages"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:localPackageDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:localPackageDir withIntermediateDirectories:NO attributes:nil error:nil];
        }
        if (index == 0){
            [self.delegate onSelectMotionTmpl:nil inDir:localPackageDir];
        }
        else{
            NSArray *koubeiArray = _optionsContainer[PanelMenuIndexKoubei];
            NSString *tmp = [koubeiArray objectAtIndex:index];
            NSString *pituPath = [NSString stringWithFormat:@"%@/%@", localPackageDir, tmp];
            if ([[NSFileManager defaultManager] fileExistsAtPath:pituPath]) {
                [self.delegate onSelectMotionTmpl:tmp inDir:localPackageDir];
            }else{
                [self startLoadPitu:localPackageDir pituName:tmp packageURL:[NSURL URLWithString:[_koubeiAddressDic objectForKey:tmp]]];
            }
        }
    }
}

- (void)startLoadPitu:(NSString *)pituDir pituName:(NSString *)pituName packageURL:(NSURL *)packageURL{
#ifdef PITU
    if (self.operation) {
        if (self.operation.state != NSURLSessionTaskStateRunning) {
            [self.operation resume];
        }
    }
    NSString *targetPath = [NSString stringWithFormat:@"%@/%@.zip", pituDir, pituName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
    }

    __weak __typeof(self) weakSelf = self;
    NSURLRequest *downloadReq = [NSURLRequest requestWithURL:packageURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.f];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak AFHTTPSessionManager *weakManager = manager;
    [self.pituDelegate onLoadPituStart];
    self.operation = [manager downloadTaskWithRequest:downloadReq progress:^(NSProgress * _Nonnull downloadProgress) {
        if (weakSelf.pituDelegate) {
            CGFloat progress = (float)downloadProgress.completedUnitCount / (float)downloadProgress.totalUnitCount;
            [weakSelf.pituDelegate onLoadPituProgress:progress];
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath_, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:targetPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [weakManager invalidateSessionCancelingTasks:YES];
        if (error) {
            [weakSelf.pituDelegate onLoadPituFailed];
            return;
        }
        // 解压
        BOOL unzipSuccess = NO;
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        if ([zipArchive UnzipOpenFile:targetPath]) {
            unzipSuccess = [zipArchive UnzipFileTo:pituDir overWrite:YES];
            [zipArchive UnzipCloseFile];

            // 删除zip文件
            [[NSFileManager defaultManager] removeItemAtPath:targetPath error:&error];
        }
        if (unzipSuccess) {
            [weakSelf.pituDelegate onLoadPituFinished];
            [weakSelf.delegate onSelectMotionTmpl:pituName inDir:pituDir];
        } else {
            [weakSelf.pituDelegate onLoadPituFailed];
        }
    }];
    [self.operation resume];
#endif
}

#pragma mark - height
+ (NSUInteger)getHeight
{
    return BeautyViewMargin * 4 + 3 * BeautyViewSliderHeight + BeautyViewCollectionHeight;
}

#pragma mark - Translator
/// 获取二级菜单显示名字
- (NSString *)textAtIndex:(NSInteger)index inMenu:(PanelMenuIndex)menuIndex {
    NSString *text = _optionsContainer[menuIndex][index];
    if (menuIndex == PanelMenuIndexMotion || menuIndex == PanelMenuIndexKoubei) {
        text = [self getMotionName:text];
    }
    return text;
}

/// 动效的显示名字
- (NSString *)getMotionName:(NSString *)motion
{
    if (_motionNameMap == nil) {
        _motionNameMap = @{
                           @"video_boom":               L(@"Boom"),
                           @"video_nihongshu":          L(@"霓虹鼠"),
                           @"video_3DFace_dogglasses2": L(@"眼镜狗"),
                           @"video_fengkuangdacall":    L(@"疯狂打call"),
                           @"video_Qxingzuo_iOS" :      L(@"Q星座"),
                           @"video_caidai_iOS" :        L(@"彩色丝带"),
                           @"video_liuhaifadai" :       L(@"刘海发带"),
                           @"video_rainbow":            L(@"彩虹云"),
                           @"video_purplecat":          L(@"紫色小猫"),
                           @"video_huaxianzi":          L(@"花仙子"),
                           @"video_baby_agetest":       L(@"小公举"),
                           @"video_xiaofu":             L(@"AI抠背")
                           };
    }
    return _motionNameMap[motion] ?: motion;
}

- (UIImage*)filterImageByIndex:(NSInteger)index;
{
    NSString *lookupFileName = nil;

#define CASE(x) case FilterType_##x: lookupFileName = @#x".png"; break;

    switch (index)
    {
            CASE(normal)
            CASE(yinghong)
            CASE(yunshang)
            CASE(chunzhen)
            CASE(bailan)
            CASE(yuanqi)
            CASE(chaotuo)
            CASE(xiangfen)
            CASE(white)
            CASE(langman)
            CASE(qingxin)
            CASE(weimei)
            CASE(fennen)
            CASE(huaijiu)
            CASE(landiao)
            CASE(qingliang)
            CASE(rixi)
        default:
            break;
    }

    if (lookupFileName != nil) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"FilterResource" ofType:@"bundle"];
        if (path != nil && index != FilterType_None) {
            path = [path stringByAppendingPathComponent:lookupFileName];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            return image;
        }
    }
    return nil;
}

- (float)filterMixLevelByIndex:(NSInteger)index
{
    if (index < 0)
        index = self.filterMap.count - 1;
    if (index >= self.filterMap.count)
        index = 0;
    return ((NSNumber*)[self.filterMap objectForKey:@(index)]).floatValue;
}

/// 二级菜单
- (UICollectionView *)optionsCollectionView {
    if (_optionsCollectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _optionsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _optionsCollectionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _optionsCollectionView.showsHorizontalScrollIndicator = NO;
        _optionsCollectionView.delegate = self;
        _optionsCollectionView.dataSource = self;
        [_optionsCollectionView registerClass:[TextCell class] forCellWithReuseIdentifier:[TextCell reuseIdentifier]];
    }
    return _optionsCollectionView;
}

/// 一级菜单
- (UICollectionView *)menuCollectionView
{
    if(!_menuCollectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //        layout.itemSize = CGSizeMake(100, 40);
        _menuCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _menuCollectionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        _menuCollectionView.showsHorizontalScrollIndicator = NO;
        _menuCollectionView.delegate = self;
        _menuCollectionView.dataSource = self;
        [_menuCollectionView registerClass:[TextCell class] forCellWithReuseIdentifier:[TextCell reuseIdentifier]];
    }
    return _menuCollectionView;
}

/// 美颜滑杆
- (UISlider *)beautySlider
{
    if(!_beautySlider){
        _beautySlider = [[UISlider alloc] init];
        _beautySlider.minimumValue = 0;
        _beautySlider.maximumValue = 10;
        [_beautySlider setMinimumTrackTintColor:UIColorFromRGB(0x0ACCAC)];
        [_beautySlider setMaximumTrackTintColor:[UIColor whiteColor]];
        [_beautySlider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _beautySlider;
}

/// 滑杆数值显示
- (UILabel *)beautyLabel
{
    if(!_beautyLabel){
        _beautyLabel = [[UILabel alloc] init];
        _beautyLabel.backgroundColor = [UIColor whiteColor];
        _beautyLabel.textAlignment = NSTextAlignmentCenter;
        _beautyLabel.text = @"0";
        [_beautyLabel setTextColor:UIColorFromRGB(0x0ACCAC)];
    }
    return _beautyLabel;
}

/// 滤镜滑杆
- (UISlider *)filterSlider
{
    if(!_filterSlider){
        _filterSlider = [[UISlider alloc] init];
        _filterSlider.minimumValue = 0;
        _filterSlider.maximumValue = 10;
        [_filterSlider setMinimumTrackTintColor:UIColorFromRGB(0x0ACCAC)];
        [_filterSlider setMaximumTrackTintColor:[UIColor whiteColor]];
        [_filterSlider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _filterSlider;
}

/// 滤镜滑杆数值显示
- (UILabel *)filterLabel
{
    if(!_filterLabel){
        _filterLabel = [[UILabel alloc] init];
        _filterLabel.backgroundColor = [UIColor whiteColor];
        _filterLabel.textAlignment = NSTextAlignmentCenter;
        _filterLabel.text = @"0";
        [_filterLabel setTextColor:UIColorFromRGB(0x0ACCAC)];
    }
    return _filterLabel;
}

/// 重置为默认值
- (void)resetValues
{
    self.beautySlider.hidden = NO;
    self.beautyLabel.hidden = NO;
    self.filterSlider.hidden = YES;
    self.filterLabel.hidden = YES;

    [_selectedIndexMap removeAllObjects];
    [self.optionsCollectionView reloadData];

    [self onSetMotionWithIndex:0];
    [self onSetKoubeiWithIndex:0];
    [self onSetGreenWithIndex:0];

    // 重置美颜滤镜
    [self.beautyValueMap removeAllObjects];
    [self.beautyValueMap setObject:@(3) forKey:@(BeautyMenuItemSmooth)]; //美颜默认值（光滑）
    [self.beautyValueMap setObject:@(6) forKey:@(BeautyMenuItemNature)]; //美颜默认值（自然）
#ifndef UGC_SMART
    [self.beautyValueMap setObject:@(5) forKey:@(BeautyMenuItemPiTu)];   //美颜默认值（天天PITU）
#endif
    [self.beautyValueMap setObject:@(1) forKey:@(BeautyMenuItemWhite)];  //美白默认值
    [self.beautyValueMap setObject:@(0) forKey:@(BeautyMenuItemRed)];    //红润默认值

    _whiteLevel = 1;
    _beautyLevel = 6;
    _ruddyLevel = 0;
    
    self.beautySlider.minimumValue = 0;
    self.beautySlider.maximumValue = 10;
    
    const BeautyMenuItem defaultBeautyStyle = BeautyMenuItemNature;
    self.beautyStyle = PanelBeautyStyle_STYLE_NATURE;
    NSInteger beautyValue = [self.beautyValueMap[@(defaultBeautyStyle)] integerValue];
    self.beautySlider.value = beautyValue;
    self.beautyLabel.text = [NSString stringWithFormat:@"%d",(int)beautyValue];
    [self setSelectedIndexPath:[NSIndexPath indexPathForItem:defaultBeautyStyle inSection:0] forMenu:PanelMenuIndexBeauty];

    // 重置滤镜
    NSDictionary *defaultFilterValue = @{
                                    @(FilterType_None)        :@(0) 
                                    ,@(FilterType_normal)     :@(5)  
                                    ,@(FilterType_yinghong)   :@(8)
                                    ,@(FilterType_yunshang)   :@(8)  
                                    ,@(FilterType_chunzhen)   :@(7)  
                                    ,@(FilterType_bailan)     :@(10) 
                                    ,@(FilterType_yuanqi)     :@(8)  
                                    ,@(FilterType_chaotuo)    :@(10)
                                    ,@(FilterType_xiangfen)   :@(5)  
                                    ,@(FilterType_white)      :@(3)      
                                    ,@(FilterType_langman)    :@(3) 
                                    ,@(FilterType_qingxin)    :@(3) 
                                    ,@(FilterType_weimei)     :@(3) 
                                    ,@(FilterType_fennen)     :@(3)      
                                    ,@(FilterType_huaijiu)    :@(3) 
                                    ,@(FilterType_landiao)    :@(3) 
                                    ,@(FilterType_qingliang)  :@(3) 
                                    ,@(FilterType_rixi)       :@(3) 
                                    };
    [self.filterMap setDictionary:defaultFilterValue];
    const FilterType defaultFilter = FilterType_normal;
    [self setSelectedIndexPath:[NSIndexPath indexPathForItem:defaultFilter inSection:0] forMenu:PanelMenuIndexFilter];
    self.filterSlider.value = [defaultFilterValue[@(defaultFilter)] intValue];
    [self onSetEffectWithIndex:defaultFilter];

    self.currentMenuIndex = PanelMenuIndexBeauty;
    [self.menuCollectionView reloadData];
    [self.optionsCollectionView reloadData];
    [self onValueChanged:self.beautySlider];
    [self onValueChanged:self.filterSlider];
}


- (void)trigglerValues{
    [self onValueChanged:self.beautySlider];
    [self onValueChanged:self.filterSlider];
}

- (NSArray *)filterOptions {
    return _optionsContainer[PanelMenuIndexFilter];
}

- (void)setCurrentFilterIndex:(NSInteger)currentFilterIndex
{
    if (currentFilterIndex < 0)
        currentFilterIndex = self.filterOptions.count - 1;
    if (currentFilterIndex >= self.filterOptions.count)
        currentFilterIndex = 0;
    [self setSelectedIndexPath:[NSIndexPath indexPathForItem:currentFilterIndex inSection:0] forMenu:PanelMenuIndexFilter];
    if (_currentMenuIndex == PanelMenuIndexFilter) {
        [self.optionsCollectionView reloadData];
    }
}

- (NSInteger)currentFilterIndex
{
    return [self selectedIndexPathForMenu:PanelMenuIndexFilter].item;
}

- (NSString*)currentFilterName
{
    NSInteger index = self.currentFilterIndex;
    NSArray *filters = [self filterOptions];
    if (index < filters.count) {
        return filters[index];
    }
    return nil;
}
@end
