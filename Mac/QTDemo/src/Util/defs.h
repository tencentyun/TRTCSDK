//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef QTMACDEMO_BASE_DEFS_H_
#define QTMACDEMO_BASE_DEFS_H_

/**
 * 腾讯云 SDKAppId，需要替换为您自己账号下的 SDKAppId。
 *
 * 进入腾讯云实时音视频[控制台](https://console.cloud.tencent.com/rav) 创建应用，即可看到 SDKAppId，
 * 它是腾讯云用于区分客户的唯一标识。
 */

/**
 * Tencent Cloud SDKAppID. Set it to the SDKAppID of your account.
 *
 * You can view your SDKAppID after creating an application in the [TRTC console](https://console.intl.cloud.tencent.com/rav).
 * SDKAppID uniquely identifies a Tencent Cloud account.
 */
static const int SDKAppID = PLACEHOLDER;

/**
 * 计算签名用的加密密钥，获取步骤如下：
 *
 * step1. 进入腾讯云实时音视频[控制台](https://console.cloud.tencent.com/rav)，如果还没有应用就创建一个，
 * step2. 单击您的应用，并进一步找到“快速上手”部分。
 * step3. 点击“查看密钥”按钮，就可以看到计算 UserSig 使用的加密的密钥了，请将其拷贝并复制到如下的变量中
 *
 * 注意：该方案仅适用于调试Demo，正式上线前请将 UserSig 计算代码和密钥迁移到您的后台服务器上，以避免加密密钥泄露导致的流量盗用。
 * 文档：https://cloud.tencent.com/document/product/647/17275#Server
 */

/**
 * Follow the steps below to obtain the key required for UserSig calculation.
 *
 * Step 1.  Log in to the [TRTC console](https://console.intl.cloud.tencent.com/rav), and create an application if you don’t have one.
 * Step 2.  Find your application, click "Application Info", and select the "Quick Start" tab.
 * Step 3.  Copy and paste the key to the code, as shown below.
 *
 * Notes:  This method is for testing only. Before commercial launch, please migrate the UserSig calculation code and key to your backend server to prevent key disclosure and traffic theft.
 * Documentation: https://intl.cloud.tencent.com/document/product/647/35166#Server
 */
static const char* SECRETKEY = "PLACEHOLDER";

/**
 *  签名过期时间，建议不要设置得过短
 *
 *  时间单位：秒
 *  默认时间：7 x 24 x 60 x 60 = 604800 = 7 天
 */

/**
 *  Signature validity period, which should not be set too short
 *
 *  Unit: seconds
 *  Default value: 604800 (7 days)
 */
static const int EXPIRETIME = 604800;

/**
 *  CDN直播观看域名设置：
 *
 *  只有在您已经开通了直播服务并配置了播放域名的情况下，才能通过 CDN 正常观看转推到腾讯云上的直播流。
 *  获取可以转推成功，并在线播放的CDN地址，可参考：
 *  1. 实现CDN直播观看：https://cloud.tencent.com/document/product/647/16826
 *  2. 添加自有域名：https://cloud.tencent.com/document/product/267/20381
 */

/**
 *  Configuring domain names for CDN playback:
 *
 *  You can play live streams relayed to Tencent Cloud via CDNs only after you have activated CSS and configured a playback domain name.
 *  To obtain a valid URL for relayed push and CDN playback, refer to the documents below:
 *  1.  CDN Relayed Live Streaming: https://intl.cloud.tencent.com/document/product/647/35242
 *  2.  Adding Domain Name: https://intl.cloud.tencent.com/document/product/267/35970
 */
static const char* DOMAIN_URL = "PLACEHOLDER";

enum ControlButtonType {
    Audio = 0,
    Video = 1,
};

#endif  // QTMACDEMO_BASE_DEFS_H_