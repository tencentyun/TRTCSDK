/*
* Module:   AudioEffectViewController
*
* Function: 用于音乐功能的使用。
*
*/
#pragma once
#include "UIlib.h"
using namespace DuiLib;
#include <string>
#include "TRTCCloudCallback.h"
#include "ITXAudioEffectManager.h"



class AudioEffectViewController
    : public CWindowWnd
    , public INotifyUI
    , public IDialogBuilderCallback
    , public ITXMusicPlayObserver
{
private:
    enum BGM_MusicStatus
    {
        BGM_Music_Play,
        BGM_Music_Pause,
        BGM_Music_Stop,
    };
public: //virture
    AudioEffectViewController();
    ~AudioEffectViewController();
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
    void NotifyBGMSpeed(TNotifyUI & msg);
    void NotifyBGMPitch(TNotifyUI & msg);
    //interface ITXMusicPlayObserver
    void onStart(int id,int errCode) override;
    void onPlayProgress(int id,long curPtsMS,long durationMS) override;
    void onComplete(int id,int errCode) override;

    void DoMusicPlayProgress(int id, int nPos);
    void DoMusicPlayBegin(int id, int errCode);
    void DoMusicPlayFinish(int id);
    //InitView
    void InitAudioMusicView();

    void UnitAudioMusicView();

private:
    CPaintManagerUI m_pmUI;

    AudioMusicParam* m_audioEffectParam1;
    AudioMusicParam* m_audioEffectParam2;
    AudioMusicParam* m_audioEffectParam3;

    AudioMusicParam* m_bgmMusicParam;

    BGM_MusicStatus m_emBGMMusicStatus = BGM_Music_Stop;
    ITXAudioEffectManager *m_pAudioEffectMgr = nullptr;

    int m_nBGMDurationMS = 0;

    int m_nBGMPublishVolume = 100;
    int m_nBGMPlayoutVolume = 100;
    static int m_ref;
};

