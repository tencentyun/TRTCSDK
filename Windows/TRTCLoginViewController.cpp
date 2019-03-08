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
#include "TRTCGetUserIDAndUserSig.h"
#include "TRTCMainViewController.h"
#include "Base.h"
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
    m_userIdCombo.SetFont(&newFont);
    // 设置此对话框的图标。  当应用程序主窗口不是对话框时，框架将自动
    // 执行此操作
    //SetIcon(m_hIcon, TRUE);         // 设置大图标
    //SetIcon(m_hIcon, FALSE);        // 设置小图标

    bool ret = TRTCGetUserIDAndUserSig::instance().loadFromConfig();
    if (!ret)
    {
        CWnd *pEnterRoomBtn = GetDlgItem(IDC_ENTER_ROOM);
        pEnterRoomBtn->EnableWindow(FALSE);
        MessageBoxW(L"解析Config.json失败", L"错误", MB_OK);
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

    std::vector<UserInfo> userInfos = TRTCGetUserIDAndUserSig::instance().getConfigUserIdArray();
    if (userInfos.empty())
        return FALSE;

    int userCnt = userInfos.size();
    for (int i = 0; i < userCnt; i++)
    {
        UserInfo info = userInfos[i];
        m_userIdCombo.AddString(UTF82Wide(info.userId).c_str());
    }
    m_userIdCombo.SetCurSel(0);

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
    DDX_Control(pDX, IDC_COMBO_USERLIST, m_userIdCombo);
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
    // TODO: 在此添加控件通知处理程序代码
    if (m_pTRTCMainViewController == nullptr)
    {
        m_pTRTCMainViewController = new TRTCMainViewController(this);
        m_pTRTCMainViewController->Create(IDD_TESTTRTCAPP_DIALOG, this);
        m_pTRTCMainViewController->ShowWindow(SW_SHOW);
    }

    // 从控制台获取的 json 文件中，简单获取几组已经提前计算好的 userid 和 usersig
    std::vector<UserInfo> userInfos = TRTCGetUserIDAndUserSig::instance().getConfigUserIdArray();
    if (userInfos.empty())
    {   
        //也可以通过 http 协议向一台服务器获取 userid 对应的 usersig
        //示例：TRTCGetUserIDAndUserSig::instance().getUserSigFromServer();
        return;
    }
    int selIndex = m_userIdCombo.GetCurSel();
    if (selIndex >= 0 && selIndex < userInfos.size())
    {
        UserInfo info = userInfos[selIndex];   // 登录第一个用户
        std::string privateMapKey = "";
        TRTCParams params;
        params.sdkAppId = TRTCGetUserIDAndUserSig::instance().getConfigSdkAppId();
        params.roomId = roomId;//std::to_string(roomId).c_str();
        params.userId = info.userId.c_str();
        params.userSig = info.userSig.c_str();
        params.privateMapKey = privateMapKey.c_str();

        m_pTRTCMainViewController->enterRoom(params);

        ShowWindow(SW_HIDE);
    }
    else
    {
        MessageBoxW(L"选择用户出错！", L"错误", MB_OK);
    }
}


void TRTCLoginViewController::OnBnClickedEnterRoom()
{
    wchar_t buffer[256] = { 0 };
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
        delete m_pTRTCMainViewController;
        m_pTRTCMainViewController = nullptr;
    }

    SetForegroundWindow();
    return LRESULT();
}

