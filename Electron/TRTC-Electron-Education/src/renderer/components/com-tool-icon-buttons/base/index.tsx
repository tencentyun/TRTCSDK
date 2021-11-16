import React, { ReactNode } from 'react';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import Popover from '@material-ui/core/Popover';
import IconButton from '@material-ui/core/IconButton';
import './index.scss';
// 在这边需要向学生展示一个签到
interface ComBaseIconButtonProps {
  muted?: boolean;
  mode?: string;
  onClickIcon: (event: React.MouseEvent<HTMLElement>) => void;
  renderIcon: () => ReactNode;
  name: string;
  hasPopover?: boolean;
  renderPopover?: () => ReactNode;
}

function ComBaseIconButton(props: ComBaseIconButtonProps) {
  const {
    muted,
    mode,
    onClickIcon,
    renderIcon,
    name,
    hasPopover,
    renderPopover,
  } = props;

  const [anchorEl, setAnchorEl] = React.useState<HTMLDivElement | null>(null);

  const popOpenHandler = (event: React.MouseEvent<HTMLDivElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const popCloseHandler = () => {
    setAnchorEl(null);
  };

  const onPopoverClick = () => {
    popCloseHandler();
  };

  const open = Boolean(anchorEl);
  const id = open ? 'com-tool-icon-button-popover' : undefined;

  return (
    <div className={`com-tool-icon-button-base com-tool-icon-${mode}`}>
      <div className="icon-content" onClick={onClickIcon}>
        <IconButton className={`icon-button ${muted ? 'muted' : ''}`}>
          {renderIcon()}
        </IconButton>
        <div className="icon-title">{name}</div>
      </div>
      {hasPopover && (
        <>
          <div className="icon-selector" onClick={popOpenHandler}>
            <ExpandMoreIcon />
          </div>
          <Popover
            id={id}
            open={open}
            anchorEl={anchorEl}
            className="trtc-edu-popover"
            onClose={popCloseHandler}
            anchorOrigin={{
              vertical: 'top',
              horizontal: 'right',
            }}
            transformOrigin={{
              vertical: 'top',
              horizontal: 'left',
            }}
          >
            <div className="popover-content" onClick={onPopoverClick}>
              {renderPopover && renderPopover()}
            </div>
          </Popover>
        </>
      )}
    </div>
  );
}

ComBaseIconButton.defaultProps = {
  muted: false,
  mode: 'small',
  hasPopover: false,
  renderPopover: () => {},
};

export default ComBaseIconButton;
