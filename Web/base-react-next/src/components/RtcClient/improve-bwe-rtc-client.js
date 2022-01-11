import RTC from '@components/BaseRTC';
import toast from '@components/Toast';

class Client extends RTC {
  async handlePublish(options) {
    if (!this.isJoined || this.isPublished) {
      return;
    }
    await this.initLocalStream();

    await this.localStream.setVideoProfile({
      width: (options && options.videoWidth) || 640,
      height: (options && options.videoHeight) || 480,
      frameRate: (options && options.videoFps) || 15,
      bitrate: (options && options.videoBitRate) || 900,
    });

    try {
      this.client.publish(this.localStream);
      toast.success('publish localStream success!', 2000);

      this.isPublished = true;
      this.setState && this.setState('publish', this.isPublished);
    } catch (error) {
      console.error('publish localStream failed', error);
      toast.error('publish localStream failed!', 2000);
    }
  }
}

export default Client;
