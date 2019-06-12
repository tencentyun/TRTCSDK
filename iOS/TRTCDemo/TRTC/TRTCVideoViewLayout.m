/*
 * Module:   TRTCVideoViewLayout
 * 
 * Function: 用于计算每个视频画面的位置排布和大小尺寸
 *
 */

#import "TRTCVideoViewLayout.h"
#import "TRTCVideoView.h"

const static float VSPACE = 10.f;
const static float HSPACE = 20.f;
const static float MARGIN = 10.f;

@interface TRTCVideoViewLayout ()

@end

@implementation TRTCVideoViewLayout

- (void)setType:(TCLayoutType)type
{
    _type = type;
    [self relayout:self.subViews];
}

- (void)relayout:(NSArray<UIView *> *)players
{
    self.subViews = players;
    if (players == nil)
        return;
    for (UIView * player in self.subViews) {
        [self.view addSubview:player];
        [self.view bringSubviewToFront:player];
        player.userInteractionEnabled = YES;
        
        
        if (self.type == TC_Float) {
            [((TRTCVideoView*)player) hideButtons:YES];
        }
        else if (self.type == TC_Gird ) {
            TRTCVideoView* playerView = ((TRTCVideoView*)player);
            if (playerView.type != VideoViewType_Local)
                [playerView hideButtons:NO];
        }
        
    }
    if (players.count == 1) {
        players[0].frame = (CGRect){.origin = CGPointZero, .size = self.view.frame.size};
        return;
    }
    if (players.count == 0)
        return;
    [UIView beginAnimations:@"TRTCLayoutEngine" context:nil];
    [UIView setAnimationDuration:0.25];
    switch (self.type) {
        case TC_Float: {
            players[0].frame = (CGRect){.origin = CGPointZero, .size = self.view.frame.size};
            int i = 1;
            if (i < players.count) players[i].frame = [self gird:9 at:8]; i++;
            if (i < players.count) players[i].frame = [self gird:9 at:5]; i++;
            if (i < players.count) players[i].frame = [self gird:9 at:2]; i++;
            if (i < players.count) players[i].frame = [self gird:9 at:6]; i++;
            if (i < players.count) players[i].frame = [self gird:9 at:3]; i++;
            if (i < players.count) players[i].frame = [self gird:9 at:0]; i++;
            if (i < players.count) players[i].frame = [self gird:9 at:7]; i++;
            if (i < players.count) players[i].frame = [self gird:9 at:4]; i++;
            if (i < players.count) players[i].frame = [self gird:9 at:1]; i++;
        }
            break;
        case TC_Gird: {
            for (int i = 0; i < players.count; i++) {
                players[i].frame = [self gird:(int)players.count at:i];
            }
        }
            break;
        default:
            break;
    }
    [UIView commitAnimations];
}

// 将view等分为total块，处理好边距
#define FitH(rect) rect.size.height = (rect.size.width)/9.0*16
- (CGRect)gird:(int)total at:(int)at
{
    CGRect atRect = CGRectZero;
    CGFloat H = self.view.frame.size.height;
    CGFloat W = self.view.frame.size.width;
    // 等分主view，2、4、9...
    // 6宫格不能处理
    if (total <= 2) {
        atRect.size.width = (W - HSPACE - 2 * MARGIN) / 2;
        FitH(atRect);
        atRect.origin.y = (H-atRect.size.height)/2;
        if (at == 0) {
            atRect.origin.x = MARGIN;
        } else {
            atRect.origin.x = W-MARGIN-atRect.size.width;
        }
        return atRect;
    }
    if (total <= 4) {
        atRect.size.width = (W - HSPACE - 2 * MARGIN) / 2;
        FitH(atRect);
        if (at / 2 == 0) {
            atRect.origin.y = (H - VSPACE)/2-atRect.size.height;
        } else {
            atRect.origin.y = (H + VSPACE)/2;
        }
        
        if (at % 2 == 0) {
            atRect.origin.x = MARGIN;
        } else {
            atRect.origin.x = W-MARGIN-atRect.size.width;
        }
        return atRect;
    }
    if (total <= 6) {
        atRect.size.width = (W - 2 * HSPACE - 2 * MARGIN) / 3;
        FitH(atRect);
        if (at / 3 == 0) {
            atRect.origin.y = H/2 - atRect.size.height - VSPACE;
        } else {
            atRect.origin.y = H/2 + VSPACE;
        }
        
        if (at % 3 == 0) {
            atRect.origin.x = MARGIN;
        } else if (at % 3 == 1) {
            atRect.origin.x = W/2 - atRect.size.width/2;
        } else {
            atRect.origin.x = W - atRect.size.width - MARGIN;
        }
        return atRect;
    }
    if (total <= 9) {
        atRect.size.width = (W - 2 * HSPACE - 2 * MARGIN) / 3;
        FitH(atRect);
        if (at / 3 == 0) {
            atRect.origin.y = H/2 - atRect.size.height/2 - VSPACE - atRect.size.height;
        } else if (at / 3 == 1) {
            atRect.origin.y = H/2 - atRect.size.height/2;
        } else {
            atRect.origin.y = H/2 + atRect.size.height/2 + VSPACE;
        }
        
        if (at % 3 == 0) {
            atRect.origin.x = MARGIN;
        } else if (at % 3 == 1) {
            atRect.origin.x = W/2 - atRect.size.width/2;
        } else {
            atRect.origin.x = W - atRect.size.width - MARGIN;
        }
        return atRect;
    }
    return atRect;
}

@end
