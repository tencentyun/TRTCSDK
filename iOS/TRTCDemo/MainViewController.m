
#import "MainViewController.h"
#import <TRTCCloudDef.h>

#import "TRTCNewViewController.h"
#import "CreateTRTCAudioCallViewController.h"
#import "CreateTRTCVoiceRoomViewController.h"

#import "ColorMacro.h"
#import "MainMenuCell.h"

@interface MainViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray<MainMenuItem *> *mainMenuItems;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0x0d0d0d);
    
    __weak __typeof(self) wSelf = self;
    self.mainMenuItems = @[
        [[MainMenuItem alloc]
         initWithIcon:[UIImage imageNamed:@"MenuAudioCall"]
         title:@"语音通话"
         content:@"48kHz高音质语音，60%丢包可正常语音，领先行业的3A处理，杜绝回声和啸叫"
         onSelect:^{ [wSelf gotoAudioCallView]; }],
        [[MainMenuItem alloc]
         initWithIcon:[UIImage imageNamed:@"MenuVideoCall"]
         title:@"视频通话"
         content:@"支持1080P超清视频，50%丢包率可正常视频，自备美颜特效，带来高品质视频通话体验"
         onSelect:^{ [wSelf gotoVideoCallView]; }],
        [[MainMenuItem alloc]
         initWithIcon:[UIImage imageNamed:@"MenuVoiceRoom"]
         title:@"语音聊天房"
         content:@"内含变声、音效、伴奏、背景音乐等声音玩法，适用于闲聊房、K歌房和开黑房等场景"
         onSelect:^{ [wSelf gotoVoiceRoomView]; }],
        [[MainMenuItem alloc]
         initWithIcon:[UIImage imageNamed:@"MenuLive"]
         title:@"视频互动直播"
         content:@"观众时延低至800ms，上下麦无需loading，适用于低延时、十万人高并发的大型互动直播"
         onSelect:^{ [wSelf gotoLiveView]; }]
    ];
}

- (void)gotoAudioCallView {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"TRTCAudioCall" bundle:nil]
                            instantiateViewControllerWithIdentifier:@"CreateTRTCAudioCallViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoVideoCallView {
    TRTCNewViewController *vc = [[TRTCNewViewController alloc] init];
    vc.appScene = TRTCAppSceneVideoCall;
    vc.menuTitle = @"视频通话";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoVoiceRoomView {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"TRTCVoiceRoom" bundle:nil]
                            instantiateViewControllerWithIdentifier:@"CreateTRTCVoiceRoomViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoLiveView {
    TRTCNewViewController *vc = [[TRTCNewViewController alloc] init];
    vc.appScene = TRTCAppSceneLIVE;
    vc.menuTitle = @"视频互动直播";
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mainMenuItems.count;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainMenuCell" forIndexPath:indexPath];
    cell.item = self.mainMenuItems[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.mainMenuItems[indexPath.row].selectBlock();
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

@end
