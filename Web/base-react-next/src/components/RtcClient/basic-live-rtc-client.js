import RTC from '@components/BaseRTC';
import toast from '@components/Toast';
import { joinRoomUpload } from '@utils/utils';
import { SDKAPPID } from '@app/config';
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
      joinRoomUpload(SDKAPPID);

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
}

export default Client;
