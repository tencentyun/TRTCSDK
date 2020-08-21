#include "LivePlayerCore.h"
#include <mutex>
#include "util/log.h"
LivePlayerCore* LivePlayerCore::m_instance = nullptr;
static std::mutex liveplayer_mex;
LivePlayerCore * LivePlayerCore::GetInstance()
{
    if (m_instance == NULL) {
        liveplayer_mex.lock();
        if (m_instance == NULL)
        {
            m_instance = new LivePlayerCore();
        }
        liveplayer_mex.unlock();
    }
    return m_instance;
}

void LivePlayerCore::Destory()
{
    liveplayer_mex.lock();
    if (m_instance)
    {
        delete m_instance;
        m_instance = nullptr;
    }
    liveplayer_mex.unlock();
}
LivePlayerCore::LivePlayerCore()
{
    if (m_pLivePlayer == nullptr)
    {
        m_pLivePlayer = createTXLivePlayer();
    }
}
LivePlayerCore::~LivePlayerCore()
{
    destroyTXLivePlayer(&m_pLivePlayer);
    m_pLivePlayer = nullptr;
}
ITXLivePlayer * LivePlayerCore::getLivePlayer()
{
    return m_pLivePlayer;
}
