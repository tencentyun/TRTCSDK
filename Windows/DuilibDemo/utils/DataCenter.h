#pragma once
#include <map>
#include <queue>
#include <string>
#include <memory>
#include "TRTCCloudDef.h"
#include "TXLiteAVBase.h"

class CConfigMgr;

#define TRTCAudioQualityUnSelect 0
enum LivePlayerSourceType
{
    TRTC_RTC,
    TRTC_CDN
};

enum VodRenderMode
{
    VOD_RENDER_WND,
    VOD_RENDER_CUSTOM,
    VOD_RENDER_TRTC,
};
typedef struct RemoteUserInfo
{
    std::string user_id = "";
    uint32_t room_id = 0;
    std::string str_room_id = "";
    bool available_main_video = false;
    bool available_sub_video = false;
    bool available_audio = false;
    bool subscribe_audio = false;
    bool subscribe_main_video = false;
    bool subscribe_sub_video = false;
}RemoteUserInfo;

typedef struct _tagLocalUserInfo {
public:
    _tagLocalUserInfo() {};
    std::string _userId = "test_trtc_01";
    std::string _pwd = "12345678";
    int _roomId = 1222222;
    std::string strRoomId = "";
    std::string _userSig;
    bool _bEnterRoom = false;
    bool publish_audio = false;
    bool publish_main_video = false;
    bool publish_sub_video = false;
}LocalUserInfo;

typedef struct _tagPKUserInfo
{
    std::string _userId = "";
    uint32_t _roomId = 0;
    bool bEnterRoom = false;
}PKUserInfo;

typedef std::map<std::string, RemoteUserInfo> RemoteUserInfoList;

class CDataCenter
{
public:
    typedef struct _tagBeautyConfig {
        bool _bOpenBeauty = false;
        TRTCBeautyStyle _beautyStyle = TRTCBeautyStyleSmooth;
        uint32_t _beautyValue = 0;
        uint32_t _whiteValue = 0;
        uint32_t _ruddinessValue = 0;
    }BeautyConfig;

    typedef struct _tagVideoResBitrateTable
    {
    public:
        int defaultBitrate = 800;
        int minBitrate = 1200;
        int maxBitrate = 200;
    public:
        void init(int bitrate, int minBit, int maxBit)
        {
            defaultBitrate = bitrate;
            minBitrate = minBit;
            maxBitrate = maxBit;
        }
        void resetLiveSence()
        {
            defaultBitrate = defaultBitrate * 15 / 10;
            minBitrate = minBitrate * 15 / 10;
            maxBitrate = maxBitrate * 15 / 10;
        }
    }VideoResBitrateTable;
public:
    static std::shared_ptr<CDataCenter> GetInstance();
    CDataCenter();
    ~CDataCenter();
    void CleanRoomInfo();
    void UnInit();
    void Init();    //初始化SDK的local配置信息
public:
    LocalUserInfo& getLocalUserInfo();
    std::string getLocalUserID() { return m_localInfo._userId; };
    VideoResBitrateTable getVideoConfigInfo(int resolution);
    bool getAudioAvaliable(std::string userId);
    bool getVideoAvaliable(std::string userId, TRTCVideoStreamType type);
    TRTCRenderParams getLocalRenderParams();
    TRTCVideoStreamType getRemoteVideoStreamType();
public:
    void WriteEngineConfig();
    BeautyConfig& GetBeautyConfig();
public: //trtc 
    std::wstring m_selectSpeak;
    std::wstring m_selectMic;
    std::wstring m_selectCamera;

    TRTCVideoEncParam m_videoEncParams;
    TRTCNetworkQosParam m_qosParams;
    TRTCAppScene m_sceneParams = TRTCAppSceneVideoCall;
    TRTCRoleType m_roleType = TRTCRoleAnchor;

    //美颜参数
    BeautyConfig m_beautyConfig;

    bool m_bPushSmallVideo = false; //推流打开小流设置。
    bool m_bPlaySmallVideo = false; //拉流打开小流设置。

    /*
    enum {
        Env_PROD = 0,   // 正式环境
        Env_DEV = 1,    // 开发测试环境
        Env_UAT = 2,    // 体验环境
    };
    */
    int m_nLinkTestServer = 0; //是否连接测试环境。
    bool m_bOpenDemoTestConfig = false; //是否打开demo的测试环境开关。。

    bool m_bAutoRecvAudio = true;
    bool m_bAutoRecvVideo = true;

    bool m_bMuteLocalVideo = false;
    bool m_bMuteLocalAudio = false;

    bool m_bLocalVideoMirror = false;      //本地镜像
    bool m_bRemoteVideoMirror = false;     //暂不支持
    bool m_bShowAudioVolume =   true;      //开启音量提示
    bool m_bBlackFramePush = false;        //开启黑帧推流
    bool m_bWateMark = false;

    bool m_bCustomAudioCapture = false;    //自定义采集音频
    bool m_bCustomVideoCapture = false;    //自定义采集视频
    bool m_bCustomSubAudioCapture = false;    //自定义辅路采集音频
    bool m_bCustomSubVideoCapture = false;    //自定义辅路采集视频

    bool m_bEnableAec = true;
    bool m_bEnableAns = true;
    bool m_bEnableAgc = true;

    std::string m_strSocks5ProxyIp;
    int         m_strSocks5ProxyPort = 0;

    bool m_bOpenAudioAndCanvasMix = false; //开启纯音频+画布混流模式。
    bool m_bCDNMixTranscoding = false;     //混流设置
    bool m_bPublishScreenInBigStream = false;
    int m_mixTemplateID = 0;
    std::string m_strMixStreamId;
    std::string m_strCustomStreamId;

    std::map<int, VideoResBitrateTable> m_videoConfigMap;
    uint32_t m_micVolume = 100;
    uint32_t m_speakerVolume = 100;
    uint32_t m_audioCaptureVolume = 100; // 软件采集音量
    uint32_t m_audioPlayoutVolume = 100; // 软件播放音量（人声）
    //是否在room中
    bool m_bIsEnteredRoom = false;

    //录制参数
    bool m_bStartLocalRecord = false;
    bool m_bWaitStartRecordNotify = false;
    bool m_bPauseLocalRecord = false;
    LiteAVScreenCaptureSourceInfo m_recordCaptureSourceInfo;
    std::wstring m_recordCaptureSourceInfoName;
    RECT m_recordCaptureRect = {0};
    std::wstring m_wstrRecordFile;

    //录音参数
    bool m_bStartAudioRecording = false;
    std::wstring m_wstrAudioRecordFile;

    bool m_bStartMixAppAudio = false;
    std::wstring m_wstrMixAudioAppPath;

    //本地录制参数
    bool m_bStartLocalRecording = false;
    std::wstring m_wstrLocalRecordFile;
    TRTCLocalRecordType m_localRecordType = TRTCLocalRecordType_Both;

    bool m_bStartSystemVoice = false;
    std::wstring third_app_path_;

    int audio_quality_ = TRTCAudioQualityUnSelect;
    LivePlayerSourceType m_emLivePlayerSourceType = TRTC_RTC;

    bool vod_push_video_ = true;
    bool vod_push_audio_ = true;
    VodRenderMode vod_render_mode_ = VOD_RENDER_WND;

    bool need_minimize_windows_ = true;

   public: 
    //远端用户信息
    RemoteUserInfoList m_remoteUser;
    void addRemoteUser(std::string userId, bool bClear = true);
    void removeRemoteUser(std::string userId);
    RemoteUserInfo* FindRemoteUser(std::string userId);
    std::string GetCdnUrl(const std::string & strUserId);
public:
    CConfigMgr* m_pConfigMgr;

    LocalUserInfo m_localInfo;

    std::vector<PKUserInfo> m_vecPKUserList;
};

