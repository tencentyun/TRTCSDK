import axios from 'axios';
const LIVE_ROOM_SERVICE= 'https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/forTest';
const APP_NAME = 'trtc-electron-simple-demo:live';
export const createLiveRoom = function (roomId) {
  if (!roomId) {
    return Promise.reject('roomId');
  }
  return axios.request({
      url: LIVE_ROOM_SERVICE,
      method: 'get',
      params: {
        method: 'createRoom',
        appId: APP_NAME,
        type: '1',
        roomId: roomId.toString()
      }
  });
}

export const getLiveRoomList = function () {
  return axios.request({
    url: LIVE_ROOM_SERVICE,
    method: 'get',
    params: {
      method: 'getRoomList',
      appId: APP_NAME,
      type: '1',
    },
  });
}

export const destroyLiveRoom = function  (roomId) {
  if (!roomId) {
    return Promise.reject('need roomId');
  }
  return axios.request({
    url: LIVE_ROOM_SERVICE,
    method: 'get',
    params: {
      method: 'destroyRoom',
      appId: APP_NAME,
      roomId: roomId.toString(),
      type: '1',
  }
});
}