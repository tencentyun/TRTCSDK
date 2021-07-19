import React, { useEffect, useState } from 'react';
import dynamic from 'next/dynamic';
import DeviceDetector from './index.js';
import { getLatestUserSig } from '@app/index.js';
import { SDKAPPID } from '@app/config.js';

const DynamicDeviceDetector = dynamic(import('rtc-device-detector-react'), { ssr: false });

export default function Detector({ language }) {
  const [networkDetectInfo, setNetworkDetectInfo] = useState({});
  const [visible, setVisible] = useState(false);
  const [hasNetworkDetect, setHasNetworkDetect] = useState(false);

  useEffect(() => {
    DeviceDetector.show = () => {
      setVisible(true);
    };
    DeviceDetector.hide = () => {
      setVisible(false);
    };
  }, []);

  useEffect(() => {
    async function getNetworkDetectInfo() {
      const uplinkUserId = 'uplink_test';
      const { userSig: uplinkUserSig } = await getLatestUserSig(uplinkUserId);
      const downlinkUserId = 'downlink_test';
      const { userSig: downlinkUserSig } = await getLatestUserSig(downlinkUserId);
      const roomId = 999999999;
      const networkDetectInfo =  {
        sdkAppId: SDKAPPID,
        roomId,
        uplinkUserInfo: {
          uplinkUserId,
          uplinkUserSig,
        },
        downlinkUserInfo: {
          downlinkUserId,
          downlinkUserSig,
        },
      };
      console.log('networkDetectInfo', networkDetectInfo);
      setNetworkDetectInfo(networkDetectInfo);
    }
    const isLoginPage = location.pathname === '/login' || location.pathname.slice(location.pathname.lastIndexOf('/')) === '/login.html';
    if (isLoginPage) {
      setHasNetworkDetect(false);
    } else {
      setHasNetworkDetect(true);
      getNetworkDetectInfo();
    }
  }, []);

  useEffect(() => {
    const lastTime = localStorage.getItem('trtc-last-device-detector-time');
    const newTime = Date.now();
    if (!lastTime || newTime - lastTime > 24 * 60 * 60 * 1000) {
      localStorage.setItem('trtc-last-device-detector-time', newTime);
      setVisible(true);
    }
  }, []);

  return (
    <DynamicDeviceDetector
      visible={visible}
      onClose={() => setVisible(false)}
      lang={language}
      hasNetworkDetect={hasNetworkDetect}
      networkDetectInfo={networkDetectInfo}></DynamicDeviceDetector>
  );
}
