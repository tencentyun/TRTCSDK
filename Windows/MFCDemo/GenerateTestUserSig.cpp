/*
* Module:   TRTCGetUserIDAndUserSig
*
* Function: 用于获取组装 TRTCParam 所必须的 UserSig，腾讯云使用 UserSig 进行安全校验，保护您的 TRTC 流量不被盗用
*/

#include "GenerateTestUserSig.h"
#include "json/json.h"
#include <stdio.h>

#ifdef _WIN64
#else
    #include "tls_signature.h"
#endif // WIN64

GenerateTestUserSig::GenerateTestUserSig()
    : m_http_client(L"User-Agent")
{

}

GenerateTestUserSig::~GenerateTestUserSig()
{

}

GenerateTestUserSig& GenerateTestUserSig::instance()
{
    static GenerateTestUserSig uniqueInstance;
    return uniqueInstance;
}

uint32_t GenerateTestUserSig::getSdkAppId() const
{
    return m_AccountInfo._sdkAppId; 
}

std::string GenerateTestUserSig::getUserSigFromLocal(std::string userId) const
{
    //暂时不支持64位的本地签名库。
    std::string sig;
#ifdef _WIN64
#else
    gen_sig(m_AccountInfo._sdkAppId, userId, m_AccountInfo._PRIVATEKEY, sig);
#endif // WIN64
    return sig;
}


std::string GenerateTestUserSig::getUserSigFromServer(std::string userId, int roomId)
{
    std::wstring login_cgi = m_AccountInfo._loginServer;

    //int accountType = 14418;  //您可以在应用后台页面获取AccountType的值
    Json::Value jsonObj;
    jsonObj["pwd"] = "123";
    jsonObj["appid"] = m_AccountInfo._sdkAppId;
    jsonObj["roomnum"] = roomId;
    jsonObj["privMap"] = 255;
    //jsonObj["accounttype"] = accountType;
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
        return std::string("");
    }
    std::string _userSig = "";
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
                return std::string("");;
            }
            Json::Value data;
            if (root.isMember("data"))
            {
                data = root["data"];
                if (data.isMember("userSig"))
                    _userSig = data["userSig"].asString();
                //if (data.isMember("token"))
                //    m_SdkAppInfo._token = data["token"].asString();
                //if (data.isMember("privMapEncrypt"))
                //    m_SdkAppInfo._privMapEncrypt = data["privMapEncrypt"].asString();
            }
        }
    }
    return _userSig;
}
