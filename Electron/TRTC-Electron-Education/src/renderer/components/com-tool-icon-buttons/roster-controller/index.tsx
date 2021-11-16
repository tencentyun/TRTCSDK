import React from 'react';
import PeopleAltSharpIcon from '@material-ui/icons/PeopleAltSharp';
import ComBaseToolIconButton from '../base';

interface ComRoasterControllerPropsType {
  mode?: string;
}

function ComRoasterController(props: ComRoasterControllerPropsType) {
  const { mode } = props;
  const renderIcon = () => <PeopleAltSharpIcon />;
  const onIconClick = () => {
    console.log('[ComRoasterController] clicked');
  };

  return (
    <ComBaseToolIconButton
      name="花名册"
      mode={mode}
      renderIcon={renderIcon}
      onClickIcon={onIconClick}
    />
  );
}

ComRoasterController.defaultProps = {
  mode: 'small',
};

export default ComRoasterController;
