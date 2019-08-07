#pragma once
#include <map>
#include <queue>
#include <string>
#include <memory>
#include "TRTCCloudDef.h"

class CConfigMgr;


typedef struct _tagRemoteUserInfo
{
    bool _bSubscribeAudio = false;
    bool _bSubscribeVideo = false;
    bool bEnterRoom = false;
}RemoteUserInfo;

typedef struct _tagPKUserInfo
{
    std::string _userId = "";
    uint32_t _roomId = 0;
    bool bEnterRoom = false;
}PKUserInfo;

struct UserVideoMeta
{
    std::string userId = "";
    std::string roomId = "";

    int streamType = 0;
    uint32_t width = 0;
    uint32_t height = 0;
    uint32_t fps = 0;
    bool bPureAudio = false;
    bool bMainStream = false;
};

typedef std::multimap<std::pair<std::string, TRTCVideoStreamType>, RemoteUserInfo> RemoteUserListMap;

class CDataCenter
{
public:
   typedef struct _tagLocalUserInfo {
    public:
        _tagLocalUserInfo() {};
        std::string _userId = "test_trtc_01";
        std::string _pwd = "12345678";
        int _roomId = 1222222;
        std::string _userSig;
        bool _bEnterRoom = false;
        bool _bMuteAudio = false;
        bool _bMuteVideo = false;
    }LocalUserInfo;

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
    std::string getLocalUserID() { return m_loginInfo._userId; };
    VideoResBitrateTable getVideoConfigInfo(int resolution);
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

    bool m_bPureAudioStyle = false; //是否纯音频模式。

    bool m_bLocalVideoMirror = false;      //本地镜像
    bool m_bRemoteVideoMirror = false;     //暂不支持
    bool m_bShowAudioVolume =   true;      //开启音量提示
    bool m_bCDNMixTranscoding = false;     //混流设置

    bool m_bCustomAudioCapture = false;    //自定义采集音频
    bool m_bCustomVideoCapture = false;    //自定义采集视频

    bool m_bStartScreenShare = false;

    std::map<int, VideoResBitrateTable> m_videoConfigMap;


    uint32_t m_micVolume = 100;
    uint32_t m_speakerVolume = 50;
public:  //混流信息
    std::vector<UserVideoMeta> mixStreamVideoMeta;
    void removeVideoMeta(std::string userId, int streamType);

public:  //视频窗口信息
    RemoteUserListMap m_remoteUser;
    void removeRemoteUser(std::string userId, int streamType = -1);
public:
    CConfigMgr* m_pConfigMgr;

    LocalUserInfo m_loginInfo;

    std::vector<PKUserInfo> m_vecPKUserList;


};

