#ifndef TXLIVEPLAYERPROXY_H
#define TXLIVEPLAYERPROXY_H

#include <string>
#ifdef _WIN32
#include <Live/ITXLivePlayer.h>
#include <Live/TXLiveTypeDef.h>
#include <Live/TXLiveEventDef.h>
#endif // _WIN32

enum TXLivePlayerProxy_RenderMode
{
    TXLIVEPLAYERPROXY_RENDER_MODE_ADAPT = 1,
    TXLIVEPLAYERPROXY_RENDER_MODE_FILLSCREEN = 2,
};

class TXLivePlayerProxy
{
public:
    TXLivePlayerProxy();
    ~TXLivePlayerProxy();

public:
    void startPlay(const std::string& url);
    void stopPlay();
    void pause();
    void resume();
    void setRenderFrame(void* handle);
    void setRenderMode(TXLivePlayerProxy_RenderMode render_mode);

private:
#ifdef _WIN32
    ITXLivePlayer* live_player_ = nullptr;
#endif
};
#endif // TXLIVEPLAYERPROXY_H
