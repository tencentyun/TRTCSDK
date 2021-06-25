import RTC from '@components/BaseRTC';
import Toast from '@components/Toast';
import { SDKAPPID } from '@app/config';
import TRTC from 'trtc-js-sdk';

class Client extends RTC {
  constructor(options) {
    super(options);
    this.proxyServer = options.proxyServer;
    this.turnURL = options.turnURL;
    this.username = options.username;
    this.password = options.password;
  }

  // eslint-disable-next-line camelcase
  UNSAFE_componentWillReceiveProps(props) {
    super.UNSAFE_componentWillReceiveProps(props);
    this.proxyServer = props.proxyServer;
    this.turnURL = props.turnURL;
    this.username = props.username;
    this.password = props.password;
  }

  // 初始化客户端
  async initClient() {
    await this.getUserSig();

    this.client = TRTC.createClient({
      mode: this.mode,
      sdkAppId: SDKAPPID,
      userId: this.userID,
      userSig: this.userSig,
      useStringRoomId: this.useStringRoomID,
    });

    this.proxyServer && this.client.setProxyServer(this.proxyServer);
    Toast.success('set Proxy Server success', 2000);
    if (this.turnURL && this.username && this.password) {
      this.client.setTurnServer([{
        url: this.turnURL,
        username: this.username,
        credential: this.password,
      }]);
      Toast.success('set Turn Server success', 2000);
    }
    this.handleClientEvents();
    return this.client;
  }
}

export default Client;
