//
//  ViewController.m
//  TRTC-API-Example-OC
//
//  Created by dangjiahe on 2021/4/10.
//

#import "ViewController.h"
#import "SwitchRoomViewController.h"
#import "LiveEnterViewController.h"
#import "AudioCallingEnterViewController.h"
#import "VideoCallingEnterViewController.h"
#import "ScreenEntranceViewController.h"
#import "VoiceChatRoomEnterViewController.h"
#import "SetAudioEffectViewController.h"
#import "SetAudioQualityViewController.h"
#import "SetVideoQualityViewController.h"
#import "SetBGMViewController.h"
#import "SpeedTestViewController.h"
#import "PushCDNSelectRoleViewController.h"
#import "LocalRecordViewController.h"
#import "SetRenderParamsViewController.h"
#import "SendAndReceiveSEIMessageViewController.h"
#import "JoinMultipleRoomViewController.h"
#import "RoomPkViewController.h"
#import "ThirdBeautyViewController.h"
#import "CustomCaptureViewController.h"
#import "LocalVideoShareViewController.h"
#import "StringRoomIdViewController.h"
#import "HomeTableViewCell.h"
#import <objc/runtime.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *homeTableView;
@property (nonatomic, strong) NSArray *homeData;
@end

@implementation ViewController

- (NSArray *)homeData {
    if (!_homeData) {
        _homeData = @[
            @{@"type":Localize(@"TRTC-API-Example.Home.BasicFunctions"),
              @"module":@[
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.VoiceCalls"),
                          @"desc": Localize(@"TRTC-API-Example.Home.VoiceCallsDesc"),
                          @"class": @"AudioCallingEnterViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.VideoCalls"),
                          @"desc": Localize(@"TRTC-API-Example.Home.VideoCallsDesc"),
                          @"class": @"VideoCallingEnterViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.VideoLive"),
                          @"desc": @"",
                          @"class": @"LiveEnterViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.TalkingRoom"),
                          @"desc": @"",
                          @"class": @"VoiceChatRoomEnterViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.LiveScreen"),
                          @"desc": Localize(@"TRTC-API-Example.Home.LiveScreenDesc"),
                          @"class": @"ScreenEntranceViewController"
                      }
              ]},
            @{@"type":Localize(@"TRTC-API-Example.Home.AdvancedFeatures"),
              @"module":@[
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.StringRoomId"),
                          @"desc": @"",
                          @"class": @"StringRoomIdViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.VideoQuality"),
                          @"desc": @"",
                          @"class": @"SetVideoQualityViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.SoundQuality"),
                          @"desc": @"",
                          @"class": @"SetAudioQualityViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.RenderParams"),
                          @"desc": @"",
                          @"class": @"SetRenderParamsViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.SpeedTest"),
                          @"desc": @"",
                          @"class": @"SpeedTestViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.PushCDN"),
                          @"desc": @"",
                          @"class": @"PushCDNSelectRoleViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.CustomCamera"),
                          @"desc": @"",
                          @"class": @"CustomCaptureViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.SoundEffects"),
                          @"desc": @"",
                          @"class": @"SetAudioEffectViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.SetBGM"),
                          @"desc": @"",
                          @"class": @"SetBGMViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.LocalVideoShare"),
                          @"desc": @"",
                          @"class": @"LocalVideoShareViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.LocalRecord"),
                          @"desc": @"",
                          @"class": @"LocalRecordViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.JoinMultipleRoom"),
                          @"desc": @"",
                          @"class": @"JoinMultipleRoomViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.SendReceiveSEIMessage"),
                          @"desc": @"",
                          @"class": @"SendAndReceiveSEIMessageViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.QuicklySwitchRooms"),
                          @"desc": @"",
                          @"class": @"SwitchRoomViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.RoomPK"),
                          @"desc": @"",
                          @"class": @"RoomPkViewController"
                      },
                      @{
                          @"title": Localize(@"TRTC-API-Example.Home.ThirdBeauty"),
                          @"desc": @"",
                          @"class": @"ThirdBeautyViewController"
                      }
              ]}];
    }
    return _homeData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id) self;
    [self setupNaviBarStatus];
    [self setupTableView];
}

- (void)setupNaviBarStatus {
    self.navigationItem.title = Localize(@"TRTC-API-Example.Home.Title");
    [self.navigationController setNavigationBarHidden:false animated:false];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)setupTableView {
    [self.homeTableView registerNib:[UINib nibWithNibName:@"HomeTableViewCell" bundle:nil] forCellReuseIdentifier: HomeTableViewCellReuseIdentify];
    self.homeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  self.homeData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *homeDic = self.homeData[section];
    NSArray *homeArray = [homeDic objectForKey:@"module"];
    return  homeArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, headerView.bounds.size.width, 40)];
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.font = [UIFont systemFontOfSize:16];
    NSDictionary *homeDic = self.homeData[section];
    titleLabel.text = [homeDic objectForKey:@"type"];
    [headerView addSubview:titleLabel];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HomeTableViewCellReuseIdentify forIndexPath:indexPath];
    NSDictionary *homeDic = self.homeData[indexPath.section];
    NSArray *homeArray = [homeDic objectForKey:@"module"];
    [cell setHomeDictionary:homeArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *homeDic = self.homeData[indexPath.section];
    NSArray *homeArray = [homeDic objectForKey:@"module"];
    NSDictionary *homeFeaturesDic = homeArray[indexPath.row];
    [self pushFeaturesViewController:homeFeaturesDic[@"class"]];
}

- (void)pushFeaturesViewController:(NSString *)className {
    Class class = NSClassFromString(className);
    if (class) {
        id controller = [[class alloc] initWithNibName:className bundle:nil];
        if (controller) {
            [self.navigationController pushViewController:controller animated:true];
        }
    }
}

@end
