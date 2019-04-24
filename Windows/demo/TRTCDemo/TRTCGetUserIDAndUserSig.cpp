/*
* Module:   TRTCGetUserIDAndUserSig
*
* Function: 用于获取组装 TRTCParam 所必须的 UserSig，腾讯云使用 UserSig 进行安全校验，保护您的 TRTC 流量不被盗用
*/

#include "TRTCGetUserIDAndUserSig.h"
#include "json/json.h"
#include <stdio.h>


TRTCGetUserIDAndUserSig::TRTCGetUserIDAndUserSig()
    : m_sdkAppId(0)
    , m_userInfos()
    , m_http_client(L"User-Agent")
{

}

TRTCGetUserIDAndUserSig::~TRTCGetUserIDAndUserSig()
{

}

TRTCGetUserIDAndUserSig& TRTCGetUserIDAndUserSig::instance()
{
    static TRTCGetUserIDAndUserSig uniqueInstance;
    return uniqueInstance;
}

bool TRTCGetUserIDAndUserSig::loadFromConfig()
{
    FILE* file = NULL;
    fopen_s(&file, "Config.json", "rb");
    if (!file)
    {
        return false;
    }

    std::string data;
    while (true)
    {
        char buffer[512] = { 0 };
        size_t count = ::fread(buffer, 1, 512, file);
        if (count == 0)
        {
            break;
        }

        data.append(buffer, count);
    }

    Json::Reader reader;
    Json::Value root;
    if (!reader.parse(data, root))
    {
        return false;
    }

    if (!root.isMember("sdkappid") || !root.isMember("users"))
    {
        return false;
    }

    m_sdkAppId = root["sdkappid"].asUInt();

    Json::Value users = root["users"];
    for (size_t i = 0; i < users.size(); ++i)
    {
        Json::Value item = users[i];
        if (!item.isMember("userId") || !item.isMember("userToken"))
        {
            return false;
        }

        UserInfo info;
        info.userId = item["userId"].asString();
        info.userSig = item["userToken"].asString();

        m_userInfos.push_back(info);
    }

    return true;
}


uint32_t TRTCGetUserIDAndUserSig::getConfigSdkAppId() const
{
    return m_sdkAppId;
}

std::vector<UserInfo> TRTCGetUserIDAndUserSig::getConfigUserIdArray() const
{
    return m_userInfos;
}

std::string TRTCGetUserIDAndUserSig::getUserSigFromServer(std::string userId, std::string pwd, int roomId, int sdkAppId)
{
    std::wstring login_cgi = L"https://xxx"; //您的服务器地址
    int accountType = 14000;  //您可以在应用后台页面获取AccountType的值
    Json::Value jsonObj;
    jsonObj["pwd"] = pwd;
    jsonObj["appid"] = sdkAppId;
    jsonObj["roomnum"] = roomId;
    jsonObj["privMap"] = 255;
    jsonObj["accounttype"] = accountType;
    jsonObj["identifier"] = userId;
    Json::FastWriter writer;
    std::string jsonStr = writer.write(jsonObj);
    std::vector<std::wstring> headers;
    headers.push_back(L"Content-Type: application/json; charset=utf-8");

    std::string respData;
    std::wstring _cgi_url = login_cgi;
    DWORD ret = m_http_client.http_post(_cgi_url, headers, jsonStr, respData);
    if (0 != ret || true == respData.empty())
    {
        //请求失败,请检查参数或网络。
    }
    std::string _userSig;
    {
        Json::Reader reader;
        Json::Value root;
        if (!reader.parse(respData, root))
        {
            //返回Json信息错误
        }
        if (root.isMember("errorCode"))
        {
            int code = root["errorCode"].asInt();
            if (code != 0)
            {
                //登录返回参数错误
            }
            Json::Value data;
            if (root.isMember("data"))
            {
                data = root["data"];
                if (data.isMember("userSig"))
                    _userSig = data["userSig"].asString();
            }
        }
    }
    return _userSig;
}
