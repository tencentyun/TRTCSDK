import { useState, useEffect } from 'react';
import { useDispatch } from 'react-redux';
import { TRTCDeviceInfo } from 'trtc-electron-sdk/liteav/trtc_define';
import { trtcUtil } from '../../utils/trtc-edu-sdk';
import { updateCurrentDevice } from '../../store/user/userSlice';
import { USER_EVENT_NAME } from '../../../constants';

// To-do: 处理 onDeviceChange 事件
// To-do: 处理耳麦切换，切换其一，底层 LiteAV 会自动切换另一个
function useDevice() {
  const logPrefix = '[useDevice]';
  const [cameraList, setCameraList] = useState<Array<TRTCDeviceInfo>>([]);
  const [micList, setMicList] = useState<Array<TRTCDeviceInfo>>([]);
  const [speakerList, setSpeakerList] = useState<Array<TRTCDeviceInfo>>([]);
  const [currentCamera, setCurrentCamera] =
    useState<TRTCDeviceInfo | null>(null);
  const [currentMic, setCurrentMic] = useState<TRTCDeviceInfo | null>(null);
  const [currentSpeaker, setCurrentSpeaker] =
    useState<TRTCDeviceInfo | null>(null);

  const dispatch = useDispatch();

  const getMicList = () => {
    const micDevices = trtcUtil.trtcEducation?.rtcCloud.getMicDevicesList();
    setMicList(micDevices);
  };

  const getCurrentMic = () => {
    const currentMicDevice =
      trtcUtil.trtcEducation?.rtcCloud.getCurrentMicDevice();
    setCurrentMic(currentMicDevice);
  };

  const changeCurrentMic = (newDeviceId: string) => {
    trtcUtil.trtcEducation?.rtcCloud.setCurrentMicDevice(newDeviceId);
    const selected =
      micList.filter((item) => item.deviceId === newDeviceId)[0] || null;
    if (selected) {
      setCurrentMic(selected);
      dispatch(
        updateCurrentDevice({
          currentMic: selected,
        })
      );
      (window as any).electron.ipcRenderer.send(
        USER_EVENT_NAME.ON_CHANGE_LOCAL_USER_STATE,
        {
          currentMic: selected,
        }
      );
    }
  };

  const getCameraList = () => {
    const cameraDevices =
      trtcUtil.trtcEducation?.rtcCloud.getCameraDevicesList();
    setCameraList(cameraDevices);
  };

  const getCurrentCamera = () => {
    const currentCameraDevice =
      trtcUtil.trtcEducation?.rtcCloud.getCurrentCameraDevice();
    setCurrentCamera(currentCameraDevice);
  };

  const changeCurrentCamera = (newDeviceId: string) => {
    trtcUtil.trtcEducation?.rtcCloud.setCurrentCameraDevice(newDeviceId);
    const selected =
      cameraList.filter((item) => item.deviceId === newDeviceId)[0] || null;
    if (selected) {
      setCurrentCamera(selected);
      dispatch(
        updateCurrentDevice({
          currentCamera: selected,
        })
      );
      (window as any).electron.ipcRenderer.send(
        USER_EVENT_NAME.ON_CHANGE_LOCAL_USER_STATE,
        {
          currentCamera: selected,
        }
      );
    }
  };

  const getSpeakerList = () => {
    const speakerDevices =
      trtcUtil.trtcEducation?.rtcCloud.getSpeakerDevicesList();
    setSpeakerList(speakerDevices);
  };

  const getCurrentSpeaker = () => {
    const currentSpeakerDevice =
      trtcUtil.trtcEducation?.rtcCloud.getCurrentSpeakerDevice();
    setCurrentSpeaker(currentSpeakerDevice);
  };

  const changeCurrentSpeaker = (newDeviceId: string) => {
    trtcUtil.trtcEducation?.rtcCloud.setCurrentSpeakerDevice(newDeviceId);
    const selected =
      speakerList.filter((item) => item.deviceId === newDeviceId)[0] || null;
    if (selected) {
      setCurrentSpeaker(selected);
      dispatch(
        updateCurrentDevice({
          currentSpeaker: selected,
        })
      );
      (window as any).electron.ipcRenderer.send(
        USER_EVENT_NAME.ON_CHANGE_LOCAL_USER_STATE,
        {
          currentSpeaker: selected,
        }
      );
    }
  };

  useEffect(() => {
    const refreshDevice = () => {
      console.warn(`${logPrefix}.refreshDevice`);
      getMicList();
      getCameraList();
      getCurrentMic();
      getCurrentCamera();
      getSpeakerList();
      getCurrentSpeaker();
    };

    refreshDevice();
  }, []);

  return {
    currentCamera,
    cameraList,
    setCurrentCamera,
    setCameraList,
    changeCurrentCamera,
    currentMic,
    micList,
    setCurrentMic,
    setMicList,
    changeCurrentMic,
    currentSpeaker,
    speakerList,
    setCurrentSpeaker,
    setSpeakerList,
    changeCurrentSpeaker,
  };
}

export default useDevice;
