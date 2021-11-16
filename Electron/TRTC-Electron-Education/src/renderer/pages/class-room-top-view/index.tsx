import React, { useState, useEffect, useCallback } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import {
  Rect,
  TRTCVideoStreamType,
  TRTCVideoEncParam,
  TRTCVideoResolution,
  TRTCVideoResolutionMode,
} from 'trtc-electron-sdk/liteav/trtc_define';
import useClassMember from 'renderer/hooks/use-class-member';
import { USER_EVENT_NAME } from '../../../constants';
import useDevice from '../../hooks/use-device';
import ComVideoList from '../../components/com-video-list';
import ClassTool from '../../components/com-class-tool';
import { trtcUtil } from '../../utils/trtc-edu-sdk/index';
import {
  updateCurrentDevice,
  updateDeviceState,
  updateAllStudentMuteState,
  updateAllStudentRollState,
  updateRollState,
} from '../../store/user/userSlice';

import './index.scss';

function ClassRoomTopView() {
  const logPrefix = '[class-room-top-view]';
  const [handsList, setHandsList] = useState<Array<string>>([]);
  const dispatch = useDispatch();
  const currentUser = useSelector((state: any) => state.user);
  const {
    currentMic: currentMicInStore,
    currentCamera: currentCameraInStore,
    currentSpeaker: currentSpeakerInStore,
    isAllStudentMuted,
    callRollTime,
    roomID,
    platform,
    enterRoomTime,
    isRolled,
  } = currentUser;

  const {
    cameraList,
    currentCamera,
    changeCurrentCamera,
    micList,
    currentMic,
    changeCurrentMic,
    speakerList,
    currentSpeaker,
    changeCurrentSpeaker,
  } = useDevice();
  // const { remoteUserMap } = useRemoteUsers();
  const { classMembersMap } = useClassMember();

  const updateMicMuteState = (mute: boolean) => {
    trtcUtil.trtcEducation?.rtcCloud.muteLocalAudio(mute);
    dispatch(
      updateDeviceState({
        isMicMuted: mute,
      })
    );
    (window as any).electron.ipcRenderer.send(
      USER_EVENT_NAME.ON_CHANGE_LOCAL_USER_STATE,
      {
        isMicMuted: mute,
      }
    );
  };

  const updateCameraMuteState = (mute: boolean) => {
    trtcUtil.trtcEducation?.rtcCloud.muteLocalVideo(mute);
    dispatch(
      updateDeviceState({
        isCameraMuted: mute,
      })
    );
    (window as any).electron.ipcRenderer.send(
      USER_EVENT_NAME.ON_CHANGE_LOCAL_USER_STATE,
      {
        isCameraMuted: mute,
      }
    );
  };

  // 初始数据设置后，currentUser 不会立即生效，进房依赖 currentUser, 所以要在一个单独的 useEffect 中进房
  useEffect(() => {
    console.warn(
      `enter ${logPrefix}.useEffect(): currentUser ready, enter room`,
      currentUser
    );
    function enterClassRoom() {
      console.warn(`${logPrefix}.enterClass: `, currentUser);
      const { userSig, sdkAppId } = (window as any).electron.genTestUserSig(
        currentUser.userID
      );
      const params = {
        roomID: currentUser.roomID,
        role: currentUser.role,
        sdkAppId,
        userID: currentUser.userID,
        userSig,
      };
      if (currentUser.role === 'teacher') {
        // @ts-ignore
        trtcUtil.trtcEducation?.enterClassRoom(params);
      }
    }

    if (currentUser && currentUser.userID) {
      enterClassRoom();
    }
  }, [currentUser]);

  // 根据初始化参数，启动屏幕分享：进房后，不预览，预览在单独小窗口，进房后才会推送屏幕分享流
  useEffect(() => {
    console.warn(
      `enter ${logPrefix}.useEffect(): currentUser ready, start sharing`,
      currentUser
    );
    if (
      currentUser?.sharingScreenInfo?.sourceId &&
      trtcUtil.trtcEducation?.rtcCloud
    ) {
      const screenInfo = currentUser.sharingScreenInfo;
      const selectRect = new Rect();
      const screenShareEncParam = new TRTCVideoEncParam(
        TRTCVideoResolution.TRTCVideoResolution_1920_1080,
        TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape,
        15,
        1600,
        0,
        true
      );
      trtcUtil.trtcEducation?.rtcCloud.selectScreenCaptureTarget(
        screenInfo.type,
        screenInfo.sourceId,
        screenInfo.sourceName,
        selectRect,
        true, // mouse
        true // highlight
      );
      trtcUtil.trtcEducation?.rtcCloud.startScreenCapture(
        null, // 此处不需要预览，所以位置的DOM容器元素传 null
        TRTCVideoStreamType.TRTCVideoStreamTypeSub,
        screenShareEncParam
      );
    }
  }, [currentUser]);

  useEffect(() => {
    console.warn(
      `${logPrefix}.useEffect updateCurrentDevice currentCamera`,
      currentCameraInStore,
      currentCamera
    );
    if (
      currentCameraInStore?.deviceId &&
      currentCamera?.deviceId &&
      currentCameraInStore.deviceId !== currentCamera.deviceId
    ) {
      trtcUtil.trtcEducation?.rtcCloud.setCurrentCameraDevice(
        currentCameraInStore.deviceId
      );
    } else if (currentCamera?.deviceId) {
      dispatch(
        updateCurrentDevice({
          currentCamera,
        })
      );
    }

    console.warn(
      `${logPrefix}.useEffect updateCurrentDevice currentMic`,
      currentMicInStore,
      currentMic
    );
    if (
      currentMicInStore?.deviceId &&
      currentMic?.deviceId &&
      currentMicInStore.deviceId !== currentMic.deviceId
    ) {
      trtcUtil.trtcEducation?.rtcCloud.setCurrentMicDevice(
        currentMicInStore.deviceId
      );
    } else if (currentMic?.deviceId) {
      dispatch(
        updateCurrentDevice({
          currentMic,
        })
      );
    }

    console.warn(
      `${logPrefix}.useEffect updateCurrentDevice currentSpeakerInStore`,
      currentSpeakerInStore,
      currentSpeaker
    );
    if (
      currentSpeakerInStore?.deviceId &&
      currentSpeaker?.deviceId &&
      currentSpeakerInStore.deviceId !== currentSpeaker.deviceId
    ) {
      trtcUtil.trtcEducation?.rtcCloud.setCurrentSpeakerDevice(
        currentSpeakerInStore.deviceId
      );
    } else if (currentMic?.deviceId) {
      dispatch(
        updateCurrentDevice({
          currentSpeaker,
        })
      );
    }
  }, [
    currentMicInStore,
    currentCameraInStore,
    currentSpeakerInStore,
    currentCamera,
    currentMic,
    dispatch,
    currentSpeaker,
  ]);

  const onChangeSharing = () => {
    (window as any).electron.ipcRenderer.send(
      USER_EVENT_NAME.CHANGE_SHARE_SCREEN_WINDOW,
      {}
    );
  };

  const onStopSharing = () => {
    trtcUtil.trtcEducation?.rtcCloud.stopScreenCapture(); // 停止屏幕分享
    (window as any).electron.ipcRenderer.send(
      USER_EVENT_NAME.EXIT_SHARE_ROOM,
      {}
    );
  };

  const muteAllStudent = useCallback(async () => {
    try {
      await trtcUtil.trtcEducation?.muteAllStudent(!isAllStudentMuted, roomID);
      dispatch(updateAllStudentMuteState(!isAllStudentMuted));
    } catch (error) {
      console.error(`${logPrefix}.muteAllStudent error`, error);
    }
  }, [roomID, isAllStudentMuted, dispatch]);

  const callAllStudent = useCallback(async () => {
    try {
      const currentTime = new Date().getTime();
      const rollTime = 60;
      const teacherWaitRollTime = 90;
      dispatch(updateAllStudentRollState(currentTime));
      dispatch(updateRollState(true));
      (window as any).electron.ipcRenderer.send(
        USER_EVENT_NAME.ON_CALL_ROLL,
        currentTime
      );
      await trtcUtil.trtcEducation?.callRoll(rollTime, roomID);
      setTimeout(() => {
        dispatch(updateRollState(false));
      }, teacherWaitRollTime * 1000);
    } catch (error) {
      console.error(`${logPrefix}.callAllStudent error`, error);
    }
  }, [roomID, callRollTime, dispatch]);

  const onHandsUpHandler = (args: Record<string, any>) => {
    const studentID = args.data as string;
    const newHandsList = handsList.concat(studentID);
    setHandsList(Array.from(new Set(newHandsList)));
  };

  // 注册事件监听
  useEffect(() => {
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_HANDS_UP,
      onHandsUpHandler,
      {}
    );

    return () => {
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_HANDS_UP,
        onHandsUpHandler
      );
    };
  });

  const confirmHandsUp = (studentID: any) => {
    console.warn(`${logPrefix}.confirmHandsUp studentID:`, studentID);
    trtcUtil.trtcEducation?.sendHandUpAck(studentID);
  };

  const onHandsUpPopClose = () => {
    setHandsList([]);
  };

  const toggleMicMuteState = (user: Record<string, any>) => {
    // 远端 user.isMicStarted 为 true 时需要 mute 掉，否则，unmute
    // To-do: isMicStarted 可能是 undefined 的，所以需要!!运算得到一个Boolean值
    trtcUtil.trtcEducation?.muteStudentByID(!!user.isMicStarted, user.userID);
  };

  const classUserList = [currentUser].concat(
    [...classMembersMap.keys()]
      .filter(
        (key: string) => classMembersMap.get(key).userID !== currentUser.userID
      )
      .map((key: string) => classMembersMap.get(key))
  );

  return (
    <div
      className={`trtc-edu-class-room-top-view ${
        platform === 'win32' ? 'platform-win' : ''
      }`}
    >
      {currentUser && (
        <ClassTool
          onChangeSharing={onChangeSharing}
          onStopSharing={onStopSharing}
          isCameraMuted={currentUser.isCameraMuted}
          cameraList={cameraList}
          currentCameraId={currentUser.currentCamera?.deviceId || ''}
          resetCurrentCamera={changeCurrentCamera}
          updateCameraMuteState={updateCameraMuteState}
          isMicMuted={currentUser.isMicMuted}
          microphoneList={micList}
          currentMicId={currentUser.currentMic?.deviceId || ''}
          resetCurrentMicrophone={changeCurrentMic}
          updateMicMuteState={updateMicMuteState}
          speakerList={speakerList}
          currentSpeakerId={currentUser.currentSpeaker?.deviceId || ''}
          resetCurrentSpeaker={changeCurrentSpeaker}
          isAllStudentMuted={isAllStudentMuted}
          callRollTime={callRollTime}
          onMuteAllStudent={muteAllStudent}
          onCallAllStudent={callAllStudent}
          handsUpList={handsList}
          handsUpHandler={confirmHandsUp}
          onHandsUpPopClose={onHandsUpPopClose}
          enterRoomTime={enterRoomTime}
          isRolled={isRolled}
        />
      )}
      {currentUser && (
        <ComVideoList
          userList={classUserList}
          toggleMicMuteState={toggleMicMuteState}
        />
      )}
    </div>
  );
}

export default ClassRoomTopView;
