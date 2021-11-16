import React from 'react';
import Button from '@material-ui/core/Button';
import UpdateSharpIcon from '@material-ui/icons/UpdateSharp';
import { TRTCDeviceInfo } from 'trtc-electron-sdk/liteav/trtc_define';
import ComHandUpController from '../com-tool-icon-buttons/hand-up-controller';
import ComInstantMessageController from '../com-tool-icon-buttons/instant-message-controller';
import ComRoasterController from '../com-tool-icon-buttons/roster-controller';
import ComMicrophoneController from '../com-tool-icon-buttons/microphone-controller';
import ComCameraController from '../com-tool-icon-buttons/camera-controller';
import ComShareScreenController from '../com-tool-icon-buttons/share-screen-controller';
import ComMuteAllController from '../com-tool-icon-buttons/mute-all-controller';
import ComRecordController from '../com-tool-icon-buttons/record-controller';
import ComAnnotationController from '../com-tool-icon-buttons/annotation-controller';
import ComSettingController from '../com-tool-icon-buttons/setting-controller';
import ComRollCallController from '../com-tool-icon-buttons/roll-call-controller';
import Time from '../class-room-title-time/index';
import './index.scss';

interface ClassToolProps {
  onChangeSharing: () => void;
  onStopSharing: () => void;
  isCameraMuted: boolean;
  cameraList: Array<TRTCDeviceInfo>;
  currentCameraId: string | null;
  resetCurrentCamera: (id: string) => void;
  updateCameraMuteState: (mute: boolean) => void;
  isMicMuted: boolean;
  microphoneList: Array<TRTCDeviceInfo>;
  currentMicId: string | null;
  resetCurrentMicrophone: (id: string) => void;
  updateMicMuteState: (mute: boolean) => void;
  speakerList: Array<TRTCDeviceInfo>;
  currentSpeakerId: string | undefined | null;
  resetCurrentSpeaker: (id: string) => void;
  isAllStudentMuted: boolean;
  callRollTime: number;
  onMuteAllStudent: () => void;
  onCallAllStudent: () => void;
  handsUpList?: Array<any> | undefined;
  handsUpHandler: (event: React.MouseEvent<HTMLElement> | string) => void;
  onHandsUpPopClose?: () => void;
  enterRoomTime: number | null;
  isRolled?: boolean;
}

function ClassTool(props: ClassToolProps) {
  const {
    onChangeSharing,
    onStopSharing,
    isCameraMuted,
    cameraList,
    currentCameraId,
    resetCurrentCamera,
    updateCameraMuteState,
    isMicMuted,
    microphoneList,
    currentMicId,
    resetCurrentMicrophone,
    updateMicMuteState,
    speakerList,
    currentSpeakerId,
    resetCurrentSpeaker,
    isAllStudentMuted,
    onMuteAllStudent,
    handsUpList,
    handsUpHandler,
    onHandsUpPopClose,
    enterRoomTime,
    onCallAllStudent,
    callRollTime,
    isRolled,
  } = props;

  return (
    <div className="trtc-edu-class-tool">
      <ComHandUpController
        name="举手列表"
        handsUpList={handsUpList}
        onClick={handsUpHandler}
        onPopClose={onHandsUpPopClose}
      />
      <ComInstantMessageController />
      <ComRollCallController
        onCallAllStudent={onCallAllStudent}
        callRollTime={callRollTime}
        isRolled={isRolled}
      />
      <ComRoasterController />

      <div className="vertical-line" />

      <ComCameraController
        isMute={isCameraMuted}
        cameraList={cameraList}
        currentId={currentCameraId}
        resetCurrentCamera={resetCurrentCamera}
        updateMuteState={updateCameraMuteState}
      />
      <ComMicrophoneController
        isMute={isMicMuted}
        microphoneList={microphoneList}
        currentId={currentMicId}
        resetCurrentMicrophone={resetCurrentMicrophone}
        updateMuteState={updateMicMuteState}
        speakerList={speakerList}
        currentSpeakerId={currentSpeakerId}
        resetCurrentSpeaker={resetCurrentSpeaker}
      />
      <ComShareScreenController onChangeSharing={onChangeSharing} />
      <ComMuteAllController
        onMuteAllStudent={onMuteAllStudent}
        isMute={isAllStudentMuted}
      />
      <ComRecordController />
      <ComAnnotationController />

      <div className="vertical-line" />

      <ComSettingController />

      <div className="class-info">
        <div className="class-time-span">
          <UpdateSharpIcon />
          <Time enterRoomTime={enterRoomTime} />
        </div>
        <div>
          <Button variant="contained" color="secondary" onClick={onStopSharing}>
            Stop Sharing
          </Button>
        </div>
      </div>
    </div>
  );
}

ClassTool.defaultProps = {
  handsUpList: undefined,
  onHandsUpPopClose: () => {},
  isRolled: false,
};

export default ClassTool;
