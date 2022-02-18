import RTC from '@components/BaseRTC.js';
import RTCBeautyPlugin from 'rtc-beauty-plugin';
import toast from '@components/Toast';
import { publishUpload } from '@utils/utils';
import { SDKAPPID } from '@app/config';

export default class RTCClient extends RTC {
  async handlePublish() {
    if (!this.isJoined || this.isPublishing || this.isPublished) {
      return;
    }
    this.isPublishing = true;
    !this.localStream && (await this.initLocalStream());
    try {
      this.beautyPlugin = new RTCBeautyPlugin();
      this.beautyPlugin.setBeautyParam({ beauty: 0.5, brightness: 0.5, ruddy: 0.5 });
      const stream = this.beautyPlugin.generateBeautyStream(this.localStream);
      await this.client.publish(stream);
      toast.success('publish localStream success!', 2000);
      publishUpload(SDKAPPID);

      this.isPublishing = false;
      this.isPublished = true;
      this.setState && this.setState('publish', this.isPublished);
    } catch (error) {
      this.isPublishing = false;
      console.error('publish localStream failed', error);
      toast.error('publish localStream failed!', 2000);
    }
  }
}
