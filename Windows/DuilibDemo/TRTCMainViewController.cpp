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
*    3. 创建或者加入某一个通话房间，需要先指定 roomid 和 userid，这部分由 TRTCLoginViewController 来实现
*/

#include "StdAfx.h"
#include "TRTCMainViewController.h"
#include "TRTCLoginViewController.h"
#include "TRTCSettingViewController.h"
#include "TRTCVideoViewLayout.h"
#include "MainViewBottomBar.h"
#include "DataCenter.h"
#include "util/Base.h"
#include "MsgBoxWnd.h"
#include "util/log.h"
#include "TXLiveAvVideoView.h"
#include "GenerateTestUserSig.h"
#include "utils/TrtcUtil.h"
#include "ITXLiteAVNetworkProxy.h"
#include "userlist/UserListController.h"
#include "TRTCCustomerCrypt.h"

//////////////////////////////////////////////////////////////////////////TXLiveAvVideoView
//duilib要实现一些特殊的功能，需要集成布局，做成最基础布局。   
class CBaseLayoutUI : public CHorizontalLayoutUI
{
    DECLARE_DUICONTROL(CBaseLayoutUI)
public:
    CBaseLayoutUI(TRTCMainViewController *pMainWnd) {
        m_pMainWnd = pMainWnd;
    };
    ~CBaseLayoutUI() {};
    void InitBaseLayoutUI() {
        m_pBottomTool = static_cast<CVerticalLayoutUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("layout_bottom_tool_area")));
        m_pTopTool = static_cast<CHorizontalLayoutUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("layout_top_tool_area")));
        m_pPKLayout = static_cast<CHorizontalLayoutUI*>(m_pMainWnd->getPaintManagerUI().FindControl(_T("layout_container_pkview")));
        if (m_pTopTool)
        {
            m_pTopTool->SetFloat();
            m_pTopTool->SetFixedWidth(320); 
            m_pTopTool->SetFixedHeight(60);
        }
        if (m_pPKLayout)
        {
            m_pPKLayout->SetFloat();
            m_pPKLayout->SetFixedWidth(320);
            m_pPKLayout->SetFixedHeight(220);
        }
    }
protected:
    virtual void DoEvent(TEventUI& event) {
        CControlUI::DoEvent(event);
    };
    virtual void SetPos(RECT rc, bool bNeedInvalidate /* = true */) 
    {
        CHorizontalLayoutUI::SetPos(rc, bNeedInvalidate);
        m_pBottomTool->SetFixedWidth(rc.right - rc.left - 2);

        if (m_pTopTool)
        {
            RECT rc = m_rcItem;
            int width = rc.right - rc.left;
            int left = 10; 
            int top = 4;
            SIZE leftTop = { left,top };
            SIZE btnLeftTop = m_pTopTool->GetFixedXY();
            if (btnLeftTop.cx != leftTop.cx || btnLeftTop.cy != leftTop.cy)
            {
                m_pTopTool->SetFixedXY(leftTop); 
            }
        }  
        if (m_pPKLayout)
        {
            RECT rc = m_rcItem;
            int width = rc.right - rc.left;
            int left = 270; 
            int top = rc.bottom - rc.top - 280;
            SIZE leftTop = { left,top };
            SIZE btnLeftTop = m_pPKLayout->GetFixedXY();
            if (btnLeftTop.cx != leftTop.cx || btnLeftTop.cy != leftTop.cy)
            {
                m_pPKLayout->SetFixedXY(leftTop);
            }
        }

    }
private:
    CVerticalLayoutUI *m_pBottomTool = nullptr;
    CHorizontalLayoutUI *m_pTopTool = nullptr;
    CHorizontalLayoutUI *m_pPKLayout = nullptr;
    CLabelUI* mainview_container_bgtext = nullptr;
    TRTCMainViewController *m_pMainWnd = nullptr;
};

////////////////////////////////////////////////////////////////////////// CTRTCMainWnd
TRTCMainViewController::TRTCMainViewController()
{
    m_pMainViewBottomBar = new MainViewBottomBar(this);
    m_pVideoViewLayout = new TRTCVideoViewLayout();
    m_pUserListController = new UserListController(this);
}

TRTCMainViewController::~TRTCMainViewController()
{
   
    TRTCCloudCore::GetInstance()->removeSDKMsgObserverByHwnd(GetHWND());
    m_pmUI.RemoveNotifier(this);
    m_pmUI.RemoveNotifier(m_pMainViewBottomBar);
    if (CDataCenter::GetInstance()->m_bOpenDemoTestConfig) {
        TRTCCloudCore::Destory();
    }
}

void TRTCMainViewController::Notify(TNotifyUI & msg)
{
    if (msg.sType == _T("click"))
    {
        if (msg.pSender->GetName() == _T("lecture_change_remote_visible"))
        {
            if (m_pVideoViewLayout != nullptr)
            {
                m_pVideoViewLayout->changeLectureviewVisable();
            }
        }
        else  if (msg.pSender->GetName() == _T("btn_forward"))
        {
            if (m_pVideoViewLayout != nullptr)
            {
                m_pVideoViewLayout->turnPage(true);
            }
        }
        else  if (msg.pSender->GetName() == _T("btn_backword"))
        {
            if (m_pVideoViewLayout != nullptr)
            {
                m_pVideoViewLayout->turnPage(false);
            }
        }
    }
}

void TRTCMainViewController::enterRoom()
{
    std::string socks5_host = CDataCenter::GetInstance()->m_strSocks5ProxyIp;
    int socks5_port = CDataCenter::GetInstance()->m_strSocks5ProxyPort;
    if (socks5_host.empty() == false && socks5_port > 0)
    {
        ITXNetworkProxy* proxy = createTXNetworkProxy();
        proxy->setSocks5Proxy(socks5_host.c_str(), socks5_port, "", "");
        destroyTXNetworkProxy(&proxy);
    }

    SetIcon(IDR_MAINFRAME);
    //初始化视频渲染窗口分配器
    if (m_pBaseLayoutUI)
        m_pBaseLayoutUI->InitBaseLayoutUI();
    m_pVideoViewLayout->initRenderUI();
    m_pMainViewBottomBar->InitBottomUI();
    m_pUserListController->InitUserListUI();

    TRTCCloudCore::GetInstance()->Init();

    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_EnterRoom, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_ExitRoom, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_MemberEnter, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_MemberExit, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_Error, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_Warning, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_Dashboard, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_DeviceChange, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_SDKEventMsg, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_ConnectionLost, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_TryToReconnect, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_ConnectionRecovery, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_SubVideoAvailable, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_AuidoAvailable, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_VideoAvailable, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_ScreenStart, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_ScreenEnd, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_UserVoiceVolume, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_PKConnectStatus, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_PKDisConnectStatus, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_NetworkQuality, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_FirstVideoFrame, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_RemoteScreenStop, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_SendFirstLocalVideoFrame, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_SendFirstLocalAudioFrame, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_OnStartPublishinge,GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_OnStopPublishing,GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_SwitchRoom, GetHWND());

    TRTCCloudCore::GetInstance()->getTRTCCloud()->setLocalVideoRenderCallback(TRTCVideoPixelFormat_BGRA32, TRTCVideoBufferType_Buffer, (ITRTCVideoRenderCallback*)getShareViewMgrInstance());

    TRTCCloudCore::GetInstance()->getTRTCCloud()->setDefaultStreamRecvMode(\
        CDataCenter::GetInstance()->m_bAutoRecvAudio, CDataCenter::GetInstance()->m_bAutoRecvVideo);

    if (CDataCenter::GetInstance()->audio_quality_ != TRTCAudioQualityUnSelect ) {
        TRTCCloudCore::GetInstance()->getTRTCCloud()->setAudioQuality((TRTCAudioQuality)CDataCenter::GetInstance()->audio_quality_);
    }
	InternalEnterRoom();

    //进入房间
    LocalUserInfo& info = CDataCenter::GetInstance()->getLocalUserInfo();
    //此处为了sdk本地视频回调时，userid = "",做的特殊处理
    VideoCanvasContainer::localUserId = UTF82Wide(info._userId);

    //如果当前是视频通话模式，默认打开弱网降分辨率
    if (CDataCenter::GetInstance()->m_sceneParams == TRTCAppSceneVideoCall) 
    {
        CDataCenter::GetInstance()->m_videoEncParams.enableAdjustRes = true;
    }

    //设置默认配置到SDK
    if (CDataCenter::GetInstance()->m_roleType == TRTCRoleAnchor)
    {
        TRTCCloudCore::GetInstance()->getTRTCCloud()->setVideoEncoderParam(CDataCenter::GetInstance()->m_videoEncParams);
        
    }

    TRTCCloudCore::GetInstance()->getTRTCCloud()->setNetworkQosParam(CDataCenter::GetInstance()->m_qosParams);

    if (CDataCenter::GetInstance()->m_bShowAudioVolume)
        TRTCCloudCore::GetInstance()->getTRTCCloud()->enableAudioVolumeEvaluation(200);


    //设置美颜到SDK
    CDataCenter::BeautyConfig& beautyConfig = CDataCenter::GetInstance()->GetBeautyConfig();
    if (beautyConfig._bOpenBeauty)
    {
        TRTCCloudCore::GetInstance()->getTRTCCloud()->setBeautyStyle(beautyConfig._beautyStyle,\
            beautyConfig._beautyValue, beautyConfig._whiteValue, beautyConfig._ruddinessValue);
    }
    else
    {
        TRTCCloudCore::GetInstance()->getTRTCCloud()->setBeautyStyle(beautyConfig._beautyStyle, 0, 0, 0);
    }
    //设置大小流
    if (CDataCenter::GetInstance()->m_bPushSmallVideo)
    {
        TRTCVideoEncParam param;
        param.videoFps = 15;
        param.videoBitrate = 100;
        param.videoResolution = TRTCVideoResolution_160_120;
        TRTCCloudCore::GetInstance()->getTRTCCloud()->enableSmallVideoStream(true, param);
    }
    if (CDataCenter::GetInstance()->m_bPlaySmallVideo)
    {
        TRTCCloudCore::GetInstance()->getTRTCCloud()->setPriorRemoteVideoStreamType(TRTCVideoStreamTypeSmall);
    }

    //处理是否纯音频模式
    bool bAudioSenceStyle = false;
    if ( CDataCenter::GetInstance()->m_sceneParams ==  TRTCAppSceneAudioCall || CDataCenter::GetInstance()->m_sceneParams == TRTCAppSceneVoiceChatRoom)
        bAudioSenceStyle = true;

    
    if (!(bAudioSenceStyle == true || CDataCenter::GetInstance()->m_roleType == TRTCRoleAudience))
    {
        m_pVideoViewLayout->dispatchVideoView(UTF82Wide(info._userId), TRTCVideoStreamType::TRTCVideoStreamTypeBig);
    }

    CheckLocalUiStatus();

    if (!bAudioSenceStyle)
    {
        std::vector<TRTCCloudCore::MediaDeviceInfo> cameraInfo = TRTCCloudCore::GetInstance()->getCameraDevice();
        LINFO(L"CTRTCMainWnd::InitWindow() camera.size[%d]\n", cameraInfo.size());
        if (cameraInfo.size() > 0 && CDataCenter::GetInstance()->m_roleType != TRTCRoleAudience)
        {
            TRTCCloudCore::GetInstance()->startPreview();
            CDataCenter::GetInstance()->m_localInfo.publish_main_video = true; 
        }
    }
    else
    {
        if (!CDataCenter::GetInstance()->m_bBlackFramePush) {
            TRTCCloudCore::GetInstance()->getTRTCCloud()->muteLocalVideo(true);
        }
        CDataCenter::GetInstance()->m_localInfo.publish_main_video = false;
    }

    if (CDataCenter::GetInstance()->m_roleType != TRTCRoleAudience)
    {
        TRTCCloudCore::GetInstance()->getTRTCCloud()->startLocalAudio((TRTCAudioQuality)CDataCenter::GetInstance()->audio_quality_);
        CDataCenter::GetInstance()->m_localInfo.publish_audio = true;
    }

    std::wstring sceneType = L"视频通话";
    if (CDataCenter::GetInstance()->m_sceneParams == TRTCAppSceneLIVE)
        sceneType = L"在线直播";
    else if(CDataCenter::GetInstance()->m_sceneParams == TRTCAppSceneAudioCall)
        sceneType = L"语音通话";
    else if(CDataCenter::GetInstance()->m_sceneParams == TRTCAppSceneVoiceChatRoom)
        sceneType = L"语音聊天室";

    CDuiString strFormat;
    strFormat.Format(L"%s正在进入[%d]房间,customstreamId[%s] sceneType[%s]", Log::_GetDateTimeString().c_str(), info._roomId, \
        UTF82Wide(CDataCenter::GetInstance()->m_strCustomStreamId).c_str(), sceneType.c_str());
    
    TXLiveAvVideoView::appendEventLogText(info._userId, TRTCVideoStreamTypeBig,strFormat.GetData(), true);
}

void TRTCMainViewController::switchLivePlayerMode(LivePlayerSourceType emLivePlayerSourceType)
{
    if (CDataCenter::GetInstance()->m_emLivePlayerSourceType == emLivePlayerSourceType)
    {
        return;
    }
    if (emLivePlayerSourceType == TRTC_CDN)
    {
        CDataCenter::GetInstance()->m_emLivePlayerSourceType = TRTC_CDN;
        TRTCCloudCore::GetInstance()->getTRTCCloud()->removeCallback((ITRTCCloudCallback*)TRTCCloudCore::GetInstance()->GetITRTCCloudCallback());
        m_pVideoViewLayout->HideAllVideoViewExceptMain();

        VideoCanvasContainer* pVideoCanvasContainer = m_pVideoViewLayout->GetMainRenderView()->_viewLayout;
        if (pVideoCanvasContainer == NULL)
        {
            return;
        }
        TXLiveAvVideoView *pTXLiveAvVideoView = pVideoCanvasContainer->getLiveAvVideoView();
        if (pTXLiveAvVideoView == NULL)
        {
            return;
        }
        string  strUrl = CDataCenter::GetInstance()->GetCdnUrl(pTXLiveAvVideoView->getUserId());
        if (strUrl.empty())
        {
            return;
        }

        TRTCCloudCore::GetInstance()->getTXLivePlayer()->setCallback((ITXLivePlayerCallback*)getCDNLivePlayerViewMgr(), (void*)pTXLiveAvVideoView);
        TRTCCloudCore::GetInstance()->getTXLivePlayer()->setOutputVideoFormat(TXE_OUTPUT_VIDEO_FORMAT_YUV420);
        TRTCCloudCore::GetInstance()->getTXLivePlayer()->startPlay(strUrl.c_str(), PLAY_TYPE_LIVE_FLV);

        TRTCCloudCore::GetInstance()->getTRTCCloud()->exitRoom();
    }
    else if (emLivePlayerSourceType == TRTC_RTC)
    {
        CDataCenter::GetInstance()->m_emLivePlayerSourceType = TRTC_RTC;

        TRTCCloudCore::GetInstance()->getTXLivePlayer()->setCallback(nullptr, nullptr);
        TRTCCloudCore::GetInstance()->getTXLivePlayer()->stopPlay();


        TRTCCloudCore::GetInstance()->getTRTCCloud()->addCallback((ITRTCCloudCallback*)(TRTCCloudCore::GetInstance()->GetITRTCCloudCallback()));
       
        RemoteUserInfoList remoteUser = CDataCenter::GetInstance()->m_remoteUser;
        for (RemoteUserInfoList::iterator itor = remoteUser.begin(); itor != remoteUser.end();
            itor++)
        {
            onRemoteUserLeaveRoom(itor->first);
        }

        InternalEnterRoom();

        m_pVideoViewLayout->RestoreAllVideoView();
    }
}

void TRTCMainViewController::CheckLocalUiStatus()
{
    std::vector<TRTCCloudCore::MediaDeviceInfo> micInfo = TRTCCloudCore::GetInstance()->getMicDevice();
    std::vector<TRTCCloudCore::MediaDeviceInfo> cameraInfo = TRTCCloudCore::GetInstance()->getCameraDevice();
    std::vector<TRTCCloudCore::MediaDeviceInfo> speakerInfo = TRTCCloudCore::GetInstance()->getSpeakDevice();
    std::wstring strTip = L"Error::";
    bool bShowMsgBox = false;
    bool publish_audio = true;
    bool publish_main_video = true;
    if (micInfo.size() <= 0)
    {
        publish_audio = false;
        bShowMsgBox = true;
    }
    if (cameraInfo.size() <= 0)
    {
        bShowMsgBox = true;
        publish_main_video = false;
    }
    if (speakerInfo.size() <= 0)
    {
        bShowMsgBox = true;
    }
    if (bShowMsgBox)
    {
        strTip += L"请检查本地设备。";
        std::wstring * text = new std::wstring;
        text->append(strTip);
        ::PostMessage(GetHWND(), ID_DELAY_SHOW_MSGBOX, (WPARAM)text, 0);
    }

    bool bAudioSenceStyle = false;
    if(CDataCenter::GetInstance()->m_sceneParams ==  TRTCAppSceneAudioCall || CDataCenter::GetInstance()->m_sceneParams == TRTCAppSceneVoiceChatRoom)
        bAudioSenceStyle = true;

    if (bAudioSenceStyle)
        publish_main_video = false;

    if (CDataCenter::GetInstance()->m_roleType == TRTCRoleAudience)
    {
        publish_main_video = false;
        publish_audio = false;
    }
   

    LocalUserInfo& _loginInfo = CDataCenter::GetInstance()->m_localInfo;
    if (!publish_main_video)
    {
        _loginInfo.publish_main_video = publish_main_video;
        m_pVideoViewLayout->muteVideo(UTF82Wide(_loginInfo._userId), TRTCVideoStreamTypeBig, !_loginInfo.publish_main_video);
        m_pMainViewBottomBar->muteLocalVideoBtn(!_loginInfo.publish_main_video);
        TRTCCloudCore::GetInstance()->stopPreview();
        if (!CDataCenter::GetInstance()->m_bBlackFramePush) {
            TRTCCloudCore::GetInstance()->getTRTCCloud()->muteLocalVideo(true);
        }
        m_pVideoViewLayout->deleteVideoView(UTF82Wide(_loginInfo._userId), TRTCVideoStreamType::TRTCVideoStreamTypeBig);

        m_pUserListController->RemoveUser(_loginInfo._userId);
    }
    else
    {
        _loginInfo.publish_main_video = publish_main_video;
        m_pVideoViewLayout->muteVideo(UTF82Wide(_loginInfo._userId),TRTCVideoStreamTypeBig,!_loginInfo.publish_main_video);
        m_pMainViewBottomBar->muteLocalVideoBtn(!_loginInfo.publish_main_video);
        TRTCCloudCore::GetInstance()->startPreview();
        if (!CDataCenter::GetInstance()->m_bBlackFramePush) {
            TRTCCloudCore::GetInstance()->getTRTCCloud()->muteLocalVideo(false);
        }
        m_pVideoViewLayout->dispatchVideoView(UTF82Wide(_loginInfo._userId), TRTCVideoStreamType::TRTCVideoStreamTypeBig);
        m_pUserListController->AddUser(_loginInfo._userId);
    }

    if (!publish_audio)
    {
        _loginInfo.publish_audio = publish_audio;
        m_pVideoViewLayout->muteAudio(UTF82Wide(_loginInfo._userId), TRTCVideoStreamTypeBig, !_loginInfo.publish_audio);
        m_pMainViewBottomBar->muteLocalAudioBtn(!_loginInfo.publish_audio);
        TRTCCloudCore::GetInstance()->getTRTCCloud()->stopLocalAudio();
        TRTCCloudCore::GetInstance()->getTRTCCloud()->muteLocalAudio(true);
    }
    else
    {
        _loginInfo.publish_audio = publish_audio;
        m_pVideoViewLayout->muteAudio(UTF82Wide(_loginInfo._userId),TRTCVideoStreamTypeBig,!_loginInfo.publish_audio);
        m_pMainViewBottomBar->muteLocalAudioBtn(!_loginInfo.publish_audio);
        TRTCCloudCore::GetInstance()->getTRTCCloud()->startLocalAudio((TRTCAudioQuality)CDataCenter::GetInstance()->audio_quality_);
        TRTCCloudCore::GetInstance()->getTRTCCloud()->muteLocalAudio(false);
    }
    m_pUserListController->UpdateUserInfo(_loginInfo);
}

CPaintManagerUI & TRTCMainViewController::getPaintManagerUI()
{
    return m_pmUI;
}

TRTCVideoViewLayout * TRTCMainViewController::getTRTCVideoViewLayout()
{
    return m_pVideoViewLayout;
}

void TRTCMainViewController::OnFinalMessage(HWND hWnd)
{
    delete this;
}

LRESULT TRTCMainViewController::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    if (uMsg == WM_CREATE) {
        m_pmUI.Init(m_hWnd);
        CDialogBuilder builder;
        CControlUI* pRoot = builder.Create(_T("trtc_mainwnd.xml"), (UINT)0, this, &m_pmUI);
        ASSERT(pRoot && "Failed to parse XML");
        m_pmUI.AttachDialog(pRoot);
        m_pmUI.AddNotifier(this);
        m_pmUI.AddNotifier(m_pMainViewBottomBar);
        enterRoom();
        return 0;
    }
    else if (uMsg == WM_CLOSE)
    {
        if (wParam != ID_CLOSE_WINDOW_NO_QUIT_MSGLOOP)
        {
            if (CDataCenter::GetInstance()->m_emLivePlayerSourceType == TRTC_CDN)
            {
                TRTCCloudCore::GetInstance()->getTXLivePlayer()->setCallback(nullptr, nullptr);
                TRTCCloudCore::GetInstance()->getTXLivePlayer()->stopPlay();
            }
            
            exitRoom();
            return false;
        }
    }
    else if (uMsg == WM_DESTROY)
    {
        //拦截退出程序消息，退回登录窗口
        //::PostQuitMessage(0L);
    }
    else if (uMsg == WM_NCACTIVATE)
    {
        if (!::IsIconic(*this)) return (wParam == 0) ? TRUE : FALSE;
    }
    else if (uMsg == WM_SIZE)
    {
        m_pVideoViewLayout->updateSize();
    }
    else if (uMsg == WM_USER_CMD_EnterRoom)
    {
        int result = (int)lParam;
        onEnterRoom(result);
    }
    else if (uMsg == WM_USER_CMD_ExitRoom)
    {
        onExitRoom(lParam);
    }
    else if (uMsg == WM_USER_CMD_MemberEnter)
    {
        std::string * userId = (std::string *)wParam;
        onRemoteUserEnterRoom(*userId);
        delete userId;
        userId = nullptr;

    }
    else if (uMsg == WM_USER_CMD_MemberExit)
    {
        std::string * userId = (std::string *)wParam;
        onRemoteUserLeaveRoom(*userId);
        delete userId;
        userId = nullptr;
    }
    else if (uMsg == WM_USER_CMD_Error)
    {
        std::string * errMsg = (std::string *)lParam;
        int errCode = wParam;
        onError(errCode, *errMsg);
        delete errMsg;
        errMsg = nullptr;
    }
    else if (uMsg == WM_USER_CMD_Warning)
    {
        std::string * warningMsg = (std::string *)lParam;
        int warningCode = wParam;
        onWarning(warningCode, *warningMsg);
        delete warningMsg;
        warningMsg = nullptr;
    }
    else if (uMsg == WM_USER_CMD_Dashboard)
    {
        //std::string * userId = (std::string *)wParam;
        //std::string * value = (std::string *)lParam;
                    
        DashboardInfo* info = (DashboardInfo*)lParam;
        onDashBoardData(info->streamType, info->userId, info->buffer);
        delete info;
        info = nullptr;

        //delete value;
        //value = nullptr;
    }
    else if (uMsg == WM_USER_CMD_SDKEventMsg)
    {
        //std::string * userId = (std::string *)wParam;
        //std::string * value = (std::string *)lParam;
        DashboardInfo* info = (DashboardInfo*)lParam;
        onSDKEventData(info->streamType, info->userId, info->buffer);
        delete info;
        info = nullptr;
        //delete value;
        //value = nullptr;
    }
    else if (uMsg == WM_USER_CMD_ConnectionLost)
    {
        LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();
        if (m_pVideoViewLayout)
        {
            CDuiString strFormat;
            strFormat.Format(L"%s网络异常", Log::_GetDateTimeString().c_str());
            TXLiveAvVideoView::appendEventLogText(info._userId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
        }
    }
    else if (uMsg == WM_USER_CMD_TryToReconnect)
    {
        LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();
        if (m_pVideoViewLayout)
        {
            CDuiString strFormat;
            strFormat.Format(L"%s尝试重进房", Log::_GetDateTimeString().c_str());
            TXLiveAvVideoView::appendEventLogText(info._userId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
        }
    }
    else if (uMsg == WM_USER_CMD_ConnectionRecovery)
    {
        LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();
        if (m_pVideoViewLayout)
        {
            CDuiString strFormat;
            strFormat.Format(L"%s网络恢复，重进房成功", Log::_GetDateTimeString().c_str());
            TXLiveAvVideoView::appendEventLogText(info._userId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
        }
    }
    else if (uMsg == WM_USER_CMD_SubVideoAvailable)
    {
        std::string * userId = (std::string *)wParam;
        bool available = (bool)lParam;
        onSubVideoAvailable(*userId, available);
        delete userId;
        userId = nullptr;
    }
    else if (uMsg == WM_USER_CMD_VideoAvailable)
    {
        std::string * userId = (std::string *)wParam;
        bool available = (bool)lParam;
        onVideoAvailable(*userId, available);
        delete userId;
        userId = nullptr;
    }
    else if (uMsg == WM_USER_CMD_AuidoAvailable)
    {
        std::string * userId = (std::string *)wParam;
        bool available = (bool)lParam;
        onAudioAvailable(*userId, available);
        delete userId;
        userId = nullptr;
    }
    else if (uMsg == WM_USER_CMD_SwitchRoom)
    {
        std::string* errMsg = (std::string*)lParam;
        int errCode = wParam;
        onSwitchRoom(errCode, *errMsg);
        delete errMsg;
        errMsg = nullptr;
    }
    else if (uMsg == WM_USER_CMD_SendFirstLocalVideoFrame)
    {
        int streamType = wParam;
        onSendFirstLocalVideoFrame(streamType);
    }
    else if (uMsg == WM_USER_CMD_SendFirstLocalAudioFrame)
    {
        onSendFirstLocalAudioFrame();
    }
    else if (uMsg == WM_USER_CMD_UserVoiceVolume)
    {
        std::string * userId = (std::string *)wParam;
        uint32_t volume = (uint32_t)lParam;
        onUserVoiceVolume(*userId, volume);
        delete userId;
        userId = nullptr;
    }
    else if (uMsg == WM_USER_SET_SHOW_VOICEVOLUME)
    {
        bool bShow = (bool)wParam;
        if (m_pVideoViewLayout)
            m_pVideoViewLayout->updateVoiceVolume(L"", 0);
    }
    else if (uMsg == WM_USER_CMD_PKConnectStatus)
    {
        TXLiteAVError bShow = (TXLiteAVError)wParam;
        std::string * str = (std::string *)lParam;
        m_pMainViewBottomBar->onConnectOtherRoom(bShow, *str);
        delete str;
        str = nullptr;
    }
    else if (uMsg == WM_USER_CMD_PKDisConnectStatus)
    {
        TXLiteAVError bShow = (TXLiteAVError)wParam;
        std::string * str = (std::string *)lParam;
        m_pMainViewBottomBar->onDisconnectOtherRoom(bShow, *str);
        delete str;
        str = nullptr;
    }
    else if (uMsg == WM_USER_VIEW_BTN_CLICK)
    {
        UI_EVENT_MSG* msg = (UI_EVENT_MSG*)wParam;
        onViewBtnClickEvent(msg->_id, msg->_userId, msg->_streamType);
        delete msg;
        msg = nullptr;
    }
    else if (uMsg == WM_USER_CMD_NetworkQuality)
    {
        std::string * userId = (std::string *)wParam;
        int quality = (int)lParam;
        onNetworkQuality(*userId, quality);
        delete userId;
        userId = nullptr;
    }
    else if (uMsg == WM_USER_CMD_FirstVideoFrame)
    {
        std::string * userId = (std::string *)wParam;
        uint32_t resolution = (uint32_t)lParam;
        uint32_t width = resolution >> 20;
        uint32_t height_streamType = resolution - (width << 20);
        uint32_t height = height_streamType >> 4;
        TRTCVideoStreamType streamType = (TRTCVideoStreamType)(height_streamType - (height << 4));
        onFirstVideoFrame(streamType, *userId, width, height);
        delete userId;
        userId = nullptr;
    }
    else if (uMsg == WM_USER_CMD_RoleChange)
    {
        onUpdateRoleChange();
    }
    else if (uMsg == WM_USER_CMD_LiveTypeChange)
    {
        switchLivePlayerMode((LivePlayerSourceType)wParam);
    }
    else if(uMsg == WM_USER_CMD_OnStartPublishinge)
    {
        if (CDataCenter::GetInstance()->m_mixTemplateID <= TRTCTranscodingConfigMode_Manual) TRTCCloudCore::GetInstance()->updateMixTranCodeInfo();
    }
    else if(uMsg == WM_USER_CMD_OnStopPublishing)
    {
        if (CDataCenter::GetInstance()->m_mixTemplateID <= TRTCTranscodingConfigMode_Manual) TRTCCloudCore::GetInstance()->updateMixTranCodeInfo();
    }
    LRESULT lRes = 0;
    if (m_pmUI.MessageHandler(uMsg, wParam, lParam, lRes))
        return lRes;
    return CWindowWnd::HandleMessage(uMsg, wParam, lParam);
}

CControlUI* TRTCMainViewController::CreateControl(LPCTSTR pstrClass)
{
    if (_tcsicmp(pstrClass, _T("VideoCanvasContainer")) == 0)
        return m_pVideoViewLayout->CreateControl(pstrClass, &m_pmUI);

    if (_tcsicmp(pstrClass, _T("BaseLayoutUI")) == 0)
    {
        m_pBaseLayoutUI = new CBaseLayoutUI(this);
        m_pBaseLayoutUI->SetBkColor(0xFF050505);
        CDialogBuilder builder;
        CControlUI* pUi = builder.Create(_T("trtc_mainbase.xml"), (UINT)0, this);
        m_pBaseLayoutUI->Add(pUi);
        return m_pBaseLayoutUI;
    }
    return NULL;
}

void TRTCMainViewController::onEnterRoom(int result)
{
    if (result >= 0)
    {
        CDataCenter::GetInstance()->m_bIsEnteredRoom = true;
        bool bAudioSenceStyle = false;
        if(CDataCenter::GetInstance()->m_sceneParams ==  TRTCAppSceneAudioCall || CDataCenter::GetInstance()->m_sceneParams == TRTCAppSceneVoiceChatRoom)
            bAudioSenceStyle = true;

        if (bAudioSenceStyle == false)
            if (!CDataCenter::GetInstance()->m_bBlackFramePush) {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->muteLocalVideo(false);
            }
        TRTCCloudCore::GetInstance()->getTRTCCloud()->muteLocalAudio(false);

        LocalUserInfo& info = CDataCenter::GetInstance()->getLocalUserInfo();
       
        CDuiString strFormat;
        strFormat.Format(L"%s进入[%d]房间成功,耗时:%dms", Log::_GetDateTimeString().c_str(), info._roomId, result);
        TXLiveAvVideoView::appendEventLogText(info._userId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
        info._bEnterRoom = true;

        if (!(bAudioSenceStyle == true || CDataCenter::GetInstance()->m_roleType == TRTCRoleAudience))
        {
            m_pVideoViewLayout->dispatchVideoView(UTF82Wide(info._userId), TRTCVideoStreamType::TRTCVideoStreamTypeBig);

            m_pUserListController->AddUser(info._userId);
        }

        if(CDataCenter::GetInstance()->m_bCDNMixTranscoding)
            TRTCCloudCore::GetInstance()->startCloudMixStream();

        TRTCCloudCore::GetInstance()->getTRTCCloud()->setLocalRenderParams(CDataCenter::GetInstance()->getLocalRenderParams());
        TRTCCloudCore::GetInstance()->getTRTCCloud()->setVideoEncoderMirror(CDataCenter::GetInstance()->m_bLocalVideoMirror);
    }
    else
    {
        LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();
        CDuiString strFormat;
        strFormat.Format(L"%s进房失败，ErrorCode:%d", Log::_GetDateTimeString().c_str(), result);
        TXLiveAvVideoView::appendEventLogText(info._userId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
    }
}

void TRTCMainViewController::onExitRoom(int reason)
{

    CDataCenter::GetInstance()->CleanRoomInfo();
    TRTCCloudCore::GetInstance()->Uninit();
    TRTCLoginViewController* pLogin = new TRTCLoginViewController();
    if (pLogin == NULL) return;
    pLogin->Create(NULL, _T("TRTCDuilibDemo"), WS_VISIBLE | WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU, WS_EX_WINDOWEDGE);
    pLogin->CenterWindow();
    pLogin->ShowWindow(true);
    Close(ID_CLOSE_WINDOW_NO_QUIT_MSGLOOP);
    CDataCenter::GetInstance()->m_bIsEnteredRoom = false;
}

void TRTCMainViewController::onRemoteUserEnterRoom(std::string userId)
{
    uint32_t roomId = 0;
    m_pMainViewBottomBar->onPKUserEnterRoom(userId, roomId);
    CDataCenter::GetInstance()->addRemoteUser(userId);
    
    LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();
    CDuiString strFormat;
    strFormat.Format(L"%s[%s]加入房间)", Log::_GetDateTimeString().c_str(), UTF82Wide(userId).c_str());
    TXLiveAvVideoView::appendEventLogText(info._userId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);

    m_pVideoViewLayout->dispatchVideoView(UTF82Wide(userId), TRTCVideoStreamType::TRTCVideoStreamTypeBig);

    m_pUserListController->AddUser(userId);
}

void TRTCMainViewController::onRemoteUserLeaveRoom(std::string userId)
{
    TRTCCloudCore::GetInstance()->getTRTCCloud()->setRemoteVideoRenderCallback(userId.c_str(), TRTCVideoPixelFormat_Unknown, TRTCVideoBufferType_Unknown, nullptr);

    m_pMainViewBottomBar->onPKUserLeaveRoom(userId);
    if (TRTCCloudCore::GetInstance()->getTRTCCloud())
        TRTCCloudCore::GetInstance()->getTRTCCloud()->stopRemoteView(userId.c_str(), TRTCVideoStreamTypeBig);
    m_pVideoViewLayout->deleteVideoView(UTF82Wide(userId), TRTCVideoStreamType::TRTCVideoStreamTypeBig);

    //强制清除辅路视频位。
    if (TRTCCloudCore::GetInstance()->getTRTCCloud())
        TRTCCloudCore::GetInstance()->getTRTCCloud()->stopRemoteView(userId.c_str(), TRTCVideoStreamTypeSub);
    m_pVideoViewLayout->deleteVideoView(UTF82Wide(userId), TRTCVideoStreamType::TRTCVideoStreamTypeSub);

    LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();
    CDuiString strFormat;
    strFormat.Format(L"%s[%s]离开房间", Log::_GetDateTimeString().c_str(), UTF82Wide(userId).c_str());
    TXLiveAvVideoView::appendEventLogText(info._userId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
    TXLiveAvVideoView::clearUserEventLogText(userId);

    CDataCenter::GetInstance()->removeRemoteUser(userId);

    m_pUserListController->RemoveUser(userId);
}

void TRTCMainViewController::onSubVideoAvailable(std::string userId, bool available)
{
    if (available) {
        //避免用户流事件先于进房事件到。
        CDataCenter::GetInstance()->addRemoteUser(userId, false);
        RemoteUserInfo* remoteInfo = CDataCenter::GetInstance()->FindRemoteUser(userId);
        if (remoteInfo != nullptr && remoteInfo->user_id != "")
        {
            remoteInfo->available_sub_video = true;

            int bRet = m_pVideoViewLayout->dispatchVideoView(UTF82Wide(userId), TRTCVideoStreamTypeSub);
            if (bRet == 0) {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->startRemoteView(userId.c_str(), TRTCVideoStreamTypeSub, NULL);
            }
           
            if (m_pUserListController->VideoAllMuted() != true) {
                remoteInfo->subscribe_sub_video = true;
            }

            TRTCCloudCore::GetInstance()->getTRTCCloud()->setRemoteVideoRenderCallback(userId.c_str(), TRTCVideoPixelFormat_BGRA32, \
                TRTCVideoBufferType_Buffer, (ITRTCVideoRenderCallback*)getShareViewMgrInstance());
        }
    }
    else {
        if (TRTCCloudCore::GetInstance()->getTRTCCloud())
            TRTCCloudCore::GetInstance()->getTRTCCloud()->stopRemoteView(userId.c_str(), TRTCVideoStreamTypeSub);
        m_pVideoViewLayout->deleteVideoView(UTF82Wide(userId), TRTCVideoStreamTypeSub);
        RemoteUserInfo* remoteInfo = CDataCenter::GetInstance()->FindRemoteUser(userId);
        if(remoteInfo != nullptr && remoteInfo->user_id != "")
        {
            remoteInfo->available_sub_video = false;
            if (m_pUserListController->VideoAllMuted() != false) {
                remoteInfo->subscribe_sub_video = false;
            }
        }
    }
    if (CDataCenter::GetInstance()->m_mixTemplateID <= TRTCTranscodingConfigMode_Manual) TRTCCloudCore::GetInstance()->updateMixTranCodeInfo();
    if (m_pUserListController->VideoAllMuted() != available) {
        m_pVideoViewLayout->muteVideo(UTF82Wide(userId), TRTCVideoStreamTypeSub, !available);
    }
    
    LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();
    CDuiString strFormat;
    strFormat.Format(L"%s[%s]onSubVideoAvailable : %d", Log::_GetDateTimeString().c_str(), UTF82Wide(userId).c_str(), available);
    TXLiveAvVideoView::appendEventLogText(info._userId, TRTCVideoStreamTypeSub, strFormat.GetData(), true);
}

void TRTCMainViewController::onVideoAvailable(std::string userId, bool available)
{
    RemoteUserInfo* remoteInfo = CDataCenter::GetInstance()->FindRemoteUser(userId);
    if (available) {
        CDataCenter::GetInstance()->addRemoteUser(userId, false);
        if(remoteInfo != nullptr && remoteInfo->user_id != "")
        {
            remoteInfo->available_main_video = true;
            if (m_pUserListController->VideoAllMuted() != true) {
                remoteInfo->subscribe_main_video = true;
            }
            if (m_pVideoViewLayout->IsRemoteViewShow(UTF82Wide(userId), TRTCVideoStreamTypeBig));
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->startRemoteView(
                    userId.c_str(), CDataCenter::GetInstance()->getRemoteVideoStreamType(), NULL);
            }
            TRTCCloudCore::GetInstance()->getTRTCCloud()->setRemoteVideoRenderCallback(userId.c_str(), TRTCVideoPixelFormat_BGRA32, \
                TRTCVideoBufferType_Buffer, (ITRTCVideoRenderCallback*)getShareViewMgrInstance());
        }
    }
    else {
        if (TRTCCloudCore::GetInstance()->getTRTCCloud())
            TRTCCloudCore::GetInstance()->getTRTCCloud()->stopRemoteView(userId.c_str(), TRTCVideoStreamTypeBig);
        //m_pVideoViewLayout->deleteVideoView(UTF82Wide(userId), TRTCVideoStreamTypeBig);
        if(remoteInfo != nullptr && remoteInfo->user_id != "")
        {
            remoteInfo->available_main_video = false;
            if (m_pUserListController->VideoAllMuted() != false) {
                remoteInfo->subscribe_main_video = false;
            }
            
        }
    }

    m_pUserListController->UpdateUserInfo(*remoteInfo);

    if (CDataCenter::GetInstance()->m_mixTemplateID <= TRTCTranscodingConfigMode_Manual) TRTCCloudCore::GetInstance()->updateMixTranCodeInfo();
    if (m_pUserListController->VideoAllMuted() != available) {
        m_pVideoViewLayout->muteVideo(UTF82Wide(userId), TRTCVideoStreamTypeBig, !available);
    }
   
    LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();
    CDuiString strFormat;
    strFormat.Format(L"%s[%s]onVideoAvailable : %d", Log::_GetDateTimeString().c_str(), UTF82Wide(userId).c_str(), available);
    TXLiveAvVideoView::appendEventLogText(info._userId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
}

void TRTCMainViewController::onAudioAvailable(std::string userId, bool available)
{
    LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();
    CDuiString strFormat;
    strFormat.Format(L"%s[%s]onAudioAvailable : %d", Log::_GetDateTimeString().c_str(), UTF82Wide(userId).c_str(), available);
    TXLiveAvVideoView::appendEventLogText(info._userId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);

    RemoteUserInfo* remoteInfo = CDataCenter::GetInstance()->FindRemoteUser(userId);
    if(remoteInfo != nullptr && remoteInfo->user_id != "")
    {
        remoteInfo->available_audio = available;
        if (m_pUserListController->AudioAllMuted() != available)
        {
            remoteInfo->subscribe_audio = available;
            m_pVideoViewLayout->muteAudio(UTF82Wide(userId), TRTCVideoStreamTypeBig, !available);
        }
    }

    m_pUserListController->UpdateUserInfo(*remoteInfo);

    if (CDataCenter::GetInstance()->m_mixTemplateID <= TRTCTranscodingConfigMode_Manual) TRTCCloudCore::GetInstance()->updateMixTranCodeInfo();
}

void TRTCMainViewController::onSendFirstLocalVideoFrame(int streamType)
{
    LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();
    CDuiString strFormat;
    strFormat.Format(L"%s onSendFirstLocalVideoFrame : %d", Log::_GetDateTimeString().c_str(), streamType);
    TXLiveAvVideoView::appendEventLogText(info._userId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
}

void TRTCMainViewController::onSendFirstLocalAudioFrame()
{
    LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();
    CDuiString strFormat;
    strFormat.Format(L"%s onSendFirstLocalAudioFrame", Log::_GetDateTimeString().c_str());
    TXLiveAvVideoView::appendEventLogText(info._userId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
}

void TRTCMainViewController::onSwitchRoom(int errCode, std::string errMsg) {
    LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();
    CDuiString strFormat;
    strFormat.Format(L"%s onSwitchRoom[err:%d,msg:%s]", Log::_GetDateTimeString().c_str(), errCode, UTF82Wide(errMsg).c_str());
    TXLiveAvVideoView::appendEventLogText(info._userId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
    if (errCode == ERR_NULL) {
        // 切换房间成功，更改房间信息
        CDuiString strFormat;
        std::string roomId;
        if (info._roomId == 0) {
            roomId = info.strRoomId;
        } else {
            roomId = std::to_string(info._roomId);
        }
        if (CDataCenter::GetInstance()->m_nLinkTestServer == 1) {
            strFormat.Format(L"TRTCDuilibDemo 【房间ID: %s, 用户ID: %s】【测试环境】", UTF82Wide(roomId).c_str(),
                             UTF82Wide(info._userId).c_str());
        } else if (CDataCenter::GetInstance()->m_nLinkTestServer == 2) {
            strFormat.Format(L"TRTCDuilibDemo 【房间ID: %s, 用户ID: %s】【体验环境】", UTF82Wide(roomId).c_str(),
                             UTF82Wide(info._userId).c_str());
        } else {
            strFormat.Format(L"TRTCDuilibDemo 【房间ID: %s, 用户ID: %s】【正式环境】", UTF82Wide(roomId).c_str(),
                             UTF82Wide(info._userId).c_str());
        }
        SetWindowText(GetHWND(), strFormat.GetData());
    }
}


void TRTCMainViewController::onError(int errCode, std::string errMsg)
{
    LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();
    if (errCode == ERR_SERVER_CENTER_ANOTHER_USER_PUSH_SUB_VIDEO || errCode == ERR_SERVER_CENTER_NO_PRIVILEDGE_PUSH_SUB_VIDEO || errCode == ERR_SERVER_CENTER_INVALID_PARAMETER_SUB_VIDEO)
    {
        CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"), _T("Error: 辅路发起失败，是否当前已经有人发起了辅路！"), 0xFFF08080);
    }
    else if (errCode == ERR_CAMERA_START_FAIL || errCode == ERR_CAMERA_OCCUPY ||
        errCode == ERR_MIC_START_FAIL || errCode == ERR_MIC_OCCUPY || errCode == ERR_SPEAKER_START_FAIL)
    {
        CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"), _T("Error: 请检查本地设备。"), 0xFFF08080);
    }
    else 
    {
        CDuiString strFormat;
        strFormat.Format(L"%sError[err:%d,msg:%s]", Log::_GetDateTimeString().c_str(), errCode, UTF82Wide(errMsg).c_str());
        TXLiveAvVideoView::appendEventLogText(info._userId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
    }
}

void TRTCMainViewController::onWarning(int warningCode, std::string warningMsg)
{
    LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();
    if (warningCode == WARNING_SPEAKER_DEVICE_EMPTY || warningCode == WARNING_MICROPHONE_DEVICE_EMPTY ||
        warningCode == WARNING_CAMERA_DEVICE_EMPTY || warningCode == WARNING_SPEAKER_DEVICE_ABNORMAL ||
        warningCode == WARNING_MICROPHONE_DEVICE_ABNORMAL) {
        CDuiString strFormat;
        strFormat.Format(L"%sWarning[warning:%d,msg:%s]", Log::_GetDateTimeString().c_str(), warningCode, UTF82Wide(warningMsg).c_str());
        TXLiveAvVideoView::appendEventLogText(info._userId, TRTCVideoStreamTypeBig, strFormat.GetData(), true);
    }
}

void TRTCMainViewController::onDashBoardData(int streamType, std::string userId, std::string data)
{
    if (m_pVideoViewLayout)
    {
        //大小视频是占一个视频位，底层支持动态切换。
        if (streamType == TRTCVideoStreamTypeSmall)
            streamType = TRTCVideoStreamTypeBig;
        TXLiveAvVideoView::appendDashboardLogText(userId, (TRTCVideoStreamType)streamType, UTF82Wide(data));
    }
}

void TRTCMainViewController::onSDKEventData(int streamType, std::string userId, std::string data)
{
    TXLiveAvVideoView::appendEventLogText(userId, (TRTCVideoStreamType)streamType, UTF82Wide(data));
}

void TRTCMainViewController::onUserVoiceVolume(std::string userId, uint32_t volume)
{
    if (CDataCenter::GetInstance()->m_bShowAudioVolume)
    {
        if (m_pVideoViewLayout)
            m_pVideoViewLayout->updateVoiceVolume(UTF82Wide(userId), volume);
    }
}

void TRTCMainViewController::onNetworkQuality(std::string userId, int quality)
{
    if (m_pVideoViewLayout)
        m_pVideoViewLayout->updateNetSignal(UTF82Wide(userId), quality);
}

void TRTCMainViewController::onViewBtnClickEvent(int id, std::wstring userId, int streamType)
{
    if (id == UI_EVENT_MSG::UI_BTNMSG_ID_MuteVideo)
    {
        bool bAudioSenceStyle = false;
        if(CDataCenter::GetInstance()->m_sceneParams ==  TRTCAppSceneAudioCall || CDataCenter::GetInstance()->m_sceneParams == TRTCAppSceneVoiceChatRoom)
            bAudioSenceStyle = true;

        if (bAudioSenceStyle)
        {
            CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"), _T("Error: 纯音频场景，无法打开视频，请退房重新选择模式"), 0xFFF08080);
            return;
        }

        if (CDataCenter::GetInstance()->m_roleType == TRTCRoleAudience)
        {
            CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"), _T("Error: 观众进房场景，无法打开视频，请退房重新选择模式"), 0xFFF08080);
            return;
        }

        std::wstring localUserId = UTF82Wide(CDataCenter::GetInstance()->getLocalUserID());
        if (localUserId.compare(userId) == 0)
        {
            bool publish_main_video = CDataCenter::GetInstance()->m_localInfo.publish_main_video;
            std::vector<TRTCCloudCore::MediaDeviceInfo> deviceInfo = TRTCCloudCore::GetInstance()->getCameraDevice();
            if (deviceInfo.size() <= 0 && !publish_main_video)
            {
                CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"), _T("Error: 未检出到摄像头，请检查本地电脑设备。"), 0xFFF08080);
                return;
            }
            onLocalVideoPublishChange(userId, streamType);
        }
        else
        {
            onRemoteVideoSubscribeChange(userId, streamType);
        }


    }
    else if (id == UI_EVENT_MSG::UI_BTNMSG_ID_MuteAudio)
    {
        if (CDataCenter::GetInstance()->m_roleType == TRTCRoleAudience)
        {
            CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"), _T("Error: 观众进房场景，无法打开音频，请退房重新选择模式"), 0xFFF08080);
            return;
        }

        std::wstring localUserId = UTF82Wide(CDataCenter::GetInstance()->getLocalUserID());
        if (localUserId.compare(userId) == 0)
        {

            bool publish_audio = CDataCenter::GetInstance()->m_localInfo.publish_audio;
            std::vector<TRTCCloudCore::MediaDeviceInfo> deviceInfo = TRTCCloudCore::GetInstance()->getMicDevice();
            if (deviceInfo.size() <= 0 && !publish_audio)
            {
                CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"), _T("Error: 未检出到麦克风，请检查本地电脑设备。"), 0xFFF08080);
                return;
            }
            onLocalAudioPublishChange(userId, streamType);
        }
        else
        {
            onRemoteAudioSubscribeChange(userId, streamType);
        }
    }
}

void TRTCMainViewController::onLocalVideoPublishChange(std::wstring userId, int streamType)
{
    LocalUserInfo& _loginInfo = CDataCenter::GetInstance()->getLocalUserInfo();
    if (streamType == TRTCVideoStreamTypeBig)
    {
        if (_loginInfo.publish_main_video)
        {
            _loginInfo.publish_main_video = !_loginInfo.publish_main_video;
            m_pVideoViewLayout->muteVideo(userId, (TRTCVideoStreamType)streamType, !_loginInfo.publish_main_video);
            m_pMainViewBottomBar->muteLocalVideoBtn(!_loginInfo.publish_main_video);
            TRTCCloudCore::GetInstance()->stopPreview();
            if (!CDataCenter::GetInstance()->m_bBlackFramePush) {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->muteLocalVideo(true);
            }
           // m_pVideoViewLayout->deleteVideoView(UTF82Wide(_loginInfo._userId), TRTCVideoStreamType::TRTCVideoStreamTypeBig);
        }
        else
        {
            _loginInfo.publish_main_video = !_loginInfo.publish_main_video;
            m_pVideoViewLayout->muteVideo(userId, (TRTCVideoStreamType)streamType, !_loginInfo.publish_main_video);
            m_pMainViewBottomBar->muteLocalVideoBtn(!_loginInfo.publish_main_video);
            m_pVideoViewLayout->dispatchVideoView(UTF82Wide(_loginInfo._userId), TRTCVideoStreamType::TRTCVideoStreamTypeBig);

            m_pUserListController->AddUser(Wide2UTF8(userId));
            TRTCCloudCore::GetInstance()->startPreview();

            if (!CDataCenter::GetInstance()->m_bBlackFramePush) {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->muteLocalVideo(false);
            }
        }
        m_pUserListController->UpdateUserInfo(_loginInfo);
    }
    else if (streamType == TRTCVideoStreamTypeSub)
    {
        TRTCScreenCaptureSourceInfo info{};
        info.type = TRTCScreenCaptureSourceTypeUnknown;
        RECT rect;
        TRTCScreenCaptureProperty property;
        m_pMainViewBottomBar->OpenScreenBtnEvent(info, rect, property);
    }
}

void TRTCMainViewController::onLocalAudioPublishChange(std::wstring userId, int streamType)
{
    if (streamType == TRTCVideoStreamTypeBig)
    {
        LocalUserInfo& _loginInfo = CDataCenter::GetInstance()->getLocalUserInfo();
        if (_loginInfo.publish_audio)
        {
            _loginInfo.publish_audio = !_loginInfo.publish_audio;
            m_pVideoViewLayout->muteAudio(userId, (TRTCVideoStreamType)streamType, !_loginInfo.publish_audio);
            m_pMainViewBottomBar->muteLocalAudioBtn(!_loginInfo.publish_audio);
            TRTCCloudCore::GetInstance()->getTRTCCloud()->stopLocalAudio();
            TRTCCloudCore::GetInstance()->getTRTCCloud()->muteLocalAudio(true);
        }
        else
        {
            _loginInfo.publish_audio = !_loginInfo.publish_audio;
            m_pVideoViewLayout->muteAudio(userId, (TRTCVideoStreamType)streamType, !_loginInfo.publish_audio);
            m_pMainViewBottomBar->muteLocalAudioBtn(!_loginInfo.publish_audio);
            TRTCCloudCore::GetInstance()->getTRTCCloud()->startLocalAudio((TRTCAudioQuality)CDataCenter::GetInstance()->audio_quality_);
            TRTCCloudCore::GetInstance()->getTRTCCloud()->muteLocalAudio(false);
        }
        m_pUserListController->UpdateUserInfo(_loginInfo);
    }
}

void TRTCMainViewController::onRemoteVideoSubscribeChange(std::wstring userId, int streamType)
{
    RemoteUserInfo* remoteInfo = CDataCenter::GetInstance()->FindRemoteUser(Wide2UTF8(userId));
    if (remoteInfo != nullptr && remoteInfo->user_id != "")
    {
        if(streamType == TRTCVideoStreamTypeBig)
        {
            remoteInfo->subscribe_main_video = !remoteInfo->subscribe_main_video;
            if (remoteInfo->available_main_video)
            {
                m_pVideoViewLayout->muteVideo(userId, (TRTCVideoStreamType)streamType, !remoteInfo->subscribe_main_video);
            }
            TRTCCloudCore::GetInstance()->getTRTCCloud()->muteRemoteVideoStream(Wide2UTF8(userId).c_str(),!remoteInfo->subscribe_main_video);
        } 
        else if(streamType == TRTCVideoStreamTypeSub)
        {
            remoteInfo->subscribe_sub_video = !remoteInfo->subscribe_sub_video;
            if (remoteInfo->available_sub_video)
            {
                m_pVideoViewLayout->muteVideo(userId, (TRTCVideoStreamType)streamType, !remoteInfo->subscribe_sub_video);
            }
            if(remoteInfo->subscribe_sub_video)
                TRTCCloudCore::GetInstance()->getTRTCCloud()->startRemoteView(Wide2UTF8(userId).c_str(), TRTCVideoStreamTypeSub, nullptr);
            else
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopRemoteView(Wide2UTF8(userId).c_str(), TRTCVideoStreamTypeSub);
        }
        if (CDataCenter::GetInstance()->m_mixTemplateID <= TRTCTranscodingConfigMode_Manual) TRTCCloudCore::GetInstance()->updateMixTranCodeInfo();

        m_pUserListController->UpdateUserInfo(*remoteInfo);
    }
}

void TRTCMainViewController::onRemoteAudioSubscribeChange(std::wstring userId, int streamType)
{
    RemoteUserInfo* remoteInfo = CDataCenter::GetInstance()->FindRemoteUser(Wide2UTF8(userId));
    if(remoteInfo != nullptr && remoteInfo->user_id != "")
    {
        if(streamType == TRTCVideoStreamTypeBig)
        {
            remoteInfo->subscribe_audio = !remoteInfo->subscribe_audio;
            if (remoteInfo->available_audio)
            {
                m_pVideoViewLayout->muteAudio(userId, (TRTCVideoStreamType)streamType, !remoteInfo->subscribe_audio);
            }
            TRTCCloudCore::GetInstance()->getTRTCCloud()->muteRemoteAudio(Wide2UTF8(userId).c_str(),!remoteInfo->subscribe_audio);
            if (CDataCenter::GetInstance()->m_mixTemplateID <= TRTCTranscodingConfigMode_Manual) TRTCCloudCore::GetInstance()->updateMixTranCodeInfo();

            m_pUserListController->UpdateUserInfo(*remoteInfo);
        }
    }
}

void TRTCMainViewController::InternalEnterRoom()
{
    //进入房间
    LocalUserInfo& info = CDataCenter::GetInstance()->getLocalUserInfo();
    TRTCParams params;
    params.sdkAppId = GenerateTestUserSig::SDKAPPID;
    params.roomId = info._roomId;//std::to_string(info._roomId).c_str();
    std::string userid = info._userId.c_str();
    params.userId = (char*)userid.c_str();
    std::string userSig = info._userSig.c_str();
    params.userSig = (char*)userSig.c_str();
    std::string privMapEncrypt = "";
    params.privateMapKey = (char*)privMapEncrypt.c_str();
    params.role = CDataCenter::GetInstance()->m_roleType;

    // 默认旁路streamId = sdkappid_roomid_userid_main
    if (CDataCenter::GetInstance()->m_strCustomStreamId.empty())
        CDataCenter::GetInstance()->m_strCustomStreamId = format("%d_%d_%s_main", GenerateTestUserSig::SDKAPPID, info._roomId, info._userId.c_str());
    params.streamId = CDataCenter::GetInstance()->m_strCustomStreamId.c_str();

    TRTCCloudCore::GetInstance()->getTRTCCloud()->enterRoom(params, CDataCenter::GetInstance()->m_sceneParams);
}



void TRTCMainViewController::exitRoom()
{
    LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();

    m_pVideoViewLayout->deleteVideoView(UTF82Wide(info._userId),TRTCVideoStreamType::TRTCVideoStreamTypeBig);
    TRTCCloudCore::GetInstance()->PreUninit();
    m_pMainViewBottomBar->UnInitBottomUI();
    m_pVideoViewLayout->unInitRenderUI();
    m_pUserListController->UnInitUserListUI();
    TXLiveAvVideoView::clearAllLogText();
    ShowWindow(false);
    TRTCCloudCore::GetInstance()->getTRTCCloud()->muteAllRemoteAudio(true);
    TRTCCloudCore::GetInstance()->getTRTCCloud()->exitRoom();

    if (info._bEnterRoom == false || CDataCenter::GetInstance()->m_emLivePlayerSourceType == TRTC_CDN)
    {
        CDataCenter::GetInstance()->m_emLivePlayerSourceType = TRTC_RTC;
        onExitRoom(0);
    }
}

void TRTCMainViewController::onFirstVideoFrame(TRTCVideoStreamType streamType, std::string userId, uint32_t width, uint32_t height)
{

}

void TRTCMainViewController::onUpdateRoleChange()
{
    CheckLocalUiStatus();
    if (CDataCenter::GetInstance()->m_roleType == TRTCRoleAudience && CDataCenter::GetInstance()->m_localInfo.publish_sub_video)
    {
        TRTCScreenCaptureSourceInfo info{ };
        info.type = TRTCScreenCaptureSourceTypeUnknown;
        RECT rect;
        TRTCScreenCaptureProperty property;
        m_pMainViewBottomBar->OpenScreenBtnEvent(info, rect, property);
    }
}
