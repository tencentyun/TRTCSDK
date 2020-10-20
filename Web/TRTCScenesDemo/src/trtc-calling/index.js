import TrtcCalling from 'trtc-calling-js';
import config from '../config';

export function createTrtcCalling() {
  return TrtcCalling.create({
    SDKAppID: config.SDKAppID
  });
}
