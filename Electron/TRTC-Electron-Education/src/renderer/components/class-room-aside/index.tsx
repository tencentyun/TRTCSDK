import React, { useState, useEffect, useRef } from 'react';
import { TRTCVideoStreamType } from 'trtc-electron-sdk/liteav/trtc_define';
import { trtcUtil } from 'renderer/utils/trtc-edu-sdk';
import Bottom from '../class-room-aside-bottom';
import './index.scss';

function ClassAside(props: Record<string, any>) {
  const logPrefix = '[ClassAside]';
  console.warn(`${logPrefix} props:`, props);
  const [validUserList, setValidUserList] = useState<Array<any>>([]);
  const {
    currentUser,
    ownerID,
    toggleMicMuteState,
    classMembers,
    messageList,
  } = props;
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (trtcUtil.trtcEducation?.rtcCloud) {
      if (currentUser.role === 'teacher') {
        // 教师 - 预览白板和本地摄像头
        // To-do: 白板预览暂未实现
        // To-do: 角色抽取为枚举常量
        // To-do：ownerID 这个命名是基于 IM 群组的技术命名，不友好，按照业务场景改下名字，统一改为 teacher 或者 teacherID 比较好
        trtcUtil.trtcEducation.rtcCloud.startLocalPreview(ref.current);
      } else if (ownerID) {
        // 学生 - 预览老师摄像头
        trtcUtil.trtcEducation?.rtcCloud.startRemoteView(
          ownerID,
          ref.current,
          TRTCVideoStreamType.TRTCVideoStreamTypeBig
        );
      }
    }
  }, [currentUser.role, ownerID]);

  useEffect(() => {
    console.warn(`${logPrefix} useEffect calc validUserList`);
    if (ownerID && currentUser.role && classMembers?.length > 0) {
      if (currentUser.role === 'teacher') {
        const validData = classMembers.filter(
          (item: any) => item.userID !== ownerID
        );
        setValidUserList(validData);
      } else {
        // 学生时，排除老师（老师显示在右边栏上方区域），并将自己放在列表最前面
        // To-do: 待优化，同样代码出现在 student/home/index.tsx 中
        let isMicMuted = true;
        if (currentUser.isHandUpConfirmed) {
          // 举手被同意，优先级最高
          isMicMuted = currentUser.isMicMuted;
        } else {
          isMicMuted = currentUser.isMutedByTeacher || currentUser.isMicMuted;
        }

        const validData = [
          {
            userID: currentUser.userID,
            isMicStarted: currentUser.isMicStarted,
            isMicMuted,
            isCameraStarted: currentUser.isCameraStarted,
            isCameraMuted: currentUser.isCameraMuted,
            isLocal: currentUser.isLocal,
          },
        ].concat(
          classMembers.filter(
            (item: Record<string, any>) =>
              item.userID !== currentUser.userID && item.userID !== ownerID
          )
        );
        setValidUserList(validData);
      }
    }
  }, [
    currentUser.role,
    classMembers,
    currentUser.isHandUpConfirmed,
    currentUser.userID,
    currentUser.isMicStarted,
    currentUser.isCameraStarted,
    currentUser.isCameraMuted,
    currentUser.isLocal,
    currentUser.isMicMuted,
    currentUser.isMutedByTeacher,
    ownerID,
  ]);

  return (
    <div className="classAside">
      <div className="top" ref={ref} />
      <div className="bottom">
        {ownerID && (
          <Bottom
            userList={validUserList}
            toggleMicMuteState={toggleMicMuteState}
            classMembers={classMembers}
            messageList={messageList}
          />
        )}
      </div>
    </div>
  );
}

export default ClassAside;
