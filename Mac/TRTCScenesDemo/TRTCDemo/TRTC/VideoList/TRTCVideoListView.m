//
//  TRTCVideoListView.m
//  TXLiteAVMacDemo
//
//  Created by Xiaoya Liu on 2020/2/25.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TRTCVideoListView.h"
#import "TRTCVideoCell.h"

@interface TRTCVideoListView()<NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *viewTableView;
@property (nonatomic, strong) NSArray<TRTCUserConfig *> *userList;
@property (nonatomic, strong, nullable) TRTCUserManager *userManager;
@property (nonatomic) CGFloat tableHeight;

@end

@implementation TRTCVideoListView

- (void)dealloc {
    [self.userManager removeObserver:self forKeyPath:@"userConfigs"];
}

- (void)observeUserManager:(TRTCUserManager *)userManager {
    self.userManager = userManager;
    [userManager addObserver:self forKeyPath:@"userConfigs" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"userConfigs"]) {
        self.userList = ((TRTCUserManager *)object).userConfigs;
        if (![self.userList containsObject:self.mainUser]) {
            self.mainUser = self.userList.count > 1 ? self.userList[1] : self.userList.firstObject;
            if ([self.delegate respondsToSelector:@selector(videoListView:onSelectUser:)]) {
                [self.delegate videoListView:self onSelectUser:self.mainUser];
            }
        }
        [self.viewTableView reloadData];
        self.tableHeight = self.viewTableView.intrinsicContentSize.height + 2;
    }
}

- (TRTCUserConfig *)mainUser {
    if (_mainUser == nil) {
        _mainUser = self.userList.count > 1 ? self.userList[1] : self.userList.firstObject;
    }
    return _mainUser;
}

- (void)reloadData {
    [self.viewTableView reloadData];
}

#pragma mark - UITableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    TRTCVideoCell *cell = [tableView makeViewWithIdentifier:@"TRTCVideoCell" owner:self];
    TRTCUserConfig *user = self.userList[row];
    
    if (user == self.mainUser || self.isHidden) {
        [cell configWithUserId:self.mainUser.userId renderView:nil];
    } else {
        [cell configWithUserId:user.userId renderView:user.renderView];
    }
    
    return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.userList.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 200 * 360 / 640;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    self.mainUser = self.userList[row];
    if ([self.delegate respondsToSelector:@selector(videoListView:onSelectUser:)]) {
        [self.delegate videoListView:self onSelectUser:self.mainUser];
    }
    return NO;
}

@end
