#include "StdAfx.h"
#include "TRTCCloudCore.h"
#include "UserMassegeIdDefine.h"
#include "util/log.h"
#include "util/Base.h"
#include "json/json.h"
#include <mutex>
#include <iostream>
#include <fstream>
#include <cstdint>
#include "GenerateTestUserSig.h"
#include "utils/TrtcUtil.h"
#include <assert.h>

TRTCCloudCore* TRTCCloudCore::m_instance = nullptr;
static std::mutex engine_mex;
TRTCCloudCore* TRTCCloudCore::GetInstance()
{
    if (m_instance == NULL) {
        engine_mex.lock();
        if (m_instance == NULL)
        {
            m_instance = new TRTCCloudCore();
        }
        engine_mex.unlock();
    }
    return m_instance;
}
void TRTCCloudCore::Destory()
{
    engine_mex.lock();
    if (m_instance )
    {
        delete m_instance;
        m_instance = nullptr;
    }
    engine_mex.unlock();
}
TRTCCloudCore::TRTCCloudCore()
{
    trtc_module_ = nullptr;
    if (trtc_module_ != nullptr) return;

    HMODULE hmodule = NULL;
    GetModuleHandleEx(
        GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
        L"TRTCModule", &hmodule);

    char module_path[MAX_PATH] = { 0 };
    ::GetModuleFileNameA(hmodule, module_path, _countof(module_path));

    std::string module_dir = GetPathNoExt(module_path);
    if (module_dir.length() == 0) {
        LINFO(L"TRTC GetModule Path Error");
        return;
    }

    std::string module_full_path = module_dir + "liteav.dll";

    trtc_module_ =
        ::LoadLibraryExA(module_full_path.c_str(), NULL, LOAD_WITH_ALTERED_SEARCH_PATH);

    if (trtc_module_ == NULL) {
        DWORD dw_ret = GetLastError();
        LINFO(L"TRTC Load liteav.dll Fail ErrorCode[0x%04X]", dw_ret);
        return;
    }
    else{

        getTRTCShareInstance_ = (GetTRTCShareInstance)::GetProcAddress(trtc_module_, "getTRTCShareInstance");

        destroyTRTCShareInstance_ = (DestroyTRTCShareInstance)::GetProcAddress(trtc_module_, "destroyTRTCShareInstance");

        m_pCloud = getTRTCShareInstance();
    }}

TRTCCloudCore::~TRTCCloudCore()
{
    destroyTRTCShareInstance_();
    m_pCloud = nullptr;
    getTRTCShareInstance_ = nullptr;
    destroyTRTCShareInstance_ = nullptr;

    if (trtc_module_)
        FreeLibrary(trtc_module_);
}

void TRTCCloudCore::Init()
{
    //检查默认选择设备
    m_localUserId = CDataCenter::GetInstance()->getLocalUserID(); 

    m_pCloud->addCallback(this);
    m_pCloud->setLogCallback(this);
    m_bPreUninit = false;
    //std::string logPath = Wide2UTF8(L"D:/中文/log/");
   //m_pCloud->setLogDirPath(logPath.c_str());
   // m_pCloud->setConsoleEnabled(true);
    m_pCloud->setAudioFrameCallback(this);
}

void TRTCCloudCore::Uninit()
{
    m_bStartLocalPreview = false;
    m_bStartCameraTest = false;

    removeAllSDKMsgObserver();
    m_pCloud->removeCallback(this);
    m_pCloud->setLogCallback(nullptr);
}

void TRTCCloudCore::PreUninit()
{
    m_bPreUninit = true;
    if (CDataCenter::GetInstance()->m_bStartSystemVoice)
    {
        CDataCenter::GetInstance()->m_bStartSystemVoice = false;
        TRTCCloudCore::GetInstance()->getTRTCCloud()->stopSystemAudioLoopback();
    }

    stopLocalRecord();
    destroyLocalRecordShareInstance();
    stopCloudMixStream();
    stopCustomCaptureVideo();
    stopCustomCaptureAudio();
    m_pCloud->stopAllRemoteView();
    m_pCloud->stopLocalPreview();
    m_pCloud->muteLocalVideo(true);
    m_pCloud->muteLocalAudio(true);

}

ITRTCCloud * TRTCCloudCore::getTRTCCloud()
{
    return m_pCloud;
}

void TRTCCloudCore::onError(TXLiteAVError errCode, const char* errMsg, void* arg)
{
    LINFO(L"onError errorCode[%d], errorInfo[%s]\n", errCode, UTF82Wide(errMsg).c_str());
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_Error && itr.second != nullptr)
        {
            std::string * str = new std::string();
            if (errMsg != nullptr)
                *str = errMsg;
            ::PostMessage(itr.second, WM_USER_CMD_Error, (WPARAM)errCode, (LPARAM)str);
        }
    }
}

void TRTCCloudCore::onWarning(TXLiteAVWarning warningCode, const char* warningMsg, void* arg)
{
    LINFO(L"onWarning errorCode[%d], errorInfo[%s]\n", warningCode, UTF82Wide(warningMsg).c_str());
}

void TRTCCloudCore::onEnterRoom(int result)
{
    LINFO(L"onEnterRoom elapsed[%d]\n", result);

    std::unique_lock<std::mutex> lck(m_mutexMsgFilter);
    int tresult = result;
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_EnterRoom && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_EnterRoom, 0, (LPARAM)tresult);
        }
    }
}

void TRTCCloudCore::onExitRoom(int reason)
{
    LINFO(L"onExitRoom reason[%d]\n", reason);

    std::unique_lock<std::mutex> lck(m_mutexMsgFilter);
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_ExitRoom && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_ExitRoom, 0, reason);
        }
    }
}

void TRTCCloudCore::onRemoteUserEnterRoom(const char * userId)
{
    LINFO(L"onMemberEnter userId[%s]\n", UTF82Wide(userId).c_str());
    std::unique_lock<std::mutex> lck(m_mutexMsgFilter);
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_MemberEnter && itr.second != nullptr)
        {
            std::string * str = new std::string(userId);
            ::PostMessage(itr.second, WM_USER_CMD_MemberEnter, (WPARAM)str, 0);
        }
    }
}

void TRTCCloudCore::onRemoteUserLeaveRoom(const char* userId, int reason)
{
    LINFO(L"onMemberExit userId[%s]\n", UTF82Wide(userId).c_str());
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_MemberExit && itr.second != nullptr)
        {
            std::string * str = new std::string(userId);
            ::PostMessage(itr.second, WM_USER_CMD_MemberExit, (WPARAM)str, 0);
        }
    }
}

void TRTCCloudCore::onUserAudioAvailable(const char * userId, bool available)
{
    LINFO(L"onUserAudioAvailable userId[%s] available[%d]\n", UTF82Wide(userId).c_str(), available);
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_AuidoAvailable && itr.second != nullptr)
        {
            std::string * str = new std::string(userId);
            ::PostMessage(itr.second, WM_USER_CMD_AuidoAvailable, (WPARAM)str, available);
        }
    }
}

void TRTCCloudCore::onFirstAudioFrame(const char * userId)
{
    LINFO(L"onFirstAudioFrame userId[%s] \n", UTF82Wide(userId).c_str());
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_OnFirstAudioFrame && itr.second != nullptr)
        {
            std::string * str = new std::string(userId);
            ::PostMessage(itr.second, WM_USER_CMD_OnFirstAudioFrame, (WPARAM)str, NULL);
        }
    }
}

void TRTCCloudCore::onUserVoiceVolume(TRTCVolumeInfo* userVolumes, uint32_t userVolumesCount, uint32_t totalVolume)
{
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_UserVoiceVolume && itr.second != nullptr)
        {
            for (int i = 0; i < userVolumesCount; i++)
            {
                TRTCVolumeInfo volume = userVolumes[i];
                std::string * str = new std::string(volume.userId);
                if (str->compare("") == 0)
                {
                    *str = CDataCenter::GetInstance()->getLocalUserID();
                }
                //LINFO(L"onUserVoiceVolume userId[%d], volume[%d]\n", UTF82Wide(*str).c_str(), volume.volume);
                ::PostMessage(itr.second, WM_USER_CMD_UserVoiceVolume, (WPARAM)str, volume.volume);
            }
        }
    }
}

void TRTCCloudCore::onNetworkQuality(TRTCQualityInfo localQuality, TRTCQualityInfo* remoteQuality, uint32_t remoteQualityCount)
{
    //LINFO(L"onNetworkQuality userId[%s], txQuality[%d],  rxQuality[%d]\n", UTF82Wide(userId).c_str(), txQuality, rxQuality);
    // todo kamis

    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_NetworkQuality && itr.second != nullptr)
        {
            std::string * str = new std::string("");
            if (str->compare("") == 0)
                *str = CDataCenter::GetInstance()->getLocalUserID();
            ::PostMessage(itr.second, WM_USER_CMD_NetworkQuality, (WPARAM)str, (LPARAM)localQuality.quality);



            for (int i = 0; i < remoteQualityCount; i++)
            {
                TRTCQualityInfo info = remoteQuality[i];
                std::string * str = new std::string(info.userId);
                if (str->compare("") == 0)
                    *str = CDataCenter::GetInstance()->getLocalUserID();
                //LINFO(L"onUserVoiceVolume userId[%d], volume[%d]\n", UTF82Wide(*str).c_str(), volume.volume);
                ::PostMessage(itr.second, WM_USER_CMD_NetworkQuality, (WPARAM)str, (LPARAM)info.quality);
            }
        }
    }

}


void TRTCCloudCore::onUserSubStreamAvailable(const char * userId, bool available)
{
    LINFO(L"onUserSubStreamAvailable userId[%s] available[%d]\n", UTF82Wide(userId).c_str(), available);
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_SubVideoAvailable && itr.second != nullptr)
        {
            std::string * str = new std::string(userId);
            ::PostMessage(itr.second, WM_USER_CMD_SubVideoAvailable, (WPARAM)str, available);
        }
    }
}

void TRTCCloudCore::onUserVideoAvailable(const char * userId, bool available)
{
    LINFO(L"onUserVideoAvailable userId[%s] available[%d]\n", UTF82Wide(userId).c_str(), available);
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_VideoAvailable && itr.second != nullptr)
        {
            std::string * str = new std::string(userId);
            ::PostMessage(itr.second, WM_USER_CMD_VideoAvailable, (WPARAM)str, available);
        }
    }
}

void TRTCCloudCore::onStatistics(const TRTCStatistics& statis)
{
    //更新云端混流的结构信息
    if (statis.localStatisticsArray != nullptr && statis.localStatisticsArraySize != 0)
    {
        for (int i = 0; i < statis.localStatisticsArraySize; i++)
        {
            if (statis.localStatisticsArray[i].streamType == TRTCVideoStreamTypeSub)
            {
                uint32_t width = statis.localStatisticsArray[i].width;
                uint32_t height = statis.localStatisticsArray[i].height;
                TRTCVideoStreamType streamType = statis.localStatisticsArray[i].streamType;
                std::unique_lock<std::mutex> lck(m_mutexMsgFilter);
                for (auto& itr : m_mapSDKMsgFilter)
                {
                    if (itr.first == WM_USER_CMD_FirstVideoFrame && itr.second != nullptr)
                    {
                        std::string * str = new std::string(m_localUserId);
                        //高14位width，低14位height，低4位streamType
                        uint32_t _width = width << 20;
                        uint32_t _height = height << 4;
                        uint32_t videoInfo = _width + _height + (int)streamType;
                        ::PostMessage(itr.second, WM_USER_CMD_FirstVideoFrame, (WPARAM)str, videoInfo);
                    }
                }

            }
        }
    }

}

void TRTCCloudCore::onScreenCaptureStarted()
{
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_ScreenStart && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_ScreenStart, 0, 0);
        }
    }
}

void TRTCCloudCore::onScreenCaptureStoped(int reason)
{
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_ScreenStart && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_ScreenEnd, (WPARAM)reason, 0);
        }
    }
}

void TRTCCloudCore::onVodPlayerStarted(uint64_t msLength)
{
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_VodStart && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_VodStart, 0, 0);
        }
    }
}

void TRTCCloudCore::onVodPlayerStoped(int reason)
{
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_VodEnd && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_VodEnd, 0, 0);
        }
    }
    if (m_pVodPlayer) {
        destroyTXVodPlayer(&m_pVodPlayer);
        m_pVodPlayer = nullptr;
    }
}

void TRTCCloudCore::onVodPlayerError(int error)
{
}

void TRTCCloudCore::onDeviceChange(const char* deviceId, TRTCDeviceType type, TRTCDeviceState state)
{
    LINFO(L"onDeviceChange type[%d], state[%d], deviceId[%s]\n", type, state, UTF82Wide(deviceId));
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_DeviceChange && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_DeviceChange, (WPARAM)type, (LPARAM)state);
        }
    }
}

void TRTCCloudCore::onLog(const char* log, TRTCLogLevel level, const char* module)
{
    //LINFO(L"onStatus userId[%s], paramCount[%d] \n", UTF82Wide(userId).c_str());

    int type = (int)level;
    if (type <= -1000 && type >-1999 && log && module)
    {
        int streamType = -1000 - type;
        for (auto& itr : m_mapSDKMsgFilter)
        {
            if (itr.first == WM_USER_CMD_Dashboard && itr.second != nullptr)
            {
                DashboardInfo* info = new DashboardInfo();
                info->userId.assign(module);
                info->buffer.assign(log);
                info->streamType = streamType;
                ::PostMessage(itr.second, WM_USER_CMD_Dashboard, 0, (LPARAM)info);
            }
        }
    }
    else if (type == -2000 && log && module)
    {
        int streamType = 0;
        for (auto& itr : m_mapSDKMsgFilter)
        {
            if (itr.first == WM_USER_CMD_SDKEventMsg && itr.second != nullptr)
            {
                DashboardInfo* info = new DashboardInfo();
                info->userId.assign(module);
                info->buffer.assign(log);
                info->streamType = streamType;
                ::PostMessage(itr.second, WM_USER_CMD_SDKEventMsg, 0, (LPARAM)info);
            }
        }
    }


}

void TRTCCloudCore::onConnectOtherRoom(const char* userId, TXLiteAVError errCode, const char * errMsg)
{
    LINFO(L"onConnectOtherRoom\n");
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_PKConnectStatus && itr.second != nullptr)
        {
            std::string * str = new std::string(errMsg);
            ::PostMessage(itr.second, WM_USER_CMD_PKConnectStatus, errCode, (LPARAM)str);
        }
    }
}

void TRTCCloudCore::onDisconnectOtherRoom(TXLiteAVError errCode, const char * errMsg)
{
    LINFO(L"onConnectOtherRoom\n");
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_PKDisConnectStatus && itr.second != nullptr)
        {
            std::string * str = new std::string(errMsg);
            ::PostMessage(itr.second, WM_USER_CMD_PKDisConnectStatus, errCode, (LPARAM)str);
        }
    }
}

void TRTCCloudCore::onCapturedAudioFrame(TRTCAudioFrame * frame)
{
    //LINFO(L"onCapturedAudioFrame\n");
}

void TRTCCloudCore::onPlayAudioFrame(TRTCAudioFrame * frame, const char * userId)
{
    
    //LINFO(L"onPlayAudioFrame\n");
    /*FILE* file = NULL;
    ::fopen_s(&file, "D:/subTest/playaudio_frame.pcm", "ab+");
    ::fwrite(frame->data, frame->length, 1, file);
    ::fflush(file);
    ::fclose(file);*/
    
}

void TRTCCloudCore::onMixedPlayAudioFrame(TRTCAudioFrame * frame)
{
   
    //LINFO(L"onMixedPlayAudioFrame\n");
    /*FILE* file = NULL;
    ::fopen_s(&file, "D:/subTest/mixplayaudio_frame.pcm", "ab+");
    ::fwrite(frame->data, frame->length, 1, file);
    ::fflush(file);
    ::fclose(file);

    if (m_pCloud)
    {
        m_pCloud->sendCustomAudioData(frame);
    }
    */
}

void TRTCCloudCore::onSetMixTranscodingConfig(int errCode, const char * errMsg)
{
    LINFO(L"onSetMixTranscodingConfig errCode[%d], errMsg[%s]\n", errCode, UTF82Wide(errMsg).c_str());
}

void TRTCCloudCore::onFirstVideoFrame(const char* userId, const TRTCVideoStreamType streamType, const int width, const int height)
{
    LINFO(L"onFirstVideoFrame userId[%s], width[%d], height[%d]\n", UTF82Wide(userId).c_str(), width, height);
    
    std::unique_lock<std::mutex> lck(m_mutexMsgFilter);
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_FirstVideoFrame && itr.second != nullptr)
        {
            std::string * str = new std::string(userId);
            //高14位width，低14位height，低4位streamType
            uint32_t _width = width << 20;
            uint32_t _height = height << 4;
            uint32_t videoInfo = _width + _height + (int)streamType;
            ::PostMessage(itr.second, WM_USER_CMD_FirstVideoFrame, (WPARAM)str, videoInfo);
        }
    }
}

void TRTCCloudCore::onSendFirstLocalVideoFrame(const TRTCVideoStreamType streamType)
{
    LINFO(L"onSendFirstLocalVideoFrame streamType[%d]\n", streamType);

    std::unique_lock<std::mutex> lck(m_mutexMsgFilter);
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_SendFirstLocalVideoFrame && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_SendFirstLocalVideoFrame, streamType, 0);
        }
    }
}

void TRTCCloudCore::onSendFirstLocalAudioFrame()
{
    LINFO(L"onSendFirstLocalAudioFrame\n");

    std::unique_lock<std::mutex> lck(m_mutexMsgFilter);
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_SendFirstLocalAudioFrame && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_SendFirstLocalAudioFrame, 0, 0);
        }
    }
}

void TRTCCloudCore::onAudioEffectFinished(int effectId, int code)
{
    LINFO(L"onAudioEffectFinished effectId[%d], code[%d]\n", effectId, code);
}

void TRTCCloudCore::onStartPublishing(int err,const char *errMsg)
{
    LINFO(L"onStartPublishing err[%d], errMsg[%s]\n", err, UTF82Wide(errMsg).c_str());
    /*
    if(err == 0)
    {

        std::unique_lock<std::mutex> lck(m_mutexMsgFilter);
        for(auto& itr : m_mapSDKMsgFilter)
        {
            if(itr.first == WM_USER_CMD_OnStartPublishinge && itr.second != nullptr)
            {
                ::PostMessage(itr.second,WM_USER_CMD_OnStartPublishinge,0,0);
            }
        }
    } else
    {
        CDataCenter::GetInstance()->m_strCustomStreamId = "";
    }
    */
}

void TRTCCloudCore::onStopPublishing(int err,const char * errMsg)
{
    LINFO(L"onStartPublishing err[%d], errMsg[%s]\n", err, UTF82Wide(errMsg).c_str());
    if(err == 0)
    {
        /*
         CDataCenter::GetInstance()->m_strCustomStreamId = "";
        std::unique_lock<std::mutex> lck(m_mutexMsgFilter);
        for(auto& itr : m_mapSDKMsgFilter)
        {
            if(itr.first == WM_USER_CMD_OnStopPublishing && itr.second != nullptr)
            {
                ::PostMessage(itr.second,WM_USER_CMD_OnStopPublishing,0,0);
            }
        }
        */
    }
}

void TRTCCloudCore::startLocalRecord(const LiteAVScreenCaptureSourceInfo & source,  const char * szRecordPath)
{
    RECT captureRect = CDataCenter::GetInstance()->m_recordCaptureRect;
    ITXLiteAVLocalRecord * pRecorder = getLocalRecordShareInstance();
    if (pRecorder)
    {
        pRecorder->setCallback(this);
        pRecorder->startLocalRecord(source, captureRect, szRecordPath);
    }
    CDataCenter::GetInstance()->m_bStartLocalRecord = true;
    CDataCenter::GetInstance()->m_bWaitStartRecordNotify = true;
}

void TRTCCloudCore::stopLocalRecord()
{
    CDataCenter::GetInstance()->m_bStartLocalRecord = false;
    ITXLiteAVLocalRecord * pRecorder = getLocalRecordShareInstance();
    if (pRecorder)
    {
        pRecorder->stopLocalRecord();
        pRecorder->setCallback(nullptr);
      
        CDataCenter::GetInstance()->m_recordCaptureRect = { 0 };
        CDataCenter::GetInstance()->m_recordCaptureSourceInfo.type = LiteAVScreenCaptureSourceTypeUnknown;
        CDataCenter::GetInstance()->m_bStartLocalRecord = false;
        CDataCenter::GetInstance()->m_bPauseLocalRecord = false;
        CDataCenter::GetInstance()->m_wstrRecordFile = L"";

    }
}

void TRTCCloudCore::pauseLocalRecord()
{
    ITXLiteAVLocalRecord * pRecorder = getLocalRecordShareInstance();
    if (pRecorder)
    {
        pRecorder->pauseLocalRecord();
    }
    CDataCenter::GetInstance()->m_bPauseLocalRecord = true;
}

void TRTCCloudCore::resumeLocalRecord()
{
    CDataCenter::GetInstance()->m_bPauseLocalRecord = false;
    ITXLiteAVLocalRecord * pRecorder = getLocalRecordShareInstance();
    if (pRecorder)
    {
        pRecorder->resumeLocalRecord();
    }
}

void TRTCCloudCore::onConnectionLost()
{
    LINFO(L"onConnectionLost\n");
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_ConnectionLost && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_ConnectionLost, 0, 0);
        }
    }
}

void TRTCCloudCore::onTryToReconnect()
{
    LINFO(L"onTryToReconnect\n");
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_TryToReconnect && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_TryToReconnect, 0, 0);
        }
    }
}

void TRTCCloudCore::onConnectionRecovery()
{
    LINFO(L"onConnectionRecovery\n");
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_ConnectionRecovery && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_ConnectionRecovery, 0, 0);
        }
    }
}

void TRTCCloudCore::onCameraDidReady()
{
    LINFO(L"onCameraDidReady\n");
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_OnCameraDidReady && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_OnCameraDidReady, 0, 0);
        }
    }
}

void TRTCCloudCore::onMicDidReady()
{
    LINFO(L"onMicDidReady\n");
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_OnMicDidReady && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_OnMicDidReady, 0, 0);
        }
    }
}

void TRTCCloudCore::onTestMicVolume(uint32_t volume)
{
    LINFO(L"onTestMicVolume\n");
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_OnTestMicVolume && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_OnTestMicVolume, 0, 0);
        }
    }
}

void TRTCCloudCore::onTestSpeakerVolume(uint32_t volume)
{
    LINFO(L"onTestSpeakerVolume\n");
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_OnTestSpeakerVolume && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_OnTestSpeakerVolume, 0, 0);
        }
    }
}
void TRTCCloudCore::OnRecordError(TXLiteAVLocalRecordError err, const char * msg)
{
    std::string * str = new std::string(msg);

    LINFO(L"OnRecordError\n");
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_OnRecordError && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_OnRecordError, (WPARAM)str, (LPARAM)err);
        }
    }
}

void TRTCCloudCore::OnRecordComplete(const char * path)
{
    LINFO(L"OnRecordComplete\n");
    std::string * str = new std::string(path);
  
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_OnRecordComplete && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_OnRecordComplete, (WPARAM)str, 0);
        }
    }
}

void TRTCCloudCore::OnRecordProgress(int duration, int fileSize, int width, int height)
{
    LINFO(L"OnRecordProgress\n");
   
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_OnRecordProgress && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_OnRecordProgress, (WPARAM)duration, (LPARAM)fileSize);
        }
    }
}
void TRTCCloudCore::regSDKMsgObserver(uint32_t msg, HWND hwnd)
{
    std::unique_lock<std::mutex> lck(m_mutexMsgFilter);
    bool bFind = false;
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == msg && itr.second == hwnd)
        {
            bFind = true;
            break;
        }
    }
    if (!bFind)
        m_mapSDKMsgFilter.insert(std::pair<uint32_t, HWND>(msg, hwnd));
}

void TRTCCloudCore::removeSDKMsgObserver(uint32_t msg, HWND hwnd)
{
    std::unique_lock<std::mutex> lck(m_mutexMsgFilter);
    std::map<uint32_t, HWND>::iterator itr = m_mapSDKMsgFilter.begin();
    for (; itr != m_mapSDKMsgFilter.end(); itr++)
    {
        if (itr->first == msg && itr->second == hwnd)
        {
            m_mapSDKMsgFilter.erase(itr);
            break;;
        }
    }
}

void TRTCCloudCore::removeSDKMsgObserverByHwnd(HWND hwnd)
{
    std::unique_lock<std::mutex> lck(m_mutexMsgFilter);

    std::map<uint32_t, HWND>::iterator itr;
    for (itr = m_mapSDKMsgFilter.begin(); itr != m_mapSDKMsgFilter.end(); )
    {

        if (itr->second == hwnd)
        {
            m_mapSDKMsgFilter.erase(itr++);
        }
        else
        {
            ++itr;
        }
    }
}

void TRTCCloudCore::removeAllSDKMsgObserver()
{
    std::unique_lock<std::mutex> lck(m_mutexMsgFilter);
    m_mapSDKMsgFilter.clear();
}

std::vector<TRTCCloudCore::MediaDeviceInfo>& TRTCCloudCore::getMicDevice()
{
    std::vector<MediaDeviceInfo> &vecDeviceList = m_vecMicDevice;
    std::wstring& select_device =  CDataCenter::GetInstance()->m_selectMic;
    vecDeviceList.clear();
    ITRTCDeviceInfo* activeMic = m_pCloud->getCurrentMicDevice();
    select_device = UTF82Wide(activeMic->getDeviceName());
    activeMic->release();

    bool find_select_device = false;
    ITRTCDeviceCollection * pDevice = m_pCloud->getMicDevicesList();
    for (int i = 0; i < pDevice->getCount(); i++) {
        std::wstring name = UTF82Wide(pDevice->getDeviceName(i));
        TRTCCloudCore::MediaDeviceInfo info;
        info._index = i;
        info._text = name;
        info._deviceId = UTF82Wide(pDevice->getDevicePID(i));
        info._type = L"mic";

        if (info._text.compare(select_device) == 0) {
            info._select = true;
            find_select_device = true;
        }
        vecDeviceList.push_back(info);
    }
    pDevice->release();
    pDevice = nullptr;

    
    if (vecDeviceList.size() <= 0) {
        select_device = L"";
    }
    return vecDeviceList;
}

std::vector<TRTCCloudCore::MediaDeviceInfo>& TRTCCloudCore::getSpeakDevice()
{
    std::vector<MediaDeviceInfo> &vecDeviceList = m_vecSpeakDevice;
    std::wstring& select_device =  CDataCenter::GetInstance()->m_selectSpeak;
    vecDeviceList.clear();

    ITRTCDeviceInfo* activeSpeaker = m_pCloud->getCurrentSpeakerDevice();
    select_device = UTF82Wide(activeSpeaker->getDeviceName());
    activeSpeaker->release();

    bool find_select_device = false;
    ITRTCDeviceCollection * pDevice = m_pCloud->getSpeakerDevicesList();
    for (int i = 0; i < pDevice->getCount(); i++) {
        std::wstring name = UTF82Wide(pDevice->getDeviceName(i));
        TRTCCloudCore::MediaDeviceInfo info;
        info._index = i;
        info._text = name;
        info._deviceId = UTF82Wide(pDevice->getDevicePID(i));
        info._type = L"speaker";
        if (info._text.compare(select_device) == 0) {
            info._select = true;
            find_select_device = true;
        }
        vecDeviceList.push_back(info);
    }
    pDevice->release();
    pDevice = nullptr;

    if (vecDeviceList.size() <= 0) {
        select_device = L"";
    }
    return vecDeviceList;
}

std::vector<TRTCCloudCore::MediaDeviceInfo>& TRTCCloudCore::getCameraDevice()
{
    std::vector<MediaDeviceInfo> &vecDeviceList = m_vecCameraDevice;
    std::wstring& select_device =  CDataCenter::GetInstance()->m_selectCamera;
    vecDeviceList.clear();

    ITRTCDeviceInfo* activeCamera = m_pCloud->getCurrentCameraDevice();
    select_device = UTF82Wide(activeCamera->getDeviceName());
    activeCamera->release();

    bool find_select_device = false;
    ITRTCDeviceCollection * pDevice = m_pCloud->getCameraDevicesList();
    for (int i = 0; i < pDevice->getCount(); i++)
    {
        std::wstring name = UTF82Wide(pDevice->getDeviceName(i));
        TRTCCloudCore::MediaDeviceInfo info;
        info._index = i;
        info._text = name;
        info._deviceId = UTF82Wide(pDevice->getDevicePID(i));
        info._type = L"camera";
        if (info._text.compare(select_device) == 0) {
            info._select = true;
            find_select_device = true;
        }
        vecDeviceList.push_back(info);
    }
    pDevice->release();
    pDevice = nullptr;

   if (vecDeviceList.size() <= 0) {
       select_device = L"";
   }

   return vecDeviceList;
}

ITRTCScreenCaptureSourceList* TRTCCloudCore::GetWndList()
{
    return m_pCloud->getScreenCaptureSources(SIZE{ 120, 70 }, SIZE{ 20,20 });
}

void TRTCCloudCore::selectMicDevice(std::wstring text)
{
    if (m_pCloud)
    {
        m_pCloud->setCurrentMicDevice(Wide2UTF8(text.c_str()).c_str());
        m_pCloud->setCurrentMicDeviceVolume(CDataCenter::GetInstance()->m_micVolume);
    }
}

void TRTCCloudCore::selectSpeakerDevice(std::wstring text)
{
    if (m_pCloud)
    {
        m_pCloud->setCurrentSpeakerDevice(Wide2UTF8(text.c_str()).c_str());
        m_pCloud->setCurrentSpeakerVolume(CDataCenter::GetInstance()->m_speakerVolume);
    }
}

void TRTCCloudCore::selectCameraDevice(std::wstring text)
{
    if (m_pCloud)
        m_pCloud->setCurrentCameraDevice(Wide2UTF8(text.c_str()).c_str());
}

void TRTCCloudCore::startPreview(bool bSetting)
{
    if (m_pCloud == nullptr)
        return;

    //防重入
    if (m_bStartCameraTest && bSetting)
        return; 
    if (m_bStartLocalPreview && !bSetting)
        return;

    //判断是否还需要打开设备


    if (bSetting)
    {
        if (!m_bStartLocalPreview)
            m_pCloud->startCameraDeviceTest(NULL);
        m_bStartCameraTest = true;
    }
    else
    {
        m_pCloud->startLocalPreview(NULL);
        m_bStartLocalPreview = true;
    }
}

void TRTCCloudCore::stopPreview(bool bSetting)
{
    if (bSetting)
    {
        if (!m_bStartLocalPreview)
            m_pCloud->stopCameraDeviceTest();
        m_bStartCameraTest = false;
    }
    else
    {
        if (m_bStartCameraTest)
        {
            //设置中心还在打开预览
            m_pCloud->stopLocalPreview();
            m_pCloud->startCameraDeviceTest(NULL);
        }
        else
        {
             m_pCloud->stopLocalPreview();
        }
        m_bStartLocalPreview = false;
    }

}

void TRTCCloudCore::startScreen(HWND rendHwnd)
{
    m_pCloud->startScreenCapture(rendHwnd);
}

void TRTCCloudCore::startScreenCapture(HWND rendHwnd, TRTCVideoStreamType streamType, TRTCVideoEncParam* params)
{
    m_pCloud->startScreenCapture(rendHwnd, streamType, params);
}

void TRTCCloudCore::stopScreen()
{
    m_pCloud->stopScreenCapture();
}

void TRTCCloudCore::startMedia(const char * mediaFile, HWND rendHwnd)
{
    stopMedia();
    if (m_pVodPlayer == nullptr)
    {
        m_pVodPlayer = createTXVodPlayer(mediaFile);
        m_pVodPlayer->setCallback(this);
    }
    //m_pCloud->setSubStreamDataSource(m_pVodPlayer, rendHwnd);
}

void TRTCCloudCore::stopMedia()
{
    //m_pCloud->setSubStreamDataSource(nullptr, nullptr);
}

void TRTCCloudCore::selectScreenCaptureTarget(const TRTCScreenCaptureSourceInfo &source, const RECT & captureRect)
{
    m_pCloud->selectScreenCaptureTarget(source, captureRect);
}

void TRTCCloudCore::showDashboardStyle(int logStyle)
{
    if (logStyle != 0)
        logStyle = 1001;
    m_pCloud->showDebugView(logStyle);
}

void TRTCCloudCore::connectOtherRoom(std::string userId, uint32_t roomId)
{
    std::string json = format("{\"roomId\":%d,\"userId\":\"%s\"}", roomId, userId.c_str());
    if (m_pCloud)
    {
        m_pCloud->connectOtherRoom(json.c_str());
    }
}

void TRTCCloudCore::startCloudMixStream()
{
    m_bStartCloudMixStream = true;

    updateMixTranCodeInfo();
}

void TRTCCloudCore::stopCloudMixStream()
{
    m_bStartCloudMixStream = false;
    if (m_pCloud)
    {
        m_pCloud->setMixTranscodingConfig(NULL);
    }
}


void TRTCCloudCore::updateMixTranCodeInfo()
{
    if (m_bStartCloudMixStream == false)
        return;

    int appId = GenerateTestUserSig::APPID;
    int bizId = GenerateTestUserSig::BIZID;

    if(appId == 0 || bizId == 0)
    {
        LERROR(L"混流功能不可使用，请在TRTCGetUserIDAndUserSig.h->TXCloudAccountInfo填写混流的账号信息\n");
        return;
    }

    RemoteUserInfoList& remoteMetaInfo = CDataCenter::GetInstance()->m_remoteUser;
    LocalUserInfo& localMetaInfo = CDataCenter::GetInstance()->getLocalUserInfo();

    bool bAudioSenceStyle = false;
    if(CDataCenter::GetInstance()->m_sceneParams ==  TRTCAppSceneAudioCall || CDataCenter::GetInstance()->m_sceneParams == TRTCAppSceneVoiceChatRoom)
        bAudioSenceStyle = true;

    //没有主流，直接停止混流。
    if(!localMetaInfo.publish_audio && !localMetaInfo.publish_main_video)
    {
        m_pCloud->setMixTranscodingConfig(NULL);
        return;
    }

    TRTCTranscodingConfig config;
    config.mode = (TRTCTranscodingConfigMode)CDataCenter::GetInstance()->m_mixTemplateID;
    config.appId = appId;
    config.bizId = bizId;

    if (config.mode > TRTCTranscodingConfigMode_Manual) {
        if (config.mode == TRTCTranscodingConfigMode_Template_PresetLayout) {
            setPresetLayoutConfig(config);
        }

        m_pCloud->setMixTranscodingConfig(&config);
        if (config.mixUsersArray) {
            delete[] config.mixUsersArray;
            config.mixUsersArray = nullptr;
        }
        return;
    }


    config.videoBitrate = 800;
    config.videoFramerate = 15;
    config.videoGOP = 1;
    config.audioSampleRate = 48000;
    config.audioBitrate = 64;
    config.audioChannels = 1;

    //没有远端流 A+画布->C / A+画布->A  / A->A  / A->C 的场景。
    if(remoteMetaInfo.size() == 0 && !localMetaInfo.publish_sub_video)
    {
        //A->A  / A->C 的场景
        int canvasWidth = 0,canvasHeight = 0;

        //A+画布->C / A+画布->A 
        if (CDataCenter::GetInstance()->m_bOpenAudioAndCanvasMix)
        {
            canvasWidth = 32;
            canvasHeight = 32;
        }
        //如果是音视频，一定要添加背景画布
        if(bAudioSenceStyle == false)
        {
            canvasWidth = 960;
            canvasHeight = 720;
        }

        int mixUsersArraySize = 1;

        // 更新混流信息
        config.videoWidth = canvasWidth;
        config.videoHeight = canvasHeight;
        config.mixUsersArraySize = mixUsersArraySize;
        TRTCMixUser* mixUsersArray = new TRTCMixUser[config.mixUsersArraySize];
        config.mixUsersArray = mixUsersArray;

        //本地主路信息
        int zOrder = 1,index = 0;
        mixUsersArray[index].roomId = nullptr;
        mixUsersArray[index].userId = localMetaInfo._userId.c_str();
        if(bAudioSenceStyle)
        {
            mixUsersArray[index].pureAudio = true;
        } 
        else
        {
            mixUsersArray[index].rect.left = 0;
            mixUsersArray[index].rect.top = 0;
            mixUsersArray[index].rect.right = canvasWidth;
            mixUsersArray[index].rect.bottom = canvasHeight;
        }
        mixUsersArray[index].streamType = TRTCVideoStreamTypeBig;
        mixUsersArray[index].zOrder = zOrder++;
        index++;
    }
    else  
    {
        //其他的A+B...的场景。
        for(auto& it : remoteMetaInfo)
        {
            std::vector<PKUserInfo>& pkList = CDataCenter::GetInstance()->m_vecPKUserList;
            std::vector<PKUserInfo>::iterator result;
            for(result = pkList.begin(); result != pkList.end(); result++)
            {
                if(result->_userId.compare(it.second.user_id.c_str()) == 0)
                {
                    it.second.room_id = result->_roomId;//std::to_string(result->_roomId);
                    break;
                }
            }
        }

        bool pureAudioRemoteUser = true; //如果远端有音视频，则混流是音视频的。
        for(auto& it : remoteMetaInfo)
        {
            if(it.second.subscribe_main_video || it.second.subscribe_sub_video)
                pureAudioRemoteUser = false;
        }
        int canvasWidth = 960,canvasHeight = 720;
        if(bAudioSenceStyle && pureAudioRemoteUser && !localMetaInfo.publish_sub_video)
        {
            canvasWidth = 0;
            canvasHeight = 0;
            if(CDataCenter::GetInstance()->m_bOpenAudioAndCanvasMix)
            {
                //纯音频+画布模式。
                canvasWidth = 32;
                canvasHeight = 32;
            }
        }

        int mixUsersArraySize = 1;
        if(localMetaInfo.publish_sub_video)
            mixUsersArraySize++;

        for(auto& it : remoteMetaInfo)
        {
            if(it.second.subscribe_audio || it.second.subscribe_main_video)
                mixUsersArraySize++;
            if(it.second.subscribe_sub_video)
                mixUsersArraySize++;
        }
        if(mixUsersArraySize > 16)
            mixUsersArraySize = 16;

        // 更新混流信息
        config.videoWidth = canvasWidth;
        config.videoHeight = canvasHeight;
        config.mixUsersArraySize = mixUsersArraySize;

        TRTCMixUser* mixUsersArray = new TRTCMixUser[config.mixUsersArraySize];
        config.mixUsersArray = mixUsersArray;

        //本地主路信息
        int zOrder = 1,index = 0;
        mixUsersArray[index].roomId = nullptr;
        mixUsersArray[index].userId = localMetaInfo._userId.c_str();
        if(bAudioSenceStyle)
        {
            mixUsersArray[index].pureAudio = true;
        } else
        {
            mixUsersArray[index].rect.left = 0;
            mixUsersArray[index].rect.top = 0;
            mixUsersArray[index].rect.right = canvasWidth;
            mixUsersArray[index].rect.bottom = canvasHeight;
        }
        mixUsersArray[index].streamType = TRTCVideoStreamTypeBig;
        mixUsersArray[index].zOrder = zOrder++;
        index++;

        //本地辅路信息
        if(localMetaInfo.publish_sub_video)
        {
            int left = 20,top = 40;
            int right = 240 + left,bottom = 240 + top;
            getMixVideoPos(1,left,top,right,bottom);

            mixUsersArray[index].roomId = nullptr;
            mixUsersArray[index].userId = localMetaInfo._userId.c_str();
            if (bAudioSenceStyle)
            {
                mixUsersArray[index].rect.left = 0;
                mixUsersArray[index].rect.top = 0;
                mixUsersArray[index].rect.right = canvasWidth;
                mixUsersArray[index].rect.bottom = canvasHeight;
            }
            else
            {
                mixUsersArray[index].rect.left = left;
                mixUsersArray[index].rect.top = top;
                mixUsersArray[index].rect.right = right;
                mixUsersArray[index].rect.bottom = bottom;
            }
            mixUsersArray[index].streamType = TRTCVideoStreamTypeSub;
            mixUsersArray[index].zOrder = zOrder++;
            index++;
        }

        int pos = index >= 2 ? 2 : 1; //第一个格子是辅路的信息。
        for(auto& it : remoteMetaInfo)
        {
            if(it.second.user_id == m_localUserId)
                continue;
            int left = 20,top = 40;
            int right = 240 + left,bottom = 240 + top;

            if(it.second.subscribe_main_video || it.second.subscribe_audio)
            {
                getMixVideoPos(pos,left,top,right,bottom);
                mixUsersArray[index].userId = it.second.user_id.c_str();
                if(it.second.room_id == 0)
                    mixUsersArray[index].roomId = nullptr;
                else
                {
                    it.second.str_room_id = std::to_string(it.second.room_id);
                    mixUsersArray[index].roomId = it.second.str_room_id.c_str();
                }
                mixUsersArray[index].streamType = TRTCVideoStreamTypeBig;
                mixUsersArray[index].zOrder = zOrder;
                if(it.second.subscribe_main_video == false)
                {
                    mixUsersArray[index].pureAudio = true;
                } else
                {
                    mixUsersArray[index].rect.left = left;
                    mixUsersArray[index].rect.top = top;
                    mixUsersArray[index].rect.right = right;
                    mixUsersArray[index].rect.bottom = bottom;
                    pos++;
                }
                zOrder++;
                index++;
            }

            if(it.second.subscribe_sub_video)
            {
                getMixVideoPos(pos,left,top,right,bottom);
                mixUsersArray[index].userId = it.second.user_id.c_str();
                if(it.second.room_id == 0)
                    mixUsersArray[index].roomId = nullptr;
                else
                {
                    it.second.str_room_id = std::to_string(it.second.room_id);
                    mixUsersArray[index].roomId = it.second.str_room_id.c_str();
                }
                mixUsersArray[index].streamType = TRTCVideoStreamTypeSub;
                mixUsersArray[index].zOrder = zOrder;
                mixUsersArray[index].rect.left = left;
                mixUsersArray[index].rect.top = top;
                mixUsersArray[index].rect.right = right;
                mixUsersArray[index].rect.bottom = bottom;
                pos++;
                zOrder++;
                index++;
            }
        }
    }
    config.backgroundColor = 0x696969;
    /*
    if (CDataCenter::GetInstance()->m_strMixStreamId.empty() == false)
    {
        config.streamId = CDataCenter::GetInstance()->m_strMixStreamId.c_str();
    }
    */

    if (m_pCloud)
    {
        m_pCloud->setMixTranscodingConfig(&config);
    }

    if (config.mixUsersArray) {
        delete[] config.mixUsersArray;
        config.mixUsersArray = nullptr;
    }
}

void TRTCCloudCore::getMixVideoPos(int index, int& left, int& top, int& right, int& bottom)
{
    left = 20,top = 40;
    if(index == 1)
    {
        left = 240 / 4 * 3 + 240 * 2;
        top = 240 / 3 * 1;
    }
    if(index == 2)
    {
        left = 240 / 4 * 3 + 240 * 2;
        top = 240 / 3 * 2 + 240 * 1;
    }
    if(index == 3)
    {
        left = 240 / 4 * 2 + 240 * 1;
        top = 240 / 3 * 1;
    }
    if(index == 4)
    {
        left = 240 / 4 * 2 + 240 * 1;
        top = 240 / 3 * 2 + 240 * 1;
    }
    if(index == 5)
    {
        left = 240 / 4 * 1;
        top = 240 / 3 * 1;
    }
    if(index == 6)
    {
        left = 240 / 4 * 1;
        top = 240 / 3 * 2 + 240 * 1;
    }
    right = 240 + left;
    bottom = 240 + top;
}

void TRTCCloudCore::startCustomCaptureAudio(std::wstring filePat, int samplerate, int channel)
{
    m_audioFilePath = filePat;
    _audio_file_length = 0;
    _audio_samplerate = samplerate;
    _audio_channel = channel;
    ifstream ifs(m_audioFilePath, ifstream::binary);
    if (!ifs)
        return;
    streampos pos = ifs.tellg();
    ifs.seekg(0, ios::end);
    _audio_file_length = ifs.tellg();
    ifs.close();

    m_bStartCustomCaptureAudio = true;
    m_pCloud->stopLocalAudio();
    if (m_pCloud)
        m_pCloud->enableCustomAudioCapture(true);

    if (custom_audio_thread_ == nullptr)
    {
        auto task2 = [=]() {
            while (m_bStartCustomCaptureAudio)
            {
                sendCustomAudioFrame();
                Sleep(20);
            }
        };
        custom_audio_thread_ = new std::thread(task2);
    }
}

void TRTCCloudCore::stopCustomCaptureAudio()
{
    m_audioFilePath = L"";
    m_bStartCustomCaptureAudio = false;
    _offset_audioread = 0;
    if (_audio_buffer != nullptr)
    {
        delete _audio_buffer;
        _audio_buffer = nullptr;
    }


    if (custom_audio_thread_)
    {
        custom_audio_thread_->join();
        delete custom_audio_thread_;
        custom_audio_thread_ = nullptr;
    }

    if (m_pCloud)
        m_pCloud->enableCustomAudioCapture(false);

    LocalUserInfo& _loginInfo = CDataCenter::GetInstance()->m_localInfo;
    if (_loginInfo.publish_audio && m_bPreUninit == false)
        m_pCloud->startLocalAudio();
}

void TRTCCloudCore::startCustomCaptureVideo(std::wstring filePat, int width, int height)
{
    m_videoFilePath = filePat;
    _video_file_length = 0;
    _video_width = width;
    _video_height = height;
    ifstream ifs(m_videoFilePath, ifstream::binary);
    if (!ifs)
        return;
    streampos pos = ifs.tellg();
    ifs.seekg(0, ios::end);
    _video_file_length = ifs.tellg();
    ifs.close();

    m_bStartCustomCaptureVideo = true;
    m_pCloud->stopLocalPreview();

    if (m_pCloud)
        m_pCloud->enableCustomVideoCapture(true);

    if (custom_video_thread_ == nullptr)
    {
        auto task2 = [=]() {
            while (m_bStartCustomCaptureVideo)
            {
                sendCustomVideoFrame();
                Sleep(66);
            }
        };
        custom_video_thread_ = new std::thread(task2);
    }
}

void TRTCCloudCore::stopCustomCaptureVideo()
{
    m_videoFilePath = L"";
    m_bStartCustomCaptureVideo = false;
    _offset_videoread = 0;
    if (_video_buffer != nullptr)
    {
        delete _video_buffer;
        _video_buffer = nullptr;
    }
    if (m_pCloud)
        m_pCloud->enableCustomVideoCapture(false);
    if (m_bStartLocalPreview && m_bPreUninit == false)
        m_pCloud->startLocalPreview(NULL);

    if (custom_video_thread_)
    {
        custom_video_thread_->join();
        delete custom_video_thread_;
        custom_video_thread_ = nullptr;
    }
}

void TRTCCloudCore::sendCustomAudioFrame()
{
    if (!m_bStartCustomCaptureAudio)
        return;
    if (m_pCloud)
    {
        ifstream ifs(m_audioFilePath, ifstream::binary);
        if (!ifs)
            return;

        uint32_t bufferSize = (960 * _audio_samplerate / 48000) * (_audio_channel * 16 / 8);
        if (_audio_buffer == nullptr)
            _audio_buffer = (char*)malloc(bufferSize + 2);

        if (_offset_audioread + bufferSize >_audio_file_length)
            _offset_audioread = 0;

        ifs.seekg(_offset_audioread);
        ifs.read(_audio_buffer, bufferSize);
        _offset_audioread += bufferSize;

        TRTCAudioFrame frame;
        frame.audioFormat = LiteAVAudioFrameFormatPCM;
        frame.length = bufferSize;
        frame.data = _audio_buffer;
        frame.sampleRate = _audio_samplerate;
        frame.channel = _audio_channel;
        m_pCloud->sendCustomAudioData(&frame);
    }
}

void TRTCCloudCore::sendCustomVideoFrame()
{
    if (!m_bStartCustomCaptureVideo)
        return;
    if (m_pCloud)
    {
        ifstream ifs(m_videoFilePath, ifstream::binary);
        if (!ifs)
            return;

        uint32_t bufferSize = _video_width * _video_height * 3 / 2;
        if (_video_buffer == nullptr)
            _video_buffer = (char*)malloc(bufferSize + 2);

        if (_offset_videoread + bufferSize > _video_file_length)
            _offset_videoread = 0;

        ifs.seekg(_offset_videoread);
        ifs.read(_video_buffer, bufferSize);
        _offset_videoread += bufferSize;

        TRTCVideoFrame frame;
        frame.videoFormat = LiteAVVideoPixelFormat_I420;
        frame.length = bufferSize;
        frame.data = _video_buffer;
        frame.width = _video_width;
        frame.height = _video_height;
        m_pCloud->sendCustomVideoData(&frame);
    }
}

void TRTCCloudCore::setPresetLayoutConfig(TRTCTranscodingConfig & config) {

    int canvasWidth = 1280;
    int canvasHeight = 720;
    if (CDataCenter::GetInstance()->m_videoEncParams.resMode == TRTCVideoResolutionModePortrait) {
        canvasHeight = 1280;
        canvasWidth = 720;
    }

    config.videoWidth = canvasWidth;
    config.videoHeight = canvasHeight;
    config.videoBitrate = 1500;
    config.videoFramerate = 15;
    config.videoGOP = 1;
    config.audioSampleRate = 48000;
    config.audioBitrate = 64;
    config.audioChannels = 1;

    config.mixUsersArraySize = 8;

    TRTCMixUser* mixUsersArray = new TRTCMixUser[config.mixUsersArraySize];
    config.mixUsersArray = mixUsersArray;
    int zOrder = 1, index = 0;
    auto setMixUser = [&](const char * _userid, int _index, int _zOrder,
        int left, int top, int width, int height) {
        mixUsersArray[_index].roomId = nullptr;
        mixUsersArray[_index].userId = _userid;
        mixUsersArray[_index].zOrder = _zOrder;
        {
            mixUsersArray[_index].rect.left = left;
            mixUsersArray[_index].rect.top = top;
            mixUsersArray[_index].rect.right = left + width;
            mixUsersArray[_index].rect.bottom = top + height;
        }
    };
    //本地主路信息
    setMixUser("$PLACE_HOLDER_LOCAL_MAIN$", index, zOrder, 0, 0, canvasWidth, canvasHeight);
    index++; zOrder++;

    setMixUser("$PLACE_HOLDER_LOCAL_SUB$", index, zOrder, 0, 0, canvasWidth, canvasHeight);
    index++; zOrder++;

    if (canvasWidth < canvasHeight) {
        //竖屏排布
        int subWidth = canvasWidth / 5 / 2 * 2;
        int subHeight = canvasHeight / 5 / 2 * 2;
        int xOffSet = (canvasWidth - (3 * subWidth)) / 4;
        int yOffSet = (canvasHeight - (4 * subHeight)) / 5;
        for (int u = 0; u < 6; ++u, index++, zOrder++) {

            if (u < 3) {
                // 前三个小画面靠左往右
                setMixUser("$PLACE_HOLDER_REMOTE$", index, zOrder,
                    xOffSet * (1 + u) + subWidth * u, canvasHeight - yOffSet - subHeight, subWidth, subHeight);
            }
            else if (u < 6) {
                // 后三个小画面靠左从下往上铺
                setMixUser("$PLACE_HOLDER_REMOTE$", index, zOrder,
                    canvasWidth - xOffSet - subWidth, canvasHeight - (u-1) * yOffSet - (u - 1) * subHeight, subWidth, subHeight);
            }
            else {
                // 最多只叠加六个小画面
            }
        }
    }
    else {
        //横屏排布
        int subWidth = canvasWidth / 5 / 2 * 2;
        int subHeight = canvasHeight / 5 / 2 * 2;
        int xOffSet = 10;
        int yOffSet = (canvasHeight - (3 * subHeight)) / 4;

        for (int u = 0; u < 6; ++u, index++, zOrder++) {
            if (u < 3) {
                // 前三个小画面靠右从下往上铺
                setMixUser("$PLACE_HOLDER_REMOTE$", index, zOrder,
                    canvasWidth - xOffSet - subWidth, canvasHeight - (u + 1) * yOffSet - (u + 1) * subHeight, subWidth, subHeight);
            }
            else if (u < 6) {
                // 后三个小画面靠左从下往上铺
                setMixUser("$PLACE_HOLDER_REMOTE$", index, zOrder,
                    xOffSet, canvasHeight - (u - 2) * yOffSet - (u - 2) * subHeight, subWidth, subHeight);
            }
            else {
                // 最多只叠加六个小画面
            }
        }
    }
}

void TRTCCloudCore::startGreenScreen(const std::string &path)
{
    
}

void TRTCCloudCore::stopGreenScreen()
{
    
}
std::string TRTCCloudCore::GetPathNoExt(std::string path) {
    std::string str_ret;
    if (path.length() > 0) {
        size_t uPos = 0;
        for (size_t u = 0; u < path.size() - 1; u++) {
            if (path.c_str()[u] == '\\') uPos = u;
        }

        str_ret = path.substr(0, uPos + 1);
    }
    return str_ret;
}