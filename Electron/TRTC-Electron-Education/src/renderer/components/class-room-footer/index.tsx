import React, { useState, useEffect } from 'react';
import {
  TRTCScreenCaptureSourceInfo,
  TRTCDeviceInfo,
} from 'trtc-electron-sdk/liteav/trtc_define';
import { trtcUtil } from 'renderer/utils/trtc-edu-sdk';
import ComHandUpController from '../com-tool-icon-buttons/hand-up-controller';
import ComRoasterController from '../com-tool-icon-buttons/roster-controller';
import ComCameraController from '../com-tool-icon-buttons/camera-controller';
import ComShareScreenController from '../com-tool-icon-buttons/share-screen-controller';
import ComMicrophoneController from '../com-tool-icon-buttons/microphone-controller';
import ShareScreenSelectionDialog from '../share-screen-selection-dialog';
import ComMuteAllController from '../com-tool-icon-buttons/mute-all-controller';
import ComRecordController from '../com-tool-icon-buttons/record-controller';
import ComSettingController from '../com-tool-icon-buttons/setting-controller';
import ComRollCallController from '../com-tool-icon-buttons/roll-call-controller';
import ComExitController from '../com-tool-icon-buttons/exit-controller';
import { USER_EVENT_NAME } from '../../../constants';

import './index.scss';

interface ClassRoomFooterProps {
  onStartSharing?: (screenSource: TRTCScreenCaptureSourceInfo | null) => void;
  userInfo: Record<string, unknown>;
  isCameraMute: boolean;
  cameraList: Array<TRTCDeviceInfo>;
  currentCameraId: string | null;
  resetCurrentCamera: (id: string) => void;
  updateCameraMuteState: (mute: boolean) => void;
  isMicMute: boolean;
  microphoneList: Array<TRTCDeviceInfo>;
  currentMicId: string | null;
  resetCurrentMicrophone: (id: string) => void;
  updateMicMuteState: (mute: boolean) => void;
  preselectedScreen?: string | '';
  speakerList: Array<TRTCDeviceInfo>;
  currentSpeakerId: string | undefined | null;
  resetCurrentSpeaker: (id: string) => void;
  isAllStudentMuted?: boolean;
  onMuteAllStudent?: () => void;
  handsUpList?: Array<any> | undefined;
  handsUpHandler: (event: React.MouseEvent<HTMLElement> | string) => void;
  onHandsUpPopClose?: () => void;
  callRollTime?: number;
  onCallAllStudent?: () => void;
  isRolled?: boolean;
}

function ClassFooter(props: ClassRoomFooterProps) {
  const logPrefix = '[ClassFooter]';
  console.warn(`${logPrefix}.props:`, props);
  const {
    onStartSharing,
    userInfo,
    isCameraMute,
    cameraList,
    currentCameraId,
    resetCurrentCamera,
    updateCameraMuteState,
    isMicMute,
    microphoneList,
    currentMicId,
    resetCurrentMicrophone,
    updateMicMuteState,
    preselectedScreen,
    speakerList,
    currentSpeakerId,
    resetCurrentSpeaker,
    isAllStudentMuted,
    onMuteAllStudent,
    handsUpList,
    handsUpHandler,
    onCallAllStudent,
    onHandsUpPopClose,
    callRollTime,
    isRolled,
  } = props;
  const [isShareSelectionVisible, setIsShareSelectionVisible] = useState(false);
  const [isSettingModalOpen, setIsSettingModalOpen] = useState(false);
  const onCancelShareSelection = () => {
    setIsShareSelectionVisible(false);
  };

  const onConfirmShareSelection = (
    id: string,
    screenSource: TRTCScreenCaptureSourceInfo | null
  ) => {
    // @ts-ignore
    onStartSharing(screenSource);
    setIsShareSelectionVisible(false);
  };

  const onLeaveRoom = () => {
    trtcUtil.trtcEducation?.exitClassRoom();
    if (userInfo.role === 'teacher') {
      (window as any).electron.ipcRenderer.send(
        USER_EVENT_NAME.EXIT_CLASS_ROOM,
        {}
      );
    } else {
      (window as any).electron.ipcRenderer.send(
        USER_EVENT_NAME.STUDENT_EXIT_CLASS_ROOM,
        {}
      );
    }
  };

  // 注册窗口关闭事件，点用离开教室的事件处理函数
  useEffect(() => {
    window.addEventListener('beforeunload', onLeaveRoom, false);
    return () => {
      window.removeEventListener('beforeunload', onLeaveRoom, false);
    };
  });

  const toggleSettingModal = () => {
    setIsSettingModalOpen(!isSettingModalOpen);
  };

  return (
    <div className="footer-tool">
      <ComHandUpController
        mode="big"
        name={userInfo.role === 'teacher' ? '举手列表' : '举手'}
        handsUpList={handsUpList}
        onClick={handsUpHandler}
        onPopClose={onHandsUpPopClose}
      />
      {userInfo.role === 'teacher' && (
        <ComRollCallController
          mode="big"
          // @ts-ignore
          onCallAllStudent={onCallAllStudent}
          callRollTime={callRollTime}
          isRolled={isRolled}
        />
      )}
      {userInfo.role === 'teacher' && <ComRoasterController mode="big" />}
      <div className="vertical-line" />
      <ComCameraController
        mode="big"
        isMute={isCameraMute}
        cameraList={cameraList}
        currentId={currentCameraId}
        resetCurrentCamera={resetCurrentCamera}
        updateMuteState={updateCameraMuteState}
      />
      <ComMicrophoneController
        mode="big"
        isMute={isMicMute}
        microphoneList={microphoneList}
        currentId={currentMicId}
        resetCurrentMicrophone={resetCurrentMicrophone}
        updateMuteState={updateMicMuteState}
        speakerList={speakerList}
        currentSpeakerId={currentSpeakerId}
        resetCurrentSpeaker={resetCurrentSpeaker}
      />
      {userInfo.role === 'teacher' && (
        <ComShareScreenController
          mode="big"
          onChangeSharing={() => setIsShareSelectionVisible(true)}
        />
      )}
      {userInfo.role === 'teacher' && onMuteAllStudent && (
        <ComMuteAllController
          mode="big"
          onMuteAllStudent={onMuteAllStudent}
          isMute={isAllStudentMuted}
        />
      )}
      {userInfo.role === 'teacher' && <ComRecordController mode="big" />}
      <ComSettingController mode="big" onClick={toggleSettingModal} />
      <div className="vertical-line" />
      <ComExitController mode="big" onExit={onLeaveRoom} />
      <ShareScreenSelectionDialog
        show={isShareSelectionVisible}
        onCancel={onCancelShareSelection}
        onConfirm={onConfirmShareSelection}
        preselected={preselectedScreen}
      />
    </div>
  );
}

ClassFooter.defaultProps = {
  onStartSharing: () => {},
  preselectedScreen: '',
  isAllStudentMuted: false,
  onMuteAllStudent: () => {},
  handsUpList: undefined,
  onHandsUpPopClose: () => {},
  callRollTime: 0,
  onCallAllStudent: () => {},
  isRolled: false,
};

export default ClassFooter;
