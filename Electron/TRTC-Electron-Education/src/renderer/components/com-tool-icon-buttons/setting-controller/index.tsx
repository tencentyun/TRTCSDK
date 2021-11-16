import React from 'react';
import SettingsSharpIcon from '@material-ui/icons/SettingsSharp';
import ComBaseToolIconButton from '../base';

interface PropsType {
  mode?: string;
  onClick?: () => void;
}

function ComSettingController(props: PropsType) {
  const { mode, onClick } = props;
  const renderIcon = () => <SettingsSharpIcon />;
  const onIconClick = () => {
    console.log('[ComSettingController] clicked');
    onClick();
  };

  return (
    <ComBaseToolIconButton
      name="设置"
      mode={mode}
      renderIcon={renderIcon}
      onClickIcon={onIconClick}
    />
  );
}

ComSettingController.defaultProps = {
  mode: 'small',
  onClick: () => {},
};

export default ComSettingController;
