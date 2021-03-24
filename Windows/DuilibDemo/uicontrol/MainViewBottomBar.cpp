#include "StdAfx.h"
#include "MainViewBottomBar.h"
#include "TRTCMainViewController.h"
#include "TRTCVideoViewLayout.h"
#include "DataCenter.h"
#include "TRTCCloudCore.h"
#include "TRTCSettingViewController.h"
#include "UiShareSelect.h"
#include "util/Base.h"
#include "util/log.h"
#include "MsgBoxWnd.h"
#include "TXLiveAvVideoView.h"
#include "TRTCScreenShareToolWnd.h"
#include <Commdlg.h>
#include "UserMassegeIdDefine.h"
#include "AudioEffectViewController.h"
#include "AudioEffectOldViewController.h"
#include "VodPlayerViewController.h"

MainViewBottomBar::MainViewBottomBar(TRTCMainViewController * pMainWnd)
{
    m_pMainWnd = pMainWnd;
}

MainViewBottomBar::~MainViewBottomBar()
{
    m_pMainWnd->getPaintManagerUI().RemovePreMessageFilter(this);
}

void MainViewBottomBar::InitBottomUI()
{
    m_pMainWnd->getPaintManagerUI().AddPreMessageFilter(this);

   
}

void MainViewBottomBar::UnInitBottomUI()
{
    m_pMainWnd->getPaintManagerUI().RemovePreMessageFilter(this);
    TRTCShareScreenToolMgr::GetInstance()->destroyToolWnd();
}

void MainViewBottomBar::Notify(TNotifyUI& msg)
{
    if (msg.sType == _T("click"))
    {
        if (msg.pSender->GetName() == _T("btn_open_audio") && m_pMainWnd)
        {
            onClickMuteAudioBtn();
        }
        else if (msg.pSender->GetName() == _T("btn_open_video") && m_pMainWnd)
        {
            onClickMuteVideoBtn();
        }
        else if (msg.pSender->GetName() == _T("btn_open_log"))
        {
            m_showDashboardStyle++;
            int style = m_showDashboardStyle % 3;
            TXLiveAvVideoView::switchViewDashboardStyle((TXLiveAvVideoView::ViewDashboardStyleEnum)style);
            TRTCCloudCore::GetInstance()->showDashboardStyle(style);
        }
        else if (msg.pSender->GetName() == _T("btn_quit_room"))
        {
            if (m_pMainWnd)
                m_pMainWnd->exitRoom();
        }
        else if (msg.pSender->GetName() == _T("btn_audio_device"))
        {
            POINT point1;
            RECT rc = msg.pSender->GetClientPos();
            RECT winRc = { 0 };
            ::GetWindowRect(m_pMainWnd->GetHWND(), &winRc);
            point1.y = winRc.top + rc.top + 26;
            point1.x = winRc.left + rc.left + 5;
            CMenuWnd* pMenu = CMenuWnd::CreateMenu(NULL, _T("devicemenu.xml"), point1, &m_pMainWnd->getPaintManagerUI(), NULL, eMenuAlignment_Bottom);
            CMenuUI* rootMenu = pMenu->GetMenuUI();
            if (rootMenu != NULL)
            {
                // mic
                {
                    //title
                    CMenuElementUI* pNewTabContainer = new CMenuElementUI;
                    pNewTabContainer->SetEnabled(false);
                    CHorizontalLayoutUI* pLayout = new CHorizontalLayoutUI();
                    CLabelUI * headerItem = new CLabelUI();
                    headerItem->SetText(L"选择麦克风");
                    headerItem->SetFont(0);
                    headerItem->SetTextPadding(RECT{ 10,0,0,0 });
                    headerItem->SetTextColor(0xFFE0E0E0);
                    pLayout->Add(headerItem);
                    pNewTabContainer->Add(pLayout);
                    rootMenu->Add(pNewTabContainer);
                    //list
                    std::vector<TRTCCloudCore::MediaDeviceInfo> micInfo = TRTCCloudCore::GetInstance()->getMicDevice();
                    for (auto info : micInfo)
                    {
                        CMenuElementUI* pNewMenuElement = new CMenuElementUI;
                        pNewMenuElement->SetText(info._text.c_str());
                        pNewMenuElement->SetName(info._type.c_str());
                        if (info._select)
                        {
                            pNewMenuElement->SetIcon(L"file='menu/item_choose.png'");
                            pNewMenuElement->SetIconSize(12, 12);
                        }
                        rootMenu->Add(pNewMenuElement);
                    }
                }
                {   //line
                    CMenuElementUI* pNewMenuElement = new CMenuElementUI;
                    pNewMenuElement->SetLineType();
                    pNewMenuElement->SetLinePadding(RECT{ 2,0,2,0 });
                    pNewMenuElement->SetFixedHeight(6);
                    pNewMenuElement->SetLineColor(0xFF707070);
                    rootMenu->Add(pNewMenuElement);
                }
                {   // speaker 
                    //title
                    CMenuElementUI* pNewTabContainer = new CMenuElementUI;
                    pNewTabContainer->SetEnabled(false);
                    CHorizontalLayoutUI* pLayout = new CHorizontalLayoutUI();
                    CLabelUI * headerItem = new CLabelUI();
                    headerItem->SetText(L"选择扬声器");
                    headerItem->SetFont(0);
                    headerItem->SetTextPadding(RECT{ 10,0,0,0 });
                    headerItem->SetTextColor(0xFFE0E0E0);
                    pLayout->Add(headerItem);
                    pNewTabContainer->Add(pLayout);
                    rootMenu->Add(pNewTabContainer);
                    //list
                    std::vector<TRTCCloudCore::MediaDeviceInfo> speakerInfo = TRTCCloudCore::GetInstance()->getSpeakDevice();
                    for (auto info : speakerInfo)
                    {
                        CMenuElementUI* pNewMenuElement = new CMenuElementUI;
                        pNewMenuElement->SetText(info._text.c_str());
                        pNewMenuElement->SetName(info._type.c_str());
                        if (info._select)
                        {
                            pNewMenuElement->SetIcon(L"file='menu/item_choose.png'");
                            pNewMenuElement->SetIconSize(12, 12);
                        }
                        rootMenu->Add(pNewMenuElement);
                    }
                }
                {   //line
                    CMenuElementUI* pNewMenuElement = new CMenuElementUI;
                    pNewMenuElement->SetLineType();
                    pNewMenuElement->SetLinePadding(RECT{ 2,0,2,0 });
                    pNewMenuElement->SetFixedHeight(0);
                    pNewMenuElement->SetLineColor(0xFF707070);
                    rootMenu->Add(pNewMenuElement);
                }
                {   //设置中心
                    CMenuElementUI* pNewMenuElement = new CMenuElementUI;
                    pNewMenuElement->SetText(L"音频设置");
                    rootMenu->Add(pNewMenuElement);
                }
            }
            // 动态添加后重新设置菜单的大小
            pMenu->ResizeMenu();
        }
        else if (msg.pSender->GetName() == _T("btn_video_device"))
        {
            POINT point1;
            RECT rc = msg.pSender->GetClientPos();
            RECT winRc = { 0 };
            ::GetWindowRect(m_pMainWnd->GetHWND(), &winRc);
            point1.y = winRc.top + rc.top + 26;
            point1.x = winRc.left + rc.left + 5;
            CMenuWnd* pMenu = CMenuWnd::CreateMenu(NULL, _T("devicemenu.xml"), point1, &m_pMainWnd->getPaintManagerUI(), NULL, eMenuAlignment_Bottom);
            CMenuUI* rootMenu = pMenu->GetMenuUI();
            if (rootMenu != NULL)
            {
                // camera 
                {
                    //title
                    CMenuElementUI* pNewTabContainer = new CMenuElementUI;
                    pNewTabContainer->SetEnabled(false);
                    CHorizontalLayoutUI* pLayout = new CHorizontalLayoutUI();
                    CLabelUI * headerItem = new CLabelUI();
                    headerItem->SetText(L"选择摄像头");
                    headerItem->SetFont(0);
                    headerItem->SetTextPadding(RECT{ 10,0,0,0 });
                    headerItem->SetTextColor(0xFFE0E0E0);
                    pLayout->Add(headerItem);
                    pNewTabContainer->Add(pLayout);
                    rootMenu->Add(pNewTabContainer);
                    //list
                    std::vector<TRTCCloudCore::MediaDeviceInfo> micInfo = TRTCCloudCore::GetInstance()->getCameraDevice();
                    for (auto info : micInfo)
                    {
                        CMenuElementUI* pNewMenuElement = new CMenuElementUI;
                        pNewMenuElement->SetText(info._text.c_str());
                        pNewMenuElement->SetName(info._type.c_str());
                        if (info._select)
                        {
                            pNewMenuElement->SetIcon(L"file='menu/item_choose.png'");
                            pNewMenuElement->SetIconSize(12, 12);
                        }
                        rootMenu->Add(pNewMenuElement);
                    }
                }
                {   //line
                    CMenuElementUI* pNewMenuElement = new CMenuElementUI;
                    pNewMenuElement->SetLineType();
                    pNewMenuElement->SetLinePadding(RECT{ 2,0,2,0 });
                    pNewMenuElement->SetFixedHeight(6);
                    pNewMenuElement->SetLineColor(0xFF707070);
                    rootMenu->Add(pNewMenuElement);
                }
                {   //设置中心
                    CMenuElementUI* pNewMenuElement = new CMenuElementUI;
                    pNewMenuElement->SetText(L"视频设置");
                    rootMenu->Add(pNewMenuElement);
                }
            }
            // 动态添加后重新设置菜单的大小
            pMenu->ResizeMenu();
        }
        else if (msg.pSender->GetName() == _T("btn_open_screen")) {
            if (CDataCenter::GetInstance()->m_localInfo.publish_sub_video) {
                CButtonUI* pBtn = static_cast<CButtonUI*>(msg.pSender);
                if (pBtn){
                    TRTCScreenCaptureSourceInfo info{};
                    info.type = TRTCScreenCaptureSourceTypeUnknown;
                    RECT rect;
                    TRTCScreenCaptureProperty property;
                    OpenScreenBtnEvent(info, rect, property);
                }
            }
            else {
                UiShareSelect uiShareSelect;
                uiShareSelect.Create(m_pMainWnd->GetHWND(), _T("选择分享内容"), UI_WNDSTYLE_DIALOG, 0);
                uiShareSelect.CenterWindow();
                UINT nRet = uiShareSelect.ShowModal();
                if (nRet == IDOK)
                {
                    TRTCScreenCaptureSourceInfo info = uiShareSelect.getSelectWnd();
                    RECT rect = uiShareSelect.getRect();
                    TRTCScreenCaptureProperty property = uiShareSelect.getProperty();
                    CButtonUI* pBtn = static_cast<CButtonUI*>(msg.pSender);
                    if (pBtn)
                        OpenScreenBtnEvent(info, rect, property);
                }
            }        
        }
        else if (msg.pSender->GetName() == _T("btn_open_pkview"))
        {
            CHorizontalLayoutUI* _pPKLayout = static_cast<CHorizontalLayoutUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("layout_container_pkview")));
            if (_pPKLayout)
                _pPKLayout->SetVisible(true);
            CLabelUI* pStatus = static_cast<CLabelUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("label_pkview_status")));
            if (pStatus) pStatus->SetText(L"");
            std::vector<PKUserInfo>& pkList = CDataCenter::GetInstance()->m_vecPKUserList;
            CButtonUI* pBtn = static_cast<CButtonUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("btn_pkview_stop")));
            if (pBtn)
            {
                if (pkList.size() > 0)
                    pBtn->SetEnabled(true);
                else
                    pBtn->SetEnabled(false);
            }
        }
        else if (msg.pSender->GetName() == _T("btn_close_pkview"))
        {
            CHorizontalLayoutUI* _pPKLayout = static_cast<CHorizontalLayoutUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("layout_container_pkview")));
            if (_pPKLayout)
                _pPKLayout->SetVisible(false);

        }
        else if (msg.pSender->GetName() == _T("btn_pkview_start"))
        {
            CLabelUI* pStatus = static_cast<CLabelUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("label_pkview_status")));
            CEditUI* pEditRoomID = static_cast<CEditUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("edit_pk_roomid")));
            CEditUI* pEditUserID = static_cast<CEditUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("edit_pk_userid")));
            if (pEditRoomID != nullptr && pEditUserID != nullptr && pStatus != nullptr)
            {
                m_pkRoomId = pEditRoomID->GetText();
                m_pkUserId = pEditUserID->GetText();
                if (m_pkRoomId.compare(L"") == 0)
                {
                    if (pStatus != nullptr)
                        pStatus->SetText(L"房间号不能为空");
                    return;
                }
                if (m_pkUserId.compare(L"") == 0)
                {
                    if (pStatus != nullptr)
                        pStatus->SetText(L"房间号不能为空");
                    return;
                }
                TRTCCloudCore::GetInstance()->connectOtherRoom(Wide2UTF8(m_pkUserId), _wtoi(m_pkRoomId.c_str()));

                std::wstring statusText = format(L"连接房间[%s]中...", m_pkUserId.c_str());
                pStatus->SetText(statusText.c_str());
                msg.pSender->SetEnabled(false);
            }
        } else if (msg.pSender->GetName() == _T("btn_pkview_stop")) {
            TRTCCloudCore::GetInstance()->getTRTCCloud()->disconnectOtherRoom();
        } else if (msg.pSender->GetName() == _T("btn_member")) {
            onBtnMemberClick();
        } else if (msg.pSender->GetName() == _T("btn_music")) {
            OpenAudioEffectWnd();
        } else if (msg.pSender->GetName() == _T("btn_player")) {
            OpenVodPlayerWnd();
        }
    }
}

LRESULT MainViewBottomBar::MessageHandler(UINT uMsg, WPARAM wParam, LPARAM lParam, bool& bHandled) {
    if (uMsg == WM_MENUCLICK)
    {
        MenuCmd* pMenuCmd = (MenuCmd*)wParam;
        BOOL bChecked = pMenuCmd->bChecked;
        CDuiString strMenuName = pMenuCmd->szName;
        CDuiString sUserData = pMenuCmd->szUserData;
        CDuiString sText = pMenuCmd->szText;
        m_pMainWnd->getPaintManagerUI().DeletePtr(pMenuCmd);
        if (strMenuName == _T("mic"))
            TRTCCloudCore::GetInstance()->selectMicDevice(sText.GetData());
        else if (strMenuName == _T("speaker"))
            TRTCCloudCore::GetInstance()->selectSpeakerDevice(sText.GetData());
        else if (strMenuName == _T("camera"))
            TRTCCloudCore::GetInstance()->selectCameraDevice(sText.GetData());
        else if (sText == _T("音频设置"))
        {
            if (m_pSettingWnd) {
                if (TRTCSettingViewController::getRef() > 0)
                    m_pSettingWnd->Close(ID_CLOSE_WINDOW_NO_QUIT_MSGLOOP);
                m_pSettingWnd = nullptr;
            }
            m_pSettingWnd = new TRTCSettingViewController(TRTCSettingViewController::SettingTag_Audio, m_pMainWnd->GetHWND());
            m_pSettingWnd->Create(m_pMainWnd->GetHWND(), _T("TRTCDuilibDemo"), WS_VISIBLE | WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU, WS_EX_WINDOWEDGE);
            //pSetting->Create(GetHWND(), _T("设置"), WS_POPUP | WS_VISIBLE, WS_EX_TOOLWINDOW);
            m_pSettingWnd->CenterWindow();
            m_pSettingWnd->ShowWindow(true);
        }
        else if (sText == _T("视频设置"))
        {
            if (m_pSettingWnd) {
                if (TRTCSettingViewController::getRef() > 0)
                    m_pSettingWnd->Close(ID_CLOSE_WINDOW_NO_QUIT_MSGLOOP);
                m_pSettingWnd = nullptr;
            }
            m_pSettingWnd = new TRTCSettingViewController(TRTCSettingViewController::SettingTag_Video, m_pMainWnd->GetHWND());
            m_pSettingWnd->Create(m_pMainWnd->GetHWND(), _T("TRTCDuilibDemo"), WS_VISIBLE | WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU, WS_EX_WINDOWEDGE);
            //pSetting->Create(GetHWND(), _T("设置"), WS_POPUP | WS_VISIBLE, WS_EX_TOOLWINDOW);
            m_pSettingWnd->CenterWindow();
            m_pSettingWnd->ShowWindow(true);
 
        }
    }
    else if (uMsg == WM_USER_CMD_DeviceChange)
    {
        TRTCDeviceType type = (TRTCDeviceType)wParam;
        TRTCDeviceState eventCode = (TRTCDeviceState)lParam;
        if (type == TRTCDeviceTypeCamera)
        {
            RefreshVideoDevice();
        }
        if (type == TRTCDeviceTypeMic)
        {
            RefreshAudioDevice();
        }
        if (type == TRTCDeviceTypeSpeaker)
        {

        }
    }
    else if (uMsg == ID_DELAY_SHOW_MSGBOX)
    {
        std::wstring * text = (std::wstring *)wParam;
        CMsgWnd::ShowMessageBox(m_pMainWnd->GetHWND(), _T("TRTCDuilibDemo"), text->c_str(), 0xFFF08080);
        delete text;
        text = nullptr;
    }
    else if (uMsg == WM_USER_CMD_ScreenStart)
    {
        LINFO(L"WM_USER_CMD_ScreenStart m_bStartScreenShare: %d", CDataCenter::GetInstance()->m_localInfo.publish_sub_video);
        CButtonUI* pBtn = static_cast<CButtonUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("btn_open_screen")));
        if (pBtn) {
            pBtn->SetForeImage(L"dest='24,4,50,30' source='0,0,26,26' res='bottom/screen_share_start.png'");
            pBtn->SetText(L"关闭分享");
        }
        CDataCenter::GetInstance()->m_localInfo.publish_sub_video = true;
        TRTCShareScreenToolMgr::GetInstance()->createToolWnd(CDataCenter::GetInstance()->getLocalUserID());
        //TRTCShareScreenToolMgr::GetInstance()->showScreenVideoView(true);
        if (CDataCenter::GetInstance()->m_mixTemplateID <= TRTCTranscodingConfigMode_Manual) TRTCCloudCore::GetInstance()->updateMixTranCodeInfo();
    }
    else if (uMsg == WM_USER_CMD_ScreenEnd)
    {
        LINFO(L"WM_USER_CMD_ScreenEnd m_bStartScreenShare: %d", CDataCenter::GetInstance()->m_localInfo.publish_sub_video);
        CButtonUI* pBtn = static_cast<CButtonUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("btn_open_screen")));
        if (pBtn) {
            pBtn->SetForeImage(L"dest='24,4,50,30' source='0,0,26,26' res='bottom/screen_share_normal.png'");
            pBtn->SetText(L"启动分享");
        }
        TRTCShareScreenToolMgr::GetInstance()->destroyToolWnd();

        CDataCenter::GetInstance()->m_localInfo.publish_sub_video = false;
        if (CDataCenter::GetInstance()->m_mixTemplateID <= TRTCTranscodingConfigMode_Manual) TRTCCloudCore::GetInstance()->updateMixTranCodeInfo();
    }
    return 0;
}

void MainViewBottomBar::RefreshVideoDevice()
{
    std::wstring selectOldDevice = CDataCenter::GetInstance()->m_selectCamera;
    bool publish_main_video = CDataCenter::GetInstance()->m_localInfo.publish_main_video;
    std::vector<TRTCCloudCore::MediaDeviceInfo> vecDevice = TRTCCloudCore::GetInstance()->getCameraDevice();
    std::wstring selectNewDevice = L"Unknow";
    for (auto info : vecDevice){
        if (info._select) {
            selectNewDevice = info._text; break;
        }
    }

    //没有设备变成有设备
    if (selectOldDevice.compare(L"") == 0 && !publish_main_video)
    {
        onClickMuteVideoBtn();
    }

    //有设备变成没设备
    if (publish_main_video && vecDevice.size() <= 0)
    {
        onClickMuteVideoBtn();
    }
}

void MainViewBottomBar::RefreshAudioDevice()
{
    bool publish_audio = CDataCenter::GetInstance()->m_localInfo.publish_audio;
    std::vector<TRTCCloudCore::MediaDeviceInfo> vecDevice = TRTCCloudCore::GetInstance()->getMicDevice();
    //没有设备变成有设备
    if ( !publish_audio && vecDevice.size() > 0) {
        onClickMuteAudioBtn();
    }

    //有设备变成没设备
    if (publish_audio && vecDevice.size() <= 0) {
        onClickMuteAudioBtn();
    }
}

void MainViewBottomBar::onBtnMemberClick()
{
    CVerticalLayoutUI* pMemberView = static_cast<CVerticalLayoutUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("layout_im_user_area")));
    CVerticalLayoutUI* pBottomToolArea = static_cast<CVerticalLayoutUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("layout_bottom_tool_area")));
    m_bShowMemberWnd = !m_bShowMemberWnd;
    if (m_bShowMemberWnd) {
        pMemberView->SetVisible(true);
        pBottomToolArea->SetFixedWidth(pBottomToolArea->GetFixedWidth() - 320);
    }
    else {
        pMemberView->SetVisible(false);
        pBottomToolArea->SetFixedWidth(pBottomToolArea->GetFixedWidth() + 320);
    }
}

void MainViewBottomBar::muteLocalVideoBtn(bool bMute)
{
    CButtonUI* pBtn = static_cast<CButtonUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("btn_open_video")));
    if (pBtn == nullptr)
        return;
    if (bMute)
    {
        pBtn->SetForeImage(L"dest='24,4,50,30' source='0,0,26,26' res='bottom/camera_mute.png'");
        pBtn->SetText(L"启动视频"); 
    }
    else
    {
        pBtn->SetForeImage(L"dest='24,4,50,30' source='0,0,26,26' res='bottom/camera_start.png'");
        pBtn->SetText(L"关闭视频");
    }
}

void MainViewBottomBar::muteLocalAudioBtn(bool bMute)
{
    CButtonUI* pBtn = static_cast<CButtonUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("btn_open_audio")));
    if (pBtn == nullptr)
        return;
    if (bMute)
    {
        pBtn->SetForeImage(L"dest='24,4,50,30' source='0,0,26,26' res='bottom/audio_mute.png'");
        pBtn->SetText(L"解除静音");
    }
    else
    {
        pBtn->SetForeImage(L"dest='24,4,50,30' source='0,0,26,26' res='bottom/audio_start.png'");
        pBtn->SetText(L"静音");
    }
}

bool MainViewBottomBar::onPKUserLeaveRoom(std::string userId)
{
    std::vector<PKUserInfo>& pkList = CDataCenter::GetInstance()->m_vecPKUserList;
    std::vector<PKUserInfo>::iterator result;
    for (result = pkList.begin(); result != pkList.end(); result++)
    {
        if (result->_userId.compare(userId.c_str()) == 0)
        {
            pkList.erase(result);
            std::string localUserId = CDataCenter::GetInstance()->getLocalUserID();
            CDuiString strFormat;
            strFormat.Format(L"%s连麦用户[%s]离开房间", Log::_GetDateTimeString().c_str(), UTF82Wide(userId).c_str());
            TXLiveAvVideoView::appendEventLogText(localUserId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
            return true;
        }
    }
    return false;
}

bool MainViewBottomBar::onPKUserEnterRoom(std::string userId, uint32_t& roomId)
{
    std::vector<PKUserInfo>& pkList = CDataCenter::GetInstance()->m_vecPKUserList;
    std::vector<PKUserInfo>::iterator result;
    for (result = pkList.begin(); result != pkList.end(); result++)
    {
        if (result->_userId.compare(userId.c_str()) == 0)
        {
            result->bEnterRoom = true;
            roomId = result->_roomId;
            std::string localUserId = CDataCenter::GetInstance()->getLocalUserID();
            CDuiString strFormat;
            strFormat.Format(L"%s连麦用户[%s]进入房间", Log::_GetDateTimeString().c_str(), UTF82Wide(userId).c_str());
            TXLiveAvVideoView::appendEventLogText(localUserId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
            return true;
        }
    }
    return false;
}

void MainViewBottomBar::onConnectOtherRoom(int errCode, std::string errMsg)
{
    CButtonUI* pBtn = static_cast<CButtonUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("btn_pkview_start")));
    if (pBtn == nullptr)
        return;
    pBtn->SetEnabled(true);
    std::string localUserId = CDataCenter::GetInstance()->getLocalUserID();
    CDuiString strFormat;
    if (errCode == 0)
    {
        PKUserInfo info;
        info._userId = Wide2UTF8(m_pkUserId);
        info._roomId = _wtoi(m_pkRoomId.c_str());

        std::wstring statusText = format(L"连麦成功:[room:%d, user:%s]", info._roomId, m_pkUserId.c_str());
        CLabelUI* pStatus = static_cast<CLabelUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("label_pkview_status")));
        if (pStatus)
        pStatus->SetText(statusText.c_str());

        strFormat.Format(L"%s连麦成功[room:%d, user:%s])", Log::_GetDateTimeString().c_str(), info._roomId, m_pkUserId.c_str());
        TXLiveAvVideoView::appendEventLogText(localUserId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);

        std::vector<PKUserInfo>& pkList = CDataCenter::GetInstance()->m_vecPKUserList;
        pkList.push_back(info);
        CButtonUI* pBtn = static_cast<CButtonUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("btn_pkview_stop")));
        if (pBtn)
            pBtn->SetEnabled(true);
    }
    else
    {
        CLabelUI* pStatus = static_cast<CLabelUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("label_pkview_status")));
        if (pStatus != nullptr)
        {
            std::wstring statusText = format(L"连麦失败,errCode:%d", errCode);
            pStatus->SetText(statusText.c_str());
        }
        strFormat.Format(L"%s连麦失败[userId:%s, roomId:%s, errCode:%d, msg:%s]", m_pkUserId.c_str(), m_pkRoomId.c_str() ,Log::_GetDateTimeString().c_str(), errCode, UTF82Wide(errMsg).c_str());
        TXLiveAvVideoView::appendEventLogText(localUserId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
    }
}

void MainViewBottomBar::onDisconnectOtherRoom(int errCode, std::string errMsg)
{
    std::string localUserId = CDataCenter::GetInstance()->getLocalUserID();
    CDuiString strFormat;
    if (errCode == 0)
    {
        CLabelUI* pStatus = static_cast<CLabelUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("label_pkview_status")));
        if (pStatus != nullptr)
            pStatus->SetText(L"取消连麦成功");
        CButtonUI* pBtn = static_cast<CButtonUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("btn_pkview_stop")));
        if (pBtn)
            pBtn->SetEnabled(false);
        std::vector<PKUserInfo>& pkList = CDataCenter::GetInstance()->m_vecPKUserList;
        pkList.clear();
        strFormat.Format(L"%s取消连麦成功[msg:%s]", Log::_GetDateTimeString().c_str(), UTF82Wide(errMsg).c_str());
        TXLiveAvVideoView::appendEventLogText(localUserId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
    }
    else
    {
        std::wstring statusText = format(L"取消连麦失败,errCode:%d", errCode);
        CLabelUI* pStatus = static_cast<CLabelUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("label_pkview_status")));
        if (pStatus)
            pStatus->SetText(statusText.c_str());

        strFormat.Format(L"%s取消连麦失败:[room:%d, user:%s])", Log::_GetDateTimeString().c_str(), errCode, UTF82Wide(errMsg).c_str());
        TXLiveAvVideoView::appendEventLogText(localUserId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
    }
}

void MainViewBottomBar::onClickMuteVideoBtn()
{
    UI_EVENT_MSG *msg = new UI_EVENT_MSG;
    msg->_id = UI_EVENT_MSG::UI_BTNMSG_ID_MuteVideo;
    msg->_userId = UTF82Wide(CDataCenter::GetInstance()->getLocalUserID());
    msg->_streamType = TRTCVideoStreamTypeBig;
    ::PostMessage(m_pMainWnd->GetHWND(), WM_USER_VIEW_BTN_CLICK, (WPARAM)msg, 0);
}

void MainViewBottomBar::onClickMuteAudioBtn()
{
    UI_EVENT_MSG *msg = new UI_EVENT_MSG;
    msg->_id = UI_EVENT_MSG::UI_BTNMSG_ID_MuteAudio;
    msg->_userId = UTF82Wide(CDataCenter::GetInstance()->getLocalUserID());
    msg->_streamType = TRTCVideoStreamTypeBig;
    ::PostMessage(m_pMainWnd->GetHWND(), WM_USER_VIEW_BTN_CLICK, (WPARAM)msg, 0);
}

void MainViewBottomBar::OpenScreenBtnEvent(TRTCScreenCaptureSourceInfo &source, RECT & rect, TRTCScreenCaptureProperty & property) 
{
    LINFO(L"OpenScreenBtnEvent, m_bStartScreenShare:%d", CDataCenter::GetInstance()->m_localInfo.publish_sub_video);
    if (CDataCenter::GetInstance()->m_localInfo.publish_sub_video)
    {        
        TRTCCloudCore::GetInstance()->stopScreen();
        CDataCenter::GetInstance()->m_localInfo.publish_sub_video = false;
        if (CDataCenter::GetInstance()->m_mixTemplateID <= TRTCTranscodingConfigMode_Manual) 
            TRTCCloudCore::GetInstance()->updateMixTranCodeInfo();
        if (CDataCenter::GetInstance()->m_bPublishScreenInBigStream && TRTCCloudCore::GetInstance()->IsStartPreview()) {
            TRTCCloudCore::GetInstance()->stopPreview();
            TRTCCloudCore::GetInstance()->startPreview();
        }
    }
    else
    {
        TRTCCloudCore::GetInstance()->selectScreenCaptureTarget(source, rect, property);
        if (CDataCenter::GetInstance()->m_bPublishScreenInBigStream) {
            TRTCCloudCore::GetInstance()->startScreenCapture(nullptr, TRTCVideoStreamTypeBig, nullptr);
        }
        else {
            TRTCCloudCore::GetInstance()->startScreen(nullptr);
        }
    }
}
void MainViewBottomBar::OpenAudioEffectWnd()
{
    if (CDataCenter::GetInstance()->m_bOpenDemoTestConfig)
    {
        if (m_pAudioEffectOldWnd)
        {
            if (AudioEffectOldViewController::getRef() > 0)
            {
                m_pAudioEffectOldWnd->Close(ID_CLOSE_WINDOW_NO_QUIT_MSGLOOP);
            }

            m_pAudioEffectOldWnd = nullptr;
        }

        m_pAudioEffectOldWnd = new AudioEffectOldViewController();
        m_pAudioEffectOldWnd->Create(m_pMainWnd->GetHWND(), _T("音乐"), WS_VISIBLE | WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU, WS_EX_WINDOWEDGE);
        m_pAudioEffectOldWnd->CenterWindow();
        m_pAudioEffectOldWnd->ResizeClient(540, 500);
        m_pAudioEffectOldWnd->ShowWindow(true);
    }
    else
    {
        if (m_pAudioEffectWnd)
        {
            if (AudioEffectViewController::getRef() > 0)
            {
                m_pAudioEffectWnd->Close(ID_CLOSE_WINDOW_NO_QUIT_MSGLOOP);
            }

            m_pAudioEffectWnd = nullptr;
        }

        m_pAudioEffectWnd = new AudioEffectViewController();
        m_pAudioEffectWnd->Create(m_pMainWnd->GetHWND(), _T("音乐"), WS_VISIBLE | WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU, WS_EX_WINDOWEDGE);
        m_pAudioEffectWnd->CenterWindow();
        m_pAudioEffectWnd->ShowWindow(true);
    }
   
}

void MainViewBottomBar::OpenVodPlayerWnd() {
   
    if (m_pVodPlayerViewWnd) {
        if (VodPlayerViewController::getRef() > 0) {
            m_pVodPlayerViewWnd->Close(ID_CLOSE_WINDOW_NO_QUIT_MSGLOOP);
        }

        m_pVodPlayerViewWnd = nullptr;
    }

    m_pVodPlayerViewWnd = new VodPlayerViewController();
    m_pVodPlayerViewWnd->Create(m_pMainWnd->GetHWND(), _T("播放器"),
                                WS_VISIBLE | WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU,
                                WS_EX_WINDOWEDGE);
    m_pVodPlayerViewWnd->CenterWindow();
    m_pVodPlayerViewWnd->ShowWindow(true);

}
