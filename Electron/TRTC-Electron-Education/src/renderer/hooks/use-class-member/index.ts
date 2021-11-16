import { useState, useEffect, useCallback } from 'react';
import { useSelector } from 'react-redux';
import { USER_EVENT_NAME } from '../../../constants';
import { trtcUtil } from '../../utils/trtc-edu-sdk';
// to-do: 后续统一数据类型
// interface ClassMemberType {
//   userID: string;
//   avatar?: string | '';
//   role?: string | '';
//   nick?: string | '';
//   isCameraStarted?: boolean | false;
//   isMicStarted?: boolean | false;
// }

function useClassMember() {
  const logPrefix = '[useClassMember]';
  // 本地的一些信息
  const userID = useSelector((state: any) => state.user.userID);
  const role = useSelector((state: any) => state.user.role);
  const enterRoomTime = useSelector((state: any) => state.user.enterRoomTime);
  const callRollTime = useSelector((state: any) => state.user.callRollTime);
  const roomID = useSelector((state: any) => state.user.roomID);
  const isAllStudentMuted = useSelector(
    (state: any) => state.user.isAllStudentMuted
  );
  const [classMembersMap, setClassMembersMap] = useState<Map<string, any>>(
    new Map<string, any>()
  );
  const [messageList, setMessageList] = useState<Array<any>>([]);

  const [rolledList, setRolledList] = useState<Array<any>>([]);

  const onGetGroupMemberList = (args: Record<string, any>) => {
    if (args.data.length > 0) {
      console.log(
        `${logPrefix}.onGetGroupMemberList args:`,
        JSON.stringify(args)
      );
      args.data.forEach(
        (item: { userID: string; role: string | undefined }) => {
          if (!classMembersMap.has(item.userID)) {
            classMembersMap.set(item.userID, item);
          } else {
            let member = classMembersMap.get(item.userID);
            // 合并
            member = Object.assign(member, item, {
              role: item.role !== 'Owner' ? member.role : item.role,
            });
            classMembersMap.set(item.userID, member);
          }
        }
      );
      setClassMembersMap(new Map(classMembersMap));
    }
  };

  // 如果老师开启全员禁麦，发送禁麦消息给新加入学生
  const checkAndMuteStudent = useCallback(
    (newUserID: string) => {
      if (role === 'teacher' && isAllStudentMuted) {
        console.warn(
          `${logPrefix}.onGroupMemberEnterRoom muteStudentByID:`,
          newUserID
        );
        trtcUtil.trtcEducation?.muteStudentByID(true, newUserID);
      }
    },
    [isAllStudentMuted, role]
  );

  const onGroupMemberEnterRoom = useCallback(
    (args: Record<string, any>) => {
      console.log(
        `${logPrefix}.onGroupMemberEnterRoom args:`,
        JSON.stringify(args)
      );
      if (!classMembersMap.has(args.data.userID)) {
        classMembersMap.set(args.data.userID, args.data);
      } else {
        let member = classMembersMap.get(args.data.userID);
        member = Object.assign(member, args.data, {
          role: args.data?.role !== 'Owner' ? member.role : args.data.role,
        });
        classMembersMap.set(args.data.userID, member);
      }

      checkAndMuteStudent(args.data.userID);

      // 向学生端发送老师开始上课的时间戳。
      console.warn(`${logPrefix}enter-member-enter-time`, enterRoomTime);
      if (enterRoomTime > 0) {
        trtcUtil.trtcEducation?.sendClassTimeMessage(roomID, enterRoomTime);
      } else {
        console.error(
          `${logPrefix}hooks-enter-group-member-time`,
          enterRoomTime
        );
      }
      // 向学生端发送老师签到剩余时间
      console.warn(`${logPrefix}student-rolled-time`, callRollTime);
      const currentTime = new Date().getTime();
      const diffTime = (currentTime - callRollTime) / 1000;
      const time = 60 - parseInt((diffTime % 60).toString(), 10);
      if (callRollTime > 0 && time > 0) {
        trtcUtil.trtcEducation?.callRollByID(time, args.data.userID);
      }
    },
    [classMembersMap, checkAndMuteStudent, enterRoomTime, roomID]
  );

  const onGroupMemberQuitRoom = (args: Record<string, any>) => {
    if (classMembersMap.has(args.data.userID)) {
      classMembersMap.delete(args.data.userID);
      setClassMembersMap(new Map(classMembersMap));
    }
  };

  const onRemoteUserEnterRoom = useCallback(
    (args: Record<string, any>) => {
      const newUserID = args.data;
      if (!classMembersMap.has(newUserID)) {
        classMembersMap.set(newUserID, {
          userID: newUserID,
          isCameraStarted: false,
          isMicStarted: false,
        });
        setClassMembersMap(new Map(classMembersMap));
      } else {
        classMembersMap.set(newUserID, {
          ...classMembersMap.get(newUserID),
          isCameraStarted: false,
          isMicStarted: false,
        });
      }

      checkAndMuteStudent(newUserID);
    },
    [classMembersMap, checkAndMuteStudent]
  );

  const onRemoteUserLeaveRoom = (args: Record<string, any>) => {
    if (classMembersMap.has(args.data)) {
      classMembersMap.delete(args.data);
      setClassMembersMap(new Map(classMembersMap));
    }
  };

  const onUserVideoAvailable = (args: Record<string, any>) => {
    const newUserID = args.data.userID as string;

    // onUserVideoAvailable 事件通知有可能早于 onRemoteUserEnter 事件到达
    if (!classMembersMap.has(newUserID)) {
      classMembersMap.set(newUserID, {
        userID: newUserID,
        isCameraStarted: Boolean(args.data.available),
      });
    } else {
      classMembersMap.set(newUserID, {
        ...classMembersMap.get(newUserID),
        isCameraStarted: Boolean(args.data.available),
      });
    }

    setClassMembersMap(new Map(classMembersMap));
  };

  const onUserAudioAvailable = (args: Record<string, any>) => {
    const newUserID = args.data.userID as string;

    // onUserAudioAvailable 事件通知有可能早于 onRemoteUserEnter 事件到达
    if (!classMembersMap.has(newUserID)) {
      classMembersMap.set(newUserID, {
        userID: newUserID,
        isMicStarted: Boolean(args.data.available),
      });
    } else {
      classMembersMap.set(newUserID, {
        ...classMembersMap.get(newUserID),
        isMicStarted: Boolean(args.data.available),
      });
    }

    setClassMembersMap(new Map(classMembersMap));
  };

  const onMessageListChange = (args: Record<string, any>) => {
    const newMessageList = messageList?.concat(args.data);
    setMessageList(newMessageList);
  };

  const onStudentRolled = (args: Record<string, any>) => {
    const newRolledList = rolledList?.concat(JSON.parse(args.data));
    setRolledList(newRolledList);
    console.log(`${logPrefix}.onStudentRolled args:`, args, rolledList);
  };

  // 注册事件监听
  useEffect(() => {
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.GET_GROUP_MEMBER_LIST,
      onGetGroupMemberList,
      {}
    );
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_CLASS_MEMBER_ENTER,
      onGroupMemberEnterRoom,
      {}
    );

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
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_CLASS_MEMBER_QUIT,
      onGroupMemberQuitRoom,
      {}
    );
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_CHAT_MESSAGE,
      onMessageListChange,
      {}
    );
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_CALL_ROLL_REPLY,
      onStudentRolled,
      {}
    );

    return () => {
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.GET_GROUP_MEMBER_LIST,
        onGetGroupMemberList
      );
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_CLASS_MEMBER_ENTER,
        onGroupMemberEnterRoom
      );

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
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_CLASS_MEMBER_QUIT,
        onGroupMemberQuitRoom
      );
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_CHAT_MESSAGE,
        onMessageListChange
      );
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_CALL_ROLL_REPLY,
        onStudentRolled
      );
    };
  }, [onGetGroupMemberList, onRemoteUserEnterRoom]);

  return {
    classMembersMap,
    messageList,
  };
}

export default useClassMember;
