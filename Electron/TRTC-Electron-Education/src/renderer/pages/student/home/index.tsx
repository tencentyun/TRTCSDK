import React, { useEffect, useState, useRef, useCallback } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { TRTCVideoStreamType } from 'trtc-electron-sdk/liteav/trtc_define';
import { trtcUtil } from 'renderer/utils/trtc-edu-sdk';
import useClassMember from 'renderer/hooks/use-class-member';
import StudentSignIn from 'renderer/components/student-sign-in';
import { USER_EVENT_NAME } from '../../../../constants';
import useDevice from '../../../hooks/use-device';
import {
  updateDeviceState,
  updateIsMutedByTeacher,
  updateIsHandUpConfirmed,
  updateEnterRoomTime,
  updateAllStudentRollState,
} from '../../../store/user/userSlice';
import Title from '../../../components/class-room-title';
import Footer from '../../../components/class-room-footer';
import Aside from '../../../components/class-room-aside';

import './index.scss';

function StudentHome() {
  const logPrefix = '[StudentHome]';
  const refShareScreen = useRef<HTMLDivElement>(null);

  const dispatch = useDispatch();
  const currentUser = useSelector((state: any) => state.user);
  const userID = useSelector((state: any) => state.user.userID);
  const roomID = useSelector((state: any) => state.user.roomID);
  const role = useSelector((state: any) => state.user.role);
  const enterRoomTime = useSelector((state: any) => state.user.enterRoomTime);
  const callRollTime = useSelector((state: any) => state.user.callRollTime);
  const [ownerID, setOwnerID] = useState<string>('');

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
  let isRenderedTeacherScreen = false;

  const sendHandUpMessage = async () => {
    try {
      await trtcUtil.trtcEducation?.sendHandsMessage(roomID, userID);
    } catch (error) {
      console.error(`${logPrefix} [sendHandUpMessage] hands-up error`, error);
    }
  };

  const updateMicMuteState = useCallback(
    (mute: boolean) => {
      if (currentUser.isMutedByTeacher && !currentUser.isHandUpConfirmed) {
        return;
      }
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
    },
    [currentUser.isMutedByTeacher, currentUser.isHandUpConfirmed, dispatch]
  );

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

  const videoHandler = useCallback(
    (event: { data: string; eventCode: string }) => {
      const ownerId = event.data;
      setOwnerID(ownerId);
      if (!isRenderedTeacherScreen) {
        trtcUtil.trtcEducation?.rtcCloud.startRemoteView(
          ownerId,
          refShareScreen.current,
          TRTCVideoStreamType.TRTCVideoStreamTypeSub
        );
      }
    },
    []
  );

  const onUserVideoAvailableHandler = useCallback(
    (args: Record<string, any>) => {
      console.warn(`${logPrefix}.onUserVideoAvailable args:`, args);
      if (args.data.available) {
        if (trtcUtil.trtcEducation?.rtcCloud) {
          const ownerId = trtcUtil.trtcEducation?.ownerID;
          if (ownerId) {
            setOwnerID(ownerId);
            if (ownerId === args.data.userID) {
              isRenderedTeacherScreen = true;
              trtcUtil.trtcEducation?.rtcCloud.startRemoteView(
                ownerId,
                refShareScreen.current,
                TRTCVideoStreamType.TRTCVideoStreamTypeSub
              );
            }
          }
        }
      }
    },
    []
  );

  const onUserSubStreamAvailableHandler = (args: Record<string, any>) => {
    if (trtcUtil.trtcEducation?.rtcCloud) {
      if (args.data.available) {
        const ownerId = trtcUtil.trtcEducation?.ownerID;
        if (ownerId) {
          setOwnerID(ownerId);
          if (ownerId === args.data.userId) {
            trtcUtil.trtcEducation.rtcCloud.startRemoteView(
              ownerId,
              refShareScreen.current,
              TRTCVideoStreamType.TRTCVideoStreamTypeSub
            );
          }
        }
      }
    }
  };

  const onMuteAllStudentHandler = useCallback(
    (event: { data: boolean; eventCode: string }) => {
      if (currentUser.role === 'student') {
        dispatch(updateIsMutedByTeacher(event.data));
        // 学生本地未禁麦，则是否禁麦由教师端全员禁麦指令决定
        if (!currentUser.isMicMuted) {
          trtcUtil.trtcEducation?.rtcCloud.muteLocalAudio(event.data);
        } else {
          // 学生本地已禁麦，只需基于教师端全员禁麦指令修改 isMutedByTeacher，无需调用禁麦接口
        }
      }
    },
    [currentUser.isMicMuted, currentUser.role, dispatch]
  );

  const onCallRollHandler = useCallback(
    (event: { data: number; eventCode: string }) => {
      if (event.data > 0) {
        console.log(`${logPrefix}.onMuteAllStudentHandler`, event.data);
        dispatch(updateAllStudentRollState(event.data));
      }
    },
    [currentUser.callRollTime, currentUser.role, dispatch]
  );

  const onConfirmHandUp = useCallback(() => {
    dispatch(updateIsHandUpConfirmed(true));
    // if (currentUser.isMicMuted) {
    const mute = false;
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
    // }
    // updateMicMuteState(false);
  }, [dispatch]);

  // eslint-disable-next-line react-hooks/exhaustive-deps
  const onClassTimeHandler = (args: Record<string, any>) => {
    if (args.data) {
      dispatch(updateEnterRoomTime(args.data));
    }
  };

  // 注册事件监听
  useEffect(() => {
    // 监听远端用户视频
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_USER_VIDEO_AVAILABLE,
      onUserVideoAvailableHandler,
      {}
    );
    // 监听全员禁麦事件
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_MUTE_ALL_STUDENT,
      onMuteAllStudentHandler,
      {}
    );
    // 监听老师同意举手事件
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_CONFIRM_HAND_UP,
      onConfirmHandUp,
      {}
    );
    // 监听远端用户屏幕分享
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_USER_SUB_STREAM_AVAILABLE,
      onUserSubStreamAvailableHandler,
      {}
    );
    // 监听老师成功进房
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_OWNER_READY,
      videoHandler,
      null
    );
    // 监听老师发出的签到请求
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_CALL_ROLL,
      onCallRollHandler,
      {}
    );
    // 监听老师
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_CLASS_TIME,
      onClassTimeHandler,
      {}
    );
    return () => {
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_USER_VIDEO_AVAILABLE,
        onUserVideoAvailableHandler
      );
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_MUTE_ALL_STUDENT,
        onMuteAllStudentHandler
      );
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_CONFIRM_HAND_UP,
        onConfirmHandUp
      );
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_USER_SUB_STREAM_AVAILABLE,
        onUserSubStreamAvailableHandler
      );
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_OWNER_READY,
        videoHandler
      );
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_CALL_ROLL,
        onCallRollHandler
      );
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_CLASS_TIME,
        onClassTimeHandler
      );
    };
  }, [
    onMuteAllStudentHandler,
    onUserVideoAvailableHandler,
    videoHandler,
    onConfirmHandUp,
    onCallRollHandler,
    onClassTimeHandler,
  ]);

  useEffect(() => {
    if (userID && roomID && userID) {
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
      if (role === 'student') {
        // @ts-ignore
        trtcUtil.trtcEducation?.enterClassRoom(params);
      }
    }
  }, [role, roomID, userID]);

  const onDismissGroupHandler = (args: Record<string, any>) => {
    alert(`老师已解散群组${args.data}`);
    (window as any).electron.ipcRenderer.send(
      USER_EVENT_NAME.STUDENT_EXIT_CLASS_ROOM,
      {}
    );
  };

  // 注册解散群组事件监听
  useEffect(() => {
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.TEACHER_GROUP_DISMISSED,
      onDismissGroupHandler,
      {}
    );

    return () => {
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.TEACHER_GROUP_DISMISSED,
        onDismissGroupHandler
      );
    };
  });

  const toggleMicMuteState = useCallback(
    (user: Record<string, any>) => {
      if (user.userID === userID) {
        // 当前学生修改自己的麦克风状态
        updateMicMuteState(user.isMicStarted && !user.isMicMuted);
      } else {
        // 当前学生不能修改其他学生的麦克风状态
        console.warn(
          `${logPrefix}.toggleMicMuteState current userID: ${userID} cannot modify mic of other userID: ${user.userID}`
        );
      }
    },
    [updateMicMuteState, userID]
  );

  // const remoteUserList = [...remoteUserMap.keys()].map((key) =>
  //   remoteUserMap.get(key)
  // );
  const classUserList = [...classMembersMap.keys()].map((key) =>
    classMembersMap.get(key)
  );

  let isMicMuted = true;
  if (currentUser.isHandUpConfirmed) {
    // 举手被同意，优先级最高
    isMicMuted = currentUser.isMicMuted;
  } else {
    isMicMuted = currentUser.isMutedByTeacher || currentUser.isMicMuted;
  }

  return (
    <div className="student-class-room">
      <header className="class-room-header">
        <Title enterRoomTime={enterRoomTime} />
      </header>
      <div className="class-room-body">
        <div className="main-content">
          <div className="white-board" ref={refShareScreen} />
          <StudentSignIn callRollTime={callRollTime} userID={userID} />
          <div className="class-room-footer">
            <Footer
              userInfo={currentUser}
              isCameraMute={currentUser.isCameraMuted}
              cameraList={cameraList}
              currentCameraId={currentCamera?.deviceId || ''}
              resetCurrentCamera={changeCurrentCamera}
              updateCameraMuteState={updateCameraMuteState}
              isMicMute={isMicMuted}
              microphoneList={micList}
              currentMicId={currentMic?.deviceId || ''}
              resetCurrentMicrophone={changeCurrentMic}
              updateMicMuteState={updateMicMuteState}
              speakerList={speakerList}
              currentSpeakerId={currentSpeaker?.deviceId || ''}
              resetCurrentSpeaker={changeCurrentSpeaker}
              handsUpHandler={sendHandUpMessage}
            />
          </div>
        </div>
        <div className="aside-content">
          <Aside
            currentUser={currentUser}
            ownerID={ownerID}
            // remoteUsers={remoteUserList}
            toggleMicMuteState={toggleMicMuteState}
            classMembers={classUserList}
            messageList={messageList}
          />
        </div>
      </div>
    </div>
  );
}

export default StudentHome;
