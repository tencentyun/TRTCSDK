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
#include "TRTCGetUserIDAndUserSig.h"

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
    if (m_pCloud == nullptr)
    {
        m_pCloud = getTRTCShareInstance();
    }
}

TRTCCloudCore::~TRTCCloudCore()
{
    destroyTRTCShareInstance();
    m_pCloud = nullptr;
}

void TRTCCloudCore::Init()
{
    //检查默认选择设备

    m_pCloud->addCallback(this);
    m_pCloud->setLogCallback(this);
    //std::string logPath = Wide2UTF8(L"D:/中文/log/");
    //m_pCloud->setLogDirPath(logPath.c_str());
    
    //m_pCloud->setAudioFrameCallback(this);
}

void TRTCCloudCore::Uninit()
{
    m_mRefLocalPreview = 0;

    removeAllSDKMsgObserver();
    m_pCloud->removeCallback(this);
    m_pCloud->setLogCallback(nullptr);

    stopCloudMixStream();
}

void TRTCCloudCore::PreUninit()
{
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
            ::PostMessage(itr.second, WM_USER_CMD_Error, (WPARAM)0, errCode);
        }
    }
}

void TRTCCloudCore::onWarning(TXLiteAVWarning warningCode, const char* warningMsg, void* arg)
{
    LINFO(L"onWarning errorCode[%d], errorInfo[%s]\n", warningCode, UTF82Wide(warningMsg).c_str());

    // 临时方案 todo
    /*
    int type = (int)warningCode;
    if (type == -1 && warningMsg && arg)
    {
        for (auto& itr : m_mapSDKMsgFilter)
        {
            if (itr.first == WM_USER_CMD_Dashboard && itr.second != nullptr)
            {
                std::string* strUserid = new std::string((char*)arg);
                std::string* value = new std::string(warningMsg);
                ::PostMessage(itr.second, WM_USER_CMD_Dashboard, (WPARAM)strUserid, (LPARAM)value);
            }
        }
    }
    else if (type == -2 && warningMsg && arg)
    {
        for (auto& itr : m_mapSDKMsgFilter)
        {
            if (itr.first == WM_USER_CMD_SDKEventMsg && itr.second != nullptr)
            {
                std::string* strUserid = new std::string((char*)arg);
                std::string* value = new std::string(warningMsg);
                ::PostMessage(itr.second, WM_USER_CMD_SDKEventMsg, (WPARAM)strUserid, (LPARAM)value);
            }
        }
    }
    */
}

void TRTCCloudCore::onEnterRoom(uint64_t elapsed)
{
    LINFO(L"onEnterRoom elapsed[%lld]\n", elapsed);

    std::unique_lock<std::mutex> lck(m_mutexMsgFilter);
    uint32_t useTime = (uint32_t)elapsed;
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_EnterRoom && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_EnterRoom, 0, (LPARAM)useTime);
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

void TRTCCloudCore::onUserEnter(const char * userId)
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

void TRTCCloudCore::onUserExit(const char* userId, int reason)
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
    // todo kamis
    // todo 更新流统计信息内容。
    
    //更新云端混流的结构信息
    /*
    if (m_bStartCloudMixStream)
    {
        std::vector<UserVideoInfo>* vecList = new std::vector<UserVideoInfo>;
        UserVideoInfo* localInfo = new UserVideoInfo;
        localInfo->userId = m_localUserId;
        if (statis.localStatisticsArray != nullptr && statis.localStatisticsArraySize != 0)
        {
            for (int i = 0; i < statis.localStatisticsArraySize; i++)
            {
                if (statis.localStatisticsArray[i].streamType == TRTCVideoStreamTypeBig)
                {
                    localInfo->width = statis.localStatisticsArray[i].width;
                    localInfo->height = statis.localStatisticsArray[i].height;
                    localInfo->fps = statis.localStatisticsArray[i].frameRate;
                }
            }
        }
        if (statis.remoteStatisticsArray != nullptr && statis.remoteStatisticsArraySize != 0)
        {
            for (int i = 0; i < statis.remoteStatisticsArraySize; i++)
            {
                if (statis.remoteStatisticsArray[i].streamType == TRTCVideoStreamTypeBig)
                {
                    UserVideoInfo info;
                    info.userId = std::string(statis.remoteStatisticsArray[i].userId);
                    info.width = statis.remoteStatisticsArray[i].width;
                    info.height = statis.remoteStatisticsArray[i].height;
                    vecList->push_back(info);
                }
            }
        }
        //updateMixTranCodeInfo(*vecList, localInfo);
        for (auto& itr : m_mapSDKMsgFilter)
        {
            if (itr.first == WM_USER_CMD_UserListStaticChange && itr.second != nullptr)
            {
                ::PostMessage(itr.second, WM_USER_CMD_UserListStaticChange, (WPARAM)vecList, (LPARAM)localInfo);
            }
        }
    }
    */
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
                //std::string* strUserid = new std::string((char*)module);
                //std::string* value = new std::string(log);
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
                //std::string* strUserid = new std::string((char*)module);
                //std::string* value = new std::string(log);
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
    
}

void TRTCCloudCore::onPlayAudioFrame(TRTCAudioFrame * frame, const char * userId)
{
    /*
    LINFO(L"onPlayAudioFrame\n");
    FILE* file = NULL;
    ::fopen_s(&file, "D:/subTest/playaudio_frame.pcm", "ab+");
    ::fwrite(frame->data, frame->length, 1, file);
    ::fflush(file);
    ::fclose(file);
    */
}

void TRTCCloudCore::onMixedPlayAudioFrame(TRTCAudioFrame * frame)
{
    /*
    LINFO(L"onMixedPlayAudioFrame\n");
    FILE* file = NULL;
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

void TRTCCloudCore::onFirstVideoFrame(const char* userId, uint32_t width, uint32_t height)
{
    LINFO(L"onFirstVideoFrame userId[%s], width[%d], height[%d]\n", UTF82Wide(userId).c_str(), width, height);
    
    std::unique_lock<std::mutex> lck(m_mutexMsgFilter);
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_FirstVideoFrame && itr.second != nullptr)
        {
            std::string * str = new std::string(userId);
            uint32_t resolution = width << 16 + height;
            ::PostMessage(itr.second, WM_USER_CMD_FirstVideoFrame, (WPARAM)str, resolution);
        }
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
    int size = m_mapSDKMsgFilter.size();
    for (int i = 0; i < size; i++)
    {
        bool bFind = false;
        std::map<uint32_t, HWND>::iterator itr = m_mapSDKMsgFilter.begin();
        for (; itr != m_mapSDKMsgFilter.end(); itr++)
        {
            if (itr->second == hwnd)
            {
                m_mapSDKMsgFilter.erase(itr);
                bFind = true;
                break;;
            }
        }
        if (bFind == false)
            break;
    }
}

void TRTCCloudCore::removeAllSDKMsgObserver()
{
    std::unique_lock<std::mutex> lck(m_mutexMsgFilter);
    m_mapSDKMsgFilter.clear();
}

std::vector<TRTCCloudCore::MediaDeviceInfo>& TRTCCloudCore::getMicDevice()
{
    std::wstring& selectDevice = CDataCenter::GetInstance()->m_selectMic;
    std::vector<MediaDeviceInfo>& vecDeviceList = m_vecMicDevice;
    vecDeviceList.clear();
    ITRTCDeviceCollection * pDevice = m_pCloud->getMicDevicesList();
    bool bFindSelect = false;
    for (int i = 0; i < pDevice->getCount(); i++)
    {
        std::wstring name = UTF82Wide(pDevice->getDeviceName(i));
        TRTCCloudCore::MediaDeviceInfo info;
        info._index = i;
        info._text = name;
        info._deviceId = UTF82Wide(pDevice->getDevicePID(i));
        info._type = L"mic";
        if (info._text.compare(selectDevice.c_str()) == 0)
        {
            bFindSelect = true;
            info._select = true;
        }
        vecDeviceList.push_back(info);
    }
    pDevice->release();
    pDevice = nullptr;
    if (!bFindSelect && vecDeviceList.size() > 0)
    {
        selectDevice = vecDeviceList[0]._text;
        vecDeviceList[0]._select = true;
    }
    else if (!bFindSelect && vecDeviceList.size() <= 0)
    {
        selectDevice = L"";
    }
    return vecDeviceList;
}

std::vector<TRTCCloudCore::MediaDeviceInfo>& TRTCCloudCore::getSpeakDevice()
{
    std::wstring& selectDevice = CDataCenter::GetInstance()->m_selectSpeak;
    std::vector<MediaDeviceInfo>& vecDeviceList = m_vecSpeakDevice;
    vecDeviceList.clear();

    ITRTCDeviceCollection * pDevice = m_pCloud->getSpeakerDevicesList();
    bool bFindSelect = false;
    for (int i = 0; i < pDevice->getCount(); i++)
    {
        std::wstring name = UTF82Wide(pDevice->getDeviceName(i));
        TRTCCloudCore::MediaDeviceInfo info;
        info._index = i;
        info._text = name;
        info._deviceId = UTF82Wide(pDevice->getDevicePID(i));
        info._type = L"speaker";
        if (info._text.compare(selectDevice.c_str()) == 0)
        {
            bFindSelect = true;
            info._select = true;
        }
        vecDeviceList.push_back(info);
    }
    pDevice->release();
    pDevice = nullptr;
    if (!bFindSelect && vecDeviceList.size() > 0)
    {
        selectDevice = vecDeviceList[0]._text;
        vecDeviceList[0]._select = true;
    }
    else if (!bFindSelect && vecDeviceList.size() <= 0)
    {
        selectDevice = L"";
    }
    return vecDeviceList;
}

std::vector<TRTCCloudCore::MediaDeviceInfo>& TRTCCloudCore::getCameraDevice()
{
    std::wstring& selectDevice = CDataCenter::GetInstance()->m_selectCamera;
    std::vector<MediaDeviceInfo>& vecDeviceList = m_vecCameraDevice;
    vecDeviceList.clear();
    ITRTCDeviceCollection * pDevice = m_pCloud->getCameraDevicesList();
    bool bFindSelect = false;
    for (int i = 0; i < pDevice->getCount(); i++)
    {
        std::wstring name = UTF82Wide(pDevice->getDeviceName(i));
        TRTCCloudCore::MediaDeviceInfo info;
        info._index = i;
        info._text = name;
        info._deviceId = UTF82Wide(pDevice->getDevicePID(i));
        info._type = L"camera";
        if (info._text.compare(selectDevice.c_str()) == 0)
        {
            bFindSelect = true;
            info._select = true;
        }
        vecDeviceList.push_back(info);
    }
    pDevice->release();
    pDevice = nullptr;

    if (!bFindSelect && vecDeviceList.size() > 0)
    {
        selectDevice = vecDeviceList[0]._text;
        vecDeviceList[0]._select = true;
    }
    else if (!bFindSelect && vecDeviceList.size() <= 0)
    {
        selectDevice = L"";
    }
    return vecDeviceList;
}

ITRTCScreenCaptureSourceList* TRTCCloudCore::GetWndList()
{
	return m_pCloud->getScreenCaptureSources(SIZE{ 120, 70 }, SIZE{ 20,20 });
}

void TRTCCloudCore::selectMicDevice(std::wstring text)
{
    std::wstring& selectDevice = CDataCenter::GetInstance()->m_selectMic;
    std::vector<MediaDeviceInfo>& vecDeviceList = m_vecMicDevice;
    if (text.compare(selectDevice) != 0)
    {
        for (auto& item : vecDeviceList)
        {
            if (item._select)
                item._select = false;
        }
        for (auto& item : vecDeviceList)
        {
            if (item._text.compare(text) == 0)
            {
                item._select = true;
                break;
            }
        }
        selectDevice = text;
    }

    std::wstring deviceId = text;
    for (auto itr: vecDeviceList)
    {
        if (itr._text.compare(text) == 0)
        {
            deviceId = itr._deviceId;
            break;
        }
    }

    if (m_pCloud)
    {
        m_pCloud->setCurrentMicDevice(Wide2UTF8(deviceId.c_str()).c_str());
        m_pCloud->setCurrentMicDeviceVolume(CDataCenter::GetInstance()->m_micVolume);
    }
}

void TRTCCloudCore::selectSpeakerDevice(std::wstring text)
{
    std::wstring& selectDevice = CDataCenter::GetInstance()->m_selectSpeak;
    std::vector<MediaDeviceInfo>& vecDeviceList = m_vecSpeakDevice;
    if (text.compare(selectDevice) != 0)
    {
        for (auto& item : vecDeviceList)
        {
            if (item._select)
                item._select = false;
        }
        for (auto& item : vecDeviceList)
        {
            if (item._text.compare(text) == 0)
            {
                item._select = true;
                break;
            }
        }
        selectDevice = text;
    }

    std::wstring deviceId = text;
    for (auto itr : vecDeviceList)
    {
        if (itr._text.compare(text) == 0)
        {
            deviceId = itr._deviceId;
            break;
        }
    }

    if (m_pCloud)
    {
        m_pCloud->setCurrentSpeakerDevice(Wide2UTF8(deviceId.c_str()).c_str());
        m_pCloud->setCurrentSpeakerVolume(CDataCenter::GetInstance()->m_speakerVolume);
    }
}

void TRTCCloudCore::selectCameraDevice(std::wstring text)
{
    std::wstring& selectDevice = CDataCenter::GetInstance()->m_selectCamera;
    std::vector<MediaDeviceInfo>& vecDeviceList = m_vecCameraDevice;
    if (text.compare(selectDevice) != 0)
    {
        for (auto& item : vecDeviceList)
        {
            if (item._select)
                item._select = false;
        }
        for (auto& item : vecDeviceList)
        {
            if (item._text.compare(text) == 0)
            {
                item._select = true;
                break;
            }
        }
        selectDevice = text;
    }

    std::wstring deviceId = text;
    for (auto itr : vecDeviceList)
    {
        if (itr._text.compare(text) == 0)
        {
            deviceId = itr._deviceId;
            break;
        }
    }

    if (m_pCloud)
        m_pCloud->setCurrentCameraDevice(Wide2UTF8(deviceId.c_str()).c_str());
}

void TRTCCloudCore::startPreview(bool bSetting)
{
    if (m_pCloud == nullptr)
        return;
    //if (nCntLocalPreview == 0)
    if (bSetting && m_mRefLocalPreview >0)
    {
        m_mRefLocalPreview++;
        LINFO(L"startPreview m_mRefLocalPreview[%d], bSetting[1]\n", m_mRefLocalPreview);
        return;
    }
    m_pCloud->startLocalPreview(NULL);
    m_mRefLocalPreview++;
    LINFO(L"startPreview m_mRefLocalPreview[%d]\n", m_mRefLocalPreview);
}

void TRTCCloudCore::stopPreview()
{
    m_mRefLocalPreview--;
    if (m_mRefLocalPreview < 0)
        m_mRefLocalPreview = 0;
    if (m_mRefLocalPreview == 0)
        m_pCloud->stopLocalPreview();
    LINFO(L"stopPreview m_mRefLocalPreview[%d]\n", m_mRefLocalPreview);
  
}

void TRTCCloudCore::startScreen(HWND rendHwnd)
{
	m_pCloud->startScreenCapture(rendHwnd);
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

void TRTCCloudCore::startCloudMixStream(std::string localUserId)
{
    m_localUserId = localUserId;
    m_bStartCloudMixStream = true;

    updateMixTranCodeInfo(CDataCenter::GetInstance()->_remoteVideoInfo, CDataCenter::GetInstance()->_localVideoInfo, true);
}

void TRTCCloudCore::stopCloudMixStream()
{
    m_bStartCloudMixStream = false;
    m_localUserId = "";
    m_mapMixTranCodeInfo.clear();
    if (m_pCloud)
    {
        m_pCloud->setMixTranscodingConfig(NULL);
    }
}

bool TRTCCloudCore::isChangeMixTranCodeInfo(std::vector<UserVideoInfo> vec)
{
    if (m_mapMixTranCodeInfo.size() != vec.size() )
    {
        return true;
    }
    for (auto it : vec)
    {
        if (m_mapMixTranCodeInfo.find(it.userId) == m_mapMixTranCodeInfo.end())
            return true;
    }

    return false;
}

void TRTCCloudCore::updateMixTranCodeInfo(std::vector<UserVideoInfo> vec, UserVideoInfo& localInfo, bool bForce)
{
    if (m_bStartCloudMixStream == false)
        return;
    if (vec.size() == 0 && m_mapMixTranCodeInfo.size() > 0)
    {
        m_pCloud->setMixTranscodingConfig(NULL);
        m_mapMixTranCodeInfo.clear();
        return;
    }

    if (isChangeMixTranCodeInfo(vec) == false && bForce == false)
        return;
    if (localInfo.userId.compare("") == 0)
        return;
    m_mapMixTranCodeInfo.clear();

    for (auto& it : vec)
    {
        std::vector<PKUserInfo>& pkList = CDataCenter::GetInstance()->m_vecPKUserList;
        std::vector<PKUserInfo>::iterator result;
        for (result = pkList.begin(); result != pkList.end(); result++)
        {
            if (result->_userId.compare(it.userId.c_str()) == 0)
            {
                it.roomId = std::to_string(result->_roomId);
                break;
            }
        }
    }
    if (CDataCenter::GetInstance()->m_bPureAudioStyle)
    {
        localInfo.bPureAudio = true;
        for (auto& it : vec)
            it.bPureAudio = true;
    }


    for (auto it : vec)
        m_mapMixTranCodeInfo.insert(std::pair<std::string, UserVideoInfo>(it.userId, it));

    int canvasWidth = 960, canvasHeight = 720;

    int appId = TRTCGetUserIDAndUserSig::instance().getTXCloudAccountInfo()._appId;
    int bizId = TRTCGetUserIDAndUserSig::instance().getTXCloudAccountInfo()._bizId;

    if (appId == 0 || bizId == 0)
    {
        LERROR(L"混流功能不可使用，请在TRTCGetUserIDAndUserSig.h->TXCloudAccountInfo填写混流的账号信息\n");
        return;
    }
    // 更新混流信息
    TRTCTranscodingConfig config;
    config.mode = TRTCTranscodingConfigMode_Manual;
    config.appId = 1252463788;
    config.bizId = 3891;
    config.videoWidth = canvasWidth;
    config.videoHeight = canvasHeight;
    config.videoBitrate = 800;
    config.videoFramerate = 15;
    config.videoGOP = 1;
    config.audioSampleRate = 48000;
    config.audioBitrate = 64;
    config.audioChannels = 1;
    config.mixUsersArraySize = 1 + vec.size();

    TRTCMixUser* mixUsersArray = new TRTCMixUser[config.mixUsersArraySize];
    config.mixUsersArray = mixUsersArray;

    int zOrder = 1, index = 0;
    mixUsersArray[index].roomId = nullptr;
    mixUsersArray[index].userId = localInfo.userId.c_str();
    mixUsersArray[index].pureAudio = localInfo.bPureAudio;
    mixUsersArray[index].rect.left = 0;
    mixUsersArray[index].rect.top = 0;
    mixUsersArray[index].rect.right = canvasWidth;
    mixUsersArray[index].rect.bottom = canvasHeight;
    mixUsersArray[index].zOrder = zOrder++;

    index++;

    for (auto& it : vec)
    {
        int left = 20, top = 40;

        if (zOrder == 2)
        {
            left = 240 / 4 * 3 + 240 * 2;
            top = 240 / 3 * 1;
        }
        if (zOrder == 3)
        {
            left = 240 / 4 * 3 + 240 * 2;
            top = 240 / 3 * 2 + 240 * 1;
        }
        if (zOrder == 4)
        {
            left = 240 / 4 * 2 + 240 * 1;
            top = 240 / 3 * 1;
        }
        if (zOrder == 5)
        {
            left = 240 / 4 * 2 + 240 * 1;
            top = 240 / 3 * 2 + 240 * 1;
        }
        if (zOrder == 6)
        {
            left = 240 / 4 * 1;
            top = 240 / 3 * 1;
        }
        if (zOrder == 7)
        {
            left = 240 / 4 * 1;
            top = 240 / 3 * 2 + 240 * 1;
        }

        int right = 240 + left, bottom = 240 + top;
        if (it.roomId.compare("") == 0)
            mixUsersArray[index].roomId = nullptr;
        else
            mixUsersArray[index].roomId = it.roomId.c_str();
        mixUsersArray[index].userId = it.userId.c_str();
        mixUsersArray[index].pureAudio = it.bPureAudio;
        mixUsersArray[index].rect.left = left;
        mixUsersArray[index].rect.top = top;
        mixUsersArray[index].rect.right = right;
        mixUsersArray[index].rect.bottom = bottom;
        mixUsersArray[index].zOrder = zOrder;
        zOrder++;
        index++;
    }
    if (m_pCloud)
    {
        m_pCloud->setMixTranscodingConfig(&config);
    }
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

    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_CustomAudioCapture && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_CustomAudioCapture, 1, 0);
        }
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
    if (m_pCloud)
        m_pCloud->enableCustomAudioCapture(false);

    CDataCenter::LocalUserInfo& _loginInfo = CDataCenter::GetInstance()->m_loginInfo;
    if (_loginInfo._bMuteAudio == false)
        m_pCloud->startLocalAudio();

    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_CustomAudioCapture && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_CustomAudioCapture, 0, 0);
        }
    }
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
    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_CustomVideoCapture && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_CustomVideoCapture, 1, 0);
        }
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
    if (m_mRefLocalPreview)
        m_pCloud->startLocalPreview(NULL);

    for (auto& itr : m_mapSDKMsgFilter)
    {
        if (itr.first == WM_USER_CMD_CustomVideoCapture && itr.second != nullptr)
        {
            ::PostMessage(itr.second, WM_USER_CMD_CustomVideoCapture, 0, 0);
        }
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

void TRTCCloudCore::startGreenScreen(const std::string &path)
{
	
}

void TRTCCloudCore::stopGreenScreen()
{
	
}