#include "tx_liveplayer_proxy.h"

TXLivePlayerProxy::TXLivePlayerProxy()
{
    live_player_ = createTXLivePlayer();
}

TXLivePlayerProxy::~TXLivePlayerProxy()
{
    if (live_player_ != nullptr)
    {
        destroyTXLivePlayer(&live_player_);
        live_player_ = nullptr;
    }
}

void TXLivePlayerProxy::startPlay(const std::string& url)
{
    live_player_->startPlay(url.c_str(), PLAY_TYPE_LIVE_FLV);
}

void TXLivePlayerProxy::stopPlay()
{
    live_player_->stopPlay();
}

void TXLivePlayerProxy::pause()
{
    live_player_->pause();
}

void TXLivePlayerProxy::resume()
{
    live_player_->resume();
}

void TXLivePlayerProxy::setRenderFrame(void* handle)
{
    live_player_->setRenderFrame(reinterpret_cast<trtc::TXView>(handle));
}

void TXLivePlayerProxy::setRenderMode(TXLivePlayerProxy_RenderMode render_mode)
{
    live_player_->setRenderMode((TXERenderMode)render_mode);
}

