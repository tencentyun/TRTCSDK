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

#include "StdAfx.h"
#include "resource.h"
#include "TRTCScreenShareToolWnd.h"
#include "UserMassegeIdDefine.h"
#include <mutex>
#include "util/log.h"
#include "MsgBoxWnd.h"
#include <windows.h>
#include "util/Base.h"


int TRTCShareScreenToolWnd::m_ref = 0;
TRTCShareScreenToolWnd::TRTCShareScreenToolWnd()
{
    m_ref++;
}

TRTCShareScreenToolWnd::~TRTCShareScreenToolWnd()
{
    m_ref--;
}


DuiLib::CControlUI* TRTCShareScreenToolWnd::CreateControl(LPCTSTR pstrClass)
{
    return nullptr;
}

void TRTCShareScreenToolWnd::initUI()
{
    SetIcon(IDR_MAINFRAME);
    m_pLableTips = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("screenshare_userinfo_tip")));
}

int TRTCShareScreenToolWnd::getRef()
{
    return m_ref;
}

void TRTCShareScreenToolWnd::setParentHwnd(HWND pHwnd)
{
    m_mainHwnd = pHwnd;
}

void TRTCShareScreenToolWnd::setUserId(std::string userId)
{
    if (m_pLableTips)
    {
        CDuiString strFormat;
        strFormat.Format(L"%s 正在屏幕共享", UTF82Wide(userId).c_str());
        m_pLableTips->SetText(strFormat.GetData());
    }
}

void TRTCShareScreenToolWnd::OnFinalMessage(HWND hWnd)
{
     delete this;
}

LRESULT TRTCShareScreenToolWnd::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    if (uMsg == WM_CREATE) {
        m_pmUI.Init(m_hWnd);
        CDialogBuilder builder;
        CControlUI* pRoot = builder.Create(_T("trtc_screentoolwnd.xml"), (UINT)0, this, &m_pmUI);
        ASSERT(pRoot && "Failed to parse XML");
        m_pmUI.AttachDialog(pRoot);
        m_pmUI.AddNotifier(this); 
        initUI();
        return 0;
    }
    else if (uMsg == WM_NCACTIVATE)
    {
        if (!::IsIconic(*this)) return (wParam == 0) ? TRUE : FALSE;
    }
    LRESULT lRes = 0;
    if (m_pmUI.MessageHandler(uMsg, wParam, lParam, lRes))
        return lRes;
    return CWindowWnd::HandleMessage(uMsg, wParam, lParam);
}

TRTCShareScreenToolMgr* TRTCShareScreenToolMgr::m_instance = nullptr; 
static std::mutex screen_mex;

TRTCShareScreenToolMgr::TRTCShareScreenToolMgr()
{
}

TRTCShareScreenToolMgr::~TRTCShareScreenToolMgr()
{
}

TRTCShareScreenToolMgr * TRTCShareScreenToolMgr::GetInstance()
{
    if (m_instance == NULL) {
        screen_mex.lock();
        if (m_instance == NULL)
        {
            m_instance = new TRTCShareScreenToolMgr();
        }
        screen_mex.unlock();
    }
    return m_instance;
}

void TRTCShareScreenToolMgr::Destory()
{
    screen_mex.lock();
    if (m_instance)
    {
        delete m_instance;
        m_instance = nullptr;
    }
    screen_mex.unlock();
}

void TRTCShareScreenToolMgr::createToolWnd(std::string userId)
{
    if (TRTCShareScreenToolWnd::getRef() <= 0)
        _pView = nullptr;

    if (_pView == nullptr)
    {
        _pView = new TRTCShareScreenToolWnd();
        _pView->Create(NULL, _T("TRTCScreenShareTool"), WS_VISIBLE | WS_POPUP | WS_THICKFRAME | WS_CLIPCHILDREN | WS_CLIPSIBLINGS | WS_SYSMENU, WS_EX_PALETTEWINDOW | WS_EX_CLIENTEDGE);
        
        RECT rect;
        //取桌面
        rect.left = 0;
        rect.top = 0;
        rect.right = rect.left + GetSystemMetrics(SM_CXSCREEN); //获取最大化窗体的显示区域宽度
        rect.bottom = rect.top + GetSystemMetrics(SM_CYSCREEN); //获取最大化窗体的显示区域高度

        RECT rcDlg = { 0 };
        ::GetWindowRect(_pView->GetHWND(), &rcDlg);

        int tip_width = rcDlg.right - rcDlg.left;
        int tip_height = rcDlg.bottom - rcDlg.top;
        
        int xLeft = (rect.right - rect.left) / 2 - tip_width / 2;
        int yTop = rect.left;

        ::SetWindowPos(_pView->GetHWND(), NULL, xLeft, yTop, -1, -1, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);

        _pView->setUserId(userId);
        _pView->ShowWindow(true);
    }
}

void TRTCShareScreenToolMgr::destroyToolWnd()
{
    if (_pView && TRTCShareScreenToolWnd::getRef() > 0)
        _pView->Close(ID_CLOSE_WINDOW_NO_QUIT_MSGLOOP);
    _pView = nullptr;
}

