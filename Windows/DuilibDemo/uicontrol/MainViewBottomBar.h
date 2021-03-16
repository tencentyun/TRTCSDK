#pragma once
/**
* Module:   MainViewBottomBar @ liteav
*
* Author:   kmais @ 2018/10/1
*
* Function: 主窗口Bottom的工具条
*
* Modify: 创建 by kmais @ 2018/10/1
*
*/
#include <memory>
#include <TRTCCloudDef.h>
#include "UIlib.h"
using namespace DuiLib;

class TRTCMainViewController;
class TRTCSettingViewController;
class AudioEffectViewController;
class AudioEffectOldViewController;
class VodPlayerViewController;
class MainViewBottomBar : public INotifyUI, public IMessageFilterUI {
public:
    MainViewBottomBar(TRTCMainViewController * pMainWnd = nullptr);
    ~MainViewBottomBar();
public:
    void InitBottomUI();
    void UnInitBottomUI();
protected:
    virtual void Notify(TNotifyUI& msg);
    virtual LRESULT MessageHandler(UINT uMsg, WPARAM wParam, LPARAM lParam, bool& bHandled);
protected:
    void RefreshVideoDevice();
    void RefreshAudioDevice();
    void onBtnMemberClick();
public:
    void muteLocalVideoBtn(bool bMute);
    void muteLocalAudioBtn(bool bMute);
    void onClickMuteVideoBtn();
    void onClickMuteAudioBtn();

    void OpenScreenBtnEvent(TRTCScreenCaptureSourceInfo &source, RECT & rect, TRTCScreenCaptureProperty & property);

    bool onPKUserLeaveRoom(std::string userId);
    bool onPKUserEnterRoom(std::string userId, uint32_t& roomId);
    void onConnectOtherRoom(int errCode, std::string errMsg);
    void onDisconnectOtherRoom(int errCode, std::string errMsg);
private:
    void OpenAudioEffectWnd();
    void OpenVodPlayerWnd();
private:
    TRTCSettingViewController* m_pSettingWnd = nullptr;
    TRTCMainViewController *m_pMainWnd = nullptr;

    AudioEffectViewController *m_pAudioEffectWnd = nullptr;
    AudioEffectOldViewController *m_pAudioEffectOldWnd = nullptr;

    VodPlayerViewController *m_pVodPlayerViewWnd = nullptr;

    bool m_bPlay = false;
    bool m_bShowLectureModeUi = false;
    int m_showDashboardStyle = 0;
    bool m_bShowMemberWnd = false;

    std::wstring m_pkUserId;
    std::wstring m_pkRoomId;
};