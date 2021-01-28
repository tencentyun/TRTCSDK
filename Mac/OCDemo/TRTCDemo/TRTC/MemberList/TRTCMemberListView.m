//
//  TRTCMemberListView.m
//  TXLiteAVMacDemo
//
//  Created by Xiaoya Liu on 2020/2/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TRTCMemberListView.h"
#import "TRTCMemberListCell.h"
#import "TRTCUserManager.h"

@interface TRTCMemberListView()<NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, strong) NSArray<TRTCUserConfig *> *userList;

@property (weak) IBOutlet NSTableView *userTableView;
@property (weak) IBOutlet NSTableHeaderView *headerView;
@property (nonatomic, strong) NSTextField *userCountLabel;
@property (nonatomic, strong, nullable) TRTCUserManager *userManager;

@end

@implementation TRTCMemberListView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupHeaderView];
    self.wantsLayer = YES;
    self.layer.backgroundColor = [NSColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0].CGColor;
    
    self.userTableView.backgroundColor = [NSColor clearColor];
    [[self.userTableView enclosingScrollView] setDrawsBackground:NO];
}

- (void)dealloc {
    [self.userManager removeObserver:self forKeyPath:@"userConfigs"];
}

- (void)setupHeaderView {
    if (self.userCountLabel) {
        return;
    }
    self.userCountLabel = [[NSTextField alloc] init];
    self.userCountLabel.editable = NO;
    [self.headerView addSubview:self.userCountLabel];
    self.userCountLabel.frame = self.headerView.bounds;
}

- (void)observeUserManager:(TRTCUserManager *)userManager {
    self.userManager = userManager;
    [userManager addObserver:self forKeyPath:@"userConfigs" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"userConfigs"]) {
        self.userList = ((TRTCUserManager *)object).userConfigs;
        self.userCountLabel.stringValue = [NSString stringWithFormat:@"成员(%@人)", @(self.userList.count)];
        [self.userTableView reloadData];
    }
}

#pragma mark - UITableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    TRTCMemberListCell *cell = [tableView makeViewWithIdentifier:@"TRTCMemberListCell" owner:self];
    cell.user = self.userList[row];
    cell.userManager = self.userManager;
    return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.userList.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 48;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return NO;
}

@end
