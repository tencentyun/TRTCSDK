#include "StdAfx.h"
#include "DataCenter.h"
#include "ConfigMgr.h"
#include "TrtcUtil.h"
#include "util/Base.h"
#include <mutex>
#include "util/md5.h"
#include <strstream>
#include <iostream>
#include <iomanip>
#include "GenerateTestUserSig.h"
//////////////////////////////////////////////////////////////////////////CDataCenter

static std::shared_ptr<CDataCenter> s_pInstance;
static std::mutex engine_mex;
CRITICAL_SECTION g_DataCS;
std::shared_ptr<CDataCenter> CDataCenter::GetInstance()
{
    if (s_pInstance == NULL) {
        engine_mex.lock();
        if (s_pInstance == NULL)
        {
            s_pInstance = std::make_shared<CDataCenter>();
        }
        engine_mex.unlock();
    }
    return s_pInstance;
}
CDataCenter::CDataCenter()
{
    ::InitializeCriticalSection(&g_DataCS);//初始化关键代码段对象
    m_pConfigMgr = new CConfigMgr;

    VideoResBitrateTable& info1 = m_videoConfigMap[TRTCVideoResolution_120_120];
    info1.init(150, 40, 200);
    VideoResBitrateTable& info2 = m_videoConfigMap[TRTCVideoResolution_160_160];
    info2.init(250, 40, 300);
    VideoResBitrateTable& info3 = m_videoConfigMap[TRTCVideoResolution_270_270];
    info3.init(300, 100, 400);
    VideoResBitrateTable& info4 = m_videoConfigMap[TRTCVideoResolution_480_480];
    info4.init(500, 200, 1000);
    VideoResBitrateTable& info5 = m_videoConfigMap[TRTCVideoResolution_160_120];
    info5.init(150, 40, 200);
    VideoResBitrateTable& info6 = m_videoConfigMap[TRTCVideoResolution_240_180];
    info6.init(200, 80, 300);
    VideoResBitrateTable& info7 = m_videoConfigMap[TRTCVideoResolution_280_210];
    info7.init(200, 100, 300);
    VideoResBitrateTable& info8 = m_videoConfigMap[TRTCVideoResolution_320_240];
    info8.init(400, 100, 400);
    VideoResBitrateTable& info9 = m_videoConfigMap[TRTCVideoResolution_400_300];
    info9.init(400, 200, 800);
    VideoResBitrateTable& info10 = m_videoConfigMap[TRTCVideoResolution_480_360];
    info10.init(500, 200, 800);
    VideoResBitrateTable& info11 = m_videoConfigMap[TRTCVideoResolution_640_480];
    info11.init(700, 250, 1000);
    VideoResBitrateTable& info12 = m_videoConfigMap[TRTCVideoResolution_960_720];
    info12.init(1000, 200, 1600);
    VideoResBitrateTable& info13 = m_videoConfigMap[TRTCVideoResolution_320_180];
    info13.init(300, 80, 300);
    VideoResBitrateTable& info14 = m_videoConfigMap[TRTCVideoResolution_480_270];
    info14.init(400, 200, 800);
    VideoResBitrateTable& info15 = m_videoConfigMap[TRTCVideoResolution_640_360];
    info15.init(600, 200, 1000);
    VideoResBitrateTable& info16 = m_videoConfigMap[TRTCVideoResolution_960_540];
    info16.init(900, 400, 1600);
    VideoResBitrateTable& info17 = m_videoConfigMap[TRTCVideoResolution_1280_720];
    info17.init(1250, 500, 2000);     
    VideoResBitrateTable& info18 = m_videoConfigMap[TRTCVideoResolution_1920_1080];
    info18.init(2000, 1000, 3000);

    m_sceneParams = TRTCAppSceneVideoCall;
}

CDataCenter::~CDataCenter()
{
    UnInit();
    ::DeleteCriticalSection(&g_DataCS);//删除关键代码段对象
    if (m_pConfigMgr)
    {
        delete  m_pConfigMgr;
        m_pConfigMgr = nullptr;
    }
}

void CDataCenter::CleanRoomInfo()
{
    m_remoteUser.clear();
    m_vecPKUserList.clear();
    m_localInfo._bEnterRoom = false;
    m_localInfo.publish_audio = false;
    m_localInfo.publish_main_video = false;
    m_localInfo.publish_sub_video = false;
    m_bCustomAudioCapture = false;
    m_bCustomVideoCapture = false;
    m_strCustomStreamId = "";
    m_strMixStreamId = "";
}

void CDataCenter::UnInit()
{
    WriteEngineConfig();
}

LocalUserInfo & CDataCenter::getLocalUserInfo()
{
    return m_localInfo;
}

CDataCenter::VideoResBitrateTable CDataCenter::getVideoConfigInfo(int resolution)
{
    VideoResBitrateTable info;
    if (m_videoConfigMap.find(resolution) != m_videoConfigMap.end())
        info = m_videoConfigMap[resolution];

    if (m_sceneParams == TRTCAppSceneLIVE)
        info.resetLiveSence();
    return info;
}

void CDataCenter::Init()
{
    if (m_pConfigMgr->GetSize() == 0)
    {
        m_localInfo._userId = TrtcUtil::genRandomNumString(8);
        return;
    }
    std::wstring id;
    bool bIdRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_USER_ID, id);
    if (id.compare(L"") == 0 || !bIdRet)
        m_localInfo._userId = TrtcUtil::genRandomNumString(8);
    else
        m_localInfo._userId = Wide2UTF8(id);

    m_localInfo._roomId = std::stoi(TrtcUtil::genRandomNumString(6));

    //音视频参数配置
    std::wstring strParam;
    bool bRet = false;


    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_AUDIO_QUALITY, strParam);
    if (bRet) {
        audio_quality_ = (TRTCAudioQuality)_wtoi(strParam.c_str());
    }
        
    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_VIDEO_RESOLUTION, strParam);
    if (bRet)
        m_videoEncParams.videoResolution = (TRTCVideoResolution)_wtoi(strParam.c_str());
    else
        m_videoEncParams.videoResolution = TRTCVideoResolution_640_360;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_VIDEO_FPS, strParam);
    if (bRet)
        m_videoEncParams.videoFps = _wtoi(strParam.c_str());
    else
        m_videoEncParams.videoFps = 15;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_VIDEO_QUALITY, strParam);
    if (bRet)
        m_qosParams.preference = (TRTCVideoQosPreference)_wtoi(strParam.c_str());
    else
        m_qosParams.preference = TRTCVideoQosPreferenceClear;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_VIDEO_QUALITY_CONTROL, strParam);
    if (bRet)
        m_qosParams.controlMode = (TRTCQosControlMode)_wtoi(strParam.c_str());
    else
        m_qosParams.controlMode = TRTCQosControlModeServer;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_VIDEO_APP_SCENE, strParam);
    if (bRet)
        m_sceneParams = (TRTCAppScene)_wtoi(strParam.c_str());
    else
        m_sceneParams = TRTCAppSceneVideoCall;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_ROLE_TYPE, strParam);
    if (bRet)
        m_roleType = (TRTCRoleType)_wtoi(strParam.c_str());
    else
        m_roleType = TRTCRoleAnchor;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_BEAUTY_OPEN, strParam);
    if (bRet)
        m_beautyConfig._bOpenBeauty = _wtoi(strParam.c_str());
    else
        m_beautyConfig._bOpenBeauty = false;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_BEAUTY_STYLE, strParam);
    if (bRet)
        m_beautyConfig._beautyStyle = (TRTCBeautyStyle)_wtoi(strParam.c_str());
    else
        m_beautyConfig._beautyStyle = TRTCBeautyStyleSmooth;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_BEAUTY_VALUE, strParam);
    if (bRet)
        m_beautyConfig._beautyValue = _wtoi(strParam.c_str());
    else
        m_beautyConfig._beautyValue = 0;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_WHITE_VALUE, strParam);
    if (bRet)
        m_beautyConfig._whiteValue = _wtoi(strParam.c_str());
    else
        m_beautyConfig._whiteValue = 0;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_RUDDINESS_VALUE, strParam);
    if (bRet)
        m_beautyConfig._ruddinessValue = _wtoi(strParam.c_str());
    else
        m_beautyConfig._ruddinessValue = 0;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_SET_PUSH_SMALLVIDEO, strParam);
    if (bRet)
        m_bPushSmallVideo = _wtoi(strParam.c_str());
    else
        m_bPushSmallVideo = false;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_SET_PLAY_SMALLVIDEO, strParam);
    if (bRet)
        m_bPlaySmallVideo = _wtoi(strParam.c_str());
    else
        m_bPlaySmallVideo = false;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_SET_NETENV_STYLE, strParam);
    if (bRet)
        m_nLinkTestServer = _wtoi(strParam.c_str());
    else
        m_nLinkTestServer = 0;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_VIDEO_RES_MODE, strParam);
    if (bRet)
        m_videoEncParams.resMode = (TRTCVideoResolutionMode)_wtoi(strParam.c_str());
    else
        m_videoEncParams.resMode = TRTCVideoResolutionModeLandscape;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_REMOTE_VIDEO_MIRROR, strParam);
    if (bRet)
        m_bRemoteVideoMirror = _wtoi(strParam.c_str());
    else
        m_bRemoteVideoMirror = false;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_SHOW_AUDIO_VOLUME, strParam);
    if (bRet)
        m_bShowAudioVolume = _wtoi(strParam.c_str());
    else
        m_bShowAudioVolume = false;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_CLOUD_MIX_TRANSCODING, strParam);
    if (bRet)
        m_bCDNMixTranscoding = _wtoi(strParam.c_str());
    else
        m_bCDNMixTranscoding = false;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_PUBLISH_SCREEN_IN_BIG_STREAM, strParam);
    if (bRet)
        m_bPublishScreenInBigStream = _wtoi(strParam.c_str());
    else
        m_bPublishScreenInBigStream = false;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_MIX_TEMP_ID, strParam);
    if (bRet)
        m_mixTemplateID = (TRTCAppScene)_wtoi(strParam.c_str());
    else
        m_mixTemplateID = TRTCTranscodingConfigMode_Manual;

    /*
    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_MIC_VOLUME, strParam);
    if (bRet)
        m_micVolume = _wtoi(strParam.c_str());
    else
        m_micVolume = 100;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_SPEAKER_VOLUME, strParam);
    if (bRet)
        m_speakerVolume = _wtoi(strParam.c_str());
    else
        m_speakerVolume = 100;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_ENABLE_AEC, strParam);
    if (bRet)
        m_bEnableAec = _wtoi(strParam.c_str());
    else
        m_bEnableAec = 0;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_ENABLE_ANS, strParam);
    if (bRet)
        m_bEnableAns = _wtoi(strParam.c_str());
    else
        m_bEnableAns = 0;

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_ENABLE_AGC, strParam);
    if (bRet)
        m_bEnableAgc = _wtoi(strParam.c_str());
    else
        m_bEnableAgc = 0;
    */

    std::wstring ip;
    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_SOCKS5_PROXY_IP, ip);
    if (ip.compare(L"") != 0 && bRet)
        m_strSocks5ProxyIp = Wide2UTF8(ip);

    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_SOCKS5_PROXY_PORT, strParam);
    if (bRet)
        m_strSocks5ProxyPort = _wtoi(strParam.c_str());
    else
        m_strSocks5ProxyPort = 0;


    bRet = m_pConfigMgr->GetValue(INI_ROOT_KEY, INI_KEY_LOCAL_VIDEO_MIRROR, strParam);
    if (bRet)
        m_bLocalVideoMirror = _wtoi(strParam.c_str());
    else
        m_bLocalVideoMirror = false;
}

void CDataCenter::WriteEngineConfig()
{
    //User Info
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_USER_ID, UTF82Wide(m_localInfo._userId));
    //m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_USER_ID, UTF82Wide(""));
    //设备选项

    //音视频参数配置
    DuiLib::CDuiString strFormat;
    strFormat.Format(L"%d", audio_quality_);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_AUDIO_QUALITY, strFormat.GetData());
    strFormat.Format(L"%d", m_videoEncParams.videoBitrate);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_VIDEO_BITRATE, strFormat.GetData());
    strFormat.Format(L"%d", m_videoEncParams.videoResolution);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_VIDEO_RESOLUTION, strFormat.GetData());
    strFormat.Format(L"%d", m_videoEncParams.videoFps);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_VIDEO_FPS, strFormat.GetData());
    strFormat.Format(L"%d", m_qosParams.preference);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_VIDEO_QUALITY, strFormat.GetData());
    strFormat.Format(L"%d", m_qosParams.controlMode);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_VIDEO_QUALITY_CONTROL, strFormat.GetData());
    strFormat.Format(L"%d", m_sceneParams);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_VIDEO_APP_SCENE, strFormat.GetData());
    strFormat.Format(L"%d", m_roleType);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_ROLE_TYPE, strFormat.GetData());

    strFormat.Format(L"%d", m_beautyConfig._bOpenBeauty);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_BEAUTY_OPEN, strFormat.GetData());
    strFormat.Format(L"%d", m_beautyConfig._beautyStyle);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_BEAUTY_STYLE, strFormat.GetData());
    strFormat.Format(L"%d", m_beautyConfig._beautyValue);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_BEAUTY_VALUE, strFormat.GetData());
    strFormat.Format(L"%d", m_beautyConfig._whiteValue);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_WHITE_VALUE, strFormat.GetData());
    strFormat.Format(L"%d", m_beautyConfig._ruddinessValue);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_RUDDINESS_VALUE, strFormat.GetData());

    strFormat.Format(L"%d", m_bPushSmallVideo);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_SET_PUSH_SMALLVIDEO, strFormat.GetData());
    strFormat.Format(L"%d", m_bPlaySmallVideo);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_SET_PLAY_SMALLVIDEO, strFormat.GetData());
    strFormat.Format(L"%d", m_nLinkTestServer);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_SET_NETENV_STYLE, strFormat.GetData());

    strFormat.Format(L"%d", m_bLocalVideoMirror);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_LOCAL_VIDEO_MIRROR, strFormat.GetData());
    strFormat.Format(L"%d", m_bRemoteVideoMirror);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_REMOTE_VIDEO_MIRROR, strFormat.GetData());
    strFormat.Format(L"%d", m_bShowAudioVolume);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_SHOW_AUDIO_VOLUME, strFormat.GetData());
    strFormat.Format(L"%d", m_bCDNMixTranscoding);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_CLOUD_MIX_TRANSCODING, strFormat.GetData());
    strFormat.Format(L"%d", m_mixTemplateID);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_MIX_TEMP_ID, strFormat.GetData());
    strFormat.Format(L"%d", m_bPublishScreenInBigStream);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_PUBLISH_SCREEN_IN_BIG_STREAM, strFormat.GetData());
    /*
    strFormat.Format(L"%d", m_micVolume);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_MIC_VOLUME, strFormat.GetData());
    strFormat.Format(L"%d", m_speakerVolume);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_SPEAKER_VOLUME, strFormat.GetData());

    strFormat.Format(L"%d", m_bEnableAec);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_ENABLE_AEC, strFormat.GetData());
    strFormat.Format(L"%d", m_bEnableAns);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_ENABLE_ANS, strFormat.GetData());
    strFormat.Format(L"%d", m_bEnableAgc);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_ENABLE_AGC, strFormat.GetData());
    */

    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_SOCKS5_PROXY_IP, UTF82Wide(m_strSocks5ProxyIp));
    strFormat.Format(L"%d", m_strSocks5ProxyPort);
    m_pConfigMgr->SetValue(INI_ROOT_KEY, INI_KEY_SOCKS5_PROXY_PORT, strFormat.GetData());


}

CDataCenter::BeautyConfig & CDataCenter::GetBeautyConfig()
{
    // TODO: 在此处插入 return 语句
    return m_beautyConfig;
}

RemoteUserInfo* CDataCenter::FindRemoteUser(std::string userId)
{
    std::map<std::string, RemoteUserInfo>::iterator iter;
    iter = m_remoteUser.find(userId);
    if(iter != m_remoteUser.end())
    {
        return &iter->second;
    }
    return nullptr;
}

std::string CDataCenter::GetCdnUrl(const std::string & strUserId)
{
    if (m_localInfo._bEnterRoom == false)
    {
        return "";
    }
    std::string  strMixStreamId = format("%d_%d_%s_main", GenerateTestUserSig::SDKAPPID, m_localInfo._roomId, strUserId.c_str());

    std::string strUrl = format("http://%d.liveplay.myqcloud.com/live/%s.flv", GenerateTestUserSig::BIZID, strMixStreamId.c_str());

    return strUrl;
}

void CDataCenter::addRemoteUser(std::string userId, bool bClear)
{
    std::map<std::string,RemoteUserInfo>::iterator iter;
    iter = m_remoteUser.find(userId);
    if(iter != m_remoteUser.end())
    {
        if(bClear)
            m_remoteUser.erase(iter);
        else
            return;
    }

    RemoteUserInfo info;
    info.user_id = userId;
    m_remoteUser.insert(std::pair<std::string,RemoteUserInfo>(userId, info));
}

void CDataCenter::removeRemoteUser(std::string userId)
{
    std::map<std::string, RemoteUserInfo>::iterator iter;//定义一个迭代指针iter
    iter = m_remoteUser.find(userId);
    if(iter != m_remoteUser.end())
    {
         m_remoteUser.erase(iter);
    }
}

bool CDataCenter::getAudioAvaliable(std::string userId)
{
    if (userId.compare(m_localInfo._userId) == 0)
    {
        return m_localInfo.publish_audio;
    }
    else 
    {
        auto iter = m_remoteUser.find(userId);
        if (iter != m_remoteUser.end())
        {
            return (iter->second.available_audio && iter->second.subscribe_audio);
        }
    }
    return false;
}

bool CDataCenter::getVideoAvaliable(std::string userId, TRTCVideoStreamType type)
{
    if (userId.compare(m_localInfo._userId) == 0)
    {
        return m_localInfo.publish_main_video;
    }
    else
    {
        auto iter = m_remoteUser.find(userId);
        if (iter != m_remoteUser.end())
        {
            if (type == TRTCVideoStreamTypeSub)
            {
                return (iter->second.available_sub_video && iter->second.subscribe_sub_video);
            }
            else
            {
                return (iter->second.available_main_video && iter->second.subscribe_main_video);
            }
        }
    }
    return false;
}

TRTCRenderParams CDataCenter::getLocalRenderParams() {
    TRTCRenderParams param;
    if (m_bLocalVideoMirror) {
        param.mirrorType = TRTCVideoMirrorType_Enable;
    } else {
        param.mirrorType = TRTCVideoMirrorType_Disable;
    }
    return param;
}

TRTCVideoStreamType CDataCenter::getRemoteVideoStreamType() {
    TRTCVideoStreamType type = TRTCVideoStreamTypeBig;
    if (m_bPlaySmallVideo) {
        type = TRTCVideoStreamTypeSmall;
    }
    return type;
}
