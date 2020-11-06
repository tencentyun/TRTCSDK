import TRTCCalling from 'trtc-calling-js';
import config from '../config';

export function createTrtcCalling() {
  return new TRTCCalling({
    SDKAppID: config.SDKAppID
  });
}
