/*
* Module:   TRTCVideoViewLayout
*
* Function: 用于对视频通话的分辨率、帧率和流畅模式进行调整，并支持记录下这些设置项
*
*/
#pragma once
#include "UIlib.h"
using namespace DuiLib;
#include <string>
#include "TRTCCloudCallback.h"


class TXLiveAvVideoView;
class TRTCSettingViewControllerNotify {
public:
    virtual ~TRTCSettingViewControllerNotify() {}
};

class TRTCSettingViewController
    : public CWindowWnd
    , public INotifyUI
    , public IDialogBuilderCallback
    , public ITRTCCloudCallback

{
public:
    enum SettingTagEnum {
        SettingTag_Normal,
        SettingTag_Audio,
        SettingTag_Video,
    };
    enum BGM_MusicStatus
    {
        BGM_Music_Play,
        BGM_Music_Pause,
        BGM_Music_Stop,
    };
public: //virture
    TRTCSettingViewController(SettingTagEnum tagType, HWND parentHwnd);
    ~TRTCSettingViewController();
    void preUnInit();
public:
    static void regTRTCSettingViewControllerNotify(TRTCSettingViewControllerNotify* ptr);
    static void unregTRTCSettingViewControllerNotify(TRTCSettingViewControllerNotify* ptr);
    static int  getRef();
public: //overwrite
    virtual LPCTSTR GetWindowClassName() const { return _T("设置"); };
    virtual UINT GetClassStyle() const { return /*UI_CLASSSTYLE_FRAME |*/ CS_DBLCLKS; };
    virtual void OnFinalMessage(HWND hWnd);
    virtual LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);

public: //cb
    virtual void Notify(TNotifyUI& msg);
    virtual void NotifyAudioTab(TNotifyUI& msg);
    virtual void NotifyOtherTab(TNotifyUI& msg);
    virtual void NotifyMixTab(TNotifyUI& msg);
    virtual void NotifyRecordTab(TNotifyUI& msg);
    virtual void NotifyAudioRecord(TNotifyUI& msg);
    virtual void NotifyLocalRecord(TNotifyUI& msg);
    virtual void NotifyVodTab(TNotifyUI& msg);
    virtual CControlUI* CreateControl(LPCTSTR pstrClass);

    //ITRTCCloudCallback
    virtual void onError(TXLiteAVError errCode, const char* errMsg, void* arg) {}
    virtual void onWarning(TXLiteAVWarning warningCode, const char* warningMsg, void* arg) {}
    virtual void onEnterRoom(int elapsed) {}
    virtual void onExitRoom(int reason) {}
    virtual void onUserEnter(const char* userId) {}
    virtual void onUserExit(const char* userId, int reason) {}
    virtual void onUserVoiceVolume(TRTCVolumeInfo* userVolumes, uint32_t userVolumesCount, uint32_t totalVolume);
    virtual void onSpeedTest(const TRTCSpeedTestResult& currentResult, uint32_t finishedCount, uint32_t totalCount);
    virtual void onTestMicVolume(uint32_t volume);
    virtual void onTestSpeakerVolume(uint32_t volume);

   
    void DoRecordError (int nRet,std::string msg);
    void DoRecordComplete (std::string path);
    void DoRecordProgress(int duration,int fileSize);

private:
    static void addRef();
    static void subRef();
    void InitWindow();
    void InitNormalTab();
    void InitAudioTab();
    void InitVideoTab();
    void InitOtherTab();
    void InitMixTab();
    void InitRecordTab();
    void InitVodTab();
    void UpdateCameraDevice();
    void UpdateMicDevice();
    void UpdateSpeakerDevice();
    void ResetBeautyConfig();

    void stopAllTestSetting();
private:
    void updateRoleUi();
    void UpdateAudioQualityUi();
    void updateVideoBitrateUi();
    bool isCustomUploaderStreamIdValid(const std::string &streamId);
public:
    SettingTagEnum m_eTagType = SettingTag_Video;
    CPaintManagerUI m_pmUI;
    TXLiveAvVideoView *m_pVideoView = nullptr;
    CProgressUI* m_pProgressTestSpeaker = nullptr;
    CProgressUI* m_pProgressTestMic = nullptr;
    CProgressUI* m_pProgressTestNetwork = nullptr;
    HWND m_parentHwnd = nullptr;
    int m_send_sei_timer = 100;

    bool m_bStartLocalPreview = false;
    bool m_bStartTestMic = false;
    bool m_bStartTestSpeaker = false;
    bool m_bStartTestNetwork = false;
    bool m_bMuteRemotesAudio = false;
    TRTCAudioEffectParam* m_audioEffectParam1;
    TRTCAudioEffectParam* m_audioEffectParam2;
    TRTCAudioEffectParam* m_audioEffectParam3;

    bool is_init_device_combo_list_ = false;
    bool is_init_windows_finished = false;
    bool is_init_audio_quality_combo = false;

    static int m_ref;
    static std::vector<TRTCSettingViewControllerNotify*> vecNotifyList;

    wstring m_strAudioRecordFile;
    wstring m_strMixAudioAppPath;
    wstring m_strLocalRecordFile;
};