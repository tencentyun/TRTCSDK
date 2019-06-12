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
    UpdateRemoteViewInfo(IDC_REMOTE_VIDEO_VIEW1, "");
    UpdateRemoteViewInfo(IDC_REMOTE_VIDEO_VIEW2, "");
    UpdateRemoteViewInfo(IDC_REMOTE_VIDEO_VIEW3, "");
    UpdateRemoteViewInfo(IDC_REMOTE_VIDEO_VIEW4, "");
    UpdateRemoteViewInfo(IDC_REMOTE_VIDEO_VIEW5, "");
    UpdateRemoteViewInfo(IDC_REMOTE_VIDEO_VIEW6, "");
    UpdateRemoteViewInfo(IDC_REMOTE_VIDEO_VIEW7, "");
    UpdateRemoteViewInfo(IDC_REMOTE_VIDEO_VIEW8, "");

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

void TRTCMainViewController::onEnterRoom(uint64_t elapsed)
{
    CWnd *pLocalVideoView = GetDlgItem(IDC_LOCAL_VIDEO_VIEW);
    HWND hwnd = pLocalVideoView->GetSafeHwnd();
    getTRTCCloud()->setLocalViewFillMode(TRTCVideoFillMode_Fit);
    getTRTCCloud()->startLocalPreview(hwnd);
    getTRTCCloud()->startLocalAudio();

    CWnd *pStatic = GetDlgItem(IDC_STATIC_LOCAL_USERID);
    pStatic->SetWindowTextW(UTF82Wide(m_userId).c_str());
    pStatic->SetFont(&newFont);
}

void TRTCMainViewController::onExitRoom(int reason)
{
    getTRTCCloud()->removeCallback(this);
    getTRTCCloud()->stopLocalPreview();
    getTRTCCloud()->stopAllRemoteView();

    CWnd *pStatic = GetDlgItem(IDC_STATIC_LOCAL_USERID);
    pStatic->SetWindowTextW(L"");

    UpdateRemoteViewInfo(IDC_REMOTE_VIDEO_VIEW1, "");
    UpdateRemoteViewInfo(IDC_REMOTE_VIDEO_VIEW2, "");
    UpdateRemoteViewInfo(IDC_REMOTE_VIDEO_VIEW3, "");
    UpdateRemoteViewInfo(IDC_REMOTE_VIDEO_VIEW4, "");
    UpdateRemoteViewInfo(IDC_REMOTE_VIDEO_VIEW5, "");
    UpdateRemoteViewInfo(IDC_REMOTE_VIDEO_VIEW6, "");
    UpdateRemoteViewInfo(IDC_REMOTE_VIDEO_VIEW7, "");
    UpdateRemoteViewInfo(IDC_REMOTE_VIDEO_VIEW8, "");

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
    int viewId = FindIdleRemoteVideoView();
    if (viewId != 0)
    {
        UpdateRemoteViewInfo(viewId, userId);
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
    int viewId = FindOccupyRemoteVideoView(userId);

    if (viewId != 0)
    {
        getTRTCCloud()->stopRemoteView(userId);
        UpdateRemoteViewInfo(viewId, "");
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
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_BORD8)
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

            rect.InflateRect(-3, -7, -3, -3);
            pDC->FillRect(rect, &brh);//填充Groupbox矩形背景色
            return (HBRUSH)brh.m_hObject;//返回Groupbox背景画刷绘制画刷
        }

        if (pWnd->GetDlgCtrlID() == IDC_STATIC_LOCAL_USERID ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_USERID1 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_USERID2 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_USERID3 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_USERID4 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_USERID5 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_USERID6 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_USERID7 ||
            pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_USERID8)
        {
            static CBrush brh(RGB(210, 210, 210));//静态画刷资源
            CRect rect;
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_LOCAL_USERID)
                GetDlgItem(IDC_STATIC_LOCAL_USERID)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_USERID1)
                GetDlgItem(IDC_STATIC_REMOTE_USERID1)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_USERID2)
                GetDlgItem(IDC_STATIC_REMOTE_USERID2)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_USERID3)
                GetDlgItem(IDC_STATIC_REMOTE_USERID3)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_USERID4)
                GetDlgItem(IDC_STATIC_REMOTE_USERID4)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_USERID5)
                GetDlgItem(IDC_STATIC_REMOTE_USERID5)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_USERID6)
                GetDlgItem(IDC_STATIC_REMOTE_USERID6)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_USERID7)
                GetDlgItem(IDC_STATIC_REMOTE_USERID7)->GetClientRect(rect);
            if (pWnd->GetDlgCtrlID() == IDC_STATIC_REMOTE_USERID8)
                GetDlgItem(IDC_STATIC_REMOTE_USERID8)->GetClientRect(rect);

            pDC->FillRect(rect, &brh);//填充Groupbox矩形背景色
            pDC->SetBkMode(TRANSPARENT);
            return (HBRUSH)brh.m_hObject;//返回Groupbox背景画刷绘制画刷
        }
    }
    return hbr;
}

int TRTCMainViewController::FindIdleRemoteVideoView()
{
    if (m_remoteUserInfo[IDC_REMOTE_VIDEO_VIEW1].compare("") == 0)
    {
        return IDC_REMOTE_VIDEO_VIEW1;
    }
    if (m_remoteUserInfo[IDC_REMOTE_VIDEO_VIEW2].compare("") == 0)
    {
        return IDC_REMOTE_VIDEO_VIEW2;
    }
    if (m_remoteUserInfo[IDC_REMOTE_VIDEO_VIEW3].compare("") == 0)
    {
        return IDC_REMOTE_VIDEO_VIEW3;
    }
    if (m_remoteUserInfo[IDC_REMOTE_VIDEO_VIEW4].compare("") == 0)
    {
        return IDC_REMOTE_VIDEO_VIEW4;
    }
    if (m_remoteUserInfo[IDC_REMOTE_VIDEO_VIEW5].compare("") == 0)
    {
        return IDC_REMOTE_VIDEO_VIEW5;
    }
    if (m_remoteUserInfo[IDC_REMOTE_VIDEO_VIEW6].compare("") == 0)
    {
        return IDC_REMOTE_VIDEO_VIEW6;
    }
    if (m_remoteUserInfo[IDC_REMOTE_VIDEO_VIEW7].compare("") == 0)
    {
        return IDC_REMOTE_VIDEO_VIEW7;
    }
    if (m_remoteUserInfo[IDC_REMOTE_VIDEO_VIEW8].compare("") == 0)
    {
        return IDC_REMOTE_VIDEO_VIEW8;
    }
    return 0;
}

int TRTCMainViewController::FindOccupyRemoteVideoView(std::string userId)
{
    if (m_remoteUserInfo[IDC_REMOTE_VIDEO_VIEW1].compare(userId.c_str()) == 0)
    {
        return IDC_REMOTE_VIDEO_VIEW1;
    }
    if (m_remoteUserInfo[IDC_REMOTE_VIDEO_VIEW2].compare(userId.c_str()) == 0)
    {
        return IDC_REMOTE_VIDEO_VIEW2;
    }
    if (m_remoteUserInfo[IDC_REMOTE_VIDEO_VIEW3].compare(userId.c_str()) == 0)
    {
        return IDC_REMOTE_VIDEO_VIEW3;
    }
    if (m_remoteUserInfo[IDC_REMOTE_VIDEO_VIEW4].compare(userId.c_str()) == 0)
    {
        return IDC_REMOTE_VIDEO_VIEW4;
    }
    if (m_remoteUserInfo[IDC_REMOTE_VIDEO_VIEW5].compare(userId.c_str()) == 0)
    {
        return IDC_REMOTE_VIDEO_VIEW5;
    }
    if (m_remoteUserInfo[IDC_REMOTE_VIDEO_VIEW6].compare(userId.c_str()) == 0)
    {
        return IDC_REMOTE_VIDEO_VIEW6;
    }
    if (m_remoteUserInfo[IDC_REMOTE_VIDEO_VIEW7].compare(userId.c_str()) == 0)
    {
        return IDC_REMOTE_VIDEO_VIEW7;
    }
    if (m_remoteUserInfo[IDC_REMOTE_VIDEO_VIEW8].compare(userId.c_str()) == 0)
    {
        return IDC_REMOTE_VIDEO_VIEW8;
    }
    return 0;
}

void TRTCMainViewController::UpdateRemoteViewInfo(int id, std::string userId)
{
    if (id == IDC_REMOTE_VIDEO_VIEW1)
    {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID1);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        m_remoteUserInfo[id] = userId;
    }
    if (id == IDC_REMOTE_VIDEO_VIEW2)
    {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID2);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        m_remoteUserInfo[id] = userId;
    }
    if (id == IDC_REMOTE_VIDEO_VIEW3)
    {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID3);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        m_remoteUserInfo[id] = userId;
    }
    if (id == IDC_REMOTE_VIDEO_VIEW4)
    {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID4);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        m_remoteUserInfo[id] = userId;
    }
    if (id == IDC_REMOTE_VIDEO_VIEW5)
    {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID5);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        m_remoteUserInfo[id] = userId;
    }
    if (id == IDC_REMOTE_VIDEO_VIEW6)
    {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID6);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        m_remoteUserInfo[id] = userId;
    }
    if (id == IDC_REMOTE_VIDEO_VIEW7)
    {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID7);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        m_remoteUserInfo[id] = userId;
    }
    if (id == IDC_REMOTE_VIDEO_VIEW8)
    {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_REMOTE_USERID8);
        pStatic->SetWindowTextW(UTF82Wide(userId).c_str());
        pStatic->SetFont(&newFont);
        m_remoteUserInfo[id] = userId;
    }
}

LRESULT TRTCMainViewController::OnMsgSettingViewClose(WPARAM wParam, LPARAM lParam)
{
    if (m_pTRTCSettingViewController != nullptr)
    {
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
