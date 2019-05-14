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
    void onEnterRoom(uint32_t useTime);
    void onExitRoom(int reason);
    void onUserEnter(std::string userId);
    void onUserExit(std::string userId);
	void onSubVideoAvailable(std::string userId, bool available);
	void onVideoAvailable(std::string userId, bool available);
    void onError(int errCode);
    void onDashBoardData(int streamType, std::string userId, std::string data);
    void onSDKEventData(int streamType, std::string userId, std::string data);
    void onUserVoiceVolume(std::string userId, uint32_t volume);
    void onNetworkQuality(std::string userId, int quality);
    //void onUserVideoListChange(std::vector<UserVideoInfo> vec, UserVideoInfo& localInfo);
    void DoExitRoom();
    void onFirstVideoFrame(std::string userId, uint32_t width, uint32_t height);
private:
    void InitWindow();
    void CheckDeviceStatus();
    void onViewBtnClickEvent(int id, std::wstring userId, int streamType);
    void onLocalVideoPublishChange(std::wstring userId, int streamType);
    void onLocalAudioPublishChange(std::wstring userId, int streamType);
    void onRemoteVideoSubscribeChange(std::wstring userId, int streamType);
    void onRemoteAudioSubscribeChange(std::wstring userId, int streamType);
public:
    CPaintManagerUI& getPaintManagerUI();
    TRTCVideoViewLayout* getTRTCVideoViewLayout();
private:
    bool isTestStringRoomId();
    void getSizeAlign16(long originWidth, long originHeight, long& align16Width, long& align16Height);
    void convertCaptureResolution(TRTCVideoResolution resolution, long& width, long& height);
private:
    MainViewBottomBar* m_pMainViewBottomBar = nullptr;
    TRTCVideoViewLayout* m_pVideoViewLayout = nullptr;
    CBaseLayoutUI * m_pBaseLayoutUI = nullptr;
    CPaintManagerUI m_pmUI;
    bool m_bQuit = true;

    UINT m_nCustomVideoTimerID = 10001;
    UINT m_nCustomAudioTimerID = 10002;

};