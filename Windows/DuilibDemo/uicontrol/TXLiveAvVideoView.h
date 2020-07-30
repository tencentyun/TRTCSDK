/**
* Module:   TXLiveAvVideoView @ liteav
*
* Author:   kmais @ 2018/10/1
*
* Function: SDK 视频渲染View，可直接拷贝使用,接口非线程安装，在主线程调用。
*
* Modify: 创建 by kmais @ 2018/10/1
*
*/
#pragma once
#include "ITRTCCloud.h"
#include "UIlib.h"
using namespace DuiLib;
#include <vector>

class CCriticalSection
{
public:
    CCriticalSection() { ::InitializeCriticalSection(&m_Cs); }
    ~CCriticalSection() { ::DeleteCriticalSection(&m_Cs); }
public:
    void          Enter() { ::EnterCriticalSection(&m_Cs); }
    void          Leave() { ::LeaveCriticalSection(&m_Cs); }
protected:
    CRITICAL_SECTION    m_Cs;
};
class CCSGuard
{
public:
    CCSGuard(CCriticalSection &Cs) : m_Cs(Cs) { m_Cs.Enter(); };
    ~CCSGuard() { m_Cs.Leave(); };
protected:
    CCriticalSection &m_Cs;
};

class CTXLiveAvVideoViewMgr;
class CDNLivePlayerViewMgr;
extern  CTXLiveAvVideoViewMgr* getShareViewMgrInstance();
extern  CDNLivePlayerViewMgr* getCDNLivePlayerViewMgr();
class TXLiveAvVideoView : public CControlUI, public IMessageFilterUI
{
    DECLARE_DUICONTROL(TXLiveAvVideoView)
public:
    enum ViewRenderModeEnum
    {
        EVideoRenderModeFill = 0,     // 图像铺满屏幕，超出显示视窗的视频部分将被截掉
        EVideoRenderModeFit = 1,  // 图像长边填满屏幕，短边区域会被填充黑色，图像居中
    };

    enum ViewDashboardStyleEnum
    {
        EViewDashboardNoVisible = 0,      // 不显示仪表盘
        EViewDashboardShowDashboard = 1,  // 只显示仪表盘
        EViewDashboardRenderAll = 2,      // 显示仪表盘和事件 
    };
public:
    TXLiveAvVideoView();
    ~TXLiveAvVideoView();
public:
    /**
    * \brief：设置View绑定参数
    * \param：userId - 需要渲染画面的userid，如果是本地画面，则传空字符串。
    * \param：type - 需要渲染的视频流类型。
    * \param：bLocal - 渲染本地画面，SDK返回的userID为""
    */
    bool SetRenderInfo(const std::string& userId, TRTCVideoStreamType type, bool bLocal = false);

    /**
    * \brief：移除View绑定参数
    * \param：userId - 需要渲染画面的userid
    */
    void RemoveRenderInfo();

    /**
    * \brief：判断view是否被占用
    */
    bool IsViewOccupy();

    /**
    * \brief：设置View的渲染模式
    * \param：mode - 参考<ViewRenderModeEnum>定义
    */
    void SetRenderMode(ViewRenderModeEnum mode);
    
    /**
    * \brief：暂停渲染，显示默认图片
    * \param：bPause
    */
    void SetPause(bool bPause);

    /**
    * \brief：清除所有映射信息
    * \param：bPause
    */
    static void RemoveAllRegEngine();
public:
    /**
    * \brief：view层 显示仪表盘和事件信息。
    */
    static void appendDashboardLogText(const std::string& userId, TRTCVideoStreamType steamType, const std::wstring& logText);
    static void appendEventLogText(const std::string& userId, TRTCVideoStreamType steamType, const std::wstring& logText, bool bAllFilter = false);
    static void clearUserEventLogText(const std::string& userId);
    static void clearAllLogText();
    static void switchViewDashboardStyle(ViewDashboardStyleEnum style);
    static std::multimap<std::pair<std::string, TRTCVideoStreamType>, std::vector<std::wstring>> g_mapEventLogText;
    static std::multimap<std::pair<std::string, TRTCVideoStreamType>, std::wstring> g_mapDashboardLogText;
    static ViewDashboardStyleEnum g_nStyleDashboard;     //0 关闭， 1打开， 2暂定
     //* 支持rbga数据处理，如需自定义数据，需重载此函数。
    virtual bool AppendVideoFrame(unsigned char * data, uint32_t length, uint32_t width, uint32_t height, TRTCVideoPixelFormat videoFormat, TRTCVideoRotation rotation);
public:
    void GetVideoResolution(int& width, int& height);
    UINT GetPaintMsgID();
    std::string getUserId();

    HWND getWnd() { return m_hWnd; }
protected:
    //IMessageFilterUI
    virtual LRESULT MessageHandler(UINT uMsg, WPARAM wParam, LPARAM lParam, bool& bHandled);
    //CControlUI
    virtual bool DoPaint(HDC hDC, const RECT& rcPaint, CControlUI* pStopControl = NULL);
   
    virtual void DoEvent(TEventUI& event);

protected:
    struct AVFrameBufferInfo {
        unsigned char* frameBuf = nullptr;
        int width = 0;
        int height = 0;
        bool newFrame = false;
        TRTCVideoRotation rotation = TRTCVideoRotation0;
    };
private:

    bool DoPaintText(HDC hDC, const RECT& rcText, const RECT& rcLog, bool bDrawAVFrame);
    void calFullScreenPos(const RECT& rcView, int & x, int & y, int & dstWidth, int & dstHeight);
    void calAdaptPos(const RECT& rcView, int & dstX, int & dstY, int & dstWidth, int & dstHeight);
    std::wstring UTF82Wide(const std::string& strAnsi);
    int  GetNameFontSize(const RECT& rcImage);
    int  GetPauseNameFontSize(const RECT& rcImage);
    int  GetLogFontSize(const RECT& rcImage);
    int  getRotationAngle(TRTCVideoRotation rotatio);
    bool resetBuffer(int srcWidth, int srcHeight, int& dstWidth, int& dstHeight, unsigned char ** dstBuffer);
    void releaseBuffer(AVFrameBufferInfo &info);
    void renderFitMode(HDC hDC, unsigned char* buffer, int width, int height, RECT& rcImage);
    void renderFillMode(HDC hDC, unsigned char* buffer, int width, int height, RECT& rcImage);
private:
    
    friend CTXLiveAvVideoViewMgr;
    ViewRenderModeEnum m_renderMode = EVideoRenderModeFit; //1 填充 2 适应 

    AVFrameBufferInfo m_argbSrcFrame;
    AVFrameBufferInfo m_argbRotationFrame;
    AVFrameBufferInfo m_argbRenderFrame;

    BITMAPINFO m_bmi;
    bool m_bPause = false;
    std::string m_userId;
    TRTCVideoStreamType m_type;
private:
    UINT m_nDefineMsg = 0;  //自定义win32消息，用来通知主线程刷新
    HWND m_hWnd = nullptr;
    bool m_bRegMsgFilter = false;
    bool m_bOccupy = false;
    bool m_bLocalView = false;
private: //统计
    bool bFirstFrame = false;
    //UINT m_nTimerID = 0;
    int nCntSDKFps = 0;
    int nCntPaintFps = 0;
    int nCntPaint = 0;

    DWORD dwLastCntTicket = 0;
    DWORD dwLastAppendFrameTicket = 0;

    uint64_t m_i64TotalFrame;
    uint64_t m_i64TotalTicketTime;

    CCriticalSection m_viewCs;
};
