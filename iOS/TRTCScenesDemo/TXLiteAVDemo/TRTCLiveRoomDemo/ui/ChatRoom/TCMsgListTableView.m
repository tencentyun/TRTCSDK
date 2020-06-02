/**
 * Module: TCMsgListTableView
 *
 * Function: 聊天室UI
 */

#import "TCMsgListTableView.h"
#import "UIView+Additions.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TXLiteAVDemo-Swift.h"

@implementation TCMsgListTableView
{
    NSMutableArray  *_msgArray;
    BOOL            _beginScroll;
    BOOL            _canScrollToBottom;
    BOOL            _canReload;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        [self initTableView];
        _msgArray = [NSMutableArray array];
        _beginScroll        = NO;
        _canScrollToBottom  = YES;
        _canReload = YES;
    }
    return self;
}

- (void)initTableView {
    self.delegate = self;
    self.dataSource = self;
    self.backgroundView  = nil;
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.showsVerticalScrollIndicator = NO;
    self.hidden = YES;
}

- (void)bulletNewMsg:(TCMsgModel *)msgModel {
    if (msgModel) {
        if (_msgArray.count > 1000)
        {
            [_msgArray removeObjectsInRange:NSMakeRange(0, 100)];
        }
        
        msgModel.msgAttribText = [TCMsgListCell getAttributedStringFromModel:msgModel];
        msgModel.msgHeight = [self calCellHeight:msgModel.msgAttribText];
        [_msgArray addObject:msgModel];
         self.hidden = NO;
        
        if (_canReload) {
            _canReload = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                self->_canReload = YES;
                [self reloadData];
                
                if (!self->_beginScroll)
                {
                    if ([self calculateTotalCellHeight] >= self.height) {
                        [self scrollToBottom];
                        self->_beginScroll = YES;
                    }
                }else{
                    [self scrollToBottom];
                }
            });
        }
    }
}

- (void)scrollToBottom {
    if (_canScrollToBottom) {
        NSUInteger n = MIN(_msgArray.count, [self numberOfRowsInSection:0]);
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:n - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}

- (CGFloat)calculateCellHeight:(NSIndexPath *)indexPath {
    TCMsgModel *msgModel = _msgArray[indexPath.row];
    NSAttributedString *msg = [TCMsgListCell getAttributedStringFromModel:msgModel];
    CGRect rect = [msg boundingRectWithSize:CGSizeMake(self.width - 20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat cellHeight = rect.size.height + 10;
    return cellHeight;
}

- (CGFloat)calCellHeight:(NSAttributedString *)attribText {
    CGRect rect = [attribText boundingRectWithSize:CGSizeMake(self.width - 20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat cellHeight = rect.size.height + 10;
    return cellHeight;
}

- (CGFloat)calculateTotalCellHeight {
    CGFloat totalCellHeight = 0;
    for (TCMsgModel *model in _msgArray) {
        //NSInteger index = [_msgArray indexOfObject:model];
        totalCellHeight += model.msgHeight;
    }
    return totalCellHeight;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return [self calculateCellHeight:indexPath];
    
    if (_msgArray.count > indexPath.row) {
        TCMsgModel *msgModel = _msgArray[indexPath.row];
        return msgModel.msgHeight;
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //todo
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _msgArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID =@"MsgListCell";
    TCMsgListCell *cell = (TCMsgListCell *)[self dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[TCMsgListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    }
    if (_msgArray.count > indexPath.row) {
        TCMsgModel *msgModel = _msgArray[indexPath.row];
        [cell refreshWithModel:msgModel];
    }
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
     _canScrollToBottom = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat tableViewOffset = self.contentOffset.y + self.frame.size.height;
    if (tableViewOffset + 10 >= [self calculateTotalCellHeight]) {
        _canScrollToBottom = YES;
    }
}

@end


#pragma mark 观众列表

@implementation TCAudienceListTableView
{
    TRTCLiveRoomInfo     *_liveInfo;
    NSMutableArray *_dataArray;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style liveInfo:(TRTCLiveRoomInfo *)liveInfo {
    if (self = [super initWithFrame:frame style:style]) {
        self.dataSource = self;
        self.delegate   = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.showsVerticalScrollIndicator = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _liveInfo = liveInfo;
        _dataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)isAlreadyInAudienceList:(TCMsgModel *)model {
    if (model.userId == nil) {
        return NO;
    }
    for (TRTCLiveUserInfo *data in _dataArray) {
        if ([data.userId isEqualToString:model.userId]) {
            return YES;
        }
    }
    return NO;
}

- (void)refreshAudienceList:(TCMsgModel *)model {
    if (model.userId == nil) {
        return;
    }
    
    for (TRTCLiveUserInfo *data in _dataArray) {
        if ([data.userId isEqualToString:model.userId]) {
            [_dataArray removeObject:data];
            break;
        }
    }
    if (model.msgType == TCMsgModelType_MemberEnterRoom) {
        TRTCLiveUserInfo *infoData = [[TRTCLiveUserInfo alloc] init];
        infoData.userId = model.userId;
        infoData.avatarURL = model.userHeadImageUrl;
        [_dataArray insertObject:infoData atIndex:0];
    }
    [self reloadData];
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return IMAGE_SIZE + IMAGE_SPACE;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID =@"AudienceListCell";
    TCAudienceListCell  *cell = (TCAudienceListCell *)[self dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[TCAudienceListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    }
    if (_dataArray.count > indexPath.row) {
        TRTCLiveUserInfo *msgModel = (TRTCLiveUserInfo *)_dataArray[indexPath.row];
        [cell refreshWithModel:msgModel];
    }
    return cell;
}

@end
