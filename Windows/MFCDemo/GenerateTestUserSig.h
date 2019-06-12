#pragma once
/*
* Module:   TRTCGetUserIDAndUserSig
*
* Function: 用于获取组装 TRTCParam 所必须的 UserSig，腾讯云使用 UserSig 进行安全校验，保护您的 TRTC 流量不被盗用
*/

#include <string>
#include <vector>
#include <stdint.h>
#include "http/HttpClient.h"
struct UserInfo
{
    std::string userId;
    std::string userSig;
};

/*
*  腾讯云账号信息，您需要补齐相关账号信息，才能运行体验Demo。
*/
struct TXCloudAccountInfo
{
    /*
    *  TRTCDuilibDemo源码 登录进房需要，如 GenerateTestUserSig->getUserSigFromServer接口。
    *  获取途径：腾讯云网页控制台->实时音视频->应用信息面板可以获取sdkAppId。
    */
    int _sdkAppId = 0;

    /*
    *  TRTCDuilibDemo 本地获取 usersig 需求，如 GenerateTestUserSig->getUserSigFromLocal
    *  获取途径：腾讯云网页控制台（https://console.cloud.tencent.com/rav）->实时音视频->快速上手可以获取签发UserSig私钥文件。
    *  
    *  WARNING: 请防止此私钥泄露，会造成计费盗用，建议把签名放到服务器(getUserSigFromServer)
    *  签名原理参考文档: https://cloud.tencent.com/document/product/647/17275#GetForDebug
    *
    *  NOTE: 【此处是一个“无效”的私钥样例，仅仅代码编写参考】
    */
    const char* _PRIVATEKEY = "-----BEGIN PRIVATE KEY-----\n"
        "MIGHAgEAMBM  “无效”的私钥样例，仅仅代码编写参考   GBB6RtS7EMWX\n"
        "nnXrYKui2gM  “无效”的私钥样例，仅仅代码编写参考   IlzTwqs0DD03\n"
        "ELuZK8EIQWA  “无效”的私钥样例，仅仅代码编写参考   pBKP\n"
        "-----END PRIVATE KEY-----\n";

    /*
     *  官方提供获取usersign的cgi地址仅给官网体验demo使用(后台每天定时关机)，您需要替换你的签名服务cgi地址。
    */
    std::wstring _loginServer = L"https://www.qcloudtrtc.com/sxb_dev/?svc=account&cmd=authPrivMap";

    /*
    *  TRTCDuilibDemo源码 TRTCCloudCore.h->updateMixTranCodeInfo 混流接口功能实现需要补齐此账号信息。
    *  获取途径：腾讯云网页控制台->实时音视频->您的应用(eg客服通话)->账号信息面板可以获取appid/bizid
    */
    int _appId      = 0;
    int _bizId      = 0;
};

class GenerateTestUserSig
{
protected:
    GenerateTestUserSig();
    GenerateTestUserSig(const GenerateTestUserSig&);
    GenerateTestUserSig operator =(const GenerateTestUserSig&);
public:
    ~GenerateTestUserSig();
    static GenerateTestUserSig& instance();
    uint32_t getSdkAppId() const;

    /**
    * 通过本地计算获取 userid 和 usersig。
    * 调用此函数前，需要先填写相关的腾讯云账号私钥信息到: TXCloudAccountInfo._sdkAppId 和 TXCloudAccountInfo._PRIVATEKEY。
    *
    * 该方案仅适合本地跑通demo和功能调试，产品真正上线发布，要使用服务器获取方案避免私钥被破解。
    */
    std::string getUserSigFromLocal(std::string userId) const;

    /**
    * 通过 http 请求到客户的业务服务器上获取 userid 和 usersig
    * 这种方式可以将签发 usersig 的计算工作放在您的业务服务器上进行，这样一来，usersig 的签发工作就可以安全可控
    *
    * 但本demo中的 getUserSigFromServer 函数仅作为示例代码，要跑通该逻辑，您需要参考：https://cloud.tencent.com/document/product/647/17275#GetFromServer
    */
    //此示例代码仅供参考
    std::string getUserSigFromServer(std::string userId, int roomId);
public:
    // 获取腾讯云实时音视频账号配置信息。详情参考： SdkAppInfo 定义
    TXCloudAccountInfo getTXCloudAccountInfo() const {  return m_AccountInfo; };
private:
    TXCloudAccountInfo m_AccountInfo;
private:
    HttpClient m_http_client;
};
