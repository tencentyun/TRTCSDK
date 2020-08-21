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

#include "stdafx.h"
#include "TRTCDemo.h"
#include "afxdialogex.h"
#include "StorageConfigMgr.h"
#include "TRTCLoginViewController.h"
#include "GenerateTestUserSig.h"
#include "TRTCMainViewController.h"
#include "util/Base.h"
// TRTCLoginViewController 对话框

IMPLEMENT_DYNAMIC(TRTCLoginViewController, CDialogEx)

TRTCLoginViewController::TRTCLoginViewController(CWnd* pParent /*=NULL*/)
	: CDialogEx(IDD_DIALOG_TRTC_LOGIN, pParent)
{

}

TRTCLoginViewController::~TRTCLoginViewController()
{

}

BOOL TRTCLoginViewController::OnInitDialog()
{
    CDialogEx::OnInitDialog();
    TRTCStorageConfigMgr::GetInstance()->ReadStorageConfig();
    newFont.CreatePointFont(120, L"微软雅黑");
    // 设置此对话框的图标。  当应用程序主窗口不是对话框时，框架将自动
    // 执行此操作
    //SetIcon(m_hIcon, TRUE);         // 设置大图标
    //SetIcon(m_hIcon, FALSE);        // 设置小图标

    int sdkAppID = GenerateTestUserSig::SDKAPPID;
    if (sdkAppID == 0)
    {
        CWnd *pEnterRoomBtn = GetDlgItem(IDC_ENTER_ROOM);
        pEnterRoomBtn->EnableWindow(FALSE);
        MessageBoxW(L"你需要补齐腾讯云账号信息到 GenerateTestUserSig.h 才能运行demo.", L"错误", MB_OK);
        return FALSE;
    }

    CWnd *pStatic = GetDlgItem(IDC_STATIC_ROOM_ID);
    pStatic->SetWindowTextW(L"房间：");
    pStatic->SetFont(&newFont);

    CWnd *pEditRoomId = GetDlgItem(IDC_EDIT_ROOM_ID);
    pEditRoomId->SetWindowTextW(L"901");
    pEditRoomId->SetFont(&newFont);

    CWnd *pBtnEnterRoom = GetDlgItem(IDC_ENTER_ROOM);
    pBtnEnterRoom->SetFont(&newFont);


    CWnd *pStaticUser = GetDlgItem(IDC_STATIC_USER_ID);
    pStaticUser->SetWindowTextW(L"用户：");
    pStaticUser->SetFont(&newFont);

    CWnd *pEditUserId = GetDlgItem(IDC_EDIT_USER_ID);
    pEditUserId->SetWindowTextW(L"TRTC_TEST_USER01");
    pEditUserId->SetFont(&newFont);

    CWnd *pEnterRoomBtn = GetDlgItem(IDC_ENTER_ROOM);
    pEnterRoomBtn->EnableWindow(TRUE);

    ShowWindow(SW_NORMAL);

    CRect rtDesk, rtDlg;
    ::GetWindowRect(::GetDesktopWindow(), &rtDesk);
    GetWindowRect(&rtDlg);
    int iXPos = rtDesk.Width() / 2 - rtDlg.Width() / 2;
    int iYPos = rtDesk.Height() / 2 - rtDlg.Height() / 2;
    SetWindowPos(NULL, iXPos, iYPos, 0, 0, SWP_NOOWNERZORDER | SWP_NOSIZE | SWP_NOZORDER);
    return TRUE;  // 除非将焦点设置到控件，否则返回 TRUE
}

void TRTCLoginViewController::DoDataExchange(CDataExchange* pDX)
{
    CDialogEx::DoDataExchange(pDX);
}

void TRTCLoginViewController::OnCancel()
{
    destroyTRTCCloud();
    CDialogEx::OnCancel();
}

BEGIN_MESSAGE_MAP(TRTCLoginViewController, CDialogEx)
    ON_BN_CLICKED(IDC_ENTER_ROOM, &TRTCLoginViewController::OnBnClickedEnterRoom)
    ON_MESSAGE(WM_CUSTOM_CLOSE_MAINVIEW, OnMsgMainViewClose)
END_MESSAGE_MAP()


/**
*  Function: 读取用户输入，并创建（或加入）音视频房间
*
*  此段示例代码最主要的作用是组装 TRTC SDK 进房所需的 TRTCParams
*
*  TRTCParams.sdkAppId => 可以在腾讯云实时音视频控制台（https://console.cloud.tencent.com/rav）获取
*  TRTCParams.userId   => 此处即用户输入的用户名，它是一个字符串
*  TRTCParams.roomId   => 此处即用户输入的音视频房间号，比如 125
*  TRTCParams.userSig  => 此处示例代码展示了两种获取 usersig 的方式，一种是从【控制台】获取，一种是从【服务器】获取
*
* （1）控制台获取：可以获得几组已经生成好的 userid 和 usersig，他们会被放在一个 json 格式的配置文件中，仅适合调试使用
* （2）服务器获取：直接在服务器端用我们提供的源代码，根据 userid 实时计算 usersig，这种方式安全可靠，适合线上使用
*
*  参考文档：https://cloud.tencent.com/document/product/647/17275
*/

void TRTCLoginViewController::joinRoom(int roomId)
{
    // 从控制台获取的 json 文件中，简单获取几组已经提前计算好的 userid 和 usersig
    wchar_t buffer[MAX_PATH];
    CWnd *pEditUserID = GetDlgItem(IDC_EDIT_USER_ID);
    pEditUserID->GetWindowTextW(buffer, _countof(buffer));
    std::wstring strUserId = buffer;
    if (strUserId == L"")
    {
        MessageBoxW(L"用户ID不能为空！", L"错误", MB_OK);
        return;
    }
    std::string userId = Wide2Ansi(strUserId);

    //从本地计算法方法获取 userid 对应的 usersig
    std::string userSig = GenerateTestUserSig::instance().genTestUserSig(userId);
    if (userSig == "")
    {
        //也可以通过 http 协议向一台服务器获取 userid 对应的 usersig
        //示例：TRTCGetUserIDAndUserSig::instance().getUserSigFromServer();
        MessageBoxW(L"userSig 获取失败，请检查是否填写账号信息！", L"错误", MB_OK);
        return;
    }

    if (m_pTRTCMainViewController == nullptr)
    {
        m_pTRTCMainViewController = new TRTCMainViewController(this);
        m_pTRTCMainViewController->Create(IDD_TESTTRTCAPP_DIALOG, this);
        m_pTRTCMainViewController->ShowWindow(SW_SHOW);
    }
    
    std::string privateMapKey = "";
    TRTCParams params;
    params.sdkAppId = GenerateTestUserSig::SDKAPPID;
    params.roomId = roomId;//std::to_string(roomId).c_str();
    params.userId = userId.c_str();
    params.userSig = userSig.c_str();
    params.privateMapKey = privateMapKey.c_str();

    m_pTRTCMainViewController->enterRoom(params);

    ShowWindow(SW_HIDE);
}


void TRTCLoginViewController::OnBnClickedEnterRoom()
{
    wchar_t buffer[MAX_PATH] = { 0 };
    CWnd *pEdit = GetDlgItem(IDC_EDIT_ROOM_ID);
    pEdit->GetWindowTextW(buffer, _countof(buffer));
    std::wstring strRoomId = buffer;
    if (strRoomId.compare(L"") == 0)
    {
        MessageBoxW(L"房间号不能为空！", L"错误", MB_OK);
        return;
    }
    uint32_t roomId = 0;
    ::swscanf_s(buffer, L"%lu", &roomId);

    joinRoom(roomId);
}

LRESULT TRTCLoginViewController::OnMsgMainViewClose(WPARAM wParam, LPARAM lParam)
{
    if (m_pTRTCMainViewController != nullptr)
    {
        m_pTRTCMainViewController->DestroyWindow();
        delete m_pTRTCMainViewController;
        m_pTRTCMainViewController = nullptr;
    }

    SetForegroundWindow();
    return LRESULT();
}

