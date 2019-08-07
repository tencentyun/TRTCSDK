/*
* Module:   TRTCVideoViewLayout
*
* Function: 用于对视频通话的分辨率、帧率和流畅模式进行调整，并支持记录下这些设置项
*
*/

#include "stdafx.h"
#include "afxdialogex.h"
#include "TRTCDemo.h"
#include "util/Base.h"
#include "StorageConfigMgr.h"

#include "TRTCSettingViewController.h"
#include "TRTCMainViewController.h"

// TRTCSettingViewController 对话框

IMPLEMENT_DYNAMIC(TRTCSettingViewController, CDialogEx)

TRTCSettingViewController::TRTCSettingViewController(CWnd* pParent /*=NULL*/)
	: CDialogEx(IDD_DIALOG_SETTING, pParent)
{
    m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

TRTCSettingViewController::~TRTCSettingViewController()
{
}

void TRTCSettingViewController::DoDataExchange(CDataExchange* pDX)
{
    CDialogEx::DoDataExchange(pDX);
    DDX_Control(pDX, IDC_COMBO_RESOLUTION, m_resolutionCombo);
    DDX_Control(pDX, IDC_COMBO_FPS, m_fpsCombo);
    DDX_Control(pDX, IDC_COMBO_QUALITY, m_qualityCombo);
    DDX_Control(pDX, IDC_COMBO_SENSE, m_senseCombo);
    DDX_Control(pDX, IDC_SLIDER_BITRATE, m_bitrateSlider);
    DDX_Control(pDX, IDC_CHECK_PUSH_SAMLL_VIDEO, m_pushSmallVideoCheck);
    DDX_Control(pDX, IDC_CHECK_PLAY_SAMLL_VIDEO, m_playSmallVideoCheck);
}


BEGIN_MESSAGE_MAP(TRTCSettingViewController, CDialogEx)
    ON_BN_CLICKED(IDC_BUTTON_SAVE, &TRTCSettingViewController::OnBnClickedButtonSave)
    ON_BN_CLICKED(IDC_BUTTON_CLOSE, &TRTCSettingViewController::OnBnClickedButtonClose)
    ON_CBN_SELCHANGE(IDC_COMBO_RESOLUTION, &TRTCSettingViewController::OnCbnSelchangeComboResolution)
    ON_BN_CLICKED(IDC_CHECK_PUSH_SAMLL_VIDEO, &TRTCSettingViewController::OnBnClickedCheckPushSamllVideo)
    ON_BN_CLICKED(IDC_CHECK_PLAY_SAMLL_VIDEO, &TRTCSettingViewController::OnBnClickedCheckPlaySamllVideo)
    ON_CBN_SELCHANGE(IDC_COMBO_FPS, &TRTCSettingViewController::OnCbnSelchangeComboFps)
    ON_CBN_SELCHANGE(IDC_COMBO_QUALITY, &TRTCSettingViewController::OnCbnSelchangeComboQuality)
    ON_CBN_SELCHANGE(IDC_COMBO_SENSE, &TRTCSettingViewController::OnCbnSelchangeComboSense)
    ON_WM_HSCROLL()
END_MESSAGE_MAP()

BOOL TRTCSettingViewController::OnInitDialog()
{
    CDialogEx::OnInitDialog();
    newFont.CreatePointFont(120, L"微软雅黑");
    InitStorageConfig();
    InitVideoTableConfig();
    m_resolutionCombo.SetFont(&newFont);
    m_fpsCombo.SetFont(&newFont);
    m_qualityCombo.SetFont(&newFont);
    m_senseCombo.SetFont(&newFont);
    m_bitrateSlider.SetFont(&newFont);
    m_pushSmallVideoCheck.SetFont(&newFont);
    m_playSmallVideoCheck.SetFont(&newFont);

    TRTCSettingBitrateTable& info1 = m_videoConfigMap[TRTCVideoResolution_320_180];
    info1.init(250, 100, 300);
    TRTCSettingBitrateTable& info2 = m_videoConfigMap[TRTCVideoResolution_320_240];
    info2.init(250, 100, 300);
    TRTCSettingBitrateTable& info3 = m_videoConfigMap[TRTCVideoResolution_640_360];
    info3.init(500, 200, 800);
    TRTCSettingBitrateTable& info4 = m_videoConfigMap[TRTCVideoResolution_640_480];
    info4.init(500, 200, 800);
    TRTCSettingBitrateTable& info5 = m_videoConfigMap[TRTCVideoResolution_960_540];
    info5.init(800, 400, 1000);
    TRTCSettingBitrateTable& info6 = m_videoConfigMap[TRTCVideoResolution_1280_720];
    info6.init(1000, 500, 2500);

    m_resolutionCombo.AddString(L"320 x 180");
    m_resolutionCombo.AddString(L"320 x 240");
    m_resolutionCombo.AddString(L"640 x 360");
    m_resolutionCombo.AddString(L"640 x 480");
    m_resolutionCombo.AddString(L"960 x 540");
    m_resolutionCombo.AddString(L"1280 x 720");
    if (m_videoEncParams.videoResolution == TRTCVideoResolution_320_180)
        m_resolutionCombo.SetCurSel(0);
    if (m_videoEncParams.videoResolution == TRTCVideoResolution_320_240)
        m_resolutionCombo.SetCurSel(1);
    if (m_videoEncParams.videoResolution == TRTCVideoResolution_640_360)
        m_resolutionCombo.SetCurSel(2);
    if (m_videoEncParams.videoResolution == TRTCVideoResolution_640_480)
        m_resolutionCombo.SetCurSel(3);
    if (m_videoEncParams.videoResolution == TRTCVideoResolution_960_540)
        m_resolutionCombo.SetCurSel(4);
    if (m_videoEncParams.videoResolution == TRTCVideoResolution_1280_720)
        m_resolutionCombo.SetCurSel(5);

    m_fpsCombo.AddString(L"15 fps");
    m_fpsCombo.AddString(L"20 fps");
    m_fpsCombo.AddString(L"24 fps");
    if (m_videoEncParams.videoFps == 15)
        m_fpsCombo.SetCurSel(0);
    if (m_videoEncParams.videoFps == 20)
        m_fpsCombo.SetCurSel(1);
    if (m_videoEncParams.videoFps == 24)
        m_fpsCombo.SetCurSel(2);

    m_qualityCombo.AddString(L"流畅");
    m_qualityCombo.AddString(L"清晰");
    if (m_qosParams.preference == TRTCVideoQosPreferenceSmooth)
        m_qualityCombo.SetCurSel(0);
    if (m_qosParams.preference == TRTCVideoQosPreferenceClear)
        m_qualityCombo.SetCurSel(1);

    m_senseCombo.AddString(L"在线直播");
    m_senseCombo.AddString(L"视频通话");
    if (m_appScene == TRTCAppSceneLIVE )
        m_senseCombo.SetCurSel(0);
    if (m_appScene == TRTCAppSceneVideoCall)
        m_senseCombo.SetCurSel(1);

    TRTCSettingBitrateTable sliderInfo = getVideoConfigInfo(m_videoEncParams.videoResolution);
    m_bitrateSlider.SetRange(sliderInfo.minBitrate, sliderInfo.maxBitrate);
    if (m_videoEncParams.videoBitrate < sliderInfo.minBitrate)
        m_videoEncParams.videoBitrate = sliderInfo.minBitrate;
    if (m_videoEncParams.videoBitrate > sliderInfo.maxBitrate)
        m_videoEncParams.videoBitrate = sliderInfo.maxBitrate;
    int bitrate_value = m_videoEncParams.videoBitrate;
    m_bitrateSlider.SetPos(bitrate_value);
    std::wstring bitrateStr = format(L"%d kbps", m_videoEncParams.videoBitrate);
    SetDlgItemTextW(IDC_STATIC_BITRATE, bitrateStr.c_str());

    if (m_bPushSmallVideo)
    {
        m_pushSmallVideoCheck.SetCheck(1);
    }

    if (m_bPlaySmallVideo)
    {
        m_playSmallVideoCheck.SetCheck(1);
    }

    CWnd *pSaveBtn = GetDlgItem(IDC_BUTTON_SAVE);
    if (pSaveBtn)
    {
        pSaveBtn->EnableWindow(FALSE);
        pSaveBtn->SetFont(&newFont);
    }

    CWnd *pCloseBtn = GetDlgItem(IDC_BUTTON_CLOSE);
    if (pCloseBtn)
        pCloseBtn->SetFont(&newFont);

    {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_RESOLUTION);
        pStatic->SetFont(&newFont);
    }
    {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_FPS);
        pStatic->SetFont(&newFont);
    }
    {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_QUALITY);
        pStatic->SetFont(&newFont);
    }
    {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_TEXT_BIT);
        pStatic->SetFont(&newFont);
    }
    {
        CWnd *pStatic = GetDlgItem(IDC_STATIC_BITRATE);
        pStatic->SetFont(&newFont);
    }

    CRect rtDesk, rtDlg;
    ::GetWindowRect(::GetDesktopWindow(), &rtDesk);
    GetWindowRect(&rtDlg);
    int iXPos = rtDesk.Width() / 2 - rtDlg.Width() / 2;
    int iYPos = rtDesk.Height() / 2 - rtDlg.Height() / 2;
    SetWindowPos(NULL, iXPos, iYPos, 0, 0, SWP_NOOWNERZORDER | SWP_NOSIZE | SWP_NOZORDER);
    return TRUE;  // 除非将焦点设置到控件，否则返回 TRUE
    return 0;
}

void TRTCSettingViewController::OnBnClickedButtonSave()
{
    TRTCVideoEncParam& _videoEncParams = TRTCStorageConfigMgr::GetInstance()->videoEncParams;
    TRTCNetworkQosParam& _qosParams = TRTCStorageConfigMgr::GetInstance()->qosParams;
    if (_videoEncParams.videoBitrate != m_videoEncParams.videoBitrate ||
        _videoEncParams.videoFps != m_videoEncParams.videoFps ||
        _videoEncParams.videoResolution != m_videoEncParams.videoResolution)
    {
        getTRTCCloud()->setVideoEncoderParam(m_videoEncParams);
    }

    if (_qosParams.controlMode != m_qosParams.controlMode || _qosParams.preference != m_qosParams.preference)
    {
        getTRTCCloud()->setNetworkQosParam(m_qosParams);
    }

    bool _bPushSmallVideo = TRTCStorageConfigMgr::GetInstance()->bPushSmallVideo;
    if (_bPushSmallVideo != m_bPushSmallVideo)
    {
        TRTCVideoEncParam param;
        param.videoFps = 15;
        param.videoBitrate = 100;
        param.videoResolution = TRTCVideoResolution_320_240;
        bool bEnable = true;
        if (m_bPushSmallVideo == false)
            bEnable = false;
        getTRTCCloud()->enableSmallVideoStream(bEnable, param);
    }

    bool _bPlaySmallVideo = TRTCStorageConfigMgr::GetInstance()->bPlaySmallVideo;
    if (_bPlaySmallVideo != m_bPlaySmallVideo)
    {
        if (m_bPlaySmallVideo)
            getTRTCCloud()->setPriorRemoteVideoStreamType(TRTCVideoStreamTypeSmall);
        else
            getTRTCCloud()->setPriorRemoteVideoStreamType(TRTCVideoStreamTypeBig);
    }

    TRTCStorageConfigMgr::GetInstance()->videoEncParams = m_videoEncParams;
    TRTCStorageConfigMgr::GetInstance()->qosParams = m_qosParams;
    TRTCStorageConfigMgr::GetInstance()->bPushSmallVideo = m_bPushSmallVideo;
    TRTCStorageConfigMgr::GetInstance()->bPlaySmallVideo = m_bPlaySmallVideo;
    TRTCStorageConfigMgr::GetInstance()->appScene = m_appScene;

    CWnd *pSaveBtn = GetDlgItem(IDC_BUTTON_SAVE);
    if (pSaveBtn)
        pSaveBtn->EnableWindow(FALSE);
}

void TRTCSettingViewController::OnBnClickedButtonClose()
{
    CWnd* pWnd = GetParent();
    if (pWnd)
        ::PostMessage(pWnd->GetSafeHwnd(), WM_CUSTOM_CLOSE_SETTINGVIEW, 0, 0);
}


void TRTCSettingViewController::OnCbnSelchangeComboResolution()
{
    DWORD nIndex = m_resolutionCombo.GetCurSel();
    if (nIndex == 0)
        m_videoEncParams.videoResolution = TRTCVideoResolution_320_180;
    if (nIndex == 1)
        m_videoEncParams.videoResolution = TRTCVideoResolution_320_240;
    if (nIndex == 2)
        m_videoEncParams.videoResolution = TRTCVideoResolution_640_360;
    if (nIndex == 3)
        m_videoEncParams.videoResolution = TRTCVideoResolution_640_480;
    if (nIndex == 4)
        m_videoEncParams.videoResolution = TRTCVideoResolution_960_540;
    if (nIndex == 5)
        m_videoEncParams.videoResolution = TRTCVideoResolution_1280_720;


    TRTCSettingBitrateTable sliderInfo = getVideoConfigInfo(m_videoEncParams.videoResolution);
    m_bitrateSlider.SetRange(sliderInfo.minBitrate, sliderInfo.maxBitrate, TRUE);
    m_bitrateSlider.SetPos(sliderInfo.videoBitrate);
    m_videoEncParams.videoBitrate = sliderInfo.videoBitrate;
    std::wstring bitrateStr = format(L"%d kbps", m_videoEncParams.videoBitrate);
    SetDlgItemTextW(IDC_STATIC_BITRATE, bitrateStr.c_str());

    CWnd *pSaveBtn = GetDlgItem(IDC_BUTTON_SAVE);
    if (pSaveBtn)
        pSaveBtn->EnableWindow(TRUE);
}

void TRTCSettingViewController::InitStorageConfig()
{
    m_videoEncParams = TRTCStorageConfigMgr::GetInstance()->videoEncParams;
    m_qosParams = TRTCStorageConfigMgr::GetInstance()->qosParams;
    m_bPushSmallVideo = TRTCStorageConfigMgr::GetInstance()->bPushSmallVideo;
    m_bPlaySmallVideo = TRTCStorageConfigMgr::GetInstance()->bPlaySmallVideo;
    m_appScene = TRTCStorageConfigMgr::GetInstance()->appScene;
}

void TRTCSettingViewController::InitVideoTableConfig()
{
    TRTCSettingBitrateTable& info1 = m_videoConfigMap[TRTCVideoResolution_320_180];
    info1.init(200, 100, 200);
    TRTCSettingBitrateTable& info2 = m_videoConfigMap[TRTCVideoResolution_320_240];
    info2.init(250, 100, 300);
    TRTCSettingBitrateTable& info3 = m_videoConfigMap[TRTCVideoResolution_640_360];
    info3.init(500, 200, 800);
    TRTCSettingBitrateTable& info4 = m_videoConfigMap[TRTCVideoResolution_640_480];
    info4.init(500, 200, 800);
    TRTCSettingBitrateTable& info5 = m_videoConfigMap[TRTCVideoResolution_960_540];
    info5.init(800, 400, 1000);
    TRTCSettingBitrateTable& info6 = m_videoConfigMap[TRTCVideoResolution_1280_720];
    info6.init(1000, 500, 1500);
}

TRTCSettingBitrateTable TRTCSettingViewController::getVideoConfigInfo(int resolution)
{
    if (m_videoConfigMap.find(resolution) != m_videoConfigMap.end())
    {
        return m_videoConfigMap[resolution];
    }
    TRTCSettingBitrateTable info;
    return info;
}

void TRTCSettingViewController::OnBnClickedCheckPushSamllVideo()
{
    int nState = ((CButton*)GetDlgItem(IDC_CHECK_PUSH_SAMLL_VIDEO))->GetCheck();
    if (nState == BST_CHECKED)
    {
        m_bPushSmallVideo = true;
    }
    else
    {
        m_bPushSmallVideo = false;
    }
    CWnd *pSaveBtn = GetDlgItem(IDC_BUTTON_SAVE);
    if (pSaveBtn)
        pSaveBtn->EnableWindow(TRUE);
}

void TRTCSettingViewController::OnBnClickedCheckPlaySamllVideo()
{
    int nState = ((CButton*)GetDlgItem(IDC_CHECK_PLAY_SAMLL_VIDEO))->GetCheck();
    if (nState == BST_CHECKED)
    {
        m_bPlaySmallVideo = true;
    }
    else
    {
        m_bPlaySmallVideo = false;
    }
    CWnd *pSaveBtn = GetDlgItem(IDC_BUTTON_SAVE);
    if (pSaveBtn)
        pSaveBtn->EnableWindow(TRUE);
}


void TRTCSettingViewController::OnCbnSelchangeComboFps()
{
    // TODO: 在此添加控件通知处理程序代码
    DWORD nIndex = m_fpsCombo.GetCurSel();
    if (nIndex == 0)
        m_videoEncParams.videoFps = 15;
    if (nIndex == 1)
        m_videoEncParams.videoFps = 20;
    if (nIndex == 2)
        m_videoEncParams.videoFps = 24;

    CWnd *pSaveBtn = GetDlgItem(IDC_BUTTON_SAVE);
    if (pSaveBtn)
        pSaveBtn->EnableWindow(TRUE);
}


void TRTCSettingViewController::OnCbnSelchangeComboQuality()
{
    // TODO: 在此添加控件通知处理程序代码
    DWORD nIndex = m_qualityCombo.GetCurSel();
    if (nIndex == 0)
        m_qosParams.preference = TRTCVideoQosPreferenceSmooth;
    if (nIndex == 1)
        m_qosParams.preference = TRTCVideoQosPreferenceClear;

    CWnd *pSaveBtn = GetDlgItem(IDC_BUTTON_SAVE);
    if (pSaveBtn)
        pSaveBtn->EnableWindow(TRUE);
}



void TRTCSettingViewController::OnCbnSelchangeComboSense()
{
    // TODO: 在此添加控件通知处理程序代码
    DWORD nIndex = m_senseCombo.GetCurSel();
    if (nIndex == 0)
        m_appScene = TRTCAppSceneLIVE;
    if (nIndex == 1)
        m_appScene = TRTCAppSceneVideoCall;

    CWnd *pSaveBtn = GetDlgItem(IDC_BUTTON_SAVE);
    if (pSaveBtn)
        pSaveBtn->EnableWindow(TRUE);
}


void TRTCSettingViewController::OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar)
{
    // TODO: 在此添加消息处理程序代码和/或调用默认值
    CDialogEx::OnHScroll(nSBCode, nPos, pScrollBar);
    if (pScrollBar->GetDlgCtrlID() == IDC_SLIDER_BITRATE)
    {
        int nPos = ((CSliderCtrl*)pScrollBar)->GetPos();
        int bitrate_value = nPos;
        std::wstring bitrateStr = format(L"%d kbps", bitrate_value);
        SetDlgItemTextW(IDC_STATIC_BITRATE, bitrateStr.c_str());
        m_videoEncParams.videoBitrate = bitrate_value;

        CWnd *pSaveBtn = GetDlgItem(IDC_BUTTON_SAVE);
        if (pSaveBtn)
            pSaveBtn->EnableWindow(TRUE);
    }
}