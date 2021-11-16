import React from 'react';
import VideocamSharpIcon from '@material-ui/icons/VideocamSharp';
import ComBaseToolIconButton from '../base';

interface PropsType {
  mode?: string;
}

function ComRecordController(props: PropsType) {
  const { mode } = props;
  const renderIcon = () => <VideocamSharpIcon />;
  const onIconClick = () => {
    console.log('[ComRecordController] clicked');
  };

  return (
    <ComBaseToolIconButton
      name="屏幕录制"
      mode={mode}
      renderIcon={renderIcon}
      onClickIcon={onIconClick}
    />
  );
}

ComRecordController.defaultProps = {
  mode: 'small',
};

export default ComRecordController;
