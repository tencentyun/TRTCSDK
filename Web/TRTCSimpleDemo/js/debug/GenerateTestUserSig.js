/* eslint-disable require-jsdoc */
/*
 * Module:   GenerateTestUserSig
 *
 * Function：テスト用のUserSigを生成するために使用され、UserSigはTencent Cloudがクラウドサービスのために設計したセキュリティ保護署名の一種です。
 * 計算方法はSDKAppID、UserID、EXPIRETIMEを暗号化し、暗号化アルゴリズムはHMAC-SHA256です。
 *
 * 注意：以下の理由により、オンライン公式版のアプリに以下のコードを投稿しないでください。
 *
 * このドキュメントに記載されているコードは、UserSigを正しく計算することができますが、SDKの基本的な機能のクイックチューンナップにのみ適しており、オンライン製品のためのものではありません。
 * これは、クライアント側のコードに含まれるSECRETKEYは、逆コンパイルやリバースエンジニアリングが容易であり、特にWeb側では、コードを解読することの難易度がほぼゼロに近いためです。
 * 鍵が漏洩すると、攻撃者は正しいUserSigを計算してTencent Cloudのトラフィックを盗むことができます。
 *
 * 正しいアプローチは、UserSigの計算コードと暗号化キーをビジネスサーバーに置き、アプリがリアルタイムで計算されたUserSigをサーバーからオンデマンドで取得することです。
 * サーバーをクラックすることは、クライアントアプリをクラックするよりもコストがかかるため、サーバーコンピューティングソリューションは暗号化キーをより確実に保護します。
 *
 * 引用元: https://cloud.tencent.com/document/product/647/17275#Server
 */
function genTestUserSig(userID) {
  /**
   * テンセントクラウドのSDKAppIdは、ご自身のアカウントでSDKAppIdに置き換える必要があります。
   *
   * Tencent Cloud Real-time Audio and Video [console](https://console.cloud.tencent.com/rav )を入力してアプリケーションを作成すると、SDKAppIdが表示されます。
   * テンセントクラウドが顧客を区別するために使用する固有の識別子です。
   */
  const SDKAPPID = 0;

  /**
   * 署名の有効期限は、あまり短く設定することは推奨されません。
   * <p>
   * 時間単位：秒
   * デフォルト時間：7×24×60×60＝604800＝7日
   */
  const EXPIRETIME = 604800;

  /*
   * 署名の暗号化キーを計算するには、以下のようにします。
   *
   * ステップ1. Tencent Cloud Real-time Audio and Video [console](https://console.cloud.tencent.com/rav )を入力し、まだ適用していない場合は作成してください。
   * ステップ2. 「設定を適用する」をクリックして基本設定ページに入り、さらに「アカウントシステムの統合」セクションを検索します。
   * ステップ3. 「鍵を見る」ボタンをクリックすると、UserSig で使用されている暗号化を計算するために使用された鍵が表示されます。
   *
   * 暗号化キーの漏洩によるトラフィックの盗難を防ぐため、本番前にUserSigの計算コードとキーをバックエンドサーバーに移行してください。
   * ドキュメンテーション: https://cloud.tencent.com/document/product/647/17275#Server
   */
  const SECRETKEY = '';

  // sdkAppId/secretKeyを設定する際の注意点を説明。
  if (SDKAPPID === '' || SECRETKEY === '') {
    alert(
      'まずはアカウント情報の設定をお願いします： SDKAPPID と SECRETKEY ' +
        '\r\n\r\njs/debug/GenerateTestUserSig.js で SDKAPPID/SECRETKEY を設定してください'
    );
  }
  const generator = new LibGenerateTestUserSig(SDKAPPID, SECRETKEY, EXPIRETIME);
  const userSig = generator.genTestUserSig(userID);
  return {
    sdkAppId: SDKAPPID,
    userSig: userSig
  };
}
