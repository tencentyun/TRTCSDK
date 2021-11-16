import React from 'react';
import VideocamIcon from '@material-ui/icons/Videocam';
import VideocamOffIcon from '@material-ui/icons/VideocamOff';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import CheckIcon from '@material-ui/icons/Check';
import Popover from '@material-ui/core/Popover';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import { TRTCDeviceInfo } from 'trtc-electron-sdk/liteav/trtc_define';
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

interface ComCameraMonitorProps {
  isMute: boolean;
  cameraList: Array<TRTCDeviceInfo>;
  currentId?: string | undefined | null;
  resetCurrentCamera: (id: string) => void;
  updateMuteState: (mute: boolean) => void;
}

function ComCameraMonitor(props: ComCameraMonitorProps) {
  const { isMute, cameraList, currentId, resetCurrentCamera, updateMuteState } =
    props;

  const [anchorEl, setAnchorEl] = React.useState<HTMLDivElement | null>(null);

  const popOpenHandler = (event: React.MouseEvent<HTMLDivElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const popCloseHandler = () => {
    setAnchorEl(null);
  };

  const open = Boolean(anchorEl);
  const id = open ? 'camera-select-popover' : undefined;

  const onCameraChange = (newDeviceId: string) => {
    setAnchorEl(null);

    if (currentId === newDeviceId) {
      return;
    }

    if (resetCurrentCamera) {
      resetCurrentCamera(newDeviceId);
    }
  };

  const toggleMuteStatus = () => {
    updateMuteState(!isMute);
  };

  return (
    <div className="com-camera-monitor">
      <div className="icon-content" onClick={toggleMuteStatus}>
        <div className="icon-status">
          {isMute ? <VideocamOffIcon /> : <VideocamIcon />}
        </div>
        <div className="title">Camera</div>
      </div>
      <div className="icon-selector" onClick={popOpenHandler}>
        <ExpandMoreIcon />
      </div>
      <Popover
        id={id}
        open={open}
        anchorEl={anchorEl}
        className="com-camera-popover"
        onClose={popCloseHandler}
        anchorOrigin={{
          vertical: 'top',
          horizontal: 'right',
        }}
        transformOrigin={{
          vertical: 'top',
          horizontal: 'left',
        }}
      >
        {CameraList(cameraList, currentId, onCameraChange)}
      </Popover>
    </div>
  );
}

ComCameraMonitor.defaultProps = {
  currentId: '',
};

export default ComCameraMonitor;
