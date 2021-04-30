/**
* Module:   TXLiveAvVideoView @ liteav
*
* Author:   kmais @ 2018/10/1
*
* Function: SDK 视频渲染View，可直接拷贝使用
*
* Modify: 创建 by kmais @ 2018/10/1
*
*/

#include "StdAfx.h"
#include "TXLiveAvVideoView.h"
#include <map>
#include <gdiplus.h>
#include <windows.h>
#include "libyuv.h"
#include <time.h>
#include "util/log.h"
#include "Live/TXLiveEventDef.h"
//#include "common/Base.h"

static CCriticalSection g_viewMgrCS;

using namespace Gdiplus;
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////CTXLiveAvVideoViewMgr

class CTXLiveAvVideoViewMgr
    : public ITRTCVideoRenderCallback
{
public:
    CTXLiveAvVideoViewMgr()
    {
        GdiplusStartupInput gdiplusStartupInput;
        Status status = GdiplusStartup(&m_gdiplusToken, &gdiplusStartupInput, NULL);
    };

    ~CTXLiveAvVideoViewMgr()
    {
        RemoveAllView();
        ::GdiplusShutdown(m_gdiplusToken);
    }
public:
    void AddView(const std::string& userId, const TRTCVideoStreamType type, TXLiveAvVideoView* view)
    {
        CCSGuard guard(g_viewMgrCS);
        bool bFind = false;
        for (auto& itr : m_mapViews)
        {
            if (itr.first == std::make_pair(userId, type) && itr.second == view)
            {
                bFind = true;
                break;
            }
        }
        if (!bFind) {
            std::pair<std::string, TRTCVideoStreamType> key = { userId, type };
            m_mapViews.insert({key, view});
        }
            
    }

    void RemoveView(const std::string& userId, const TRTCVideoStreamType type, TXLiveAvVideoView* view)
    {
        CCSGuard guard(g_viewMgrCS);
        std::map<std::pair<std::string, TRTCVideoStreamType>, TXLiveAvVideoView*>::iterator itr = m_mapViews.begin();
        for (; itr != m_mapViews.end(); itr++)
        {
            if (itr->first == std::make_pair(userId, type) && itr->second == view)
            {
                m_mapViews.erase(itr);
                break;;
            }
        }
    }
    void RemoveAllView() {
        CCSGuard guard(g_viewMgrCS);
        m_mapViews.clear();
    }
    uint32_t GetRef()
    {
        CCSGuard guard(g_viewMgrCS);
        return m_mapViews.size();
    }
public:
    virtual void onRenderVideoFrame(const char* userId, TRTCVideoStreamType streamType, TRTCVideoFrame* frame)
    {
        //if (streamType == TRTCVideoStreamTypeBig)
        {
            TRTCVideoStreamType streamTypeTemp = streamType;
            //大小视频是占一个视频位，底层支持动态切换。
            if (streamTypeTemp == TRTCVideoStreamTypeSmall)
            {
                streamTypeTemp = TRTCVideoStreamTypeBig;
            }
            size_t viewCnt = 0;
            {
                CCSGuard guard(g_viewMgrCS);
                viewCnt = m_mapViews.size();
            }
            //此处复杂遍历迭代器，主要是为了释放锁，避免性能瓶颈。
            for (size_t i = 0; i < viewCnt; i++)
            {
                TXLiveAvVideoView* viewPtr = nullptr;
                int index = 0;
                {
                    CCSGuard guard(g_viewMgrCS);
                    for (auto& itr : m_mapViews)
                    {
                        if (index < i)
                        {
                            index++;
                            continue;
                        }
                        if (index == i)
                        {
                            if (itr.first == std::make_pair(std::string(userId), streamTypeTemp) && itr.second != nullptr)
                                viewPtr = itr.second;
                            break;
                        }
                    }
                }
                if (viewPtr != nullptr)
                    viewPtr->AppendVideoFrame((unsigned char *)frame->data, frame->length, frame->width, frame->height, frame->videoFormat, frame->rotation);
            }
            
        }
    }
private:
    ULONG_PTR m_gdiplusToken = 0;
    std::multimap<std::pair<std::string, TRTCVideoStreamType>, TXLiveAvVideoView*> m_mapViews;    // userId和VideoView*的映射map
};

CTXLiveAvVideoViewMgr* getShareViewMgrInstance()
{
    static CTXLiveAvVideoViewMgr uniqueInstance;
    return &uniqueInstance;
}

class CDNLivePlayerViewMgr :public ITXLivePlayerCallback
{
    virtual void onEventCallback(int eventId, const int paramCount, const char **paramKeys, const char **paramValues, void *pUserData)
    {
        int n = eventId;
    }
    virtual void onVideoDecodeCallback(char* data, unsigned int length, int width, int height, TXEOutputVideoFormat format, void *pUserData)
    {
        TXLiveAvVideoView* viewPtr = (TXLiveAvVideoView*)pUserData;

       viewPtr->AppendVideoFrame((unsigned char *)data, length, width, height, TRTCVideoPixelFormat_I420, LiteAVVideoRotation0);


    }
    virtual void onAudioDecodeCallback(unsigned char * pcm, unsigned int length, unsigned int sampleRate, unsigned int channel, unsigned long long timestamp, void *pUserData)
    {

    }
};

CDNLivePlayerViewMgr* getCDNLivePlayerViewMgr()
{
    static CDNLivePlayerViewMgr uniqueInstance;
    return &uniqueInstance;
}
//////////////////////////////////////////////////////////////////////////TXLiveAvVideoView
std::multimap<std::pair<std::string, TRTCVideoStreamType>, std::vector<std::wstring>> TXLiveAvVideoView::g_mapEventLogText;
std::multimap<std::pair<std::string, TRTCVideoStreamType>, std::wstring> TXLiveAvVideoView::g_mapDashboardLogText;
//static UINT g_nTimerCnt = 1;
static UINT g_DefineMsg = WM_USER + 1000;
TXLiveAvVideoView::ViewDashboardStyleEnum TXLiveAvVideoView::g_nStyleDashboard = EViewDashboardNoVisible;

TXLiveAvVideoView::TXLiveAvVideoView()
{
    m_nDefineMsg = g_DefineMsg++;
    //m_nTimerID = g_nTimerCnt++;
    memset(&m_bmi, 0, sizeof(BITMAPINFO));
}

TXLiveAvVideoView::~TXLiveAvVideoView()
{
    getShareViewMgrInstance()->RemoveView(m_userId, m_type, this);
    if (m_pManager) {
        m_pManager->RemoveMessageFilter(this);
        m_bRegMsgFilter = false;
    }

    releaseBuffer(m_argbSrcFrame);
    releaseBuffer(m_argbRotationFrame);
    releaseBuffer(m_argbRenderFrame);

    /*
    if (m_nTimerID != 0)
    {
        KillTimer(m_nTimerID);
        m_nTimerID = 0;
    }
    */
}

bool TXLiveAvVideoView::SetRenderInfo(const std::string & userId, TRTCVideoStreamType type,  bool bLocal)
{
    if (m_bOccupy)
        return false;
    // 设置TRTCCloud回调音视频
    m_bLocalView = bLocal;
    if (m_pManager && m_bRegMsgFilter == false)
    {
        m_pManager->AddMessageFilter(this);
        m_bRegMsgFilter = true;
    }
    m_userId = userId;
    m_type = type;
    uint32_t ref = getShareViewMgrInstance()->GetRef();

    /*
    if (engine)
    {

        if (ref == 0)
        {
            engine->setLocalVideoRenderCallback(TRTCVideoPixelFormat_BGRA32, TRTCVideoBufferType_Buffer, &CTXLiveAvVideoViewMgr::instance());
        }
       
        if (!m_bLocalView)
        {
            engine->setRemoteVideoRenderCallback(userId.c_str(), TRTCVideoPixelFormat_BGRA32, TRTCVideoBufferType_Buffer, &CTXLiveAvVideoViewMgr::instance());
        }
    }
    */
    if (m_bLocalView)
        getShareViewMgrInstance()->AddView("", type, this);
    else
        getShareViewMgrInstance()->AddView(userId, type, this);

    m_hWnd = m_pManager->GetPaintWindow();
    {
        CCSGuard guard(m_viewCs);
        releaseBuffer(m_argbSrcFrame);
    }
    releaseBuffer(m_argbRotationFrame);
    releaseBuffer(m_argbRenderFrame);

    m_bOccupy = true;
    NeedUpdate();
    //SetTimer(m_nTimerID, 1000);
    return true;
}

void TXLiveAvVideoView::RemoveRenderInfo()
{
    if (m_bLocalView)
        getShareViewMgrInstance()->RemoveView("", m_type, this);
    else
        getShareViewMgrInstance()->RemoveView(m_userId, m_type, this);
    uint32_t ref = getShareViewMgrInstance()->GetRef();

    /*
    if (engine)
    {
        if (ref == 0)
        {
            engine->setLocalVideoRenderCallback(TRTCVideoPixelFormat_Unknown, TRTCVideoBufferType_Unknown, nullptr);
        }
        
        if (!m_bLocalView)
        {
            //engine->setRemoteVideoRenderCallback(m_userId.c_str(), TRTCVideoPixelFormat_Unknown, TRTCVideoBufferType_Unknown, nullptr);
        }
    }
    */
    {
        m_hWnd = nullptr;
        {
            CCSGuard guard(m_viewCs);
            releaseBuffer(m_argbSrcFrame);
        }
        releaseBuffer(m_argbRotationFrame);
        releaseBuffer(m_argbRenderFrame);
    }
    {
        m_userId = "";
        m_bOccupy = false;
        m_bLocalView = false;
        bFirstFrame = false;
        dwLastAppendFrameTicket = 0;
        /*
        if (m_nTimerID)
        {
            KillTimer(m_nTimerID);
        }
        */
    }
    NeedUpdate();
}

bool TXLiveAvVideoView::IsViewOccupy()
{
    return m_bOccupy;
}

void TXLiveAvVideoView::SetRenderMode(ViewRenderModeEnum mode)
{
    m_renderMode = mode;
}

void TXLiveAvVideoView::SetPause(bool bPause)
{
    if (m_bPause != bPause)
    {
        m_bPause = bPause;
        if (m_bPause)
        {
            this->SetBkColor(0xFF202020);
        }
        else
        {
            this->SetBkColor(0xFF000000);
            //避免刷新最后一帧数据。
            {
                CCSGuard guard(m_viewCs);
                releaseBuffer(m_argbSrcFrame);
            }
            releaseBuffer(m_argbRotationFrame);
            releaseBuffer(m_argbRenderFrame);
        }
        if (m_hWnd)
            ::PostMessage(m_hWnd, m_nDefineMsg, m_argbSrcFrame.width, m_argbSrcFrame.height);
    }
}

void TXLiveAvVideoView::RemoveAllRegEngine()
{
    getShareViewMgrInstance()->RemoveAllView();
    //g_nTimerCnt = 1;
}

void TXLiveAvVideoView::GetVideoResolution(int & width, int & height)
{
    width = m_argbSrcFrame.width;
    height = m_argbSrcFrame.height;
}

UINT TXLiveAvVideoView::GetPaintMsgID()
{
    return m_nDefineMsg;
}

std::string TXLiveAvVideoView::getUserId()
{
    return m_userId;
}

void TXLiveAvVideoView::switchViewDashboardStyle(ViewDashboardStyleEnum style)
{
    g_nStyleDashboard = style;
}

void TXLiveAvVideoView::appendDashboardLogText(const std::string& userId, TRTCVideoStreamType steamType, const std::wstring& logText)
{
    if (logText.compare(L"") == 0)
        return;

    bool bFind = false;
    for (auto& itr : g_mapDashboardLogText)
    {
        if (itr.first == std::make_pair(userId, steamType))
        {
            bFind = true;
            itr.second = logText;
            break;
        }
    }
    if (!bFind) {
        std::pair<std::string, TRTCVideoStreamType> key = { userId, steamType };
        g_mapDashboardLogText.insert({ key, logText });
    }
    //g_mapDashboardLogText[userId] = logText;
}

void TXLiveAvVideoView::appendEventLogText(const std::string& userId, TRTCVideoStreamType steamType, const std::wstring & logText, bool bAllFilter)
{
    if (logText.compare(L"") == 0)
        return;
    bool bFind = false;
    if (bAllFilter)
    {
        for (auto &itr : g_mapEventLogText)
        {
            if (itr.first == std::make_pair(userId, steamType))
                bFind = true;
            itr.second.push_back(logText);
        }
    }
    else
    {
        for (auto& itr : g_mapEventLogText)
        {
            if (itr.first == std::make_pair(userId, steamType))
            {
                itr.second.push_back(logText);
                if (itr.second.size() > 60)
                    itr.second.erase(itr.second.begin(), itr.second.begin() + 40);
                bFind = true;
                break;
            }
        }
    }
    if (!bFind) {
        std::pair<std::string, TRTCVideoStreamType> key = { userId, steamType };
        std::vector<std::wstring> value;
        value.push_back(logText);
        g_mapEventLogText.insert({ key, value });
    }
}

void TXLiveAvVideoView::clearUserEventLogText(const std::string & userId)
{
    std::multimap<std::pair<std::string, TRTCVideoStreamType>, std::vector<std::wstring>>::iterator iter;//定义一个迭代指针iter
    for (iter = g_mapEventLogText.begin(); iter != g_mapEventLogText.end();)
    {
        if (iter->first.first.compare(userId) == 0)
        {
            iter->second.clear();
            iter = g_mapEventLogText.erase(iter);
        }
        else
            iter++;
    }
}

void TXLiveAvVideoView::clearAllLogText()
{
    g_mapDashboardLogText.clear();
    for (auto &itr : g_mapEventLogText)
        itr.second.clear();
    g_mapEventLogText.clear();
}

LRESULT TXLiveAvVideoView::MessageHandler(UINT uMsg, WPARAM wParam, LPARAM lParam, bool & bHandled)
{
    if (uMsg == m_nDefineMsg)
    {
        this->NeedUpdate();
    }
    return 0;
}

bool TXLiveAvVideoView::DoPaint(HDC hDC, const RECT & rcPaint, CControlUI * pStopControl)
{
    nCntPaint++;
    if (m_bPause) {
        CControlUI::DoPaint(hDC, rcPaint, pStopControl);
        DoPaintText(hDC, m_rcItem, m_rcItem, false);
        return true;
    }

    bool bNeedDrawFrame = true;
    {
        CCSGuard guard(m_viewCs);
        if (m_argbSrcFrame.frameBuf == nullptr) {
            bNeedDrawFrame = false;
        }
    }

    if (bNeedDrawFrame == false) {
        CControlUI::DoPaint(hDC, rcPaint, pStopControl);
        DoPaintText(hDC, m_rcItem, m_rcItem, false);
        return true;
    }

    //超过过一定时间没渲染数据了
    DWORD curTicket = ::GetTickCount();
    if (dwLastAppendFrameTicket > 0 && curTicket - dwLastAppendFrameTicket > 3000) {
        CControlUI::DoPaint(hDC, rcPaint, pStopControl);
        DoPaintText(hDC, m_rcItem, m_rcItem, false);
        return true;
    }

    clock_t begin_t = clock();

    //处理选择
    int w_rotation = 0, h_rotation = 0;
    {
        CCSGuard guard(m_viewCs);
        if (m_argbSrcFrame.frameBuf == nullptr) return true;

        resetBuffer(m_argbSrcFrame.width, m_argbSrcFrame.height, m_argbRotationFrame.width,
                    m_argbRotationFrame.height, &m_argbRotationFrame.frameBuf);
        libyuv::RotationMode mode = (libyuv::RotationMode)getRotationAngle(m_argbSrcFrame.rotation);
        w_rotation = m_argbRotationFrame.width;
        h_rotation = m_argbRotationFrame.height;
        if (mode == libyuv::kRotate90 || mode == libyuv::kRotate270) {
            int temp = w_rotation;
            w_rotation = h_rotation;
            h_rotation = temp;

            // ARGBRotate 做了XMirror，如果是90/270度旋转，需要调整
            mode = (libyuv::RotationMode)((mode + 180) % 360);
        }
        int src_stride_argb = m_argbSrcFrame.width * 4;
        int dst_stride_argb = w_rotation * 4;

        libyuv::ARGBRotate(m_argbSrcFrame.frameBuf, src_stride_argb, m_argbRotationFrame.frameBuf,
                           dst_stride_argb, m_argbSrcFrame.width, -m_argbSrcFrame.height, mode);
    }
    RECT rcImage = { 0 };
    if (EVideoRenderModeFill == m_renderMode)
    {
        renderFillMode(hDC, m_argbRotationFrame.frameBuf, w_rotation, h_rotation, rcImage);
    }
    else if (EVideoRenderModeFit == m_renderMode)
    {
        renderFitMode(hDC, m_argbRotationFrame.frameBuf, w_rotation, h_rotation, rcImage);
    }

    DoPaintText(hDC, rcImage, m_rcItem, true);
    nCntPaintFps++;


    uint64_t duration_t = clock() - begin_t;
    m_i64TotalTicketTime += duration_t;
    m_i64TotalFrame++;
    if (m_i64TotalFrame > 100)
    {
        //LINFO(L"duilib_render_duration:%lld, cntframes:%lld, resolution[%d-%d]", m_i64TotalTicketTime, m_i64TotalFrame, width, height);
        m_i64TotalTicketTime = 0;
        m_i64TotalFrame = 0;
    }
    return true;
}

void TXLiveAvVideoView::renderFitMode(HDC hDC, unsigned char * buffer, int width, int height, RECT& rcImage)
{
    Point origin;
    origin.X = m_rcItem.left, origin.Y = m_rcItem.top;
    int viewWith = m_rcItem.right - m_rcItem.left;
    int viewHeight = m_rcItem.bottom - m_rcItem.top;

    bool bReDrawBg = false;
    //计算缩放尺寸。
    int x = 0, y = 0, dstWidth = width, dstHeight = height;
    calAdaptPos(m_rcItem, x, y, dstWidth, dstHeight);

    rcImage.left = x + origin.X;
    rcImage.right = rcImage.left + dstWidth;
    rcImage.top = y + origin.Y;
    rcImage.bottom = rcImage.top + dstHeight;

    bool bRet = resetBuffer(dstWidth, dstHeight, m_argbRenderFrame.width, m_argbRenderFrame.height, &m_argbRenderFrame.frameBuf);
    if (bRet == true)
        bReDrawBg = true;

    int src_stride_argb = width * 4;
    int dst_stride_argb = dstWidth * 4;

    libyuv::ARGBScale(buffer, src_stride_argb, width, height,
        m_argbRenderFrame.frameBuf, dst_stride_argb, dstWidth, dstHeight, libyuv::kFilterBox);

    if (m_bmi.bmiHeader.biWidth != dstWidth || m_bmi.bmiHeader.biHeight != dstHeight)
    {
        memset(&m_bmi, 0, sizeof(m_bmi));
        m_bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
        m_bmi.bmiHeader.biWidth = dstWidth;
        m_bmi.bmiHeader.biHeight = dstHeight;
        m_bmi.bmiHeader.biPlanes = 1;
        m_bmi.bmiHeader.biBitCount = 32;
        m_bmi.bmiHeader.biCompression = BI_RGB;
        bReDrawBg = true;
    }
    
    //开始处理渲染
    ::SetStretchBltMode(hDC, COLORONCOLOR);

    if (bReDrawBg)
        ::PatBlt(hDC, 0 + origin.X, 0 + origin.Y, viewWith, viewHeight, BLACKNESS);
    ::StretchDIBits(hDC, x + origin.X, y + origin.Y, dstWidth, dstHeight, 0, 0, dstWidth, dstHeight, m_argbRenderFrame.frameBuf, &m_bmi, DIB_RGB_COLORS, SRCCOPY);
    //::StretchDIBits(hDC, x + origin.X, y + origin.Y, dstWidth, dstHeight, 0, dstHeight - 1, dstWidth, -dstHeight, m_argbRenderFrame.frameBuf, &m_bmi, DIB_RGB_COLORS, SRCCOPY);
}

void TXLiveAvVideoView::renderFillMode(HDC hDC, unsigned char * buffer, int width, int height, RECT& rcImage)
{
    Point origin;
    origin.X = m_rcItem.left, origin.Y = m_rcItem.top;
    int viewWith = m_rcItem.right - m_rcItem.left;
    int viewHeight = m_rcItem.bottom - m_rcItem.top;
   

    int x = 0, y = 0, dstWidth = width, dstHeight = height;
    calFullScreenPos(m_rcItem, x, y, dstWidth, dstHeight);

    rcImage = m_rcItem;

    resetBuffer(dstWidth, dstHeight, m_argbRenderFrame.width, m_argbRenderFrame.height, &m_argbRenderFrame.frameBuf);
    int src_stride_argb = width * 4;
    int dst_stride_argb = dstWidth * 4;

    libyuv::ARGBScale(buffer, src_stride_argb, width, height,
        m_argbRenderFrame.frameBuf, dst_stride_argb, dstWidth, dstHeight, libyuv::kFilterBox);

    if (m_bmi.bmiHeader.biWidth != dstWidth || m_bmi.bmiHeader.biHeight != dstHeight)
    {
        memset(&m_bmi, 0, sizeof(m_bmi));
        m_bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
        m_bmi.bmiHeader.biWidth = dstWidth;
        m_bmi.bmiHeader.biHeight = dstHeight;
        m_bmi.bmiHeader.biPlanes = 1;
        m_bmi.bmiHeader.biBitCount = 32;
        m_bmi.bmiHeader.biCompression = BI_RGB;
    }

    //开始处理渲染
    ::SetStretchBltMode(hDC, COLORONCOLOR);
    //::StretchDIBits(hDC, origin.X, origin.Y, viewWith, viewHeight, x, viewHeight - 1 + y,
    //    viewWith, -viewHeight, m_argbRenderFrame.frameBuf, &m_bmi, DIB_RGB_COLORS, SRCCOPY);

    ::StretchDIBits(hDC, origin.X, origin.Y, viewWith, viewHeight, x, y,
        viewWith, viewHeight, m_argbRenderFrame.frameBuf, &m_bmi, DIB_RGB_COLORS, SRCCOPY);
}

void TXLiveAvVideoView::calFullScreenPos(const RECT& rcView, int & x, int & y, int & dstWidth, int & dstHeight)
{
    int viewWith = rcView.right - rcView.left;
    int viewHeight = rcView.bottom - rcView.top;

    int videoWidth = dstWidth, videoHeight = dstHeight;
    float videoRate = videoWidth*1.0 / videoHeight;
    float screenRate = viewWith*1.0 / viewHeight;

    if (screenRate > videoRate)
    {
        dstWidth = viewWith;
        dstHeight = dstWidth * videoHeight / videoWidth + 0.5;
        x = 0;
        y = (dstHeight - viewHeight) / 2 + 0.5;
        //dstHeight = dstWidth*1.0 / screenRate + 0.5;
    }
    else
    {
        dstHeight = viewHeight;
        dstWidth = dstHeight * videoRate + 0.5;
        x = (dstWidth - viewWith) / 2 + 0.5;
        y = 0;
        //x = (dstWidth - screenRate*dstHeight) *1.0 / 2 + 0.5;
    }
}

void TXLiveAvVideoView::calAdaptPos(const RECT& rcView, int & dstX, int & dstY, int & dstWidth, int & dstHeight)
{
    int viewWith = rcView.right - rcView.left;
    int viewHeight = rcView.bottom - rcView.top;

    float videoRate = dstWidth * 1.0 / dstHeight;
    float screenRate = viewWith * 1.0 / viewHeight;

    if (dstWidth == viewWith && dstHeight == viewHeight)
    {
        dstX = 0;
        dstY = 0;
        return;
    }

    if (screenRate > videoRate)
    {
        dstY = 0;
        dstWidth = videoRate / screenRate * viewWith + 0.5;
        dstHeight = viewHeight;
        dstX = (viewWith - dstWidth) / 2 + 0.5;
    }
    else
    {
        dstX = 0;
        dstWidth = viewWith;
        dstHeight = screenRate / videoRate* viewHeight + 0.5;
        dstY = (viewHeight - dstHeight) / 2 + 0.5;
    }

    /*
    double imgRate = imgWidth*1.0 / imgHeight;
    int hwndWidth = m_rcItem.right - m_rcItem.left;
    int hwndHeight = m_rcItem.bottom - m_rcItem.top;
    double screenRate = hwndWidth*1.0 / hwndHeight;

    if (screenRate > imgRate)
    {
        x = (1 - imgRate / screenRate) / 2 * hwndWidth + 0.5;
        y = 0;
        imgWidth = imgRate / screenRate *hwndWidth + 0.5;
        imgHeight = hwndHeight;
    }
    else
    {
        x = 0;
        y = (1 - screenRate / imgRate) / 2 * hwndHeight + 0.5;
        imgWidth = hwndWidth;
        imgHeight = screenRate / imgRate* hwndHeight + 0.5;
    }
    */
}

bool TXLiveAvVideoView::AppendVideoFrame(unsigned char * data, uint32_t length, uint32_t width, uint32_t height, TRTCVideoPixelFormat videoFormat, TRTCVideoRotation rotation)
{
    if (bFirstFrame == false)
    {
        bFirstFrame = true;
        LINFO(L"TXLiveAvVideoView::AppendVideoFrame m_userId[%s], bFirstFrame = true\n", UTF82Wide(m_userId).c_str());
    }
    if (m_bPause)
        return false;
    if (data == nullptr)
        return false;
    if (videoFormat == TRTCVideoPixelFormat_BGRA32 && length != width * height * 4)
        return false;
    if (videoFormat == TRTCVideoPixelFormat_I420 && length != width * height * 3 / 2) //当下不支持YUV
        return false;

    if (videoFormat == TRTCVideoPixelFormat_I420)
    {
        CCSGuard guard(m_viewCs);
        if (m_argbSrcFrame.frameBuf == nullptr || m_argbSrcFrame.width != width || m_argbSrcFrame.height != height)
        {
            releaseBuffer(m_argbSrcFrame);
            m_argbSrcFrame.width = width;
            m_argbSrcFrame.height = height;
            m_argbSrcFrame.frameBuf = new unsigned char[width * height * 4 + 16];
        }
        //转码
        unsigned char* src_y = data;
        int y_stride = width;

        unsigned char* src_u = data + width * height;
        int u_stride = width / 2;

        unsigned char* src_v = data + width * height * 5 / 4;
        int v_stride = width / 2;

        int argb_stride = width * 4;

        libyuv::I420ToARGB(src_y, y_stride,
            src_u, u_stride,
            src_v, v_stride,
            m_argbSrcFrame.frameBuf,
            argb_stride,
            width, height);
        //::memcpy(m_argbSrcFrame.frameBuf, data, length);
        m_argbSrcFrame.newFrame = true;
        m_argbSrcFrame.rotation = rotation;
    }
    else
    {
        CCSGuard guard(m_viewCs);
        if (m_argbSrcFrame.frameBuf == nullptr || m_argbSrcFrame.width != width || m_argbSrcFrame.height != height)
        {
            releaseBuffer(m_argbSrcFrame);
            m_argbSrcFrame.width = width;
            m_argbSrcFrame.height = height;
            m_argbSrcFrame.frameBuf = new unsigned char[length];
        }
        ::memcpy(m_argbSrcFrame.frameBuf, data, length);
        m_argbSrcFrame.newFrame = true;
        m_argbSrcFrame.rotation = rotation;
    }


    if (m_hWnd)
        ::PostMessage(m_hWnd, m_nDefineMsg, m_argbSrcFrame.width, m_argbSrcFrame.height);


    dwLastAppendFrameTicket = ::GetTickCount();
    if (dwLastCntTicket == 0)
        dwLastCntTicket = ::GetTickCount();
    nCntSDKFps++;

    if (::GetTickCount() - dwLastCntTicket > 4000)
    {
        dwLastCntTicket = ::GetTickCount();
        //LINFO(L"TXLiveAvVideoView m_userId[%s], nCntPaint[%d], nCntPaintFps[%d], nCntSDKFps[%d]\n",UTF82Wide(m_userId).c_str(),nCntPaint / 4, nCntPaintFps / 4, nCntSDKFps / 4);
        nCntPaintFps = 0;
        nCntSDKFps = 0;
        nCntPaint = 0;
    }
    return true;
}

void TXLiveAvVideoView::DoEvent(TEventUI & event)
{
    CControlUI::DoEvent(event);
    /*
    if (event.Type == UIEVENT_TIMER)
    {
        if (event.wParam == m_nTimerID)
        {
            DWORD curTicket = ::GetTickCount();
            if (dwLastAppendFrameTicket > 0 && curTicket - dwLastAppendFrameTicket > 3000)
            {
                NeedUpdate();
            }
        }
    }
    */
}

bool TXLiveAvVideoView::DoPaintText(HDC hDC, const RECT& rcText, const RECT& rcLog, bool bDrawAVFrame)
{
    if (m_userId.compare("") == 0 && g_nStyleDashboard == EViewDashboardNoVisible)
        return false;

    Gdiplus::Graphics guard(hDC);
    guard.SetTextRenderingHint(Gdiplus::TextRenderingHintAntiAlias);
    if (m_userId.compare("") != 0)
    {
        if (bDrawAVFrame == false || m_bPause)
        {
            int fontSize = GetPauseNameFontSize(rcText);
            Gdiplus::FontFamily fontFamily(L"微软雅黑");
            Gdiplus::Font font(&fontFamily, fontSize, Gdiplus::FontStyleRegular, Gdiplus::UnitPixel);
            StringFormat stringformat;
            stringformat.SetAlignment(Gdiplus::StringAlignmentCenter);
            stringformat.SetLineAlignment(Gdiplus::StringAlignmentCenter);
            Gdiplus::SolidBrush brush(Color(255, 255, 255, 255));
            std::wstring text = UTF82Wide(m_userId);
            guard.DrawString(text.c_str(), -1, &font, Gdiplus::RectF(rcText.left, rcText.top, rcText.right - rcText.left, rcText.bottom - rcText.top), &stringformat, &brush);
        }
        else
        {
            //int fontSize = GetNameFontSize(rcText);
            //Gdiplus::FontFamily fontFamily(L"微软雅黑");
            //Gdiplus::Font font(&fontFamily, fontSize, Gdiplus::FontStyleBold, Gdiplus::UnitPixel);
            //StringFormat stringformat;
            //stringformat.SetAlignment(Gdiplus::StringAlignmentNear);
            //stringformat.SetLineAlignment(Gdiplus::StringAlignmentCenter);
            //Gdiplus::SolidBrush brush(Color(255, 255, 255, 255));
            //std::wstring text = UTF82Wide(m_userId);
            //guard.DrawString(text.c_str(), -1, &font, Gdiplus::RectF(rcText.left + 5, rcText.top + 10, rcText.right - rcText.left, 20), &stringformat, &brush);
        }
    }

    std::wstring dashboardText = L"";
    {
        for (auto& itr : g_mapDashboardLogText)
        {
            if (itr.first == std::make_pair(m_userId, m_type))
            {
                dashboardText = itr.second;
                break;
            }
        }
    }

    if (dashboardText.compare(L"") != 0 && g_nStyleDashboard > EViewDashboardNoVisible)
    {
        int fontSize = GetLogFontSize(rcLog);
        Gdiplus::FontFamily fontFamily(L"微软雅黑");
        Gdiplus::Font font(&fontFamily, fontSize, Gdiplus::FontStyleRegular, Gdiplus::UnitPixel);
        StringFormat stringformat;
        stringformat.SetAlignment(Gdiplus::StringAlignmentNear);
        stringformat.SetLineAlignment(Gdiplus::StringAlignmentNear);
        Gdiplus::SolidBrush brush(Color(255, 235, 10, 60));
        guard.DrawString(dashboardText.c_str(), -1, &font, Gdiplus::RectF(rcLog.left + 5, rcLog.top + 5, rcLog.right - rcLog.left, rcLog.bottom - rcLog.top), &stringformat, &brush);
    }

    std::wstring eventText = L"";
    size_t eventCnt = 0;
    {
        for (auto& itr : g_mapEventLogText)
        {
            if (itr.first == std::make_pair(m_userId, m_type))
            {
                int logCnt = (rcLog.bottom - rcLog.top - 140) / 20; //20像素一条消息
                eventCnt = itr.second.size();
                int i = 0;
                if (eventCnt > logCnt)
                    i = eventCnt - logCnt;
                for (; i < eventCnt; i++)
                {
                    eventText += itr.second[i];
                    eventText += L"\n";
                }
                break;
            }
        }
    }

    if (eventCnt > 0 && g_nStyleDashboard > EViewDashboardShowDashboard)
    {
        int fontSize = GetLogFontSize(rcLog);
        Gdiplus::FontFamily fontFamily(L"微软雅黑");
        Gdiplus::Font font(&fontFamily, fontSize, Gdiplus::FontStyleRegular, Gdiplus::UnitPixel);
        StringFormat stringformat;
        stringformat.SetAlignment(Gdiplus::StringAlignmentNear);
        stringformat.SetLineAlignment(Gdiplus::StringAlignmentNear);
        Gdiplus::SolidBrush brush(Color(255, 235, 10, 60));
        guard.DrawString(eventText.c_str(), -1, &font, Gdiplus::RectF(rcLog.left + 5, rcLog.top + 140, 500, rcLog.bottom - rcLog.top - 5), &stringformat, &brush);
    }
    return false;
}


std::wstring TXLiveAvVideoView::UTF82Wide(const std::string& strUTF8)
{
    int nWide = ::MultiByteToWideChar(CP_UTF8, 0, strUTF8.c_str(), strUTF8.size(), NULL, 0);

    std::unique_ptr<wchar_t[]> buffer(new wchar_t[nWide + 1]);
    if (!buffer)
    {
        return L"";
    }

    ::MultiByteToWideChar(CP_UTF8, 0, strUTF8.c_str(), strUTF8.size(), buffer.get(), nWide);
    buffer[nWide] = L'\0';

    return buffer.get();
}

int TXLiveAvVideoView::GetNameFontSize(const RECT & rcImage)
{
    int reference = rcImage.right - rcImage.left;
    if (reference > rcImage.bottom - rcImage.top)
        reference = rcImage.bottom - rcImage.top;
    if (reference <= 150)
        return 16;
    if (reference <= 300)
        return 17;
    if (reference <= 450)
        return 18;
    if (reference <= 600)
        return 19;
    if (reference <= 750)
        return 20;
    return 22;
}

int TXLiveAvVideoView::GetPauseNameFontSize(const RECT & rcImage)
{
    int reference = rcImage.right - rcImage.left;
    if (reference > rcImage.bottom - rcImage.top)
        reference = rcImage.bottom - rcImage.top;
    if (reference <= 150)
        return 20;
    if (reference <= 300)
        return 24;
    if (reference <= 450)
        return 26;
    if (reference <= 600)
        return 28;
    if (reference <= 750)
        return 30;
    return 32;
}

int TXLiveAvVideoView::GetLogFontSize(const RECT & rcImage)
{
    int reference = rcImage.right - rcImage.left;
    if (reference > rcImage.bottom - rcImage.top)
        reference = rcImage.bottom - rcImage.top;
    if (reference <= 150)
        return 10;
    return 16;
}

bool TXLiveAvVideoView::resetBuffer(int srcWidth, int srcHeight, int& dstWidth, int& dstHeight, unsigned char ** dstBuffer)
{
    if (dstWidth != srcWidth || dstHeight != srcHeight || (*dstBuffer) == nullptr)
    {
        unsigned char * buffer = (*dstBuffer);
        if (buffer)
        {
            delete[]buffer;
            buffer = nullptr;
        }
        (*dstBuffer) = new unsigned char[(srcWidth + 1) * srcHeight * 4];
        dstWidth = srcWidth;
        dstHeight = srcHeight;
        return true;
    }
    return false;
}

void TXLiveAvVideoView::releaseBuffer(AVFrameBufferInfo & info)
{
    if (info.frameBuf != nullptr)
    {
        delete[] info.frameBuf;
        info.frameBuf = nullptr;
    }
    info.height = 0;
    info.width = 0;
    info.newFrame = false;
    info.rotation = TRTCVideoRotation0;
}

int TXLiveAvVideoView::getRotationAngle(TRTCVideoRotation rotatio)
{
    switch (rotatio)
    {
    case TRTCVideoRotation0:
        return 0;
    case TRTCVideoRotation90:
        return 90;
    case TRTCVideoRotation180:
        return 180;
    case TRTCVideoRotation270:
        return 270;
    default:
        return 0;
    }
}
