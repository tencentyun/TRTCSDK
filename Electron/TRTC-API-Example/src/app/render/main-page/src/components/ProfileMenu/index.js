import a18n from 'a18n';
import React, { useState } from 'react';
import Menu from '@material-ui/core/Menu';
import MenuItem from '@material-ui/core/MenuItem';
import IconButton from '@material-ui/core/IconButton';
import MenuIcon from '@material-ui/icons/Menu';
import GitHubIcon from '@material-ui/icons/GitHub';
import TranslateIcon from '@material-ui/icons/Translate';
import LanguageChange from '@components/LanguageChange';

import './index.scss';

export default function ProfileMenu(props) {
  const [isOpenMenu, setIsOpenMenu] = useState(false);
  const [anchorEl, setAnchorEl] = useState(null);
  const openMenu = (event) => {
    setIsOpenMenu(true);
    setAnchorEl(event.target);
  };

  const handleClose = () => {
    setIsOpenMenu(false);
  };

  const handleGitHub = () => {
    window.shell.openExternal('https://github.com/tencentyun/TRTCSDK/tree/master/Electron/TRTC-API-Example');
    handleClose();
  };

  const configList = [
    { key: 'language', icon: TranslateIcon, text: a18n('语言切换') },
    { key: 'github', icon: GitHubIcon, text: a18n('GitHub 地址'), callback: handleGitHub }
  ];

  return (
    <div className="profile-dropdown-menu">
      <IconButton
        aria-label="more"
        aria-controls="long-menu"
        aria-haspopup="true"
        onClick={openMenu}
        style={{ color: '#1890fe' }}
        className='more-menu'
      >
        <MenuIcon />
      </IconButton>

      <Menu
          id="simple-menu"
          keepMounted
          open={isOpenMenu}
          anchorEl={anchorEl}
          onClose={handleClose}
        >
        {
          configList.map(configItem => <MenuItem key={configItem.key} onClick={configItem.callback}>
              <configItem.icon style={{ color: '#1890fe', fontSize: '20px' }}></configItem.icon>
              <span className='profile-menu-item-text'>{configItem.text}</span>
              {configItem.key === 'language' && <LanguageChange toolTipsVisible={false}></LanguageChange>}
            </MenuItem>)
        }
      </Menu>
    </div>
  )
}