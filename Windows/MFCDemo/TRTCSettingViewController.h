#pragma once
#include "afxwin.h"
#include "TRTCCloudDef.h"
#include "afxcmn.h"
#include <map>
/*
* Module:   TRTCVideoViewLayout
*
* Function: 用于对视频通话的分辨率、帧率和流畅模式进行调整，并支持记录下这些设置项
*
*/

struct TRTCSettingBitrateTable
{
public:
    int videoBitrate = 500;
    int minBitrate = 800;
    int maxBitrate = 200;
public:
    void init(int bitrate, int minBit, int maxBit)
    {
        videoBitrate = bitrate;
        minBitrate = minBit;
        maxBitrate = maxBit;
    }
};

class TRTCSettingViewController : public CDialogEx
{
	DECLARE_DYNAMIC(TRTCSettingViewController)

public:
	TRTCSettingViewController(CWnd* pParent = NULL);   // 标准构造函数
	virtual ~TRTCSettingViewController();

// 对话框数据
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_DIALOG_SETTING };
#endif

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV 支持
    virtual BOOL OnInitDialog();
	DECLARE_MESSAGE_MAP()
public:
    afx_msg void OnBnClickedButtonSave();
    afx_msg void OnBnClickedButtonClose();
    afx_msg void OnCbnSelchangeComboResolution();
    afx_msg void OnBnClickedCheckPushSamllVideo();
    afx_msg void OnBnClickedCheckPlaySamllVideo();
    afx_msg void OnCbnSelchangeComboFps();
    afx_msg void OnCbnSelchangeComboQuality();
    afx_msg void OnCbnSelchangeComboSense();
    afx_msg void OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);

    CComboBox m_resolutionCombo;
    CComboBox m_fpsCombo;
    CComboBox m_qualityCombo;
    CComboBox m_senseCombo;
    CSliderCtrl m_bitrateSlider;
    CButton m_pushSmallVideoCheck;
    CButton m_playSmallVideoCheck;
    HICON m_hIcon;
    CFont newFont;
protected:
    void InitStorageConfig();
    void InitVideoTableConfig();
    TRTCSettingBitrateTable getVideoConfigInfo(int resolution);
private:
    TRTCVideoEncParam m_videoEncParams;
    TRTCNetworkQosParam m_qosParams;
    TRTCAppScene m_appScene;
    
    bool m_bPushSmallVideo = false; //推流打开小流设置。
    bool m_bPlaySmallVideo = false; //拉流打开小流设置。
    std::map<int, TRTCSettingBitrateTable> m_videoConfigMap;
    
};
