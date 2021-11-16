import React from 'react';
import IconButton from '@material-ui/core/IconButton';
import MouseIcon from '@material-ui/icons/Mouse';
import GestureIcon from '@material-ui/icons/Gesture';
import LinearScaleIcon from '@material-ui/icons/LinearScale';
import DeleteIcon from '@material-ui/icons/Delete';
import UndoIcon from '@material-ui/icons/Undo';
import RedoIcon from '@material-ui/icons/Redo';
import './white-board-draw-toolbar.scss';

function WhiteBoardDrawToolbar(props: Record<string, any>) {
  const {
    onChooseMouse,
    onChooseLine,
    onChooseRandomLine,
    onChooseErase,
    onUndo,
    onRedo
  } = props;
  return (
    <div className="white-board-draw-toolbar">
      <IconButton aria-label="mouse" onClick={onChooseMouse}>
        <MouseIcon />
      </IconButton>
      <IconButton aria-label="draw line" onClick={onChooseLine}>
        <LinearScaleIcon />
      </IconButton>
      <IconButton aria-label="draw random line" onClick={onChooseRandomLine}>
        <GestureIcon />
      </IconButton>
      <IconButton aria-label="delete graphic" onClick={onChooseErase}>
        <DeleteIcon />
      </IconButton>
      <IconButton aria-label="Undo" onClick={onUndo}>
        <UndoIcon />
      </IconButton>
      <IconButton aria-label="Redo" onClick={onRedo}>
        <RedoIcon />
      </IconButton>
    </div>
  );
}

export default WhiteBoardDrawToolbar;
