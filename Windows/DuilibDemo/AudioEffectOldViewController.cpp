#include "StdAfx.h"
#include "AudioEffectOldViewController.h"
#include "TRTCCloudCore.h"
#include "TRTCCloudDef.h"
#include "TrtcUtil.h"
#include "util/Base.h"
#include "util/log.h"
#define AUDIO_VOLUME_TICKET 100
#define BGM_PROGRESS_TICHET 100
#define AUDIO_BGM_SPEED_CONVERSION_RATE     10
#define AUDIO_BGM_PITCH_CONVERSION_RATE     10

#define AUDIO_VOLUME_CONVERSION_RATE 100
int AudioEffectOldViewController::m_ref = 0;
AudioEffectOldViewController::AudioEffectOldViewController()
{
    AudioEffectOldViewController::addRef();

    TRTCCloudCore::GetInstance()->getTRTCCloud()->addCallback(this);

    m_audioEffectParam1 = new TRTCAudioEffectParam(0, NULL);
    m_audioEffectParam2 = new TRTCAudioEffectParam(0, NULL);
    m_audioEffectParam3 = new TRTCAudioEffectParam(0, NULL);

    m_audioEffectParam1->publish = false;
    m_audioEffectParam2->publish = false;
    m_audioEffectParam3->publish = false;
}

AudioEffectOldViewController::~AudioEffectOldViewController()
{
    if (m_emBGMMusicStatus != BGM_Music_Stop)
    {
        TRTCCloudCore::GetInstance()->getTRTCCloud()->stopBGM();
    }
    TRTCCloudCore::GetInstance()->getTRTCCloud()->stopAllAudioEffects();
    TRTCCloudCore::GetInstance()->getTRTCCloud()->removeCallback(this);

    if (m_audioEffectParam1)
        delete m_audioEffectParam1;

    if (m_audioEffectParam2)
        delete m_audioEffectParam2;

    if (m_audioEffectParam3)
        delete m_audioEffectParam3;

    AudioEffectOldViewController::subRef();
}
int  AudioEffectOldViewController::getRef()
{
    return m_ref;
}

void AudioEffectOldViewController::addRef()
{
    m_ref++;
}
void AudioEffectOldViewController::subRef()
{
    m_ref--;
}

void AudioEffectOldViewController::InitAudioMusicView()
{

    CGroupBoxUI* pGroupBoxUI = static_cast<CGroupBoxUI*>(m_pmUI.FindControl(_T("BGM_groupbox")));
    if (pGroupBoxUI)  pGroupBoxUI->SetFixedHeight(250);

    //BGM
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

    // 初始化Reverb
    {
        CComboUI* pReverbCombo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_voice_reverb")));
        if (pReverbCombo)
        {
            pReverbCombo->SetVisible(false);
        }
    }

    //初始化Changer
    {
        CComboUI* pChangerCombo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_voice_changer")));
        if (pChangerCombo)
        {
            pChangerCombo->SetVisible(false);
        }
    }
    {
        CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_speed")));
        if (pSlider)
        {
            pSlider->SetVisible(false);
        }
        CLabelUI *pLabel = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_bgm_speed_text")));
        if (pLabel)
        {
            pLabel->SetVisible(false);
        }
    }
    {
        CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_pitch")));
        if (pSlider)
        {
            pSlider->SetVisible(false);
        }

        CLabelUI *pLabel = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_bgm_pitch_text")));
        if (pLabel)
        {
            pLabel->SetVisible(false);
        }
    }
    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
    if (pSlider)  pSlider->SetEnabled(false);
}
void AudioEffectOldViewController::UnitAudioMusicView()
{
    
}
void AudioEffectOldViewController::OnFinalMessage(HWND hWnd)
{
    delete this;
}
LRESULT AudioEffectOldViewController::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
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
    case WM_NCACTIVATE:
    {
        if (!::IsIconic(*this)) return (wParam == 0) ? TRUE : FALSE;
    }
    case WM_USER_CMD_OnMusicPlayComplete:
    {
        TXLiteAVError errCode = (TXLiteAVError)wParam;
        DoPlayBGMComplete(errCode);
    }
    break;
    case  WM_USER_CMD_OnMusicPlayBegin:
    {
        int id = wParam;
    }
    break;
    case  WM_USER_CMD_OnMusicPlayProgress:
    {
        uint32_t uProgressMS = wParam;
        uint32_t uDurationMS = lParam;
        DoPlayBGMProgress(uProgressMS, uDurationMS);
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
void AudioEffectOldViewController::Notify(TNotifyUI& msg)
{
    NotifyAudioEffect(msg);
    NotifyBGMMusic(msg);
}
CControlUI* AudioEffectOldViewController::CreateControl(LPCTSTR pstrClass)
{
    return nullptr;
}


void AudioEffectOldViewController::NotifyAudioEffect(TNotifyUI & msg)
{
    if (msg.sType == _T("click"))
    {
        if (msg.pSender->GetName() == _T("check_btn_effect1_start"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam1);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/clap.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.volume = 100;
                effect.effectId = 1;
                effect.path = testFileAcc.c_str();
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
            else
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopAudioEffect(effect.effectId);
                effect.effectId = 0;
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect1_loop"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam1);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.loopCount = 1000;
            else
                effect.loopCount = 1;
            if (effect.effectId > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/clap.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = testFileAcc.c_str();
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect1_publish"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam1);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.publish = true;
            else
                effect.publish = false;
            if (effect.effectId > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/clap.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = testFileAcc.c_str();
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
        }

        if (msg.pSender->GetName() == _T("check_btn_effect2_start"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam2);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/gift_sent.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = testFileAcc.c_str();
                effect.volume = 100;
                effect.effectId = 2;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
            else
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopAudioEffect(effect.effectId);
                effect.effectId = 0;
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect2_loop"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam2);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.loopCount = 1000;
            else
                effect.loopCount = 1;
            if (effect.effectId > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/gift_sent.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = testFileAcc.c_str();
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect2_publish"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam2);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.publish = true;
            else
                effect.publish = false;
            if (effect.effectId > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/gift_sent.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = testFileAcc.c_str();
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
        }

        if (msg.pSender->GetName() == _T("check_btn_effect3_start"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam3);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/on_mic.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = testFileAcc.c_str();
                effect.volume = 100;
                effect.effectId = 3;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
            else
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopAudioEffect(effect.effectId);
                effect.effectId = 0;
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect3_loop"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam3);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.loopCount = 1000;
            else
                effect.loopCount = 1;
            if (effect.effectId > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/on_mic.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = testFileAcc.c_str();
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect3_publish"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam3);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.publish = true;
            else
                effect.publish = false;
            if (effect.effectId > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/on_mic.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = testFileAcc.c_str();
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
        }
    }
   
}
void AudioEffectOldViewController::NotifyBGMMusic(TNotifyUI & msg)
{

    if (msg.sType == _T("click"))
    {
        if (msg.pSender->GetName() == _T("btn_start_bgm"))
        {

            COptionUI* pTestSender = static_cast<COptionUI*>(msg.pSender);
            if (m_emBGMMusicStatus == BGM_Music_Stop)
            {
                pTestSender->SetNormalImage(L"music/bgm_pause.png");
                std::wstring testFileMp3 = TrtcUtil::getAppDirectory() + L"trtcres/BGM.mp3";
                std::string testBGMFile = Wide2UTF8(testFileMp3);

                m_nBGMDurationMS = TRTCCloudCore::GetInstance()->getTRTCCloud()->getBGMDuration(testBGMFile.c_str());

                TRTCCloudCore::GetInstance()->getTRTCCloud()->playBGM(testBGMFile.c_str());
                m_emBGMMusicStatus = BGM_Music_Play;

                CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
                if (pSlider)  pSlider->SetEnabled(true);

            }
            else if (m_emBGMMusicStatus == BGM_Music_Play)
            {
                pTestSender->SetNormalImage(L"music/bgm_start.png");
                TRTCCloudCore::GetInstance()->getTRTCCloud()->pauseBGM();
                m_emBGMMusicStatus = BGM_Music_Pause;

                CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
                if (pSlider)  pSlider->SetEnabled(false);
            }
            else if (m_emBGMMusicStatus == BGM_Music_Pause)
            {
                pTestSender->SetNormalImage(L"music/bgm_pause.png");
                TRTCCloudCore::GetInstance()->getTRTCCloud()->resumeBGM();
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
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopBGM();
                m_emBGMMusicStatus = BGM_Music_Stop;
                CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
                if (pSlider)  pSlider->SetEnabled(false);


                {
                    CButtonUI* pButton = static_cast<CButtonUI*>(m_pmUI.FindControl(_T("btn_start_bgm")));
                    if (pButton)  pButton->SetNormalImage(L"music/bgm_start.png");
                }
                m_nBGMPublishVolume = 100;
                m_nBGMPlayoutVolume = 100;
                {
                    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_publish_volume")));
                    if (pSlider)  pSlider->SetValue(m_nBGMPublishVolume);
                   
                }
                {
                    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_volume")));
                    if (pSlider)  pSlider->SetValue(m_nBGMPlayoutVolume);
                   
                }
                {
                    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
                    if (pSlider)  pSlider->SetValue(0);
                }
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setBGMPlayoutVolume(m_nBGMPlayoutVolume);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setBGMPublishVolume(m_nBGMPlayoutVolume);

                wstring strTime = TrtcUtil::convertMSToTime(0, m_nBGMDurationMS);

                CLabelUI* pLabel = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_time_bgm")));
                if (pLabel)
                {
                    pLabel->SetText(strTime.c_str());
                }
            }

        }
    }
    else if (msg.sType == _T("valuechanged"))
    {
        if (msg.pSender->GetName() == _T("slider_bgm_volume"))
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_bgm_volume")));
            CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_bgm_playout_volume")));
            CDuiString sText;
            int volume = pSlider->GetValue();
            sText.Format(_T("%d%%"), volume);
           
            if (TRTCCloudCore::GetInstance()->getTRTCCloud())
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setBGMPlayoutVolume(volume * AUDIO_VOLUME_TICKET / 100);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setBGMPublishVolume(volume * AUDIO_VOLUME_TICKET / 100);
            }
            {
                CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_publish_volume")));
                if (pSlider)  pSlider->SetValue(volume);
            }
            {
                CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_playout_volume")));
                if (pSlider)  pSlider->SetValue(volume);
            }
        }
        else if (msg.pSender->GetName() == _T("slider_bgm_publish_volume"))
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_bgm_publish_volume")));
            CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_bgm_publish_volume")));
            CDuiString sText;
            int volume = pSlider->GetValue();
            sText.Format(_T("%d%%"), volume);
           
            if (TRTCCloudCore::GetInstance()->getTRTCCloud())
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setBGMPublishVolume(volume * AUDIO_VOLUME_TICKET / 100);
        }
        else if (msg.pSender->GetName() == _T("slider_bgm_playout_volume"))
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_bgm_playout_volume")));
            int volume = pSlider->GetValue();
   

            if (TRTCCloudCore::GetInstance()->getTRTCCloud())
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setBGMPlayoutVolume(volume * AUDIO_VOLUME_TICKET / 100);
        }
        else if (msg.pSender->GetName() == _T("slider_progress_bgm"))
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
            int nCurPos = pSlider->GetValue();

            int nCurMs = m_nBGMDurationMS * ((float)nCurPos / BGM_PROGRESS_TICHET);

            TRTCCloudCore::GetInstance()->getTRTCCloud()->setBGMPosition(nCurMs);

        }
    }
}

void AudioEffectOldViewController::onPlayBGMBegin(TXLiteAVError errCode)
{
    ::PostMessage(GetHWND(), WM_USER_CMD_OnMusicPlayBegin, (TXLiteAVError)errCode, NULL);
}

void AudioEffectOldViewController::onPlayBGMProgress(uint32_t progressMS, uint32_t durationMS)
{
    ::PostMessage(GetHWND(), WM_USER_CMD_OnMusicPlayProgress, (WPARAM)progressMS, (LPARAM)durationMS);
}

void AudioEffectOldViewController::onPlayBGMComplete(TXLiteAVError errCode)
{
    ::PostMessage(GetHWND(), WM_USER_CMD_OnMusicPlayComplete, (WPARAM)errCode, NULL);
}

void AudioEffectOldViewController::DoPlayBGMBrgin(TXLiteAVError errCode)
{
    LINFO(L"DoPlayBGMBrgin  errCode: %d\n",errCode);
}

void AudioEffectOldViewController::DoPlayBGMProgress(uint32_t progressMS, uint32_t durationMS)
{
    int nProgressPos = (BGM_PROGRESS_TICHET) * ((float)progressMS / durationMS);

    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
    if (pSlider)  pSlider->SetValue(nProgressPos);

    wstring strTime = TrtcUtil::convertMSToTime(progressMS, durationMS);

    CLabelUI* pLabel = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_time_bgm")));
    if (pLabel)
    {
        pLabel->SetText(strTime.c_str());
    }
}

void AudioEffectOldViewController::DoPlayBGMComplete(TXLiteAVError errCode)
{
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
    m_emBGMMusicStatus = BGM_Music_Stop;
    TRTCCloudCore::GetInstance()->getTRTCCloud()->stopBGM();

    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_progress_bgm")));
    if (pSlider)  pSlider->SetEnabled(false);
}
