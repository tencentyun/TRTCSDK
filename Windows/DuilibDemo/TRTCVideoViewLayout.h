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
#include "TXLiveAvVideoView.h"

static const int MAX_VIEW_PER_PAGE = 4;     //右侧列表最多显示的视图数，排除占位视图

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
    void SetIsLable();
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
        TRTCRenderParams renderParams;
        uint32_t _volume = 0;          //
        uint32_t _netSignalQuality = 1;          //
        VideoCanvasAttribute() {};
        void clean() {
            renderParams.rotation = TRTCVideoRotation0;
            renderParams.fillMode = TRTCVideoFillMode_Fit;
            _volume = 0;
            _bMuteAudio = false;
            _bMuteVideo = false;
            _bPKUser = false;
            _pkRoomId = 0;
            _netSignalQuality = 1;
        }
    };
    
    VideoCanvasAttribute& getVideoCanvasAttribute() { return m_canvasAttribute; };
    TXLiveAvVideoView * getLiveAvVideoView() { return m_pLiveAvView; }
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
    CButtonUI *m_pBtnSnapshot = nullptr;
    CLabelUI *m_pLableText = nullptr;
    CHorizontalLayoutUI * m_pIconBg = nullptr;
    CDuiString strBtnRotationName;
    CDuiString strBtnRenderModeName;
    CDuiString strBtnAudioIconName;
    CDuiString strBtnVideoIconName;
    CDuiString strBtnNetSignalIconName;
    CDuiString strBtnSnapshotName;
    
    //CProgressUI* m_pVoiceProgress = nullptr;
private:
    bool m_bMainView = false;
    UINT m_nTimerID = 0;
    bool m_bRegMsgFilter = false;
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
            _isLable = false;
        }
        std::wstring _userId;
        TRTCVideoStreamType _streamType;
        bool _isLable;
        VideoCanvasContainer* _viewLayout;
        void copyVideoRenderInfo(_tagVideoRenderInfo& info)
        {
            _userId = info._userId;
            _streamType = info._streamType;
            _isLable = info._isLable;
        }
        void clean()
        {
            _userId = L"";
            _streamType = TRTCVideoStreamTypeBig;
            _isLable = false;
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
    bool IsRemoteViewShow(std::wstring userId, TRTCVideoStreamType type);
    //全部隐藏
    void HideAllVideoViewExceptMain();
    //全部恢复
    void RestoreAllVideoView();
public:
    bool muteAudio(std::wstring userId, TRTCVideoStreamType type, bool bMute);
    bool muteVideo(std::wstring userId, TRTCVideoStreamType type, bool bMute);
    void updateVoiceVolume(std::wstring userId, int volume);
    void updateNetSignal(std::wstring userId, int quality);
public:
    void updateSize();
    void changeLectureviewVisable();
    bool turnPage(bool forward, bool isDel = false);
    VideoRenderInfo *GetMainRenderView();
protected:
    void InsertIntoAllView(VideoRenderInfo& info);
    int  dispatchVideoView(std::wstring userId, TRTCVideoStreamType type, bool bPKUser, int roomId);
    bool IsUserRender(std::wstring userId, TRTCVideoStreamType type);
    bool IsMainRenderWndUse();
    VideoRenderInfo *FindIdleRenderView(bool& bFind);
    VideoRenderInfo *FindFitMainRenderView(bool& bFind);   //寻找符合主窗口渲染的视频对象。
    VideoRenderInfo *FindRenderView(std::wstring userId, TRTCVideoStreamType type, bool label, bool& bFind);   //
    
    void AdjustViewDispatch(std::map<std::wstring, VideoRenderInfo>& mapView, int delCnt);//主要是把按 1 2 3 4 5 次序从新排位视频
    bool SwapVideoView(std::wstring userIdA, std::wstring userIdB, TRTCVideoStreamType typeA, TRTCVideoStreamType typeB);
public:
    virtual void DoubleClickView(std::wstring userId, TRTCVideoStreamType type);
    virtual int  GetDispatchViewCnt();
    static void switchVideoRenderInfo(VideoRenderInfo& viewA, VideoRenderInfo& viewB);
private:
    void updateLectureview();
    void checkPageBtnStatus();
private:
    CPaintManagerUI * m_pmUI = nullptr;
    int nHadUseCnt = 0;
    int nTotalRenderWindowCnt = 0;
    bool bLectureviewShow = true;

    std::map<std::wstring, VideoRenderInfo> m_mapLectureView; // uiName/info
    std::map<int, VideoRenderInfo> m_mapAllViews; // 所有的视图信息
    CVerticalLayoutUI* lectureview_sublayout_container1 = nullptr;  //
    int nCurrentPage = 0;
    int nId = 0;

    CButtonUI* m_pForward = nullptr;
    CButtonUI* m_pBackword = nullptr;

    CVerticalLayoutUI* lecture_layout_videoview_container = nullptr;       //
    CButtonUI* lecture_change_remote_visible = nullptr;
    CLabelUI* mainview_container_bgtext = nullptr;      //
};

