import { useState, useEffect, useCallback } from 'react';
import { useSelector } from 'react-redux';
import { USER_EVENT_NAME } from '../../../constants';
import { trtcUtil } from '../../utils/trtc-edu-sdk';

function useRemoteUsers() {
  const logPrefix = '[useRemoteUsers]';
  const userID = useSelector((state: any) => state.user.userID);
  const role = useSelector((state: any) => state.user.role);
  const isAllStudentMuted = useSelector(
    (state: any) => state.user.isAllStudentMuted
  );
  const [remoteUserMap, setRemoteUserMap] = useState<Map<string, any>>(
    new Map<string, any>()
  );

  const onRemoteUserEnterRoom = useCallback(
    (args: Record<string, any>) => {
      const newUserID = args.data;
      // userID为currentUser
      if (userID === newUserID) {
        // IM 当前用户入群通知消息触发的事件，不处理
        return;
      }

      if (!remoteUserMap.has(newUserID)) {
        remoteUserMap.set(newUserID, {
          userID: newUserID,
        });
        setRemoteUserMap(new Map(remoteUserMap));
      }

      if (role === 'teacher' && isAllStudentMuted) {
        console.warn(
          `${logPrefix}.onRemoteUserEnterRoom muteStudentByID:`,
          newUserID
        );
        trtcUtil.trtcEducation?.muteStudentByID(true, newUserID);
      }
    },
    [userID, isAllStudentMuted, role, remoteUserMap]
  );

  const onRemoteUserLeaveRoom = (args: Record<string, any>) => {
    if (remoteUserMap.has(args.data)) {
      remoteUserMap.delete(args.data);
      setRemoteUserMap(new Map(remoteUserMap));
    }
  };

  const onUserVideoAvailable = (args: Record<string, any>) => {
    const newUserID = args.data.userID as string;

    // onUserVideoAvailable 事件通知有可能早于 onRemoteUserEnter 事件到达
    if (!remoteUserMap.has(newUserID)) {
      remoteUserMap.set(newUserID, {
        userID: newUserID,
        isCameraStarted: Boolean(args.data.available),
      });
    } else {
      remoteUserMap.get(newUserID).isCameraStarted = Boolean(
        args.data.available
      );
    }

    setRemoteUserMap(new Map(remoteUserMap));
  };

  const onUserAudioAvailable = (args: Record<string, any>) => {
    const newUserID = args.data.userID as string;

    // onUserAudioAvailable 事件通知有可能早于 onRemoteUserEnter 事件到达
    if (!remoteUserMap.has(newUserID)) {
      remoteUserMap.set(newUserID, {
        userID: newUserID,
        isMicStarted: Boolean(args.data.available),
      });
    } else {
      remoteUserMap.get(newUserID).isMicStarted = Boolean(args.data.available);
    }

    setRemoteUserMap(new Map(remoteUserMap));
  };

  // 注册事件监听
  useEffect(() => {
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_REMOTE_USER_ENTER_ROOM,
      onRemoteUserEnterRoom,
      {}
    );
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_REMOTE_USER_LEAVE_ROOM,
      onRemoteUserLeaveRoom,
      {}
    );
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_USER_VIDEO_AVAILABLE,
      onUserVideoAvailable,
      {}
    );
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_USER_AUDIO_AVAILABLE,
      onUserAudioAvailable,
      {}
    );

    return () => {
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_REMOTE_USER_ENTER_ROOM,
        onRemoteUserEnterRoom
      );
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_REMOTE_USER_LEAVE_ROOM,
        onRemoteUserLeaveRoom
      );
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_USER_VIDEO_AVAILABLE,
        onUserVideoAvailable
      );
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_USER_AUDIO_AVAILABLE,
        onUserAudioAvailable
      );
    };
  }, [onRemoteUserEnterRoom]);

  return {
    remoteUserMap,
  };
}

export default useRemoteUsers;
