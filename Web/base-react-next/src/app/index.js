/**
 * Attention: 请不要将如下代码发布到您的线上正式版本的 App 中，原因如下：
 *
 *  本文件中的代码虽然能够正确计算出 UserSig，但仅适合快速调通 SDK 的基本功能，不适合线上产品，
 *  这是因为客户端代码中的 SECRETKEY 很容易被反编译逆向破解，尤其是 Web 端的代码被破解的难度几乎为零。
 *  一旦您的密钥泄露，攻击者就可以计算出正确的 UserSig 来盗用您的腾讯云流量。
 *
 *  正确的做法是将 UserSig 的计算代码和加密密钥放在您的业务服务器上，然后由 App 按需向您的服务器获取实时算出的 UserSig。
 *  由于破解服务器的成本要高于破解客户端 App，所以服务器计算的方案能够更好地保护您的加密密钥。
 *  文档：https://cloud.tencent.com/document/product/647/17275#Server
 */
import { SDKAPPID, SECRETKEY, EXPIRETIME } from '@app/config';
import LibGenerateTestUserSig from '@app/lib-generate-test-usersig.min.js';

// a soft reminder to guide developer to configure sdkAppId/secretKey
if (SDKAPPID === '' || SECRETKEY === '') {
  alert('请先配置好您的账号信息： SDKAPPID 及 SECRETKEY '
    + '\r\n\r\nPlease configure your SDKAPPID/SECRETKEY in src/app/config.js');
}

const generator = new LibGenerateTestUserSig(SDKAPPID, SECRETKEY, EXPIRETIME);

/**
 * 获取 userSig 和 privateMapKey
 * @param {string} userID 用户名
 */
export async function getLatestUserSig(userID) {
  const userSig = generator.genTestUserSig(userID);
  return {
    userSig,
    privateMapKey: 255,
  };
}
