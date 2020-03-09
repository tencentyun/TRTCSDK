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

int TRTCSettingViewController::m_ref = 0;
std::vector<TRTCSettingViewControllerNotify*> TRTCSettingViewController::vecNotifyList;

TRTCSettingViewController::TRTCSettingViewController(SettingTagEnum tagType, HWND parentHwnd)
{
    m_eTagType = tagType;
    m_parentHwnd = parentHwnd;
    TRTCSettingViewController::addRef();

    TRTCCloudCore::GetInstance()->getTRTCCloud()->addCallback(this);

    m_audioEffectParam1 = new TRTCAudioEffectParam(0, NULL);
    m_audioEffectParam2 = new TRTCAudioEffectParam(0, NULL);
    m_audioEffectParam3 = new TRTCAudioEffectParam(0, NULL);

    m_audioEffectParam1->publish = false;
    m_audioEffectParam2->publish = false;
    m_audioEffectParam3->publish = false;

    CDataCenter::GetInstance()->m_speakerVolume = TRTCCloudCore::GetInstance()->getTRTCCloud()->getCurrentSpeakerVolume();
}

TRTCSettingViewController::~TRTCSettingViewController()
{
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
    m_pVideoView->RemoveEngine(TRTCCloudCore::GetInstance()->getTRTCCloud());
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
    NotifyAudioEffectTab(msg);
    NotifyMixTab(msg);
    CDuiString name = msg.pSender->GetName();
    if (msg.sType == _T("selectchanged"))  
    {
        CTabLayoutUI* pTabSwitch = static_cast<CTabLayoutUI*>(m_pmUI.FindControl(_T("tab_switch")));
        if (name.CompareNoCase(_T("normal_tab")) == 0) pTabSwitch->SelectItem(0);
        if (name.CompareNoCase(_T("video_tab")) == 0) pTabSwitch->SelectItem(1);
        if (name.CompareNoCase(_T("audio_tab")) == 0) pTabSwitch->SelectItem(2);
        if (name.CompareNoCase(_T("audio_effect_tab")) == 0) pTabSwitch->SelectItem(3);
        if (name.CompareNoCase(_T("other_tab")) == 0) pTabSwitch->SelectItem(4);
        if (name.CompareNoCase(_T("mix_tab")) == 0) pTabSwitch->SelectItem(5);
        if (name.CompareNoCase(_T("record_tab")) == 0) pTabSwitch->SelectItem(6);
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
            CGroupBoxUI* normalContainer = static_cast<CGroupBoxUI*>(m_pmUI.FindControl(_T("normal_groupbox")));
            if (normalContainer)
                normalContainer->SetFixedHeight(344);
            CHorizontalLayoutUI* roleContainer = static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("choose_role")));
            if (roleContainer)
                roleContainer->SetVisible(true);
            CDataCenter::GetInstance()->m_sceneParams = TRTCAppSceneLIVE;
            //直播场景和视频通话场景默认码率值不一样。
            updateVideoBitrateUi();
        }
        if (name.CompareNoCase(_T("scene_call")) == 0) {
            CGroupBoxUI* normalContainer = static_cast<CGroupBoxUI*>(m_pmUI.FindControl(_T("normal_groupbox")));
            if (normalContainer)
                normalContainer->SetFixedHeight(304);
            CHorizontalLayoutUI* roleContainer = static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("choose_role")));
            if (roleContainer)
                roleContainer->SetVisible(false);
            CDataCenter::GetInstance()->m_sceneParams = TRTCAppSceneVideoCall;
            CDataCenter::GetInstance()->m_roleType = TRTCRoleAnchor;
            if (CDataCenter::GetInstance()->m_localInfo._bEnterRoom)
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->switchRole(CDataCenter::GetInstance()->m_roleType);
            }
            //直播场景和视频通话场景默认码率值不一样。
            updateVideoBitrateUi();
        }
        if(name.CompareNoCase(_T("audio_scene_live")) == 0) {
            CGroupBoxUI* normalContainer = static_cast<CGroupBoxUI*>(m_pmUI.FindControl(_T("normal_groupbox")));
            if(normalContainer)
                normalContainer->SetFixedHeight(344);
            CHorizontalLayoutUI* roleContainer = static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("choose_role")));
            if(roleContainer)
                roleContainer->SetVisible(true);
            CDataCenter::GetInstance()->m_sceneParams = TRTCAppSceneVoiceChatRoom;
            //直播场景和视频通话场景默认码率值不一样。
            updateVideoBitrateUi();
        }
        if(name.CompareNoCase(_T("audio_scene_call")) == 0) {
            CGroupBoxUI* normalContainer = static_cast<CGroupBoxUI*>(m_pmUI.FindControl(_T("normal_groupbox")));
            if(normalContainer)
                normalContainer->SetFixedHeight(304);
            CHorizontalLayoutUI* roleContainer = static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("choose_role")));
            if(roleContainer)
                roleContainer->SetVisible(false);
            CDataCenter::GetInstance()->m_sceneParams = TRTCAppSceneAudioCall;
            CDataCenter::GetInstance()->m_roleType = TRTCRoleAnchor;
            if(CDataCenter::GetInstance()->m_localInfo._bEnterRoom)
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->switchRole(CDataCenter::GetInstance()->m_roleType);
            }
            //直播场景和视频通话场景默认码率值不一样。
            updateVideoBitrateUi();
        }
        if (name.CompareNoCase(_T("role_anchor")) == 0) {
            CDataCenter::GetInstance()->m_roleType = TRTCRoleAnchor;
            if (CDataCenter::GetInstance()->m_localInfo._bEnterRoom)
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->switchRole(CDataCenter::GetInstance()->m_roleType);
                ::PostMessage(m_parentHwnd, WM_USER_CMD_RoleChange, (WPARAM)CDataCenter::GetInstance()->m_roleType, 0);
            }
        }
        if (name.CompareNoCase(_T("role_audience")) == 0) {
            CDataCenter::GetInstance()->m_roleType = TRTCRoleAudience;
            if (CDataCenter::GetInstance()->m_localInfo._bEnterRoom)
            {
                //需要关闭所有的流：
                TRTCCloudCore::GetInstance()->getTRTCCloud()->switchRole(CDataCenter::GetInstance()->m_roleType);
                ::PostMessage(m_parentHwnd, WM_USER_CMD_RoleChange, (WPARAM)CDataCenter::GetInstance()->m_roleType, 0);
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
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setCurrentSpeakerVolume(volume * AUDIO_DEVICE_VOLUME_TICKET / 100);
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
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setCurrentMicDeviceVolume(volume * AUDIO_DEVICE_VOLUME_TICKET / 100);
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
            if(TRTCCloudCore::GetInstance()->getTRTCCloud())
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setAudioCaptureVolume(volume * AUDIO_DEVICE_VOLUME_TICKET / 100);
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
            if(TRTCCloudCore::GetInstance()->getTRTCCloud())
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setAudioPlayoutVolume(volume * AUDIO_DEVICE_VOLUME_TICKET / 100);
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

            updateVideoBitrateUi();

            TRTCCloudCore::GetInstance()->getTRTCCloud()->setVideoEncoderParam(CDataCenter::GetInstance()->m_videoEncParams);
        }
        else if (name.CompareNoCase(_T("combo_camera")) == 0) 
        {
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
                    TRTCCloudCore::GetInstance()->getTRTCCloud()->startSpeakerDeviceTest(Wide2UTF8(testFileMp3).c_str());
                    //TRTCCloudCore::GetInstance()->getTRTCCloud()->playBGM(Wide2UTF8(testFileMp3).c_str());
                }

                m_bStartTestSpeaker = true;
            }
            else
            {
                pTestSender->SetText(_T("扬声器测试"));
                if (TRTCCloudCore::GetInstance()->getTRTCCloud())
                {
                    TRTCCloudCore::GetInstance()->getTRTCCloud()->stopSpeakerDeviceTest();
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
                    TRTCCloudCore::GetInstance()->getTRTCCloud()->startMicDeviceTest(200);

                int ret = TRTCCloudCore::GetInstance()->getTRTCCloud()->getCurrentMicDeviceVolume();
                pTestSender->SetText(_T("停止"));
                m_bStartTestMic = true;
            }
            else
            {
                if (TRTCCloudCore::GetInstance()->getTRTCCloud())
                    TRTCCloudCore::GetInstance()->getTRTCCloud()->stopMicDeviceTest();

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
                    std::string api = format("{\"api\":\"muteRemoteAudioInSpeaker\",\"params\":{\"userID\":\"%s\", \"enable\":%d}}", it.first.c_str(), true);
                    TRTCCloudCore::GetInstance()->getTRTCCloud()->callExperimentalAPI(api.c_str());
                }
                m_bMuteRemotesAudio = true;
            }
            else
            {
                RemoteUserInfoList& userMap = CDataCenter::GetInstance()->m_remoteUser;
                for (auto it : userMap)
                {
                    std::string api = format("{\"api\":\"muteRemoteAudioInSpeaker\",\"params\":{\"userID\":\"%s\", \"enable\":%d}}", it.first.c_str(), false);
                    TRTCCloudCore::GetInstance()->getTRTCCloud()->callExperimentalAPI(api.c_str());
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
    }
}

void TRTCSettingViewController::NotifyAudioEffectTab(TNotifyUI & msg)
{
    if (msg.sType == _T("click"))
    {
        if (msg.pSender->GetName() == _T("check_btn_effect1_start"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam1);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/clap.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.volume = 100;
                effect.effectId = 1;
                effect.path = testFileAcc.c_str();
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
            else
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopAudioEffect(effect.effectId);
                effect.effectId = 0;
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect1_loop"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam1);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.loopCount = 1000;
            else
                effect.loopCount = 1;
            if (effect.effectId > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/clap.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = testFileAcc.c_str();
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect1_publish"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam1);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.publish = true;
            else
                effect.publish = false;
            if (effect.effectId > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/clap.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = testFileAcc.c_str();
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
        }

        if (msg.pSender->GetName() == _T("check_btn_effect2_start"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam2);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/gift_sent.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = testFileAcc.c_str();
                effect.volume = 100;
                effect.effectId = 2;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
            else
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopAudioEffect(effect.effectId);
                effect.effectId = 0;
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect2_loop"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam2);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.loopCount = 1000;
            else
                effect.loopCount = 1;
            if (effect.effectId > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/gift_sent.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = testFileAcc.c_str();
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect2_publish"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam2);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.publish = true;
            else
                effect.publish = false;
            if (effect.effectId > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/gift_sent.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = testFileAcc.c_str();
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
        }

        if (msg.pSender->GetName() == _T("check_btn_effect3_start"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam3);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/on_mic.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = testFileAcc.c_str();
                effect.volume = 100;
                effect.effectId = 3;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
            else
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopAudioEffect(effect.effectId);
                effect.effectId = 0;
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect3_loop"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam3);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.loopCount = 1000;
            else
                effect.loopCount = 1;
            if (effect.effectId > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/on_mic.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = testFileAcc.c_str();
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
        }
        else if (msg.pSender->GetName() == _T("check_btn_effect3_publish"))
        {
            TRTCAudioEffectParam& effect = (*m_audioEffectParam3);
            COptionUI* pTestAudioEffect = static_cast<COptionUI*>(msg.pSender);
            if (pTestAudioEffect->IsSelected() == false) //事件值是反的
                effect.publish = true;
            else
                effect.publish = false;
            if (effect.effectId > 0)
            {
                std::wstring testFileMp = TrtcUtil::getAppDirectory() + L"trtcres/on_mic.aac"; //gift_sent on_mic
                std::string testFileAcc = Wide2UTF8(testFileMp);
                effect.path = testFileAcc.c_str();
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playAudioEffect(&effect);
            }
        }

        if (msg.pSender->GetName() == _T("check_btn_aec"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) //事件值是反的
            {
                CDataCenter::GetInstance()->m_bEnableAec = true;
                std::string api = format("{\"api\":\"enableAudioAEC\",\"params\":{\"enable\":%d}}", CDataCenter::GetInstance()->m_bEnableAec);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->callExperimentalAPI(api.c_str());

            }
            else
            {
                CDataCenter::GetInstance()->m_bEnableAec = false;
                std::string api = format("{\"api\":\"enableAudioAEC\",\"params\":{\"enable\":%d}}", CDataCenter::GetInstance()->m_bEnableAec);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->callExperimentalAPI(api.c_str());
            }
        }
        if (msg.pSender->GetName() == _T("check_btn_ans"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) //事件值是反的
            {
                CDataCenter::GetInstance()->m_bEnableAns = true;
                std::string api = format("{\"api\":\"enableAudioANS\",\"params\":{\"enable\":%d}}", CDataCenter::GetInstance()->m_bEnableAns);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->callExperimentalAPI(api.c_str());

            }
            else
            {
                CDataCenter::GetInstance()->m_bEnableAns = false;
                std::string api = format("{\"api\":\"enableAudioANS\",\"params\":{\"enable\":%d}}", CDataCenter::GetInstance()->m_bEnableAns);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->callExperimentalAPI(api.c_str());
            }
        }
        if (msg.pSender->GetName() == _T("check_btn_agc"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if (pOpenSender->IsSelected() == false) //事件值是反的
            {
                CDataCenter::GetInstance()->m_bEnableAgc = true;
                std::string api = format("{\"api\":\"enableAudioAGC\",\"params\":{\"enable\":%d}}", CDataCenter::GetInstance()->m_bEnableAgc);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->callExperimentalAPI(api.c_str());

            }
            else
            {
                CDataCenter::GetInstance()->m_bEnableAgc = false;
                std::string api = format("{\"api\":\"enableAudioAGC\",\"params\":{\"enable\":%d}}", CDataCenter::GetInstance()->m_bEnableAgc);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->callExperimentalAPI(api.c_str());
            }
        }
        if(msg.pSender->GetName() == _T("check_btn_testbgm"))
        {
            COptionUI* pTestSender = static_cast<COptionUI*>(msg.pSender);
            if(pTestSender->IsSelected() == false) //事件值是反的
            {
                std::wstring testFileMp3 = TrtcUtil::getAppDirectory() + L"trtcres/testspeak.mp3";
                TRTCCloudCore::GetInstance()->getTRTCCloud()->playBGM(Wide2UTF8(testFileMp3).c_str());

                m_bStartTestBGM = true;
            } else
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopBGM();
                m_bStartTestBGM = false;
                m_nBGMPublishVolume = 100;
                m_nBGMPlayoutVolume = 100;
                {
                    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_publish_volume")));
                    if(pSlider)  pSlider->SetValue(m_nBGMPublishVolume);
                    CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_bgm_publish_volume")));
                    if(pLabelValue)
                    {
                        CDuiString sText;
                        sText.Format(_T("%d%%"),m_nBGMPublishVolume);
                        pLabelValue->SetText(sText);
                    }
                }
                {
                    CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_playout_volume")));
                    if(pSlider)  pSlider->SetValue(m_nBGMPlayoutVolume);
                    CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_bgm_playout_volume")));
                    if(pLabelValue)
                    {
                        CDuiString sText;
                        sText.Format(_T("%d%%"),m_nBGMPlayoutVolume);
                        pLabelValue->SetText(sText);
                    }
                }
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setBGMPlayoutVolume(m_nBGMPlayoutVolume);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setBGMPublishVolume(m_nBGMPlayoutVolume);
            }
        }
        if(msg.pSender->GetName() == _T("check_system_audio_mix"))
        {
            #ifndef _WIN64
            COptionUI* pTestSystemVoice = static_cast<COptionUI*>(msg.pSender);
            if(pTestSystemVoice->IsSelected() == false) //事件值是反的
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->startSystemAudioLoopback();
                m_bStartSystemVoice = true;
            } else
            {
                TRTCCloudCore::GetInstance()->getTRTCCloud()->stopSystemAudioLoopback();
                m_bStartSystemVoice = false;
            }
            #endif
        }
    }
    else if (msg.sType == _T("valuechanged"))
    {
        if(msg.pSender->GetName() == _T("slider_bgm_playout_volume"))
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_bgm_playout_volume")));
            CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_bgm_playout_volume")));
            CDuiString sText;
            int volume = pSlider->GetValue();
            sText.Format(_T("%d%%"),volume);
            pLabelValue->SetText(sText);
            CDataCenter::GetInstance()->m_audioCaptureVolume = volume;
            if(TRTCCloudCore::GetInstance()->getTRTCCloud())
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setBGMPlayoutVolume(volume * AUDIO_DEVICE_VOLUME_TICKET / 100);
        }
        if(msg.pSender->GetName() == _T("slider_bgm_publish_volume"))
        {
            CProgressUI* pSlider = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("slider_bgm_publish_volume")));
            CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_bgm_publish_volume")));
            CDuiString sText;
            int volume = pSlider->GetValue();
            sText.Format(_T("%d%%"),volume);
            pLabelValue->SetText(sText);
            CDataCenter::GetInstance()->m_audioCaptureVolume = volume;
            if(TRTCCloudCore::GetInstance()->getTRTCCloud())
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setBGMPublishVolume(volume * AUDIO_DEVICE_VOLUME_TICKET / 100);
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
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setLocalViewMirror(CDataCenter::GetInstance()->m_bLocalVideoMirror);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setVideoEncoderMirror(CDataCenter::GetInstance()->m_bLocalVideoMirror);
            }
            else
            {
                CDataCenter::GetInstance()->m_bLocalVideoMirror = false;
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setLocalViewMirror(CDataCenter::GetInstance()->m_bLocalVideoMirror);
                TRTCCloudCore::GetInstance()->getTRTCCloud()->setVideoEncoderMirror(CDataCenter::GetInstance()->m_bLocalVideoMirror);
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

            if(CDataCenter::GetInstance()->m_strCustomStreamId.empty() == false)
            {
                strStreamId = CDataCenter::GetInstance()->m_strCustomStreamId;
            }

            RemoteUserInfoList& remoteMetaInfo = CDataCenter::GetInstance()->m_remoteUser;
            LocalUserInfo& localMetaInfo = CDataCenter::GetInstance()->getLocalUserInfo();
            if(remoteMetaInfo.size() > 0 || localMetaInfo.publish_sub_video || (remoteMetaInfo.size() == 0 && CDataCenter::GetInstance()->m_bOpenAudioAndCanvasMix))
            {
                if (CDataCenter::GetInstance()->m_strMixStreamId.empty() == false)
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
        else if(msg.pSender->GetName() == _T("check_audio_canvas_mix"))
        {
            COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
            if(pOpenSender->IsSelected() == false) //事件值是反的
            {
                CDataCenter::GetInstance()->m_bOpenAudioAndCanvasMix = true;
            } else
            {
                CDataCenter::GetInstance()->m_bOpenAudioAndCanvasMix = false;
            }
            TRTCCloudCore::GetInstance()->updateMixTranCodeInfo();
        }
        else if(msg.pSender->GetName() == _T("btn_update_custom_streamid"))
        {
            CEditUI* pEdit = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_custom_streamid")));
            if(pEdit != nullptr)
            {
                std::wstring strId = pEdit->GetText();
                if(!(strId.compare(L"") == 0))
                {
                    if(isCustomUploaderStreamIdValid(Wide2UTF8(strId)) == false)
                    {
                        MessageBox(0,L"valid stream id, must in a~z A~Z 0~9",L"error update",0);
                        return;
                    }
                    std::string streamid = Wide2UTF8(strId);
                    if (CDataCenter::GetInstance()->m_strCustomStreamId != streamid)
                    {
                        CDataCenter::GetInstance()->m_strCustomStreamId = streamid;
                        TRTCCloudCore::GetInstance()->getTRTCCloud()->startPublishing(CDataCenter::GetInstance()->m_strCustomStreamId.c_str(),TRTCVideoStreamTypeBig);
                        TRTCCloudCore::GetInstance()->updateMixTranCodeInfo();
                    }
                }
                else
                {
                    if (CDataCenter::GetInstance()->m_strCustomStreamId != "")
                    {
                        CDataCenter::GetInstance()->m_strCustomStreamId = "";
                        TRTCCloudCore::GetInstance()->getTRTCCloud()->setMixTranscodingConfig(NULL);
                        TRTCCloudCore::GetInstance()->getTRTCCloud()->stopPublishing();

                    }
                }
            }
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

void TRTCSettingViewController::InitWindow()
{
    TRTCCloudCore::GetInstance()->regSDKMsgObserver(WM_USER_CMD_DeviceChange, GetHWND());
    SetIcon(IDR_MAINFRAME);

    InitNormalTab();
    InitAudioTab();
	InitAudioEffectTab();
    InitVideoTab();
    InitOtherTab();
    InitMixTab();

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
            pAudioSceneLive->Selected(true);
        if(appScene == TRTCAppSceneVoiceChatRoom)
            pAudioSceneCall->Selected(true);
    }

    TRTCRoleType roleType = CDataCenter::GetInstance()->m_roleType;
    COptionUI* pRoleAnchor = static_cast<COptionUI*>(m_pmUI.FindControl(_T("role_anchor")));
    COptionUI* pRoleAudience = static_cast<COptionUI*>(m_pmUI.FindControl(_T("role_audience")));
    if (pRoleAnchor && pRoleAudience)
    {
        pRoleAnchor->Selected(false);
        pRoleAudience->Selected(false);
        if (roleType == TRTCRoleAnchor)
            pRoleAnchor->Selected(true);
        if (roleType == TRTCRoleAudience)
            pRoleAudience->Selected(true);
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
        pAutoMode->Selected(true);
        pAudioMode->Selected(false);
        pVideoMode->Selected(false);
        pManualMode->Selected(false);
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
}

void TRTCSettingViewController::InitAudioTab()
{
    UpdateMicDevice();
    UpdateSpeakerDevice();
    {
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
        if (TRTCCloudCore::GetInstance()->getTRTCCloud())
            TRTCCloudCore::GetInstance()->getTRTCCloud()->setCurrentSpeakerVolume(nVolume * AUDIO_DEVICE_VOLUME_TICKET / 100);
    }
    {
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
        if (TRTCCloudCore::GetInstance()->getTRTCCloud())
            TRTCCloudCore::GetInstance()->getTRTCCloud()->setCurrentMicDeviceVolume(nVolume * AUDIO_DEVICE_VOLUME_TICKET / 100);
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
    m_pProgressTestNetwork = static_cast<CProgressUI*>(m_pmUI.FindControl(_T("progress_testnetwork")));;
}

void TRTCSettingViewController::InitAudioEffectTab()
{
    //音频 3A 开关
    COptionUI* pCheckAec = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_btn_aec")));
    COptionUI* pCheckAns = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_btn_ans")));
    COptionUI* pCheckAgc = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_btn_agc")));

    if (pCheckAec && pCheckAns && pCheckAgc)
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
    }

    {
        uint32_t nVolume = CDataCenter::GetInstance()->m_micVolume;
        nVolume = nVolume * 100 / AUDIO_DEVICE_VOLUME_TICKET;
        CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_playout_volume")));
        if(pSlider)
            pSlider->SetValue(nVolume);
        CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_bgm_playout_volume")));
        if(pLabelValue)
        {
            CDuiString sText;
            sText.Format(_T("%d%%"),nVolume);
            pLabelValue->SetText(sText);
        }
    }

    {
        uint32_t nVolume = CDataCenter::GetInstance()->m_audioCaptureVolume;
        nVolume = nVolume * 100 / AUDIO_DEVICE_VOLUME_TICKET;
        CSliderUI* pSlider = static_cast<CSliderUI*>(m_pmUI.FindControl(_T("slider_bgm_publish_volume")));
        if(pSlider)
            pSlider->SetValue(nVolume);
        CLabelUI* pLabelValue = static_cast<CLabelUI*>(m_pmUI.FindControl(_T("lable_bgm_publish_volume")));
        if(pLabelValue)
        {
            CDuiString sText;
            sText.Format(_T("%d%%"),nVolume);
            pLabelValue->SetText(sText);
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

#ifdef _WIN64
    COptionUI* pSystemAudioMix = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_system_audio_mix")));
    if (pSystemAudioMix)
    {
        pSystemAudioMix->SetEnabled(false);
    }
#endif // ! _WIN64

    CEditUI* pEditIp = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_ip")));
    if (pEditIp != nullptr)
        pEditIp->SetText(UTF82Wide(CDataCenter::GetInstance()->m_strSocks5ProxyIp).c_str());

    char string_num[32];
    itoa(CDataCenter::GetInstance()->m_strSocks5ProxyPort, string_num, 10);
    std::string strPort = string_num;
    CEditUI* pEditPort = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_port")));
    if (pEditPort != nullptr)
        pEditPort->SetText(UTF82Wide(strPort).c_str());
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
        COptionUI* pMixTab = static_cast<COptionUI*>(m_pmUI.FindControl(_T("mix_tab")));
        if(pMixTab)
            pMixTab->SetVisible(true);

        COptionUI* pMixCanvasVideo = static_cast<COptionUI*>(m_pmUI.FindControl(_T("check_audio_canvas_mix")));
        if(pMixCanvasVideo)
        {
            pMixCanvasVideo->Selected(false);
            if(CDataCenter::GetInstance()->m_bOpenAudioAndCanvasMix)
                pMixCanvasVideo->Selected(true);
        }

        CEditUI* pEditMixStreamId = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_mix_streamid")));
        if(pEditMixStreamId != nullptr)
        pEditMixStreamId->SetText(UTF82Wide(CDataCenter::GetInstance()->m_strMixStreamId).c_str());

        CHorizontalLayoutUI* pLayoutCustomStreamId = static_cast<CHorizontalLayoutUI*>(m_pmUI.FindControl(_T("layout_custom_streamid")));
        if(pLayoutCustomStreamId)
        {
            pLayoutCustomStreamId->SetVisible(true);
        }

        CEditUI* pEditCustomStreamId = static_cast<CEditUI*>(m_pmUI.FindControl(_T("edit_custom_streamid")));
        if(pEditCustomStreamId != nullptr)
            pEditCustomStreamId->SetText(UTF82Wide(CDataCenter::GetInstance()->m_strCustomStreamId).c_str());
    }
}

void TRTCSettingViewController::UpdateCameraDevice()
{
    //初始化视频设备 
    CComboUI* pDeviceCombo = static_cast<CComboUI*>(m_pmUI.FindControl(_T("combo_camera")));
    if (pDeviceCombo)
    {
        pDeviceCombo->RemoveAll();
        std::vector<TRTCCloudCore::MediaDeviceInfo> vecDeviceList = TRTCCloudCore::GetInstance()->getCameraDevice();
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
        if (selectIndex >= 0)
        {
            pDeviceCombo->SelectItem(selectIndex);
            
            LocalUserInfo info = CDataCenter::GetInstance()->getLocalUserInfo();
            if (m_pVideoView->IsViewOccupy() == false)
            {
                m_pVideoView->RegEngine(info._userId, TRTCVideoStreamType::TRTCVideoStreamTypeBig, TRTCCloudCore::GetInstance()->getTRTCCloud(), true);
                m_pVideoView->SetRenderMode(TXLiveAvVideoView::EVideoRenderModeFit);
            }

            m_pVideoView->SetPause(false);
            TRTCCloudCore::GetInstance()->startPreview(true);
            m_bStartLocalPreview = true;
        }
        else
        {
            TRTCCloudCore::GetInstance()->stopPreview(true);
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
        if (selectIndex >= 0)
            pDeviceCombo->SelectItem(selectIndex);
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
        if (selectIndex >= 0)
            pDeviceCombo->SelectItem(selectIndex);
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
        TRTCCloudCore::GetInstance()->stopPreview(true);
    if (m_bStartTestMic)
        TRTCCloudCore::GetInstance()->getTRTCCloud()->stopMicDeviceTest();
    if (m_bStartTestSpeaker)
        TRTCCloudCore::GetInstance()->getTRTCCloud()->stopSpeakerDeviceTest();
    if (m_bStartTestNetwork)
        TRTCCloudCore::GetInstance()->getTRTCCloud()->stopSpeedTest();
    if (m_bStartTestBGM)
        TRTCCloudCore::GetInstance()->getTRTCCloud()->stopBGM();
#ifndef _WIN64
    if (m_bStartSystemVoice)
        TRTCCloudCore::GetInstance()->getTRTCCloud()->stopSystemAudioLoopback();
#endif
    TRTCCloudCore::GetInstance()->getTRTCCloud()->stopAllAudioEffects();

    if (m_bMuteRemotesAudio)
    {
        RemoteUserInfoList& userMap = CDataCenter::GetInstance()->m_remoteUser;
        for (auto it : userMap)
        {
            std::string api = format("{\"api\":\"muteRemoteAudioInSpeaker\",\"params\":{\"userID\":\"%s\", \"enable\":%d}}", it.first.c_str(), false);
            TRTCCloudCore::GetInstance()->getTRTCCloud()->callExperimentalAPI(api.c_str());
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
        m_pVideoView->RemoveEngine(TRTCCloudCore::GetInstance()->getTRTCCloud());
        stopAllTestSetting();

    }
    else if (uMsg == WM_NCACTIVATE)
    {
        if (!::IsIconic(*this)) return (wParam == 0) ? TRUE : FALSE;
    }
    /*
    else if (uMsg == WM_TIMER)    
    {
        BOOL bRet = OnTimer(uMsg, wParam, lParam); 
        if (bRet)
            return bRet;
    }
    */
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
    LRESULT lRes = 0;
    if (m_pmUI.MessageHandler(uMsg, wParam, lParam, lRes))
        return lRes;
    return CWindowWnd::HandleMessage(uMsg, wParam, lParam);

}
