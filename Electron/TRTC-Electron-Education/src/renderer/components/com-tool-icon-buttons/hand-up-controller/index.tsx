import React from 'react';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import Popover from '@material-ui/core/Popover';
import PanToolOutlined from '@material-ui/icons/PanToolOutlined';
import IconButton from '@material-ui/core/IconButton';
import MicIcon from '@material-ui/icons/Mic';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import ComBaseToolIconButton from '../base';

import './index.scss';

interface PropsType {
  name: string;
  mode?: string;
  handsUpList?: Array<any> | undefined;
  onClick: (event: React.MouseEvent<HTMLElement> | string) => void;
  onPopClose?: () => void;
}

function ComHandUpController(props: PropsType) {
  const { name, mode, handsUpList, onClick, onPopClose } = props;
  const renderIcon = () => <PanToolOutlined />;
  const onIconClick = (event: React.MouseEvent<HTMLElement>) => {
    console.log('[ComHandUpController] clicked');
    if (onClick) {
      onClick(event);
    }
  };

  const [anchorEl, setAnchorEl] = React.useState<HTMLDivElement | null>(null);

  const popOpenHandler = (event: React.MouseEvent<HTMLDivElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const popCloseHandler = () => {
    setAnchorEl(null);
    if (onPopClose) {
      onPopClose();
    }
  };

  const open = Boolean(anchorEl);
  const id = open ? 'com-tool-icon-button-popover' : undefined;

  const renderPopoverContent = () => {
    return (
      <div className="hands-up-popover-content">
        <div className="hands-up-popover-toolbar">
          <IconButton
            className="trtc-edu-icon-button"
            onClick={popCloseHandler}
          />
        </div>
        <List dense className="hands-up-list">
          {handsUpList !== undefined && handsUpList.length >= 1 ? (
            handsUpList.map((item: string) => {
              return (
                <ListItem className="hands-up-list-item" key={item}>
                  <div className="hands-up-info">{item}</div>
                  <div className="icon-group">
                    <IconButton
                      className="trtc-edu-icon-button"
                      onClick={() => onClick(item)}
                    >
                      <MicIcon />
                    </IconButton>
                  </div>
                </ListItem>
              );
            })
          ) : (
            <ListItem className="hands-up-list-item" key="empty">
              无数据
            </ListItem>
          )}
        </List>
      </div>
    );
  };

  let content = null;
  if (handsUpList !== undefined) {
    content = (
      <div
        className={`com-tool-icon-hand-up com-tool-icon-button-base com-tool-icon-${mode}`}
      >
        <div className="icon-content">
          <IconButton
            className={`icon-button ${
              handsUpList?.length > 0 ? 'icon-notification' : ''
            }`}
          >
            {renderIcon()}
          </IconButton>
          <div className="icon-title">{name}</div>
        </div>
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
          <div className="popover-content">{renderPopoverContent()}</div>
        </Popover>
      </div>
    );
  } else {
    content = (
      <ComBaseToolIconButton
        name="举手"
        mode={mode}
        renderIcon={renderIcon}
        onClickIcon={onIconClick}
      />
    );
  }

  return content;
}

ComHandUpController.defaultProps = {
  mode: 'small',
  handsUpList: undefined,
  onPopClose: () => {},
};

export default ComHandUpController;
