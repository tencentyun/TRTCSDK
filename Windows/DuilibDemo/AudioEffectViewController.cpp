#include "StdAfx.h"
#include "AudioEffectViewController.h"
#include "TRTCCloudCore.h"
#include "TRTCCloudDef.h"
#include "TrtcUtil.h"
#include "util/Base.h"

#define AUDIO_VOLUME_TICKET 100
#define BGM_PROGRESS_TICHET 100
#define AUDIO_BGM_SPEED_CONVERSION_RATE     10
#define AUDIO_BGM_PITCH_CONVERSION_RATE     10

#define AUDIO_VOLUME_CONVERSION_RATE 100
int AudioEffectViewController::m_ref = 0;
AudioEffectViewController::AudioEffectViewController()
{
    AudioEffectViewController::addRef();

    m_audioEffectParam1 = new AudioMusicParam(0, NULL);
    m_audioEffectParam2 = new AudioMusicParam(0, NULL);
    m_audioEffectParam3 = new AudioMusicParam(0, NULL);
    m_bgmMusicParam = new AudioMusicParam(0, NULL);

    m_audioEffectParam1->publish = false;
    m_audioEffectParam2->publish = false;
    m_audioEffectParam3->publish = false;
    m_bgmMusicParam->publish = true;

    m_pAudioEffectMgr = TRTCCloudCore::GetInstance()->getTRTCCloud()->getAudioEffectManager();

}

AudioEffectViewController::~AudioEffectViewController()
{

    if (m_emBGMMusicStatus != BGM_Music_Stop)
    {
        m_pAudioEffectMgr->setMusicObserver(m_bgmMusicParam->id, NULL);
        m_pAudioEffectMgr->stopPlayMusic(m_bgmMusicParam->id);
    }

    if (m_audioEffectParam1)
    {
        m_pAudioEffectMgr->setMusicObserver(m_audioEffectParam1->id, NULL);
        m_pAudioEffectMgr->stopPlayMusic(m_audioEffectParam1->id);
        delete m_audioEffectParam1;
    }
        

    if (m_audioEffectParam2)
    {
        m_pAudioEffectMgr->setMusicObserver(m_audioEffectParam2->id, NULL);
        m_pAudioEffectMgr->stopPlayMusic(m_audioEffectParam2->id);
        delete m_audioEffectParam2;
    }

    if (m_audioEffectParam3)
    {
        m_pAudioEffectMgr->setMusicObserver(m_audioEffectParam3->id, NULL);
        m_pAudioEffectMgr->stopPlayMusic(m_audioEffectParam3->id);
        delete m_audioEffectParam3;
    }

    if (m_bgmMusicParam)
    {
        delete m_bgmMusicParam;
    }
    AudioEffectViewController::subRef();
}
int  AudioEffectViewController::getRef()
{
    return m_ref;
}

void AudioEffectViewController::addRef()
{
    m_ref++;
}
void AudioEffectViewController::subRef()
{
    m_ref--;
}

void AudioEffectViewController::InitAudioMusicView()
{
    //初始化背景音乐列表
    CComboUI* pMusicCombo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_test_music")));
    if (pMusicCombo) {
        CListLabelElementUI* pElement1 = new CListLabelElementUI;
        pElement1->SetText(L"测试音乐1");
        pElement1->SetName(L"https://liteav.sdk.qcloud.com/app/res/bgm/testmusic1.mp3"); 

        pMusicCombo->Add(pElement1); 

        CListLabelElementUI* pElement2 = new CListLabelElementUI;
        pElement2->SetText(L"测试音乐2");
        pElement2->SetName(L"https://liteav.sdk.qcloud.com/app/res/bgm/testmusic2.mp3");

        pMusicCombo->Add(pElement2); 

        CListLabelElementUI* pElement3 = new CListLabelElementUI;
        pElement3->SetText(L"测试音乐3");
        pElement3->SetName(L"https://liteav.sdk.qcloud.com/app/res/bgm/testmusic3.mp3");
        pMusicCombo->Add(pElement3);

        CListLabelElementUI* pElement4 = new CListLabelElementUI;
        pElement4->SetText(L"测试音乐4");
        std::wstring testFileMp3 = TrtcUtil::getAppDirectory() + L"trtcres/BGM.mp3";
        pElement4->SetName(testFileMp3.c_str());
        pMusicCombo->Add(pElement4); 

        pMusicCombo->SelectItem(0);
    }
    //以MIC采集播放的声音作为  背景，本地，远端的声音
    {
       
        {
            CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_volume")));
            if (pSlider)
            {
                pSlider->SetValue(m_nBGMPlayoutVolume);
            }
        }
       
        {
            CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_playout_volume")));
            if (pSlider)
            {
                pSlider->SetValue(m_nBGMPlayoutVolume);
            }
        }
       
        {
            CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_publish_volume")));
            if (pSlider)
            {
                pSlider->SetValue(m_nBGMPublishVolume);
            }
        }
       
    }

    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
    if (pSlider)  pSlider->SetEnabled(false);
}
void AudioEffectViewController::UnitAudioMusicView()
{
    
}
void AudioEffectViewController::OnFinalMessage(HWND hWnd)
{
    delete this;
}
LRESULT AudioEffectViewController::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    switch (uMsg)
    {
    case WM_CREATE:
    {
        m_pmUI.Init(m_hWnd);
        CDialogBuilder builder;
        CControlUI* pRoot = builder.Create(_T("trtc_audioeffect.xml"), (UINT)0, this, &m_pmUI);
        ASSERT(pRoot && "Failed to parse XML");
        m_pmUI.AttachDialog(pRoot);
        m_pmUI.AddNotifier(this);
        SetIcon(IDR_MAINFRAME);
        InitAudioMusicView();
        return 0;
    }
        
    case WM_CLOSE:
    {
        UnitAudioMusicView();
    }
    break;
    case  WM_MOUSEHOVER:
    {
        POINT pt = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
        CSliderUI* pHover = static_cast<CSliderUI*>(m_pmUI.FindControl(pt));
        if (pHover == NULL) return 0;

        if (pHover->GetName() == _T("slider_progress_bgm"))
        {
            long lMusicCurPosMs = m_pAudioEffectMgr->getMusicCurrentPosInMS(m_bgmMusicParam->id);
            wstring strTime =  TrtcUtil::convertMSToTime(lMusicCurPosMs, m_nBGMDurationMS);

            wstring strToolTip;
            strToolTip = L"time：" + strTime;
            pHover->SetToolTip(strToolTip.c_str());
        }
    }
    break;
    case WM_NCACTIVATE:
    {
        if (!::IsIconic(*this)) return (wParam == 0) ? TRUE : FALSE;
    }
    case WM_USER_CMD_OnMusicPlayComplete:
    {
        int id = wParam;
        DoMusicPlayFinish(id);
    }
    break;
    case  WM_USER_CMD_OnMusicPlayBegin:
    {
        int id = wParam;
        int errCode = lParam;
        DoMusicPlayBegin(id, errCode);
    }
    break;
    case  WM_USER_CMD_OnMusicPlayProgress:
    {
        int id = wParam;
        int nPos = lParam;
        DoMusicPlayProgress(id, nPos);
    }
    break;
    default:
        break;
    }
    
    LRESULT lRes = 0;
    if (m_pmUI.MessageHandler(uMsg, wParam, lParam, lRes))
        return lRes;
    return CWindowWnd::HandleMessage(uMsg, wParam, lParam);
}
void AudioEffectViewController::Notify(TNotifyUI& msg)
{
    NotifyAudioEffect(msg);
    NotifyBGMMusic(msg);
    NotifyBGMSpeed(msg);
    NotifyBGMPitch(msg);
}
CControlUI* AudioEffectViewController::CreateControl(LPCTSTR pstrClass)
{
    return nullptr;
}

void AudioEffectViewController::onPlayProgress(int id, long curPtsMS, long durationMS)
{
    if (id == m_bgmMusicParam->id && durationMS != 0)
    {
        int nProgressPos = (BGM_PROGRESS_TICHET) * ((float)curPtsMS / durationMS);

        ::PostMessage(GetHWND(), WM_USER_CMD_OnMusicPlayProgress, (WPARAM)id, (LPARAM)nProgressPos);
    }
}
void AudioEffectViewController::onStart(int id, int errCode)
{
    ::PostMessage(GetHWND(), WM_USER_CMD_OnMusicPlayBegin, (WPARAM)id, (LPARAM)errCode);
}
void AudioEffectViewController::onComplete(int id, int errCode)
{
    ::PostMessage(GetHWND(), WM_USER_CMD_OnMusicPlayComplete, (WPARAM)id,NULL);
}
void AudioEffectViewController::DoMusicPlayProgress(int id, int nPos)
{
    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
    if (pSlider)  pSlider->SetValue(nPos);

    long lMusicCurPosMs = m_pAudioEffectMgr->getMusicCurrentPosInMS(m_bgmMusicParam->id);
    wstring strTime = TrtcUtil::convertMSToTime(lMusicCurPosMs, m_nBGMDurationMS);

    CLabelUI* pLabel = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_time_bgm")));
    if (pLabel)
    {
        pLabel->SetText(strTime.c_str());
    }
}
void AudioEffectViewController::DoMusicPlayBegin(int id, int errCode)
{
    
}
void AudioEffectViewController::DoMusicPlayFinish(int id)
{
    if (id == m_bgmMusicParam->id)
    {
        CButtonUI* pButton = static_cast<CButtonUI*>(m_pmUI.FindControl(_T("btn_start_bgm")));
        if (pButton)  pButton->SetNormalImage(L"music/bgm_start.png");
    }
    {
        CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
        if (pSlider)  pSlider->SetValue(0);
    }
    wstring strTime = TrtcUtil::convertMSToTime(0, m_nBGMDurationMS);

    CLabelUI* pLabel = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_time_bgm")));
    if (pLabel)
    {
        pLabel->SetText(strTime.c_str());
    }
    m_pAudioEffectMgr->stopPlayMusic(m_bgmMusicParam->id);
    m_emBGMMusicStatus = BGM_Music_Stop;
    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
    if (pSlider)  pSlider->SetEnabled(false);
}
void AudioEffectViewController::NotifyAudioEffect(TNotifyUI & msg)
{
    if (m_pAudioEffectMgr == NULL)
    {
        return;
    }
    if (msg.sType == _T("click"))
    {
        if (msg.pSender->GetName() == _T("check_btn_effect1_start"))
        {
            AudioMusicParam& effect = (*m_audioEffectParam1);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/clap.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
            
                effect.id = 1;
                effect.path= const_cast<char*>(testFileAcc.c_str());
                effect.isShortFile = true;
                m_pAudioEffectMgr->startPlayMusic(effect);
                m_pAudioEffectMgr->setMusicPlayoutVolume(effect.id, 100);
            }
            else
            {
                m_pAudioEffectMgr->stopPlayMusic(effect.id);
                effect.id = 0;
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect1_loop"))
        {
            AudioMusicParam& effect = (*m_audioEffectParam1);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.loopCount = 1000;
            else
                effect.loopCount = 1;
            if (effect.id > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/clap.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = const_cast<char*>(testFileAcc.c_str());
                m_pAudioEffectMgr->startPlayMusic(effect);
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect1_publish"))
        {
            AudioMusicParam& effect = (*m_audioEffectParam1);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.publish = true;
            else
                effect.publish = false;
            if (effect.id > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/clap.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = const_cast<char*>(testFileAcc.c_str());
                m_pAudioEffectMgr->startPlayMusic(effect);
            }
        }

        if (msg.pSender->GetName() == _T("check_btn_effect2_start"))
        {
            AudioMusicParam& effect = (*m_audioEffectParam2);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/gift_sent.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = const_cast<char*>(testFileAcc.c_str());
                effect.id = 2;
                effect.isShortFile = true;
                m_pAudioEffectMgr->setMusicPlayoutVolume(effect.id, 100);
                m_pAudioEffectMgr->startPlayMusic(effect);
            }
            else
            {
                m_pAudioEffectMgr->stopPlayMusic(effect.id);
                effect.id = 0;
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect2_loop"))
        {
            AudioMusicParam& effect = (*m_audioEffectParam2);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.loopCount = 1000;
            else
                effect.loopCount = 1;
            if (effect.id > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/gift_sent.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = const_cast<char*>(testFileAcc.c_str());
                m_pAudioEffectMgr->startPlayMusic(effect);
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect2_publish"))
        {
            AudioMusicParam& effect = (*m_audioEffectParam2);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.publish = true;
            else
                effect.publish = false;
            if (effect.id > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/gift_sent.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = const_cast<char*>(testFileAcc.c_str());
                m_pAudioEffectMgr->startPlayMusic(effect);
            }
        }

        if (msg.pSender->GetName() == _T("check_btn_effect3_start"))
        {
            AudioMusicParam& effect = (*m_audioEffectParam3);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/on_mic.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = const_cast<char*>(testFileAcc.c_str());
 
                effect.id = 3;
                effect.isShortFile = true;
                m_pAudioEffectMgr->setMusicPlayoutVolume(effect.id, 100);
                m_pAudioEffectMgr->startPlayMusic(effect);
            }
            else
            {
                m_pAudioEffectMgr->stopPlayMusic(effect.id);
                effect.id = 0;
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect3_loop"))
        {
            AudioMusicParam& effect = (*m_audioEffectParam3);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.loopCount = 1000;
            else
                effect.loopCount = 1;
            if (effect.id > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/on_mic.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = const_cast<char*>(testFileAcc.c_str());
                m_pAudioEffectMgr->startPlayMusic(effect);
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect3_publish"))
        {
            AudioMusicParam& effect = (*m_audioEffectParam3);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.publish = true;
            else
                effect.publish = false;
            if (effect.id > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/on_mic.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = const_cast<char*>(testFileAcc.c_str());
                m_pAudioEffectMgr->startPlayMusic(effect);
            }
        }
    }
}
void AudioEffectViewController::NotifyBGMMusic(TNotifyUI & msg)
{
    if (m_pAudioEffectMgr == NULL)
    {
        return;
    }
    if (msg.sType == _T("click"))
    {
        if (msg.pSender->GetName() == _T("btn_start_bgm"))
        {
            COptionUI* pTestSender = static_cast<COptionUI*>(msg.pSender);
            if (m_emBGMMusicStatus == BGM_Music_Stop)
            {
                CComboUI* pMusicCombo =
                    static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_test_music")));
                if (pMusicCombo) {
                    int nIndex = pMusicCombo->GetCurSel();
                    CListLabelElementUI* pListElement =
                        static_cast<CListLabelElementUI*>(pMusicCombo->GetItemAt(nIndex));
                    if (pListElement) {
                        CDuiString wsMusic = pListElement->GetName();

                        CButtonUI* pPlayButtom =
                            static_cast<CButtonUI*>(m_pmUI.FindControl(_T("btn_start_bgm")));
                        pPlayButtom->SetNormalImage(L"music/bgm_pause.png");

                        m_nBGMDurationMS = m_pAudioEffectMgr->getMusicDurationInMS(
                            const_cast<char*>(Wide2UTF8(wsMusic.GetData()).c_str()));
                        wstring strBGMTime = TrtcUtil::convertMSToTime(0, m_nBGMDurationMS);

                        CLabelUI* pLabel =
                            static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_time_bgm")));
                        if (pLabel) {
                            pLabel->SetText(strBGMTime.c_str());
                        }
                        string musicPath = Wide2UTF8(pListElement->GetName().GetData());
                        m_bgmMusicParam->id = 4;
                        m_bgmMusicParam->path = const_cast<char*>(musicPath.c_str());
                        m_bgmMusicParam->publish = true;

                        m_pAudioEffectMgr->startPlayMusic(*m_bgmMusicParam);
                        m_pAudioEffectMgr->setMusicObserver(4, this);

                        m_emBGMMusicStatus = BGM_Music_Play;
                        CSliderUI* pSlider =
                            static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
                        if (pSlider) pSlider->SetEnabled(true);
                     }
                 }
            }
            else if(m_emBGMMusicStatus == BGM_Music_Play)
            {
                pTestSender->SetNormalImage(L"music/bgm_start.png");
                m_pAudioEffectMgr->pausePlayMusic(m_bgmMusicParam->id);
                m_emBGMMusicStatus = BGM_Music_Pause;
                CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
                if (pSlider)  pSlider->SetEnabled(false);

            }
            else if(m_emBGMMusicStatus == BGM_Music_Pause)
            {
                pTestSender->SetNormalImage(L"music/bgm_pause.png");
                m_pAudioEffectMgr->resumePlayMusic(m_bgmMusicParam->id);
                m_emBGMMusicStatus = BGM_Music_Play;
                CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
                if (pSlider)  pSlider->SetEnabled(true);
            }
        }
        if (msg.pSender->GetName() == _T("btn_stop_bgm"))
        {
            COptionUI* pTestSender = static_cast<COptionUI*>(msg.pSender);
            if (m_emBGMMusicStatus != BGM_Music_Stop)
            {
                m_pAudioEffectMgr->stopPlayMusic(m_bgmMusicParam->id);
                m_emBGMMusicStatus = BGM_Music_Stop;
                CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
                if (pSlider)  pSlider->SetEnabled(false);
                {
                    CButtonUI* pButton = static_cast<CButtonUI*>(m_pmUI.FindControl(_T("btn_start_bgm")));
                    if (pButton)  pButton->SetNormalImage(L"music/bgm_start.png");
                }
                {
                    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
                    if (pSlider)  pSlider->SetValue(0);
                }
                {
                    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_publish_volume")));
                    if (pSlider)  pSlider->SetValue(AUDIO_VOLUME_TICKET);
                }
                {
                    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_volume")));
                    if (pSlider)  pSlider->SetValue(AUDIO_VOLUME_TICKET);
                }
                {
                    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_playout_volume")));
                    if (pSlider)  pSlider->SetValue(AUDIO_VOLUME_TICKET);
                }
                {
                    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_speed")));
                    if (pSlider)  pSlider->SetValue(10);
                }
                {
                    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_pitch")));
                    if (pSlider)  pSlider->SetValue(0);
                }
                {
                    CComboUI* pReverbCombo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_voice_reverb")));
                    if (pReverbCombo)
                    {
                        pReverbCombo->SelectItem(0);
                    }
                }

                {
                    CComboUI* pChangerCombo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_voice_changer")));
                    if (pChangerCombo)
                    {
                        pChangerCombo->SelectItem(0);
                    }
                }
                wstring strTime = TrtcUtil::convertMSToTime(0, m_nBGMDurationMS);

                CLabelUI* pLabel = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_time_bgm")));
                if (pLabel)
                {
                    pLabel->SetText(strTime.c_str());
                }
                m_pAudioEffectMgr->setMusicPlayoutVolume(m_bgmMusicParam->id, 100);
            }
           
        }
    }
   
    else if (msg.sType == _T("valuechanged"))
    {
        
        if (msg.pSender->GetName() == _T("slider_bgm_volume")) {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_bgm_volume")));
            int volume = pSlider->GetValue();
           
            m_pAudioEffectMgr->setMusicPlayoutVolume(m_bgmMusicParam->id, volume);
            m_pAudioEffectMgr->setMusicPublishVolume(m_bgmMusicParam->id, volume);
           
            {
                CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_publish_volume")));
                if (pSlider)  pSlider->SetValue(volume);
            }
            {
                CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_playout_volume")));
                if (pSlider)  pSlider->SetValue(volume);
            }
           
        }
        else if (msg.pSender->GetName() == _T("slider_bgm_playout_volume"))
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_bgm_playout_volume")));
            int volume = pSlider->GetValue();

            m_pAudioEffectMgr->setMusicPlayoutVolume(m_bgmMusicParam->id, volume);
        }
        else if (msg.pSender->GetName() == _T("slider_bgm_publish_volume"))
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_bgm_publish_volume")));
            int volume = pSlider->GetValue();

            m_pAudioEffectMgr->setMusicPublishVolume(m_bgmMusicParam->id, volume);
           
        }
        else if (msg.pSender->GetName() == _T("slider_progress_bgm"))
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
            int nCurPos = pSlider->GetValue();

            int nCurMs = m_nBGMDurationMS * ((float)nCurPos / BGM_PROGRESS_TICHET);

            m_pAudioEffectMgr->seekMusicToPosInTime(m_bgmMusicParam->id, nCurMs);

        }
    } 
    else if (msg.sType == _T("itemselect"))
    {
        if (msg.pSender->GetName() == _T("combo_test_music") && m_emBGMMusicStatus == BGM_Music_Play) {

            CComboUI* pMusicSender = static_cast<CComboUI*>(msg.pSender);
            if (pMusicSender) {
                int nIndex = pMusicSender->GetCurSel();
                CListLabelElementUI* pListElement =
                    static_cast<CListLabelElementUI*>(pMusicSender->GetItemAt(nIndex));
                if (pListElement) {
                    CDuiString wsMusic = pListElement->GetName();

                    CButtonUI* pPlayButtom =
                        static_cast<CButtonUI*>(m_pmUI.FindControl(_T("btn_start_bgm")));
                    pPlayButtom->SetNormalImage(L"music/bgm_pause.png");

                    m_nBGMDurationMS = m_pAudioEffectMgr->getMusicDurationInMS(
                        const_cast<char*>(Wide2UTF8(wsMusic.GetData()).c_str()));
                    wstring strBGMTime = TrtcUtil::convertMSToTime(0, m_nBGMDurationMS);

                    CLabelUI* pLabel =
                        static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_time_bgm")));
                    if (pLabel) {
                        pLabel->SetText(strBGMTime.c_str());
                    }
                    string musicPath = Wide2UTF8(pListElement->GetName().GetData());
                    m_bgmMusicParam->id = 4;
                    m_bgmMusicParam->path = const_cast<char*>(musicPath.c_str());
                    m_bgmMusicParam->publish = true;

                    m_pAudioEffectMgr->startPlayMusic(*m_bgmMusicParam);
                    m_pAudioEffectMgr->setMusicObserver(4, this);

                    m_emBGMMusicStatus = BGM_Music_Play;
                    CSliderUI* pSlider =
                        static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
                    if (pSlider) pSlider->SetEnabled(true);
                }
            }
        }
    }
}
void AudioEffectViewController::NotifyBGMSpeed(TNotifyUI & msg)
{
    if (msg.sType == _T("valuechanged"))
    {
        if (msg.pSender->GetName() == _T("slider_bgm_speed"))
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_bgm_speed")));
            int nSpeed = pSlider->GetValue();

            float fSpeed = (float)nSpeed / AUDIO_BGM_SPEED_CONVERSION_RATE;

            m_pAudioEffectMgr->setMusicSpeedRate(m_bgmMusicParam->id, fSpeed);

        }
    }
}
void AudioEffectViewController::NotifyBGMPitch(TNotifyUI & msg)
{
    if (msg.sType == _T("valuechanged"))
    {
        if (msg.pSender->GetName() == _T("slider_bgm_pitch"))
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_bgm_pitch")));
            int nPitch = pSlider->GetValue();

            float fPitch = ((float)nPitch / AUDIO_BGM_PITCH_CONVERSION_RATE);

            m_pAudioEffectMgr->setMusicPitch(m_bgmMusicParam->id, fPitch);

        }
    }
}