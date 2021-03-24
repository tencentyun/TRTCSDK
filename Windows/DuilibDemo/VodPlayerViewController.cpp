#include "VodPlayerViewController.h"
#include "StdAfx.h"
#include "TRTCCloudCore.h"
#include "FileDialog.h"
#include "util/Base.h"
#include "TrtcUtil.h"
#include "MsgBoxWnd.h"
int VodPlayerViewController::m_ref = 0;
VodPlayerViewController::VodPlayerViewController() {
    VodPlayerViewController::addRef();
    m_fSpeedRate = 1.0f;
    m_emVodStatus = Vod_Stop;
    m_strFileName = L"http://1252463788.vod2.myqcloud.com/95576ef5vodtransgzp1252463788/e1ab85305285890781763144364/v.f30.mp4";
    m_emVodRenderMode = VOD_RENDER_WND;
}

VodPlayerViewController::~VodPlayerViewController() {
    VodPlayerViewController::subRef();
}

void VodPlayerViewController::OnFinalMessage(HWND hWnd) {
    if (m_pVodPlayer) {
        destroyTXVodPlayer(&m_pVodPlayer);
        m_pVodPlayer = nullptr;
    }
    delete this;
}

LRESULT VodPlayerViewController::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
        case WM_CREATE: {
            m_pmUI.Init(m_hWnd);
            CDialogBuilder builder;
            CControlUI* pRoot = builder.Create(_T("trtc_vodplayer.xml"), (UINT)0, this, &m_pmUI);
            ASSERT(pRoot && "Failed to parse XML");
            m_pmUI.AttachDialog(pRoot);
            m_pmUI.AddNotifier(this);
            SetIcon(IDR_MAINFRAME);
            InitVodPlayerView();
            return 0;
        }
        case WM_CLOSE: {
            UnitVodPlayerView();
        } break;
        case WM_MOUSEHOVER: {
           
        } break;
        case WM_NCACTIVATE: {
            if (!::IsIconic(*this)) return (wParam == 0) ? TRUE : FALSE;
        }
       break;
        case WM_USER_CMD_OnVodPlayerStarted: {
            uint64_t msLength = wParam;
            DoVodPlayerStarted(msLength);
        } break;
        case WM_USER_CMD_OnVodPlayerPaused: {
            DoVodPlayerPaused();
        } break;
        case WM_USER_CMD_OnVodPlayerResumed: {
            DoVodPlayerResumed();
        } break;
        case WM_USER_CMD_OnVodPlayerStoped: {
            int reason = wParam;
            DoVodPlayerStoped(reason);
        } break;
        case WM_USER_CMD_OnVodPlayerProgress: {
            uint64_t msPos = wParam;
            DoVodPlayerProgress(msPos);
        } break;
        case WM_USER_CMD_OnVodPlayerRenderMode: {
            VodRenderMode vodRenderMode = (VodRenderMode)wParam;
            DoVodRenderMode(vodRenderMode);
        } break;
        case WM_USER_CMD_OnVodPlayerError: {
            DoVodPlayerError(wParam);
        } break;
        case WM_USER_CMD_OnVodPlayerPublishVideo: {
            DoVodEnablePublishVideo(wParam);
        } break;
        case WM_USER_CMD_OnVodPlayerPublishAudio: {
            DoVodEnablePublishAudio(wParam);
        } break;
        default:
            break;
    }

    LRESULT lRes = 0;
    if (m_pmUI.MessageHandler(uMsg, wParam, lParam, lRes)) return lRes;
    return CWindowWnd::HandleMessage(uMsg, wParam, lParam);
}

void VodPlayerViewController::Notify(TNotifyUI& msg) {
    if (msg.sType == _T("click")) {
        if (msg.pSender == m_pPLAY) {
            OnClickPlay();
        } else if (msg.pSender == m_pOPENFILE) {
            OnClickOpenFile();
        } else if (msg.pSender == m_pSPEEDUP) {
            OnClickSpeedUp();
        } else if (msg.pSender == m_pSPEEDDOWN) {
            OnClickSpeedDown();
        } else if (msg.pSender == m_pPAUSE) {
            OnClickPause();
        } else if (msg.pSender == m_pSTOP) {
            OnClickStop();
        } else if (msg.pSender == m_pMUTE) {
            OnClickMute();
        } else if (msg.pSender == m_pUNMUTE) {
            OnClickUnmute();
        }
    } else if (msg.sType == _T("valuechanged")) {
        if (msg.pSender == m_pPLAYSEEK) {
            OnSliderSeek();
        } else if (msg.pSender == m_pVOLUME) {
            OnSliderVolume();
        }
    }
}

CControlUI* VodPlayerViewController::CreateControl(LPCTSTR pstrClass) {
    if (_tcsicmp(pstrClass, _T("VideoCanvasContainer")) == 0) {
        m_pVideoView = new TXLiveAvVideoView();
        return m_pVideoView;
    }

    return nullptr;
}

void VodPlayerViewController::InitVodPlayerView() {

    m_pOPENFILE = (CButtonUI*)m_pmUI.FindControl(_T("IDOPENFILE"));
    m_pSPEEDDOWN = (CButtonUI*)m_pmUI.FindControl(_T("IDSPEEDDOWN"));
    m_pPLAYSEEK = (CSliderUI*)m_pmUI.FindControl(_T("IDPLAYSEEK"));
    m_pSPEEDUP = (CButtonUI*)m_pmUI.FindControl(_T("IDSPEEDUP"));
    m_pPTS = (CLabelUI*)m_pmUI.FindControl(_T("IDPTS"));
    m_pSTOP = (CButtonUI*)m_pmUI.FindControl(_T("IDSTOP"));
    m_pPLAY = (CButtonUI*)m_pmUI.FindControl(_T("IDPLAY"));
    m_pPAUSE = (CButtonUI*)m_pmUI.FindControl(_T("IDPAUSE"));
    m_pVOLUME = (CSliderUI*)m_pmUI.FindControl(_T("IDVOLUME"));
    m_pMUTE = (CButtonUI*)m_pmUI.FindControl(_T("IDMUTE"));
    m_pUNMUTE = (CButtonUI*)m_pmUI.FindControl(_T("IDUNMUTE"));
    m_pSPEED = (CButtonUI*)m_pmUI.FindControl(_T("IDSPEED"));

    m_pVOLUME->SetMaxValue(100);
    m_pVOLUME->SetValue(100);

    m_pVideo = new VideoWnd();
    m_pVideo->Create(GetHWND(), _T(""), UI_WNDSTYLE_CHILD, WS_EX_STATICEDGE | WS_EX_APPWINDOW);
    m_pVideo->MoveWindow(0, 0, GetWidth(), GetHeight() - 120);
    m_pVideo->ShowWindow();

    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_OnVodPlayerRenderMode, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_OnVodPlayerPublishVideo, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_OnVodPlayerPublishAudio, GetHWND());
}

void VodPlayerViewController::UnitVodPlayerView() {
    TRTCCloudCore::GetInstance()->removeSDKMsgObserverByHwnd(GetHWND());
    if (m_pVodPlayer)
    {
        m_pVodPlayer->stop();
        m_pVodPlayer->detachTRTC();
        m_pVodPlayer->setDataCallback(nullptr);
        m_pVodPlayer->setEventCallback(nullptr);
    }
}

void VodPlayerViewController::OnClickOpenFile() {
    //文件过滤字符串。够长
    TCHAR* strfilter =
        _T("Video(*.avi;*mp4;*flv;*wmv;*mkv;*m4v;)\0*.avi;*.wmv;*.flv;*.mp4;*.mkv;*.m4v\0")
        _T("Audio(*.mp3;*wav;*aac;*wma)\0*.wav;*.mp3;*.aac;*.wma\0")
        _T("All Files(*.*)\0*.*\0\0");

    TCHAR szFileName[MAX_PATH];
    int nRet = DialogGetFileName(GetHWND(), strfilter, szFileName, MAX_PATH * sizeof(TCHAR));
    if (nRet == 1) {
        if (m_strFileName != szFileName) {
            m_strFileName = szFileName;
            if (m_pVodPlayer) {
               
                destroyTXVodPlayer(&m_pVodPlayer);
                m_pVodPlayer = nullptr;
               
            }
            InitRender();
            m_pVodPlayer = createTXVodPlayer(Wide2UTF8(m_strFileName.GetData()).c_str());
            m_pVodPlayer->setDataCallback(this);
            m_pVodPlayer->setEventCallback(this);
            m_pVodPlayer->setRate(1.0f);
            m_pVodPlayer->attachTRTC(TRTCCloudCore::GetInstance()->getTRTCCloud());
            if (CDataCenter::GetInstance()->vod_push_video_) {
                m_pVodPlayer->publishVideo();
            }
            if (CDataCenter::GetInstance()->vod_push_audio_) {
                m_pVodPlayer->publishAudio();
            }
            if (m_pVideo) {
                 m_pVodPlayer->setView(m_pVideo->GetHWND());
             }
            m_pVodPlayer->start();
        }
    }
}

void VodPlayerViewController::OnClickSpeedDown() {
    if (m_pVodPlayer == nullptr) {
        return;
    }
    if (m_fSpeedRate < 0.5) {
        return;
    }
    m_fSpeedRate = m_fSpeedRate - 0.2;
    m_pVodPlayer->setRate(m_fSpeedRate);
    std::wstring speedText = format(L"%.1f倍速", m_fSpeedRate);
    m_pSPEED->SetText(speedText.c_str());
}

void VodPlayerViewController::OnClickSpeedUp() {
    if (m_pVodPlayer == nullptr) {
        return;
    }
    if (m_fSpeedRate > 2.0) {
        return;
    }
    m_fSpeedRate = m_fSpeedRate + 0.2;
    m_pVodPlayer->setRate(m_fSpeedRate);
    std::wstring speedText = format(L"%.1f倍速", m_fSpeedRate);
    m_pSPEED->SetText(speedText.c_str());
}

void VodPlayerViewController::OnClickStop() {
    if (m_pVodPlayer == nullptr) {
        return;
    }
    m_pVodPlayer->stop();
}

void VodPlayerViewController::OnClickPlay() {
    InitRender();
    if (m_pVodPlayer == nullptr) {

        m_pVodPlayer = createTXVodPlayer(Wide2UTF8(m_strFileName.GetData()).c_str());
        m_pVodPlayer->setEventCallback(this);
        m_pVodPlayer->setDataCallback(this);
        m_pVodPlayer->setRate(1.0f);
        m_pVodPlayer->attachTRTC(TRTCCloudCore::GetInstance()->getTRTCCloud());
        if (CDataCenter::GetInstance()->vod_push_video_) {
            m_pVodPlayer->publishVideo();
        }
        if (CDataCenter::GetInstance()->vod_push_audio_) {
            m_pVodPlayer->publishAudio();
        }
    }
    if (m_emVodStatus == Vod_Stop) {
        if (m_pVideo){
            m_pVodPlayer->setView(m_pVideo->GetHWND());
        }
        
        m_pVodPlayer->start();
     
    } else if (m_emVodStatus == Vod_Pause) {
        m_pVodPlayer->resume();
        
    }
}

void VodPlayerViewController::OnClickPause() {
    if (m_pVodPlayer == nullptr) {
        return;
    } 
    if (m_emVodStatus == Vod_Play) {
        m_pVodPlayer->pause();
       
    }
    
}

void VodPlayerViewController::OnSliderSeek() {
    int nPos = m_pPLAYSEEK->GetValue();
    if (m_pVodPlayer != NULL) {
        uint64_t vod_pos = (nPos / 1000.0) * m_nVodDurationMS;
        m_pVodPlayer->seek(vod_pos);
    }
}

void VodPlayerViewController::OnSliderVolume() {
    int nVolume = m_pVOLUME->GetValue();
    if (m_pVodPlayer != NULL) {
        m_pVodPlayer->setVolume(nVolume);
    }
}

void VodPlayerViewController::OnClickMute() {
    if (m_pVodPlayer != NULL) {
        m_pVodPlayer->mute(true);
        m_pMUTE->SetVisible(false);
        m_pUNMUTE->SetVisible(true);
    }
}

void VodPlayerViewController::OnClickUnmute() {
    if (m_pVodPlayer != NULL) {
        m_pVodPlayer->mute(false);
        m_pMUTE->SetVisible(true);
        m_pUNMUTE->SetVisible(false);
    }
}

void VodPlayerViewController::onVodPlayerStarted(uint64_t msLength) {
    ::PostMessage(GetHWND(), WM_USER_CMD_OnVodPlayerStarted, (WPARAM)msLength, NULL);
}

void VodPlayerViewController::onVodPlayerProgress(uint64_t msPos) {
    ::PostMessage(GetHWND(), WM_USER_CMD_OnVodPlayerProgress, (WPARAM)msPos, NULL);
}

void VodPlayerViewController::onVodPlayerPaused() {
    ::PostMessage(GetHWND(), WM_USER_CMD_OnVodPlayerPaused, NULL, NULL);
}

void VodPlayerViewController::onVodPlayerResumed() {
    ::PostMessage(GetHWND(), WM_USER_CMD_OnVodPlayerResumed, NULL, NULL);
}

void VodPlayerViewController::onVodPlayerStoped(int reason) {
    ::PostMessage(GetHWND(), WM_USER_CMD_OnVodPlayerStoped, (WPARAM)reason, NULL);
   
}

void VodPlayerViewController::onVodPlayerError(int error) {
    ::PostMessage(GetHWND(), WM_USER_CMD_OnVodPlayerError, (WPARAM)error, NULL);
}

int VodPlayerViewController::onVodVideoFrame(LiteAVVideoFrame& frame) {
    if (CDataCenter::GetInstance()->vod_render_mode_ == VOD_RENDER_CUSTOM)
    {
        m_pVideoView->AppendVideoFrame((unsigned char*)frame.data, frame.length, frame.width,
                                       frame.height, frame.videoFormat, frame.rotation);
    }
    return 0;
}

int VodPlayerViewController::onVodAudioFrame(LiteAVAudioFrame& frame) {
    return 0;
}

void VodPlayerViewController::DoVodPlayerStarted(uint64_t msLength) {
    m_pPLAY->SetVisible(false);
    m_pPAUSE->SetVisible(true);
    m_emVodStatus = Vod_Play;
    m_nVodDurationMS = msLength;
    wstring strVODTime = TrtcUtil::convertMSToTime(0, m_nVodDurationMS);

    m_pPTS->SetText(strVODTime.c_str());
    //duilib进度条不能设置过大。上限设置为1000
    m_pPLAYSEEK->SetMaxValue(1000);
}

void VodPlayerViewController::DoVodPlayerProgress(uint64_t msPos) {
    wstring strVODTime = TrtcUtil::convertMSToTime(msPos, m_nVodDurationMS);
    m_pPTS->SetText(strVODTime.c_str());

    m_pPLAYSEEK->SetValue((msPos/static_cast<float>(m_nVodDurationMS)) * 1000);

}


void VodPlayerViewController::DoVodPlayerPaused() {
    m_pPLAY->SetVisible(true);
    m_pPAUSE->SetVisible(false);
    m_emVodStatus = Vod_Pause;
}

void VodPlayerViewController::DoVodPlayerResumed() {
    m_pPLAY->SetVisible(false);
    m_pPAUSE->SetVisible(true);
    m_emVodStatus = Vod_Play;
}

void VodPlayerViewController::DoVodPlayerStoped(int reason) {
    m_pPLAY->SetVisible(true);
    m_pPAUSE->SetVisible(false);
    m_emVodStatus = Vod_Stop;

    m_pPTS->SetText(L"00:00/00:00");
    m_pPLAYSEEK->SetValue(0);

    m_fSpeedRate = 1.0f;
    std::wstring speedText = format(L"%.1f倍速", m_fSpeedRate);
    m_pSPEED->SetText(speedText.c_str());
    m_pVideoView->RemoveRenderInfo();
}

void VodPlayerViewController::DoVodPlayerError(int error) {
     CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"), _T("Error: 播片失败！"), 0xFFF08080);
}

void VodPlayerViewController::DoVodRenderMode(VodRenderMode vodRenderMode) {
    m_emVodRenderMode = vodRenderMode;
    if (vodRenderMode == VOD_RENDER_WND)
    {
        m_pVideo->ShowWindow(true);
        m_pVideoView->RemoveRenderInfo();

    } else if (vodRenderMode == VOD_RENDER_CUSTOM)
    {
        m_pVideo->ShowWindow(false);
        m_pVideoView->RemoveRenderInfo();
        m_pVideoView->SetRenderInfo("vod", TRTCVideoStreamType::TRTCVideoStreamTypeSub);
    } else if (vodRenderMode == VOD_RENDER_TRTC) {
        m_pVideo->ShowWindow(false);
        m_pVideoView->RemoveRenderInfo();
        m_pVideoView->SetRenderInfo("", TRTCVideoStreamType::TRTCVideoStreamTypeSub);
    }
}

void VodPlayerViewController::DoVodEnablePublishVideo(bool enable) {
    if (m_pVodPlayer != NULL) {
        if (enable) {
            m_pVodPlayer->publishVideo();
        } else {
            m_pVodPlayer->unpublishVideo();
        }
    }
}

void VodPlayerViewController::DoVodEnablePublishAudio(bool enable) {
    if (m_pVodPlayer != NULL) {
        if (enable) {
            m_pVodPlayer->publishAudio();
        } else {
            m_pVodPlayer->unpublishAudio();
        }
    }
}

int VodPlayerViewController::getRef() {
    return m_ref;
}

void VodPlayerViewController::addRef() {
    m_ref++;
}

void VodPlayerViewController::subRef() {
    m_ref--;
}
int VodPlayerViewController::GetWidth() {
    RECT childrc = {0};
    GetWindowRect(GetHWND(), &childrc);
    return childrc.right - childrc.left;
}
int VodPlayerViewController::GetHeight() {
    RECT childrc = {0};
    GetWindowRect(GetHWND(), &childrc);
    return childrc.bottom - childrc.top;
}

void VodPlayerViewController::InitRender() {
    if (!m_pVideoView || !m_pVideo) {
        return;
    }

    m_pVideoView->RemoveRenderInfo();
    if (m_emVodRenderMode == VOD_RENDER_WND) {
        m_pVideo->ShowWindow(true);
    } else if (m_emVodRenderMode == VOD_RENDER_CUSTOM) {
        m_pVideo->ShowWindow(false);

        m_pVideoView->SetRenderInfo("vod", TRTCVideoStreamType::TRTCVideoStreamTypeSub);
    } else if (m_emVodRenderMode == VOD_RENDER_TRTC) {
        m_pVideo->ShowWindow(false);
        m_pVideoView->SetRenderInfo("", TRTCVideoStreamType::TRTCVideoStreamTypeSub);
    }
}
