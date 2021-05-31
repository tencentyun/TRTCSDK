#include "tx_liveplayer_proxy.h"
#include "TXLivePlayer.h"
#include "TXLivePlayListener.h"
#include <QDebug>

@interface TXLivePlayerDelegate : NSObject <TXLivePlayListener>
- (void)onPlayEvent:(int)EvtID withParam:(NSDictionary *)param;
- (void)onNetStatus:(NSDictionary *)param;
@end

@implementation  TXLivePlayerDelegate
- (void)onPlayEvent:(int)EvtID withParam:(NSDictionary *)param
{
    qDebug() << "txliveplayer event id:" << EvtID;
}
- (void)onNetStatus:(NSDictionary *)param
{
    qDebug() << "txliveplayer onNetStatus:" << param;
}
@end

TXLivePlayer* live_player_ = nullptr;
TXLivePlayerDelegate* live_player_delegate_ = nullptr;
TXLivePlayerProxy::TXLivePlayerProxy()
{
    if (live_player_ == nullptr)
    {
        live_player_ = [[TXLivePlayer alloc] init];
        live_player_delegate_ = [[TXLivePlayerDelegate alloc] init];
        [live_player_ setDelegate:live_player_delegate_];
    }
}


TXLivePlayerProxy::~TXLivePlayerProxy()
{

}

void TXLivePlayerProxy::startPlay(const std::string& url)
{
    [live_player_
        startPlay:[NSString stringWithCString:url.c_str() encoding:[NSString defaultCStringEncoding]]
        type:PLAY_TYPE_LIVE_FLV];
}

void TXLivePlayerProxy::stopPlay()
{
    [live_player_ stopPlay];
}

void TXLivePlayerProxy::pause()
{
    [live_player_ pause];
}

void TXLivePlayerProxy::resume()
{
    [live_player_ resume];
}


void TXLivePlayerProxy::setRenderFrame(void* handle)
{
    [live_player_ setupVideoWidget:CGRectMake(0, 0, 100, 100) containView:(__bridge TXView *)handle insertIndex:0];
}

void TXLivePlayerProxy::setRenderMode(TXLivePlayerProxy_RenderMode render_mode)
{
    [live_player_ setRenderMode:(TX_Enum_Type_RenderMode)render_mode];
}


