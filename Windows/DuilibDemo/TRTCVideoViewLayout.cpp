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
    this->SetBorderColor(0xFF000000);
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
    strBtnSnapshotName.Format(L"snapshot_%s_%d", m_userId.c_str(), m_streamType);

    std::wstring _name = GetName();
    if (_name.compare(L"lecture_view0") == 0 || _name.compare(L"gallery_view0") == 0)
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
        m_pIconBg->SetFixedWidth(150);
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

    if (m_pBtnSnapshot == nullptr)
    {
        m_pBtnSnapshot = new CButtonUI();
        m_pBtnSnapshot->SetNormalImage(L"videoview/snapshot.png");
        m_pBtnSnapshot->SetName(strBtnSnapshotName);
        m_pBtnSnapshot->SetFloat();
        m_pBtnSnapshot->SetFixedWidth(16);
        m_pBtnSnapshot->SetFixedHeight(16);
        m_pBtnSnapshot->SetToolTip(L"截图");
        p->Add(m_pBtnSnapshot);
    }

    if (!m_bMainView && m_pLableText == nullptr) {
        m_pLableText = new CLabelUI();
        m_pLableText->SetText(m_userId.c_str());
        m_pLableText->SetTextColor(0x00FFFFFF);
        m_pLableText->SetFont(1);
        m_pLableText->SetBkColor(0xB0202020);
        p->Add(m_pLableText);
    }
}

void VideoCanvasContainer::cleanViewStatus()
{
    m_canvasAttribute.clean();
    if (m_pBtnRenderMode)
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

    if (m_pLableText)
    {
        m_pLableText->SetText(L"");
    }

    if (m_pLiveAvView)
    {
        m_pLiveAvView->SetPause(false);
        m_pLiveAvView->SetRenderMode(TXLiveAvVideoView::EVideoRenderModeFit);
    }
}

void VideoCanvasContainer::SetIsLable()
{
    this->SetBorderColor(0xFFFFFFFF);
    if (m_pLiveAvView)
    {
        m_pLiveAvView->SetPause(true);
    }
    if (m_pBtnRenderMode)
    {
        m_pBtnRenderMode->SetVisible(false);
    }
    if (m_pBtnRotation)
    {
        m_pBtnRotation->SetVisible(false);
    }
    if (m_pBtnAudioIcon)
    {
        m_pBtnAudioIcon->SetVisible(false);
    }
    if (m_pBtnVideoIcon)
    {
        m_pBtnVideoIcon->SetVisible(false);
    }
    if (m_pBtnNetSignalIcon)
    {
        m_pBtnNetSignalIcon->SetVisible(false);
    }
    if (m_pBtnSnapshot)
    {
        m_pBtnSnapshot->SetVisible(false);
    }
    if (m_pLableText)
    {
        m_pLableText->SetVisible(false);
    }
}

void VideoCanvasContainer::resetViewUIStatus(std::wstring userId, TRTCVideoStreamType type)
{
    this->SetBorderColor(0xFF000000);
    m_userId = userId;
    m_streamType = type;
    if (m_pLiveAvView)
    {
        if (userId.compare(L"") == 0)
            m_pLiveAvView->RemoveRenderInfo();
        else
        {
            if (m_userId.compare(localUserId) == 0)
                m_pLiveAvView->SetRenderInfo(Wide2UTF8(m_userId), type, true);
            else
                m_pLiveAvView->SetRenderInfo(Wide2UTF8(m_userId), type);
        }
        m_pLiveAvView->NeedUpdate();
    }

    strBtnRotationName.Format(L"rotation_%s_%d", m_userId.c_str(), m_streamType);
    strBtnRenderModeName.Format(L"rendermode_%s_%d", m_userId.c_str(), m_streamType);
    strBtnAudioIconName.Format(L"audioicon_%s_%d", m_userId.c_str(), m_streamType);
    strBtnVideoIconName.Format(L"videoicon_%s_%d", m_userId.c_str(), m_streamType);
    strBtnNetSignalIconName.Format(L"netsignalicon_%s_%d", m_userId.c_str(), m_streamType);
    strBtnSnapshotName.Format(L"snapshot_%s_%d", m_userId.c_str(), m_streamType);

    m_pBtnRotation->SetName(strBtnRotationName);
    m_pBtnRenderMode->SetName(strBtnRenderModeName);
    m_pBtnAudioIcon->SetName(strBtnAudioIconName);
    m_pBtnVideoIcon->SetName(strBtnVideoIconName);
    m_pBtnNetSignalIcon->SetName(strBtnNetSignalIconName);
    m_pBtnSnapshot->SetName(strBtnSnapshotName);

    if (m_pBtnRotation)
    {
        if (VideoCanvasContainer::localUserId.compare(m_userId) == 0)
        {
            TRTCCloudCore::GetInstance()->getTRTCCloud()->setLocalRenderParams(m_canvasAttribute.renderParams);
            TRTCCloudCore::GetInstance()->getTRTCCloud()->setVideoEncoderRotation(m_canvasAttribute.renderParams.rotation);
        }
        else
            TRTCCloudCore::GetInstance()->getTRTCCloud()->setRemoteRenderParams(Wide2UTF8(m_userId).c_str(), TRTCVideoStreamTypeBig, m_canvasAttribute.renderParams);

        if (m_streamType != TRTCVideoStreamTypeBig)
            m_pBtnRotation->SetVisible(false);
        else
            m_pBtnRotation->SetVisible(true);
    }

    if (m_pBtnRenderMode)
    {
        if (m_canvasAttribute.renderParams.fillMode == TRTCVideoFillMode_Fit)
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
            m_pLiveAvView->SetRenderMode((TXLiveAvVideoView::ViewRenderModeEnum)m_canvasAttribute.renderParams.fillMode);
        }
        if (VideoCanvasContainer::localUserId.compare(m_userId) == 0 && m_streamType != TRTCVideoStreamTypeSub)
            TRTCCloudCore::GetInstance()->getTRTCCloud()->setLocalRenderParams(m_canvasAttribute.renderParams);
        else
        {
            TRTCCloudCore::GetInstance()->getTRTCCloud()->setRemoteRenderParams(Wide2UTF8(m_userId).c_str(), m_streamType, m_canvasAttribute.renderParams);
        }
    }

    if (m_pBtnSnapshot) {
        m_pBtnSnapshot->SetVisible(true);
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
        m_pBtnNetSignalIcon->SetVisible(true);
        std::wstring formatStr = format(L"videoview/net_signal_%d.png", m_canvasAttribute._netSignalQuality);
        m_pBtnNetSignalIcon->SetNormalImage(formatStr.c_str());
    }

    if (m_pLableText)
    {
        m_pLableText->SetText(m_userId.c_str());
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
    int id = _volume * 14 / 100;

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
        int top = 4;
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

    if (m_pBtnSnapshot && m_pBtnSnapshot->IsVisible()) {
        RECT rc = m_rcItem;
        int width = rc.right - rc.left;
        int left = width - right_pos + 2;
        int top = 8;
        SIZE leftTop = {left, top};

        SIZE btnLeftTop = m_pBtnSnapshot->GetFixedXY();
        if (btnLeftTop.cx != leftTop.cx || btnLeftTop.cy != leftTop.cy) {
            m_pBtnSnapshot->SetFixedXY(leftTop);
        }
        right_pos += 24;
    }

    if (m_pIconBg)
    {
        RECT rc = m_rcItem;
        int width = rc.right - rc.left;
        int left = width - 150;
        int top = 2;
        SIZE leftTop = { left,top };

        SIZE btnLeftTop = m_pIconBg->GetFixedXY();
        if (btnLeftTop.cx != leftTop.cx || btnLeftTop.cy != leftTop.cy)
        {
            m_pIconBg->SetFixedXY(leftTop);
        }
    }

    if (m_pLableText)
    {
        RECT rc;
        rc.left = m_rcItem.left + 1;
        rc.right = m_rcItem.right - 1;
        rc.top = m_rcItem.bottom - 30;
        rc.bottom = m_rcItem.bottom - 1;
        m_pLableText->SetPos(rc);
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
        if (msg.pSender == m_pBtnRotation)
        {
            if (m_canvasAttribute.renderParams.rotation == TRTCVideoRotation0)
                m_canvasAttribute.renderParams.rotation = TRTCVideoRotation90;
            else if (m_canvasAttribute.renderParams.rotation == TRTCVideoRotation90)
                m_canvasAttribute.renderParams.rotation = TRTCVideoRotation180;
            else if (m_canvasAttribute.renderParams.rotation == TRTCVideoRotation180)
                m_canvasAttribute.renderParams.rotation = TRTCVideoRotation270;
            else if (m_canvasAttribute.renderParams.rotation == TRTCVideoRotation270)
                m_canvasAttribute.renderParams.rotation = TRTCVideoRotation0;

            if (VideoCanvasContainer::localUserId.compare(m_userId) == 0)
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setLocalRenderParams(m_canvasAttribute.renderParams);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setVideoEncoderRotation(m_canvasAttribute.renderParams.rotation);
            }
            else
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setRemoteRenderParams(Wide2UTF8(m_userId).c_str(), m_streamType, m_canvasAttribute.renderParams);
            return;
        }

        if (msg.pSender == m_pBtnRenderMode)
        {
            if (m_canvasAttribute.renderParams.fillMode == TRTCVideoFillMode_Fit)
            {
                m_canvasAttribute.renderParams.fillMode = TRTCVideoFillMode_Fill;
                m_pBtnRenderMode->SetNormalImage(L"videoview/render_fit.png");
            }
            else
            {
                m_canvasAttribute.renderParams.fillMode = TRTCVideoFillMode_Fit;
                m_pBtnRenderMode->SetNormalImage(L"videoview/render_fill.png");
            }

            if (m_pLiveAvView)
            {
                m_pLiveAvView->SetRenderMode((TXLiveAvVideoView::ViewRenderModeEnum)m_canvasAttribute.renderParams.fillMode);
            }
            if (VideoCanvasContainer::localUserId.compare(m_userId) == 0) {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setLocalRenderParams(m_canvasAttribute.renderParams);
            } else {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setRemoteRenderParams(Wide2UTF8(m_userId).c_str(), m_streamType, m_canvasAttribute.renderParams);
            }
            return;
        }

        if (msg.pSender == m_pBtnSnapshot) {
            if (VideoCanvasContainer::localUserId.compare(m_userId) == 0) {
                TRTCCloudCore::GetInstance()->snapshotVideoFrame("", TRTCVideoStreamTypeBig);
                TRTCCloudCore::GetInstance()->snapshotVideoFrame("", TRTCVideoStreamTypeSmall);
                TRTCCloudCore::GetInstance()->snapshotVideoFrame("", TRTCVideoStreamTypeSub);
            } else {
                TRTCCloudCore::GetInstance()->snapshotVideoFrame(Wide2UTF8(m_userId).c_str(), m_streamType);
            }
            return;
        }


        if (m_streamType == TRTCVideoStreamTypeBig)
        {
            if (msg.pSender == m_pBtnAudioIcon)
            {
                HWND _hwnd = GetManager()->GetPaintWindow();
                UI_EVENT_MSG *msg = new UI_EVENT_MSG;
                msg->_id = UI_EVENT_MSG::UI_BTNMSG_ID_MuteAudio;
                msg->_userId = m_userId;
                msg->_streamType = m_streamType;
                ::PostMessage(_hwnd, WM_USER_VIEW_BTN_CLICK, (WPARAM)msg, 0);
            }
        }

        if (msg.pSender == m_pBtnVideoIcon)
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

        if (m_pLableText)
        {
            m_pLableText->SetVisible(true);
        }
    }
    else
    {
        m_pBtnVideoIcon->SetNormalImage(L"videoview/video_close.png");
        m_pBtnVideoIcon->SetToolTip(L"启动视频");
        m_pLiveAvView->SetPause(true);

        if (m_pLableText)
        {
            m_pLableText->SetVisible(false);
        }
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
    }
    g_VideoCanvasContainerList.clear();
    nTotalRenderWindowCnt = nTotalRenderWindowCnt;
    lectureview_sublayout_container1 = static_cast<CVerticalLayoutUI*>(m_pmUI->FindControl(_T("view_sublayout_container1")));
    lectureview_sublayout_container1->GetVerticalScrollBar()->SetFixedWidth(2);
    lecture_layout_videoview_container = static_cast<CVerticalLayoutUI*>(m_pmUI->FindControl(_T("lecture_layout_videoview_container")));;       //
    mainview_container_bgtext = static_cast<CLabelUI*>(m_pmUI->FindControl(_T("mainview_container_bgtext")));;
    lecture_change_remote_visible = static_cast<CButtonUI*>(m_pmUI->FindControl(_T("lecture_change_remote_visible")));
    mainview_container_bgtext->SetVisible(false);

    m_pForward = static_cast<CButtonUI*>(m_pmUI->FindControl(_T("btn_forward")));
    m_pBackword = static_cast<CButtonUI*>(m_pmUI->FindControl(_T("btn_backword")));
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
    m_mapAllViews.clear();
    nId = 0;
    TXLiveAvVideoView::RemoveAllRegEngine();
}

/*
窗口分配规则比较复杂，后面补充交互步骤。
*/
int TRTCVideoViewLayout::dispatchVideoView(std::wstring userId, TRTCVideoStreamType type)
{
    return dispatchVideoView(userId, type, false, 0);
}

void TRTCVideoViewLayout::InsertIntoAllView(VideoRenderInfo& info)
{
    bool bFind = false;
    for (auto &itr : m_mapAllViews)
    {
        if (_tcsicmp(itr.second._userId.c_str(), info._userId.c_str()) == 0 && itr.second._streamType == info._streamType)
        {
            bFind = true;
            break;
        }
    }
    if (!bFind)
    {
        m_mapAllViews.insert(std::pair<int, VideoRenderInfo>(++nId, info));
    }

    checkPageBtnStatus();
}

int TRTCVideoViewLayout::dispatchVideoView(std::wstring userId, TRTCVideoStreamType type, bool bPKUser, int roomId)
{
    HWND dispacthHwnd = NULL;
    if (IsUserRender(userId, type))
        return -1;
    if (nHadUseCnt >= nTotalRenderWindowCnt) //已经没有渲染视频的位置了
    {
        VideoRenderInfo info = VideoRenderInfo();
        info._userId = userId;
        info._streamType = type;
        info._isLable = false;
        InsertIntoAllView(info);
        return -2;
    }

    //首先个窗口直接分配主窗口
    if (nHadUseCnt == 0)
    {
        VideoRenderInfo* info = GetMainRenderView();
        if (info != nullptr)
        {
            info->_userId = userId;
            info->_streamType = type;
            info->_isLable = false;
            if (bPKUser) info->_viewLayout->showPKIcon(true, roomId);
            info->_viewLayout->cleanViewStatus();
            info->_viewLayout->resetViewUIStatus(userId.c_str(), type);
            info->_viewLayout->SetVisible(true);
            nHadUseCnt++;
        }
        

        bool bFind = false;
        VideoRenderInfo* lableInfo = FindIdleRenderView(bFind);
        if (lableInfo != nullptr)
        {
            lableInfo->_userId = userId;
            lableInfo->_streamType = type;
            lableInfo->_isLable = true;
            lableInfo->_viewLayout->cleanViewStatus();
            lableInfo->_viewLayout->resetViewUIStatus(userId.c_str(), type);
            lableInfo->_viewLayout->SetVisible(true);
            lableInfo->_viewLayout->SetIsLable();

            InsertIntoAllView(*lableInfo);
            nHadUseCnt++;
        }
        
    }
    else if (IsMainRenderWndUse() && nHadUseCnt == 1)     //主窗口被占用,mViewLayoutStyleEnum == ViewLayoutStyle_Lecture暂定
    {
        bool bFind = false;
        VideoRenderInfo* minInfo = FindIdleRenderView(bFind);
        if (minInfo != nullptr)
        {
            minInfo->_userId = userId;
            minInfo->_streamType = type;
            minInfo->_isLable = false;
            if (bFind == false)
            {
                InsertIntoAllView(*minInfo);
                return -3;
            }

            InsertIntoAllView(*minInfo);
            if (bPKUser) minInfo->_viewLayout->showPKIcon(true, roomId);
            minInfo->_viewLayout->resetViewUIStatus(userId.c_str(), type);
            minInfo->_viewLayout->SetVisible(true);
            nHadUseCnt++;
        }
    }
    else
    {
        bool bFind = false;
        VideoRenderInfo* info = FindIdleRenderView(bFind);
        if (info != nullptr)
        {
            info->_userId = userId;
            info->_streamType = type;
            info->_isLable = false;
            if (bFind == false) {
                InsertIntoAllView(*info);
                return -4;
            }

            InsertIntoAllView(*info);
            info->_viewLayout->cleanViewStatus();
            if (bPKUser) info->_viewLayout->showPKIcon(true, roomId);
            info->_viewLayout->resetViewUIStatus(userId.c_str(), type);
            info->_viewLayout->SetVisible(true);
            nHadUseCnt++;
        }
    }

    updateLectureview();

    if (type == TRTCVideoStreamTypeSub)
    {
        DoubleClickView(userId, type);
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
    int delCnt = 0;

    int index = 0;
    bool needUpdate = false;
    int curMaxIndex = (nCurrentPage + 1) * MAX_VIEW_PER_PAGE + 1;
    //调整窗口
    for (auto itr = m_mapAllViews.begin(); itr != m_mapAllViews.end();)
    {
        if (_tcsicmp(itr->second._userId.c_str(), userId.c_str()) == 0 && itr->second._streamType == type)
        {
            if (index++ <= curMaxIndex)
            {
                needUpdate = true;
            }
            m_mapAllViews.erase(itr++);
        }
        else
        {
            itr++;
        }
    }

    for (auto &itr : m_mapLectureView)
    {
        if (_tcsicmp(itr.second._userId.c_str(), userId.c_str()) == 0 && itr.second._streamType == type)
        {
            itr.second._userId = L"";
            itr.second._viewLayout->resetViewUIStatus(itr.second._userId.c_str(), itr.second._streamType);
            itr.second._isLable = false;
            itr.second._viewLayout->SetVisible(false);
            nHadUseCnt--;
            ++delCnt;
            bDel = true;
        }
    }
    if (bDel == false)
    {
        checkPageBtnStatus();
        return bDel;
    }

    AdjustViewDispatch(m_mapLectureView, delCnt);

    if (delCnt == 2)
    {
        bool bFindMain = false;
        VideoRenderInfo* mainInfo = FindFitMainRenderView(bFindMain);
        if (bFindMain && mainInfo != nullptr)
        {
            bool bFind = false;
            VideoRenderInfo* lableInfo = FindIdleRenderView(bFind);
            if (bFind && lableInfo != nullptr)
            {
                lableInfo->_userId = mainInfo->_userId;
                lableInfo->_streamType = mainInfo->_streamType;
                lableInfo->_isLable = true;
                lableInfo->_viewLayout->cleanViewStatus();
                lableInfo->_viewLayout->resetViewUIStatus(mainInfo->_userId, mainInfo->_streamType);
                lableInfo->_viewLayout->SetVisible(true);
                lableInfo->_viewLayout->SetIsLable();

                ++nHadUseCnt;
            }
        }
    }
    if (needUpdate)
    {
        turnPage(true, needUpdate);
    }
   
    checkPageBtnStatus();

    //调整布局渲染区域
    updateLectureview();
    return bDel;
}

bool TRTCVideoViewLayout::IsRemoteViewShow(std::wstring userId, TRTCVideoStreamType type)
{
    bool bFind = false;
    FindRenderView(userId, type, false, bFind);
    return bFind;
}

void TRTCVideoViewLayout::HideAllVideoViewExceptMain()
{
    for (auto &itr : m_mapLectureView)
    {
        if (itr.second._viewLayout->isMainView())
        {
            continue;
        }
        itr.second._viewLayout->SetVisible(false);
           
    }
    lecture_change_remote_visible->SetVisible(false);
    m_pForward->SetVisible(false);
    m_pBackword->SetVisible(false);
}

void TRTCVideoViewLayout::RestoreAllVideoView()
{
    for (auto &itr : m_mapLectureView)
    {
        if (itr.second._viewLayout->getUserId() == L"")
        {
            continue;
        }
       
        itr.second._viewLayout->SetVisible(true);
    }
    lecture_change_remote_visible->SetVisible(true);
    m_pForward->SetVisible(true);
    m_pBackword->SetVisible(true);
}

bool TRTCVideoViewLayout::SwapVideoView(std::wstring userIdA, std::wstring userIdB, TRTCVideoStreamType typeA, TRTCVideoStreamType typeB)
{
    // A-待切换到主窗口的窗口
    bool bFindA = false;
    VideoRenderInfo* minInfoA = FindRenderView(userIdA, typeA, false, bFindA);
    if (bFindA == false || minInfoA == nullptr)
        return NULL;

    // B-主窗口
    bool bFindB = false;
    VideoRenderInfo* minInfoB = FindRenderView(userIdB, typeB, false, bFindB);
    if (bFindB == false || minInfoB == nullptr)
        return NULL;

    //BLable-主窗口B的右侧展位
    bool bFindBLable = false;
    VideoRenderInfo* minInfoBLable = FindRenderView(userIdB, typeB, true, bFindBLable);
    if (bFindBLable == false || minInfoBLable == nullptr)
        return NULL;

    minInfoA->_viewLayout->resetViewUIStatus(L"");
    minInfoB->_viewLayout->resetViewUIStatus(L"");
    minInfoBLable->_viewLayout->resetViewUIStatus(L"");

    // A-B切换
    VideoCanvasContainer::switchCanvasAttribute(minInfoA->_viewLayout, minInfoB->_viewLayout);
    TRTCVideoViewLayout::switchVideoRenderInfo(*minInfoA, *minInfoB);

    //BL-A切换
    VideoCanvasContainer::switchCanvasAttribute(minInfoA->_viewLayout, minInfoBLable->_viewLayout);
    TRTCVideoViewLayout::switchVideoRenderInfo(*minInfoA, *minInfoBLable);

    minInfoA->_userId = minInfoB->_userId;
    minInfoA->_streamType = typeA;
    minInfoA->_viewLayout->resetViewUIStatus(minInfoB->_userId.c_str(), minInfoB->_streamType);
    minInfoB->_viewLayout->resetViewUIStatus(minInfoB->_userId.c_str(), minInfoB->_streamType);
    minInfoBLable->_viewLayout->resetViewUIStatus(minInfoBLable->_userId.c_str(), minInfoBLable->_streamType);

    minInfoA->_viewLayout->SetIsLable();
    return true;
}

bool TRTCVideoViewLayout::muteAudio(std::wstring userId, TRTCVideoStreamType type, bool bMute)
{
    bool bFind = false;
    VideoRenderInfo* info = FindRenderView(userId, type, false, bFind);
    if (bFind == false || info == nullptr)
        return false;
    if (info->_viewLayout)
    {
        info->_viewLayout->muteAudio(bMute);
    }
    return true;
}

bool TRTCVideoViewLayout::muteVideo(std::wstring userId, TRTCVideoStreamType type, bool bMute)
{
    bool bFind = false;
    VideoRenderInfo* info = FindRenderView(userId, type, false, bFind);
    if (bFind == false || info == nullptr)
        return false;
    if (info->_viewLayout)
    {
        info->_viewLayout->muteVideo(bMute);
    }
    return true;
}

void TRTCVideoViewLayout::updateVoiceVolume(std::wstring userId, int volume)
{
    //设置所有view的音量回归初始状态。
    if (userId.compare(L"") == 0)
    {
        for (auto &itr : m_mapLectureView)
        {
            itr.second._viewLayout->updateVoiceVolume(volume);
        }
    }
    else
    {
        for (auto &itr : m_mapLectureView)
        {
            if (_tcsicmp(itr.second._userId.c_str(), userId.c_str()) == 0 && itr.second._streamType == TRTCVideoStreamTypeBig)
            {
                itr.second._viewLayout->updateVoiceVolume(volume);
            }
        }
    }
}

void TRTCVideoViewLayout::updateNetSignal(std::wstring userId, int quality)
{
    for (auto &itr : m_mapLectureView)
    {
        if (_tcsicmp(itr.second._userId.c_str(), userId.c_str()) == 0)
        {
            itr.second._viewLayout->updateNetSignal(quality);
        }
    }
}

void TRTCVideoViewLayout::AdjustViewDispatch(std::map<std::wstring, VideoRenderInfo>& mapView, int delCnt)
{
    //主要从新把占用窗口，按 1、2、3、4、5排序
    int index = 0;
    for (auto &itr1 : mapView)
    {
        index++;
        if (_tcsicmp(itr1.second._userId.c_str(), L"") == 0)
        {
            int i = index;
            for (auto &itr2 : mapView)
            {
                if (i > 0)
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
                    if (itr1.second._isLable)
                    {
                        itr1.second._viewLayout->SetIsLable();
                    }

                    itr2.second._isLable = false;
                    itr2.second.clean();
                    itr2.second._viewLayout->cleanViewStatus();
                    itr2.second._viewLayout->SetVisible(false);
                    --delCnt;
                    break;
                }
            }
            if (delCnt == 0)
                break;
        }
    }
}

bool TRTCVideoViewLayout::IsUserRender(std::wstring userId, TRTCVideoStreamType type)
{
    for (auto &itr : m_mapLectureView)
    {
        if (_tcsicmp(itr.second._userId.c_str(), userId.c_str()) == 0 && itr.second._streamType == type)
        {
            return true;
        }
    }

    return false;
}

bool TRTCVideoViewLayout::IsMainRenderWndUse()
{
    for (auto &itr : m_mapLectureView)
    {
        if (itr.second._viewLayout->isMainView())
        {
            if (_tcsicmp(itr.second._userId.c_str(), L"") != 0)
                return true;
        }
    }

    return false;
}

TRTCVideoViewLayout::VideoRenderInfo * TRTCVideoViewLayout::FindIdleRenderView(bool& bFind)
{
    for (auto &itr : m_mapLectureView)
    {
        if (_tcsicmp(itr.second._userId.c_str(), L"") == 0)
        {
            bFind = true;
            return &itr.second;
        }
    }
    bFind = false;
   
    return nullptr;
}

TRTCVideoViewLayout::VideoRenderInfo * TRTCVideoViewLayout::FindFitMainRenderView(bool& bFind)
{
    for (auto &itr : m_mapLectureView)
    {
        if (_tcsicmp(itr.second._userId.c_str(), L"") != 0)
        {
            bFind = true;
            return &itr.second;
        }
    }
    bFind = false;

    return nullptr;
}

TRTCVideoViewLayout::VideoRenderInfo * TRTCVideoViewLayout::FindRenderView(std::wstring userId, TRTCVideoStreamType type, bool label, bool& bFind)
{
    for (auto &itr : m_mapLectureView)
    {
        if (_tcsicmp(itr.second._userId.c_str(), userId.c_str()) == 0 && itr.second._streamType == type && itr.second._isLable == label)
        {
            bFind = true;
            return &itr.second;
        }
    }
    bFind = false;

    return nullptr;
}

TRTCVideoViewLayout::VideoRenderInfo * TRTCVideoViewLayout::GetMainRenderView()
{
    for (auto &itr : m_mapLectureView)
    {
        if (itr.second._viewLayout->isMainView())
        {
            return &itr.second;
        }
    }

    return nullptr;
}

void TRTCVideoViewLayout::DoubleClickView(std::wstring userId, TRTCVideoStreamType type)
{
    bool bFind = false;
    VideoRenderInfo* mainInfo = FindFitMainRenderView(bFind);
    if (!bFind || mainInfo == nullptr)
        return;
    if (userId.compare(mainInfo->_userId) == 0 && mainInfo->_viewLayout->getVideoStreamType() == type)
        return;
    SwapVideoView(userId, mainInfo->_userId, type, mainInfo->_streamType);
}

int TRTCVideoViewLayout::GetDispatchViewCnt()
{
    return nHadUseCnt;
}

void TRTCVideoViewLayout::switchVideoRenderInfo(VideoRenderInfo & viewA, VideoRenderInfo & viewB)
{
    std::wstring tempUserIdA = viewA._userId;
    TRTCVideoStreamType tempTypeA = viewA._streamType;
    bool tempLableA = viewA._isLable;
    viewA._userId = viewB._userId;
    viewA._streamType = viewB._streamType;
    viewA._isLable = viewB._isLable;
    viewB._userId = tempUserIdA;
    viewB._streamType = tempTypeA;
    viewB._isLable = tempLableA;
}

void TRTCVideoViewLayout::updateLectureview()
{
    if (lectureview_sublayout_container1 == nullptr)
        return;

    if (!bLectureviewShow)
    {
        lectureview_sublayout_container1->GetParent()->SetFixedWidth(16);
        lectureview_sublayout_container1->SetVisible(false);
        return;
    }

    if (nHadUseCnt <= 1)
    {
        lectureview_sublayout_container1->GetParent()->SetFixedWidth(16);
        lectureview_sublayout_container1->SetVisible(false);
    }
    else
    {
        lectureview_sublayout_container1->GetParent()->SetFixedWidth(216);
        lectureview_sublayout_container1->SetVisible(true);
        VideoRenderInfo* mainInfo = GetMainRenderView();
        if (mainInfo != nullptr)
        {
            // 演讲布局List高度要取相对小的值。
            int mainViewHeight = mainInfo->_viewLayout->GetPos().bottom - mainInfo->_viewLayout->GetPos().top;
            bool bForwardVisible = m_pForward->IsVisible();
            bool bBackword = m_pBackword->IsVisible();
            int height = MIN(120 * (nHadUseCnt - 1), mainViewHeight > 0 ? mainViewHeight - 100 : 120 * (nHadUseCnt - 1)) + (bForwardVisible ? 32 : 0) + (bBackword ? 32 : 0) + (nHadUseCnt - 1) * 2;
            lectureview_sublayout_container1->SetFixedHeight(height);
            lectureview_sublayout_container1->GetParent()->SetFixedHeight(height);
        }
    }
}

void TRTCVideoViewLayout::checkPageBtnStatus()
{
    if (m_pForward == nullptr || m_pBackword == nullptr)
    {
        return;
    }
    bool bForwardVisible = m_pForward->IsVisible();
    bool bBackword = m_pBackword->IsVisible();
    int height = lectureview_sublayout_container1->GetFixedHeight();

    if (bForwardVisible && nCurrentPage < 1)
    {
        m_pForward->SetVisible(false);
        m_pForward->GetParent()->SetVisible(false);
        height -= 32;
    }
    if (!bForwardVisible && nCurrentPage > 0)
    {
        m_pForward->SetVisible(true);
        m_pForward->GetParent()->SetVisible(true);
        height += 32;
    }

    if (bBackword && (nCurrentPage + 1)* MAX_VIEW_PER_PAGE >= (m_mapAllViews.size() - 1))
    {
        m_pBackword->SetVisible(false);
        m_pBackword->GetParent()->SetVisible(false);
        height -= 32;
    }
    if (!bBackword && (nCurrentPage + 1)* MAX_VIEW_PER_PAGE < (m_mapAllViews.size() - 1))
    {
        m_pBackword->SetVisible(true);
        m_pBackword->GetParent()->SetVisible(true);
        height += 32;
    }

    lectureview_sublayout_container1->SetFixedHeight(height);
    lectureview_sublayout_container1->GetParent()->SetFixedHeight(height);
}

void TRTCVideoViewLayout::updateSize()
{
    updateLectureview();
}

void TRTCVideoViewLayout::changeLectureviewVisable()
{
    bLectureviewShow = !bLectureviewShow;
    if (bLectureviewShow)
    {
        for (auto &itr : m_mapLectureView)
        {
            if (itr.second._viewLayout->isMainView() || _tcsicmp(itr.second._userId.c_str(), L"") == 0
                || _tcsicmp(itr.second._userId.c_str(), VideoCanvasContainer::localUserId.c_str()) == 0
                || itr.second._isLable)
            {
                continue;
            }
            if (itr.second._viewLayout->getVideoStreamType() == TRTCVideoStreamTypeSub)
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->startRemoteView(Wide2UTF8(itr.second._userId).c_str(), TRTCVideoStreamTypeSub, nullptr);
            }
            else if (!itr.second._isLable)
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->startRemoteView(Wide2UTF8(itr.second._userId).c_str(), CDataCenter::GetInstance()->getRemoteVideoStreamType(), NULL);
            }
        }

        lecture_change_remote_visible->SetForeImage(L"source='16,0,32,32' res='videoview/lecture.png'");
    }
    else
    {
        for (auto &itr : m_mapLectureView)
        {
            if (itr.second._viewLayout->isMainView() || _tcsicmp(itr.second._userId.c_str(), L"") == 0
                || _tcsicmp(itr.second._userId.c_str(), VideoCanvasContainer::localUserId.c_str()) == 0
                || itr.second._isLable)
            {
                continue;
            }
            if (itr.second._viewLayout->getVideoStreamType() == TRTCVideoStreamTypeSub)
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopRemoteView(Wide2UTF8(itr.second._userId).c_str(), TRTCVideoStreamTypeSub);
            }
            else
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopRemoteView(Wide2UTF8(itr.second._userId).c_str(), TRTCVideoStreamTypeBig);
            }
        }
        lecture_change_remote_visible->SetForeImage(L"source='0,0,16,32' res='videoview/lecture.png'");
    }
    updateLectureview();
}

bool TRTCVideoViewLayout::turnPage(bool forward, bool adjustCurrent)
{
    if (!adjustCurrent)
    {
        if (forward && nCurrentPage < 1)
        {
            return false;
        }
        if (!forward && (nCurrentPage + 1)* MAX_VIEW_PER_PAGE >= (m_mapAllViews.size() - 1))
        {
            return false;
        }

        nCurrentPage = forward ? (nCurrentPage - 1) : (nCurrentPage + 1);
    }

    int minIndex = nCurrentPage * MAX_VIEW_PER_PAGE;
    int maxIndex = (nCurrentPage + 1) * MAX_VIEW_PER_PAGE - 1;
    int index = 0;
    std::wstring mainUserId = L"";
    TRTCVideoStreamType mainStreamType = TRTCVideoStreamTypeBig;

    for (auto &itr1 : m_mapLectureView)
    {
        if (itr1.second._viewLayout->isMainView() || itr1.second._isLable == true)
        {
            mainUserId = itr1.second._userId;
            mainStreamType = itr1.second._streamType;
            continue;
        }

        if (_tcsicmp(itr1.second._userId.c_str(), L"") != 0)
        {
            if (itr1.second._streamType == TRTCVideoStreamTypeSub)
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopRemoteView(Wide2UTF8(itr1.second._userId).c_str(), TRTCVideoStreamTypeSub);
            }
            else
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopRemoteView(Wide2UTF8(itr1.second._userId).c_str(), TRTCVideoStreamTypeBig);
            }

            itr1.second._userId = L"";
            itr1.second._viewLayout->cleanViewStatus();
            itr1.second._viewLayout->resetViewUIStatus(itr1.second._userId.c_str(), itr1.second._streamType);
            itr1.second._isLable = false;
            itr1.second._viewLayout->SetVisible(false);
            nHadUseCnt--;
        }
    }

    for (auto &itr2 : m_mapAllViews)
    {
        if (_tcsicmp(itr2.second._userId.c_str(), mainUserId.c_str()) == 0 && itr2.second._streamType == mainStreamType)
        {
            ++index;
            ++minIndex;
            ++maxIndex;
            continue;
        }
        if (index < minIndex)
        {
            ++index;
            continue;
        }
        if (index > maxIndex)
        {
            break;
        }

        ++index;

        for (auto &itr1 : m_mapLectureView)
        {
            if (_tcsicmp(itr1.second._userId.c_str(), L"") == 0)
            {
                itr1.second._userId = itr2.second._userId;
                itr1.second._streamType = itr2.second._streamType;
                itr1.second._viewLayout->cleanViewStatus();
                itr1.second._viewLayout->resetViewUIStatus(itr2.second._userId, itr2.second._streamType);
                itr1.second._viewLayout->muteAudio(!CDataCenter::GetInstance()->getAudioAvaliable(Wide2UTF8(itr1.second._userId)));
                itr1.second._viewLayout->muteVideo(!CDataCenter::GetInstance()->getVideoAvaliable(Wide2UTF8(itr1.second._userId), itr1.second._streamType));
                itr1.second._viewLayout->SetVisible(true);

                ++nHadUseCnt;

                if (itr2.second._streamType == TRTCVideoStreamTypeSub)
                {
                    TRTCCloudCore::GetInstance()->getTRTCCloud()->startRemoteView(Wide2UTF8(itr2.second._userId).c_str(), TRTCVideoStreamTypeSub, NULL);
                }
                else
                {
                    TRTCCloudCore::GetInstance()->getTRTCCloud()->startRemoteView(Wide2UTF8(itr2.second._userId).c_str(), CDataCenter::GetInstance()->getRemoteVideoStreamType(), NULL);
                }
                break;
            }

        }

        ++minIndex;
        continue;
    }
    checkPageBtnStatus();
    updateLectureview();
    return true;
}
