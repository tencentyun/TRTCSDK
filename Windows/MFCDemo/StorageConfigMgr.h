#pragma once

#include <map>
#include <string>
#include "TRTCCloudDef.h"
//键值对结构体
namespace Config {
    #define INI_ROOT_KEY L"TRTCDemo"
    #define INI_KEY_VIDEO_BITRATE L"INI_KEY_VIDEO_BITRATE"
    #define INI_KEY_VIDEO_RESOLUTION L"INI_KEY_VIDEO_RESOLUTION"
    #define INI_KEY_VIDEO_FPS L"INI_KEY_VIDEO_FPS"
    #define INI_KEY_VIDEO_QUALITY L"INI_KEY_VIDEO_QUALITY"
    #define INI_KEY_VIDEO_QUALITY_CONTROL L"INI_KEY_VIDEO_QUALITY_CONTROL"
    #define INI_KEY_SET_PUSH_SMALLVIDEO L"INI_KEY_SET_PUSH_SMALLVIDEO"
    #define INI_KEY_SET_PLAY_SMALLVIDEO L"INI_KEY_SET_PLAY_SMALLVIDEO"
    #define INI_KEY_SET_APP_SENSE L"INI_KEY_SET_APP_SENSE"
};

class SubNode
{
public:
    void InsertElement(std::wstring key, std::wstring value)
    {
        sub_node.insert(std::pair<std::wstring, std::wstring>(key, value));
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
    std::wstring GetValue(std::wstring root, std::wstring key);			    //由根结点和键获取值
    bool SetValue(std::wstring root, std::wstring key, std::wstring value);	//设置根结点和键获取值
    int GetSize() { return map_ini.size(); }
private:
    int WriteINI();			//写入INI文件
    void Clear() { map_ini.clear(); }	//清空
    void Travel();						//遍历打印INI文件
    int InitReadINI();
private:
    std::map<std::wstring, SubNode> map_ini;		//INI文件内容的存储变量
    std::wstring _IncFilePath;                      //文件路径
};

/*
* Module:   TRTCStorageConfigMgr
*
* Function: 存储持久化的配置参数
*
*    1. 将TRTCSettingViewController配置的参数需要持久化到本地。
*
*/
class TRTCStorageConfigMgr
{
public:
    static std::shared_ptr<TRTCStorageConfigMgr> GetInstance();
    TRTCStorageConfigMgr();
    ~TRTCStorageConfigMgr();
    void ReadStorageConfig();    //初始化SDK的local配置信息
    void WriteStorageConfig();

public: //trtc 
    // 视频流控类型
    TRTCVideoEncParam videoEncParams;
    TRTCNetworkQosParam qosParams;
    TRTCAppScene appScene = TRTCAppSceneVideoCall;
    bool bPushSmallVideo = false; //推流打开推双流标志。
    bool bPlaySmallVideo = false; //默认拉低请视频流标志。
private:
    CConfigMgr* m_pConfigMgr;
};

