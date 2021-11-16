import React, { useState, useEffect } from 'react';
import SettingsSharpIcon from '@material-ui/icons/SettingsSharp';
import VideocamIcon from '@material-ui/icons/Videocam';
import VideocamOffIcon from '@material-ui/icons/VideocamOff';
import MicIcon from '@material-ui/icons/Mic';
import MicOffIcon from '@material-ui/icons/MicOff';
import Dialog from '@material-ui/core/Dialog';
import DialogTitle from '@material-ui/core/DialogTitle';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import './index.scss';

function ComSetting(props: Record<string, any>) {
  const [isOpen, setIsOpen] = useState(false);

  const toggleSettingDialog = () => {
    setIsOpen(!isOpen);
  };

  const onClose = () => {
    setIsOpen(!isOpen);
  };

  return (
    <div className="com-setting">
      <SettingsSharpIcon onClick={toggleSettingDialog} />
      <Dialog
        open={isOpen}
        onClose={onClose}>
        <DialogContent>

        </DialogContent>
      </Dialog>
    </div>
  );
}

export default ComSetting;
