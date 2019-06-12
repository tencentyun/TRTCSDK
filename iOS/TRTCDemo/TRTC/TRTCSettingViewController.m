/*
 * Module:   TRTCVideoViewLayout
 * 
 * Function: 用于对视频通话的分辨率、帧率和流畅模式进行调整，并支持记录下这些设置项
 *
 */

#import "TRTCSettingViewController.h"
#import "UIView+Additions.h"
#import "ColorMacro.h"
#import "TRTCCloudDef.h"

#define TRTC_SETTING_RESOLUTION @"TRTC_SETTING_RESOLUTION"
#define TRTC_SETTING_FPS        @"TRTC_SETTING_FPS"
#define TRTC_SETTING_BITRATE    @"TRTC_SETTING_BITRATE"
#define TRTC_SETTING_QOS_TYPE   @"TRTC_SETTING_QOS_TYPE"
#define TRTC_SETTING_QOS_CONTROL @"TRTC_SETTING_QOS_CONTROL"
#define TRTC_SETTING_ENABLE_SMALL_STREAM    @"TRTC_SETTING_ENABLE_SMALL_STREAM"
#define TRTC_SETTING_PRIOR_SMALL_STREAM     @"TRTC_SETTING_PRIOR_SMALL_STREAM"
#define TRTC_SETTING_SENCE      @"TRTC_SETTING_SCENE"
#define TRTC_SETTING_RESMODE   @"TRTC_SETTING_RES_MODE"


#define TAG_SETTING_RESOLUTION 5001
#define TAG_SETTING_FPS        5002
#define TAG_SETTING_BITRATE    5003
#define TAG_SETTING_CTRL_QOS   5004
#define TAG_SETTING_QOS        5005
#define TAG_SETTING_SCENE      5006
#define TAG_SETTING_RES_MODE   5007

#define SECTION_RESOLUTION              0
#define SECTION_FPS                     1
#define SECTION_BITRATE                 2
#define SECTION_QOS                     3
#define SECTION_RESMODE                 4
#define SECTION_QOS_CTRL                5
#define SECTION_ENABLE_SMALL_STREAM     6
#define SECTION_PRIOR_SMALL_STREAM      7
#define SECTION_SAVE_PARAM              8
#define SECTION_SCENE                   9

@implementation TRTCSettingsProperty
@end

@implementation TRTCSettingBitrateTable
- (instancetype)initWithResolution:(int)resolution defaultBitrate:(int)defaultBitrate
                        minBitrate:(int)minBitrate maxBitrate:(int)maxBitrate step:(int)step {
    if (self = [super init]) {
        self.resolution = resolution;
        self.defaultBitrate = defaultBitrate;
        self.minBitrate = minBitrate;
        self.maxBitrate = maxBitrate;
        self.step = step;
    }
    return self;
}
@end

@interface TRTCSettingViewController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    
    UISlider *_bitrateSlider;
    UILabel *_bitrateValueLabel;
    UISwitch *_saveSwith;
    UISwitch *_smallStreamSwitch;
    UISwitch *_priorSmallStreamSwitch;
    
    NSArray *_paramArray;  // TRTCSettingBitrateTable
    NSArray *_fpsArray;
    int _selectResolution;
    int _selectBitrate;
    int _selectFps;
    int _selectQosType;
    int _selectQosCtrlType;
    int _selectScene;
    int _selectResMode;
    
    UIActionSheet *_actionSheet;
    UITableView *_mainTableView;
}
@end

@implementation TRTCSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onClickedCancel:)];;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(onClickedOK:)];;
    
    TRTCAppScene scene = [[self class] getAppScene];
    //视频通话的模式码率设置
    _paramArray = @[[[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_160_160 defaultBitrate:150 minBitrate:40 maxBitrate:300 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_320_180 defaultBitrate:250 minBitrate:80 maxBitrate:350 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_320_240 defaultBitrate:300 minBitrate:100 maxBitrate:400 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_640_360 defaultBitrate:500 minBitrate:200 maxBitrate:1000 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_480_480 defaultBitrate:400 minBitrate:200 maxBitrate:1000 step:10],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_640_480 defaultBitrate:600 minBitrate:250 maxBitrate:1000 step:50],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_960_540 defaultBitrate:800 minBitrate:400 maxBitrate:1600 step:50],
                    [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_1280_720 defaultBitrate:1150 minBitrate:500 maxBitrate:2000 step:50]];
    //直播模式的码率设置
    if (scene == TRTCAppSceneLIVE) {
        _paramArray = @[[[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_160_160 defaultBitrate:225 minBitrate:40 maxBitrate:300 step:10],
                        [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_320_180 defaultBitrate:350 minBitrate:80 maxBitrate:350 step:10],
                        [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_320_240 defaultBitrate:400 minBitrate:100 maxBitrate:400 step:10],
                        [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_640_360 defaultBitrate:750 minBitrate:200 maxBitrate:1000 step:10],
                        [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_480_480 defaultBitrate:600 minBitrate:200 maxBitrate:1000 step:10],
                        [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_640_480 defaultBitrate:900 minBitrate:250 maxBitrate:1000 step:50],
                        [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_960_540 defaultBitrate:1200 minBitrate:400 maxBitrate:1600 step:50],
                        [[TRTCSettingBitrateTable alloc] initWithResolution:TRTCVideoResolution_1280_720 defaultBitrate:1750 minBitrate:500 maxBitrate:2000 step:50]];
    }
    
    _fpsArray = @[@(15), @(20), @(24)];
    
    _selectResolution = [TRTCSettingViewController getResolution];
    _selectBitrate = [TRTCSettingViewController getBitrate];
    _selectFps = [TRTCSettingViewController getFPS];
    _selectResMode = [TRTCSettingViewController getResMode];
    
    _bitrateValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width-80*kScaleX, 0, 80*kScaleX, 40*kScaleY)];
    _bitrateValueLabel.text = [NSString stringWithFormat:@"%dkbps", _selectBitrate];
    _bitrateValueLabel.textAlignment = NSTextAlignmentLeft;
    _bitrateValueLabel.font = [UIFont systemFontOfSize:16];
    
    _bitrateSlider = [[UISlider alloc] initWithFrame:CGRectMake(10*kScaleX, 0, self.view.width-90*kScaleX, 40*kScaleY)];
    for (int i = 0; i < [_paramArray count]; i++) {
        if ([_paramArray[i] resolution] == _selectResolution) {
            _bitrateSlider.minimumValue = [_paramArray[i] minBitrate] / [_paramArray[i] step];
            _bitrateSlider.maximumValue = [_paramArray[i] maxBitrate] / [_paramArray[i] step];
            _bitrateSlider.value = _selectBitrate / [_paramArray[i] step];
            _bitrateSlider.tag = [_paramArray[i] step]; // tag是倍数
            break;
        }
    }
    _bitrateSlider.continuous = YES;
    [_bitrateSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    // 是否保存配置
    _saveSwith = [[UISwitch alloc] initWithFrame:CGRectZero];
    _saveSwith.on = YES;
    
    _smallStreamSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    _smallStreamSwitch.on = [TRTCSettingViewController getEnableSmallStream];
    
    
    // 默认观看小流
    _priorSmallStreamSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    _priorSmallStreamSwitch.on = [TRTCSettingViewController getPriorSmallStream];

    // QOS类型
    _selectQosType = [TRTCSettingViewController getQosType];
    _selectQosCtrlType = [TRTCSettingViewController getQosCtrlType];
    _selectScene = [TRTCSettingViewController getAppScene];
    
    _mainTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:_mainTableView];
    [_mainTableView setContentInset:UIEdgeInsetsMake(0, 0, 34, 0)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent = YES;
}

+ (int)getResolution {
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:TRTC_SETTING_RESOLUTION];
    if (d != nil) {
        return [d intValue];
    }
    return TRTCVideoResolution_640_360;
}

+ (int)getFPS {
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:TRTC_SETTING_FPS];
    if (d != nil) {
        return [d intValue];
    }
    return 15;
}

+ (int)getAppScene {
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:TRTC_SETTING_SENCE];
    if (d != nil) {
        return [d intValue];
    }
    
    return TRTCAppSceneVideoCall;
}

+ (int)getBitrate {
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:TRTC_SETTING_BITRATE];
    if (d != nil) {
        return [d intValue];
    }
    
    //直播默认值为通话的1.5倍
    if ([[self class] getAppScene] == TRTCAppSceneLIVE)
        return 750;
    
    return 500;
}

+ (int)getQosType {
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:TRTC_SETTING_QOS_TYPE];
    if (d != nil) {
        return [d intValue];
    }
    return 1; // 默认清晰
}

+ (int)getQosCtrlType {
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:TRTC_SETTING_QOS_CONTROL];
    if (d != nil) {
        return [d intValue];
    }
    return TRTCQosControlModeServer;
}


+ (int)getResMode {
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:TRTC_SETTING_RESMODE];
    if (d != nil) {
        return [d intValue];
    }
    
    return TRTCVideoResolutionModePortrait;
}

+ (BOOL)getEnableSmallStream {
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:TRTC_SETTING_ENABLE_SMALL_STREAM];
    if (d != nil) {
        return [d intValue];
    }
    return 0;
}

+ (BOOL)getPriorSmallStream {
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:TRTC_SETTING_PRIOR_SMALL_STREAM];
    if (d != nil) {
        return [d intValue];
    }
    return 0;
}

+ (void)setAppScene:(int)appScene
{
    [[NSUserDefaults standardUserDefaults] setObject:@(appScene) forKey:TRTC_SETTING_SENCE];
}

- (NSString *)resolutionStr:(int)resolution {
    if (resolution == TRTCVideoResolution_160_160) return @"160x160";
    if (resolution == TRTCVideoResolution_320_180) return @"180x320";
    if (resolution == TRTCVideoResolution_320_240) return @"240x320";
    if (resolution == TRTCVideoResolution_640_360) return @"360x640";
    if (resolution == TRTCVideoResolution_480_480) return @"480x480";
    if (resolution == TRTCVideoResolution_640_480) return @"480x640";
    if (resolution == TRTCVideoResolution_960_540) return @"540x960";
    if (resolution == TRTCVideoResolution_1280_720) return @"720x1280";
    return @"";
}

- (NSString*)qosControlString:(int)qosControl
{
    if (qosControl == TRTCQosControlModeServer)
        return @"云端流控";
    if (qosControl == TRTCQosControlModeClient)
        return @"客户端流控";
    
    return @"未知";
}

- (NSString*)senceString:(int)scene
{
    if (scene == TRTCAppSceneVideoCall)
        return @"视频通话";
    if (scene == TRTCAppSceneLIVE)
        return @"在线直播";
    
    return @"";
}

- (void)onClickedCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onClickedOK:(id)sender {
    // 保存配置
    if (_saveSwith.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@(_selectResolution) forKey:TRTC_SETTING_RESOLUTION];
        [[NSUserDefaults standardUserDefaults] setObject:@(_selectFps) forKey:TRTC_SETTING_FPS];
        [[NSUserDefaults standardUserDefaults] setObject:@(_selectBitrate) forKey:TRTC_SETTING_BITRATE];
        [[NSUserDefaults standardUserDefaults] setObject:@(_selectQosType) forKey:TRTC_SETTING_QOS_TYPE];
        [[NSUserDefaults standardUserDefaults] setObject:@(_selectQosCtrlType) forKey:TRTC_SETTING_QOS_CONTROL];
        [[NSUserDefaults standardUserDefaults] setObject:@(_selectScene) forKey:TRTC_SETTING_SENCE];
        [[NSUserDefaults standardUserDefaults] setObject:@(_selectResMode) forKey:TRTC_SETTING_RESMODE];
        [[NSUserDefaults standardUserDefaults] setObject:@(_smallStreamSwitch.on) forKey:TRTC_SETTING_ENABLE_SMALL_STREAM];
        [[NSUserDefaults standardUserDefaults] setObject:@(_priorSmallStreamSwitch.on) forKey:TRTC_SETTING_PRIOR_SMALL_STREAM];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (_delegate) {
        
        TRTCSettingsProperty * property = [[TRTCSettingsProperty alloc] init];
        property.resolution = _selectResolution;
        property.fps = _selectFps;
        property.bitRate = _selectBitrate;
        property.qosType = _selectQosType;
        property.qosControl = _selectQosCtrlType;
        property.resMode = _selectResMode;
        property.enableSmallStream = _smallStreamSwitch.on;
        property.priorSmallStream = _priorSmallStreamSwitch.on;
        
        [_delegate settingVC:self
                    Property:property];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 9;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    if (indexPath.section == SECTION_RESOLUTION) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = [self resolutionStr:_selectResolution];
    } else if (indexPath.section == SECTION_FPS) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = [NSString stringWithFormat:@"%d", _selectFps];
    } else if (indexPath.section == SECTION_BITRATE) {
        [cell addSubview:_bitrateSlider];
        [cell addSubview:_bitrateValueLabel];
    } else if (indexPath.section == SECTION_ENABLE_SMALL_STREAM) {
        cell.textLabel.text = @"开启双路编码";
        cell.accessoryView = _smallStreamSwitch;
    } else if (indexPath.section == SECTION_PRIOR_SMALL_STREAM) {
        cell.textLabel.text = @"默认观看低清";
        cell.accessoryView = _priorSmallStreamSwitch;
    } else if (indexPath.section == SECTION_QOS) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = (_selectQosType == 0)?@"优先流畅":@"优先清晰";
    } else if (indexPath.section == SECTION_RESMODE) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = (_selectResMode == 0)?@"横屏模式":@"竖屏模式";
    }
    else if (indexPath.section == SECTION_SAVE_PARAM) {
        cell.textLabel.text = @"记住设置的参数";
        cell.accessoryView = _saveSwith;
    } else if (indexPath.section == SECTION_QOS_CTRL) {
        cell.textLabel.text = [self qosControlString:_selectQosCtrlType];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == SECTION_SCENE) {
        cell.textLabel.text = [self senceString:_selectScene];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_RESOLUTION) {
        return @"分辨率";
    }
    if (section == SECTION_FPS) {
        return @"帧率";
    }
    if (section == SECTION_BITRATE) {
        return @"码率";
    }
    if (section == SECTION_QOS) {
        return @"画质偏好";
    }
    if (section == SECTION_RESMODE) {
        return @"画面方向";
    }
    if (section == SECTION_QOS_CTRL) {
        return @"流控方案";
    }
    if (section == SECTION_SCENE) {
        return @"应用场景";
    }
    
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_RESOLUTION) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"分辨率" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"160x160",@"180x320",@"240x320",@"360x640",@"480x480",@"480x640",@"540x960",@"720x1280",nil];
        _actionSheet.tag = TAG_SETTING_RESOLUTION;
        _actionSheet.actionSheetStyle = UIBarStyleDefault;
        [_actionSheet showInView:self.view];
        
    } else if (indexPath.section == SECTION_FPS) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"帧率" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"15", @"20", @"24",nil];
        _actionSheet.tag = TAG_SETTING_FPS;
        _actionSheet.actionSheetStyle = UIBarStyleDefault;
        [_actionSheet showInView:self.view];
    } else if (indexPath.section == SECTION_QOS) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"画质偏好" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"流畅",@"清晰",nil];
        _actionSheet.tag = TAG_SETTING_QOS;
        _actionSheet.actionSheetStyle = UIBarStyleDefault;
        [_actionSheet showInView:self.view];
    } else if (indexPath.section == SECTION_RESMODE) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"画面方向" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"横屏模式",@"竖屏模式",nil];
        _actionSheet.tag = TAG_SETTING_RES_MODE;
        _actionSheet.actionSheetStyle = UIBarStyleDefault;
        [_actionSheet showInView:self.view];
    }
    else if (indexPath.section == SECTION_QOS_CTRL) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"流控方案" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"客户端流控", @"云端流控", nil];
        _actionSheet.tag = TAG_SETTING_CTRL_QOS;
        _actionSheet.actionSheetStyle = UIBarStyleDefault;
        [_actionSheet showInView:self.view];
    } else if (indexPath.section == SECTION_SCENE) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"应用场景" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"视频通话", @"在线直播", nil];
        _actionSheet.tag = TAG_SETTING_SCENE;
        _actionSheet.actionSheetStyle = UIBarStyleDefault;
        [_actionSheet showInView:self.view];
    }
}

#pragma mark - UIActionSheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == TAG_SETTING_RESOLUTION) { // 分辨率
        if (_selectResolution != [_paramArray[buttonIndex] resolution]) {
            _selectResolution = [_paramArray[buttonIndex] resolution];
            
            _bitrateSlider.minimumValue = [_paramArray[buttonIndex] minBitrate] / [_paramArray[buttonIndex] step];
            _bitrateSlider.maximumValue = [_paramArray[buttonIndex] maxBitrate] / [_paramArray[buttonIndex] step];;
            _bitrateSlider.value = [_paramArray[buttonIndex] defaultBitrate] / [_paramArray[buttonIndex] step];
            
            _selectBitrate = [_paramArray[buttonIndex] defaultBitrate];
            _bitrateSlider.tag = [_paramArray[buttonIndex] step]; // tag是倍数
            _bitrateValueLabel.text = [NSString stringWithFormat:@"%dkbps", _selectBitrate];
        }
    } else if (actionSheet.tag == TAG_SETTING_FPS) { // 帧率
        _selectFps = [_fpsArray[buttonIndex] intValue];
    } else if (actionSheet.tag == TAG_SETTING_QOS) {
        _selectQosType = (int)buttonIndex;
    } else if (actionSheet.tag == TAG_SETTING_RES_MODE) {
        _selectResMode = (int)buttonIndex;
    }
    else if(actionSheet.tag == TAG_SETTING_CTRL_QOS) {
        _selectQosCtrlType = (int)buttonIndex;
    } else if (actionSheet.tag == TAG_SETTING_SCENE) {
        _selectScene = (int)buttonIndex;
    }
    [_mainTableView reloadData];
}

#pragma mark - UISlider

- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    _selectBitrate = (int)(slider.value) * (int)slider.tag; // tag是倍数
    _bitrateValueLabel.text = [NSString stringWithFormat:@"%dkbps", _selectBitrate];
}


@end
