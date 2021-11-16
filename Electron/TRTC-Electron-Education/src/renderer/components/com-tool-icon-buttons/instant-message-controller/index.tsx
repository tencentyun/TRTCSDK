import React from 'react';
import TextsmsIcon from '@material-ui/icons/Textsms';
import ComBaseToolIconButton from '../base';

function ComInstantMessageController() {
  const renderIcon = () => <TextsmsIcon />;
  const onIconClick = () => {
    console.log('[ComInstantMessageController] clicked');
  };

  return (
    <ComBaseToolIconButton
      name="消息"
      renderIcon={renderIcon}
      onClickIcon={onIconClick}
    />
  );
}

export default ComInstantMessageController;
