#pragma once
#include "ITRTCCloud.h"
#include "ITXVodPlayer.h"
#include "DataCenter.h"
#include <map>
#include <string>
#include <mutex>
#include "ITXLiteAVLocalRecord.h"
struct DashboardInfo
{
    int streamType = -1;
    std::string userId;
    std::string buffer;   
};
typedef ITRTCCloud* (__cdecl *GetTRTCShareInstance)();
typedef void(__cdecl *DestroyTRTCShareInstance)();

class TRTCCloudCore 
    : public ITRTCCloudCallback
    , public ITRTCLogCallback
    , public ITXVodPlayerCallback
    , public ITRTCAudioFrameCallback
    , public TXLiteAVLocalRecordCallback
{
public:
    typedef struct _tagMediaDeviceInfo
    {
        std::wstring _text;
        std::wstring _type; //识别类别选项:camera/speaker/mic 
        std::wstring _deviceId;
        int _index = 0;
        bool _select = false;
    }MediaDeviceInfo;

    static TRTCCloudCore* GetInstance();
    static void Destory();
    TRTCCloudCore();
    ~TRTCCloudCore();
public:
    void Init();
    void Uninit();
    void PreUninit();
    ITRTCCloud * getTRTCCloud();
public: 
    //interface ITRTCCloudCallback
    virtual void onError(TXLiteAVError errCode, const char* errMsg, void* arg);
    virtual void onWarning(TXLiteAVWarning warningCode, const char* warningMsg, void* arg);
    virtual void onEnterRoom(int result);
    virtual void onExitRoom(int reason);
    virtual void onRemoteUserEnterRoom(const char* userId);
    virtual void onRemoteUserLeaveRoom(const char* userId, int reason);
    virtual void onUserAudioAvailable(const char* userId, bool available);
    virtual void onFirstAudioFrame(const char* userId);
    virtual void onUserVoiceVolume(TRTCVolumeInfo* userVolumes, uint32_t userVolumesCount, uint32_t totalVolume);
    virtual void onUserSubStreamAvailable(const char* userId, bool available);
    virtual void onUserVideoAvailable(const char* userId, bool available);
    virtual void onNetworkQuality(TRTCQualityInfo localQuality, TRTCQualityInfo* remoteQuality, uint32_t remoteQualityCount);
    virtual void onStatistics(const TRTCStatistics& statis);
    virtual void onConnectionLost();
    virtual void onTryToReconnect();
    virtual void onConnectionRecovery();
    //设备相关接口回调
    virtual void onCameraDidReady();
    
    virtual void onMicDidReady();

    virtual void onTestMicVolume(uint32_t volume);

    virtual void onTestSpeakerVolume(uint32_t volume);


    virtual void onDeviceChange(const char* deviceId, TRTCDeviceType type, TRTCDeviceState state);
    virtual void onScreenCaptureStarted();
    virtual void onScreenCaptureStoped(int reason);
    virtual void onVodPlayerStarted(uint64_t msLength);
    virtual void onVodPlayerStoped(int reason);
    virtual void onVodPlayerError(int error) override;
    virtual void onLog(const char* log, TRTCLogLevel level, const char* module);
    virtual void onConnectOtherRoom(const char* userId, TXLiteAVError errCode, const char* errMsg);
    virtual void onDisconnectOtherRoom(TXLiteAVError errCode, const char* errMsg);
    virtual void onCapturedAudioFrame(TRTCAudioFrame *frame);
    virtual void onPlayAudioFrame(TRTCAudioFrame *frame, const char* userId);
    virtual void onMixedPlayAudioFrame(TRTCAudioFrame *frame);
    virtual void onSetMixTranscodingConfig(int errCode, const char* errMsg);
    virtual void onFirstVideoFrame(const char* userId, const TRTCVideoStreamType streamType, const int width, const int height);
    virtual void onSendFirstLocalVideoFrame(const TRTCVideoStreamType streamType);
    virtual void onSendFirstLocalAudioFrame();
    virtual void onAudioEffectFinished(int effectId, int code);
    virtual void onStartPublishing(int err, const char *errMsg);
    virtual void onStopPublishing(int err, const char *errMsg);


    void startLocalRecord(const LiteAVScreenCaptureSourceInfo &source, const char* szRecordPath);
    void stopLocalRecord();
    void pauseLocalRecord();
    void resumeLocalRecord();
    void OnRecordError(TXLiteAVLocalRecordError err, const char* msg) override;
    void OnRecordComplete(const char* path) override;
    void OnRecordProgress(int duration, int fileSize, int width, int height) override;
public:
    void regSDKMsgObserver(uint32_t msg, HWND hwnd);
    void removeSDKMsgObserver(uint32_t msg, HWND hwnd);
    void removeSDKMsgObserverByHwnd(HWND hwnd);
    void removeAllSDKMsgObserver();
public:
    std::vector<MediaDeviceInfo>& getMicDevice();
    std::vector<MediaDeviceInfo>& getSpeakDevice();
    std::vector<MediaDeviceInfo>& getCameraDevice();
    ITRTCScreenCaptureSourceList* GetWndList();
    void selectMicDevice(std::wstring text);
    void selectSpeakerDevice(std::wstring text);
    void selectCameraDevice(std::wstring text);
    //此处要添加引用计数，支持多处渲染
    void startPreview(bool bSetting = false);
    void stopPreview(bool bSetting = false);
    void startScreen(HWND rendHwnd);
    void startScreenCapture(HWND rendHwnd, TRTCVideoStreamType streamType, TRTCVideoEncParam* params);
    void stopScreen();
    void startMedia(const char *mediaFile, HWND rendHwnd);
    void stopMedia();
    void startGreenScreen(const std::string &path);
    void stopGreenScreen();
    void selectScreenCaptureTarget(const TRTCScreenCaptureSourceInfo &source, const RECT& captureRect);
    void showDashboardStyle(int logStyle);

    void connectOtherRoom(std::string userId, uint32_t roomId);

    void startCloudMixStream();
    void stopCloudMixStream();
    void updateMixTranCodeInfo();
    void getMixVideoPos(int index, int& left, int& top, int& right, int& bottom);

    void startCustomCaptureAudio(std::wstring filePath, int samplerate, int channel);
    void stopCustomCaptureAudio();
    void startCustomCaptureVideo(std::wstring filePat, int width, int height);
    void stopCustomCaptureVideo();

    void sendCustomAudioFrame();
    void sendCustomVideoFrame();

protected:
    void setPresetLayoutConfig(TRTCTranscodingConfig & config);
    std::string GetPathNoExt(std::string path);
private:
    static TRTCCloudCore* m_instance;
    std::string m_localUserId;

    std::vector<MediaDeviceInfo> m_vecSpeakDevice;
    std::vector<MediaDeviceInfo> m_vecMicDevice;
    std::vector<MediaDeviceInfo> m_vecCameraDevice;

    std::multimap<uint32_t, HWND> m_mapSDKMsgFilter;    // userId和VideoView*的映射map
    std::mutex m_mutexMsgFilter;
    ITRTCCloud* m_pCloud = nullptr;
    ITXVodPlayer* m_pVodPlayer = nullptr;
    bool m_bStartLocalPreview = false;
    bool m_bStartCameraTest = false;
    bool m_bFirstUpdateDevice = false;

    //云端混流功能

    bool m_bStartCloudMixStream = false;


    //自定义采集功能:
    std::wstring m_videoFilePath, m_audioFilePath;
    bool m_bStartCustomCaptureAudio = false;
    bool m_bStartCustomCaptureVideo = false;
    uint32_t _offset_videoread = 0, _offset_audioread = 0;
    uint32_t _video_file_length = 0, _audio_file_length = 0;
    char * _audio_buffer = nullptr;
    char * _video_buffer = nullptr;
    int _audio_samplerate = 0, _audio_channel = 0;
    int _video_width = 0, _video_height = 0;

    bool m_bPreUninit = false;

    std::thread* custom_audio_thread_ = nullptr;
    std::thread* custom_video_thread_ = nullptr;

private:
    HMODULE trtc_module_;
    GetTRTCShareInstance getTRTCShareInstance_ = nullptr;
    DestroyTRTCShareInstance destroyTRTCShareInstance_ = nullptr;
};

