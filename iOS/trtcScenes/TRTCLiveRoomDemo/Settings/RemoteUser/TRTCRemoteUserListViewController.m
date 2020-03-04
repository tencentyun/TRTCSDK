/*
* Module:   TRTCRemoteUserListViewController
*
* Function: 房间内其它用户（即远端用户）的列表页
*
*    1. 列表中显示每个用户的ID，以及该用户的视频、音频开启状态
*
*    2. 点击用户项，将跳转到远端用户设置页
*
*/

#import "TRTCRemoteUserListViewController.h"
#import "TRTCRemoteUserCell.h"
#import "TRTCRemoteUserSettingsViewController.h"
#import "Masonry.h"

@interface TRTCRemoteUserListViewController ()

@property (strong, nonatomic) UIVisualEffectView *backView;

@end

@implementation TRTCRemoteUserListViewController

- (void)makeCustomRegistrition {
    [self.tableView registerClass:TRTCRemoteUserItem.bindedCellClass
           forCellReuseIdentifier:TRTCRemoteUserItem.bindedCellId];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"用户列表";
    self.view.backgroundColor = UIColor.clearColor;
    self.tableView.allowsSelection = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.items = [self buildMemberItems];
    [self.tableView reloadData];
}

- (NSArray *)buildMemberItems {
    NSMutableArray *users = [NSMutableArray array];
    [self.userManager.remoteUsers enumerateKeysAndObjectsUsingBlock:^(NSString *userId, TRTCRemoteUserConfig *settings, BOOL *stop) {
        [users addObject:[[TRTCRemoteUserItem alloc] initWithUser:userId settings:settings]];
    }];
    return users;
}

- (void)onSelectItem:(TRTCSettingsBaseItem *)item {
    TRTCRemoteUserSettingsViewController *vc = [[TRTCRemoteUserSettingsViewController alloc] init];
    vc.userManager = self.userManager;
    vc.userId = ((TRTCRemoteUserItem *) item).userId;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
