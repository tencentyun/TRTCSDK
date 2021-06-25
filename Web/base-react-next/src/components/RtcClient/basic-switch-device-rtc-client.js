import RTC from '@components/BaseRTC';
import toast from '@components/Toast';

class Client extends RTC {
  async switchDevice(type, deviceID) {
    await this.localStream.switchDevice(type, deviceID);
    toast.success(`switch ${type} device success`, 2000);
  }
}

export default Client;
