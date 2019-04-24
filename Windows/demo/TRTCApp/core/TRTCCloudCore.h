#pragma once
#include "ITRTCCloud.h"
#include "ITXVodPlayer.h"
#include <map>
#include <string>
#include <mutex>

struct DashboardInfo
{
    int streamType = -1;
    std::string userId;
    std::string buffer;   
};

struct UserVideoInfo
{
    std::string userId = "";
    std::string roomId = "";

    uint32_t width;
    uint32_t height;
    uint32_t fps;
    uint32_t streamType;
    uint32_t videoBitrate;
    bool bPureAudio = false;
};

class TRTCCloudCore 
    : public ITRTCCloudCallback
    , public ITRTCLogCallback
	, public ITXVodPlayerCallback
    , public ITRTCAudioFrameCallback
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
    void Destory();
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
    virtual void onEnterRoom(uint64_t elapsed);
    virtual void onExitRoom(int reason);
    virtual void onUserEnter(const char* userId);
    virtual void onUserExit(const char* userId, int reason);
    virtual void onUserAudioAvailable(const char* userId, bool available) {}
    virtual void onUserVoiceVolume(TRTCVolumeInfo* userVolumes, uint32_t userVolumesCount, uint32_t totalVolume);
	virtual void onUserSubStreamAvailable(const char* userId, bool available);
	virtual void onUserVideoAvailable(const char* userId, bool available);
    virtual void onNetworkQuality(TRTCQualityInfo localQuality, TRTCQualityInfo* remoteQuality, uint32_t remoteQualityCount);
    virtual void onStatistics(const TRTCStatistics& statis);
    virtual void onConnectionLost();
    virtual void onTryToReconnect();
    virtual void onConnectionRecovery();
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
    void stopPreview();
	void startScreen(HWND rendHwnd);
	void stopScreen();
    void startMedia(const char *mediaFile, HWND rendHwnd);
    void stopMedia();
	void startGreenScreen(const std::string &path);
	void stopGreenScreen();
	void selectScreenCaptureTarget(const TRTCScreenCaptureSourceInfo &source, const RECT& captureRect);
    void showDashboardStyle(int logStyle);

    void connectOtherRoom(std::string userId, uint32_t roomId);

    void startCloudMixStream(std::string localUserId);
    void stopCloudMixStream();
    void updateMixTranCodeInfo(std::vector<UserVideoInfo> vec, UserVideoInfo& localInfo);

    void startCustomCaptureAudio(std::wstring filePath, int samplerate, int channel);
    void stopCustomCaptureAudio();
    void startCustomCaptureVideo(std::wstring filePat, int width, int height);
    void stopCustomCaptureVideo();

    void sendCustomAudioFrame();
    void sendCustomVideoFrame();
protected:
    bool isChangeMixTranCodeInfo(std::vector<UserVideoInfo> vec);
private:
    static TRTCCloudCore* m_instance;

    std::vector<MediaDeviceInfo> m_vecSpeakDevice;
    std::vector<MediaDeviceInfo> m_vecMicDevice;
    std::vector<MediaDeviceInfo> m_vecCameraDevice;

    std::multimap<uint32_t, HWND> m_mapSDKMsgFilter;    // userId和VideoView*的映射map
    std::mutex m_mutexMsgFilter;
    ITRTCCloud* m_pCloud = nullptr;
    ITXVodPlayer* m_pVodPlayer = nullptr;
    int m_mRefLocalPreview = 0;
    bool m_bFirstUpdateDevice = false;

    //云端混流功能
    std::string m_localUserId;
    bool m_bStartCloudMixStream = false;
    std::map<std::string, UserVideoInfo> m_mapMixTranCodeInfo;

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
};

