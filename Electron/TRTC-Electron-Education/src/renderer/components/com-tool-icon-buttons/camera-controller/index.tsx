import React from 'react';
import VideocamIcon from '@material-ui/icons/Videocam';
import VideocamOffIcon from '@material-ui/icons/VideocamOff';
import CheckIcon from '@material-ui/icons/Check';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import { TRTCDeviceInfo } from 'trtc-electron-sdk/liteav/trtc_define';
import ComBaseToolIconButton from '../base';
import './index.scss';

function CameraList(
  camList: Array<any>,
  currentCamId: string | undefined | null,
  handleUpdateCurrentCam: (id: any) => void
) {
  return (
    <List dense className="camera-device-list">
      {[...camList].map((cam) => {
        return (
          <ListItem
            className="camera-device-item"
            key={cam.deviceId}
            onClick={() => handleUpdateCurrentCam(cam.deviceId)}
          >
            <div className="check-wrapper">
              {cam.deviceId === currentCamId ? <CheckIcon /> : null}
            </div>
            <div className="device-name">{cam.deviceName}</div>
          </ListItem>
        );
      })}
    </List>
  );
}

interface ComCameraControllerProps {
  mode?: string;
  isMute: boolean;
  cameraList: Array<TRTCDeviceInfo>;
  currentId?: string | undefined | null;
  resetCurrentCamera: (id: string) => void;
  updateMuteState: (mute: boolean) => void;
}

function ComCameraController(props: ComCameraControllerProps) {
  const {
    mode,
    isMute,
    cameraList,
    currentId,
    resetCurrentCamera,
    updateMuteState,
  } = props;

  const onCameraChange = (newDeviceId: string) => {
    if (currentId === newDeviceId) {
      return;
    }

    if (resetCurrentCamera) {
      resetCurrentCamera(newDeviceId);
    }
  };

  const renderIcon = () => {
    return <>{isMute ? <VideocamOffIcon /> : <VideocamIcon />}</>;
  };

  const renderPopoverSelect = () => {
    return CameraList(cameraList, currentId, onCameraChange);
  };

  const toggleMuteStatus = () => {
    updateMuteState(!isMute);
  };

  return (
    <ComBaseToolIconButton
      name="摄像头"
      muted={isMute}
      mode={mode}
      renderIcon={renderIcon}
      onClickIcon={toggleMuteStatus}
      hasPopover
      renderPopover={renderPopoverSelect}
    />
  );
}

ComCameraController.defaultProps = {
  currentId: '',
  mode: 'small',
};

export default ComCameraController;
