#pragma once
#include "ITRTCCloud.h"
#include "ITXVodPlayer.h"
#include "DataCenter.h"
#include <map>
#include <string>
#include <mutex>
#include "ITXLiteAVLocalRecord.h"
#include "Live/ITXLivePlayer.h"
#include "Live/TXLiveEventDef.h"
struct DashboardInfo
{
    int streamType = -1;
    std::string userId;
    std::string buffer;   
};
typedef ITRTCCloud* (__cdecl *GetTRTCShareInstance)();
typedef void(__cdecl *DestroyTRTCShareInstance)();

typedef ITXLivePlayer* (__cdecl *CreateTXLivePlayer)();
typedef void(__cdecl *DestroyTXLivePlayer)(ITXLivePlayer** pTXlivePlayer);
typedef void(__cdecl* SetNetEnv)(int bTestEnv);

class TRTCCloudCore 
    : public ITRTCCloudCallback
    , public ITRTCLogCallback
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
    ITXDeviceManager * getDeviceManager();
    ITRTCCloudCallback* GetITRTCCloudCallback();

    ITXLivePlayer* getTXLivePlayer();
public: 
    //interface ITRTCCloudCallback
    virtual void onError(TXLiteAVError errCode, const char* errMsg, void* arg);
    virtual void onWarning(TXLiteAVWarning warningCode, const char* warningMsg, void* arg);
    virtual void onEnterRoom(int result);
    virtual void onExitRoom(int reason);
    virtual void onRemoteUserEnterRoom(const char* userId);
    virtual void onRemoteUserLeaveRoom(const char* userId, int reason);
    virtual void onUserAudioAvailable(const char* userId, bool available);
    virtual void onSwitchRoom(TXLiteAVError errCode, const char* errMsg);
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

    virtual void onSnapshotComplete(const char* userId, TRTCVideoStreamType type, char* data,
                                    uint32_t length, uint32_t width, uint32_t height,
                                    TRTCVideoPixelFormat format);

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
    void startPreview();
    void stopPreview();
    bool IsStartPreview();
    void startScreen(HWND rendHwnd);
    void startScreenCapture(HWND rendHwnd, TRTCVideoStreamType streamType, TRTCVideoEncParam* params);
    void stopScreen();
    void startMedia(const char *mediaFile, HWND rendHwnd);
    void stopMedia();
    void startGreenScreen(const std::string &path);
    void stopGreenScreen();
    void selectScreenCaptureTarget(const TRTCScreenCaptureSourceInfo &source, const RECT& captureRect, const TRTCScreenCaptureProperty & property);
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
    void startCustomSubCaptureAudio(std::wstring filePath, int samplerate, int channel);
    void stopCustomSubCaptureAudio();
    void startCustomSubCaptureVideo(std::wstring filePat, int width, int height);
    void stopCustomSubCaptureVideo();
    void switchVodRender(VodRenderMode vodRenderMode);
    void enableVodPublishVideo(bool enable);
    void enableVodPublishAudio(bool enable);

    void sendCustomAudioFrame();
    void sendCustomVideoFrame();
    void sendCustomSubAudioFrame();
    void sendCustomSubVideoFrame();

    void snapshotVideoFrame(const char* userId, TRTCVideoStreamType type);

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
    ITXLivePlayer* m_pLivePlayer = nullptr;
    ITXDeviceManager* m_pDeviceManager = nullptr;
    bool m_bStartLocalPreview = false;
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

    //自定义辅路采集功能:
    std::wstring m_videoSubFilePath, m_audioSubFilePath;
    bool m_bStartCustomSubCaptureAudio = false;
    bool m_bStartCustomSubCaptureVideo = false;
    uint32_t _sub_offset_videoread = 0, _sub_offset_audioread = 0;
    uint32_t _sub_video_file_length = 0, _sub_audio_file_length = 0;
    char* _sub_audio_buffer = nullptr;
    char* _sub_video_buffer = nullptr;
    int _sub_audio_samplerate = 0, _sub_audio_channel = 0;
    int _sub_video_width = 0, _sub_video_height = 0;

    std::thread* sub_custom_audio_thread_ = nullptr;
    std::thread* sub_custom_video_thread_ = nullptr;

    int test_file_index_ = 1;

private:
    HMODULE trtc_module_;
    GetTRTCShareInstance getTRTCShareInstance_ = nullptr;
    DestroyTRTCShareInstance destroyTRTCShareInstance_ = nullptr;

    CreateTXLivePlayer createTXLivePlayer_ = nullptr;
    DestroyTXLivePlayer destroyTXLivePlayer_ = nullptr;
    SetNetEnv set_net_env_ = nullptr;
};

