import React from 'react';
import LocationOnOutlinedIcon from '@material-ui/icons/LocationOnOutlined';
import ComBaseToolIconButton from '../base';

interface PropsType {
  mode?: string;
  callRollTime?: number;
  onCallAllStudent: () => void;
  isRolled?: boolean;
}
function ComRollCallController(props: PropsType) {
  const { mode, callRollTime, onCallAllStudent, isRolled } = props;
  const renderIcon = () => <LocationOnOutlinedIcon />;
  const onIconClick = () => {
    console.log('[ComRollCallController] clicked');
    if (!isRolled) {
      onCallAllStudent();
    } else {
      alert('签到时间还未结束！');
    }
  };

  return (
    <ComBaseToolIconButton
      name="点名"
      mode={mode}
      renderIcon={renderIcon}
      onClickIcon={onIconClick}
    />
  );
}

ComRollCallController.defaultProps = {
  mode: 'small',
  callRollTime: 0,
  isRolled: false,
};

export default ComRollCallController;
