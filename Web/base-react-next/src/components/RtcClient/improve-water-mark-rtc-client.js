import RTC from '@components/BaseRTC.js';
import UAParser from 'ua-parser-js';

export default class RTCClient extends RTC {
  constructor(options) {
    super(options);

    this.mirror = false;
    this.localStreamWithWaterMark = null;
    this.videoElement = null;
    this.sourceVideoTrack = null;
    this.intervalId = -1;

    const os = new UAParser().getOS();
    this.IS_IOS_BEFORE_15 = os.name === 'iOS' && os.version.split('.')[0] < 15;
  }

  loadImage({ imageUrl, width, height }) {
    return new Promise((resolve) => {
      const image = new Image(width, height);
      image.src = imageUrl;
      image.onload = () => resolve(image);
    });
  }

  async startWaterMark({ localStream, imageUrl, x, y, width, height, mode, rotate = 0, alpha = 1 }) {
    if (this.localStreamWithWaterMark) {
      throw 'watermark had been added';
    }
    if (!localStream || !localStream.hasVideo()) {
      throw 'local stream has not video track';
    }
    // 1. 创建 video 播放 localStream.getVideoTrack()，用于将视频渲染至 canvas 中
    this.videoElement = document.createElement('video');
    const mediaStream = new MediaStream();
    this.sourceVideoTrack = localStream.getVideoTrack();
    mediaStream.addTrack(this.sourceVideoTrack);
    this.videoElement.playsInline = true;
    this.videoElement.muted = true;
    this.videoElement.srcObject = mediaStream;
    await this.videoElement.play();
    // 2. 加载水印图片
    const image = await this.loadImage({ imageUrl, width, height });

    // 3. 创建 canvas
    const canvas = document.createElement('canvas');
    this.canvas = canvas;
    const ctx = canvas.getContext('2d');
    const { width: trackWidth, height: trackHeight, frameRate } = this.sourceVideoTrack.getSettings();
    canvas.width = trackWidth;
    canvas.height = trackHeight;

    // 4. 渲染 canvas
    this.intervalId = setInterval(() => {
      ctx.drawImage(this.videoElement, 0, 0, canvas.width, canvas.height);

      ctx.globalAlpha = alpha;
      ctx.rotate((rotate * Math.PI) / 180);
      if (mode === 'cover') {
        const xCount = Math.ceil(canvas.width / image.width);
        const yCount = Math.ceil(canvas.height / image.height);
        for (let i = -xCount; i < xCount + 5; i++) {
          for (let j = -yCount; j < yCount + 5; j++) {
            ctx.drawImage(image, i * image.width, j * image.height, image.width, image.height);
          }
        }
      } else {
        ctx.drawImage(image, x, y, image.width, image.height);
      }
      ctx.rotate((-rotate * Math.PI) / 180);
      ctx.globalAlpha = 1;
    }, Math.floor(1000 / frameRate));

    if (this.IS_IOS_BEFORE_15) {
      // 将 canvas 放置到 DOM 中渲染。
      canvas.style.width = '100%';
      canvas.style.height = '100%';
      canvas.style.objectFit = 'cover';
      // dom 为 localStream.play(elementId) 传入的 dom 对象
      this.dom.appendChild(canvas);
      // 停止播放
      localStream.stop();
    }

    // 5. 从 canvas 中捕获视频流，并替换到 localStream 中
    const canvasStream = canvas.captureStream();
    await localStream.replaceTrack(canvasStream.getVideoTracks()[0]);

    this.localStreamWithWaterMark = localStream;
    return localStream;
  }

  stopWaterMark() {
    clearInterval(this.intervalId);
    this.intervalId = -1;
    if (this.localStreamWithWaterMark && this.sourceVideoTrack) {
      this.localStreamWithWaterMark.replaceTrack(this.sourceVideoTrack);
    }

    if (this.IS_IOS_BEFORE_15) {
      this.dom.removeChild(this.canvas);
      this.canvas = null;
      this.localStreamWithWaterMark.play(this.dom);
    }

    this.localStreamWithWaterMark = null;
    if (this.videoElement) {
      this.videoElement.srcObject = null;
      this.videoElement = null;
    }
  }
}
