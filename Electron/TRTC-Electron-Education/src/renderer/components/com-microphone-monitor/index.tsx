import React from 'react';
import MicIcon from '@material-ui/icons/Mic';
import MicOffIcon from '@material-ui/icons/MicOff';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import CheckIcon from '@material-ui/icons/Check';
import Popover from '@material-ui/core/Popover';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import { TRTCDeviceInfo } from 'trtc-electron-sdk/liteav/trtc_define';
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

interface ComMicrophoneMonitorProps {
  isMute: boolean;
  microphoneList: Array<TRTCDeviceInfo>;
  currentId?: string | undefined | null;
  resetCurrentMicrophone: (id: string) => void;
  updateMuteState: (mute: boolean) => void;
}

function ComMicrophoneMonitor(props: ComMicrophoneMonitorProps) {
  const {
    isMute,
    microphoneList,
    currentId,
    resetCurrentMicrophone,
    updateMuteState,
  } = props;
  const [anchorEl, setAnchorEl] = React.useState<HTMLDivElement | null>(null);

  const popOpenHandler = (event: React.MouseEvent<HTMLDivElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const popCloseHandler = () => {
    setAnchorEl(null);
  };

  const onMicrophoneChange = (newDeviceId: string) => {
    setAnchorEl(null);

    if (currentId === newDeviceId) {
      return;
    }

    if (resetCurrentMicrophone) {
      resetCurrentMicrophone(newDeviceId);
    }
  };

  const toggleMuteStatus = () => {
    updateMuteState(!isMute);
  };

  const open = Boolean(anchorEl);
  const id = open ? 'microphone-select-popover' : undefined;

  return (
    <div className="com-microphone-monitor">
      <div className="icon-content" onClick={toggleMuteStatus}>
        <div className="icon-status">
          {isMute ? <MicOffIcon /> : <MicIcon />}
        </div>
        <div className="title">Mic</div>
      </div>
      <div className="icon-selector" onClick={popOpenHandler}>
        <ExpandMoreIcon />
      </div>
      <Popover
        id={id}
        open={open}
        anchorEl={anchorEl}
        className="com-microphone-popover"
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
        {MicrophoneList(microphoneList, currentId, onMicrophoneChange)}
      </Popover>
    </div>
  );
}

ComMicrophoneMonitor.defaultProps = {
  currentId: '',
};

export default ComMicrophoneMonitor;
