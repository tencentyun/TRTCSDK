import React, { useEffect } from 'react';
import a18n from 'a18n';
import TRTC from 'trtc-js-sdk';

const getDeviceList = async (deviceType) => {
  let deviceList = [];
  switch (deviceType) {
    case 'camera':
      deviceList = await TRTC.getCameras();
      break;
    case 'microphone':
      deviceList = await TRTC.getMicrophones();
      break;
    case 'speaker':
      deviceList = await TRTC.getSpeakers();
      break;
    default:
      break;
  }
  return deviceList;
};

export default function DeviceData({ deviceType, updateDeviceList, updateActiveDeviceId }) {
  useEffect(async () => {
    try {
      const mediaStream = await navigator.mediaDevices.getUserMedia({ audio: deviceType === 'microphone', video: deviceType === 'camera' });
      mediaStream.getTracks()[0].stop();
    } catch (error) {
      if (error.name === 'NotAllowedError') {
        alert(a18n`请允许网页访问${deviceType === 'microphone' ? a18n('麦克风') : a18n('摄像头')}的权限！`);
      } else if (error.name === 'NotFoundError') {
        alert(a18n`请检查${deviceType === 'microphone' ? a18n('麦克风') : a18n('摄像头')}设备连接是否正常！`);
      } else if (error.name === 'NotReadableError') {
        alert(a18n`请检查${deviceType === 'microphone' ? a18n('麦克风') : a18n('摄像头')}设备是否被其它应用占用或未授权应用权限！`);
      }
    }

    const list = await getDeviceList(deviceType);
    updateDeviceList && updateDeviceList(list);
    const activeDeviceId = (list[0] && list[0].deviceId) || '';
    updateActiveDeviceId && updateActiveDeviceId(activeDeviceId);
  }, []);

  navigator.mediaDevices.addEventListener('devicechange', async () => {
    const newList = await getDeviceList(deviceType);
    updateDeviceList && updateDeviceList(newList);
  });

  return (
    <div></div>
  );
}
