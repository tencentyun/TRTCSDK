import RTC from '@components/BaseRTC';
import toast from '@components/Toast';
class Client extends RTC {
  constructor(options) {
    super(options);
    this.role = options.role;
  }

  async handleJoin() {
    if (this.isJoining || this.isJoined) {
      return;
    }
    this.isJoining = true;
    await this.initClient();
    try {
      await this.client.join({ roomId: this.roomID, role: this.role });
      toast.success('join room success!', 2000);

      this.isJoining = false;
      this.isJoined = true;
      this.setState && this.setState('join', this.isJoined);
      this.addUser && this.addUser(this.userID, 'local');

      this.startGetAudioLevel();
    } catch (error) {
      this.isJoining = false;
      toast.error('join room failed!', 20000);
      console.error('join room failed', error);
    }
  }

  async handlePublish(isManualChangeRole) {
    if (!this.isJoined || this.isPublishing || this.isPublished) {
      toast.success('please join room!', 2000);
      return false;
    }

    // live/audience need to switch role before publish
    if (this.mode !== 'live') {
      toast.error('client mode must be live, current client mode is rtc');
      return false;
    }

    if (isManualChangeRole) {
      if (this.role !== 'anchor') {
        toast.error('please change to Anchor');
        return false;
      }
    } else {
      await this.changeRole('anchor');
    }
    this.isPublishing = true;
    !this.localStream && await this.initLocalStream();
    try {
      this.client.publish(this.localStream);
      toast.success('publish localStream success!', 2000);

      this.isPublishing = false;
      this.isPublished = true;
      this.setState && this.setState('publish', this.isPublished);
      return true;
    } catch (error) {
      this.isPublishing = false;
      console.error('publish localStream failed', error);
      toast.error('publish localStream failed!', 2000);
      return false;
    }
  }

  async changeRole(targetRole) {
    if (!this.isJoined || this.isPublishing || this.isPublished) {
      toast.success('please join room!', 2000);
      return false;
    }

    try {
      if (this.mode === 'live') {
        await this.client.switchRole(targetRole);
        this.role = targetRole;
        return true;
      }
      return false;
    } catch (err) {
      return false;
    }
  }
}

export default Client;
