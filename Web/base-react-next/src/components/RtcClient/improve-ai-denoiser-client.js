import RTC from '@components/BaseRTC';
import RTCAIDenoiser from 'rtc-ai-denoiser';
import { SDKAPPID } from '@app/config';
import toast from '@components/Toast';
import { publishFailedUpload, publishSuccessUpload } from '@utils/utils';

class Client extends RTC {
  constructor(options) {
    super(options);
    this.denoiser = new RTCAIDenoiser({ assetsPath: 'https://web.sdk.qcloud.com/trtc/webrtc/demo/api-sample/denoiser/' });
  }

  async handlePublish() {
    if (!this.isJoined || this.isPublishing || this.isPublished) {
      return;
    }
    this.isPublishing = true;
    !this.localStream && (await this.initLocalStream());

    try {
      if (this.denoiser.isSupported()) {
        this.processor = await this.denoiser.createProcessor({
          sdkAppId: SDKAPPID,
          userId: this.userID,
          userSig: this.userSig,
        });
        if (this.localStream) {
          await this.processor.process(this.localStream);
          await this.processor.enable();
        }
      }

      await this.client.publish(this.localStream);
      toast.success('publish localStream success!', 2000);
      publishSuccessUpload(SDKAPPID);

      this.isPublishing = false;
      this.isPublished = true;
      this.setState && this.setState('publish', this.isPublished);
    } catch (error) {
      this.isPublishing = false;
      console.error('publish localStream failed', error);
      toast.error('publish localStream failed!', 2000);
      publishFailedUpload(SDKAPPID, `${JSON.stringify(error.message)}`);
    }
  }

  async handleOpenDenoiser() {
    if (!this.processor.enabled) {
      await this.processor.enable();
    }
  }

  async handleCloseDenoiser() {
    if (this.processor.enabled) {
      await this.processor.disable();
    }
  }
}

export default Client;
