import RTC from '@components/BaseRTC';
import Toast from '@components/Toast';
class Client extends RTC {
  constructor(options) {
    super(options);
    this.streamID = options.streamID;
    this.appID = options.appID;
    this.bizID = options.bizID;
    this.publishCDNUrl = options.publishCDNUrl;
  }

  // eslint-disable-next-line camelcase
  UNSAFE_componentWillReceiveProps(props) {
    super.UNSAFE_componentWillReceiveProps(props);
    this.streamID = props.streamID;
    this.appID = props.appID;
    this.bizID = props.bizID;
    this.publishCDNUrl = props.publishCDNUrl;
  }

  // ref: https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/Client.html#startPublishCDNStream

  // example 1：“全局自动旁路”模式下，修改当前用户音视频流在腾讯云 CDN 对应的 StreamId
  // async handleStartPublishCDNStream() {
  //   if (!this.streamID) {
  //     Toast.error('please input streamID');
  //     return;
  //   }
  //   const options = { streamId: this.streamID };
  //   try {
  //     await this.client.startPublishCDNStream(options);
  //     Toast.success('start publishCDNStream success', 2000);
  //   } catch (error) {
  //     console.error('start publishCDNStream error', error);
  //     Toast.error('start publishCDNStream error', 2000);
  //   }
  // }

  // example 2：“指定流旁路”模式下，以默认 streamId: ${sdkAppId}_${roomId}_${userId}_main 发布当前用户音视频流到腾讯云 CDN
  // async handleStartPublishCDNStream() {
  //   try {
  //     await this.client.startPublishCDNStream();
  //     Toast.success('start publishCDNStream success', 2000);
  //   } catch (error) {
  //     console.error('start publishCDNStream error', error);
  //     Toast.error('start publishCDNStream error', 2000);
  //   }
  // }

  // example 3：“指定流旁路”模式下，以指定 streamId 发布当前用户音视频流到腾讯云 CDN
  // async handleStartPublishCDNStream() {
  //   if (!this.streamID) {
  //     Toast.error('please input streamID');
  //   }
  //   const options = { streamId: this.streamID };
  //   try {
  //     await this.client.startPublishCDNStream(options);
  //     Toast.success('start publishCDNStream success', 2000);
  //   } catch (error) {
  //     console.error('start publishCDNStream error', error);
  //     Toast.error('start publishCDNStream error', 2000);
  //   }
  // }

  // example 4: 将当前用户音视频流发布到指定的 CDN 地址
  // async handleStartPublishCDNStream() {
  //   if (!this.appID || !this.bizID || !this.publishCDNUrl) {
  //     Toast.error('please input appID, bizID, publishCDNUrl');
  //   }
  //   const options = {
  //     appId: parseInt(this.appID, 10),
  //     bizId: parseInt(this.bizID, 10),
  //     url: this.publishCDNUrl,
  //   };
  //   try {
  //     await this.client.startPublishCDNStream(options);
  //     Toast.success('start publishCDNStream success', 2000);
  //   } catch (error) {
  //     console.error('start publishCDNStream error', error);
  //     Toast.error('start publishCDNStream error', 2000);
  //   }
  // }

  // example 5: 修改当前用户音视频流在腾讯云 CDN 对应的 StreamId，并且发布当前用户音视频流到指定的 CDN 地址
  async handleStartPublishCDNStream() {
    if (!this.streamID || !this.appID || !this.bizID || !this.publishCDNUrl) {
      Toast.error('please input streamID, appID, bizID, publishCDNUrl');
      return;
    }
    const options = {
      streamId: this.streamID,
      appId: parseInt(this.appID, 10),
      bizId: parseInt(this.bizID, 10),
      url: this.publishCDNUrl,
    };
    try {
      await this.client.startPublishCDNStream(options);
      Toast.success('start publishCDNStream success', 2000);
    } catch (error) {
      console.error('start publishCDNStream error', error);
      Toast.error('start publishCDNStream error', 2000);
    }
  }


  // ref: https://web.sdk.qcloud.com/trtc/webrtc/doc/zh-cn/Client.html#stopPublishCDNStream
  async handleStopPublishCDNStream() {
    try {
      await this.client.stopPublishCDNStream();
      Toast.success('start publishCDNStream success', 2000);
    } catch (error) {
      console.error('start publishCDNStream error', error);
      Toast.error('start publishCDNStream error', 2000);
    }
  }
}

export default Client;
