/*
* Module:   TRTCMainViewController
*
* Function: 使用TRTC SDK完成 1v1 和 1vn 的视频通话功能
*
*    1. 支持九宫格平铺和前后叠加两种不同的视频画面布局方式，该部分由 TRTCVideoViewLayout 
*       来计算每个视频画面的位置排布和大小尺寸(window暂未实现九宫格布局)
*
*    2. 支持对视频通话的分辨率、帧率和流畅模式进行调整，该部分由 TRTCSettingViewController 来实现
*
*    3. 创建或者加入某一个通话房间，需要先指定 roomid 和 userid，这部分由 TRTCNewViewController 来实现
*/

#include "stdafx.h"
#include "afxdialogex.h"
#include "TRTCDemo.h"
#include "util/Base.h"
#include "StorageConfigMgr.h"
#include "TRTCMainViewController.h"
#include "TRTCSettingViewController.h"

#include <ctime>
#include <cstdio>

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

ITRTCCloud* getTRTCCloud()
{
    if (TRTCMainViewController::g_cloud == nullptr)
    {
        TRTCMainViewController::g_cloud = getTRTCShareInstance();
    }
    return TRTCMainViewController::g_cloud;
}

void destroyTRTCCloud()
{
    if (TRTCMainViewController::g_cloud != nullptr)
        destroyTRTCShareInstance();
    TRTCMainViewController::g_cloud = nullptr;
}

ITRTCCloud* TRTCMainViewController::g_cloud = nullptr;

// CTRTCDemoDlg 对话框

TRTCMainViewController::TRTCMainViewController(CWnd* pParent /*=NULL*/)
    : CDialogEx(IDD_TESTTRTCAPP_DIALOG, pParent)
{
    m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void TRTCMainViewController::DoDataExchange(CDataExchange* pDX)
{
    CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(TRTCMainViewController, CDialogEx)
    ON_WM_CLOSE(OnClose)
    ON_MESSAGE(WM_CUSTOM_CLOSE_SETTINGVIEW, OnMsgSettingViewClose)
    ON_BN_CLICKED(IDC_EXIT_ROOM, &TRTCMainViewController::OnBnClickedExitRoom)
    ON_BN_CLICKED(IDC_BTN_SETTING, &TRTCMainViewController::OnBnClickedSetting)
    ON_BN_CLICKED(IDC_BTN_LOG, &TRTCMainViewController::OnBnClickedLog)
    ON_BN_CLICKED(IDC_BTN_SWAP, &TRTCMainViewController::OnBnClickedSwapRenderView)
    ON_WM_CTLCOLOR()
END_MESSAGE_MAP()
/*
* 初始化界面控件，包括主要的视频显示View，以及底部的一排功能按钮
*/
BOOL TRTCMainViewController::OnInitDialog()
{
    CDialogEx::OnInitDialog();
    newFont.CreatePointFont(120, L"微软雅黑");

    CWnd *pBtnSetting = GetDlgItem(IDC_BTN_SETTING);
    pBtnSetting->SetFont(&newFont);

    CWnd *pBtnExit = GetDlgItem(IDC_EXIT_ROOM);
    pBtnExit->SetFont(&newFont);

    // 设置此对话框的图标。  当应用程序主窗口不是对话框时，框架将自动
    // 执行此操作
    SetIcon(m_hIcon, TRUE);         // 设置大图标
    SetIcon(m_hIcon, FALSE);        // 设置小图标

    getTRTCCloud()->addCallback(this);

    // TODO: 在此添加额外的初始化代码
    UpdateVideoViewInfo(IDC_LOCAL_VIDEO_VIEW, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW1, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW2, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW3, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW4, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW5, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW6, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW7, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW8, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW9, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW10, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW11, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW12, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW13, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW14, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW15, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW16, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW17, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW18, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW19, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW20, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW21, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW22, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW23, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW24, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW25, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW26, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW27, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW28, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW29, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW30, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW31, "");

    ShowWindow(SW_NORMAL);

    CRect rtDesk, rtDlg;
    ::GetWindowRect(::GetDesktopWindow(), &rtDesk);
    GetWindowRect(&rtDlg);
    int iXPos = rtDesk.Width() / 2 - rtDlg.Width() / 2;
    int iYPos = rtDesk.Height() / 2 - rtDlg.Height() / 2;
    SetWindowPos(NULL, iXPos, iYPos, 0, 0, SWP_NOOWNERZORDER | SWP_NOSIZE | SWP_NOZORDER);
    return TRUE;  // 除非将焦点设置到控件，否则返回 TRUE
}

void TRTCMainViewController::onError(TXLiteAVError errCode, const char* errMsg, void* arg)
{

}

void TRTCMainViewController::onWarning(TXLiteAVWarning warningCode, const char* warningMsg, void* arg)
{

}

void TRTCMainViewController::onEnterRoom(int result)
{
    if (result >= 0)
    {
        int viewId = FindIdleVideoView();
        if (viewId != 0) {
            UpdateVideoViewInfo(viewId, m_userId);
            CWnd *pRemoteVideoView = GetDlgItem(viewId);
            HWND hwnd = pRemoteVideoView->GetSafeHwnd();
            getTRTCCloud()->setLocalViewFillMode(TRTCVideoFillMode_Fit);
            getTRTCCloud()->setLocalVideoRenderCallback(TRTCVideoPixelFormat_BGRA32, TRTCVideoBufferType_Buffer, this);
            getTRTCCloud()->startLocalPreview(hwnd);
            getTRTCCloud()->startLocalAudio();
        }
        else {
            // no find view to render remote video
        }
    }
    else
    {
        // to do enterRoom error
    }
}

void TRTCMainViewController::onExitRoom(int reason)
{
    getTRTCCloud()->setLocalVideoRenderCallback(TRTCVideoPixelFormat_Unknown, TRTCVideoBufferType_Buffer, nullptr);
    getTRTCCloud()->removeCallback(this);
    getTRTCCloud()->stopLocalPreview();
    getTRTCCloud()->stopAllRemoteView();

    CWnd *pStatic = GetDlgItem(IDC_STATIC_LOCAL_USERID);
    pStatic->SetWindowTextW(L"");
    UpdateVideoViewInfo(IDC_LOCAL_VIDEO_VIEW, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW1, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW2, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW3, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW4, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW5, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW6, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW7, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW8, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW9, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW10, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW11, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW12, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW13, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW14, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW15, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW16, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW17, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW18, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW19, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW20, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW21, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW22, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW23, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW24, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW25, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW26, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW27, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW28, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW29, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW30, "");
    UpdateVideoViewInfo(IDC_REMOTE_VIDEO_VIEW31, "");

    //切换回登录界面
    ShowWindow(SW_HIDE);
    CWnd* pWnd = GetParent();
    if (pWnd)
    {
        pWnd->ShowWindow(SW_NORMAL);
        ::PostMessage(pWnd->GetSafeHwnd(), WM_CUSTOM_CLOSE_MAINVIEW, 0, 0);
    }
}

void TRTCMainViewController::onUserEnter(const char* userId)
{
    int viewId = FindIdleVideoView();
    if (viewId != 0)
    {
        UpdateVideoViewInfo(viewId, userId);
        CWnd *pRemoteVideoView = GetDlgItem(viewId);
        HWND hwnd = pRemoteVideoView->GetSafeHwnd();
        getTRTCCloud()->setRemoteViewFillMode(userId, TRTCVideoFillMode_Fit);
        getTRTCCloud()->startRemoteView(userId, hwnd);
    }
    else
    {
        // no find view to render remote video
    }
}

void TRTCMainViewController::onUserExit(const char* userId, int reason)
{
    int viewId = FindOccupyVideoView(userId);

    if (viewId != 0)
    {
        getTRTCCloud()->stopRemoteView(userId);
        UpdateVideoViewInfo(viewId, "");
    }
}

void TRTCMainViewController::OnClose()
{
    getTRTCCloud()->exitRoom();
}

HBRUSH TRTCMainViewController::OnCtlColor(CDC * pDC, CWnd * pWnd, UINT nCtlColor)
{
    HBRUSH hbr = CDialogEx::OnCtlColor(pDC, pWnd, nCtlColor);
    if (nCtlColor == CTLCOLOR_STATIC)
    {
       
        if (pWnd->GetDlgCtrlID() == IDC_STATIC_LOCAL_BORD ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD1 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD2 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD3 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD4 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD5 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD6 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD7 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD8 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD9 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD10 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD11 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD12 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD13 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD14 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD15 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD16 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD17 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD18 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD19 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD20 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD21 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD22 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD23 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD24 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD25 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD26 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD27 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD28 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD29 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD30 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD31)
        {
            static CBrush brh(RGB(210, 210, 210));//静态画刷资源
            CRect rect;
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_LOCAL_BORD)
                GetDlgItem(IDC_STATIC_LOCAL_BORD)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD1)
                GetDlgItem(IDC_STATIC_REMOTE_BORD1)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD2)
                GetDlgItem(IDC_STATIC_REMOTE_BORD2)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD3)
                GetDlgItem(IDC_STATIC_REMOTE_BORD3)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD4)
                GetDlgItem(IDC_STATIC_REMOTE_BORD4)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD5)
                GetDlgItem(IDC_STATIC_REMOTE_BORD5)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD6)
                GetDlgItem(IDC_STATIC_REMOTE_BORD6)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD7)
                GetDlgItem(IDC_STATIC_REMOTE_BORD7)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD8)
                GetDlgItem(IDC_STATIC_REMOTE_BORD8)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD9)
                GetDlgItem(IDC_STATIC_REMOTE_BORD9)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD10)
                GetDlgItem(IDC_STATIC_REMOTE_BORD10)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD11)
                GetDlgItem(IDC_STATIC_REMOTE_BORD11)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD12)
                GetDlgItem(IDC_STATIC_REMOTE_BORD12)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD13)
                GetDlgItem(IDC_STATIC_REMOTE_BORD13)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD14)
                GetDlgItem(IDC_STATIC_REMOTE_BORD14)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD15)
                GetDlgItem(IDC_STATIC_REMOTE_BORD15)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD16)
                GetDlgItem(IDC_STATIC_REMOTE_BORD16)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD17)
                GetDlgItem(IDC_STATIC_REMOTE_BORD17)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD18)
                GetDlgItem(IDC_STATIC_REMOTE_BORD18)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD19)
                GetDlgItem(IDC_STATIC_REMOTE_BORD19)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD20)
                GetDlgItem(IDC_STATIC_REMOTE_BORD20)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD21)
                GetDlgItem(IDC_STATIC_REMOTE_BORD21)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD22)
                GetDlgItem(IDC_STATIC_REMOTE_BORD22)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD23)
                GetDlgItem(IDC_STATIC_REMOTE_BORD23)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD24)
                GetDlgItem(IDC_STATIC_REMOTE_BORD24)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD25)
                GetDlgItem(IDC_STATIC_REMOTE_BORD25)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD26)
                GetDlgItem(IDC_STATIC_REMOTE_BORD26)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD27)
                GetDlgItem(IDC_STATIC_REMOTE_BORD27)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD28)
                GetDlgItem(IDC_STATIC_REMOTE_BORD28)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD29)
                GetDlgItem(IDC_STATIC_REMOTE_BORD29)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD30)
                GetDlgItem(IDC_STATIC_REMOTE_BORD30)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD31)
                GetDlgItem(IDC_STATIC_REMOTE_BORD31)->GetClientRect(rect);

            rect.InflateRect(-3, -7, -3, -3);
            pDC->FillRect(rect, &brh);//填充Groupbox矩形背景色
            return (HBRUSH)brh.m_hObject;//返回Groupbox背景画刷绘制画刷
        }

        if (pWnd->GetDlgCtrlID() == IDC_STATIC_LOCAL_BORD ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD1 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD2 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD3 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD4 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD5 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD6 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD7 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD8 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD9 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD10 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD11 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD12 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD13 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD14 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD15 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD16 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD17 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD18 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD19 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD20 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD21 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD22 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD23 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD24 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD25 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD26 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD27 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD28 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD29 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD30 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD31)
        {
            static CBrush brh(RGB(210, 210, 210));//静态画刷资源
            CRect rect;
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_LOCAL_BORD)
                GetDlgItem(IDC_STATIC_LOCAL_BORD)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD1)
                GetDlgItem(IDC_STATIC_REMOTE_BORD1)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD2)
                GetDlgItem(IDC_STATIC_REMOTE_BORD2)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD3)
                GetDlgItem(IDC_STATIC_REMOTE_BORD3)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD4)
                GetDlgItem(IDC_STATIC_REMOTE_BORD4)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD5)
                GetDlgItem(IDC_STATIC_REMOTE_BORD5)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD6)
                GetDlgItem(IDC_STATIC_REMOTE_BORD6)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD7)
                GetDlgItem(IDC_STATIC_REMOTE_BORD7)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD8)
                GetDlgItem(IDC_STATIC_REMOTE_BORD8)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD9)
                GetDlgItem(IDC_STATIC_REMOTE_BORD9)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD10)
                GetDlgItem(IDC_STATIC_REMOTE_BORD10)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD11)
                GetDlgItem(IDC_STATIC_REMOTE_BORD11)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD12)
                GetDlgItem(IDC_STATIC_REMOTE_BORD12)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD13)
                GetDlgItem(IDC_STATIC_REMOTE_BORD13)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD14)
                GetDlgItem(IDC_STATIC_REMOTE_BORD14)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD15)
                GetDlgItem(IDC_STATIC_REMOTE_BORD15)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD16)
                GetDlgItem(IDC_STATIC_REMOTE_BORD16)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD17)
                GetDlgItem(IDC_STATIC_REMOTE_BORD17)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD18)
                GetDlgItem(IDC_STATIC_REMOTE_BORD18)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD19)
                GetDlgItem(IDC_STATIC_REMOTE_BORD19)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD20)
                GetDlgItem(IDC_STATIC_REMOTE_BORD20)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD21)
                GetDlgItem(IDC_STATIC_REMOTE_BORD21)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD22)
                GetDlgItem(IDC_STATIC_REMOTE_BORD22)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD23)
                GetDlgItem(IDC_STATIC_REMOTE_BORD23)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD24)
                GetDlgItem(IDC_STATIC_REMOTE_BORD24)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD25)
                GetDlgItem(IDC_STATIC_REMOTE_BORD25)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD26)
                GetDlgItem(IDC_STATIC_REMOTE_BORD26)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD27)
                GetDlgItem(IDC_STATIC_REMOTE_BORD27)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD28)
                GetDlgItem(IDC_STATIC_REMOTE_BORD28)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD29)
                GetDlgItem(IDC_STATIC_REMOTE_BORD29)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD30)
                GetDlgItem(IDC_STATIC_REMOTE_BORD30)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD31)
                GetDlgItem(IDC_STATIC_REMOTE_BORD31)->GetClientRect(rect);

            pDC->FillRect(rect, &brh);//填充Groupbox矩形背景色
            pDC->SetBkMode(TRANSPARENT);
            return (HBRUSH)brh.m_hObject;//返回Groupbox背景画刷绘制画刷
        }
    }
    return hbr;
}

int TRTCMainViewController::FindIdleVideoView()
{
    if (view_info_[IDC_LOCAL_VIDEO_VIEW].compare("") == 0) {
        return IDC_LOCAL_VIDEO_VIEW;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW1].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW1;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW2].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW2;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW3].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW3;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW4].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW4;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW5].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW5;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW6].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW6;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW7].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW7;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW8].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW8;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW9].compare("") == 0) 
    {
        return IDC_REMOTE_VIDEO_VIEW9;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW10].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW10;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW11].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW11;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW12].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW12;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW13].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW13;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW14].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW14;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW15].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW15;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW16].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW16;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW17].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW17;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW18].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW18;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW19].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW19;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW20].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW20;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW21].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW21;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW22].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW22;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW23].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW23;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW24].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW24;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW25].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW25;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW26].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW26;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW27].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW27;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW28].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW28;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW29].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW29;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW30].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW30;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW31].compare("") == 0) {
        return IDC_REMOTE_VIDEO_VIEW31;
    }
    return 0;
}

int TRTCMainViewController::FindOccupyVideoView(std::string userId)
{
    if (view_info_[IDC_LOCAL_VIDEO_VIEW].compare(userId.c_str()) == 0) {
        return IDC_LOCAL_VIDEO_VIEW;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW1].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW1;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW2].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW2;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW3].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW3;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW4].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW4;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW5].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW5;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW6].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW6;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW7].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW7;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW8].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW8;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW9].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW9;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW10].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW10;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW11].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW11;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW12].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW12;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW13].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW13;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW14].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW14;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW15].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW15;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW16].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW16;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW17].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW17;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW18].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW18;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW19].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW19;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW20].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW20;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW21].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW21;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW22].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW22;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW23].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW23;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW24].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW24;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW25].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW25;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW26].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW26;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW27].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW27;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW28].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW28;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW29].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW29;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW30].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW30;
    }
    if (view_info_[IDC_REMOTE_VIDEO_VIEW31].compare(userId.c_str()) == 0) {
        return IDC_REMOTE_VIDEO_VIEW31;
    }
    return 0;
}

void TRTCMainViewController::UpdateVideoViewInfo(int id, std::string userId)
{
    if (id == IDC_LOCAL_VIDEO_VIEW)  {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_LOCAL_USERID);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    }
    if (id == IDC_REMOTE_VIDEO_VIEW1) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID1);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    }
    else if (id == IDC_REMOTE_VIDEO_VIEW2) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID2);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    }
    else if (id == IDC_REMOTE_VIDEO_VIEW3) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID3);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    }
    else if (id == IDC_REMOTE_VIDEO_VIEW4) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID4);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    }
    else if (id == IDC_REMOTE_VIDEO_VIEW5) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID5);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    }
    else if (id == IDC_REMOTE_VIDEO_VIEW6) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID6);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    }
    else if (id == IDC_REMOTE_VIDEO_VIEW7) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID7);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    }
    else if (id == IDC_REMOTE_VIDEO_VIEW8) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID8);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    }
     else if (id == IDC_REMOTE_VIDEO_VIEW9) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID9);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW10) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID10);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW11) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID11);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    }
     else if (id == IDC_REMOTE_VIDEO_VIEW12) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID12);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW13) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID13);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW14) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID14);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW15) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID15);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW16) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID16);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW17) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID17);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW18) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID18);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW19) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID19);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW20) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID20);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW21) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID21);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW22) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID22);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW23) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID23);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW24) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID24);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW25) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID25);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW26) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID26);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW27) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID27);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW28) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID28);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW29) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID29);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW30) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID30);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    } 
     else if (id == IDC_REMOTE_VIDEO_VIEW31) {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID31);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        view_info_[id] = userId;
    }
}

LRESULT TRTCMainViewController::OnMsgSettingViewClose(WPARAM wParam, LPARAM lParam)
{
    if (m_pTRTCSettingViewController != nullptr) {
        delete m_pTRTCSettingViewController;
        m_pTRTCSettingViewController = nullptr;
    }
    SetForegroundWindow();
    return LRESULT();
}

/**
* 加入视频房间：需要 TRTCNewViewController 提供的  TRTCVideoEncParam 函数
*/
void TRTCMainViewController::enterRoom(TRTCParams& params)
{
    // 大画面的编码器参数设置
    // 设置视频编码参数，包括分辨率、帧率、码率等等，这些编码参数来自于 TRTCSettingViewController 的设置
    // 注意（1）：不要在码率很低的情况下设置很高的分辨率，会出现较大的马赛克
    // 注意（2）：不要设置超过25FPS以上的帧率，因为电影才使用24FPS，我们一般推荐15FPS，这样能将更多的码率分配给画质
    TRTCVideoEncParam& encParams = TRTCStorageConfigMgr::GetInstance()->videoEncParams;
    TRTCNetworkQosParam qosParams = TRTCStorageConfigMgr::GetInstance()->qosParams;
    getTRTCCloud()->setVideoEncoderParam(encParams);
    getTRTCCloud()->setNetworkQosParam(qosParams);
    
    bool m_bPushSmallVideo = TRTCStorageConfigMgr::GetInstance()->bPushSmallVideo;
    bool m_bPlaySmallVideo = TRTCStorageConfigMgr::GetInstance()->bPlaySmallVideo;


    if (m_bPushSmallVideo)
    {
        //小画面的编码器参数设置
        //TRTC SDK 支持大小两路画面的同时编码和传输，这样网速不理想的用户可以选择观看小画面
        //注意：iPhone & Android 不要开启大小双路画面，非常浪费流量，大小路画面适合 Windows 和 MAC 这样的有线网络环境
        TRTCVideoEncParam param;
        param.videoFps = 15;
        param.videoBitrate = 100;
        param.videoResolution = TRTCVideoResolution_320_240;
        getTRTCCloud()->enableSmallVideoStream(true, param);
    }
    if (m_bPlaySmallVideo)
    {
        getTRTCCloud()->setPriorRemoteVideoStreamType(TRTCVideoStreamTypeSmall);
    }

    getTRTCCloud()->enterRoom(params, TRTCStorageConfigMgr::GetInstance()->appScene);
    std::string userId(params.userId);
    m_userId = userId;
    std::wstring title = format(L"TRTCDemo【房间ID: %d, 用户ID: %s】", params.roomId, Ansi2Wide(userId.c_str()).c_str());

    SetWindowText(title.c_str());

}

void TRTCMainViewController::OnBnClickedExitRoom()
{
    getTRTCCloud()->exitRoom();
    CWnd *pExitRoomBtn = GetDlgItem(IDC_EXIT_ROOM);
    pExitRoomBtn->EnableWindow(FALSE);
}

void TRTCMainViewController::OnBnClickedSetting()
{
    if (m_pTRTCSettingViewController == nullptr)
    {
        m_pTRTCSettingViewController = new TRTCSettingViewController(this);
        m_pTRTCSettingViewController->Create(IDD_DIALOG_SETTING, this);
        m_pTRTCSettingViewController->ShowWindow(SW_SHOW);
    }
}

void TRTCMainViewController::OnBnClickedLog()
{
    m_showDebugView++;
    int style = m_showDebugView % 3;
    if (getTRTCCloud())
        getTRTCCloud()->showDebugView(style);
}

void TRTCMainViewController::OnBnClickedSwapRenderView() {

    std::string user_id1_;
    std::string user_id2_;
    int view_id1_ = 0;
    int view_id2_ = 0;
    for (auto it : view_info_) {
        if (it.second == m_userId) {
            if (user_id1_ == ""){
                user_id1_ = it.second;
                view_id1_ = it.first;
            }
            continue;
        }

        if (it.second.compare("") != 0) {
            if (user_id2_ == "") {
                user_id2_ = it.second;
                view_id2_ = it.first;
            }
            continue;
        }
    }
    if (user_id1_ == ""  || user_id2_ == "") {
        return;
    }

    CWnd *view1 = GetDlgItem(view_id1_);
    CWnd *view2 = GetDlgItem(view_id2_);
    HWND hwnd1 = view1->GetSafeHwnd();
    HWND hwnd2 = view2->GetSafeHwnd();

    getTRTCCloud()->updateLocalView(hwnd2);
    UpdateVideoViewInfo(view_id2_, user_id1_);
    
    getTRTCCloud()->updateRemoteView(user_id2_.c_str(), TRTCVideoStreamTypeBig, hwnd1);
    UpdateVideoViewInfo(view_id1_, user_id2_);
}
