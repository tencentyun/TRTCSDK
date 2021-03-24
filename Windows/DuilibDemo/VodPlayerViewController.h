#pragma once
#include "UIlib.h"
using namespace DuiLib;
#include "TXLiveAvVideoView.h"
#include <string>
#include "ITXVodPlayer.h"
#include "uicontrol/VideoWnd.h"
#include "DataCenter.h"
/*
 * Module:   VodPlayerViewController
 *
 * Function: 播放器
 *
 */
class VodPlayerViewController : public CWindowWnd,
                                public INotifyUI,
                                public IDialogBuilderCallback,
                                public ITXVodPlayerEventCallback,
                                public ITXVodPlayerDataCallback {
   public:
    VodPlayerViewController();
    ~VodPlayerViewController();
   private:
    enum VodStatus {
        Vod_Play,
        Vod_Pause,
        Vod_Stop,
    };
   public:  // overwrite
    virtual LPCTSTR GetWindowClassName() const {
        return _T("播放器");
    };
    virtual UINT GetClassStyle() const {
        return /*UI_CLASSSTYLE_FRAME |*/ CS_DBLCLKS;
    };
    virtual void OnFinalMessage(HWND hWnd);
    virtual LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);

   public:
    virtual void Notify(TNotifyUI& msg);
    virtual CControlUI* CreateControl(LPCTSTR pstrClass);

   private:
    void OnClickOpenFile();
    void OnClickSpeedDown();
    void OnClickSpeedUp();
    void OnClickStop();
    void OnClickPlay();
    void OnClickPause();
    void OnSliderSeek();
    void OnSliderVolume();
    void OnClickMute();
    void OnClickUnmute();
   private:
    void onVodPlayerStarted(uint64_t msLength);

    void onVodPlayerProgress(uint64_t msPos);

    void onVodPlayerPaused();

    void onVodPlayerResumed();

    void onVodPlayerStoped(int reason);

    void onVodPlayerError(int error);

    int onVodVideoFrame(LiteAVVideoFrame& frame);

    int onVodAudioFrame(LiteAVAudioFrame& frame);

   private:
    void DoVodPlayerStarted(uint64_t msLength);

    void DoVodPlayerProgress(uint64_t msPos);

    void DoVodPlayerPaused();

    void DoVodPlayerResumed();

    void DoVodPlayerStoped(int reason);

    void DoVodPlayerError(int error);

    void DoVodRenderMode(VodRenderMode vodRenderMode);

    void DoVodEnablePublishVideo(bool enable);

    void DoVodEnablePublishAudio(bool enable);
   public:
    static int getRef();

   private:
    static void addRef();
    static void subRef();
    // InitView
    void InitVodPlayerView();

    void UnitVodPlayerView();

    int GetWidth();
    int GetHeight();

    void InitRender();
   private:
    CPaintManagerUI m_pmUI;
    static int m_ref;

    TXLiveAvVideoView* m_pVideoView = nullptr;
    ITXVodPlayer* m_pVodPlayer = nullptr;

    CButtonUI* m_pOPENFILE;
    CButtonUI* m_pSPEEDDOWN;
    CSliderUI* m_pPLAYSEEK;
    CButtonUI* m_pSPEEDUP;
    CLabelUI* m_pPTS;
    CButtonUI* m_pSTOP;
    CButtonUI* m_pPLAY;
    CButtonUI* m_pPAUSE;
    CSliderUI* m_pVOLUME;
    CButtonUI* m_pMUTE;
    CButtonUI* m_pUNMUTE;
    CButtonUI* m_pSPEED;

    CDuiString m_strFileName;

    float m_fSpeedRate;
    VodStatus m_emVodStatus;

    long m_nVodDurationMS = 0;

    VideoWnd* m_pVideo;
    VodRenderMode m_emVodRenderMode;
};
