import RTC from '@components/BaseRTC';
import toast from '@components/Toast';

class Client extends RTC {
  async handlePublish(videoBitRate = 480) {
    if (!this.isJoined || this.isPublished) {
      return;
    }
    await this.initLocalStream();

    await this.localStream.setVideoProfile({
      width: 640,
      height: 480,
      frameRate: 15,
      bitrate: videoBitRate,
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
