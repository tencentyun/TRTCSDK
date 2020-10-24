/*
* Module:   TRTCMainViewController
*
* Function: 使用TRTC SDK完成 1v1 和 1vn 的视频通话功能
*
*    1. 支持九宫格平铺和前后叠加两种不同的视频画面布局方式，该部分由 TRTCVideoViewLayout 来计算每个视频画面的位置排布和大小尺寸
*
*    2. 支持对视频通话的分辨率、帧率和流畅模式进行调整，该部分由 TRTCSettingViewController 来实现
*
*    3. 创建或者加入某一个通话房间，需要先指定 roomid 和 userid，这部分由 TRTCLoginViewController 来实现
*/

#pragma once
#include <string>
#include "TRTCCloudCore.h"

class TRTCVideoViewLayout;
class MainViewBottomBar;
class TRTCCloudCore;
class TXLiveAvVideoView;
class CBaseLayoutUI;
class UserListController;
class TRTCMainViewController
    : public CWindowWnd
    , public INotifyUI
    , public IDialogBuilderCallback
{
public: //virture
    TRTCMainViewController();
    ~TRTCMainViewController();
public: //overwrite
    virtual LPCTSTR GetWindowClassName() const { return _T("TRTCDuilibDemo_MainWnd"); };
    virtual UINT GetClassStyle() const { return /*UI_CLASSSTYLE_FRAME |*/ CS_DBLCLKS; };
    virtual void OnFinalMessage(HWND hWnd);
    virtual LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);
    virtual void Notify(TNotifyUI& msg);
    virtual CControlUI* CreateControl(LPCTSTR pstrClass);
public: 
    void exitRoom();
    void enterRoom();
    //切换观看模式
    void switchLivePlayerMode(LivePlayerSourceType emLivePlayerSourceType);
public:
    //消息响应函数：
    void onEnterRoom(int result);     //进房成功响应
    void onExitRoom(int reason);            //退出成功响应
    void onRemoteUserEnterRoom(std::string userId);   //远端用户进房响应
    void onRemoteUserLeaveRoom(std::string userId);    //远端用户退房响应
    void onSubVideoAvailable(std::string userId, bool available);   //远端辅路视频状态切换通知。
    void onVideoAvailable(std::string userId, bool available);      //远端主路视频状态切换通知。
    void onAudioAvailable(std::string userId, bool available);      //远端音频主路状态切换通知。
    void onError(int errCode, std::string errMsg);                  //SDK错误码事件通知。
    void onWarning(int warningCode, std::string warningMsg);        //SDK警告吗事件通知。
    void onDashBoardData(int streamType, std::string userId, std::string data); //仪表盘数据
    void onSDKEventData(int streamType, std::string userId, std::string data);  //SDK事件通知
    void onUserVoiceVolume(std::string userId, uint32_t volume);                //用户音量
    void onNetworkQuality(std::string userId, int quality);                     //网络质量状态
    void onFirstVideoFrame(TRTCVideoStreamType streamType, std::string userId, uint32_t width, uint32_t height);//第一帧数据
    void onUpdateRoleChange();                                                  //主播切观众时。
    void onSendFirstLocalVideoFrame(int streamType);
    void onSendFirstLocalAudioFrame();
    void onSwitchRoom(int errCode, std::string errMsg);
private:
    void CheckLocalUiStatus();
    void onViewBtnClickEvent(int id, std::wstring userId, int streamType);
    void onLocalVideoPublishChange(std::wstring userId, int streamType);
    void onLocalAudioPublishChange(std::wstring userId, int streamType);
    void onRemoteVideoSubscribeChange(std::wstring userId, int streamType);
    void onRemoteAudioSubscribeChange(std::wstring userId, int streamType);
    void InternalEnterRoom();
    //void updateMixTranscodingConfig();      //更新混流信息
public:
    CPaintManagerUI& getPaintManagerUI();
    TRTCVideoViewLayout* getTRTCVideoViewLayout();
private:
    MainViewBottomBar* m_pMainViewBottomBar = nullptr;  //管理主面板下功能按钮列表。
    TRTCVideoViewLayout* m_pVideoViewLayout = nullptr;  //管理主面板的视频渲染窗口分配。
    UserListController* m_pUserListController = nullptr;  //管理成员列表。

    CBaseLayoutUI * m_pBaseLayoutUI = nullptr;          //
    CPaintManagerUI m_pmUI;
    bool m_bQuit = true;

};