/*
* Module:   AudioEffectOldViewController
*
* Function: 用于音乐功能的使用。
*
*/
#pragma once
#include "UIlib.h"
using namespace DuiLib;
#include <string>
#include "TRTCCloudCallback.h"



class AudioEffectOldViewController
    : public CWindowWnd
    , public INotifyUI
    , public IDialogBuilderCallback
    , public ITRTCCloudCallback
{
private:
    enum BGM_MusicStatus
    {
        BGM_Music_Play,
        BGM_Music_Pause,
        BGM_Music_Stop,
    };
public: //virture
    AudioEffectOldViewController();
    ~AudioEffectOldViewController();
public: //overwrite
    virtual LPCTSTR GetWindowClassName() const { return _T("音乐"); };
    virtual UINT GetClassStyle() const { return /*UI_CLASSSTYLE_FRAME |*/ CS_DBLCLKS; };
    virtual void OnFinalMessage(HWND hWnd);
    virtual LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);

public:
    virtual void Notify(TNotifyUI& msg);
    virtual CControlUI* CreateControl(LPCTSTR pstrClass);
public:
    static int  getRef();
private:
    static void addRef();
    static void subRef();

    void NotifyAudioEffect(TNotifyUI & msg);
    void NotifyBGMMusic(TNotifyUI & msg);
    
    virtual void onPlayBGMBegin(TXLiteAVError errCode)override;
    virtual void onPlayBGMProgress(uint32_t progressMS, uint32_t durationMS)override;
    virtual void onPlayBGMComplete(TXLiteAVError errCode) override;

    void DoPlayBGMBrgin(TXLiteAVError errCode);
    void DoPlayBGMProgress(uint32_t progressMS, uint32_t durationMS);
    void DoPlayBGMComplete(TXLiteAVError errCode);
    
    void InitAudioMusicView();

    void UnitAudioMusicView();

    virtual void onError(TXLiteAVError errCode, const char* errMsg, void* extraInfo) {};

    virtual void onWarning(TXLiteAVWarning warningCode, const char* warningMsg, void* extraInfo) {};


    virtual void onEnterRoom(int result) {};

    virtual void onExitRoom(int reason) {};


private:
    CPaintManagerUI m_pmUI;

    TRTCAudioEffectParam* m_audioEffectParam1;
    TRTCAudioEffectParam* m_audioEffectParam2;
    TRTCAudioEffectParam* m_audioEffectParam3;

    int m_nBGMPublishVolume = 100;
    int m_nBGMPlayoutVolume = 100;

    BGM_MusicStatus m_emBGMMusicStatus = BGM_Music_Stop;
    

    int m_nBGMDurationMS = 0;
    static int m_ref;
};

