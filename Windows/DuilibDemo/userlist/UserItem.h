/*
* Module:   UsertItem
*
* Function: 成员项
*
*/

#pragma once
#include "UIlib.h"
#include "DataCenter.h"
using namespace DuiLib;

class UsertItem : public INotifyUI
{
public:
    UsertItem(HWND hwnd);
    ~UsertItem();

    CHorizontalLayoutUI* CreateControl(CPaintManagerUI* pManager);
    CHorizontalLayoutUI* GetControl();
    void SetUserInfo(const RemoteUserInfo& info);
    void SetUserInfo(const LocalUserInfo& info);
    virtual void Notify(TNotifyUI& msg);
    bool GetVideoAvailable();
    bool GetAudioAvailable();
protected:
    void UpdateUI();
private:
    HWND m_pHWnd;
    CHorizontalLayoutUI*    m_pRootControl = nullptr;
    CLabelUI* m_pUserIdLabel = nullptr;
    CButtonUI* m_pAudioBtn = nullptr;
    CButtonUI* m_pVideoBtn = nullptr;
    std::string m_user_id = "";
    bool m_available_main_video = false;
    bool m_subscribe_main_video = false;
    bool m_available_audio = false;
    bool m_subscribe_audio = false;
};

