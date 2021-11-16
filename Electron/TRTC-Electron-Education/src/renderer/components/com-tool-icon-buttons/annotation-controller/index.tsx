import React from 'react';
import QuestionAnswerSharpIcon from '@material-ui/icons/QuestionAnswerSharp';
import ComBaseToolIconButton from '../base';

function ComAnnotationController() {
  const renderIcon = () => <QuestionAnswerSharpIcon />;
  const onIconClick = () => {
    console.log('[ComAnnotationController] clicked');
  };

  return (
    <ComBaseToolIconButton
      name="互动批注"
      renderIcon={renderIcon}
      onClickIcon={onIconClick}
    />
  );
}

export default ComAnnotationController;
