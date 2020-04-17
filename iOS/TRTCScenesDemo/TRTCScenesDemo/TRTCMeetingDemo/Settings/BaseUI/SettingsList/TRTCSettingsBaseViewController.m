/*
* Module:   TRTCSettingsBaseViewController
*
* Function: 基础框架类。用作包含各种配置项的列表页
*
*    1. 列表的各种配置Cell定义在Cells目录中，也可继承
*
*    2. 通过继承TRTCSettingsBaseCell，可自定义Cell，需要在TRTCSettingsBaseViewController
*       子类中重载makeCustomRegistrition，并调用registerClass将Cell注册到tableView中。
*
*/

#import "TRTCSettingsBaseViewController.h"
#import "Masonry.h"

@interface TRTCSettingsBaseViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation TRTCSettingsBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.clearColor;
    [self setupTableView];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:TRTCSettingsSwitchItem.bindedCellClass
           forCellReuseIdentifier:TRTCSettingsSwitchItem.bindedCellId];
    [self.tableView registerClass:TRTCSettingsSegmentItem.bindedCellClass
           forCellReuseIdentifier:TRTCSettingsSegmentItem.bindedCellId];
    [self.tableView registerClass:TRTCSettingsMessageItem.bindedCellClass
           forCellReuseIdentifier:TRTCSettingsMessageItem.bindedCellId];
    [self.tableView registerClass:TRTCSettingsButtonItem.bindedCellClass
           forCellReuseIdentifier:TRTCSettingsButtonItem.bindedCellId];
    [self.tableView registerClass:TRTCSettingsSliderItem.bindedCellClass
           forCellReuseIdentifier:TRTCSettingsSliderItem.bindedCellId];
    [self.tableView registerClass:TRTCSettingsSelectorItem.bindedCellClass
           forCellReuseIdentifier:TRTCSettingsSelectorItem.bindedCellId];
    [self.tableView registerClass:TRTCSettingsLargeInputItem.bindedCellClass
           forCellReuseIdentifier:TRTCSettingsLargeInputItem.bindedCellId];
    [self.tableView registerClass:TRTCSettingsInputItem.bindedCellClass
           forCellReuseIdentifier:TRTCSettingsInputItem.bindedCellId];

    [self makeCustomRegistrition];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:NO];
}

- (void)makeCustomRegistrition {
}

- (void)onSelectItem:(TRTCSettingsBaseItem *)item {
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    TRTCSettingsBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:self.items[indexPath.row].bindedCellId];
    [cell didSelect];
    [self onSelectItem:self.items[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.items[indexPath.row].height;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TRTCSettingsBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:self.items[indexPath.row].bindedCellId];
    cell.item = self.items[indexPath.row];

    return cell;
}

@end
