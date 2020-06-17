import {
  TRTCVideoEncParam,
  TRTCVideoResolution,
  TRTCVideoResolutionMode,
  TRTCBeautyStyle,
} from "trtc-electron-sdk/liteav/trtc_define";
export class BDVideoEncode {
  constructor(trtc) {
    this.trtc = trtc;
    this.encParam = new TRTCVideoEncParam();
    this.encParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_640_360;
    this.encParam.resMode = TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape;
    this.encParam.videoFps = 25;
    this.encParam.videoBitrate = 800;
    this.encParam.enableAdjustRes = true;
  }
  get help() {
    let helpOpt =  {
      'videoResolution': {
        type: Object.values(TRTCVideoResolution),
        current: this.encParam.videoResolution,
      },
      'resMode': {
        type: Object.values(TRTCVideoResolutionMode),
        current: this.encParam.resMode,
      },
      'videoFps': {
        type: 'number',
        current: this.encParam.videoFps,
      },
      'videoBitrate': {
        type: 'number',
        current: this.encParam.videoBitrate,
      },
      'enableAdjustRes': {
        type: 'boolean',
        current: this.encParam.enableAdjustRes,
      },
    };
    console.log(helpOpt);
    return helpOpt;
  }

  update() {
    console.log('setVideoEncoderParam',this.encParam);
    this.trtc.setVideoEncoderParam(this.encParam);
  }

  set videoResolution(value) {
    this.encParam.videoResolution = parseInt(value);
    this.update();
  }
  set resMode(value) {
    this.encParam.resMode = parseInt(value);
    this.update();
  }
  set videoFps(value) {
    this.encParam.videoFps = parseInt(value);
    this.update();
  }
  set videoBitrate(value) {
    this.encParam.videoBitrate = parseInt(value);
    this.update();
  }
  set enableAdjustRes(value) {
    this.encParam.videoBitrate = parseInt(value);
    this.update();
  }
}

export class BDBeauty {
  constructor(trtc) {
    this.trtc = trtc;
    this._style = TRTCBeautyStyle.TRTCBeautyStyleNature
    this._beauty = 5;
    this._white = 5;
    this._ruddiness = 5;
  }
  get help() {
    let helpOpt = {
      style: {
        type: Object.values(TRTCBeautyStyle),
        current: this._style,
      },
      beauty: {
        type: 'number',
        current: this._beauty,
      },
      white: {
        type: 'number',
        current: this._white,
      },
      ruddiness: {
        type: 'number',
        current: this._ruddiness,
      },
    };
    console.log(helpOpt);
    return helpOpt;
  }
  update() {
    this.trtc.setBeautyStyle(this._style, this._beauty, this._white, this._ruddiness);
  }

  set style(value) {
    this._style = parseInt(value);
    this.update();
  }
  
  set beauty(value) {
    this._beauty = parseInt(value);
    this.update();
  }


  set white(value) {
    this._white = parseInt(value);
    this.update();
  }
  set ruddiness(value) {
    this._ruddiness = parseInt(value);
    this.update();
  }
}
