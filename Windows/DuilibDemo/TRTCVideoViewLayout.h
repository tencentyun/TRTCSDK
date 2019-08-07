/**
* Module:   VideoViewDispatch @ liteav
*
* Author:   kmais @ 2018/10/1
*
* Function: 视频窗口分配管理类
*
* Modify: 创建 by kmais @ 2018/10/1
*
*/

#pragma once
#include "TRTCCloudDef.h"
#include "ITRTCCloud.h"

enum ViewLayoutStyleEnum {
    ViewLayoutStyle_Lecture,    //演讲模式
    ViewLayoutStyle_Gallery,    //画廊模式
};

class TXLiveAvVideoView;
class VideoCanvasContainerCB {
public:
    virtual ~VideoCanvasContainerCB() {}
    virtual void DoubleClickView(std::wstring userId, TRTCVideoStreamType type) = 0;
    virtual int  GetDispatchViewCnt() = 0;
};

struct UI_EVENT_MSG 
{
    enum UI_EVENT_MSG_ID {
        UI_BTNMSG_ID_MuteVideo,    //点击音频按钮
        UI_BTNMSG_ID_MuteAudio,    //点击视频按钮
    };
    UI_EVENT_MSG_ID _id;
    std::wstring _userId;      
    TRTCVideoStreamType _streamType;
};


class VideoCanvasContainer : public CVerticalLayoutUI, public INotifyUI, public IMessageFilterUI
{
    DECLARE_DUICONTROL(VideoCanvasContainer)
public:
    VideoCanvasContainer(VideoCanvasContainerCB* pCb);
    ~VideoCanvasContainer();
    void initCanvasContainer();
    void cleanViewStatus();
    void resetViewUIStatus(std::wstring userId, TRTCVideoStreamType type = TRTCVideoStreamTypeBig);
    void updateVoiceVolume(int volume);
    void updateNetSignal(int quality);
    void showPKIcon(bool bShow, uint32_t roomId);
    void muteAudio(bool bMute);
    void muteVideo(bool bMute);
protected:
    virtual void SetPos(RECT rc, bool bNeedInvalidate /* = true */);
    virtual void DoEvent(TEventUI& event);
    virtual void Notify(TNotifyUI& msg);
    virtual LRESULT MessageHandler(UINT uMsg, WPARAM wParam, LPARAM lParam, bool& bHandled);
protected:
    void updateAudioIconStatus();
    void updateVideoIconStatus();

public:
    static std::wstring localUserId;//
    struct VideoCanvasAttribute
    {
        bool _bMuteAudio = false;
        bool _bMuteVideo = false;
        bool _bPKUser = false;
        uint32_t _pkRoomId;
        TRTCVideoRotation _viewRotation = TRTCVideoRotation0;  //旋转角度
        TRTCVideoFillMode _vidwFillMode = TRTCVideoFillMode_Fit;
        uint32_t _volume = 0;          //
        uint32_t _netSignalQuality = 1;          //
        VideoCanvasAttribute() {};
        void clean() {
            _viewRotation = TRTCVideoRotation0;
            _vidwFillMode = TRTCVideoFillMode_Fit;
            _volume = 0;
            _bMuteAudio = false;
            _bMuteVideo = false;
            _bPKUser = false;
            _pkRoomId = 0;
            _netSignalQuality = 1;
        }
    };
    
    VideoCanvasAttribute& getVideoCanvasAttribute() { return m_canvasAttribute; };
    static void switchCanvasAttribute(VideoCanvasContainer *viewA, VideoCanvasContainer *viewB);
    void copyCanvasAttribute(VideoCanvasContainer *view);
    TRTCVideoStreamType getVideoStreamType() { return m_streamType; };
    bool isMainView() { return m_bMainView; };
    std::wstring getUserId() { return m_userId; };
protected:
    std::wstring m_userId;      //本渲染   区域分配给谁来渲染
    TRTCVideoStreamType m_streamType; //流类型
    VideoCanvasAttribute m_canvasAttribute;
    
private:
    VideoCanvasContainerCB *m_pCb = nullptr;
    TXLiveAvVideoView * m_pLiveAvView = nullptr;
    CButtonUI *m_pBtnRotation = nullptr;
    CButtonUI *m_pBtnRenderMode = nullptr;
    CButtonUI *m_pBtnAudioIcon = nullptr;
    CButtonUI *m_pBtnVideoIcon = nullptr;
    CButtonUI *m_pBtnNetSignalIcon = nullptr;
    CHorizontalLayoutUI * m_pIconBg = nullptr;
    CDuiString strBtnRotationName;
    CDuiString strBtnRenderModeName;
    CDuiString strBtnAudioIconName;
    CDuiString strBtnVideoIconName;
    CDuiString strBtnNetSignalIconName;
    
    //CProgressUI* m_pVoiceProgress = nullptr;
private:
    bool m_bMainView = false;
    UINT m_nTimerID = 0;
    bool m_bRegMsgFilter = nullptr;
    int m_viewwidth = 0;
    int m_viewheight = 0;
};

class TRTCVideoViewLayout : public VideoCanvasContainerCB
{
public:
    typedef struct _tagVideoRenderInfo {
     public:
        _tagVideoRenderInfo() {
            _viewLayout = nullptr; 
        }
        std::wstring _userId;
		TRTCVideoStreamType _streamType;
        VideoCanvasContainer* _viewLayout;
        void copyVideoRenderInfo(_tagVideoRenderInfo& info)
        {
            _userId = info._userId;
            _streamType = info._streamType;
        }
        void clean()
        {
            _userId = L"";
            _streamType = TRTCVideoStreamTypeBig;
        }
    }VideoRenderInfo;
public:
    TRTCVideoViewLayout();
    ~TRTCVideoViewLayout();
    CControlUI* CreateControl(LPCTSTR pstrClass, CPaintManagerUI* pPM);
    void initRenderUI();
    void unInitRenderUI();
public:
    int  dispatchVideoView(std::wstring userId, TRTCVideoStreamType type);
    int  dispatchPKVideoView(std::wstring userId, TRTCVideoStreamType type, uint32_t roomId);
    bool deleteVideoView(std::wstring userId, TRTCVideoStreamType type);
public:
    bool muteAudio(std::wstring userId, TRTCVideoStreamType type, bool bMute);
    bool muteVideo(std::wstring userId, TRTCVideoStreamType type, bool bMute);
    void setLayoutStyle(ViewLayoutStyleEnum style);
    void updateVoiceVolume(std::wstring userId, int volume);
    void updateNetSignal(std::wstring userId, int quality);
protected:
    int  dispatchVideoView(std::wstring userId, TRTCVideoStreamType type,bool bPKUser, int roomId);
    bool IsUserRender(std::wstring userId, TRTCVideoStreamType type);
    bool IsMainRenderWndUse();
    VideoRenderInfo &FindIdleRenderView(bool& bFind);
    VideoRenderInfo &FindFitMainRenderView(bool& bFind);   //寻找符合主窗口渲染的视频对象。
    VideoRenderInfo &FindRenderView(std::wstring userId, TRTCVideoStreamType type, bool& bFind);   //
    VideoRenderInfo &GetMainRenderView();
    void AdjustViewDispatch(std::map<std::wstring, VideoRenderInfo>& mapView);//主要是把按 1 2 3 4 5 次序从新排位视频
    bool SwapVideoView(std::wstring userIdA, std::wstring userIdB, TRTCVideoStreamType typeA, TRTCVideoStreamType typeB);
    bool SwapViewLayoutStyle(ViewLayoutStyleEnum oldStyle, ViewLayoutStyleEnum newStyle);
public:
    virtual void DoubleClickView(std::wstring userId, TRTCVideoStreamType type);
    virtual int  GetDispatchViewCnt();
    static void switchVideoRenderInfo(VideoRenderInfo& viewA, VideoRenderInfo& viewB);
private:
    CPaintManagerUI * m_pmUI = nullptr;
    int nHadUseCnt = 0;
    int nTotalRenderWindowCnt = 0;
    ViewLayoutStyleEnum mViewLayoutStyleEnum = ViewLayoutStyle_Lecture;

    std::map<std::wstring, VideoRenderInfo> m_mapLectureView; // uiName/info
    CControlUI* lectureview_sublayout_container1 = nullptr;  //
    
    std::map<std::wstring, VideoRenderInfo> m_mapGalleryView; // uiName/info
    CControlUI* galleryview_sublayout_line2 = nullptr;       //
    CControlUI* galleryview_sublayout_line3 = nullptr;       //

    CVerticalLayoutUI* lecture_layout_videoview_container = nullptr;       //
    CVerticalLayoutUI* gallery_layout_videoview_container = nullptr;       //
    CLabelUI* mainview_container_bgtext = nullptr;       //
};

