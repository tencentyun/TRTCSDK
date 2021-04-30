/*
* Module:   TRTCVideoViewLayout
*
* Function: 用于对视频通话的分辨率、帧率和流畅模式进行调整，并支持记录下这些设置项
*
*/

#include "StdAfx.h"
#include "TRTCSettingViewController.h"
#include "DataCenter.h"
#include "TRTCCloudCore.h"
#include "TXLiveAvVideoView.h"
#include "util/Base.h"
#include "TrtcUtil.h"
#include "util/log.h"
#include "json/json.h"
#include "TRTCCloudDef.h"
#include "UserMassegeIdDefine.h"
#include "GenerateTestUserSig.h"
#include "MsgBoxWnd.h"
#include "util/md5.h"
#include <strstream>
#include <iostream>
#include <ctime>
#include <iomanip>
#include <algorithm>
#include "UiShareSelect.h"

#define AUDIO_DEVICE_VOLUME_TICKET 100
#define AUDIO_VOLUME_TICKET 100
#define BGM_PROGRESS_TICHET 100
int TRTCSettingViewController::m_ref = 0;
std::vector<TRTCSettingViewControllerNotify*> TRTCSettingViewController::vecNotifyList;

TRTCSettingViewController::TRTCSettingViewController(SettingTagEnum tagType, HWND parentHwnd)
{
    m_eTagType = tagType;
    m_parentHwnd = parentHwnd;
    TRTCSettingViewController::addRef();

    TRTCCloudCore::GetInstance()->getTRTCCloud()->addCallback(this);
    TRTCCloudCore::GetInstance()->getTRTCCloud()->setLocalVideoRenderCallback(TRTCVideoPixelFormat_BGRA32, TRTCVideoBufferType_Buffer, (ITRTCVideoRenderCallback*)getShareViewMgrInstance());

    m_audioEffectParam1 = new TRTCAudioEffectParam(0, NULL);
    m_audioEffectParam2 = new TRTCAudioEffectParam(0, NULL);
    m_audioEffectParam3 = new TRTCAudioEffectParam(0, NULL);

    m_audioEffectParam1->publish = false;
    m_audioEffectParam2->publish = false;
    m_audioEffectParam3->publish = false;

    CDataCenter::GetInstance()->m_speakerVolume = TRTCCloudCore::GetInstance()->getDeviceManager()->getCurrentDeviceVolume(TRTCDeviceTypeSpeaker);

    is_init_windows_finished = false;
}

TRTCSettingViewController::~TRTCSettingViewController()
{
    ::KillTimer(GetHWND(), m_send_sei_timer);

    TRTCCloudCore::GetInstance()->getTRTCCloud()->removeCallback(this);

    TRTCCloudCore::GetInstance()->removeSDKMsgObserverByHwnd(GetHWND());
    TRTCSettingViewController::subRef();
    if (m_audioEffectParam1)
        delete m_audioEffectParam1;

    if (m_audioEffectParam2)
        delete m_audioEffectParam2;

    if (m_audioEffectParam3)
        delete m_audioEffectParam3;
}

void TRTCSettingViewController::preUnInit()
{
    //退出所有功能测试
    m_pVideoView->RemoveRenderInfo();
    stopAllTestSetting();

    TRTCCloudCore::GetInstance()->getTRTCCloud()->removeCallback(this);

    TRTCCloudCore::GetInstance()->removeSDKMsgObserverByHwnd(GetHWND());
}

void TRTCSettingViewController::regTRTCSettingViewControllerNotify(TRTCSettingViewControllerNotify* ptr)
{
    bool bExist = false;
    for (auto it : vecNotifyList)
    {
        if (it == ptr)
        {
            bExist = true;
            break;
        }
    }
    if (!bExist)
    {
        vecNotifyList.push_back(ptr);
    }
}

void TRTCSettingViewController::unregTRTCSettingViewControllerNotify(TRTCSettingViewControllerNotify * ptr)
{
    std::vector<TRTCSettingViewControllerNotify*>::iterator it;
    for (it = vecNotifyList.begin(); it != vecNotifyList.end();)
    {
        if (*it == ptr)
        {
            vecNotifyList.erase(it);
            break;
        }
    }
}

void TRTCSettingViewController::addRef()
{
    m_ref++;
}

void TRTCSettingViewController::subRef()
{
    m_ref--;
}

int TRTCSettingViewController::getRef()
{
    return m_ref;
}

void TRTCSettingViewController::Notify(TNotifyUI & msg)
{
    NotifyOtherTab(msg);
    NotifyAudioTab(msg);
    NotifyMixTab(msg);
    NotifyRecordTab(msg);
    NotifyAudioRecord(msg);
    NotifyLocalRecord(msg);
    NotifyVodTab(msg);

    CDuiString name = msg.pSender->GetName();
    if (msg.sType == _T("selectchanged"))  
    {
        CTabLayoutUI* pTabSwitch = static_cast<CTabLayoutUI*>(m_pmUI.FindControl(_T("tab_switch")));
        if (name.CompareNoCase(_T("normal_tab")) == 0) pTabSwitch->SelectItem(0);
        if (name.CompareNoCase(_T("video_tab")) == 0) pTabSwitch->SelectItem(1);
        if (name.CompareNoCase(_T("audio_tab")) == 0) pTabSwitch->SelectItem(2);
        if (name.CompareNoCase(_T("mix_tab")) == 0) pTabSwitch->SelectItem(3);
        if (name.CompareNoCase(_T("record_tab")) == 0) pTabSwitch->SelectItem(4);
        if (name.CompareNoCase(_T("other_tab")) == 0) pTabSwitch->SelectItem(5);
        if (name.CompareNoCase(_T("vod_tab")) == 0) pTabSwitch->SelectItem(6);
        if (name.CompareNoCase(_T("qos_smooth")) == 0) {  
            CDataCenter::GetInstance()->m_qosParams.preference = TRTCVideoQosPreferenceSmooth;

            if (TRTCCloudCore::GetInstance()->getTRTCCloud())
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setNetworkQosParam(CDataCenter::GetInstance()->m_qosParams);
            }
        }
        if (name.CompareNoCase(_T("qos_clear")) == 0) {
            CDataCenter::GetInstance()->m_qosParams.preference = TRTCVideoQosPreferenceClear;

            if (TRTCCloudCore::GetInstance()->getTRTCCloud())
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setNetworkQosParam(CDataCenter::GetInstance()->m_qosParams);
            }
        }
        if (name.CompareNoCase(_T("qos_client")) == 0) {
            CDataCenter::GetInstance()->m_qosParams.controlMode = TRTCQosControlModeClient;
            if (TRTCCloudCore::GetInstance()->getTRTCCloud())
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setNetworkQosParam(CDataCenter::GetInstance()->m_qosParams);
            }
        }
        if (name.CompareNoCase(_T("qos_cloud")) == 0) {
            CDataCenter::GetInstance()->m_qosParams.controlMode = TRTCQosControlModeServer;

            if (TRTCCloudCore::GetInstance()->getTRTCCloud())
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setNetworkQosParam(CDataCenter::GetInstance()->m_qosParams);
            }
        }
        if (name.CompareNoCase(_T("scene_live")) == 0) {
            CDataCenter::GetInstance()->m_sceneParams = TRTCAppSceneLIVE;
            //直播场景和视频通话场景默认码率值不一样。
            updateVideoBitrateUi();
            updateRoleUi();
            UpdateAudioQualityUi();
        }
        if (name.CompareNoCase(_T("scene_call")) == 0) {
            CDataCenter::GetInstance()->m_sceneParams = TRTCAppSceneVideoCall;
            CDataCenter::GetInstance()->m_roleType = TRTCRoleAnchor;
            if (CDataCenter::GetInstance()->m_localInfo._bEnterRoom)
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->switchRole(CDataCenter::GetInstance()->m_roleType);
            }
            //直播场景和视频通话场景默认码率值不一样。
            updateVideoBitrateUi();
            updateRoleUi();
            UpdateAudioQualityUi();
            LocalUserInfo& _loginInfo = CDataCenter::GetInstance()->getLocalUserInfo();
            if (_loginInfo._bEnterRoom&& is_init_windows_finished)
            {
                ::PostMessage(m_parentHwnd, WM_USER_CMD_RoleChange, (WPARAM)CDataCenter::GetInstance()->m_roleType, 0);
            }
        }
        if(name.CompareNoCase(_T("audio_scene_live")) == 0) {
            CDataCenter::GetInstance()->m_sceneParams = TRTCAppSceneVoiceChatRoom;
            //直播场景和视频通话场景默认码率值不一样。
            updateRoleUi();
            UpdateAudioQualityUi();
        }
        if(name.CompareNoCase(_T("audio_scene_call")) == 0) {
            CDataCenter::GetInstance()->m_sceneParams = TRTCAppSceneAudioCall;
            CDataCenter::GetInstance()->m_roleType = TRTCRoleAnchor;
            if(CDataCenter::GetInstance()->m_localInfo._bEnterRoom)
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->switchRole(CDataCenter::GetInstance()->m_roleType);
            }
            //直播场景和视频通话场景默认码率值不一样。
            updateRoleUi();
            UpdateAudioQualityUi();
            LocalUserInfo& _loginInfo = CDataCenter::GetInstance()->getLocalUserInfo();
            if (_loginInfo._bEnterRoom&& is_init_windows_finished)
            {
                ::PostMessage(m_parentHwnd, WM_USER_CMD_RoleChange, (WPARAM)CDataCenter::GetInstance()->m_roleType, 0);
            }
        }
        if (name.CompareNoCase(_T("role_anchor")) == 0) {
            CDataCenter::GetInstance()->m_roleType = TRTCRoleAnchor;
            CHorizontalLayoutUI* pHLayout = static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("livetype")));
            pHLayout->SetVisible(false);


            if (CDataCenter::GetInstance()->m_localInfo._bEnterRoom)
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->switchRole(CDataCenter::GetInstance()->m_roleType);
            }
            LocalUserInfo& _loginInfo = CDataCenter::GetInstance()->getLocalUserInfo();
            if (_loginInfo._bEnterRoom&& is_init_windows_finished)
            {
                ::PostMessage(m_parentHwnd, WM_USER_CMD_RoleChange, (WPARAM)CDataCenter::GetInstance()->m_roleType, 0);
            }
        }
        if (name.CompareNoCase(_T("role_audience")) == 0) {
            CDataCenter::GetInstance()->m_roleType = TRTCRoleAudience;
            LocalUserInfo& _loginInfo = CDataCenter::GetInstance()->getLocalUserInfo();
            if (_loginInfo._bEnterRoom)
            {
                CHorizontalLayoutUI* pHLayout = static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("livetype")));
                pHLayout->SetVisible(true);

                if (CDataCenter::GetInstance()->m_emLivePlayerSourceType == TRTC_RTC)
                {
                    COptionUI* pRTC = static_cast<COptionUI*>(m_pmUI.FindControl(_T("trtc_rtc")));
                    pRTC->Selected(true);
                }
                else
                {
                    COptionUI* pCDN = static_cast<COptionUI*>(m_pmUI.FindControl(_T("trtc_cdn")));
                    pCDN->Selected(true);
                }
            }
           
            if (CDataCenter::GetInstance()->m_localInfo._bEnterRoom)
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->switchRole(CDataCenter::GetInstance()->m_roleType);
            }

            if (_loginInfo._bEnterRoom&& is_init_windows_finished)
            {
                ::PostMessage(m_parentHwnd, WM_USER_CMD_RoleChange, (WPARAM)CDataCenter::GetInstance()->m_roleType, 0);
            }
        }
        if (name.CompareNoCase(_T("trtc_rtc")) == 0) {
           
            LocalUserInfo& _loginInfo = CDataCenter::GetInstance()->getLocalUserInfo();
            if (_loginInfo._bEnterRoom&& is_init_windows_finished)
            {
                COptionUI* pSceneCall = static_cast<COptionUI*>(m_pmUI.FindControl(_T("scene_call")));
                pSceneCall->SetEnabled(true);
                COptionUI* pAudioSceneCall = static_cast<COptionUI*>(m_pmUI.FindControl(_T("audio_scene_call")));
                pAudioSceneCall->SetEnabled(true);
                COptionUI* pAudioSceneLive = static_cast<COptionUI*>(m_pmUI.FindControl(_T("audio_scene_live")));
                pAudioSceneLive->SetEnabled(true);
                COptionUI* pRoleAnchor = static_cast<COptionUI*>(m_pmUI.FindControl(_T("role_anchor")));
                pRoleAnchor->SetEnabled(true);
                ::PostMessage(m_parentHwnd, WM_USER_CMD_LiveTypeChange, (WPARAM)TRTC_RTC, 0);
            }
        }
        if (name.CompareNoCase(_T("trtc_cdn")) == 0) {
         
            LocalUserInfo& _loginInfo = CDataCenter::GetInstance()->getLocalUserInfo();
            if (_loginInfo._bEnterRoom&& is_init_windows_finished)
            {
                COptionUI* pSceneCall = static_cast<COptionUI*>(m_pmUI.FindControl(_T("scene_call")));
                pSceneCall->SetEnabled(false);
                COptionUI* pAudioSceneCall = static_cast<COptionUI*>(m_pmUI.FindControl(_T("audio_scene_call")));
                pAudioSceneCall->SetEnabled(false);
                COptionUI* pAudioSceneLive = static_cast<COptionUI*>(m_pmUI.FindControl(_T("audio_scene_live")));
                pAudioSceneLive->SetEnabled(false);
                COptionUI* pRoleAnchor = static_cast<COptionUI*>(m_pmUI.FindControl(_T("role_anchor")));
                pRoleAnchor->SetEnabled(false);
                ::PostMessage(m_parentHwnd, WM_USER_CMD_LiveTypeChange, (WPARAM)TRTC_CDN, 0);
            }
        }
        if (name.CompareNoCase(_T("mix_temp_manual")) == 0) {
            CDataCenter::GetInstance()->m_mixTemplateID = TRTCTranscodingConfigMode_Manual;
        }
        if (name.CompareNoCase(_T("mix_temp_pure_audio")) == 0) {
            CDataCenter::GetInstance()->m_mixTemplateID = TRTCTranscodingConfigMode_Template_PureAudio;
        }
        if (name.CompareNoCase(_T("mix_temp_screen_share")) == 0) {
            CDataCenter::GetInstance()->m_mixTemplateID = TRTCTranscodingConfigMode_Template_ScreenSharing;
        }
        if (name.CompareNoCase(_T("mix_temp_preset")) == 0) {
            CDataCenter::GetInstance()->m_mixTemplateID = TRTCTranscodingConfigMode_Template_PresetLayout;
        }

        if (name.CompareNoCase(_T("local_record_audio")) == 0) {
            CDataCenter::GetInstance()->m_localRecordType = TRTCLocalRecordType_Audio;
        }
        if (name.CompareNoCase(_T("local_record_video")) == 0) {
            CDataCenter::GetInstance()->m_localRecordType = TRTCLocalRecordType_Video;
        }
        if (name.CompareNoCase(_T("local_record_both")) == 0) {
            CDataCenter::GetInstance()->m_localRecordType = TRTCLocalRecordType_Both;
        }
        
        if (name.CompareNoCase(_T("auto_mode")) == 0) {
            CDataCenter::GetInstance()->m_bAutoRecvAudio = true;
            CDataCenter::GetInstance()->m_bAutoRecvVideo = true;
        }
        if (name.CompareNoCase(_T("audio_mode")) == 0) {
            CDataCenter::GetInstance()->m_bAutoRecvAudio = true;
            CDataCenter::GetInstance()->m_bAutoRecvVideo = false;
        }
        if (name.CompareNoCase(_T("video_mode")) == 0) {
            CDataCenter::GetInstance()->m_bAutoRecvAudio = false;
            CDataCenter::GetInstance()->m_bAutoRecvVideo = true;
        }
        if (name.CompareNoCase(_T("manual_mode")) == 0) {
            CDataCenter::GetInstance()->m_bAutoRecvAudio = false;
            CDataCenter::GetInstance()->m_bAutoRecvVideo = false;
        }

        if (name.CompareNoCase(_T("smooth_beauty")) == 0) {
            CDataCenter::GetInstance()->m_beautyConfig._beautyStyle = TRTCBeautyStyleSmooth;
            ResetBeautyConfig();
        }
        if (name.CompareNoCase(_T("natural_beauty")) == 0) {
            CDataCenter::GetInstance()->m_beautyConfig._beautyStyle = TRTCBeautyStyleNature;
            ResetBeautyConfig();
        }
    }
    else if (msg.sType == _T("valuechanged"))
    {
        if (name.CompareNoCase(_T("slider_videobitrate")) == 0)
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_videobitrate")));
            CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("slider_videobitrate_value")));
            CDuiString sText;
            int bitrate = pSlider->GetValue();
            bitrate = (bitrate + 1) / 10 * 10;
            if (bitrate > pSlider->GetMaxValue())
                bitrate = pSlider->GetMaxValue();
            sText.Format(_T("%dkbps"), bitrate);
            pLabelValue->SetText(sText);   

            CDataCenter::GetInstance()->m_videoEncParams.videoBitrate = bitrate;
            TRTCCloudCore::GetInstance()->getTRTCCloud()->setVideoEncoderParam(CDataCenter::GetInstance()->m_videoEncParams);
        }
        if (name.CompareNoCase(_T("slider_speaker_volume")) == 0)
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_speaker_volume")));
            CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_speaker_volume")));
            CDuiString sText;
            int volume = pSlider->GetValue();
            sText.Format(_T("%d%%"), volume);
            pLabelValue->SetText(sText);
            CDataCenter::GetInstance()->m_speakerVolume = volume;
            if (TRTCCloudCore::GetInstance()->getTRTCCloud())
                TRTCCloudCore::GetInstance()->getDeviceManager()->setCurrentDeviceVolume(TRTCDeviceTypeSpeaker, volume * AUDIO_DEVICE_VOLUME_TICKET / 100);
        }
        if (name.CompareNoCase(_T("slider_mic_volume")) == 0)
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_mic_volume")));
            CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_mic_volume")));
            CDuiString sText;
            int volume = pSlider->GetValue();
            sText.Format(_T("%d%%"), volume);
            pLabelValue->SetText(sText);
            CDataCenter::GetInstance()->m_micVolume = volume;
            if (TRTCCloudCore::GetInstance()->getTRTCCloud())
                TRTCCloudCore::GetInstance()->getDeviceManager()->setCurrentDeviceVolume(TRTCDeviceTypeMic, volume * AUDIO_DEVICE_VOLUME_TICKET / 100);
        }
        if(name.CompareNoCase(_T("slider_app_capture_volume")) == 0)
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_app_capture_volume")));
            CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_app_capture_volume")));
            CDuiString sText;
            int volume = pSlider->GetValue();
            sText.Format(_T("%d%%"),volume);
            pLabelValue->SetText(sText);
            CDataCenter::GetInstance()->m_audioCaptureVolume = volume;
            if (CDataCenter::GetInstance()->m_bOpenDemoTestConfig)
            {
                if (TRTCCloudCore::GetInstance()->getTRTCCloud())
                    TRTCCloudCore::GetInstance()->getTRTCCloud()->setAudioCaptureVolume(volume * AUDIO_VOLUME_TICKET / 100);
            }
            else
            {
                if (TRTCCloudCore::GetInstance()->getTRTCCloud()->getAudioEffectManager())
                {
                    TRTCCloudCore::GetInstance()->getTRTCCloud()->getAudioEffectManager()->setVoiceCaptureVolume(volume);
                }
            }
            
        }
        if(name.CompareNoCase(_T("slider_app_playout_volume")) == 0)
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_app_playout_volume")));
            CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_app_playout_volume")));
            CDuiString sText;
            int volume = pSlider->GetValue();
            sText.Format(_T("%d%%"),volume);
            pLabelValue->SetText(sText);
            CDataCenter::GetInstance()->m_audioPlayoutVolume = volume;

            if (TRTCCloudCore::GetInstance()->getTRTCCloud())
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setAudioPlayoutVolume(volume * AUDIO_VOLUME_TICKET / 100);
        }
        if (name.CompareNoCase(_T("slider_beauty_value")) == 0)
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_beauty_value")));
            int value = pSlider->GetValue();
            CDataCenter::GetInstance()->m_beautyConfig._beautyValue = value;
            ResetBeautyConfig();
        }
        if (name.CompareNoCase(_T("slider_ruddiness_value")) == 0)
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_ruddiness_value")));
            int value = pSlider->GetValue();
            CDataCenter::GetInstance()->m_beautyConfig._ruddinessValue = value;
            ResetBeautyConfig();
        }
        if (name.CompareNoCase(_T("slider_white_value")) == 0)
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_white_value")));
            int value = pSlider->GetValue();
            CDataCenter::GetInstance()->m_beautyConfig._whiteValue = value;
            ResetBeautyConfig();
        }
    }
    else if (msg.sType == _T("itemselect"))
    {
        if (name.CompareNoCase(_T("combo_videofps")) == 0) {
            if (msg.wParam == 0)
                CDataCenter::GetInstance()->m_videoEncParams.videoFps = 15;
            if (msg.wParam == 1)
                CDataCenter::GetInstance()->m_videoEncParams.videoFps = 20;
            if (msg.wParam == 2)
                CDataCenter::GetInstance()->m_videoEncParams.videoFps = 24;

            TRTCCloudCore::GetInstance()->getTRTCCloud()->setVideoEncoderParam(CDataCenter::GetInstance()->m_videoEncParams);
        }
        else if (name.CompareNoCase(_T("combo_videoresolution")) == 0) {
            if (msg.wParam == 0)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_120_120;
            else if (msg.wParam == 1)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_160_160;
            else if (msg.wParam == 2)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_270_270;
            else if (msg.wParam == 3)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_480_480;
            else if (msg.wParam == 4)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_160_120;
            else if (msg.wParam == 5)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_240_180;
            else if (msg.wParam == 6)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_280_210;
            else if (msg.wParam == 7)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_320_240;
            else if (msg.wParam == 8)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_400_300;
            else if (msg.wParam == 9)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_480_360;
            else if (msg.wParam == 10)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_640_480;
            else if (msg.wParam == 11)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_960_720;
            else if (msg.wParam == 12)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_320_180;
            else if (msg.wParam == 13)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_480_270;
            else if (msg.wParam == 14)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_640_360;
            else if (msg.wParam == 15)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_960_540;
            else if (msg.wParam == 16)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_1280_720;
            else if (msg.wParam == 17)
                CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_1920_1080;

            updateVideoBitrateUi();

            TRTCCloudCore::GetInstance()->getTRTCCloud()->setVideoEncoderParam(CDataCenter::GetInstance()->m_videoEncParams);
        }
        else if (name.CompareNoCase(_T("combo_camera")) == 0) 
        {
            if (is_init_device_combo_list_) {
                is_init_device_combo_list_ = false;
                return;
            }
            CComboUI* pDeviceSender = static_cast<CComboUI*>(msg.pSender);
            if (pDeviceSender)
            {
                int nIndex = pDeviceSender->GetCurSel();
                CListLabelElementUI* pListElement = static_cast<CListLabelElementUI*>(pDeviceSender->GetItemAt(nIndex));
                if (pListElement)
                {
                    CDuiString wsDevice = pListElement->GetText();
                    if (TRTCCloudCore::GetInstance())
                        TRTCCloudCore::GetInstance()->selectCameraDevice(wsDevice.GetData());
                }
            }
        }
        else if (name.CompareNoCase(_T("combo_speaker_device")) == 0) 
        {
            if (is_init_device_combo_list_) {
                is_init_device_combo_list_ = false;
                return;
            }
            CComboUI* pDeviceSender = static_cast<CComboUI*>(msg.pSender);
            if (pDeviceSender)
            {
                int nIndex = pDeviceSender->GetCurSel();
                CListLabelElementUI* pListElement = static_cast<CListLabelElementUI*>(pDeviceSender->GetItemAt(nIndex));
                if (pListElement)
                {
                    CDuiString wsDevice = pListElement->GetText();
                    if (TRTCCloudCore::GetInstance())
                        TRTCCloudCore::GetInstance()->selectSpeakerDevice(wsDevice.GetData());
                }
            }
        }
        else if (name.CompareNoCase(_T("combo_mic_device")) == 0) 
        {
            if (is_init_device_combo_list_) {
                is_init_device_combo_list_ = false;
                return;
            }
            CComboUI* pDeviceSender = static_cast<CComboUI*>(msg.pSender);
            if (pDeviceSender)
            {
                int nIndex = pDeviceSender->GetCurSel();
                CListLabelElementUI* pListElement = static_cast<CListLabelElementUI*>(pDeviceSender->GetItemAt(nIndex));
                if (pListElement)
                {
                    CDuiString wsDevice = pListElement->GetText();
                    if (TRTCCloudCore::GetInstance())
                        TRTCCloudCore::GetInstance()->selectMicDevice(wsDevice.GetData());
                }
            }
        }
        else if (name.CompareNoCase(_T("combo_audio_quality")) == 0)
        {
            if (is_init_audio_quality_combo){
                is_init_audio_quality_combo = false;
                return; 
            }
            if (msg.wParam == 0) {
                CDataCenter::GetInstance()->audio_quality_ = TRTCAudioQualitySpeech;
            }
            else if(msg.wParam == 1) {
                CDataCenter::GetInstance()->audio_quality_ = TRTCAudioQualityDefault;
            }
            else if (msg.wParam == 2) {
                CDataCenter::GetInstance()->audio_quality_ = TRTCAudioQualityMusic;
            }
        }
    }
    else if (msg.sType == _T("click"))
    {
        if (msg.pSender->GetName() == _T("btn_testspeaker"))
        {
            CButtonUI* pTestSender = static_cast<CButtonUI*>(msg.pSender);
            if (pTestSender && pTestSender->GetText() == _T("扬声器测试")) 
            {
                pTestSender->SetText(_T("停止"));
                std::wstring testFileMp3 = TrtcUtil::getAppDirectory() + L"trtcres/testspeak.mp3";
                if (TRTCCloudCore::GetInstance()->getTRTCCloud())
                {
                    TRTCCloudCore::GetInstance()->getDeviceManager()->startSpeakerDeviceTest(Wide2UTF8(testFileMp3).c_str());
                    //TRTCCloudCore::GetInstance()->getTRTCCloud()->playBGM(Wide2UTF8(testFileMp3).c_str());
                }

                m_bStartTestSpeaker = true;
            }
            else
            {
                pTestSender->SetText(_T("扬声器测试"));
                if (TRTCCloudCore::GetInstance()->getTRTCCloud())
                {
                    TRTCCloudCore::GetInstance()->getDeviceManager()->stopSpeakerDeviceTest();
                    //TRTCCloudCore::GetInstance()->getTRTCCloud()->stopBGM();
                }

                m_bStartTestSpeaker = false;
                if (m_pProgressTestSpeaker)
                    m_pProgressTestSpeaker->SetValue(0);
            }
        }
        if (msg.pSender->GetName() == _T("btn_testmic"))
        {
            CButtonUI* pTestSender = static_cast<CButtonUI*>(msg.pSender);
            if (pTestSender && pTestSender->GetText() == _T("麦克风测试"))
            {
                if (TRTCCloudCore::GetInstance()->getTRTCCloud())
                    TRTCCloudCore::GetInstance()->getDeviceManager()->startMicDeviceTest(200);

                int ret = TRTCCloudCore::GetInstance()->getDeviceManager()->getCurrentDeviceVolume(TRTCDeviceTypeMic);
                pTestSender->SetText(_T("停止"));
                m_bStartTestMic = true;
            }
            else
            {
                if (TRTCCloudCore::GetInstance()->getTRTCCloud())
                    TRTCCloudCore::GetInstance()->getDeviceManager()->stopMicDeviceTest();

                if (m_pProgressTestMic)
                    m_pProgressTestMic->SetValue(0);
                pTestSender->SetText(_T("麦克风测试"));
                m_bStartTestMic = false;
            }
        }
        if (msg.pSender->GetName() == _T("check_btn_muteremotes"))
        {

            COptionUI* pTestMuteRemotes = static_cast<COptionUI*>(msg.pSender);
            if (pTestMuteRemotes->IsSelected() == false) //事件值是反的
            {

                RemoteUserInfoList& userMap = CDataCenter::GetInstance()->m_remoteUser;
                for (auto it : userMap) 
                {
                    //todo
                }
                m_bMuteRemotesAudio = true;
            }
            else
            {
                RemoteUserInfoList& userMap = CDataCenter::GetInstance()->m_remoteUser;
                for (auto it : userMap)
                {
                    // todo
                }
                m_bMuteRemotesAudio = false;
            }

        }
        if (msg.pSender->GetName() == _T("btn_testnetwork"))
        {
            CButtonUI* pTestSender = static_cast<CButtonUI*>(msg.pSender);
            if (pTestSender && pTestSender->GetText() == _T("网络测试"))
            {
                // todo 网络测试
                //if (TRTCCloudCore::GetInstance()->getTRTCCloud())
                //    TRTCCloudCore::GetInstance()->getTRTCCloud()->startSpeedTest();
                //pTestSender->SetText(_T("停止"));
                //m_bStartTestNetwork = true;
            }
            else
            {
                // todo 网络测试
                //if (TRTCCloudCore::GetInstance()->getTRTCCloud())
                //    TRTCCloudCore::GetInstance()->getTRTCCloud()->stopSpeedTest();
                //if (m_pProgressTestNetwork)
                //    m_pProgressTestNetwork->SetValue(0);
                //pTestSender->SetText(_T("网络测试"));
                //m_bStartTestNetwork = false;
            }
        }
        if (msg.pSender->GetName() == _T("check_open_beaty"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) //事件值是反的
            {
                CDataCenter::GetInstance()->m_beautyConfig._bOpenBeauty = true;
                COptionUI* pBeautySmooth = static_cast<COptionUI*>(m_pmUI.FindControl(_T("smooth_beauty")));
                COptionUI* pBeautyNatural = static_cast<COptionUI*>(m_pmUI.FindControl(_T("natural_beauty")));
                CSliderUI* pBeautySlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_beauty_value")));
                CSliderUI* pRuddinessSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_ruddiness_value")));
                CSliderUI* pWhiteSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_white_value")));
                if (pBeautySmooth && pBeautyNatural && pBeautySlider && pRuddinessSlider && pWhiteSlider)
                {
                    pBeautySmooth->SetEnabled(true);
                    pBeautyNatural->SetEnabled(true);
                    pBeautySlider->SetEnabled(true);
                    pRuddinessSlider->SetEnabled(true);
                    pWhiteSlider->SetEnabled(true);
                }
                ResetBeautyConfig();
            }
            else
            {
                CDataCenter::GetInstance()->m_beautyConfig._bOpenBeauty = false;
                COptionUI* pBeautySmooth = static_cast<COptionUI*>(m_pmUI.FindControl(_T("smooth_beauty")));
                COptionUI* pBeautyNatural = static_cast<COptionUI*>(m_pmUI.FindControl(_T("natural_beauty")));
                CSliderUI* pBeautySlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_beauty_value")));
                CSliderUI* pRuddinessSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_ruddiness_value")));
                CSliderUI* pWhiteSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_white_value")));
                if (pBeautySmooth && pBeautyNatural && pBeautySlider && pRuddinessSlider && pWhiteSlider)
                {
                    pBeautySmooth->SetEnabled(false);
                    pBeautyNatural->SetEnabled(false);
                    pBeautySlider->SetEnabled(false);
                    pRuddinessSlider->SetEnabled(false);
                    pWhiteSlider->SetEnabled(false);
                }
                ResetBeautyConfig();
            }
        }
        if (msg.pSender->GetName() == _T("check_push_smallvideo"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) //事件值是反的
            {
                CDataCenter::GetInstance()->m_bPushSmallVideo = true;
                TRTCVideoEncParam param;
                param.videoFps = 15;
                param.videoBitrate = 130;
                param.videoResolution = TRTCVideoResolution_160_120;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->enableSmallVideoStream(true, param);
            }
            else
            {
                CDataCenter::GetInstance()->m_bPushSmallVideo = false;
                TRTCVideoEncParam param;
                param.videoFps = 15;
                param.videoBitrate = 130;
                param.videoResolution = TRTCVideoResolution_160_120;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->enableSmallVideoStream(false, param);
            }
        }
        if (msg.pSender->GetName() == _T("check_play_smallvideo"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) //事件值是反的
            {
                CDataCenter::GetInstance()->m_bPlaySmallVideo = true;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setPriorRemoteVideoStreamType(TRTCVideoStreamTypeSmall);
            }
            else
            {
                CDataCenter::GetInstance()->m_bPlaySmallVideo = false;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setPriorRemoteVideoStreamType(TRTCVideoStreamTypeBig);
            }
        }
        if (msg.pSender->GetName() == _T("check_play_swapvideo"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) //事件值是反的
            {
                CDataCenter::GetInstance()->m_bPlaySmallVideo = true;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setRemoteVideoStreamType(nullptr, TRTCVideoStreamTypeSmall);
            }
            else
            {
                CDataCenter::GetInstance()->m_bPlaySmallVideo = false;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setRemoteVideoStreamType(nullptr, TRTCVideoStreamTypeBig);
            }
        }
        if (msg.pSender->GetName() == _T("check_custom_audio"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (CDataCenter::GetInstance()->m_localInfo._bEnterRoom == false)
            {
                pOpenSender->Selected(true);
                CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"), _T("Error: 请先进入房间"), 0xFFF08080);
                return;
            }
            if (pOpenSender->IsSelected() == false) //事件值是反的
            {
                std::wstring testFile = TrtcUtil::getAppDirectory() + L"trtcres/48_1_audio.pcm";
                CComboUI* pAudioFileCombo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_audio_pcmfile")));
                int samplerate = 48000, channel = 1;
                if (pAudioFileCombo)
                {
                    int index = pAudioFileCombo->GetCurSel();
                    if (index == 0)
                    {
                        testFile = TrtcUtil::getAppDirectory() + L"trtcres/48_1_audio.pcm";
                        samplerate = 48000, channel = 1;
                    }
                    else if (index == 1)
                    {
                        testFile = TrtcUtil::getAppDirectory() + L"trtcres/16_1_audio.pcm";
                        samplerate = 16000, channel = 1;
                    }
                }
                CDataCenter::GetInstance()->m_bCustomAudioCapture = true;
                TRTCCloudCore::GetInstance()->startCustomCaptureAudio(testFile, samplerate, channel);
            }
            else
            {
                CDataCenter::GetInstance()->m_bCustomAudioCapture = false;
                TRTCCloudCore::GetInstance()->stopCustomCaptureAudio();
            }
        }
        if (msg.pSender->GetName() == _T("check_custom_video"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (CDataCenter::GetInstance()->m_localInfo._bEnterRoom == false)
            {
                pOpenSender->Selected(true);
                CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"), _T("Error: 请先进入房间"), 0xFFF08080);
                return;
            }

            if (pOpenSender->IsSelected() == false) //事件值是反的
            {


                std::wstring testFile = TrtcUtil::getAppDirectory() + L"trtcres/320x240_video.yuv";

                CComboUI* pVideoFileCombo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_video_yuvfile")));
                int width = 320, height = 240;
                if (pVideoFileCombo)
                {
                    int index = pVideoFileCombo->GetCurSel();
                    if (index == 0)
                    {
                        testFile = TrtcUtil::getAppDirectory() + L"trtcres/320x240_video.yuv";
                        width = 320, height = 240;
                    }
                }
                CDataCenter::GetInstance()->m_bCustomVideoCapture = true;
                TRTCCloudCore::GetInstance()->startCustomCaptureVideo(testFile, width, height);
            }
            else
            {
                CDataCenter::GetInstance()->m_bCustomVideoCapture = false;
                TRTCCloudCore::GetInstance()->stopCustomCaptureVideo();
            }
        }
        if (msg.pSender->GetName() == _T("check_custom_sub_audio")) {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (CDataCenter::GetInstance()->m_localInfo._bEnterRoom == false) {
                pOpenSender->Selected(true);
                CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"), _T("Error: 请先进入房间"),
                                        0xFFF08080);
                return;
            }
            if (pOpenSender->IsSelected() == false)  //事件值是反的
            {
                std::wstring testFile = TrtcUtil::getAppDirectory() + L"trtcres/48_1_audio.pcm";
                CComboUI* pAudioFileCombo =
                    static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_audio_sub_pcmfile")));
                int samplerate = 48000, channel = 1;
                if (pAudioFileCombo) {
                    int index = pAudioFileCombo->GetCurSel();
                    if (index == 0) {
                        testFile = TrtcUtil::getAppDirectory() + L"trtcres/48_1_audio.pcm";
                        samplerate = 48000, channel = 1;
                    } else if (index == 1) {
                        testFile = TrtcUtil::getAppDirectory() + L"trtcres/16_1_audio.pcm";
                        samplerate = 16000, channel = 1;
                    }
                }
                CDataCenter::GetInstance()->m_bCustomSubAudioCapture = true;
                TRTCCloudCore::GetInstance()->startCustomSubCaptureAudio(testFile, samplerate, channel);
            } else {
                CDataCenter::GetInstance()->m_bCustomSubAudioCapture = false;
                TRTCCloudCore::GetInstance()->stopCustomSubCaptureAudio();
            }
        }
        if (msg.pSender->GetName() == _T("check_custom_sub_video")) {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (CDataCenter::GetInstance()->m_localInfo._bEnterRoom == false) {
                pOpenSender->Selected(true);
                CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"), _T("Error: 请先进入房间"),
                                        0xFFF08080);
                return;
            }

            if (pOpenSender->IsSelected() == false)  //事件值是反的
            {
                std::wstring testFile = TrtcUtil::getAppDirectory() + L"trtcres/320x240_video.yuv";

                CComboUI* pVideoFileCombo =
                    static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_video_sub_yuvfile")));
                int width = 320, height = 240;
                if (pVideoFileCombo) {
                    int index = pVideoFileCombo->GetCurSel();
                    if (index == 0) {
                        testFile = TrtcUtil::getAppDirectory() + L"trtcres/320x240_video.yuv";
                        width = 320, height = 240;
                    }
                }
                CDataCenter::GetInstance()->m_bCustomSubVideoCapture = true;
                TRTCCloudCore::GetInstance()->startCustomSubCaptureVideo(testFile, width, height);
            } else {
                CDataCenter::GetInstance()->m_bCustomSubVideoCapture = false;
                TRTCCloudCore::GetInstance()->stopCustomSubCaptureVideo();
            }
        }
    }
}
void TRTCSettingViewController::NotifyAudioTab(TNotifyUI& msg) {
    if (msg.sType == _T("click"))
    {
        if (msg.pSender->GetName() == _T("check_mic_mute")) {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) { //事件值是反的
                TRTCCloudCore::GetInstance()->getDeviceManager()->setCurrentDeviceMute(TRTCDeviceTypeMic, true);
            }
            else {
                TRTCCloudCore::GetInstance()->getDeviceManager()->setCurrentDeviceMute(TRTCDeviceTypeMic, false);
            }
        }
        else if (msg.pSender->GetName() == _T("check_speaker_mute")) {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) { //事件值是反的
                TRTCCloudCore::GetInstance()->getDeviceManager()->setCurrentDeviceMute(TRTCDeviceTypeSpeaker, true);
            }
            else {
                TRTCCloudCore::GetInstance()->getDeviceManager()->setCurrentDeviceMute(TRTCDeviceTypeSpeaker, false);
            }
        }  else if (msg.pSender->GetName() == _T("check_btn_aec")) {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) {
                CDataCenter::GetInstance()->m_bEnableAec = true;

                //todo
            }
            else {
                CDataCenter::GetInstance()->m_bEnableAec = false;
                //todo
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_ans")) {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) {
                CDataCenter::GetInstance()->m_bEnableAns = true;
                //todo

            }
            else {
                CDataCenter::GetInstance()->m_bEnableAns = false;
                //todo
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_agc")) {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) {
                CDataCenter::GetInstance()->m_bEnableAgc = true;
                //todo
            }
            else {
                CDataCenter::GetInstance()->m_bEnableAgc = false;
                //todo
            }
        }
        else if(msg.pSender->GetName() == _T("check_system_audio_mix"))
        {
            COptionUI* pTestSystemVoice = static_cast<COptionUI*>(msg.pSender);
            if(pTestSystemVoice->IsSelected() == false) //事件值是反的
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->startSystemAudioLoopback();
                CDataCenter::GetInstance()->m_bStartSystemVoice = true;
            } else
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopSystemAudioLoopback();
                CDataCenter::GetInstance()->m_bStartSystemVoice = false;
            }

        }
    }
    else if (msg.sType == _T("valuechanged"))
    {
        if (msg.pSender->GetName() == _T("slider_aec"))
        {
            CProgressUI* pSlider =
                static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_aec")));
            CLabelUI* pLabelValue =
                static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_aec")));
            CDuiString sText;
            int level = pSlider->GetValue();
            if (level == 0) {
                level = 0;
            } else if (level == 1) {
                level = 30;
            } else if (level == 2) {
                level = 60;
            } else if (level == 3) {
                level = 100;
            }
            sText.Format(_T("%d%"), level);
            pLabelValue->SetText(sText);
            // todo
        } 
        else if (msg.pSender->GetName() == _T("slider_hook_aec"))
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_hook_aec")));
            CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_hook_aec")));
            CDuiString sText;
            int level = pSlider->GetValue();
            bool enable_hook_aec = true;
            if (level == 0) 
            {
                enable_hook_aec = false;
                level = 0;
            }
            else if (level == 1) 
            {
                level = 30;
            } 
            else if (level == 2) 
            {
                level = 60;
            } 
            else if (level == 3) {
                level = 100;
            }
            sText.Format(_T("%d%"), level);
            pLabelValue->SetText(sText);
            // todo
        }
        else if (msg.pSender->GetName() == _T("slider_agc")) {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_agc")));
            CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_agc")));
            CDuiString sText;
            int level = pSlider->GetValue();
            if (level == 0) {
                level = 0;
            } else if (level == 1) {
                level = 10;
            } else if (level == 2) {
                level = 20;
            } else if (level == 3) {
                level = 40;
            } else if (level == 4) {
                level = 60;
            } else if (level == 5) {
                level = 80;
            } else if (level == 6) {
                level = 100;
            }
            sText.Format(_T("%d%"), level);
            pLabelValue->SetText(sText);
            // todo
        } 
         else if (msg.pSender->GetName() == _T("slider_ans")) {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_ans")));
            CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_ans")));
            CDuiString sText;
            int level = pSlider->GetValue();
            if (level == 0) {
                level = 0;
            } 
            else if (level == 1) {
                level = 20;
            } 
            else if (level == 2) {
                level = 40;
            } 
            else if (level == 3) {
                level = 60;
            } 
            else if (level == 4) {
                level = 80;
            }
            else if (level == 5) {
                level = 100;
            }
            sText.Format(_T("%d%"), level);
            pLabelValue->SetText(sText);
            // todo
        } 
    }
}

void TRTCSettingViewController::NotifyOtherTab(TNotifyUI & msg)
{
    CDuiString name = msg.pSender->GetName();
    if (msg.sType == _T("selectchanged"))
    {
        {
            TRTCVideoEncParam param;
            param.videoFps = 15;
            param.videoBitrate = 130;
            param.videoResolution = TRTCVideoResolution_160_120;
            if (name.CompareNoCase(_T("horizontal_screen")) == 0) {
                CDataCenter::GetInstance()->m_videoEncParams.resMode = TRTCVideoResolutionModePortrait;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setVideoEncoderParam(CDataCenter::GetInstance()->m_videoEncParams);
                param.resMode = TRTCVideoResolutionModePortrait;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->enableSmallVideoStream(CDataCenter::GetInstance()->m_bPushSmallVideo, param);
            }
            if (name.CompareNoCase(_T("vertical_screen")) == 0) {
                CDataCenter::GetInstance()->m_videoEncParams.resMode = TRTCVideoResolutionModeLandscape;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setVideoEncoderParam(CDataCenter::GetInstance()->m_videoEncParams);
                param.resMode = TRTCVideoResolutionModeLandscape;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->enableSmallVideoStream(CDataCenter::GetInstance()->m_bPushSmallVideo, param);
            }
        }
    }
    else if (msg.sType == _T("click"))
    {
        if (msg.pSender->GetName() == _T("check_local_mirror"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) //事件值是反的
            {
                CDataCenter::GetInstance()->m_bLocalVideoMirror = true;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setLocalRenderParams(CDataCenter::GetInstance()->getLocalRenderParams());
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setVideoEncoderMirror(CDataCenter::GetInstance()->m_bLocalVideoMirror);
            }
            else
            {
                CDataCenter::GetInstance()->m_bLocalVideoMirror = false;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setLocalRenderParams(CDataCenter::GetInstance()->getLocalRenderParams());
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setVideoEncoderMirror(CDataCenter::GetInstance()->m_bLocalVideoMirror);
            }
        } else if (msg.pSender->GetName() == _T("check_water_mark"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false)  //事件值是反的
            {
                CDataCenter::GetInstance()->m_bWateMark = true;
                std::wstring srcData = TrtcUtil::getAppDirectory() + L"trtcskin/login/logo.png";
                std::string water_mark_file = Wide2UTF8(srcData);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setWaterMark(TRTCVideoStreamTypeBig, water_mark_file.c_str(), TRTCWaterMarkSrcTypeFile, 0,0,0.1,0.1,0.1);
            } else {
                CDataCenter::GetInstance()->m_bWateMark = false;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setWaterMark(TRTCVideoStreamTypeBig,"", TRTCWaterMarkSrcTypeFile, 0,0,0,0,0);
            }
        }
        else if (msg.pSender->GetName() == _T("check_black_push")) {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) {  //事件值是反的
                 //todo
            } else {
                // todo
            }
        }
        else if (msg.pSender->GetName() == _T("check_remote_mirror"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) //事件值是反的  
                CDataCenter::GetInstance()->m_bRemoteVideoMirror = true;
            else
                CDataCenter::GetInstance()->m_bRemoteVideoMirror = false;
        }
        else if (msg.pSender->GetName() == _T("check_voice_volume"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) //事件值是反的
            {
                CDataCenter::GetInstance()->m_bShowAudioVolume = true;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->enableAudioVolumeEvaluation(200);
            }
            else
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->enableAudioVolumeEvaluation(0);
                CDataCenter::GetInstance()->m_bShowAudioVolume = false;
            }
            ::PostMessage(m_parentHwnd, WM_USER_SET_SHOW_VOICEVOLUME, (WPARAM)CDataCenter::GetInstance()->m_bShowAudioVolume, 0);
        }
        else if (msg.pSender->GetName() == _T("check_use_main_stream")) {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) //事件值是反的
            {
                CDataCenter::GetInstance()->m_bPublishScreenInBigStream = true;
            }
            else
            {
                CDataCenter::GetInstance()->m_bPublishScreenInBigStream = false;
            }
        }

        else if (msg.pSender->GetName() == _T("check_localvideo_open"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false)
            {
                CDataCenter::GetInstance()->m_bMuteLocalVideo = false;
                if (!CDataCenter::GetInstance()->m_bBlackFramePush) {
                    TRTCCloudCore::GetInstance()->getTRTCCloud()->muteLocalVideo(false);
                }
            }
            else
            {
                CDataCenter::GetInstance()->m_bMuteLocalVideo = true;
                if (!CDataCenter::GetInstance()->m_bBlackFramePush) {
                    TRTCCloudCore::GetInstance()->getTRTCCloud()->muteLocalVideo(true);
                }
            }
        }
        else if (msg.pSender->GetName() == _T("check_localaudio_open"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false)
            {
                CDataCenter::GetInstance()->m_bMuteLocalAudio = false;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->muteLocalAudio(false);
            }
            else
            {
                CDataCenter::GetInstance()->m_bMuteLocalAudio = true;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->muteLocalAudio(true);
            }
        } else if (msg.pSender->GetName() == _T("btn_add_excluded_wnd")) {
            CEditUI* edit_ui = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_add_excluded_wnd")));
            if (edit_ui != nullptr) {
                wstring str_text = edit_ui->GetText();
                uint32_t hwnd = (uint32_t)std::strtoul(Wide2UTF8(str_text).c_str(), nullptr, 16);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->addExcludedShareWindow((HWND)hwnd);
            }
        } else if (msg.pSender->GetName() == _T("btn_del_excluded_wnd")) {
            CEditUI* edit_ui = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_del_excluded_wnd")));
            if (edit_ui != nullptr) {
                wstring str_text = edit_ui->GetText();
                uint32_t hwnd = (uint32_t)std::strtoul(Wide2UTF8(str_text).c_str(), nullptr, 16);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->removeExcludedShareWindow((HWND)hwnd);
            }
        } else if (msg.pSender->GetName() == _T("btn_del_all_excluded_wnd")) {
            TRTCCloudCore::GetInstance()->getTRTCCloud()->removeAllExcludedShareWindow();
        } else if (msg.pSender->GetName() == _T("btn_add_included_wnd")) {
            CEditUI* edit_ui = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_add_included_wnd")));
            if (edit_ui != nullptr) {
                wstring str_text = edit_ui->GetText();
                uint32_t hwnd = (uint32_t)std::strtoul(Wide2UTF8(str_text).c_str(), nullptr, 16);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->addIncludedShareWindow((HWND)hwnd);
            }
        } else if (msg.pSender->GetName() == _T("btn_del_included_wnd")) {
            CEditUI* edit_ui = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_del_included_wnd")));
            if (edit_ui != nullptr) {
                wstring str_text = edit_ui->GetText();
                uint32_t hwnd = (uint32_t)std::strtoul(Wide2UTF8(str_text).c_str(), nullptr, 16);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->removeIncludedShareWindow((HWND)hwnd);
            }
        } else if (msg.pSender->GetName() == _T("btn_del_all_included_wnd")) {
            TRTCCloudCore::GetInstance()->getTRTCCloud()->removeAllIncludedShareWindow();
        } else if (msg.pSender->GetName() == _T("btn_switch_room")) {
            TRTCSwitchRoomConfig config;
            int32_t roomId = 0;
            std::string str_room_id;
            CEditUI* edit_ui = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_switch_room_id")));
            if (edit_ui != nullptr) {
                wstring str_text = edit_ui->GetText();
                roomId = atoi(Wide2UTF8(str_text.c_str()).c_str());
                CDataCenter::GetInstance()->getLocalUserInfo()._roomId = roomId;
            }
            CEditUI* edit_ui_str = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_switch_str_room_id")));
            if (edit_ui_str != nullptr) {
                wstring str_text_room_id = edit_ui_str->GetText();
                str_room_id = Wide2UTF8(str_text_room_id.c_str());
                CDataCenter::GetInstance()->getLocalUserInfo().strRoomId = str_room_id;
            }
            config.roomId = roomId;
            config.strRoomId = str_room_id.c_str();
            config.userSig = CDataCenter::GetInstance()->getLocalUserInfo()._userSig.c_str();
            TRTCCloudCore::GetInstance()->getTRTCCloud()->switchRoom(config);
        } else if (msg.pSender->GetName() == _T("btn_send_sei")) {
            ::KillTimer(GetHWND(), m_send_sei_timer);
            ::SetTimer(GetHWND(), m_send_sei_timer, 500, NULL);
        } else if (msg.pSender->GetName() == _T("check_mini_windows")) {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) { //事件值是反的
                CDataCenter::GetInstance()->need_minimize_windows_ = true;
            } else {
                CDataCenter::GetInstance()->need_minimize_windows_ = false;
            }
        }
    }

}

void TRTCSettingViewController::NotifyMixTab(TNotifyUI & msg)
{
    CDuiString name = msg.pSender->GetName();
    if(msg.sType == _T("click"))
    {
        if(msg.pSender->GetName() == _T("check_cdnmix_video"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if(pOpenSender->IsSelected() == false) //事件值是反的
            {
                CDataCenter::GetInstance()->m_bCDNMixTranscoding = true;
                TRTCCloudCore::GetInstance()->startCloudMixStream();
            } else
            {
                CDataCenter::GetInstance()->m_bCDNMixTranscoding = false;
                TRTCCloudCore::GetInstance()->stopCloudMixStream();
            }
        } 
        else if(msg.pSender->GetName() == _T("btn_copyplayerurl"))
        {
            LocalUserInfo& info = CDataCenter::GetInstance()->m_localInfo;
            if(info._bEnterRoom == false)
            {
                CMsgWnd::ShowMessageBox(GetHWND(),_T("TRTCDuilibDemo"),_T("Error: 请先进入房间"),0xFFF08080);
                return;
            }
            if(CDataCenter::GetInstance()->m_bCDNMixTranscoding == false)
            {
                CMsgWnd::ShowMessageBox(GetHWND(),_T("TRTCDuilibDemo"),_T("Error: 请先勾选云端混流选项"),0xFFF08080);
                return;
            }

            std::string  sourceStr = format("%d_%s_main",info._roomId,info._userId.c_str()); 
            //http ://3891.liveplay.myqcloud.com/live/3891_12acca9a50faeaf9f92c9c202eb9bb2d.flv

            BYTE fingerPrintStableMD5[MD5_RESULT_LEN] ={0};
            char* stableStr = const_cast<char*>(sourceStr.c_str());
            TenMd5(reinterpret_cast<BYTE*>(stableStr),sourceStr.size(),fingerPrintStableMD5);

            std::strstream sstream;
            for(int i = 0; i < MD5_RESULT_LEN; ++i)
            {
                sstream << std::hex << std::setw(2) << std::setfill('0') << std::uppercase << static_cast<int>(fingerPrintStableMD5[i]);
            }
            std::string strMd5;
            sstream >> strMd5;
            std::transform(strMd5.begin(),strMd5.end(),strMd5.begin(),::tolower);
            std::string strStreamId = format("%d_%s",GenerateTestUserSig::BIZID, strMd5.c_str());

            if(CDataCenter::GetInstance()->m_strCustomStreamId.empty() == false) {
                strStreamId = CDataCenter::GetInstance()->m_strCustomStreamId;
            }

            if (CDataCenter::GetInstance()->m_strMixStreamId.empty() == false) {
                strStreamId = CDataCenter::GetInstance()->m_strMixStreamId;
            }

            std::wstring wstrStreamId = UTF82Wide(strStreamId); 
            std::wstring wstrUrl = format(L"播放地址: http://%d.liveplay.myqcloud.com/live/%s.flv 已经复制到剪切板",GenerateTestUserSig::BIZID,wstrStreamId.c_str());
            CMsgWnd::ShowMessageBox(GetHWND(),_T("TRTCDuilibDemo"),wstrUrl.c_str(),0xFFF08080);

            std::string strUrl = format("http://%d.liveplay.myqcloud.com/live/%s.flv",GenerateTestUserSig::BIZID,strStreamId.c_str());
            DWORD dwLength = strUrl.size(); // 要复制的字串长度
            HANDLE hGlobalMemory = GlobalAlloc(GHND,dwLength + 1); // 分配全局内存并获取句柄
            LPBYTE lpGlobalMemory = (LPBYTE)GlobalLock(hGlobalMemory); // 锁定全局内存
            memcpy(lpGlobalMemory,strUrl.c_str(),dwLength);
            lpGlobalMemory[dwLength] = '\0';
            GlobalUnlock(hGlobalMemory); // 锁定内存块解锁
            HWND hWnd = GetHWND(); // 获取安全窗口句柄
            ::OpenClipboard(hWnd); // 打开剪贴板
            ::EmptyClipboard(); // 清空剪贴板
            ::SetClipboardData(CF_TEXT,hGlobalMemory); // 将内存中的数据放置到剪贴板
            ::CloseClipboard(); // 关闭剪贴板
        }
        else if(msg.pSender->GetName() == _T("btn_update_mix_streamid"))
        {
            CEditUI* pEdit = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_mix_streamid")));
            if(pEdit != nullptr)
            {
                std::wstring strId = pEdit->GetText();
                if(!(strId.compare(L"") == 0))
                {
                    CDataCenter::GetInstance()->m_strMixStreamId = Wide2UTF8(strId);
                } 
                else
                {
                    CDataCenter::GetInstance()->m_strMixStreamId = "";
                }
                if(isCustomUploaderStreamIdValid(CDataCenter::GetInstance()->m_strMixStreamId) == false)
                {
                    CDataCenter::GetInstance()->m_strMixStreamId = "";
                    MessageBox(0,L"valid stream id, must in a~z A~Z 0~9",L"error update",0);
                }
                TRTCCloudCore::GetInstance()->updateMixTranCodeInfo();
            }
        }
    }
}

void TRTCSettingViewController::NotifyRecordTab(TNotifyUI & msg)
{
    CDuiString name = msg.pSender->GetName();
    if(msg.sType == _T("click"))
    {
        if(msg.pSender->GetName() == _T("check_start_record"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if(pOpenSender->IsSelected() == false) //事件值是反的
            {
                LiteAVScreenCaptureSourceInfo source = CDataCenter::GetInstance()->m_recordCaptureSourceInfo;
                std::string path = Wide2UTF8(CDataCenter::GetInstance()->m_wstrRecordFile);
                if (source.type == LiteAVScreenCaptureSourceTypeUnknown)
                {
                    CMsgWnd::ShowMessageBox(GetHWND(),_T("TRTCDuilibDemo"),_T("启动录制失败，您尚未选择录制内容！"),0xFFF08080);
                    pOpenSender->Selected(true);
                    return;
                }
                if(path.empty())
                {
                    CMsgWnd::ShowMessageBox(GetHWND(),_T("TRTCDuilibDemo"),_T("启动录制失败，您尚未输入录制文件地址！"),0xFFF08080);
                    pOpenSender->Selected(true);
                    return;
                }

                TRTCCloudCore::GetInstance()->startLocalRecord(source,path.c_str());

                CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_record_opt_status")));
                if(pLabelValue)
                {
                    CDuiString sText;
                    sText.Format(_T("正在启动录制:%s ...."), CDataCenter::GetInstance()->m_recordCaptureSourceInfoName.c_str());
                    pLabelValue->SetText(sText);
                }

                CDataCenter::GetInstance()->m_bPauseLocalRecord = false;
                CDataCenter::GetInstance()->m_bStartLocalRecord = true;
            }
            else
            {
                CDataCenter::GetInstance()->m_bPauseLocalRecord = false;
                CDataCenter::GetInstance()->m_bStartLocalRecord = false;

                TRTCCloudCore::GetInstance()->stopLocalRecord();

                CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_record_opt_status")));
                if(pLabelValue)
                {
                    pLabelValue->SetText(L"");
                }

                CLabelUI* pLabelRecordHwndNameValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_record_hwnd_name")));
                if (pLabelRecordHwndNameValue)
                {
                    pLabelRecordHwndNameValue->SetText(L"");
                }
            }
        }
        else if(msg.pSender->GetName() == _T("check_pause_record"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if(pOpenSender->IsSelected() == false) //事件值是反的
            {
                if(CDataCenter::GetInstance()->m_bStartLocalRecord == false)
                {
                    CMsgWnd::ShowMessageBox(GetHWND(),_T("TRTCDuilibDemo"),_T("暂停录制失败，您尚未启动录制！"),0xFFF08080);
                    pOpenSender->Selected(true);
                    return;
                }
                TRTCCloudCore::GetInstance()->pauseLocalRecord();

                CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_record_opt_status")));
                if(pLabelValue)
                    pLabelValue->SetText(_T("暂停录制..."));
            } else
            {
                if(CDataCenter::GetInstance()->m_bPauseLocalRecord == false || CDataCenter::GetInstance()->m_bStartLocalRecord == false)
                {
                    CMsgWnd::ShowMessageBox(GetHWND(),_T("TRTCDuilibDemo"),_T("取消暂停录制失败，当前录制状态不对！"),0xFFF08080);
                    pOpenSender->Selected(true);
                    return;
                }
                TRTCCloudCore::GetInstance()->resumeLocalRecord();
                CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_record_opt_status")));
                if(pLabelValue)
                    pLabelValue->SetText(L"唤醒录制....");
            }
        }
        else if(msg.pSender->GetName() == _T("btn_update_recode_hwnd"))
        {
            UiShareSelect uiShareSelect;
            uiShareSelect.Create(GetHWND() ,_T("选择录制内容"),UI_WNDSTYLE_DIALOG,0);
            uiShareSelect.CenterWindow();
            UINT nRet = uiShareSelect.ShowModal();
            if(nRet == IDOK)
            {
                TRTCScreenCaptureSourceInfo info = uiShareSelect.getSelectWnd();
                CDataCenter::GetInstance()->m_recordCaptureSourceInfo = uiShareSelect.getSelectWnd();
                std::string sourceName = info.sourceName == nullptr ? "" : info.sourceName;
                CDataCenter::GetInstance()->m_recordCaptureSourceInfoName = UTF82Wide(sourceName);
                CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_record_hwnd_name")));
                if(pLabelValue)
                {
                    CDuiString sText; 
                    sText.Format(_T("窗口:%s"),UTF82Wide(sourceName).c_str());
                    pLabelValue->SetText(sText);
                }
            }
        }
        else if(msg.pSender->GetName() == _T("btn_update_record_filepath"))
        {
            CEditUI* pEdit = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_record_filepath")));
            if(pEdit != nullptr)
            {
                std::wstring strId = pEdit->GetText();
                if(strId.compare(L"") == 0)
                {
                    CDataCenter::GetInstance()->m_wstrRecordFile = L"";
                }
                else
                {
                    CDataCenter::GetInstance()->m_wstrRecordFile = strId;
                }
                CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_record_opt_status")));
                if(pLabelValue)
                {
                    CDuiString sText;
                    sText.Format(_T("更新录制文件路径：%s"),CDataCenter::GetInstance()->m_wstrRecordFile.c_str());
                    pLabelValue->SetText(sText);
                }
            }
        }
    }
}

void TRTCSettingViewController::NotifyAudioRecord(TNotifyUI & msg)
{
    CDuiString name = msg.pSender->GetName();
    if (msg.sType == _T("click"))
    {
        if (msg.pSender->GetName() == _T("check_start_audio_record"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) //事件值是反的
            {
                if (m_strAudioRecordFile.empty())
                {
                    CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"), _T("启动录音失败，您尚未输入录音文件地址！"), 0xFFF08080);
                    pOpenSender->Selected(true);
                    return;
                }
                TRTCAudioRecordingParams audioRecordingParams;

                string strFile = Wide2UTF8(m_strAudioRecordFile);
                audioRecordingParams.filePath = strFile.c_str();

                int nResult = TRTCCloudCore::GetInstance()->getTRTCCloud()->startAudioRecording(audioRecordingParams);
                CDataCenter::GetInstance()->m_bStartAudioRecording = true;
                CDataCenter::GetInstance()->m_wstrAudioRecordFile = m_strAudioRecordFile;
                CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_audio_record_opt_status")));
                if (pLabelValue)
                {
                    CDuiString sText;
                    sText.Format(_T("正在启动录音:%s ...."), m_strAudioRecordFile.c_str());
                    pLabelValue->SetText(sText);
                }
            }
            else
            {

                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopAudioRecording();
                CDataCenter::GetInstance()->m_bStartAudioRecording = false;
                m_strAudioRecordFile = L"";
                CDataCenter::GetInstance()->m_wstrAudioRecordFile = m_strAudioRecordFile;
                CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_audio_record_opt_status")));
                if (pLabelValue)
                {
                    pLabelValue->SetText(L"停止录制...");
                }

            }
        }
        else if (msg.pSender->GetName() == _T("btn_update_audio_record_filepath"))
        {
            CEditUI* pEdit = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_audio_record_filepath")));
            if (pEdit != nullptr)
            {
                wstring strFile = pEdit->GetText();

                m_strAudioRecordFile = strFile;

                CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_audio_record_opt_status")));
                if (pLabelValue)
                {
                    CDuiString sText;
                    sText.Format(_T("更新录音文件路径：%s"), strFile.c_str());
                    pLabelValue->SetText(sText);
                }
            }
        }
        else if (msg.pSender->GetName() == _T("check_start_mix_app_audio")) {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false)  //事件值是反的
            {
                if (m_strMixAudioAppPath.empty()) {
                    CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"),
                                            _T("启动录音失败，您尚未输入录音文件地址！"),
                                            0xFFF08080);
                    pOpenSender->Selected(true);
                    return;
                }
                TRTCAudioRecordingParams audioRecordingParams;

                string strFile = Wide2UTF8(m_strMixAudioAppPath);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->startSystemAudioLoopback(strFile.c_str());

                CDataCenter::GetInstance()->m_bStartMixAppAudio = true;
                CDataCenter::GetInstance()->m_wstrMixAudioAppPath = m_strMixAudioAppPath;
                CLabelUI* pLabelValue =
                    static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_mix_app_audio_opt_status")));
                if (pLabelValue) {
                    CDuiString sText;
                    sText.Format(_T("正在启动进程混音:%s ...."), m_strMixAudioAppPath.c_str());
                    pLabelValue->SetText(sText);
                }
            } else {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopSystemAudioLoopback();
                CDataCenter::GetInstance()->m_bStartMixAppAudio = false;
                m_strMixAudioAppPath = L"";
                CDataCenter::GetInstance()->m_wstrMixAudioAppPath = m_strMixAudioAppPath;
                CLabelUI* pLabelValue =
                    static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_mix_app_audio_opt_status")));
                if (pLabelValue) {
                    pLabelValue->SetText(L"停止进程混音...");
                }
            }
        } else if (msg.pSender->GetName() == _T("btn_update_mix_app_audio_filepath")) {
            CEditUI* pEdit =
                static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_mix_app_audio_filepath")));
            if (pEdit != nullptr) {
                wstring strFile = pEdit->GetText();

                m_strMixAudioAppPath = strFile;

                CLabelUI* pLabelValue =
                    static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_mix_app_audio_opt_status")));
                if (pLabelValue) {
                    CDuiString sText;
                    sText.Format(_T("更新进程混音APP路径：%s"), strFile.c_str());
                    pLabelValue->SetText(sText);
                }
            }
        }
    }
}
void TRTCSettingViewController::NotifyLocalRecord(TNotifyUI & msg)
{
    CDuiString name = msg.pSender->GetName();
    if (msg.sType == _T("click"))
    {
        if (msg.pSender->GetName() == _T("check_start_local_record"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) //事件值是反的
            {
                if (m_strLocalRecordFile.empty())
                {
                    CMsgWnd::ShowMessageBox(GetHWND(), _T("TRTCDuilibDemo"), _T("启动录制失败，您尚未输入录制文件地址！"), 0xFFF08080);
                    pOpenSender->Selected(true);
                    return;
                }
                TRTCAudioRecordingParams audioRecordingParams;

                string strFile = Wide2UTF8(m_strLocalRecordFile);
                audioRecordingParams.filePath = strFile.c_str();

                //int nResult = TRTCCloudCore::GetInstance()->getTRTCCloud()->startAudioRecording(audioRecordingParams);

                TRTCLocalRecordingParams params;
                params.filePath = strFile.c_str();
                params.recordType = (TRTCLocalRecordType)CDataCenter::GetInstance()->m_localRecordType;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->startLocalRecording(params);
                CDataCenter::GetInstance()->m_bStartLocalRecording = true;
                CDataCenter::GetInstance()->m_wstrLocalRecordFile = m_strLocalRecordFile;
                CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_local_record_opt_status")));
                if (pLabelValue)
                {
                    CDuiString sText;
                    sText.Format(_T("正在启动录制:%s   type:%d...."), m_strLocalRecordFile.c_str(), (int)CDataCenter::GetInstance()->m_localRecordType);
                    pLabelValue->SetText(sText);
                }
            }
            else
            {

                //TRTCCloudCore::GetInstance()->getTRTCCloud()->stopAudioRecording();
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopLocalRecording();
                CDataCenter::GetInstance()->m_bStartLocalRecording = false;
                m_strLocalRecordFile = L"";
                CDataCenter::GetInstance()->m_wstrAudioRecordFile = m_strLocalRecordFile;
                CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_local_record_opt_status")));
                if (pLabelValue)
                {
                    pLabelValue->SetText(L"停止录制...");
                }

            }
        }
        else if (msg.pSender->GetName() == _T("btn_update_local_record_filepath"))
        {
            {
                CEditUI* pEdit = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_local_record_filepath")));
                if (pEdit != nullptr)
                {
                    wstring strFile = pEdit->GetText();

                    m_strLocalRecordFile = strFile;

                    CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_local_record_opt_status")));
                    if (pLabelValue)
                    {
                        CDuiString sText;
                        sText.Format(_T("更新录制文件路径：%s type: %d"), strFile.c_str(), (int)CDataCenter::GetInstance()->m_localRecordType);
                        pLabelValue->SetText(sText);
                    }
                }
            }

        }
    }
}
void TRTCSettingViewController::NotifyVodTab(TNotifyUI& msg) {
    if (!is_init_windows_finished) {
        return;
    }
    CDuiString name = msg.pSender->GetName();
    if (msg.sType == _T("click")) {
        if (msg.pSender->GetName() == _T("check_push_video_stream")) {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) {
                TRTCCloudCore::GetInstance()->enableVodPublishVideo(true);
                CDataCenter::GetInstance()->vod_push_video_ = true;
            } else {
               
                CDataCenter::GetInstance()->vod_push_video_ = false;
                TRTCCloudCore::GetInstance()->enableVodPublishVideo(false);
            }
        } 
        else if (msg.pSender->GetName() == _T("check_push_audio_stream")) {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) {
                TRTCCloudCore::GetInstance()->enableVodPublishAudio(true);
                CDataCenter::GetInstance()->vod_push_audio_ = true;
            } else {
                CDataCenter::GetInstance()->vod_push_audio_ = false;
                TRTCCloudCore::GetInstance()->enableVodPublishAudio(false);
            }
        } else if (msg.pSender->GetName() == _T("vod_wnd_render")) {
            CDataCenter::GetInstance()->vod_render_mode_ = VOD_RENDER_WND;
            TRTCCloudCore::GetInstance()->switchVodRender(VOD_RENDER_WND);
        } else if (msg.pSender->GetName() == _T("vod_render")) {
            CDataCenter::GetInstance()->vod_render_mode_ = VOD_RENDER_CUSTOM;
            TRTCCloudCore::GetInstance()->switchVodRender(VOD_RENDER_CUSTOM);
        } else if (msg.pSender->GetName() == _T("trtc_render")) {
            CDataCenter::GetInstance()->vod_render_mode_ = VOD_RENDER_TRTC;
            TRTCCloudCore::GetInstance()->switchVodRender(VOD_RENDER_TRTC);
        }
    }
}

DuiLib::CControlUI* TRTCSettingViewController::CreateControl(LPCTSTR pstrClass)
{
    if (_tcsicmp(pstrClass, _T("VideoViewLayoutUI")) == 0)
    {
        m_pVideoView = new TXLiveAvVideoView();
        return m_pVideoView;
    }
    return nullptr;
}

void TRTCSettingViewController::onSpeedTest(const TRTCSpeedTestResult& currentResult, uint32_t finishedCount, uint32_t totalCount)
{
    // todo

    //LINFO(L"onSpeedTest index[%d], total[%d], ip[%s], upLostRate[%d], downLostRate[%d], rtt[%d]\n", index, total, ip, upLostRate, downLostRate, rtt);
    //
    //int level = 0;
    //level = (int)upLostRate * 100.0;

    //if (level < (int)downLostRate * 100.0)
    //    level = (int)downLostRate * 100.0;
    //if (level < rtt / 10)
    //    level = rtt / 10;
    //if (level > 100)
    //    level = 100;

    //::PostMessage(GetHWND(), WM_USER_CMD_TestComplete, (WPARAM)level, 0);  
}

void TRTCSettingViewController::onUserVoiceVolume(TRTCVolumeInfo* userVolumes, uint32_t userVolumesCount, uint32_t totalVolume)
{
    for (uint32_t i = 0; i < userVolumesCount; ++i)
    {
        std::string * str = new std::string(userVolumes[i].userId);
        ::PostMessage(GetHWND(), WM_USER_CMD_MemberVolumeCallback, (WPARAM)str, userVolumes[i].volume);
    }
}

void TRTCSettingViewController::onTestMicVolume(uint32_t volume)
{
    ::PostMessage(GetHWND(), WM_USER_CMD_MicVolumeCallback, (WPARAM)volume, 0);
}

void TRTCSettingViewController::onTestSpeakerVolume(uint32_t volume)
{
    ::PostMessage(GetHWND(), WM_USER_CMD_SpeakerVolumeCallback, (WPARAM)volume, 0);
}



void TRTCSettingViewController::DoRecordError(int nRet,std::string msg)
{
    if (nRet == ERR_RECORD_SUCCESS)
    {
        CDataCenter::GetInstance()->m_bWaitStartRecordNotify = false;
        CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_record_opt_status")));
        if(pLabelValue)
            pLabelValue->SetText(L"启动录制成功");

    }
    else if (nRet == ERR_RECORD_PARAM_INVALID || nRet == ERR_START_RECORD_EXE_FAULURE || nRet == ERR_CREATE_RECORD_FILE_FAILURE || nRet == ERR_RECORD_CANCEL_BY_EXCEPTION)
    {
        TRTCCloudCore::GetInstance()->stopLocalRecord();
        COptionUI* pCheckUI = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_start_record")));
        if(pCheckUI)
            pCheckUI->Selected(false);

        CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_record_opt_status")));
        if(pLabelValue)
        {
            CDuiString sText;
            sText.Format(_T("启动录制失败:%s"), UTF82Wide(msg).c_str());
            pLabelValue->SetText(sText);
        }
    }

}

void TRTCSettingViewController::DoRecordComplete(std::string path)
{
    CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_record_opt_status")));
    if(pLabelValue)
    {
        CDuiString sText;
        sText.Format(_T("录制文件生成:%s"),UTF82Wide(path).c_str());
        pLabelValue->SetText(sText);
    }
}

void TRTCSettingViewController::DoRecordProgress(int duration,int fileSize)
{
    int duration_s = duration / 1000;
    int h,m,s;
    h = duration_s / 3600;
    m = (duration_s % 3600) / 60;
    s = duration_s % 3600 % 60;

    CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_record_opt_status")));
    if(pLabelValue)
    {
        CDuiString sText;
        if (CDataCenter::GetInstance()->m_bPauseLocalRecord)
            sText.Format(_T("【暂停录制】录制时长【 %d:%d:%d 】, 录制大小【 %d KB 】"), h, m , s ,fileSize / 1024);
        else
            sText.Format(_T("录制时长【 %d:%d:%d 】, 录制大小【 %d KB 】"), h, m , s ,fileSize / 1024);
        pLabelValue->SetText(sText);
    }
    CDataCenter::GetInstance()->m_bWaitStartRecordNotify = true;
}

void TRTCSettingViewController::InitWindow()
{
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_DeviceChange, GetHWND());

    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_OnRecordProgress, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_OnRecordError, GetHWND());
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_OnRecordComplete, GetHWND());

    SetIcon(IDR_MAINFRAME);

    InitNormalTab();
    InitAudioTab();
    InitVideoTab();
    InitOtherTab();
    InitMixTab();
    InitRecordTab();
    InitVodTab();

    //初始化tab面板  
    CTabLayoutUI* pTabSwitch = static_cast<CTabLayoutUI*>(m_pmUI.FindControl(_T("tab_switch")));
    if (pTabSwitch)
    {
        pTabSwitch->SelectItem(0);
        switch (m_eTagType)
        {
        case TRTCSettingViewController::SettingTag_Audio:
        {
            COptionUI* pTabHeader = static_cast<COptionUI*>(m_pmUI.FindControl(_T("audio_tab")));
            if (pTabHeader)
                pTabHeader->Selected(true);
            pTabSwitch->SelectItem(2);
            break;
        }
        case TRTCSettingViewController::SettingTag_Video:
        {
            COptionUI* pTabHeader = static_cast<COptionUI*>(m_pmUI.FindControl(_T("video_tab")));
            if (pTabHeader)
                pTabHeader->Selected(true);
            pTabSwitch->SelectItem(1);
            break;
        }
        }
    }

    is_init_windows_finished = true;
}

void TRTCSettingViewController::InitNormalTab()
{
    //初始化流控类型
    TRTCVideoQosPreference videoQosPreference = CDataCenter::GetInstance()->m_qosParams.preference;
    COptionUI* pQosFluent = static_cast<COptionUI*>(m_pmUI.FindControl(_T("qos_smooth")));
    COptionUI* pQosClear = static_cast<COptionUI*>(m_pmUI.FindControl(_T("qos_clear")));
    COptionUI* pQosLive = static_cast<COptionUI*>(m_pmUI.FindControl(_T("qos_live")));
    if (pQosFluent && pQosClear /*&& pQosLive*/) {
        pQosFluent->Selected(false);
        pQosClear->Selected(false);
        if (videoQosPreference == TRTCVideoQosPreferenceSmooth)
            pQosFluent->Selected(true);
        if (videoQosPreference == TRTCVideoQosPreferenceClear)
            pQosClear->Selected(true);
    }

    TRTCQosControlMode controlMode = CDataCenter::GetInstance()->m_qosParams.controlMode;
    COptionUI* pQosClient = static_cast<COptionUI*>(m_pmUI.FindControl(_T("qos_client")));
    COptionUI* pQosCloud = static_cast<COptionUI*>(m_pmUI.FindControl(_T("qos_cloud")));
    if (pQosClient && pQosCloud)
    {
        pQosClient->Selected(false);
        pQosCloud->Selected(false);
        if (controlMode == TRTCQosControlModeClient)
            pQosClient->Selected(true);
        if (controlMode == TRTCQosControlModeServer)
            pQosCloud->Selected(true);
    }

    TRTCAppScene appScene = CDataCenter::GetInstance()->m_sceneParams;
    COptionUI* pSceneCall = static_cast<COptionUI*>(m_pmUI.FindControl(_T("scene_call")));
    COptionUI* pSceneLive = static_cast<COptionUI*>(m_pmUI.FindControl(_T("scene_live")));
    COptionUI* pAudioSceneLive = static_cast<COptionUI*>(m_pmUI.FindControl(_T("audio_scene_live")));
    COptionUI* pAudioSceneCall = static_cast<COptionUI*>(m_pmUI.FindControl(_T("audio_scene_call")));
    if (pSceneLive && pSceneCall && pAudioSceneLive && pAudioSceneCall)
    {
        pSceneCall->Selected(false);
        pSceneLive->Selected(false);
        if (appScene == TRTCAppSceneVideoCall)
            pSceneCall->Selected(true);
        if (appScene == TRTCAppSceneLIVE)
            pSceneLive->Selected(true);
        if(appScene == TRTCAppSceneAudioCall)
            pAudioSceneCall->Selected(true);
        if(appScene == TRTCAppSceneVoiceChatRoom)
            pAudioSceneLive->Selected(true);
    }
   
    //处理大小流的设置配置
    COptionUI* pPushSmallVideo = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_push_smallvideo")));
    COptionUI* pPlaySmallVideo = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_play_smallvideo")));
    if (pPushSmallVideo && pPlaySmallVideo)
    {
        pPushSmallVideo->Selected(false);
        pPlaySmallVideo->Selected(false);
        if (CDataCenter::GetInstance()->m_bPushSmallVideo)
            pPushSmallVideo->Selected(true);
        if (CDataCenter::GetInstance()->m_bPlaySmallVideo)
            pPlaySmallVideo->Selected(true);
    }

    //处理音视频接收模式
    COptionUI* pAutoMode = static_cast<COptionUI*>(m_pmUI.FindControl(_T("auto_mode")));
    COptionUI* pAudioMode = static_cast<COptionUI*>(m_pmUI.FindControl(_T("audio_mode")));
    COptionUI* pVideoMode = static_cast<COptionUI*>(m_pmUI.FindControl(_T("video_mode")));
    COptionUI* pManualMode = static_cast<COptionUI*>(m_pmUI.FindControl(_T("manual_mode")));
    if (pAutoMode && pAudioMode && pVideoMode && pManualMode)
    {
        if (CDataCenter::GetInstance()->m_bAutoRecvAudio == true && CDataCenter::GetInstance()->m_bAutoRecvVideo == true)
        {
            pAutoMode->Selected(true);
            pAudioMode->Selected(false);
            pVideoMode->Selected(false);
            pManualMode->Selected(false);
        }
        else  if (CDataCenter::GetInstance()->m_bAutoRecvAudio == true && CDataCenter::GetInstance()->m_bAutoRecvVideo == false)
        {
            pAutoMode->Selected(false);
            pAudioMode->Selected(true);
            pVideoMode->Selected(false);
            pManualMode->Selected(false);
        }
        else  if (CDataCenter::GetInstance()->m_bAutoRecvAudio == false && CDataCenter::GetInstance()->m_bAutoRecvVideo == true)
        {
            pAutoMode->Selected(false);
            pAudioMode->Selected(false);
            pVideoMode->Selected(true);
            pManualMode->Selected(false);
        }
        else  if (CDataCenter::GetInstance()->m_bAutoRecvAudio == false && CDataCenter::GetInstance()->m_bAutoRecvVideo == false)
        {
            pAutoMode->Selected(false);
            pAudioMode->Selected(false);
            pVideoMode->Selected(false);
            pManualMode->Selected(true);
        }
       
       
    }

    //处理美颜设置 
    {
        CDataCenter::BeautyConfig& beautyConfig = CDataCenter::GetInstance()->GetBeautyConfig();
        COptionUI* pOpenBeautyCheck = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_open_beaty")));
        COptionUI* pBeautySmooth = static_cast<COptionUI*>(m_pmUI.FindControl(_T("smooth_beauty")));
        COptionUI* pBeautyNatural = static_cast<COptionUI*>(m_pmUI.FindControl(_T("natural_beauty")));
        if (pBeautySmooth && pBeautyNatural) {
            pBeautyNatural->Selected(false);
            pBeautySmooth->Selected(false);
            if (beautyConfig._beautyStyle == TRTCBeautyStyleSmooth)
                pBeautySmooth->Selected(true);
            if (beautyConfig._beautyStyle == TRTCBeautyStyleNature)
                pBeautyNatural->Selected(true);
        }
        CSliderUI* pBeautySlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_beauty_value")));
        CSliderUI* pRuddinessSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_ruddiness_value")));
        CSliderUI* pWhiteSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_white_value")));
        if (pBeautySlider && pRuddinessSlider && pWhiteSlider)
        {
            pBeautySlider->SetValue(beautyConfig._beautyValue);
            pRuddinessSlider->SetValue(beautyConfig._ruddinessValue);
            pWhiteSlider->SetValue(beautyConfig._whiteValue);
        }
        if (beautyConfig._bOpenBeauty)
        {
            pOpenBeautyCheck->Selected(true);
        }
        else
        {
            pOpenBeautyCheck->Selected(false);
            pBeautySmooth->SetEnabled(false);
            pBeautyNatural->SetEnabled(false);
            pBeautySlider->SetEnabled(false);
            pRuddinessSlider->SetEnabled(false);
            pWhiteSlider->SetEnabled(false);
        }
    }
    
    //处理混流的设置配置
    {
        COptionUI* pMixTempSel = static_cast<COptionUI*>(m_pmUI.FindControl(_T("mix_temp_manual")));;

        int mixTempID = CDataCenter::GetInstance()->m_mixTemplateID;
        switch (mixTempID) {
            case TRTCTranscodingConfigMode_Template_PureAudio:
                pMixTempSel = static_cast<COptionUI*>(m_pmUI.FindControl(_T("mix_temp_pure_audio")));
                break;
            case TRTCTranscodingConfigMode_Template_ScreenSharing:
                pMixTempSel = static_cast<COptionUI*>(m_pmUI.FindControl(_T("mix_temp_screen_share")));
                break;
            case TRTCTranscodingConfigMode_Template_PresetLayout:
                pMixTempSel = static_cast<COptionUI*>(m_pmUI.FindControl(_T("mix_temp_preset")));
                break;
            case 0:
            default:
                break;
        }
        if(pMixTempSel) pMixTempSel->Selected(true);
    }

    //处理本地录制的设置配置
    {
        COptionUI* pLocalRecordTypeSel = static_cast<COptionUI*>(m_pmUI.FindControl(_T("local_record_both")));;

        TRTCLocalRecordType localRecordType = CDataCenter::GetInstance()->m_localRecordType;
        switch (localRecordType) {
        case TRTCLocalRecordType_Audio:
            pLocalRecordTypeSel = static_cast<COptionUI*>(m_pmUI.FindControl(_T("local_record_audio")));
            break;
        case TRTCLocalRecordType_Video:
            pLocalRecordTypeSel = static_cast<COptionUI*>(m_pmUI.FindControl(_T("local_record_video")));
            break;
        case TRTCLocalRecordType_Both:
            pLocalRecordTypeSel = static_cast<COptionUI*>(m_pmUI.FindControl(_T("local_record_both")));
            break;
        default:
            break;
        }
        if (pLocalRecordTypeSel) pLocalRecordTypeSel->Selected(true);
    }
}

void TRTCSettingViewController::InitAudioTab()
{
    UpdateMicDevice();
    UpdateSpeakerDevice();
    {
        if (TRTCCloudCore::GetInstance()->getDeviceManager()) {
            CDataCenter::GetInstance()->m_speakerVolume =
                TRTCCloudCore::GetInstance()->getDeviceManager()->getCurrentDeviceVolume(
                    TRTCDeviceTypeSpeaker);
        }
        uint32_t nVolume = CDataCenter::GetInstance()->m_speakerVolume;
        nVolume = nVolume * 100 / AUDIO_DEVICE_VOLUME_TICKET;
        CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_speaker_volume")));
        if (pSlider)
            pSlider->SetValue(nVolume);
        CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_speaker_volume")));
        if (pLabelValue)
        {
            CDuiString sText;
            sText.Format(_T("%d%%"), nVolume);
            pLabelValue->SetText(sText);
        }
        if (TRTCCloudCore::GetInstance()->getDeviceManager()) {

            bool mute = TRTCCloudCore::GetInstance()->getDeviceManager()->getCurrentDeviceMute(TRTCDeviceTypeSpeaker);
            COptionUI* pCheckMute = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_speaker_mute")));
            if (pCheckMute)
                pCheckMute->Selected(mute);
        }
    }
    {
        if (TRTCCloudCore::GetInstance()->getTRTCCloud()) {
            CDataCenter::GetInstance()->m_micVolume =
                 TRTCCloudCore::GetInstance()->getDeviceManager()->getCurrentDeviceVolume(TRTCDeviceTypeMic);
        }
        uint32_t nVolume = CDataCenter::GetInstance()->m_micVolume;
        nVolume = nVolume * 100 / AUDIO_DEVICE_VOLUME_TICKET;
        CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_mic_volume")));
        if (pSlider)
            pSlider->SetValue(nVolume);
        CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_mic_volume")));
        if (pLabelValue)
        {
            CDuiString sText;
            sText.Format(_T("%d%%"), nVolume);
            pLabelValue->SetText(sText);
        }
        if (TRTCCloudCore::GetInstance()->getTRTCCloud()) {

            bool mute = TRTCCloudCore::GetInstance()->getDeviceManager()->getCurrentDeviceMute(TRTCDeviceTypeMic);
            COptionUI* pCheckMute = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_mic_mute")));
            if (pCheckMute)
                pCheckMute->Selected(mute);
        }
    }

    {
        uint32_t nVolume = CDataCenter::GetInstance()->m_audioCaptureVolume;
        nVolume = nVolume * 100 / AUDIO_DEVICE_VOLUME_TICKET;
        CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_app_capture_volume")));
        if(pSlider)
            pSlider->SetValue(nVolume);
        CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_app_capture_volume")));
        if(pLabelValue)
        {
            CDuiString sText;
            sText.Format(_T("%d%%"),nVolume);
            pLabelValue->SetText(sText);
        }
    }

    {
        uint32_t nVolume = CDataCenter::GetInstance()->m_audioPlayoutVolume;
        nVolume = nVolume * 100 / AUDIO_DEVICE_VOLUME_TICKET;
        CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_app_playout_volume")));
        if(pSlider)
            pSlider->SetValue(nVolume);
        CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_app_playout_volume")));
        if(pLabelValue)
        {
            CDuiString sText;
            sText.Format(_T("%d%%"),nVolume);
            pLabelValue->SetText(sText);
        }
    }

    //初始化进度条
    m_pProgressTestSpeaker = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("progress_testspeaker")));
    m_pProgressTestMic = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("progress_testmic")));
    m_pProgressTestNetwork = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("progress_testnetwork")));

    CComboUI* audio_quality_combo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_audio_quality")));
    if (audio_quality_combo && CDataCenter::GetInstance()->audio_quality_ != TRTCAudioQualityUnSelect) {
        is_init_audio_quality_combo = true;
        if (CDataCenter::GetInstance()->audio_quality_ == TRTCAudioQualitySpeech) { 
            audio_quality_combo->SelectItem(0);
        }
        else if (CDataCenter::GetInstance()->audio_quality_ == TRTCAudioQualityDefault)
        {
            audio_quality_combo->SelectItem(1);
        }
        else if (CDataCenter::GetInstance()->audio_quality_ == TRTCAudioQualityMusic)
        {
            audio_quality_combo->SelectItem(2);
        }
        else
        {
            if (CDataCenter::GetInstance()->m_sceneParams == TRTCAppSceneVideoCall ||
                CDataCenter::GetInstance()->m_sceneParams ==  TRTCAppSceneAudioCall) { 
                audio_quality_combo->SelectItem(0);
            }
            else {
                audio_quality_combo->SelectItem(1);
            }
        }
    }

    //音频 3A 开关
    COptionUI* pCheckAec = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_btn_aec")));
    COptionUI* pCheckAns = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_btn_ans")));
    COptionUI* pCheckAgc = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_btn_agc")));
    COptionUI* pCheckSystemAudioMix = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_system_audio_mix")));

    if (pCheckAec && pCheckAns && pCheckAgc && pCheckSystemAudioMix)
    {
        if (CDataCenter::GetInstance()->m_bEnableAec)
            pCheckAec->Selected(true);
        else
            pCheckAec->Selected(false);
        if (CDataCenter::GetInstance()->m_bEnableAns)
            pCheckAns->Selected(true);
        else
            pCheckAns->Selected(false);
        if (CDataCenter::GetInstance()->m_bEnableAgc)
            pCheckAgc->Selected(true);
        else
            pCheckAgc->Selected(false);
        if (CDataCenter::GetInstance()->m_bStartSystemVoice)
        {
            pCheckSystemAudioMix->Selected(true);
        }
        else
            pCheckSystemAudioMix->Selected(false);
    }

    if (CDataCenter::GetInstance()->m_bOpenDemoTestConfig) {
        CHorizontalLayoutUI* aec_layout =
            static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("ace_layout")));
        if (aec_layout) {
            aec_layout->SetVisible(true);
        }

        CHorizontalLayoutUI* hook_aec_layout =
            static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("hook_aec_layout")));
        if (hook_aec_layout) {
            hook_aec_layout->SetVisible(true);
        }
        CHorizontalLayoutUI* agc_layout =
            static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("agc_layout")));
        if (agc_layout) {
            agc_layout->SetVisible(true);
        }
        CHorizontalLayoutUI* ans_layout =
            static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("ans_layout")));
        if (ans_layout) {
            ans_layout->SetVisible(true);
        }

        CGroupBoxUI* auido_groupbox =
            static_cast<CGroupBoxUI*>(m_pmUI.FindControl(_T("audio_groupbox")));
        if (auido_groupbox) {
            auido_groupbox->SetFixedHeight(320);
        }

         CVerticalLayoutUI* switch_room_layout =
             static_cast<CVerticalLayoutUI*>(m_pmUI.FindControl(_T("switch_room_layout")));
         if (switch_room_layout) {
            switch_room_layout->SetVisible(true);
         }

         CVerticalLayoutUI* test_feat_layout =
             static_cast<CVerticalLayoutUI*>(m_pmUI.FindControl(_T("test_feat_layout")));
         if (test_feat_layout) {
             test_feat_layout->SetVisible(true);
         }
    }
}

void TRTCSettingViewController::InitVideoTab()
{
    //初始化设备
    UpdateCameraDevice();

    updateVideoBitrateUi();

    CComboUI* pFpsCombo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_videofps")));
    if (pFpsCombo)
    {
        if (CDataCenter::GetInstance()->m_videoEncParams.videoFps == 15)
            pFpsCombo->SelectItem(0);
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoFps == 20)
            pFpsCombo->SelectItem(1);
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoFps == 24)
            pFpsCombo->SelectItem(2);
        else
        {
            CDataCenter::GetInstance()->m_videoEncParams.videoFps = 15;
            pFpsCombo->SelectItem(0);
        }
    }

    //初始化分辨率
    CComboUI* pResolutionCombo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_videoresolution")));
    if (pResolutionCombo)
    {
        bool bSetDefaultItem = false;
        if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_120_120)
        {
            pResolutionCombo->SelectItem(0); bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_160_160)
        {
            pResolutionCombo->SelectItem(1);  bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_270_270)
        {
            pResolutionCombo->SelectItem(2);  bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_480_480)
        {
            pResolutionCombo->SelectItem(3);  bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_160_120)
        {
            pResolutionCombo->SelectItem(4);  bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_240_180)
        {
            pResolutionCombo->SelectItem(5);  bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_280_210)
        {
            pResolutionCombo->SelectItem(6);  bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_320_240)
        {
            pResolutionCombo->SelectItem(7);  bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_400_300)
        {
            pResolutionCombo->SelectItem(8);  bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_480_360)
        {
            pResolutionCombo->SelectItem(9);  bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_640_480)
        {
            pResolutionCombo->SelectItem(10);  bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_960_720)
        {
            pResolutionCombo->SelectItem(11);  bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_320_180)
        {
            pResolutionCombo->SelectItem(12);  bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_480_270)
        {
            pResolutionCombo->SelectItem(13);  bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_640_360)
        {
            pResolutionCombo->SelectItem(14);  bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_960_540)
        {
            pResolutionCombo->SelectItem(15);  bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_1280_720)
        {
            pResolutionCombo->SelectItem(16);  bSetDefaultItem = true;
        }
        else if (CDataCenter::GetInstance()->m_videoEncParams.videoResolution == TRTCVideoResolution_1920_1080)
        {
            pResolutionCombo->SelectItem(17);  bSetDefaultItem = true;
        }
        if (bSetDefaultItem == false)
        {
            CDataCenter::GetInstance()->m_videoEncParams.videoResolution = TRTCVideoResolution_640_360;
            pResolutionCombo->SelectItem(14);
        }
    }

    //处理横竖屏的逻辑
    TRTCVideoResolutionMode resMode = CDataCenter::GetInstance()->m_videoEncParams.resMode;
    COptionUI* pHorizontalScreen = static_cast<COptionUI*>(m_pmUI.FindControl(_T("horizontal_screen")));
    COptionUI* pVerticalScreen = static_cast<COptionUI*>(m_pmUI.FindControl(_T("vertical_screen")));
    if (pHorizontalScreen && pVerticalScreen)
    {
        pHorizontalScreen->Selected(false);
        pVerticalScreen->Selected(false);
        if (resMode == TRTCVideoResolutionModeLandscape)
            pVerticalScreen->Selected(true);
        if (resMode == TRTCVideoResolutionModePortrait)
            pHorizontalScreen->Selected(true);
    }
}

void TRTCSettingViewController::InitOtherTab()
{
    //其他设置
    COptionUI* pLoacalMirror = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_local_mirror")));
    if (pLoacalMirror)
    {
        pLoacalMirror->Selected(false);
        if (CDataCenter::GetInstance()->m_bLocalVideoMirror)
            pLoacalMirror->Selected(true);
    }
    COptionUI* pWaterMark =
        static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_water_mark")));
    if (pWaterMark) {
        pWaterMark->Selected(false);
        if (CDataCenter::GetInstance()->m_bWateMark) pWaterMark->Selected(true);
    }
    COptionUI* pBlackPush = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_black_push")));
    if (pBlackPush)
    {
        pBlackPush->Selected(false);
        if (CDataCenter::GetInstance()->m_bBlackFramePush)
            pBlackPush->Selected(true);
    }
    COptionUI* pShowAudioVolume = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_voice_volume")));
    if (pShowAudioVolume)
    {
        pShowAudioVolume->Selected(false);
        if (CDataCenter::GetInstance()->m_bShowAudioVolume)
            pShowAudioVolume->Selected(true);
    }

    COptionUI* pCustomAuidoCheck = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_custom_audio")));
    if (pCustomAuidoCheck)
    {
        pCustomAuidoCheck->Selected(false);
        if (CDataCenter::GetInstance()->m_bCustomAudioCapture)
            pCustomAuidoCheck->Selected(true);
    }

    COptionUI* pCustomVideoCheck = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_custom_video")));
    if (pCustomVideoCheck)
    {
        pCustomVideoCheck->Selected(false);
        if (CDataCenter::GetInstance()->m_bCustomVideoCapture)
            pCustomVideoCheck->Selected(true);
    }

    CComboUI* pAudioFileCombo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_audio_pcmfile")));
    if (pAudioFileCombo)
    {
        pAudioFileCombo->SelectItem(0);
    }

    CComboUI* pVideoFileCombo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_video_yuvfile")));
    if (pVideoFileCombo)
    {
        pVideoFileCombo->SelectItem(0);
    }

     CComboUI* pAudioSubFileCombo =
        static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_audio_sub_pcmfile")));
    if (pAudioSubFileCombo) {
         pAudioSubFileCombo->SelectItem(0);
    }

    CComboUI* pVideoSubFileCombo =
        static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_video_sub_yuvfile")));
    if (pVideoSubFileCombo) {
        pVideoSubFileCombo->SelectItem(0);
    }

    COptionUI* pPublishScreenInBigStream = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_use_main_stream")));
    if (pPublishScreenInBigStream)
    {
        pPublishScreenInBigStream->Selected(false);
        if (CDataCenter::GetInstance()->m_bPublishScreenInBigStream)
            pPublishScreenInBigStream->Selected(true);
    }

    CEditUI* pEditIp = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_ip")));
    if (pEditIp != nullptr)
        pEditIp->SetText(UTF82Wide(CDataCenter::GetInstance()->m_strSocks5ProxyIp).c_str());

    char string_num[32];
    itoa(CDataCenter::GetInstance()->m_strSocks5ProxyPort, string_num, 10);
    std::string strPort = string_num;
    CEditUI* pEditPort = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_port")));
    if (pEditPort != nullptr)
        pEditPort->SetText(UTF82Wide(strPort).c_str());


    COptionUI* pCheckLocalVideoOpenUI = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_localvideo_open")));
    if (pCheckLocalVideoOpenUI)
    {
        pCheckLocalVideoOpenUI->Selected(false);

        if (!CDataCenter::GetInstance()->m_bMuteLocalVideo)
        {
            pCheckLocalVideoOpenUI->Selected(true);
        }
    }

    COptionUI* pCheckLocalAudioOpenUI = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_localaudio_open")));
    if (pCheckLocalAudioOpenUI)
    {
        pCheckLocalAudioOpenUI->Selected(false);

        if (!CDataCenter::GetInstance()->m_bMuteLocalAudio)
        {
            pCheckLocalAudioOpenUI->Selected(true);
        }
    }

    COptionUI* pCheckMiniWindowOpenUI = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_mini_windows")));
    if (pCheckMiniWindowOpenUI) {
        pCheckMiniWindowOpenUI->Selected(false);
        if (CDataCenter::GetInstance()->need_minimize_windows_) {
            pCheckMiniWindowOpenUI->Selected(true);
        }
    }
}

void TRTCSettingViewController::InitMixTab()
{
    COptionUI* pCdnMixVideo = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_cdnmix_video")));
    if(pCdnMixVideo)
    {
        pCdnMixVideo->Selected(false);
        if(CDataCenter::GetInstance()->m_bCDNMixTranscoding)
            pCdnMixVideo->Selected(true);
    }

    if(CDataCenter::GetInstance()->m_bOpenDemoTestConfig)
    {
        CHorizontalLayoutUI* customMixId = static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("custom_mixid_container")));
        if (customMixId)
            customMixId->SetVisible(true);
    }
}

void TRTCSettingViewController::InitRecordTab()
{
   COptionUI* pCheckUI = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_start_record")));
    if(pCheckUI)
    {
        pCheckUI->Selected(false);
        if (CDataCenter::GetInstance()->m_bStartLocalRecord)
        {
            pCheckUI->Selected(true);
            CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_record_opt_status")));
            if (pLabelValue)
            {
                CDuiString sText;
                sText.Format(_T("正在启动录制:%s ...."), CDataCenter::GetInstance()->m_recordCaptureSourceInfoName.c_str());
                pLabelValue->SetText(sText);
            }
        }
           
    }

    pCheckUI = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_pause_record")));
    if(pCheckUI)
    {
        pCheckUI->Selected(false);
        if (CDataCenter::GetInstance()->m_bPauseLocalRecord)
        {
            pCheckUI->Selected(true);
            CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_record_opt_status")));
            if (pLabelValue)
                pLabelValue->SetText(_T("暂停录制..."));
        }
           
    }
    

    if(CDataCenter::GetInstance()->m_bOpenDemoTestConfig)
    {
        COptionUI* pRecordTab = static_cast<COptionUI*>(m_pmUI.FindControl(_T("record_tab")));
        if(pRecordTab)
        {
            pRecordTab->SetVisible(true);
        }
    }
   

    COptionUI* pCheckAudioRecordUI = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_start_audio_record")));
    if (pCheckAudioRecordUI)
    {
        pCheckAudioRecordUI->Selected(false);
        if (CDataCenter::GetInstance()->m_bStartAudioRecording)
        {
            pCheckAudioRecordUI->Selected(true);

            CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_audio_record_opt_status")));
            if (pLabelValue)
            {
                CDuiString sText;
                sText.Format(_T("正在启动录音:%s ...."), CDataCenter::GetInstance()->m_wstrAudioRecordFile.c_str());
                pLabelValue->SetText(sText);
            }

        }
        else
        {
            pCheckAudioRecordUI->Selected(false);
        }
    }

    COptionUI* pCheckMixAppAudioUI =
        static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_start_mix_app_audio")));
    if (pCheckMixAppAudioUI) {
        pCheckMixAppAudioUI->Selected(false);
        if (CDataCenter::GetInstance()->m_bStartMixAppAudio) {
            pCheckMixAppAudioUI->Selected(true);

            CLabelUI* pLabelValue =
                static_cast<CLabelUI*>(m_pmUI.FindControl(_T("label_mix_app_audio_opt_status")));
            if (pLabelValue) {
                CDuiString sText;
                sText.Format(_T("正在进程混音:%s ...."),
                             CDataCenter::GetInstance()->m_wstrMixAudioAppPath.c_str());
                pLabelValue->SetText(sText);
            }
        } else {
            pCheckMixAppAudioUI->Selected(false);
        }
    }
}

void TRTCSettingViewController::InitVodTab() {
    COptionUI* pVodPushVideo = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_push_video_stream")));
    if (pVodPushVideo) {
        pVodPushVideo->Selected(CDataCenter::GetInstance()->vod_push_video_);
    }
    COptionUI* pVodPushAudio = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_push_audio_stream")));
    if (pVodPushAudio) {
        pVodPushAudio->Selected(CDataCenter::GetInstance()->vod_push_audio_);
    }
    COptionUI* pRenderModeVodWnd =
        static_cast<COptionUI*>(m_pmUI.FindControl(_T("vod_wnd_render")));
    COptionUI* pRenderModeVodCustom = static_cast<COptionUI*>(m_pmUI.FindControl(_T("vod_render")));
    COptionUI* pRenderModeTRTCWnd = static_cast<COptionUI*>(m_pmUI.FindControl(_T("trtc_render")));
    if (pRenderModeVodWnd && pRenderModeVodCustom && pRenderModeTRTCWnd)
    {
        pRenderModeVodWnd->Selected(false);
        pRenderModeVodCustom->Selected(false);
        pRenderModeTRTCWnd->Selected(false);

        if (CDataCenter::GetInstance()->vod_render_mode_ == VOD_RENDER_WND){
            pRenderModeVodWnd->Selected(true);
        } else if (CDataCenter::GetInstance()->vod_render_mode_ == VOD_RENDER_CUSTOM) {
            pRenderModeVodCustom->Selected(true);
        } else if (CDataCenter::GetInstance()->vod_render_mode_ == VOD_RENDER_TRTC) {
            pRenderModeTRTCWnd->Selected(true);
        }
    }
    
}

void TRTCSettingViewController::UpdateCameraDevice()
{
    //初始化视频设备 
    CComboUI* pDeviceCombo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_camera")));
    if (pDeviceCombo) {
        pDeviceCombo->RemoveAll();
        std::vector<TRTCCloudCore::MediaDeviceInfo> vecDeviceList = TRTCCloudCore::GetInstance()->getCameraDevice();
        int selectIndex = -1, cnt = -1;
        for (auto info : vecDeviceList) {
            cnt++;
            CListLabelElementUI* pElement = new CListLabelElementUI;
            pElement->SetText(info._text.c_str());
            pElement->SetName(info._type.c_str());
            if (info._select) {
                selectIndex = cnt;
            }
            pDeviceCombo->Add(pElement);
        }
        if (selectIndex >= 0) {
            pDeviceCombo->SelectItem(selectIndex);

            LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();
            if (m_pVideoView->IsViewOccupy() == false) {
                m_pVideoView->SetRenderInfo("camera-test", TRTCVideoStreamType::TRTCVideoStreamTypeBig, false);
                m_pVideoView->SetRenderMode(TXLiveAvVideoView::EVideoRenderModeFit);
            }

            m_pVideoView->SetPause(false);
            TRTCCloudCore::GetInstance()->getDeviceManager()->startCameraDeviceTest((ITRTCVideoRenderCallback*)getShareViewMgrInstance());
            m_bStartLocalPreview = true;
        }
        else {
            TRTCCloudCore::GetInstance()->getDeviceManager()->stopCameraDeviceTest();
            m_bStartLocalPreview = false;
            m_pVideoView->SetPause(true);
            m_pVideoView->NeedUpdate();
        }
    }
}

void TRTCSettingViewController::UpdateMicDevice()
{
    //初始化音频设备
    CComboUI* pDeviceCombo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_mic_device")));
    if (pDeviceCombo)
    {
        pDeviceCombo->RemoveAll();
        std::vector<TRTCCloudCore::MediaDeviceInfo> vecDeviceList = TRTCCloudCore::GetInstance()->getMicDevice();
        int selectIndex = -1, cnt = -1;
        for (auto info : vecDeviceList)
        {
            cnt++;
            CListLabelElementUI* pElement = new CListLabelElementUI;
            pElement->SetText(info._text.c_str());
            pElement->SetName(info._type.c_str());
            if (info._select) {
                selectIndex = cnt;
            }
            pDeviceCombo->Add(pElement);
        }
        if (selectIndex >= 0) {
            is_init_device_combo_list_ = true;
            pDeviceCombo->SelectItem(selectIndex);
        }
    }
}

void TRTCSettingViewController::UpdateSpeakerDevice()
{
    // 初始化音频设备
    CComboUI* pDeviceCombo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_speaker_device")));
    if (pDeviceCombo)
    {
        pDeviceCombo->RemoveAll();
        std::vector<TRTCCloudCore::MediaDeviceInfo> vecDeviceList = TRTCCloudCore::GetInstance()->getSpeakDevice();
        int selectIndex = -1, cnt = -1;
        for (auto info : vecDeviceList)
        {
            cnt++;
            CListLabelElementUI* pElement = new CListLabelElementUI;
            pElement->SetText(info._text.c_str());
            pElement->SetName(info._type.c_str());
            if (info._select) {
                selectIndex = cnt;
            }
            pDeviceCombo->Add(pElement);
        }
        if (selectIndex >= 0) {
            is_init_device_combo_list_ = true;
            pDeviceCombo->SelectItem(selectIndex);
        }
    }
}

void TRTCSettingViewController::ResetBeautyConfig()
{
    CDataCenter::BeautyConfig& beautyConfig = CDataCenter::GetInstance()->GetBeautyConfig();
    if (beautyConfig._bOpenBeauty)
    {
        TRTCCloudCore::GetInstance()->getTRTCCloud()->setBeautyStyle(beautyConfig._beautyStyle, \
            beautyConfig._beautyValue, beautyConfig._whiteValue, beautyConfig._ruddinessValue);
    }
    else
    {
        TRTCCloudCore::GetInstance()->getTRTCCloud()->setBeautyStyle(beautyConfig._beautyStyle, 0, 0, 0);
    }
}

void TRTCSettingViewController::stopAllTestSetting()
{
    if (m_bStartLocalPreview)
        TRTCCloudCore::GetInstance()->getDeviceManager()->stopCameraDeviceTest();
    if (m_bStartTestMic)
        TRTCCloudCore::GetInstance()->getDeviceManager()->stopMicDeviceTest();
    if (m_bStartTestSpeaker)
        TRTCCloudCore::GetInstance()->getDeviceManager()->stopSpeakerDeviceTest();
    if (m_bStartTestNetwork)
        TRTCCloudCore::GetInstance()->getTRTCCloud()->stopSpeedTest();

    TRTCCloudCore::GetInstance()->getTRTCCloud()->stopAllAudioEffects();

    if (m_bMuteRemotesAudio)
    {
        RemoteUserInfoList& userMap = CDataCenter::GetInstance()->m_remoteUser;
        for (auto it : userMap)
        {
            //todo
        }
        m_bMuteRemotesAudio = false;
    }

    CEditUI* pEditIp = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_ip")));
    if (pEditIp != nullptr)
    {
        std::wstring strIp = pEditIp->GetText();
        if (!(strIp.compare(L"") == 0))
        {
            CDataCenter::GetInstance()->m_strSocks5ProxyIp = Wide2UTF8(strIp);
        }
    }

    CEditUI* pEditPort = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_port")));
    if (pEditPort != nullptr)
    {
        std::wstring strPort = pEditPort->GetText();
        if (!(strPort.compare(L"") == 0))
        {
            CDataCenter::GetInstance()->m_strSocks5ProxyPort = _wtoi(strPort.c_str());
        }
    }
}

void TRTCSettingViewController::updateRoleUi()
{
    TRTCRoleType roleType = CDataCenter::GetInstance()->m_roleType;
    COptionUI* pRoleAnchor = static_cast<COptionUI*>(m_pmUI.FindControl(_T("role_anchor")));
    COptionUI* pRoleAudience = static_cast<COptionUI*>(m_pmUI.FindControl(_T("role_audience")));
    if (CDataCenter::GetInstance()->m_sceneParams == TRTCAppSceneLIVE || CDataCenter::GetInstance()->m_sceneParams == TRTCAppSceneVoiceChatRoom)
    {
        if (pRoleAnchor && pRoleAudience)
        {
            pRoleAnchor->SetEnabled(true);
            pRoleAudience->SetEnabled(true);

            pRoleAnchor->Selected(false);
            pRoleAudience->Selected(false);

            if (roleType == TRTCRoleAnchor)
            {
                pRoleAnchor->Selected(true);

                CHorizontalLayoutUI* pHLayout = static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("livetype")));
                pHLayout->SetVisible(false);
            }
            if (roleType == TRTCRoleAudience)
            {
                pRoleAudience->Selected(true);
                LocalUserInfo& _loginInfo = CDataCenter::GetInstance()->getLocalUserInfo();
                if (_loginInfo._bEnterRoom&& is_init_windows_finished)
                {
                    CHorizontalLayoutUI* pHLayout = static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("livetype")));
                    pHLayout->SetVisible(true);

                    if (CDataCenter::GetInstance()->m_emLivePlayerSourceType == TRTC_RTC)
                    {
                        COptionUI* pRTC = static_cast<COptionUI*>(m_pmUI.FindControl(_T("trtc_rtc")));
                        pRTC->Selected(true);
                    }
                    else
                    {
                        COptionUI* pCDN = static_cast<COptionUI*>(m_pmUI.FindControl(_T("trtc_cdn")));
                        pCDN->Selected(true);
                    }
                }
              
            }
        }
    }
    else
    {
        if (pRoleAnchor && pRoleAudience)
        {
            pRoleAnchor->SetEnabled(true);
            pRoleAudience->SetEnabled(false);

            pRoleAnchor->Selected(false);
            pRoleAudience->Selected(false);

            CHorizontalLayoutUI* pHLayout = static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("livetype")));
            pHLayout->SetVisible(false);

            if (roleType == TRTCRoleAnchor)
            {
                pRoleAnchor->Selected(true);
            }
        }
    }
}

void TRTCSettingViewController::UpdateAudioQualityUi()
{
    if (CDataCenter::GetInstance()->m_sceneParams == TRTCAppSceneVideoCall ||
        CDataCenter::GetInstance()->m_sceneParams ==  TRTCAppSceneAudioCall) {
        CComboUI* audio_quality_combo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_audio_quality")));
        if (CDataCenter::GetInstance()->audio_quality_ == TRTCAudioQualityUnSelect && audio_quality_combo) {
            is_init_audio_quality_combo = true;
            audio_quality_combo->SelectItem(0);
        }
    }
    else
    {
        CComboUI* audio_quality_combo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_audio_quality")));
        if (CDataCenter::GetInstance()->audio_quality_ == TRTCAudioQualityUnSelect && audio_quality_combo)
        {
            is_init_audio_quality_combo = true;
            audio_quality_combo->SelectItem(1);
        }
    }
}

void TRTCSettingViewController::updateVideoBitrateUi()
{
    TRTCVideoEncParam& encParam = CDataCenter::GetInstance()->m_videoEncParams;
    CDataCenter::VideoResBitrateTable sliderInfo = CDataCenter::GetInstance()->getVideoConfigInfo(encParam.videoResolution);
    if (encParam.videoBitrate < sliderInfo.minBitrate || encParam.videoBitrate > sliderInfo.maxBitrate)
        encParam.videoBitrate = sliderInfo.defaultBitrate;

    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_videobitrate")));
    if (pSlider)
    {
        pSlider->SetMaxValue(sliderInfo.maxBitrate);
        pSlider->SetMinValue(sliderInfo.minBitrate);
        pSlider->SetValue(encParam.videoBitrate);
    }
    CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("slider_videobitrate_value")));
    if (pLabelValue)
    {
        CDuiString sText;
        sText.Format(_T("%dkbps"), encParam.videoBitrate);
        pLabelValue->SetText(sText);
    }
}

bool TRTCSettingViewController::isCustomUploaderStreamIdValid(const std::string & streamId)
{
    const char *pChar = streamId.c_str();
    auto length = streamId.length();
    for(int i = 0; i < length; ++i) {
        char c = pChar[i];
        // 不在 a~z A~Z 0~9 - _ 的都是非法字符
        if(!(('a' <= c) && (c <= 'z')) && !(('A' <= c) && (c <= 'Z')) &&
            !(('0' <= c) && (c <= '9')) && c != '-' && c != '_') {
            return false;
        }
    }
    return true;
}

void TRTCSettingViewController::OnFinalMessage(HWND hWnd)
{
     delete this;
}

LRESULT TRTCSettingViewController::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    if (uMsg == WM_CREATE) {
        m_pmUI.Init(m_hWnd);
        CDialogBuilder builder;
        CControlUI* pRoot = builder.Create(_T("trtc_setting.xml"), (UINT)0, this, &m_pmUI);
        ASSERT(pRoot && "Failed to parse XML");
        m_pmUI.AttachDialog(pRoot);
        m_pmUI.AddNotifier(this);
        InitWindow(); 
        return 0;
    }
    /*
    else if (uMsg == WM_DESTROY)
    {

    }
    */
    else if (uMsg == WM_CLOSE)
    {
        //退出所有功能测试
        m_pVideoView->RemoveRenderInfo();
        stopAllTestSetting();

    }
    else if (uMsg == WM_NCACTIVATE)
    {
        if (!::IsIconic(*this)) return (wParam == 0) ? TRUE : FALSE;
    }
    else if (uMsg == WM_TIMER)
    {
        SYSTEMTIME sys;
        GetLocalTime(&sys);
        char tmp[64] = {NULL};
        sprintf(tmp, "%4d-%02d-%02d %02d:%02d:%02d ms:%03d", sys.wYear, sys.wMonth, sys.wDay,
                sys.wHour, sys.wMinute, sys.wSecond, sys.wMilliseconds);
        std::string time(tmp);
        TRTCCloudCore::GetInstance()->getTRTCCloud()->sendSEIMsg((uint8_t*)time.c_str(),
                                                                 time.size(),
                                                                 1);
    }
    else if (uMsg == WM_USER_CMD_DeviceChange)
    {
        TRTCDeviceType type = (TRTCDeviceType)wParam;
        TRTCDeviceState eventCode = (TRTCDeviceState)lParam;
        if (type == TRTCDeviceTypeCamera)
            UpdateCameraDevice();
        if (type == TRTCDeviceTypeMic)
            UpdateMicDevice();
        if (type == TRTCDeviceTypeSpeaker)
            UpdateSpeakerDevice();
    }
    else if (uMsg == WM_USER_CMD_TestComplete)
    {
        int level = (int)wParam;
        if (m_pProgressTestNetwork)
            m_pProgressTestNetwork->SetValue(level);
    }
    else if (uMsg == WM_USER_CMD_MemberVolumeCallback)
    {
        std::string * userId = (std::string *)wParam;
        uint32_t volume = lParam;
        //onUserEnter(*userId);         
        delete userId; 
        userId = nullptr;

    }
    else if (uMsg == WM_USER_CMD_MicVolumeCallback)
    {
        uint32_t volume = wParam;
        if (m_pProgressTestMic && m_bStartTestMic)
        {
            m_pProgressTestMic->SetValue(volume);
        }
    }
    else if (uMsg == WM_USER_CMD_SpeakerVolumeCallback)
    {
        uint32_t volume = wParam;
        if (m_pProgressTestSpeaker && m_bStartTestSpeaker)
        {
            m_pProgressTestSpeaker->SetValue(volume);
        }
    }
    else if(uMsg == WM_USER_CMD_OnRecordError)
    {
        std::string * msg = (std::string *)wParam;
        uint32_t nRet = lParam;
        DoRecordError(nRet, *msg);   
        delete msg;
        msg = nullptr;

    }
    else if(uMsg == WM_USER_CMD_OnRecordComplete)
    {
        std::string * msg = (std::string *)wParam;
        DoRecordComplete(*msg);
        delete msg;
        msg = nullptr;

    }
    else if(uMsg == WM_USER_CMD_OnRecordProgress)
    {
        uint32_t duration = wParam;
        uint32_t filesize = lParam;
        DoRecordProgress(duration, filesize);
    }
    LRESULT lRes = 0;
    if (m_pmUI.MessageHandler(uMsg, wParam, lParam, lRes))
        return lRes;
    return CWindowWnd::HandleMessage(uMsg, wParam, lParam);

}
