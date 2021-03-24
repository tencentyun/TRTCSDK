/*
* Module:   UserListController
*
* Function: 主窗口的成员列表区域，显示当前房间所有成员。
*
*/

#pragma once
#include "UserItem.h"
#include "UIlib.h"
using namespace DuiLib;

class TRTCMainViewController;
class UserListController : public INotifyUI
{
public:
    UserListController(TRTCMainViewController * pMainWnd = nullptr);
    ~UserListController();
public:
    void InitUserListUI();
    void UnInitUserListUI();
    void AddUser(std::string userId);
    void RemoveUser(std::string userId);
    void UpdateUserInfo(RemoteUserInfo& info);
    void UpdateUserInfo(LocalUserInfo& info);
    bool AudioAllMuted();
    bool VideoAllMuted();

   protected:
    virtual void Notify(TNotifyUI& msg);
private:
    void MuteAllAudio();
    void MuteAllVideo();
private:
    TRTCMainViewController *m_pMainWnd = nullptr;

    std::map<std::string, UsertItem*> m_mapUserLists; // uid/UsertItem
    CLabelUI* m_pUserCounts = nullptr;
    CButtonUI* m_pMuteAllVideo = nullptr;
    CButtonUI* m_pMuteAllAudio = nullptr;
    CTileLayoutUI* m_pUserListLayout;
    bool m_bAudioAllMuted = false;
    bool m_bVideoAllMuted = false;
};

