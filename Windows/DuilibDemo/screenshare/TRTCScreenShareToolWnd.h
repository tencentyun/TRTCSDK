/*
* Module:   TRTCScreenVideoView
*
* Function: 该界面用户屏幕分享画面的渲染。
*
* Notice:
*
*  （1）采用真窗口渲染模型，无法在渲染窗口上叠加UI控件。
*/
#pragma once
#include <string>
#include "UIlib.h"
using namespace DuiLib;

class TRTCShareScreenToolWnd
    : public CWindowWnd
    , public INotifyUI
    , public IDialogBuilderCallback
{
public: //virture
    TRTCShareScreenToolWnd();
    ~TRTCShareScreenToolWnd();
public: //overwrite
    virtual LPCTSTR GetWindowClassName() const { return _T("TRTCDuilibDemo_ScreenShareToolWnd"); };
    virtual UINT GetClassStyle() const { return /*UI_CLASSSTYLE_FRAME |*/ CS_DBLCLKS; };
    virtual void OnFinalMessage(HWND hWnd);
    virtual LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);
public: //cb
    virtual void Notify(TNotifyUI& msg) {};
    virtual CControlUI* CreateControl(LPCTSTR pstrClass);
public:
    void initUI();
    static int getRef();
    void setParentHwnd(HWND pHwnd);
    void setUserId(std::string userId);
public:
    CPaintManagerUI m_pmUI;
    HWND m_mainHwnd = nullptr;
    static int m_ref;

    CLabelUI* m_pLableTips = nullptr;
};

class TRTCShareScreenToolMgr
{
public:
    TRTCShareScreenToolMgr();
    ~TRTCShareScreenToolMgr();
    static TRTCShareScreenToolMgr* GetInstance();
    void Destory();

public:
    void createToolWnd(std::string userId);
    void destroyToolWnd();
private:
    static TRTCShareScreenToolMgr* m_instance;
    TRTCShareScreenToolWnd *_pView;
};





