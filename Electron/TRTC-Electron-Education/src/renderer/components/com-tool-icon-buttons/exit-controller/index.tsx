import React from 'react';
import ExitToAppOutlinedIcon from '@material-ui/icons/ExitToAppOutlined';
import { trtcUtil } from 'renderer/utils/trtc-edu-sdk';
import ComBaseToolIconButton from '../base';

interface PropsType {
  mode?: string;
  onExit: () => void;
}

function ComExitController(props: PropsType) {
  const { mode, onExit } = props;
  const renderIcon = () => <ExitToAppOutlinedIcon />;
  const onIconClick = () => {
    console.log('[ComExitController] clicked');
    onExit();
  };

  return (
    <ComBaseToolIconButton
      name={trtcUtil.trtcEducation?.role === 'teacher' ? '下课' : '离开教室'}
      mode={mode}
      renderIcon={renderIcon}
      onClickIcon={onIconClick}
    />
  );
}

ComExitController.defaultProps = {
  mode: 'small',
};

export default ComExitController;
