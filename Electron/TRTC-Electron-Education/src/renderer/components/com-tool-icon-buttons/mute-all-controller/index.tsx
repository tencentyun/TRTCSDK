import React from 'react';
import MicOffSharpIcon from '@material-ui/icons/MicOffSharp';
import MicSharpIcon from '@material-ui/icons/MicSharp';
import ComBaseToolIconButton from '../base';

interface PropsType {
  mode?: string;
  isMute?: boolean;
  onMuteAllStudent: () => void;
}

function ComMuteAllController(props: PropsType) {
  const { mode, isMute, onMuteAllStudent } = props;
  const renderIcon = () => {
    return <>{isMute ? <MicOffSharpIcon /> : <MicSharpIcon />}</>;
  };
  const onIconClick = () => {
    console.log('[ComMuteAllController] clicked');
    onMuteAllStudent();
  };

  return (
    <ComBaseToolIconButton
      name="全员禁麦"
      muted={isMute}
      mode={mode}
      renderIcon={renderIcon}
      onClickIcon={onIconClick}
    />
  );
}

ComMuteAllController.defaultProps = {
  mode: 'small',
  isMute: false,
};

export default ComMuteAllController;
