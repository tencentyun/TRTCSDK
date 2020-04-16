#include "stdafx.h"
#include "UserItem.h"
#include "util/Base.h"
#include "TRTCVideoViewLayout.h"
#include "UserMassegeIdDefine.h"
#include "DataCenter.h"

UsertItem::UsertItem(HWND hwnd)
{
    m_pHWnd = hwnd;
}

UsertItem::~UsertItem()
{
}

CHorizontalLayoutUI* UsertItem::CreateControl(CPaintManagerUI* pManager)
{
    CDialogBuilder builer;
    m_pRootControl = static_cast<CHorizontalLayoutUI*>(builer.Create(_T("useritem.xml"), NULL, NULL, pManager));
    m_pUserIdLabel = static_cast<CLabelUI*>(m_pRootControl->GetItemAt(0));
    m_pAudioBtn = static_cast<CButtonUI*>(m_pRootControl->GetItemAt(1));
    m_pVideoBtn = static_cast<CButtonUI*>(m_pRootControl->GetItemAt(2));

    return m_pRootControl;
}

CHorizontalLayoutUI * UsertItem::GetControl()
{
    return m_pRootControl;
}

void UsertItem::SetUserInfo(const RemoteUserInfo& info)
{
    m_user_id = info.user_id;
    m_available_main_video = info.available_main_video;
    m_subscribe_main_video = info.subscribe_main_video;
    m_available_audio = info.available_audio;
    m_subscribe_audio = info.subscribe_audio;

    this->UpdateUI();
}

void UsertItem::SetUserInfo(const LocalUserInfo & info)
{
    m_user_id = info._userId;
    m_available_main_video = info.publish_main_video;
    m_subscribe_main_video = true;
    m_available_audio = info.publish_audio;
    m_subscribe_audio = true;

    this->UpdateUI();
}

void UsertItem::UpdateUI()
{
    bool isLocal = false;
    CDuiString strLabelTxt;

    if (CDataCenter::GetInstance()->getLocalUserID().compare(m_user_id) == 0)
    {
        isLocal = true;
        strLabelTxt.Format(L"%s（我）", UTF82Wide(m_user_id).c_str());
    }
    else
    {
        strLabelTxt = UTF82Wide(m_user_id).c_str();
    }

    m_pUserIdLabel->SetText(strLabelTxt);

    if (m_available_audio && m_subscribe_audio)
    {
        m_pAudioBtn->SetForeImage(L"dest='24,4,50,30' source='0,0,70,70' res='userlist/sound.png'");
    }
    else
    {
        m_pAudioBtn->SetForeImage(L"dest='24,4,50,30' source='0,0,70,70' res='userlist/sound_dis.png'");
    }
    m_pAudioBtn->SetEnabled(isLocal || m_available_audio);

    if (m_available_main_video && m_subscribe_main_video)
    {
        m_pVideoBtn->SetForeImage(L"dest='24,4,50,30' source='0,0,70,70' res='userlist/camera_nol.png'");
    }
    else
    {
        m_pVideoBtn->SetForeImage(L"dest='24,4,50,30' source='0,0,70,70' res='userlist/camera_dis.png'");
    }
    m_pVideoBtn->SetEnabled(isLocal || m_available_main_video);
}

void UsertItem::Notify(TNotifyUI & msg)
{
    if (msg.sType == _T("click"))
    {
        if (msg.pSender == m_pAudioBtn)
        {
            UI_EVENT_MSG *msg = new UI_EVENT_MSG;
            msg->_id = UI_EVENT_MSG::UI_BTNMSG_ID_MuteAudio;
            msg->_userId = UTF82Wide(m_user_id);
            msg->_streamType = TRTCVideoStreamTypeBig;
            ::PostMessage(m_pHWnd, WM_USER_VIEW_BTN_CLICK, (WPARAM)msg, 0);
        }
        else if (msg.pSender == m_pVideoBtn)
        {
            UI_EVENT_MSG *msg = new UI_EVENT_MSG;
            msg->_id = UI_EVENT_MSG::UI_BTNMSG_ID_MuteVideo;
            msg->_userId = UTF82Wide(m_user_id);
            msg->_streamType = TRTCVideoStreamTypeBig;
            ::PostMessage(m_pHWnd, WM_USER_VIEW_BTN_CLICK, (WPARAM)msg, 0);
        }
    }
}

bool UsertItem::GetVideoAvailable()
{
    return m_available_main_video && m_subscribe_main_video;
}

bool UsertItem::GetAudioAvailable()
{
    return m_available_audio && m_subscribe_audio;
}

