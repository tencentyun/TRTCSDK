#include "Live/ITXLivePlayer.h"
#include "Live/TXLiveEventDef.h"
class LivePlayerCore
{
public:

    static LivePlayerCore* GetInstance();
    void Destory();
    LivePlayerCore();
    ~LivePlayerCore();
public:
    ITXLivePlayer * getLivePlayer();
public:
private:

private:
    static LivePlayerCore* m_instance;
    ITXLivePlayer* m_pLivePlayer = nullptr;
};