import React, { useEffect, useState, useCallback } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import {
  TRTCScreenCaptureSourceInfo,
  Rect,
  TRTCVideoStreamType,
  TRTCVideoEncParam,
  TRTCVideoResolution,
  TRTCVideoResolutionMode,
} from 'trtc-electron-sdk/liteav/trtc_define';
import useClassMember from '../../hooks/use-class-member/index';
import { USER_EVENT_NAME } from '../../../constants';
import Title from '../../components/class-room-title';
import Footer from '../../components/class-room-footer';
import Aside from '../../components/class-room-aside';
import { trtcUtil } from '../../utils/trtc-edu-sdk/index';
import {
  updateCurrentDevice,
  updateDeviceState,
  updateShareScreenInfo,
  updateAllStudentMuteState,
  updateEnterRoomTime,
  updateAllStudentRollState,
  updateRollState,
} from '../../store/user/userSlice';
import useDevice from '../../hooks/use-device';
import WhiteBoard from '../../components/class-room-board';
import './index.scss';

function ClassRoom() {
  const logPrefix = '[class-room.tsx]';
  const [handsList, setHandsList] = useState<Array<string>>([]);
  const [userInfo, setUserInfo] = useState<Record<string, any>>({});
  const [sharingBounds, setSharingBounds] = useState<DOMRect | null>(null);
  const [screenInfo, setScreenInfo] =
    useState<TRTCScreenCaptureSourceInfo | null>(null);

  const dispatch = useDispatch();
  const currentUser = useSelector((state: any) => state.user);
  const {
    userID,
    roomID,
    role,
    sharingScreenInfo,
    isAllStudentMuted,
    enterRoomTime,
    callRollTime,
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
  const { classMembersMap, messageList } = useClassMember();

  const updateMicMuteState = (mute: boolean) => {
    trtcUtil.trtcEducation?.rtcCloud.muteLocalAudio(mute);
    setUserInfo({
      ...userInfo,
      isMicMuted: mute,
    });
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
    setUserInfo({
      ...userInfo,
      isCameraMuted: mute,
    });
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

  const enterShareRoom = (options: any) => {
    console.warn(`${logPrefix}.enterShareRoom: options:`, options);
    (window as any).electron.ipcRenderer.send(
      USER_EVENT_NAME.ENTER_SHARE_ROOM,
      options
    );
  };

  const startSharingHandler = (
    screenSource: TRTCScreenCaptureSourceInfo | null
  ) => {
    if (screenSource) {
      // 新窗口中也会调用 startLocalPreview() 预览本地摄像头，window下必须关闭当前窗口摄像头预览，否则新窗口预览会是黑屏
      trtcUtil.trtcEducation?.rtcCloud.stopLocalPreview();
      // 临时退房，否则屏幕分享窗口二次进房时，会导致互踢，远端用户看到的屏幕分享不断闪烁
      trtcUtil.trtcEducation?.rtcCloud.exitRoom();
      setUserInfo({}); // 清空用户信息，下次打开窗口时，在 ON-WINDOW-SHOW 时重新赋值

      enterShareRoom({ screenSource });
    } else {
      // eslint-disable-next-line no-alert
      alert('请选择需要分享的屏幕或窗口');
    }
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

  const startSharingWhiteBoard = useCallback(() => {
    if (screenInfo && sharingBounds && currentUser.platform) {
      const menubarAddToolbarHeight = window.outerHeight - window.innerHeight;

      let selectRect = null;
      if (currentUser.platform === 'win32') {
        // windows
        const devicePixelRatio = window.devicePixelRatio || 1;
        selectRect = new Rect(
          sharingBounds.left * devicePixelRatio,
          (sharingBounds.top + menubarAddToolbarHeight) * devicePixelRatio,
          sharingBounds.right * devicePixelRatio,
          (sharingBounds.bottom + menubarAddToolbarHeight) * devicePixelRatio
        );
      } else {
        // mac
        selectRect = new Rect(
          sharingBounds.left,
          sharingBounds.top + menubarAddToolbarHeight,
          sharingBounds.right,
          sharingBounds.bottom + menubarAddToolbarHeight
        );
      }

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
        false // highlight
      );
      trtcUtil.trtcEducation?.rtcCloud.startScreenCapture(
        null, // 此处不需要预览，所以位置的DOM容器元素传 null
        TRTCVideoStreamType.TRTCVideoStreamTypeSub,
        screenShareEncParam
      );
    }
  }, [screenInfo, sharingBounds, currentUser.platform]);

  useEffect(() => {
    console.info(
      `${logPrefix}.useEffect start sharing:`,
      screenInfo,
      sharingBounds
    );
    if (screenInfo && sharingBounds && sharingBounds.left !== undefined) {
      startSharingWhiteBoard();
    }
  }, [screenInfo, sharingBounds, startSharingWhiteBoard]);

  useEffect(() => {
    const screenCaptureList: Array<TRTCScreenCaptureSourceInfo> =
      trtcUtil.trtcEducation?.rtcCloud.getScreenCaptureSources(160, 90, 32, 32);
    const whiteBoardWindow = screenCaptureList.filter(
      (screen) =>
        // To-do：获取app name，应该从主进程传入
        screen.sourceName.indexOf('TRTC Education - Electron Version') !== -1
    );

    if (whiteBoardWindow && whiteBoardWindow.length) {
      setScreenInfo(whiteBoardWindow[0]);
    }
  }, []);

  useEffect(() => {
    if (currentUser && currentUser.userID) {
      const newUserInfo = {
        ...currentUser,
      };
      if (!currentUser.currentCamera?.deviceId) {
        newUserInfo.currentCamera = currentCamera;
      }
      if (!currentUser.currentMic?.deviceId) {
        newUserInfo.currentMic = currentMic;
      }
      if (!currentUser.currentSpeaker?.device) {
        newUserInfo.currentSpeaker = currentSpeaker;
      }
      setUserInfo(newUserInfo);
    }
  }, [currentUser, currentCamera, currentMic, currentSpeaker]);

  useEffect(() => {
    if (userID && role && roomID) {
      const { userSig, sdkAppId } = (window as any).electron.genTestUserSig(
        userID
      );
      const params = {
        roomID,
        role,
        sdkAppId,
        userID,
        userSig,
      };
      console.log('enter here');
      if (role === 'teacher') {
        // @ts-ignore
        trtcUtil.trtcEducation?.enterClassRoom(params);
        // 获取进房时的时间戳，即为老师开始上课的时间
        const currentTime = new Date().getTime();
        dispatch(updateEnterRoomTime(currentTime));
        (window as any).electron.ipcRenderer.send(
          USER_EVENT_NAME.ON_CHANGE_LOCAL_USER_STATE,
          {
            enterRoomTime: currentTime,
          }
        );
      }
    }
  }, [role, roomID, userID]);

  useEffect(() => {
    (window as any).electron.ipcRenderer.on(
      USER_EVENT_NAME.ON_WINDOW_SHOW,
      (event: any, args: any) => {
        console.warn(`${logPrefix}.ON_WINDOW_SHOW: `, event, args);
        trtcUtil.trtcEducation?.reenterTRTCRoom();
        startSharingWhiteBoard();

        const newUserInfo = {
          ...args.store.currentUser,
        };
        if (
          currentMic &&
          args.store.currentUser.currentMic &&
          args.store.currentUser.currentMic.deviceId &&
          currentMic.deviceId !== args.store.currentUser.currentMic.deviceId
        ) {
          console.warn(`${logPrefix}.ON_WINDOW_SHOW need change current Mic`);
          trtcUtil.trtcEducation?.rtcCloud.setCurrentMicDevice(
            args.store.currentUser.currentMic.deviceId
          );
        } else {
          newUserInfo.currentMic = currentMic;
        }

        if (
          currentCamera &&
          args.store.currentUser.currentCamera &&
          args.store.currentUser.currentCamera.deviceId &&
          currentCamera.deviceId !==
            args.store.currentUser.currentCamera.deviceId
        ) {
          console.warn(`${logPrefix}.ON_WINDOW_SHOW need change camera Mic`);
          trtcUtil.trtcEducation?.rtcCloud.setCurrentCameraDevice(
            args.store.currentUser.currentCamera.deviceId
          );
        } else {
          newUserInfo.currentCamera = currentCamera;
        }

        if (
          currentSpeaker &&
          args.store.currentUser.currentSpeaker &&
          args.store.currentUser.currentSpeaker.deviceId &&
          currentSpeaker.deviceId !==
            args.store.currentUser.currentSpeaker.deviceId
        ) {
          console.warn(
            `${logPrefix}.ON_WINDOW_SHOW need change current Speaker`
          );
          trtcUtil.trtcEducation?.rtcCloud.setCurrentSpeakerDevice(
            args.store.currentUser.currentSpeaker.deviceId
          );
        } else {
          newUserInfo.currentSpeaker = currentSpeaker;
        }
        setUserInfo(newUserInfo);
        dispatch(updateCurrentDevice(newUserInfo));
        dispatch(
          updateShareScreenInfo(args.store.currentUser.sharingScreenInfo)
        );
        dispatch(
          updateAllStudentMuteState(args.store.currentUser.isAllStudentMuted)
        );
        dispatch(
          updateAllStudentRollState(args.store.currentUser.callRollTime)
        );
        dispatch(updateRollState(args.store.currentUser.isRolled));
      }
    );
  }, [
    currentCamera,
    currentMic,
    currentSpeaker,
    dispatch,
    startSharingWhiteBoard,
  ]);

  const onUpdateWhiteBoardBoards = (boundsRect: DOMRect) => {
    console.log(
      `${logPrefix}.onUpdateWhiteBoardBoards boundsRect:`,
      boundsRect
    );
    setSharingBounds(boundsRect);
  };
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

  const classUserList = [...classMembersMap.keys()].map((key) =>
    classMembersMap.get(key)
  );

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

  return (
    <div className="trtc-class-room">
      <header className="class-room-header">
        <Title enterRoomTime={enterRoomTime} />
      </header>
      <div className="class-room-body">
        <div className="main-content">
          <div className="white-board">
            <WhiteBoard
              user={currentUser}
              onUpdateBounds={onUpdateWhiteBoardBoards}
            />
          </div>
          <div className="class-room-footer">
            <Footer
              onStartSharing={startSharingHandler}
              userInfo={userInfo}
              isCameraMute={userInfo.isCameraMuted}
              cameraList={cameraList}
              currentCameraId={userInfo.currentCamera?.deviceId || ''}
              resetCurrentCamera={changeCurrentCamera}
              updateCameraMuteState={updateCameraMuteState}
              isMicMute={userInfo.isMicMuted}
              microphoneList={micList}
              currentMicId={userInfo.currentMic?.deviceId || ''}
              resetCurrentMicrophone={changeCurrentMic}
              updateMicMuteState={updateMicMuteState}
              preselectedScreen={sharingScreenInfo.sourceId}
              speakerList={speakerList}
              currentSpeakerId={userInfo.currentSpeaker?.deviceId || ''}
              resetCurrentSpeaker={changeCurrentSpeaker}
              isAllStudentMuted={isAllStudentMuted}
              callRollTime={callRollTime}
              onMuteAllStudent={muteAllStudent}
              onCallAllStudent={callAllStudent}
              handsUpList={handsList}
              handsUpHandler={confirmHandsUp}
              onHandsUpPopClose={onHandsUpPopClose}
              isRolled={isRolled}
            />
          </div>
        </div>
        <aside className="aside-content">
          <Aside
            currentUser={userInfo}
            ownerID={userInfo.userID}
            toggleMicMuteState={toggleMicMuteState}
            classMembers={classUserList}
            messageList={messageList}
          />
        </aside>
      </div>
    </div>
  );
}

export default ClassRoom;
