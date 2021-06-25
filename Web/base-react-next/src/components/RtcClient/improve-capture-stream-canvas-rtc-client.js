import RTC from '@components/BaseRTC';
import TRTC from 'trtc-js-sdk';

class Client extends RTC {
  constructor(options) {
    super(options);
    this.canvasElement = options.canvasElement;
    this.canvasAnimate();
  }

  async initLocalStream() {
    const stream = this.canvasElement.captureStream();
    const [audioTrack] = stream.getAudioTracks();
    const [videoTrack] = stream.getVideoTracks();
    this.localStream = TRTC.createStream({
      userId: this.userID,
      audioSource: audioTrack,
      videoSource: videoTrack,
    });
    await this.localStream.initialize();
    this.addStream && this.addStream(this.localStream);
    return this.localStream;
  }

  canvasAnimate() {
    const canvas = this.canvasElement;
    const context = canvas.getContext('2d');
    let flag = 1;
    let i = 0;
    let r = 90;

    function animate() {
      window.requestAnimationFrame(animate);
      draw();
    }

    function draw() {
      const dig = Math.PI / 120;
      const x = (Math.sin(i * dig) * r) + 130;
      const y = (Math.cos(i * dig) * r) + 95;

      context.fillStyle = flag ? 'rgb(10,255,255)' : 'rgb(255,100,0)';
      context.beginPath();
      context.arc(x, y, 3, 0, Math.PI * 2, true);
      context.closePath();
      context.fill();
      i = i + 1;
      if (i > 240) {
        i = 0;
        r = r - 20;
        flag = !flag;
        if (r <= 0) {
          context.clearRect(0, 0, canvas.width, canvas.height);
          r = 90;
        }
      }
    }
    animate();
  }
}

export default Client;
