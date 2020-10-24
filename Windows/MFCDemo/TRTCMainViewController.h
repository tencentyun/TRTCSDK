/*
* Module:   TRTCMainViewController
*
* Function: 使用TRTC SDK完成 1v1 和 1vn 的视频通话功能
*
*    1. 支持九宫格平铺和前后叠加两种不同的视频画面布局方式，该部分由 TRTCVideoViewLayout 来计算每个视频画面的位置排布和大小尺寸
*
*    2. 支持对视频通话的分辨率、帧率和流畅模式进行调整，该部分由 TRTCSettingViewController 来实现
*
*    3. 创建或者加入某一个通话房间，需要先指定 roomid 和 userid，这部分由 TRTCNewViewController 来实现
*/

#pragma once

#include "ITRTCCloud.h"

#include <string>
#include <functional>
#include <map>

#pragma warning(disable : 4996)

ITRTCCloud* getTRTCCloud();
void destroyTRTCCloud();
// CTRTCDemoDlg 对话框
class TRTCSettingViewController;
class TRTCMainViewController
    : public CDialogEx
    , public ITRTCCloudCallback
    , public ITRTCVideoRenderCallback
{
    // 构造
public:
    TRTCMainViewController(CWnd* pParent = NULL);	// 标准构造函数

// 对话框数据
#ifdef AFX_DESIGN_TIME
    enum { IDD = IDD_TESTTRTCAPP_DIALOG };
#endif

public:
    void enterRoom(TRTCParams& params);

protected:
    virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV 支持
    virtual BOOL OnInitDialog();
// 实现
protected:
    CFont newFont;
    HICON m_hIcon;
    int m_roomId = 0;
    std::map<int, std::string> view_info_;
    TRTCSettingViewController *m_pTRTCSettingViewController = nullptr;
    // 生成的消息映射函数
    int m_showDebugView = 0;
    DECLARE_MESSAGE_MAP()
protected:
    virtual void onError(TXLiteAVError errCode, const char* errMsg, void* arg);
    virtual void onWarning(TXLiteAVWarning warningCode, const char* warningMsg, void* arg);
    virtual void onEnterRoom(int result);
    virtual void onExitRoom(int reason);
    virtual void onUserEnter(const char* userId);
    virtual void onUserExit(const char* userId, int reason);
private:
    int FindIdleVideoView();
    int FindOccupyVideoView(std::string userId);
    void UpdateVideoViewInfo(int id, std::string userId);
public:
    static ITRTCCloud* g_cloud;
    afx_msg void OnClose();
    afx_msg HBRUSH OnCtlColor(CDC* pDC, CWnd* pWnd, UINT nCtlColor);
    afx_msg LRESULT OnMsgSettingViewClose(WPARAM wParam, LPARAM lParam);
    afx_msg void OnBnClickedExitRoom();
    afx_msg void OnBnClickedSetting();
    afx_msg void OnBnClickedLog();
    afx_msg void OnBnClickedSwapRenderView();

    std::string m_userId;
};
