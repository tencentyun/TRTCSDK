import React from 'react';
import MicIcon from '@material-ui/icons/Mic';
import MicOffIcon from '@material-ui/icons/MicOff';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import CheckIcon from '@material-ui/icons/Check';
import { TRTCDeviceInfo } from 'trtc-electron-sdk/liteav/trtc_define';
import ComBaseToolIconButton from '../base';
import './index.scss';

function MicrophoneList(
  micList: Array<any>,
  currentMicId: string | undefined | null,
  handleUpdateCurrentMic: (id: any) => void
) {
  return (
    <List dense className="microphone-device-list">
      {[...micList].map((mic) => {
        return (
          <ListItem
            className="microphone-device-item"
            onClick={() => handleUpdateCurrentMic(mic.deviceId)}
            key={mic.deviceId}
          >
            <div className="check-wrapper">
              {mic.deviceId === currentMicId ? <CheckIcon /> : null}
            </div>
            <div className="device-name">{mic.deviceName}</div>
          </ListItem>
        );
      })}
    </List>
  );
}

function SpeakerList(
  speakerList: Array<any>,
  currentSpeakerId: string | undefined | null,
  handleUpdateCurrentSpeaker: (id: any) => void
) {
  return (
    <List dense className="speaker-device-list">
      {[...speakerList].map((speaker) => {
        return (
          <ListItem
            className="speaker-device-item"
            onClick={() => handleUpdateCurrentSpeaker(speaker.deviceId)}
            key={speaker.deviceId}
          >
            <div className="check-wrapper">
              {speaker.deviceId === currentSpeakerId ? <CheckIcon /> : null}
            </div>
            <div className="device-name">{speaker.deviceName}</div>
          </ListItem>
        );
      })}
    </List>
  );
}

interface ComMicrophoneControllerProps {
  mode?: string;
  isMute: boolean;
  microphoneList: Array<TRTCDeviceInfo>;
  currentId?: string | undefined | null;
  resetCurrentMicrophone: (id: string) => void;
  updateMuteState: (mute: boolean) => void;
  speakerList: Array<TRTCDeviceInfo>;
  currentSpeakerId: string | undefined | null;
  resetCurrentSpeaker: (id: string) => void;
}

function ComMicrophoneController(props: ComMicrophoneControllerProps) {
  const {
    mode,
    isMute,
    microphoneList,
    currentId,
    resetCurrentMicrophone,
    updateMuteState,
    speakerList,
    currentSpeakerId,
    resetCurrentSpeaker,
  } = props;

  const onMicrophoneChange = (newDeviceId: string) => {
    if (currentId === newDeviceId) {
      return;
    }

    if (resetCurrentMicrophone) {
      resetCurrentMicrophone(newDeviceId);
    }
  };

  const onSpeakerChange = (newDeviceId: string) => {
    if (currentSpeakerId === newDeviceId) {
      return;
    }

    if (resetCurrentSpeaker) {
      resetCurrentSpeaker(newDeviceId);
    }
  };

  const renderIcon = () => {
    return <>{isMute ? <MicOffIcon /> : <MicIcon />}</>;
  };

  const renderPopoverSelect = () => {
    // return MicrophoneList(microphoneList, currentId, onMicrophoneChange);
    return (
      <div className="device-select-popover">
        <div className="device-list-title">麦克风</div>
        {MicrophoneList(microphoneList, currentId, onMicrophoneChange)}
        <div className="device-list-title">扬声器</div>
        {SpeakerList(speakerList, currentSpeakerId, onSpeakerChange)}
      </div>
    );
  };

  const toggleMuteStatus = () => {
    updateMuteState(!isMute);
  };

  return (
    <ComBaseToolIconButton
      name="麦克风"
      muted={isMute}
      mode={mode}
      renderIcon={renderIcon}
      onClickIcon={toggleMuteStatus}
      hasPopover
      renderPopover={renderPopoverSelect}
    />
  );
}

ComMicrophoneController.defaultProps = {
  currentId: '',
  mode: 'small',
};

export default ComMicrophoneController;
