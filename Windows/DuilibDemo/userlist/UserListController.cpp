#include "UserListController.h"
#include "TRTCMainViewController.h"
#include "UserMassegeIdDefine.h"
#include "TRTCVideoViewLayout.h"
#include "util/Base.h"

UserListController::UserListController(TRTCMainViewController * pMainWnd)
{
    m_pMainWnd = pMainWnd;
}

UserListController::~UserListController()
{
    m_pMainWnd->getPaintManagerUI().RemoveNotifier(this);
}

void UserListController::InitUserListUI()
{
    m_pMainWnd->getPaintManagerUI().AddNotifier(this);

    m_pUserListLayout = static_cast<CTileLayoutUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("user_layout_body")));
    m_pUserCounts = static_cast<CLabelUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("label_user_counts")));
    m_pMuteAllVideo = static_cast<CButtonUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("btn_mute_video_all")));
    m_pMuteAllAudio = static_cast<CButtonUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("btn_mute_audio_all")));
    m_pUserListLayout->GetVerticalScrollBar()->SetFixedWidth(2);
}

void UserListController::UnInitUserListUI()
{
    m_pMainWnd->getPaintManagerUI().RemoveNotifier(this);
}

void UserListController::AddUser(std::string userId)
{
    if (m_mapUserLists.find(userId) == m_mapUserLists.end())
    {
        CDuiString strFormat;
        UsertItem* pItem = new UsertItem(m_pMainWnd->GetHWND());
        CHorizontalLayoutUI* pUI = pItem->CreateControl(&m_pMainWnd->getPaintManagerUI());
        pUI->SetFixedWidth(320);
        pUI->SetFixedHeight(30);
        m_pMainWnd->getPaintManagerUI().AddNotifier(pItem);
        m_pUserCounts->SetText(strFormat);

        if (CDataCenter::GetInstance()->getLocalUserID().compare(userId) == 0)
        {
            LocalUserInfo& info = CDataCenter::GetInstance()->getLocalUserInfo();
            pItem->SetUserInfo(info);
        }
        else
        {
            RemoteUserInfo* info = CDataCenter::GetInstance()->FindRemoteUser(userId);
            if (info != nullptr)
            {
                pItem->SetUserInfo(*info);
            }
        }
        m_pUserListLayout->Add(pUI);
        m_mapUserLists.insert(std::pair<std::string, UsertItem*>(userId, pItem));
        strFormat.Format(L"成员(%d人)", m_mapUserLists.size());
        m_pUserCounts->SetText(strFormat);
    }
}

void UserListController::RemoveUser(std::string userId)
{
    auto it = m_mapUserLists.find(userId);
    if (it != m_mapUserLists.end())
    {
        m_pUserListLayout->Remove(it->second->GetControl());
        m_pMainWnd->getPaintManagerUI().RemoveNotifier(it->second);
        delete it->second;
        m_mapUserLists.erase(it);
    }

    CDuiString strFormat;
    strFormat.Format(L"成员(%d人)", m_mapUserLists.size());
    m_pUserCounts->SetText(strFormat);
}

void UserListController::UpdateUserInfo(RemoteUserInfo & info)
{
    auto iter = m_mapUserLists.find(info.user_id);
    if (iter != m_mapUserLists.end())
    {
        iter->second->SetUserInfo(info);
    }
}

void UserListController::UpdateUserInfo(LocalUserInfo& info)
{
    auto iter = m_mapUserLists.find(info._userId);
    if (iter != m_mapUserLists.end())
    {
        iter->second->SetUserInfo(info);
    }
}

bool UserListController::AudioAllMuted() {
    return m_bAudioAllMuted;
}

bool UserListController::VideoAllMuted() {
    return m_bVideoAllMuted;
}

void UserListController::Notify(TNotifyUI & msg)
{
    if (msg.sType == _T("click"))
    {
        if (msg.pSender->GetName() == _T("btn_mute_audio_all"))
        {
            this->MuteAllAudio();
        }
        else  if (msg.pSender->GetName() == _T("btn_mute_video_all"))
        {
            this->MuteAllVideo();
        }
    }
}

void UserListController::MuteAllAudio()
{
    m_bAudioAllMuted = !m_bAudioAllMuted;
    if (m_bAudioAllMuted)
    {
        m_pMuteAllAudio->SetText(L"取消静音");
    }
    else
    {
        m_pMuteAllAudio->SetText(L"全部禁音");
    }

    for (auto &itr : m_mapUserLists)
    {
        std::string userId = itr.first;
        if (userId.compare(CDataCenter::GetInstance()->getLocalUserID()) != 0)
        {
            RemoteUserInfo* info = CDataCenter::GetInstance()->FindRemoteUser(userId);
            if (info != nullptr)
            {
                if ((m_bAudioAllMuted && info->subscribe_audio) ||
                    (!m_bAudioAllMuted && !info->subscribe_audio))
                {
                    HWND _hwnd = m_pMainWnd->GetHWND();
                    UI_EVENT_MSG *msg = new UI_EVENT_MSG;
                    msg->_id = UI_EVENT_MSG::UI_BTNMSG_ID_MuteAudio;
                    msg->_userId = UTF82Wide(itr.first);
                    msg->_streamType = TRTCVideoStreamTypeBig;
                    ::PostMessage(_hwnd, WM_USER_VIEW_BTN_CLICK, (WPARAM)msg, 0);
                }
            }
        }
    }
}

void UserListController::MuteAllVideo()
{
    m_bVideoAllMuted = !m_bVideoAllMuted;
    if (m_bVideoAllMuted)
    {
        m_pMuteAllVideo->SetText(L"取消禁画");
    }
    else
    {
        m_pMuteAllVideo->SetText(L"全部禁画");
    }
    for (auto &itr : m_mapUserLists)
    {
        std::string userId = itr.first;
        if (userId.compare(CDataCenter::GetInstance()->getLocalUserID()) != 0)
        {
            RemoteUserInfo* info = CDataCenter::GetInstance()->FindRemoteUser(userId);
            if (info != nullptr)
            {
                if ((m_bVideoAllMuted && info->subscribe_main_video) \
                    || (!m_bVideoAllMuted && !(info->subscribe_main_video)))
                {
                    HWND _hwnd = m_pMainWnd->GetHWND();
                    UI_EVENT_MSG *msg = new UI_EVENT_MSG;
                    msg->_id = UI_EVENT_MSG::UI_BTNMSG_ID_MuteVideo;
                    msg->_userId = UTF82Wide(itr.first);
                    msg->_streamType = TRTCVideoStreamTypeBig;
                    ::PostMessage(_hwnd, WM_USER_VIEW_BTN_CLICK, (WPARAM)msg, 0);
                }
                if ((m_bVideoAllMuted && info->subscribe_sub_video)    \
                    || (!m_bVideoAllMuted && !(info->subscribe_sub_video)))
                {
                    HWND _hwnd = m_pMainWnd->GetHWND();
                    UI_EVENT_MSG *msg = new UI_EVENT_MSG;
                    msg->_id = UI_EVENT_MSG::UI_BTNMSG_ID_MuteVideo;
                    msg->_userId = UTF82Wide(itr.first);
                    msg->_streamType = TRTCVideoStreamTypeSub;
                    ::PostMessage(_hwnd, WM_USER_VIEW_BTN_CLICK, (WPARAM)msg, 0);
                }
            }
        }
    }
}
