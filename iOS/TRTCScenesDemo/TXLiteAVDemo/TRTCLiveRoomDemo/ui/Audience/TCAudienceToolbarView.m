/**
 * Module: TCAudienceToolbarView
 *
 * Function: 工具栏
 */

#import "TCAudienceToolbarView.h"
#import "TCMsgBarrageView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+Additions.h"
#import "UIView+Additions.h"
#import "HUDHelper.h"
#import "ColorMacro.h"
#import "TCUtil.h"
#import "UIColor+MLPFlatColors.h"
#import <Masonry/Masonry.h>
#import "TXLiteAVDemo-Swift.h"

/// 浮在视频画面上面的控件
@implementation TCAudienceToolbarView
{
    TCShowLiveTopView  *_topView;
    TCAudienceListTableView *_audienceTableView;
    TCMsgListTableView *_msgTableView;
    TCMsgBarrageView *_bulletViewOne;
    TCMsgBarrageView *_bulletViewTwo;
    TRTCLiveRoomInfo         *_liveInfo;
    UIButton           *_likeBtn;
    UIButton           *_closeBtn;
    UIView             *_msgInputView;
    UITextField        *_msgInputFeild;
    CGPoint            _touchBeginLocation;
    BOOL               _bulletBtnIsOn;
    BOOL               _viewsHidden;
    NSMutableArray     *_heartAnimationPoints;
}

- (instancetype)initWithFrame:(CGRect)frame liveInfo:(TRTCLiveRoomInfo *)liveInfo withLinkMic:(BOOL)linkmic {
    if (self = [super initWithFrame:frame]) {
        _liveInfo      = liveInfo;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickScreen:)];
        [self addGestureRecognizer:tap];
        [self initUI: linkmic];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setViewerCount:(int)viewerCount likeCount:(int)likeCount {
    _liveInfo.memberCount = viewerCount;
    [_topView setViewerCount:viewerCount likeCount:likeCount];
}

- (BOOL)isAlreadyInAudienceList:(TCMsgModel *)model {
    return [_audienceTableView isAlreadyInAudienceList:model];
}

- (void)initAudienceList:(NSArray *)audienceList {
    CGFloat audience_width = self.width - 25 - _topView.right;
    _audienceTableView = [[TCAudienceListTableView alloc] initWithFrame:CGRectMake(_topView.right + 10 +audience_width / 2 - IMAGE_SIZE / 2 ,_topView.center.y -  audience_width / 2, _topView.height, audience_width) style:UITableViewStyleGrouped liveInfo:_liveInfo];
    _audienceTableView.transform = CGAffineTransformMakeRotation(- M_PI/2);
    _audienceTableView.audienceListDelegate = self;
    [self addSubview:_audienceTableView];
    
    //初始观众头像    
    for (TRTCLiveUserInfo* user in audienceList) {
        TCMsgModel *msgModel = [TCMsgModel new];
        msgModel.msgType = TCMsgModelType_MemberEnterRoom;
        msgModel.userId = user.userId;
        msgModel.userName = user.userName;
        msgModel.userHeadImageUrl = user.avatarURL;
        [_audienceTableView refreshAudienceList:msgModel];
        [_topView onUserEnterLiveRoom];
    }
}

- (void)initUI:(BOOL)linkmic {
    //close VC
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeBtn];
    
    //topview,展示主播头像，在线人数及点赞
    int statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    _topView = [[TCShowLiveTopView alloc] initWithFrame:CGRectMake(5, statusBarHeight + 5, 110, 35) isHost:NO hostNickName:_liveInfo.ownerName
                                          audienceCount:0 likeCount:0 hostFaceUrl:_liveInfo.coverUrl];
    
    [self addSubview:_topView];
    __weak __typeof(self) weakSelf = self;
    [_topView setClickHead:^{
        __strong __typeof(weakSelf) self = weakSelf;
        if (self == nil) {
            return;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickLog)]) {
            [self.delegate clickLog];
        }
    }];
    
    int   icon_size = BOTTOM_BTN_ICON_WIDTH;
    float startSpace = 15;
    float icon_center_y = self.height - icon_size/2 - startSpace;
    
    float icon_count = (linkmic == YES ? 7 : 6);
    float icon_center_interval = (self.width - 2*startSpace - icon_size)/(icon_count - 1);
    float first_icon_center_x = startSpace + icon_size/2;
    
    _btnChat = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnChat.center = CGPointMake(first_icon_center_x + icon_size / 2.0, icon_center_y);
    _btnChat.bounds = CGRectMake(0, 0, icon_size, icon_size);
    [_btnChat setBackgroundImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    [_btnChat addTarget:self action:@selector(clickChat:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnChat];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self->_btnChat.mas_centerY);
        make.right.equalTo(self).offset(-icon_center_interval*0.7);
        make.width.height.equalTo(@(icon_size));
    }];
    
    
    //点赞
    _likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _likeBtn.frame = CGRectMake(0, 0, icon_size, icon_size);
    [_likeBtn setImage:[UIImage imageNamed:@"like_hover"] forState:UIControlStateNormal];
    [_likeBtn addTarget:self action:@selector(clickLike:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_likeBtn];
    [_likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self->_closeBtn.mas_centerY);
        make.centerX.equalTo(self->_closeBtn).offset(-icon_center_interval*1.2);
        make.width.height.equalTo(@(icon_size));
    }];
    
    //弹幕
    _msgTableView = [[TCMsgListTableView alloc] initWithFrame:CGRectMake(15, _btnChat.top - MSG_TABLEVIEW_HEIGHT - MSG_TABLEVIEW_BOTTOM_SPACE, MSG_TABLEVIEW_WIDTH, MSG_TABLEVIEW_HEIGHT) style:UITableViewStyleGrouped];
    [self addSubview:_msgTableView];
    
    _bulletViewOne = [[TCMsgBarrageView alloc]initWithFrame:CGRectMake(0,_msgTableView.top - MSG_UI_SPACE - MSG_BULLETVIEW_HEIGHT, SCREEN_WIDTH, MSG_BULLETVIEW_HEIGHT)];
    [self addSubview:_bulletViewOne];
    
    _bulletViewTwo = [[TCMsgBarrageView alloc]initWithFrame:CGRectMake(0, _bulletViewOne.top - MSG_BULLETVIEW_HEIGHT, SCREEN_WIDTH, MSG_BULLETVIEW_HEIGHT)];
    [self addSubview:_bulletViewTwo];
    
    
    //输入框
    _msgInputView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height, self.width, MSG_TEXT_SEND_VIEW_HEIGHT )];
    _msgInputView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _msgInputView.width, _msgInputView.height)];
    imageView.image = [UIImage imageNamed:@"input_comment"];
    
    UIButton *bulletBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bulletBtn.frame = CGRectMake(10, (_msgInputView.height - MSG_TEXT_SEND_FEILD_HEIGHT)/2, MSG_TEXT_SEND_BULLET_BTN_WIDTH, MSG_TEXT_SEND_FEILD_HEIGHT);
    [bulletBtn setImage:[UIImage imageNamed:@"Switch_OFF"] forState:UIControlStateNormal];
    [bulletBtn setImage:[UIImage imageNamed:@"Switch_ON"] forState:UIControlStateSelected];
    [bulletBtn addTarget:self action:@selector(clickBullet:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(self.width - 15 - MSG_TEXT_SEND_BTN_WIDTH, (_msgInputView.height - MSG_TEXT_SEND_FEILD_HEIGHT)/2, MSG_TEXT_SEND_BTN_WIDTH, MSG_TEXT_SEND_FEILD_HEIGHT);
    [sendBtn setTitle:TRTCLocalize(@"Demo.TRTC.LiveRoom.send") forState:UIControlStateNormal];
    [sendBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [sendBtn setTitleColor:UIColorFromRGB(0x0ACCAC) forState:UIControlStateNormal];
    [sendBtn setBackgroundColor:[UIColor clearColor]];
    [sendBtn addTarget:self action:@selector(clickSend) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *msgInputFeildLine1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vertical_line"]];
    msgInputFeildLine1.frame = CGRectMake(bulletBtn.right + 10, sendBtn.y, 1, MSG_TEXT_SEND_FEILD_HEIGHT);
    
    UIImageView *msgInputFeildLine2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vertical_line"]];
    msgInputFeildLine2.frame = CGRectMake(sendBtn.left - 10, sendBtn.y, 1, MSG_TEXT_SEND_FEILD_HEIGHT);
    
    _msgInputFeild = [[UITextField alloc] initWithFrame:CGRectMake(msgInputFeildLine1.right + 10,sendBtn.y,msgInputFeildLine2.left - msgInputFeildLine1.right - 20,MSG_TEXT_SEND_FEILD_HEIGHT)];
    _msgInputFeild.backgroundColor = [UIColor clearColor];
    _msgInputFeild.returnKeyType = UIReturnKeySend;
    _msgInputFeild.placeholder = TRTCLocalize(@"Demo.TRTC.LiveRoom.saysomething");
    _msgInputFeild.delegate = self;
    _msgInputFeild.textColor = [UIColor blackColor];
    _msgInputFeild.font = [UIFont systemFontOfSize:14];
    
    
    [_msgInputView addSubview:imageView];
    [_msgInputView addSubview:_msgInputFeild];
    [_msgInputView addSubview:bulletBtn];
    [_msgInputView addSubview:sendBtn];
    [_msgInputView addSubview:msgInputFeildLine1];
    [_msgInputView addSubview:msgInputFeildLine2];
    _msgInputView.hidden = YES;
    [self addSubview:_msgInputView];
    
    
    //LOG UI
    _cover = [[UIView alloc]init];
    _cover.frame  = CGRectMake(10.0f, 55 + 2*icon_size, self.width - 20, self.height - 110 - 3 * icon_size);
    _cover.backgroundColor = [UIColor whiteColor];
    _cover.alpha  = 0.5;
    _cover.hidden = YES;
    [self addSubview:_cover];
    
    int logheadH = 65;
    _statusView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 55 + 2*icon_size, self.width - 20,  logheadH)];
    _statusView.backgroundColor = [UIColor clearColor];
    _statusView.alpha = 1;
    _statusView.textColor = [UIColor blackColor];
    _statusView.editable = NO;
    _statusView.hidden = YES;
    [self addSubview:_statusView];
    
    
    _logViewEvt = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 55 + 2*icon_size + logheadH, self.width - 20, self.height - 110 - 3 * icon_size - logheadH)];
    _logViewEvt.backgroundColor = [UIColor clearColor];
    _logViewEvt.alpha = 1;
    _logViewEvt.textColor = [UIColor blackColor];
    _logViewEvt.editable = NO;
    _logViewEvt.hidden = YES;
    [self addSubview:_logViewEvt];
}

- (void)bulletMsg:(TCMsgModel *)msgModel {
    [_msgTableView bulletNewMsg:msgModel];
    if (msgModel.msgType == TCMsgModelType_DanmaMsg) {
        if ([self getLocation:_bulletViewOne] >= [self getLocation:_bulletViewTwo]) {
            [_bulletViewTwo bulletNewMsg:msgModel];
        }else{
            [_bulletViewOne bulletNewMsg:msgModel];
        }
    }
    
    if (msgModel.msgType == TCMsgModelType_MemberEnterRoom || msgModel.msgType == TCMsgModelType_MemberQuitRoom) {
        [_audienceTableView refreshAudienceList:msgModel];
    }
}

- (CGFloat)getLocation:(TCMsgBarrageView *)bulletView {
    UIView *view = bulletView.lastAnimateView;
    CGRect rect = [view.layer.presentationLayer frame];
    return rect.origin.x + rect.size.width;
}


- (void)clickBullet:(UIButton *)btn {
    _bulletBtnIsOn = !_bulletBtnIsOn;
    btn.selected = _bulletBtnIsOn;
}

- (void)clickChat:(UIButton *)button {
    [_msgInputFeild becomeFirstResponder];
}

- (void)clickSend {
     [self textFieldShouldReturn:_msgInputFeild];
}

- (void)clickLike:(UIButton *)button {
    [_liveRoom sendRoomCustomMsgWithCommand:[@(TCMsgModelType_Praise) stringValue] message:@"" callback:^(int code, NSString * error) {
        
    }];
    [_topView onUserSendLikeMessage];
    [self showLikeHeartStartRect:button.frame];
}

- (void)showLikeHeart {
    [self showLikeHeartStartRect:_likeBtn.frame];
}

- (void)showLikeHeartStartRect:(CGRect)frame {
    {
        // 星星动画频率限制
        static TCFrequeControl *freqControl = nil;
        if (freqControl == nil) {
            freqControl = [[TCFrequeControl alloc] initWithCounts:10 andSeconds:1];
        }
        
        if (![freqControl canTrigger]) {
            return;
        }
    }
    
    if (_viewsHidden) {
        return;
    }
    UIImageView *imageView = [[UIImageView alloc ] initWithFrame:frame];
    imageView.image = [[UIImage imageNamed:@"img_like"] imageWithTintColor:[UIColor randomFlatDarkColor]];
    [self addSubview:imageView];
    imageView.alpha = 0;
    
    
    [imageView.layer addAnimation:[self hearAnimationFrom:frame] forKey:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imageView removeFromSuperview];
    });
}

- (CAAnimation *)hearAnimationFrom:(CGRect)frame {
    //位置
    CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.beginTime = 0.5;
    animation.duration = 2.5;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount= 0;
    animation.calculationMode = kCAAnimationCubicPaced;
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPoint point0 = CGPointMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2);
    
    CGPathMoveToPoint(curvedPath, NULL, point0.x, point0.y);
    
    if (!_heartAnimationPoints) {
        _heartAnimationPoints = [[NSMutableArray alloc] init];
    }
    if ([_heartAnimationPoints count] < 40) {
        float x11 = point0.x - arc4random() % 30 + 30;
        float y11 = frame.origin.y - arc4random() % 60 ;
        float x1 = point0.x - arc4random() % 15 + 15;
        float y1 = frame.origin.y - arc4random() % 60 - 30;
        CGPoint point1 = CGPointMake(x11, y11);
        CGPoint point2 = CGPointMake(x1, y1);
        
        int conffset2 = self.superview.bounds.size.width * 0.2;
        int conffset21 = self.superview.bounds.size.width * 0.1;
        float x2 = point0.x - arc4random() % conffset2 + conffset2;
        float y2 = arc4random() % 30 + 240;
        float x21 = point0.x - arc4random() % conffset21  + conffset21;
        float y21 = (y2 + y1) / 2 + arc4random() % 30 - 30;
        CGPoint point3 = CGPointMake(x21, y21);
        CGPoint point4 = CGPointMake(x2, y2);
        
        [_heartAnimationPoints addObject:[NSValue valueWithCGPoint:point1]];
        [_heartAnimationPoints addObject:[NSValue valueWithCGPoint:point2]];
        [_heartAnimationPoints addObject:[NSValue valueWithCGPoint:point3]];
        [_heartAnimationPoints addObject:[NSValue valueWithCGPoint:point4]];
    }
    
    // 从_heartAnimationPoints中随机选取一组point
    int idx = arc4random() % ([_heartAnimationPoints count]/4);
    CGPoint p1 = [[_heartAnimationPoints objectAtIndex:4*idx] CGPointValue];
    CGPoint p2 = [[_heartAnimationPoints objectAtIndex:4*idx+1] CGPointValue];
    CGPoint p3 = [[_heartAnimationPoints objectAtIndex:4*idx+2] CGPointValue];
    CGPoint p4 = [[_heartAnimationPoints objectAtIndex:4*idx+3] CGPointValue];
    CGPathAddQuadCurveToPoint(curvedPath, NULL, p1.x, p1.y, p2.x, p2.y);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, p3.x, p3.y, p4.x, p4.y);
    
    
    animation.path = curvedPath;
    
    CGPathRelease(curvedPath);
    
    //透明度变化
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnim.toValue = [NSNumber numberWithFloat:0];
    opacityAnim.removedOnCompletion = NO;
    opacityAnim.beginTime = 0;
    opacityAnim.duration = 3;
    
    //比例
    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    //        int scale = arc4random() % 5 + 5;
    scaleAnim.fromValue = [NSNumber numberWithFloat:.0];//[NSNumber numberWithFloat:((float)scale / 10)];
    scaleAnim.toValue = [NSNumber numberWithFloat:1];
    scaleAnim.removedOnCompletion = NO;
    scaleAnim.fillMode = kCAFillModeForwards;
    scaleAnim.duration = .5;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects: scaleAnim,opacityAnim,animation, nil];
    animGroup.duration = 3;
    
    return animGroup;
}

//监听键盘高度变化
- (void)keyboardFrameDidChange:(NSNotification *)notice {
    NSDictionary * userInfo = notice.userInfo;
    NSValue * endFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect endFrame = endFrameValue.CGRectValue;
    BOOL shouldHidden = CGRectGetMinY(endFrame) >= [UIScreen mainScreen].bounds.size.height;
    if (!shouldHidden) {
        _msgInputView.hidden = NO;
    }
    endFrame = [_msgInputView.superview convertRect:endFrame fromView:nil];
    [UIView animateWithDuration:0.25 animations:^{
        if (endFrame.origin.y >= self.height) {
            self->_msgInputView.y = endFrame.origin.y;
        }else{
            self->_msgInputView.y =  endFrame.origin.y - self->_msgInputView.height;
        }
    } completion:^(BOOL finished) {
        if (shouldHidden) {
            self->_msgInputView.hidden = YES;
        }
    }];
}

// 监听登出消息
- (void)onLogout:(NSNotification *)notice {
    [self closeVC];
}

#pragma mark TCPlayDecorateDelegate

- (void)closeVC {
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeVC:)]) {
        [_bulletViewOne stopAnimation];
        [_bulletViewTwo stopAnimation];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.delegate closeVC: YES];
    }
}

- (void)clickScreen:(UITapGestureRecognizer *)gestureRecognizer {
    [_msgInputFeild resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickScreen:)]) {
        CGPoint position = [gestureRecognizer locationInView:self];
        [self.delegate clickScreen:position];
    }
}

- (void)clickPlayVod {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPlayVod)]) {
        [self.delegate clickPlayVod];
    }
}

- (void)onSeek:(UISlider *)slider {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSeek:)]) {
        [self.delegate onSeek:slider];
    }
}

- (void)onSeekBegin:(UISlider *)slider {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSeekBegin:)]) {
        [self.delegate onSeekBegin:slider];
    }
}

- (void)onDrag:(UISlider *)slider {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onDrag:)]) {
        [self.delegate onDrag:slider];
    }
}

- (void)handleIMMessage:(IMUserAble *)info msgText:(NSString *)msgText {
    switch (info.cmdType) {
        case TCMsgModelType_NormalMsg: {
            TCMsgModel *msgModel = [[TCMsgModel alloc] init];
            msgModel.userName = [info imUserName];
            msgModel.userMsg  =  msgText;
            msgModel.userHeadImageUrl = info.imUserIconUrl;
            msgModel.msgType = TCMsgModelType_NormalMsg;
            [self bulletMsg:msgModel];
            break;
        }
            
        case TCMsgModelType_MemberEnterRoom: {
            TCMsgModel *msgModel = [[TCMsgModel alloc] init];
            msgModel.userId = info.imUserId;
            msgModel.userName = info.imUserName;
            msgModel.userMsg  =  TRTCLocalize(@"Demo.TRTC.LiveRoom.joininteraction");
            msgModel.userHeadImageUrl = info.imUserIconUrl;
            msgModel.msgType = TCMsgModelType_MemberEnterRoom;
            
            //收到新增观众消息，判断只有没在观众列表中，数量才需要增加1
            if (![self isAlreadyInAudienceList:msgModel])
            {
                [_topView onUserEnterLiveRoom];
            }
            [self bulletMsg:msgModel];
            
            break;
        }
            
        case TCMsgModelType_MemberQuitRoom: {
            TCMsgModel *msgModel = [[TCMsgModel alloc] init];
            msgModel.userId = info.imUserId;
            msgModel.userName = info.imUserName;
            msgModel.userMsg  =  TRTCLocalize(@"Demo.TRTC.LiveRoom.exitinteraction");
            msgModel.userHeadImageUrl = info.imUserIconUrl;
            msgModel.msgType = TCMsgModelType_MemberQuitRoom;
            
            [self bulletMsg:msgModel];
            [_topView onUserExitLiveRoom];
            
            break;
        }
            
        case TCMsgModelType_Praise: {
            TCMsgModel *msgModel = [[TCMsgModel alloc] init];
            msgModel.userName = [info imUserName];
            msgModel.userMsg  =  TRTCLocalize(@"Demo.TRTC.LiveRoom.clicklike");
            msgModel.userHeadImageUrl = info.imUserIconUrl;
            msgModel.msgType = TCMsgModelType_Praise;
            
            [self bulletMsg:msgModel];
            [self showLikeHeart];
            [_topView onUserSendLikeMessage];
            break;
        }
            
        case TCMsgModelType_DanmaMsg: {
            TCMsgModel *msgModel = [[TCMsgModel alloc] init];
            msgModel.userName = [info imUserName];
            msgModel.userMsg  =  msgText;
            msgModel.userHeadImageUrl = info.imUserIconUrl;
            msgModel.msgType = TCMsgModelType_DanmaMsg;
            
            [self bulletMsg:msgModel];
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _msgInputFeild.text = @"";
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _msgInputFeild.text = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *textMsg = [textField.text stringByTrimmingCharactersInSet:[NSMutableCharacterSet whitespaceCharacterSet]];
    if (textMsg.length <= 0) {
        textField.text = @"";
        [HUDHelper alert:TRTCLocalize(@"Demo.TRTC.LiveRoom.messagecantbeempty")];
        return YES;
    }
    
    TCMsgModel *msgModel = [[TCMsgModel alloc] init];
    msgModel.userName = TRTCLocalize(@"Demo.TRTC.LiveRoom.me");
    msgModel.userMsg  =  textMsg;
    msgModel.userHeadImageUrl = [[ProfileManager shared] curUserModel].avatar;
    
    if (_bulletBtnIsOn) {
        msgModel.msgType  = TCMsgModelType_DanmaMsg;
        [_liveRoom sendRoomCustomMsgWithCommand:[@(TCMsgModelType_DanmaMsg) stringValue] message:textMsg callback:^(int code, NSString * error) {
            
        }];
    }else{
        msgModel.msgType = TCMsgModelType_NormalMsg;
        [_liveRoom sendRoomTextMsg:textMsg callback:^(int code, NSString * error) {
            
        }];
    }
    
    [self bulletMsg:msgModel];
    [_msgInputFeild resignFirstResponder];
    return YES;
}


#pragma mark - 滑动隐藏界面UI
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    _touchBeginLocation = [touch locationInView:self];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self];
    [self endMove:location.x - _touchBeginLocation.x];
}


- (void)endMove:(CGFloat)moveX {
    [UIView animateWithDuration:0.2 animations:^{
        if(moveX > 10) {
            for (UIView *view in self.subviews) {
                if (![view isEqual:self->_closeBtn]) {
                    CGRect rect = view.frame;
                    if (rect.origin.x >= 0 && rect.origin.x < SCREEN_WIDTH) {
                        rect = CGRectOffset(rect, self.width, 0);
                        view.frame = rect;
                        [self resetViewAlpha:view];
                    }
                }
            }
        } else if(moveX < -10) {
            for (UIView *view in self.subviews) {
                if (![view isEqual:self->_closeBtn]) {
                    CGRect rect = view.frame;
                    if (rect.origin.x >= SCREEN_WIDTH) {
                        rect = CGRectOffset(rect, -self.width, 0);
                        view.frame = rect;
                        [self resetViewAlpha:view];
                    }
                    
                }
            }
        }
    }];
}

- (void)resetViewAlpha:(UIView *)view {
    CGRect rect = view.frame;
    if (rect.origin.x  >= SCREEN_WIDTH || rect.origin.x < 0) {
        view.alpha = 0;
        _viewsHidden = YES;
    } else {
        view.alpha = 1;
        _viewsHidden = NO;
    }
    if (view == _cover) {
        _cover.alpha = 0.5;
    }
}

#pragma mark AudienceListDelegate

- (void)onFetchGroupMemberList:(int)errCode memberCount:(int)memberCount {
    if (_topView && 0 == errCode) {
        [_topView setViewerCount:memberCount likeCount:(int)[_topView getLikeCount]];
    }
}

@end
