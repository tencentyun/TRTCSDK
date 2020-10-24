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
#include "TRTCLoginViewController.h"
#include "DataCenter.h"
#include "TRTCCloudCore.h"
#include "TRTCMainViewController.h"
#include "TRTCSettingViewController.h"
#include "GenerateTestUserSig.h"
#include "TRTCCustomerCrypt.h"
#include "util/Base.h"
#include "util/log.h"
#include "json/json.h"
#include "util/md5.h"
#include "MsgBoxWnd.h"
#include <strstream>
#include <cstdint>
#include <iomanip>

TRTCLoginViewController::TRTCLoginViewController()
{

}

void TRTCLoginViewController::Notify(TNotifyUI & msg)
{
    if (msg.sType == _T("click"))
    {
        if (msg.pSender->GetName() == _T("btn_enterroom"))
        {
            onBtnEnterRoom();
        }
        else if (msg.pSender->GetName() == _T("btn_setting"))
        {
            onBtnOpenSetting();
        }
    }

    CDuiString name = msg.pSender->GetName();
    if (msg.sType == _T("selectchanged"))
    {
        if (name.CompareNoCase(_T("test_netenv")) == 0) {
            CDataCenter::GetInstance()->m_nLinkTestServer = 1;
        }
        else if (name.CompareNoCase(_T("pretest_netenv")) == 0) {
            CDataCenter::GetInstance()->m_nLinkTestServer = 2;
        }
        else if (name.CompareNoCase(_T("product_netenv")) == 0) {
            CDataCenter::GetInstance()->m_nLinkTestServer = 0;
        }
    }
}

DuiLib::CControlUI* TRTCLoginViewController::CreateControl(LPCTSTR pstrClass)
{
    return nullptr;
}

void TRTCLoginViewController::InitLoginView()
{
    SetIcon(IDR_MAINFRAME);
    LocalUserInfo loginData = CDataCenter::GetInstance()->getLocalUserInfo();
    std::string user_id = loginData._userId;

    CEditUI* pEditName = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_nameid")));
    if (pEditName != nullptr)
        pEditName->SetText(UTF82Wide(user_id).c_str());

    if (loginData._roomId > 0)
    {
        int roomId = loginData._roomId;
        char string_num[32];
        itoa(roomId, string_num, 10);
        std::string strRoomId = string_num;
        CEditUI* pEditRoomId = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_roomid")));
        if (pEditRoomId != nullptr)
            pEditRoomId->SetText(UTF82Wide(strRoomId).c_str());
    }

    CDataCenter::GetInstance()->m_bOpenDemoTestConfig = isTestEnv();

    m_pLoginStatus = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_loginstatus")));
    m_pmUI.SetFocus(nullptr);

    //初始化房间基础配置信息
    if(CDataCenter::GetInstance()->m_bOpenDemoTestConfig)
    {
        int nLinkTestServer = CDataCenter::GetInstance()->m_nLinkTestServer;
        COptionUI* pTestNetEnv = static_cast<COptionUI*>(m_pmUI.FindControl(_T("test_netenv")));
        COptionUI* pPreTestNetEnv = static_cast<COptionUI*>(m_pmUI.FindControl(_T("pretest_netenv")));
        COptionUI* pProductNetEnv = static_cast<COptionUI*>(m_pmUI.FindControl(_T("product_netenv")));
        if (pTestNetEnv && pProductNetEnv && pPreTestNetEnv) {
            pTestNetEnv->Selected(false);
            pPreTestNetEnv->Selected(false);
            pProductNetEnv->Selected(false);
            if (nLinkTestServer == 1)
                pTestNetEnv->Selected(true);
            else if (nLinkTestServer == 2)
                pPreTestNetEnv->Selected(true);
            else
                pProductNetEnv->Selected(true);
        }
        RECT rc = { 0 };
        if (::GetClientRect(m_hWnd, &rc))
        {
            rc.bottom += (36 + 50);
            if (!::AdjustWindowRectEx(&rc, GetWindowStyle(m_hWnd), (!(GetWindowStyle(m_hWnd) & WS_CHILD) && (::GetMenu(m_hWnd) != NULL)), GetWindowExStyle(m_hWnd))) return;
            ::SetWindowPos(m_hWnd, NULL, rc.left, rc.right, rc.right - rc.left, rc.bottom - rc.top, SWP_NOZORDER | SWP_NOMOVE | SWP_NOACTIVATE);
        }

        CHorizontalLayoutUI* pTestNetEnvContainer = static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("test_netenv_container")));
        if (pTestNetEnvContainer)
            pTestNetEnvContainer->SetVisible(true);
        CHorizontalLayoutUI* pTestCallContainer = static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("test_call_container")));
        if (pTestCallContainer)
            pTestCallContainer->SetVisible(true);
        CHorizontalLayoutUI* pTestModeContainer = static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("test_mode_container")));
        if (pTestModeContainer)
            pTestModeContainer->SetVisible(true);
        CEditUI* pCryptKeyContainer =
            static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_cryptkey")));
        if (pCryptKeyContainer) pCryptKeyContainer->SetVisible(true);
    }
}

void TRTCLoginViewController::onBtnOpenSetting()
{
    //先检查是否填写了 sdkappid ,只有填写了sdkappid才可以正常使用TRTCDuilibDemo信息。
    if (GenerateTestUserSig::SDKAPPID == 0)
    {
        CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"), _T("Error: 请先在 TRTCGetUserIDAndUserSig::TXCloudAccountInfo 填写 sdkappid 信息"), 0xFFF08080);
        return;
    }

    if (m_pSettingWnd) {
        if (TRTCSettingViewController::getRef() > 0)
            m_pSettingWnd->Close(ID_CLOSE_WINDOW_NO_QUIT_MSGLOOP);
        m_pSettingWnd = nullptr;
    }
    m_pSettingWnd = new TRTCSettingViewController(TRTCSettingViewController::SettingTag_Video, GetHWND());
    m_pSettingWnd->Create(GetHWND(), _T("TRTCDuilibDemo"), WS_VISIBLE | WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU, WS_EX_WINDOWEDGE);
    m_pSettingWnd->CenterWindow();
    m_pSettingWnd->ShowWindow(true);
}

void TRTCLoginViewController::onBtnEnterRoom()
{
    //先检查是否填写了 sdkappid ,只有填写了sdkappid才可以正常使用TRTCDuilibDemo信息。
    if (GenerateTestUserSig::SDKAPPID== 0)
    {
        CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"), _T("Error: 请先在 TRTCGetUserIDAndUserSig::TXCloudAccountInfo 填写 sdkappid 信息"), 0xFFF08080);
        return;
    }

    CEditUI* pEditEnctyptKey = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_cryptkey")));
    if (pEditEnctyptKey != nullptr)
    {
        std::wstring wstrKey = pEditEnctyptKey->GetText();
        TRTCCustomerCrypt::setEncryptKey(Wide2UTF8(wstrKey));
    }
    else {
        TRTCCustomerCrypt::setEncryptKey("");
    }


    CEditUI* pEditRoomID = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_roomid")));
    LocalUserInfo& info = CDataCenter::GetInstance()->getLocalUserInfo();
    if (pEditRoomID != nullptr)
    {
        std::wstring strRoomId = pEditRoomID->GetText();
        if (strRoomId.compare(L"") == 0)
        {
            if (m_pLoginStatus != nullptr)
                m_pLoginStatus->SetText(L"房间号不能为空");
            return;
        }
        info._roomId = _wtoi(strRoomId.c_str());
    }

    CEditUI* pEditName = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_nameid")));
    if (pEditName != nullptr)
    {
        std::wstring strUserId = pEditName->GetText();
        if (strUserId.compare(L"") == 0)
        {
            if (m_pLoginStatus != nullptr)
                m_pLoginStatus->SetText(L"用户不能为空");
            return;
        }
        info._userId = Wide2UTF8(strUserId);
    }

    info._userSig = GenerateTestUserSig::instance().genTestUserSig(info._userId);

    if (info._userSig == "")
    {
        if (m_pLoginStatus != nullptr)
            m_pLoginStatus->SetText(L"user sign 获取失败");
        return;
    }

    if (m_pSettingWnd) {
        if (TRTCSettingViewController::getRef() > 0)
            m_pSettingWnd->Close(ID_CLOSE_WINDOW_NO_QUIT_MSGLOOP);
        m_pSettingWnd = nullptr;
    }

    TRTCMainViewController* pFrame = new TRTCMainViewController();
    if (pFrame == NULL)
        return;
    CDuiString strFormat;
    if (CDataCenter::GetInstance()->m_nLinkTestServer == 1)
    {
        strFormat.Format(L"TRTCDuilibDemo 【房间ID: %d, 用户ID: %s】【测试环境】", info._roomId, UTF82Wide(info._userId).c_str());
    }
    else if (CDataCenter::GetInstance()->m_nLinkTestServer == 2)
    {
        strFormat.Format(L"TRTCDuilibDemo 【房间ID: %d, 用户ID: %s】【体验环境】", info._roomId, UTF82Wide(info._userId).c_str());
    }
    else
    {
        strFormat.Format(L"TRTCDuilibDemo 【房间ID: %d, 用户ID: %s】【正式环境】", info._roomId, UTF82Wide(info._userId).c_str());
    }

    pFrame->Create(NULL, strFormat.GetData(), UI_WNDSTYLE_FRAME | WS_CLIPCHILDREN, WS_EX_WINDOWEDGE);
    pFrame->CenterWindow();
    pFrame->ShowWindow(true); 
    Close(ID_CLOSE_WINDOW_NO_QUIT_MSGLOOP);
}

bool TRTCLoginViewController::isTestEnv()
{
    WCHAR fileBuffer[MAX_PATH] = { 0 };

    ::GetModuleFileNameW(NULL, fileBuffer, MAX_PATH);

    std::wstring path(fileBuffer);
    if (path.size() > 0)
    {
        int pos = path.find_last_of('\\', path.length());
        std::wstring fileDir = path.substr(0, pos);  // Return the directory without the file name   
        fileDir += L"\\ShowTestEnv.txt";

        if ((_waccess(fileDir.c_str(), 0)) != -1)
        {
            return true;
        }
    }
    
    return false;
}

void TRTCLoginViewController::OnFinalMessage(HWND hWnd)
{
     delete this;
}

LRESULT TRTCLoginViewController::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    if (uMsg == WM_CREATE) {
        m_pmUI.Init(m_hWnd);
        CDialogBuilder builder;
        CControlUI* pRoot = builder.Create(_T("trtc_login.xml"), (UINT)0, this, &m_pmUI);
        ASSERT(pRoot && "Failed to parse XML");
        m_pmUI.AttachDialog(pRoot);
        m_pmUI.AddNotifier(this);

        InitLoginView();
        return 0;
    }
    else if (uMsg == WM_CLOSE) {
        if (wParam == ID_CLOSE_WINDOW_NO_QUIT_MSGLOOP)
            m_bQuit = false;
        else {
            LINFO(L"CTRTCLoginWnd:: App quit begin");
            if(m_pSettingWnd) {
                if (TRTCSettingViewController::getRef() > 0) {
                    if (::IsWindow(m_pSettingWnd->GetHWND())) {
                        ::SendMessage(m_pSettingWnd->GetHWND(),WM_CLOSE,(WPARAM)ID_CLOSE_WINDOW_NO_QUIT_MSGLOOP,0L);
                    }
                }
                m_pSettingWnd = nullptr;
            }
            m_bQuit = true;
        }
    }
    else if (uMsg == WM_DESTROY) {
        if (m_bQuit)
            ::PostQuitMessage(0L);
    }
    else if (uMsg == WM_NCACTIVATE) {
        if (!::IsIconic(*this)) return (wParam == 0) ? TRUE : FALSE;
    }
    LRESULT lRes = 0;
    if (m_pmUI.MessageHandler(uMsg, wParam, lParam, lRes))
        return lRes;
    return CWindowWnd::HandleMessage(uMsg, wParam, lParam);
}
