/*
* Module:   TRTCMainViewController
*
* Function: ʹ��TRTC SDK��� 1v1 �� 1vn ����Ƶͨ������
*
*    1. ֧�־Ź���ƽ�̺�ǰ��������ֲ�ͬ����Ƶ���沼�ַ�ʽ���ò����� TRTCVideoViewLayout ������ÿ����Ƶ�����λ���Ų��ʹ�С�ߴ�
*
*    2. ֧�ֶ���Ƶͨ���ķֱ��ʡ�֡�ʺ�����ģʽ���е������ò����� TRTCSettingViewController ��ʵ��
*
*    3. �������߼���ĳһ��ͨ�����䣬��Ҫ��ָ�� roomid �� userid���ⲿ���� TRTCNewViewController ��ʵ��
*/

#pragma once

#include "ITRTCCloud.h"

#include <string>
#include <functional>
#include <map>

#pragma warning(disable : 4996)

ITRTCCloud* getTRTCCloud();
void destroyTRTCCloud();
// CTRTCDemoDlg �Ի���
class TRTCSettingViewController;
class TRTCMainViewController
    : public CDialogEx
    , public ITRTCCloudCallback
    , public ITRTCVideoRenderCallback
{
    // ����
public:
    TRTCMainViewController(CWnd* pParent = NULL);	// ��׼���캯��

// �Ի�������
#ifdef AFX_DESIGN_TIME
    enum { IDD = IDD_TESTTRTCAPP_DIALOG };
#endif

public:
    void enterRoom(TRTCParams& params);

protected:
    virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV ֧��
    virtual BOOL OnInitDialog();
// ʵ��
protected:
    CFont newFont;
    HICON m_hIcon;
    int m_roomId = 0;
    std::map<int, std::string> view_info_;
    TRTCSettingViewController *m_pTRTCSettingViewController = nullptr;
    // ���ɵ���Ϣӳ�亯��
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
