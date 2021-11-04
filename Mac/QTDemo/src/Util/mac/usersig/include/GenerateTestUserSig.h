class GenerateTestUserSig
{
/**
 * 计算 UserSig 签名
 *
 * UserSig 由 HMAC SHA256 加密算法计算得出，本质是对 SDKAppID、UserID、ExpireTime 等关键信息进行了一次哈希加密。
 *
 * @note: 请不要将如下代码发布到您的线上正式版本的 App 中，原因如下：
 *
 * 本文件中的代码虽然能够正确计算出 UserSig，但仅适合快速调通 SDK 的基本功能，不适合线上产品，
 * 这是因为客户端代码中的 SECRETKEY 很容易被反编译逆向破解，尤其是 Web 端的代码被破解的难度几乎为零。
 * 一旦您的密钥泄露，攻击者就可以计算出正确的 UserSig 来盗用您的腾讯云流量。
 *
 * 正确的做法是将 UserSig 的计算代码和加密密钥放在您的业务服务器上，然后由 App 按需向您的服务器获取实时算出的 UserSig。
 * 由于破解服务器的成本要高于破解客户端 App，所以服务器计算的方案能够更好地保护您的加密密钥。
 *
 * 文档：https://cloud.tencent.com/document/product/647/17275#Server
 */

/** 
 * UserSig Calculation
 * 
 * UserSig is a security signature calculated using the HMAC SHA256 encryption algorithm.
 * Basically, it involves hashing crucial information such as SDKAppID, UserID, and ExpireTime.
 * 
 * @note:  Do not use the code below in your commercial application. This is because:
 * 
 * The code may be able to calculate UserSig correctly, but it is only for quick testing of the SDK’s basic features, not for commercial applications.
 * SECRETKEY in client code can be easily decompiled and reversed, especially on web.
 * Once your key is disclosed, attackers will be able to steal your Tencent Cloud traffic.
 * 
 * The correct method is to deploy the UserSig calculation code and encryption key on your project server so that your application can request from your server a UserSig that is calculated whenever one is needed.
 * Given that it is more difficult to hack a server than a client application, server-end calculation can better protect your key.
 * 
 * Documentation:  https://intl.cloud.tencent.com/document/product/647/35166#Server
 */

public:
   static const char* genTestUserSig(const char* identifier, int sdkAppId, const char* secretKey);
};

