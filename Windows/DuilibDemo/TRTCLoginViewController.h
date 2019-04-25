/*
* Module:   TRTCLoginViewController
*
* Function: 该界面可以让用户输入一个【房间号】和一个【用户名】
*
* Notice:
*
*  （1）房间号为数字类型，用户名为字符串类型
*
*  （2）在真实的使用场景中，房间号大多不是用户手动输入的，而是系统分配的，
*       比如视频会议中的会议号是会控系统提前预定好的，客服系统中的房间号也是根据客服员工的工号决定的。
*/
#pragma once
#include <string>

class TRTCSettingViewController;
class TRTCLoginViewController
    : public CWindowWnd
    , public INotifyUI
    , public IDialogBuilderCallback
{
public: //virture
    TRTCLoginViewController();
public: //overwrite
    virtual LPCTSTR GetWindowClassName() const { return _T("TRTCDuilibDemo_Login"); };
    virtual UINT GetClassStyle() const { return /*UI_CLASSSTYLE_FRAME |*/ CS_DBLCLKS; };
    virtual void OnFinalMessage(HWND hWnd);
    virtual LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);
public: //cb
    virtual void Notify(TNotifyUI& msg);
    virtual CControlUI* CreateControl(LPCTSTR pstrClass);
private:
    void InitLoginView();
    bool isTestEnv();
protected:
    void onBtnOpenSetting();
    void onBtnEnterRoom();
public:
    TRTCSettingViewController* m_pSettingWnd = nullptr;
    CPaintManagerUI m_pmUI;
    CLabelUI* m_pLoginStatus = nullptr;
    bool m_bConfigUserSign = false;
    bool m_bQuit= true;
};