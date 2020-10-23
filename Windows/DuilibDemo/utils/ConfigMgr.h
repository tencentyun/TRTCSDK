#pragma once

#include <map>
#include <string>
//键值对结构体
namespace Config {
#define INI_ROOT_KEY L"TRTCDemo"
#define INI_KEY_USER_ID L"INI_KEY_USER_ID"
#define INI_KEY_CHOOSE_CAMERA L"INI_KEY_CHOOSE_CAMERA"
#define INI_KEY_CHOOSE_SPEAK L"INI_KEY_CHOOSE_SPEAK"
#define INI_KEY_CHOOSE_MIC L"INI_KEY_CHOOSE_MIC"
#define INI_KEY_VIDEO_BITRATE L"INI_KEY_VIDEO_BITRATE"
#define INI_KEY_VIDEO_RESOLUTION L"INI_KEY_VIDEO_RESOLUTION"
#define INI_KEY_VIDEO_FPS L"INI_KEY_VIDEO_FPS"
#define INI_KEY_VIDEO_QUALITY L"INI_KEY_VIDEO_QUALITY"
#define INI_KEY_VIDEO_QUALITY_CONTROL L"INI_KEY_VIDEO_QUALITY_CONTROL"
#define INI_KEY_VIDEO_APP_SCENE L"INI_KEY_VIDEO_APP_SCENE"
#define INI_KEY_AUDIO_MIC_VOLUME L"INI_KEY_AUDIO_MIC_VOLUME"
#define INI_KEY_AUDIO_SPEAKER_VOLUME L"INI_KEY_AUDIO_SPEAKER_VOLUME"
#define INI_KEY_AUDIO_SAMPLERATE L"INI_KEY_AUDIO_SAMPLERATE"
#define INI_KEY_AUDIO_CHANNEL L"INI_KEY_AUDIO_CHANNEL"
#define INI_KEY_BEAUTY_OPEN L"INI_KEY_BEAUTY_OPEN"
#define INI_KEY_BEAUTY_STYLE L"INI_KEY_BEAUTY_STYLE"
#define INI_KEY_BEAUTY_VALUE L"INI_KEY_BEAUTY_VALUE"
#define INI_KEY_WHITE_VALUE L"INI_KEY_WHITE_VALUE"
#define INI_KEY_RUDDINESS_VALUE L"INI_KEY_RUDDINESS_VALUE"
#define INI_KEY_SET_PUSH_SMALLVIDEO L"INI_KEY_SET_PUSH_SMALLVIDEO"
#define INI_KEY_SET_PLAY_SMALLVIDEO L"INI_KEY_SET_PLAY_SMALLVIDEO"
#define INI_KEY_SET_NETENV_STYLE L"INI_KEY_SET_NETENV_STYLE"

#define INI_KEY_VIDEO_RES_MODE L"INI_KEY_VIDEO_RES_MODE"
#define INI_KEY_LOCAL_VIDEO_MIRROR L"INI_KEY_LOCAL_VIDEO_MIRROR"
#define INI_KEY_REMOTE_VIDEO_MIRROR L"INI_KEY_REMOTE_VIDEO_MIRROR"
#define INI_KEY_SHOW_AUDIO_VOLUME L"INI_KEY_SHOW_AUDIO_VOLUME"
#define INI_KEY_CLOUD_MIX_TRANSCODING L"INI_KEY_CLOUD_MIX_TRANSCODING"
#define INI_KEY_MIX_TEMP_ID L"INI_KEY_MIX_TEMP_ID"
#define INI_KEY_PUBLISH_SCREEN_IN_BIG_STREAM L"INI_KEY_PUBLISH_SCREEN_IN_BIG_STREAM"

//#define INI_KEY_MIC_VOLUME L"INI_KEY_MIC_VOLUME"
//#define INI_KEY_SPEAKER_VOLUME L"INI_KEY_SPEAKER_VOLUME"

#define INI_KEY_ROLE_TYPE L"INI_KEY_ROLE_TYPE"

//#define INI_KEY_ENABLE_AEC L"INI_KEY_ENABLE_AEC"
//#define INI_KEY_ENABLE_ANS L"INI_KEY_ENABLE_ANS"
//#define INI_KEY_ENABLE_AGC L"INI_KEY_ENABLE_AGC"

#define INI_KEY_SOCKS5_PROXY_IP L"INI_KEY_SOCKS5_PROXY_IP"
#define INI_KEY_SOCKS5_PROXY_PORT L"INI_KEY_SOCKS5_PROXY_PORT"
#define INI_KEY_AUDIO_QUALITY L"INI_KEY_AUDIO_QUALITY"
};



class SubNode
{
public:
    void InsertElement(std::wstring key, std::wstring value)
    {
        sub_node.insert(pair<std::wstring, std::wstring>(key, value));
    }
    std::map<std::wstring, std::wstring> sub_node;
};

//INI文件操作类
class CConfigMgr
{
public:
    CConfigMgr();
    ~CConfigMgr();
public:
    bool GetValue(std::wstring root, std::wstring key, std::wstring& value );                //由根结点和键获取值
    bool SetValue(std::wstring root, std::wstring key, std::wstring value);    //设置根结点和键获取值
    int GetSize() { return map_ini.size(); }
private:
    int WriteINI();            //写入INI文件
    void Clear() { map_ini.clear(); }    //清空
    void Travel();                        //遍历打印INI文件
    int InitReadINI();
private:
    std::map<std::wstring, SubNode> map_ini;        //INI文件内容的存储变量
    std::wstring _IncFilePath;                      //文件路径
};