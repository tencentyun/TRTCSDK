#pragma once
#include "afxwin.h"

/*
* Module:   TRTCLoginViewController
*
* Function: 该界面可以让用户输入一个【房间号】和一个【用户名】
*
* Notice:
*
*  （1）房间号为数字类型，用户名为字符串类型
*
*  （2）在真实的使用场景中，房间号大多不是用户手动输入的，而是由后台业务服务器直接分配的，
*       比如视频会议中的会议号是会控系统提前预定好的，客服系统中的房间号也是根据客服员工的工号决定的。
*/


// TRTCLoginViewController 对话框
class TRTCMainViewController;
class TRTCLoginViewController : public CDialogEx
{
	DECLARE_DYNAMIC(TRTCLoginViewController)

public:
	TRTCLoginViewController(CWnd* pParent = NULL);   // 标准构造函数
	virtual ~TRTCLoginViewController();

// 对话框数据
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_DIALOG_TRTC_LOGIN };
#endif
public:
    //加入房间
    void joinRoom(int roomId);
    
protected:
    virtual BOOL OnInitDialog();
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV 支持
    virtual void OnCancel();
	DECLARE_MESSAGE_MAP()
protected:
    afx_msg void OnBnClickedEnterRoom();
    afx_msg LRESULT OnMsgMainViewClose(WPARAM wParam, LPARAM lParam);
private:
    CFont newFont;
    TRTCMainViewController * m_pTRTCMainViewController = nullptr;
};
