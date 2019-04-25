/**
* Module:   VideoViewDispatch @ liteav
*
* Author:   kmais @ 2018/10/1
*
* Function: 视频窗口分配管理类
*
* Modify: 创建 by kmais @ 2018/10/1
*
*/
#include "StdAfx.h"
#include "TRTCVideoViewLayout.h"
#include "TRTCCloudCore.h"
#include "TXLiveAvVideoView.h"
#include "DataCenter.h"
#include "util/Base.h"

std::wstring VideoCanvasContainer::localUserId = L"";
VideoCanvasContainer::VideoCanvasContainer(VideoCanvasContainerCB* pCb)
{
    m_pCb = pCb;
}

VideoCanvasContainer::~VideoCanvasContainer()
{
    if (m_pManager) {
        m_pManager->RemoveMessageFilter(this);
        m_pManager->RemoveNotifier(this);
        m_bRegMsgFilter = false;
    }
}

void VideoCanvasContainer::initCanvasContainer()
{

    if (m_pManager && m_bRegMsgFilter == false)
    {
        m_pManager->AddMessageFilter(this);
        m_pManager->AddNotifier(this);
        m_bRegMsgFilter = true;
    }

    strBtnRotationName.Format(L"rotation_%s_%d", m_userId.c_str(), m_streamType);
    strBtnRenderModeName.Format(L"rendermode_%s_%d", m_userId.c_str(), m_streamType);
    strBtnAudioIconName.Format(L"audioicon_%s_%d", m_userId.c_str(), m_streamType);
    strBtnVideoIconName.Format(L"videoicon_%s_%d", m_userId.c_str(), m_streamType);
    strBtnNetSignalIconName.Format(L"netsignalicon_%s_%d", m_userId.c_str(), m_streamType);
    
    std::wstring _name = GetName();
    if (_name.compare(L"lecture_view1") == 0 || _name.compare(L"gallery_view1") == 0)
        m_bMainView = true;

    CContainerUI* p = static_cast<CContainerUI*> (this);
    if (m_pLiveAvView == nullptr)
    {
        m_pLiveAvView = new TXLiveAvVideoView();
        m_pLiveAvView->SetBkColor(0xFF202020);
        p->Add(m_pLiveAvView);
        m_pLiveAvView->SetVisible(true);
    }

    if (m_pIconBg == nullptr)
    {
        m_pIconBg = new CHorizontalLayoutUI();
        m_pIconBg->SetBkColor(0xB0202020);
        m_pIconBg->SetFloat();
        m_pIconBg->SetFixedWidth(130);
        m_pIconBg->SetFixedHeight(28);
        p->Add(m_pIconBg);
        m_pIconBg->SetVisible(true);
    }


    if (m_pBtnNetSignalIcon == nullptr)
    {
        m_pBtnNetSignalIcon = new CButtonUI();
        m_pBtnNetSignalIcon->SetName(strBtnNetSignalIconName);
        m_pBtnNetSignalIcon->SetFloat();
        m_pBtnNetSignalIcon->SetFixedWidth(24);
        m_pBtnNetSignalIcon->SetFixedHeight(21);
        m_pBtnNetSignalIcon->SetNormalImage(L"videoview/net_signal_1.png");
        m_pBtnNetSignalIcon->SetToolTip(L"网络信号");
        p->Add(m_pBtnNetSignalIcon);
    }

    
    if (m_pBtnRotation == nullptr)
    {
        m_pBtnRotation = new CButtonUI();
        //m_pBtnRotation->SetStateCount(3);
        m_pBtnRotation->SetNormalImage(L"res='videoview/btn_videorotation.png' source='0,0,24,24'");
        //m_pBtnRotation->SetStateImage(L"videoview/btn_videorotation.png");
        m_pBtnRotation->SetName(strBtnRotationName);
        m_pBtnRotation->SetFloat();
        m_pBtnRotation->SetFixedWidth(24);
        m_pBtnRotation->SetFixedHeight(24);
        m_pBtnRotation->SetToolTip(L"旋转画面");
        p->Add(m_pBtnRotation);
    }

    if (m_pBtnRenderMode == nullptr)
    {
        m_pBtnRenderMode = new CButtonUI();
        m_pBtnRenderMode->SetName(strBtnRenderModeName);
        m_pBtnRenderMode->SetFloat();
        m_pBtnRenderMode->SetFixedWidth(24);
        m_pBtnRenderMode->SetFixedHeight(24);
        m_pBtnRenderMode->SetNormalImage(L"videoview/render_fill.png");
        m_pBtnRenderMode->SetToolTip(L"填充模式");
        p->Add(m_pBtnRenderMode);
    }

    if (m_pBtnAudioIcon == nullptr)
    {
        m_pBtnAudioIcon = new CButtonUI();
        m_pBtnAudioIcon->SetName(strBtnAudioIconName);
        m_pBtnAudioIcon->SetFloat();
        m_pBtnAudioIcon->SetFixedWidth(24);
        m_pBtnAudioIcon->SetFixedHeight(24);
        m_pBtnAudioIcon->SetNormalImage(L"videoview/voicevolume1.png");
        m_pBtnAudioIcon->SetToolTip(L"静音");
        p->Add(m_pBtnAudioIcon);
    }

    if (m_pBtnVideoIcon == nullptr)
    {
        m_pBtnVideoIcon = new CButtonUI();
        m_pBtnVideoIcon->SetName(strBtnVideoIconName);
        m_pBtnVideoIcon->SetFloat();
        m_pBtnVideoIcon->SetFixedWidth(20);
        m_pBtnVideoIcon->SetFixedHeight(20);
        m_pBtnVideoIcon->SetNormalImage(L"videoview/video_open.png");
        m_pBtnVideoIcon->SetToolTip(L"关闭视频");
        p->Add(m_pBtnVideoIcon);
    }
}

void VideoCanvasContainer::cleanViewStatus()
{
    m_canvasAttribute.clean();
    if(m_pBtnRenderMode)
        m_pBtnRenderMode->SetNormalImage(L"videoview/render_fill.png");
    if (m_pBtnAudioIcon)
    {
        m_pBtnAudioIcon->SetNormalImage(L"videoview/voicevolume1.png");
        m_pBtnAudioIcon->SetToolTip(L"静音");
    }
    if (m_pBtnVideoIcon)
    {
        m_pBtnVideoIcon->SetNormalImage(L"videoview/video_open.png");
        m_pBtnVideoIcon->SetToolTip(L"关闭视频");
    }
    if (m_pBtnNetSignalIcon)
    {
        m_pBtnNetSignalIcon->SetNormalImage(L"videoview/net_signal_1.png");
    }

    if (m_pLiveAvView)
    {
        m_pLiveAvView->SetPause(false);
        m_pLiveAvView->SetRenderMode(TXLiveAvVideoView::EVideoRenderModeFit);
    }
}

void VideoCanvasContainer::resetViewUIStatus(std::wstring userId, TRTCVideoStreamType type)
{
    m_userId = userId;
    m_streamType = type;
    if (m_pLiveAvView)
    {
        if (userId.compare(L"") == 0)
            m_pLiveAvView->RemoveEngine(TRTCCloudCore::GetInstance()->getTRTCCloud());
        else
        {
            if (m_userId.compare(localUserId) == 0)
                m_pLiveAvView->RegEngine(Wide2Ansi(m_userId), type, TRTCCloudCore::GetInstance()->getTRTCCloud(), true);
            else
                m_pLiveAvView->RegEngine(Wide2Ansi(m_userId), type, TRTCCloudCore::GetInstance()->getTRTCCloud());
        }
        m_pLiveAvView->NeedUpdate();
    }

    strBtnRotationName.Format(L"rotation_%s_%d", m_userId.c_str(), m_streamType);
    strBtnRenderModeName.Format(L"rendermode_%s_%d", m_userId.c_str(), m_streamType);
    strBtnAudioIconName.Format(L"audioicon_%s_%d", m_userId.c_str(), m_streamType);
    strBtnVideoIconName.Format(L"videoicon_%s_%d", m_userId.c_str(), m_streamType);
    strBtnNetSignalIconName.Format(L"netsignalicon_%s_%d", m_userId.c_str(), m_streamType);

    m_pBtnRotation->SetName(strBtnRotationName);
    m_pBtnRenderMode->SetName(strBtnRenderModeName);
    m_pBtnAudioIcon->SetName(strBtnAudioIconName);
    m_pBtnVideoIcon->SetName(strBtnVideoIconName);
    m_pBtnNetSignalIcon->SetName(strBtnNetSignalIconName);


    if (m_pBtnRotation)
    {
        if (VideoCanvasContainer::localUserId.compare(m_userId) == 0)
        {
            TRTCCloudCore::GetInstance()->getTRTCCloud()->setLocalViewRotation(m_canvasAttribute._viewRotation);
            TRTCCloudCore::GetInstance()->getTRTCCloud()->setVideoEncoderRotation(m_canvasAttribute._viewRotation);
        }
        else
            TRTCCloudCore::GetInstance()->getTRTCCloud()->setRemoteViewRotation(Wide2Ansi(m_userId).c_str(), m_canvasAttribute._viewRotation);
        
        if (m_streamType != TRTCVideoStreamTypeBig)
            m_pBtnRotation->SetVisible(false);
        else
            m_pBtnRotation->SetVisible(true);
    }

    if (m_pBtnRenderMode)
    {
        if (m_canvasAttribute._vidwFillMode == TRTCVideoFillMode_Fit)
        {
            m_pBtnRenderMode->SetNormalImage(L"videoview/render_fill.png");
        }
        else
            m_pBtnRenderMode->SetNormalImage(L"videoview/render_fit.png");

        if (m_streamType != TRTCVideoStreamTypeBig && VideoCanvasContainer::localUserId.compare(m_userId) == 0)
            m_pBtnRenderMode->SetVisible(false);
        else
            m_pBtnRenderMode->SetVisible(true);

        if (m_pLiveAvView)
        {
            m_pLiveAvView->SetRenderMode((TXLiveAvVideoView::ViewRenderModeEnum)m_canvasAttribute._vidwFillMode);
        }
        if (VideoCanvasContainer::localUserId.compare(m_userId) == 0 && m_streamType != TRTCVideoStreamTypeSub)
            TRTCCloudCore::GetInstance()->getTRTCCloud()->setLocalViewFillMode(m_canvasAttribute._vidwFillMode);
        else
        {
            if (m_streamType == TRTCVideoStreamTypeSub)
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setRemoteSubStreamViewFillMode(Wide2Ansi(m_userId).c_str(), m_canvasAttribute._vidwFillMode);
            else
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setRemoteViewFillMode(Wide2Ansi(m_userId).c_str(), m_canvasAttribute._vidwFillMode);
        }
    }

    if (m_pBtnAudioIcon)
    {
        if (m_streamType != TRTCVideoStreamTypeBig)
            m_pBtnAudioIcon->SetVisible(false);
        else
            m_pBtnAudioIcon->SetVisible(true);

        updateAudioIconStatus();
    }

    if (m_pBtnVideoIcon)
    {
        m_pBtnVideoIcon->SetVisible(true);
        updateVideoIconStatus();
    }

    if (m_pBtnNetSignalIcon)
    {
        std::wstring formatStr = format(L"videoview/net_signal_%d.png", m_canvasAttribute._netSignalQuality);
        m_pBtnNetSignalIcon->SetNormalImage(formatStr.c_str());
    }

    SetPos(m_rcItem, true);
}

void VideoCanvasContainer::muteAudio(bool bMute)
{
    m_canvasAttribute._bMuteAudio = bMute;
    updateAudioIconStatus();
}

void VideoCanvasContainer::muteVideo(bool bMute)
{
    m_canvasAttribute._bMuteVideo = bMute;
    updateVideoIconStatus();
}

void VideoCanvasContainer::showPKIcon(bool bShow, uint32_t roomId)
{
    m_canvasAttribute._bPKUser = bShow;
    m_canvasAttribute._pkRoomId = roomId;
    //if (m_pBtnPKUIcon)
    //    m_pBtnPKUIcon->SetVisible(bShow);
    //SetPos(m_rcItem, true);
}

void VideoCanvasContainer::updateVoiceVolume(int volume)
{
    int _volume = volume;
    if (_volume > 100)
        _volume = 100;
    if (_volume < 0)
        _volume = 0;

    m_canvasAttribute._volume = _volume;
    int id = _volume * 15 / 100;

    if (m_canvasAttribute._bMuteAudio)
        return;

    std::wstring formatStr = format(L"videoview/voicevolume%d.png", id + 1);
    if (m_pBtnAudioIcon)
        m_pBtnAudioIcon->SetNormalImage(formatStr.c_str());
}

void VideoCanvasContainer::updateNetSignal(int quality)
{
    int _quality = quality;
    if (_quality == TRTCQuality_Unknown)
        _quality = TRTCQuality_Excellent;

    m_canvasAttribute._netSignalQuality = quality;
    std::wstring formatStr = format(L"videoview/net_signal_%d.png", m_canvasAttribute._netSignalQuality);
    if (m_pBtnNetSignalIcon)
        m_pBtnNetSignalIcon->SetNormalImage(formatStr.c_str());

}

void VideoCanvasContainer::SetPos(RECT rc, bool bNeedInvalidate)
{
    CContainerUI::SetPos(rc, bNeedInvalidate);
    
    if (m_pLiveAvView)
    {
        RECT rc;
        rc.left = m_rcItem.left + 1;
        rc.right = m_rcItem.right - 1;
        rc.top = m_rcItem.top + 1;
        rc.bottom = m_rcItem.bottom - 1;
        m_pLiveAvView->SetPos(rc);
    }
    int right_pos = 30;

    if (m_pBtnNetSignalIcon && m_pBtnNetSignalIcon->IsVisible())
    {
        RECT rc = m_rcItem;
        int width = rc.right - rc.left;
        int left = width - right_pos;
        int top = 4;
        SIZE leftTop = { left,top };

        SIZE btnLeftTop = m_pBtnNetSignalIcon->GetFixedXY();
        if (btnLeftTop.cx != leftTop.cx || btnLeftTop.cy != leftTop.cy)
        {
            m_pBtnNetSignalIcon->SetFixedXY(leftTop);
        }
        right_pos += 24;
    }

    if (m_pBtnAudioIcon && m_pBtnAudioIcon->IsVisible())
    {
        RECT rc = m_rcItem;
        int width = rc.right - rc.left;
        int left = width - right_pos;
        int top = 4;
        SIZE leftTop = { left,top };

        SIZE btnLeftTop = m_pBtnAudioIcon->GetFixedXY();
        if (btnLeftTop.cx != leftTop.cx || btnLeftTop.cy != leftTop.cy)
        {
            m_pBtnAudioIcon->SetFixedXY(leftTop);
        }
        right_pos += 24;
    }

    if (m_pBtnVideoIcon && m_pBtnVideoIcon->IsVisible())
    {
        RECT rc = m_rcItem;
        int width = rc.right - rc.left;
        int left = width - right_pos + 2;
        int top = 6;
        SIZE leftTop = { left,top };

        SIZE btnLeftTop = m_pBtnVideoIcon->GetFixedXY();
        if (btnLeftTop.cx != leftTop.cx || btnLeftTop.cy != leftTop.cy)
        {
            m_pBtnVideoIcon->SetFixedXY(leftTop);
        }
        right_pos += 24;
    }

    if (m_pBtnRotation && m_pBtnRotation->IsVisible())
    {
        RECT rc = m_rcItem;
        int width = rc.right - rc.left;
        int left = width - right_pos;
        int top =  4;
        SIZE leftTop = { left,top };
        
        SIZE btnLeftTop = m_pBtnRotation->GetFixedXY();
        if (btnLeftTop.cx != leftTop.cx || btnLeftTop.cy != leftTop.cy)
        {
            m_pBtnRotation->SetFixedXY(leftTop);
        }
        right_pos += 24;
    }

    if (m_pBtnRenderMode && m_pBtnRenderMode->IsVisible())
    {
        RECT rc = m_rcItem;
        int width = rc.right - rc.left;
        int left = width - right_pos;
        int top = 4;
        SIZE leftTop = { left,top };

        SIZE btnLeftTop = m_pBtnRenderMode->GetFixedXY();
        if (btnLeftTop.cx != leftTop.cx || btnLeftTop.cy != leftTop.cy)
        {
            m_pBtnRenderMode->SetFixedXY(leftTop);
        }
        right_pos += 24;
    }

    if (m_pIconBg)
    {
        RECT rc = m_rcItem;
        int width = rc.right - rc.left;
        int left = width - 130;
        int top = 2;
        SIZE leftTop = { left,top };

        SIZE btnLeftTop = m_pIconBg->GetFixedXY();
        if (btnLeftTop.cx != leftTop.cx || btnLeftTop.cy != leftTop.cy)
        {
            m_pIconBg->SetFixedXY(leftTop);
        }
    }

}

void VideoCanvasContainer::DoEvent(TEventUI & event)
{
    CContainerUI::DoEvent(event);
    if (event.Type == UIEVENT_DBLCLICK)
    {
        //名字双击事件
        if (::PtInRect(&m_rcItem, event.ptMouse) && IsEnabled()) {
            if (m_userId.compare(L"") != 0)
            {
                if (!m_bMainView && m_pCb)
                    m_pCb->DoubleClickView(m_userId, m_streamType);
            }
        }
    }
}

void VideoCanvasContainer::Notify(TNotifyUI & msg)
{
    if (msg.sType == _T("click"))
    {
        if (msg.pSender->GetName() == strBtnRotationName)
        {
            if (m_canvasAttribute._viewRotation == TRTCVideoRotation0)
                m_canvasAttribute._viewRotation = TRTCVideoRotation90;
            else if (m_canvasAttribute._viewRotation == TRTCVideoRotation90)
                m_canvasAttribute._viewRotation = TRTCVideoRotation180;
            else if (m_canvasAttribute._viewRotation == TRTCVideoRotation180)
                m_canvasAttribute._viewRotation = TRTCVideoRotation270;
            else if (m_canvasAttribute._viewRotation == TRTCVideoRotation270)
                m_canvasAttribute._viewRotation = TRTCVideoRotation0;

            if (VideoCanvasContainer::localUserId.compare(m_userId) == 0)
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setLocalViewRotation(m_canvasAttribute._viewRotation);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setVideoEncoderRotation(m_canvasAttribute._viewRotation);
            }
            else
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setRemoteViewRotation(Wide2Ansi(m_userId).c_str(), m_canvasAttribute._viewRotation);
            return;
        }

        if (msg.pSender->GetName() == strBtnRenderModeName)
        {
            if (m_canvasAttribute._vidwFillMode == TRTCVideoFillMode_Fit)
            {
                m_canvasAttribute._vidwFillMode = TRTCVideoFillMode_Fill;
                m_pBtnRenderMode->SetNormalImage(L"videoview/render_fit.png");
            }
            else
            {
                m_canvasAttribute._vidwFillMode = TRTCVideoFillMode_Fit;
                m_pBtnRenderMode->SetNormalImage(L"videoview/render_fill.png");
            }

            if (m_pLiveAvView)
            {
                m_pLiveAvView->SetRenderMode((TXLiveAvVideoView::ViewRenderModeEnum)m_canvasAttribute._vidwFillMode);
            }
            if (VideoCanvasContainer::localUserId.compare(m_userId) == 0)
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setLocalViewFillMode(m_canvasAttribute._vidwFillMode);
            else
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setRemoteViewFillMode(Wide2Ansi(m_userId).c_str(), m_canvasAttribute._vidwFillMode);
            return;
        }
        

        if (m_streamType == TRTCVideoStreamTypeBig)
        {
            if (msg.pSender->GetName() == strBtnAudioIconName)
            {
                HWND _hwnd = GetManager()->GetPaintWindow();
                UI_EVENT_MSG *msg = new UI_EVENT_MSG;
                msg->_id = UI_EVENT_MSG::UI_BTNMSG_ID_MuteAudio;
                msg->_userId = m_userId;
                msg->_streamType = m_streamType;
                ::PostMessage(_hwnd, WM_USER_VIEW_BTN_CLICK, (WPARAM)msg, 0);
            }
        }

        if (msg.pSender->GetName() == strBtnVideoIconName)
        {
            HWND _hwnd = GetManager()->GetPaintWindow();
            UI_EVENT_MSG *msg = new UI_EVENT_MSG;
            msg->_id = UI_EVENT_MSG::UI_BTNMSG_ID_MuteVideo;
            msg->_userId = m_userId;
            msg->_streamType = m_streamType;
            ::PostMessage(_hwnd, WM_USER_VIEW_BTN_CLICK, (WPARAM)msg, 0);
        }
        
    }
     
}

LRESULT VideoCanvasContainer::MessageHandler(UINT uMsg, WPARAM wParam, LPARAM lParam, bool & bHandled)
{
    if (uMsg == m_pLiveAvView->GetPaintMsgID())
    {
        int viewwidth = (int)wParam;
        int viewheight = (int)lParam;
        if (m_viewwidth != viewwidth || m_viewheight != viewheight)
        {
            m_viewwidth = viewwidth;
            m_viewheight = viewheight;
            SetPos(m_rcItem, true);
        }
    }
    return 0;
}

void VideoCanvasContainer::updateAudioIconStatus()
{
    if (m_canvasAttribute._bMuteAudio == false)
    {
        m_pBtnAudioIcon->SetNormalImage(L"videoview/voicevolume1.png");
        m_pBtnAudioIcon->SetToolTip(L"静音");
    }
    else
    {
        m_pBtnAudioIcon->SetNormalImage(L"videoview/voicevolume0.png");
        m_pBtnAudioIcon->SetToolTip(L"停止静音");
    }
}

void VideoCanvasContainer::updateVideoIconStatus()
{
    if (m_canvasAttribute._bMuteVideo == false)
    {
        m_pBtnVideoIcon->SetNormalImage(L"videoview/video_open.png");
        m_pBtnVideoIcon->SetToolTip(L"关闭视频");
        m_pLiveAvView->SetPause(false);
    }
    else
    {
        m_pBtnVideoIcon->SetNormalImage(L"videoview/video_close.png");
        m_pBtnVideoIcon->SetToolTip(L"启动视频");
        m_pLiveAvView->SetPause(true);
    }
}

void VideoCanvasContainer::switchCanvasAttribute(VideoCanvasContainer * viewA, VideoCanvasContainer * viewB)
{
    VideoCanvasAttribute tempAttribute = viewA->getVideoCanvasAttribute();
    viewA->copyCanvasAttribute(viewB);
    VideoCanvasAttribute& tempAttributeB = viewB->getVideoCanvasAttribute();
    tempAttributeB = tempAttribute;
}

void VideoCanvasContainer::copyCanvasAttribute(VideoCanvasContainer * view)
{
    m_canvasAttribute = view->getVideoCanvasAttribute();

}

////////////////////////////////////////////////////////////////////////// ---- CVideoRenderWndMgr
std::vector<VideoCanvasContainer*> g_VideoCanvasContainerList;
TRTCVideoViewLayout::TRTCVideoViewLayout()
{
}

TRTCVideoViewLayout::~TRTCVideoViewLayout()
{
    g_VideoCanvasContainerList.clear();
}

CControlUI * TRTCVideoViewLayout::CreateControl(LPCTSTR pstrClass, CPaintManagerUI* pPM)
{
    if (m_pmUI == nullptr)
        m_pmUI = pPM;
    if (_tcsicmp(pstrClass, _T("VideoCanvasContainer")) == 0) 
    {
        
        VideoCanvasContainer  *pVideoRenderUI = new VideoCanvasContainer(this);
        g_VideoCanvasContainerList.push_back(pVideoRenderUI);
        pVideoRenderUI->SetBorderSize(1);
        pVideoRenderUI->SetBorderColor(0xFF999999);
        nTotalRenderWindowCnt++;
        return pVideoRenderUI;
        
    }
    return nullptr;
}

void TRTCVideoViewLayout::initRenderUI()
{
    if (m_pmUI == nullptr) return;
    for (auto &object_ : g_VideoCanvasContainerList)
    {
        _tagVideoRenderInfo info;
        info._viewLayout = object_;
        std::wstring viewName = object_->GetName();
        if (viewName.find(L"lecture_view") != std::wstring::npos)
        {
            info._viewLayout->SetVisible(false);
            info._viewLayout->initCanvasContainer();
            m_mapLectureView.insert(std::pair<std::wstring, VideoRenderInfo>(viewName, info));
        }
        else if (viewName.find(L"gallery_view") != std::wstring::npos)
        {
            info._viewLayout->SetVisible(false);
            info._viewLayout->initCanvasContainer();
            m_mapGalleryView.insert(std::pair<std::wstring, VideoRenderInfo>(viewName, info));
        }
        
    }
    g_VideoCanvasContainerList.clear();
    nTotalRenderWindowCnt = nTotalRenderWindowCnt / 2;
    lectureview_sublayout_container1 = static_cast<CControlUI*>(m_pmUI->FindControl(_T("view_sublayout_container1")));
    galleryview_sublayout_line2 = static_cast<CControlUI*>(m_pmUI->FindControl(_T("view_sublayout_line2")));
    galleryview_sublayout_line3 = static_cast<CControlUI*>(m_pmUI->FindControl(_T("view_sublayout_line3")));

    lecture_layout_videoview_container = static_cast<CVerticalLayoutUI*>(m_pmUI->FindControl(_T("lecture_layout_videoview_container")));;       //
    gallery_layout_videoview_container = static_cast<CVerticalLayoutUI*>(m_pmUI->FindControl(_T("gallery_layout_videoview_container")));;       //

    if (mViewLayoutStyleEnum == ViewLayoutStyle_Lecture)
    {
        lecture_layout_videoview_container->SetVisible(true);
        gallery_layout_videoview_container->SetVisible(false);
    }
    else
    {
        lecture_layout_videoview_container->SetVisible(false);
        gallery_layout_videoview_container->SetVisible(true);
    }
}

void TRTCVideoViewLayout::unInitRenderUI()
{
    for (auto &itr : m_mapLectureView)
    {
        if (_tcsicmp(itr.second._userId.c_str(), L"") != 0)
        {
            itr.second._viewLayout->resetViewUIStatus(L"");
        }
    }
    for (auto &itr : m_mapGalleryView)
    {
        if (_tcsicmp(itr.second._userId.c_str(), L"") != 0)
        {
            itr.second._viewLayout->resetViewUIStatus(L"");
        }
    }
}

/*
窗口分配规则比较复杂，后面补充交互步骤。
*/
int TRTCVideoViewLayout::dispatchVideoView(std::wstring userId, TRTCVideoStreamType type)
{
    return dispatchVideoView(userId, type, false, 0);
}

int TRTCVideoViewLayout::dispatchVideoView(std::wstring userId, TRTCVideoStreamType type, bool bPKUser, int roomId)
{
    HWND dispacthHwnd = NULL;
    if (IsUserRender(userId, type))
        return -1;
    if (nHadUseCnt >= nTotalRenderWindowCnt) //已经没有渲染视频的位置了
        return -2;
    //首先个窗口直接分配主窗口
    if (nHadUseCnt == 0)
    {
        VideoRenderInfo& info = GetMainRenderView();
        info._userId = userId;
        info._streamType = type;
        if (bPKUser) info._viewLayout->showPKIcon(true, roomId);
        info._viewLayout->resetViewUIStatus(userId.c_str(), type);
        info._viewLayout->SetVisible(true);
        nHadUseCnt++;
    }
    else if (IsMainRenderWndUse() && nHadUseCnt == 1)     //主窗口被占用,mViewLayoutStyleEnum == ViewLayoutStyle_Lecture暂定
    {
        bool bFind = false;
        VideoRenderInfo& minInfo = FindIdleRenderView(bFind);
        if (bFind == false)
            return -3;
        //把主窗口视频移走:分配主窗口给远程视频
        VideoRenderInfo& mainInfo = GetMainRenderView();

        minInfo._userId = mainInfo._userId;
        minInfo._streamType = mainInfo._streamType;
        minInfo._viewLayout->cleanViewStatus();
        minInfo._viewLayout->copyCanvasAttribute(mainInfo._viewLayout);
        minInfo._viewLayout->resetViewUIStatus(mainInfo._userId.c_str(), mainInfo._streamType);
        minInfo._viewLayout->SetVisible(true);

        //分配主窗口视图。
        mainInfo._userId = userId;
        mainInfo._streamType = type;
        mainInfo._viewLayout->cleanViewStatus();
        mainInfo._viewLayout->resetViewUIStatus(L""); //先清除旧记录
        if (bPKUser) mainInfo._viewLayout->showPKIcon(true, roomId);
        mainInfo._viewLayout->resetViewUIStatus(userId.c_str(), type);
        mainInfo._viewLayout->SetVisible(true);
        nHadUseCnt++;
    }
    else
    {
        bool bFind = false;
        VideoRenderInfo& info = FindIdleRenderView(bFind);
        if (bFind == false)
            return -4;
        info._userId = userId;
        info._streamType = type;
        info._viewLayout->cleanViewStatus();
        if (bPKUser) info._viewLayout->showPKIcon(true, roomId);
        info._viewLayout->resetViewUIStatus(userId.c_str(), type);
        info._viewLayout->SetVisible(true);
        nHadUseCnt++;
    }
    if (mViewLayoutStyleEnum == ViewLayoutStyle_Lecture)
    {
        if (nHadUseCnt >= 2)
            lectureview_sublayout_container1->SetVisible(true);
    }
    else
    {
        if (nHadUseCnt >= 3)
            galleryview_sublayout_line2->SetVisible(true);
        if (nHadUseCnt >= 5)
            galleryview_sublayout_line3->SetVisible(true);
    }
    return 0;
}

int TRTCVideoViewLayout::dispatchPKVideoView(std::wstring userId, TRTCVideoStreamType type, uint32_t roomId)
{
    return dispatchVideoView(userId, type, true, roomId);
}

bool TRTCVideoViewLayout::deleteVideoView(std::wstring userId, TRTCVideoStreamType type)
{
    bool bDel = false;
    //调整窗口
    if (mViewLayoutStyleEnum == ViewLayoutStyle_Lecture)
    {
        for (auto &itr : m_mapLectureView)
        {
            if (_tcsicmp(itr.second._userId.c_str(), userId.c_str()) == 0 && itr.second._streamType == type)
            {
                itr.second._userId = L"";
                itr.second._viewLayout->resetViewUIStatus(itr.second._userId.c_str(), itr.second._streamType);
                itr.second._viewLayout->SetVisible(false);
                nHadUseCnt--;
                bDel = true;
                break;
            }
        }
        if (bDel == false) return bDel;
        AdjustViewDispatch(m_mapLectureView);
    }
    else
    {
        for (auto &itr : m_mapGalleryView)
        {
            if (_tcsicmp(itr.second._userId.c_str(), userId.c_str()) == 0 && itr.second._streamType == type)
            {
                itr.second._userId = L"";
                itr.second._viewLayout->resetViewUIStatus(itr.second._userId.c_str(), itr.second._streamType);
                itr.second._viewLayout->SetVisible(false);
                bDel = true;
                nHadUseCnt--;
                break;
            }
        }
        if (bDel == false) return bDel;
        AdjustViewDispatch(m_mapGalleryView);
    }
    //调整布局渲染区域
    
    if (mViewLayoutStyleEnum == ViewLayoutStyle_Lecture)
    {
        if (nHadUseCnt <= 1)
            lectureview_sublayout_container1->SetVisible(false);
    }
    else
    {
        if (nHadUseCnt <= 2)
            galleryview_sublayout_line2->SetVisible(false);
        if (nHadUseCnt <= 4)
            galleryview_sublayout_line3->SetVisible(false);
    }
    return bDel;
}

bool TRTCVideoViewLayout::SwapVideoView(std::wstring userIdA, std::wstring userIdB, TRTCVideoStreamType typeA, TRTCVideoStreamType typeB)
{
    bool bFindA = false;
    VideoRenderInfo& minInfoA = FindRenderView(userIdA, typeA, bFindA);
    if (bFindA == false)
        return NULL;
    bool bFindB = false;
    VideoRenderInfo& minInfoB = FindRenderView(userIdB, typeB, bFindB);
    if (bFindB == false)
        return NULL;

    minInfoA._viewLayout->resetViewUIStatus(L"");
    minInfoB._viewLayout->resetViewUIStatus(L"");

    VideoCanvasContainer::switchCanvasAttribute(minInfoA._viewLayout, minInfoB._viewLayout);
    TRTCVideoViewLayout::switchVideoRenderInfo(minInfoA, minInfoB);

    minInfoA._viewLayout->resetViewUIStatus(minInfoA._userId.c_str(), minInfoA._streamType);
    minInfoB._viewLayout->resetViewUIStatus(minInfoB._userId.c_str(), minInfoB._streamType);
    return true;
}

bool TRTCVideoViewLayout::SwapViewLayoutStyle(ViewLayoutStyleEnum oldStyle, ViewLayoutStyleEnum newStyle)
{
    //主要从新把占用窗口，按 1、2、3、4、5、6、7、8、9排序
    if (oldStyle == ViewLayoutStyle_Lecture && newStyle == ViewLayoutStyle_Gallery)
    {
        for (auto &itr1 : m_mapGalleryView)
        {
            if (_tcsicmp(itr1.second._userId.c_str(), L"") != 0)
            {
                itr1.second.clean();
                itr1.second._viewLayout->cleanViewStatus();
                itr1.second._viewLayout->resetViewUIStatus(itr1.second._userId.c_str(), itr1.second._streamType);
                itr1.second._viewLayout->SetVisible(false);
            }
            for (auto &itr2 : m_mapLectureView)
            {
                if (_tcsicmp(itr2.second._userId.c_str(), L"") != 0)
                {
                    itr1.second.copyVideoRenderInfo(itr2.second);
                    itr1.second._viewLayout->copyCanvasAttribute(itr2.second._viewLayout);

                    itr2.second.clean();
                    itr2.second._viewLayout->cleanViewStatus();
                    itr2.second._viewLayout->resetViewUIStatus(L"");
                    itr2.second._viewLayout->SetVisible(false);
  
                    itr1.second._viewLayout->resetViewUIStatus(itr1.second._userId.c_str(), itr1.second._streamType);
                    itr1.second._viewLayout->SetVisible(true);
                    break;
                }
            }
        }
    }
    else if (oldStyle == ViewLayoutStyle_Gallery && newStyle == ViewLayoutStyle_Lecture)
    {
        for (auto &itr1 : m_mapLectureView)
        {
            if (_tcsicmp(itr1.second._userId.c_str(), L"") != 0)
            {
                itr1.second.clean();
                itr1.second._viewLayout->cleanViewStatus();
                itr1.second._viewLayout->resetViewUIStatus(itr1.second._userId.c_str(), itr1.second._streamType);
                itr1.second._viewLayout->SetVisible(false);
            }
            for (auto &itr2 : m_mapGalleryView)
            {
                if (_tcsicmp(itr2.second._userId.c_str(), L"") != 0)
                {
                    itr1.second.copyVideoRenderInfo(itr2.second);
                    itr1.second._viewLayout->copyCanvasAttribute(itr2.second._viewLayout);

                    itr2.second.clean();
                    itr2.second._viewLayout->cleanViewStatus();
                    itr2.second._viewLayout->resetViewUIStatus(L"");
                    itr2.second._viewLayout->SetVisible(false);

                    itr1.second._viewLayout->resetViewUIStatus(itr1.second._userId.c_str(), itr1.second._streamType);
                    itr1.second._viewLayout->SetVisible(true);

                    break;
                }
            }
        }
    }

    if (newStyle == ViewLayoutStyle_Lecture)
    {
        if (nHadUseCnt >= 2)
            lectureview_sublayout_container1->SetVisible(true);
        galleryview_sublayout_line2->SetVisible(false);
        galleryview_sublayout_line3->SetVisible(false);
        lecture_layout_videoview_container->SetVisible(true);
        gallery_layout_videoview_container->SetVisible(false);

    }
    else if (newStyle == ViewLayoutStyle_Gallery)
    {
        if (nHadUseCnt >= 3 )
            galleryview_sublayout_line2->SetVisible(true);
        if (nHadUseCnt >= 5)
            galleryview_sublayout_line3->SetVisible(true);
        lectureview_sublayout_container1->SetVisible(false);
        lecture_layout_videoview_container->SetVisible(false);
        gallery_layout_videoview_container->SetVisible(true);
    }

    return true;
}

bool TRTCVideoViewLayout::muteAudio(std::wstring userId, TRTCVideoStreamType type, bool bMute)
{
    bool bFind = false;
    VideoRenderInfo& info = FindRenderView(userId, type, bFind);
    if (bFind == false)
        return false;
    if (info._viewLayout)
    {
        info._viewLayout->muteAudio(bMute);
    }
    return true;
}

bool TRTCVideoViewLayout::muteVideo(std::wstring userId, TRTCVideoStreamType type, bool bMute)
{
    bool bFind = false;
    VideoRenderInfo& info = FindRenderView(userId, type, bFind);
    if (bFind == false)
        return false;
    if (info._viewLayout)
    {
        info._viewLayout->muteVideo(bMute);
    }
    return true;
}

void TRTCVideoViewLayout::setLayoutStyle(ViewLayoutStyleEnum style)
{
    if (mViewLayoutStyleEnum == style) return;

    SwapViewLayoutStyle(mViewLayoutStyleEnum, style);

    mViewLayoutStyleEnum = style;
}

void TRTCVideoViewLayout::updateVoiceVolume(std::wstring userId, int volume)
{
    //设置所有view的音量回归初始状态。
    if (userId.compare(L"") == 0)
    {
        if (mViewLayoutStyleEnum == ViewLayoutStyle_Lecture)
        {
            for (auto &itr : m_mapLectureView)
            {
                itr.second._viewLayout->updateVoiceVolume(volume);
            }
        }
        else
        {
            for (auto &itr : m_mapGalleryView)
            {
                itr.second._viewLayout->updateVoiceVolume(volume);
            }
        }
    }
    else
    {
        if (mViewLayoutStyleEnum == ViewLayoutStyle_Lecture)
        {
            for (auto &itr : m_mapLectureView)
            {
                if (_tcsicmp(itr.second._userId.c_str(), userId.c_str()) == 0 && itr.second._streamType == TRTCVideoStreamTypeBig)
                {
                    itr.second._viewLayout->updateVoiceVolume(volume);
                }
            }
        }
        else
        {
            for (auto &itr : m_mapGalleryView)
            {
                if (_tcsicmp(itr.second._userId.c_str(), userId.c_str()) == 0 && itr.second._streamType == TRTCVideoStreamTypeBig)
                {
                    itr.second._viewLayout->updateVoiceVolume(volume);
                }
            }
        }
    }
}

void TRTCVideoViewLayout::updateNetSignal(std::wstring userId, int quality)
{
    if (mViewLayoutStyleEnum == ViewLayoutStyle_Lecture)
    {
        for (auto &itr : m_mapLectureView)
        {
            if (_tcsicmp(itr.second._userId.c_str(), userId.c_str()) == 0 )
            {
                itr.second._viewLayout->updateNetSignal(quality);
            }
        }
    }
    else
    {
        for (auto &itr : m_mapGalleryView)
        {
            if (_tcsicmp(itr.second._userId.c_str(), userId.c_str()) == 0)
            {
                itr.second._viewLayout->updateNetSignal(quality);
            }
        }
    }
}

void TRTCVideoViewLayout::AdjustViewDispatch(std::map<std::wstring, VideoRenderInfo>& mapView)
{
    //主要从新把占用窗口，按 1、2、3、4、5排序
    int index = 0;
    for (auto &itr1 : mapView)
    {
        index++;
        if (_tcsicmp(itr1.second._userId.c_str(), L"") == 0)
        {
            bool bFind = false;
            int i = index;
            for (auto &itr2 : mapView)
            {
                if (i>0)
                {
                    i--; continue;
                }
                if (_tcsicmp(itr2.second._userId.c_str(), L"") != 0)
                {
                    itr2.second._viewLayout->resetViewUIStatus(L"");

                    itr1.second._viewLayout->cleanViewStatus();
                    itr1.second.copyVideoRenderInfo(itr2.second);
                    itr1.second._viewLayout->copyCanvasAttribute(itr2.second._viewLayout);
                    itr1.second._viewLayout->resetViewUIStatus(itr1.second._userId.c_str(), itr1.second._streamType);
                    itr1.second._viewLayout->SetVisible(true);

                    itr2.second.clean();
                    itr2.second._viewLayout->cleanViewStatus();
                    itr2.second._viewLayout->SetVisible(false);
                    bFind = true;
                    break;
                }
            }
            if (bFind == true)
                break;
        }
    }
}

bool TRTCVideoViewLayout::IsUserRender(std::wstring userId, TRTCVideoStreamType type)
{
    if (mViewLayoutStyleEnum == ViewLayoutStyle_Lecture)
    {
        for (auto &itr : m_mapLectureView)
        {
            if (_tcsicmp(itr.second._userId.c_str(), userId.c_str()) == 0 && itr.second._streamType == type)
            {
                return true;
            }
        }
    }
    else
    {
        for (auto &itr : m_mapGalleryView)
        {
            if (_tcsicmp(itr.second._userId.c_str(), userId.c_str()) == 0 && itr.second._streamType == type)
            {
                return true;
            }
        }
    }
    return false;
}

bool TRTCVideoViewLayout::IsMainRenderWndUse()
{
    if (mViewLayoutStyleEnum == ViewLayoutStyle_Lecture)
    {
        for (auto &itr : m_mapLectureView)
        {
            if (itr.second._viewLayout->isMainView())
            {
                if (_tcsicmp(itr.second._userId.c_str(), L"") != 0)
                    return true;
            }
        }
    }
    else
    {
        for (auto &itr : m_mapGalleryView)
        {
            if (itr.second._viewLayout->isMainView())
            {
                if (_tcsicmp(itr.second._userId.c_str(), L"") != 0)
                    return true;
            }
        }
    }
    return false;
}

TRTCVideoViewLayout::VideoRenderInfo & TRTCVideoViewLayout::FindIdleRenderView(bool& bFind)
{
    if (mViewLayoutStyleEnum == ViewLayoutStyle_Lecture)
    {
        for (auto &itr : m_mapLectureView)
        {
            if (_tcsicmp(itr.second._userId.c_str(), L"") == 0)
            {
                bFind = true;
                return itr.second;
            }
        }
        bFind = false;
    }
    else
    {
        for (auto &itr : m_mapGalleryView)
        {
            if (_tcsicmp(itr.second._userId.c_str(), L"") == 0)
            {
                bFind = true;
                return itr.second;
            }
        }
        bFind = false;
    }
    return VideoRenderInfo();
}

TRTCVideoViewLayout::VideoRenderInfo & TRTCVideoViewLayout::FindFitMainRenderView(bool& bFind)
{
    if (mViewLayoutStyleEnum == ViewLayoutStyle_Lecture)
    {
        for (auto &itr : m_mapLectureView)
        {
            if (_tcsicmp(itr.second._userId.c_str(), L"") != 0)
            {
                bFind = true;
                return itr.second;
            }
        }
        bFind = false;
    }
    else
    {
        for (auto &itr : m_mapGalleryView)
        {
            if (_tcsicmp(itr.second._userId.c_str(), L"") != 0)
            {
                bFind = true;
                return itr.second;
            }
        }
        bFind = false;
    }
    return VideoRenderInfo();
}

TRTCVideoViewLayout::VideoRenderInfo & TRTCVideoViewLayout::FindRenderView(std::wstring userId, TRTCVideoStreamType type, bool& bFind)
{
    if (mViewLayoutStyleEnum == ViewLayoutStyle_Lecture)
    {
        for (auto &itr : m_mapLectureView)
        {
            if (_tcsicmp(itr.second._userId.c_str(), userId.c_str()) == 0 && itr.second._streamType == type)
            {
                bFind = true;
                return itr.second;
            }
        }
        bFind = false;
    }
    else
    {
        for (auto &itr : m_mapGalleryView)
        {
            if (_tcsicmp(itr.second._userId.c_str(), userId.c_str()) == 0 && itr.second._streamType == type)
            {
                bFind = true;
                return itr.second;
            }
        }
        bFind = false;
    }
    
    return VideoRenderInfo();
}

TRTCVideoViewLayout::VideoRenderInfo & TRTCVideoViewLayout::GetMainRenderView()
{
    if (mViewLayoutStyleEnum == ViewLayoutStyle_Lecture)
    {
        for (auto &itr : m_mapLectureView)
        {
            if (itr.second._viewLayout->isMainView())
            {
                return itr.second;
            }
        }
    }
    else
    {
        for (auto &itr : m_mapGalleryView)
        {
            if (itr.second._viewLayout->isMainView())
            {
                return itr.second;
            }
        }
    }
    return VideoRenderInfo();
}

void TRTCVideoViewLayout::DoubleClickView(std::wstring userId, TRTCVideoStreamType type)
{
    if (mViewLayoutStyleEnum == ViewLayoutStyle_Lecture || mViewLayoutStyleEnum == ViewLayoutStyle_Gallery)
    {
        bool bFind = false;
        VideoRenderInfo& mainInfo = FindFitMainRenderView(bFind);
        if (!bFind)
            return;
        if (userId.compare(mainInfo._userId) == 0 && mainInfo._viewLayout->getVideoStreamType() == type)
            return;
        SwapVideoView(userId, mainInfo._userId, type, mainInfo._streamType);
    }

}

int TRTCVideoViewLayout::GetDispatchViewCnt()
{
    return nHadUseCnt;
}

void TRTCVideoViewLayout::switchVideoRenderInfo(VideoRenderInfo & viewA, VideoRenderInfo & viewB)
{
    std::wstring tempUserIdA = viewA._userId;
    TRTCVideoStreamType tempTypeA = viewA._streamType;
    viewA._userId = viewB._userId;
    viewA._streamType = viewB._streamType;
    viewB._userId = tempUserIdA;
    viewB._streamType = tempTypeA;
}
