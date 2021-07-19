import a18n from 'a18n';
import React, { useState } from 'react';
import styles from './index.module.scss';
import Cookies from 'js-cookie';
import { goToPage } from '@utils/common';
import clsx from 'clsx';
import Menu from '@material-ui/core/Menu';
import MenuItem from '@material-ui/core/MenuItem';
import IconButton from '@material-ui/core/IconButton';
import MoreVertIcon from '@material-ui/icons/MoreVert';
import PermIdentityOutlinedIcon from '@material-ui/icons/PermIdentityOutlined';
import TranslateIcon from '@material-ui/icons/Translate';
import ShareIcon from '@material-ui/icons/Share';
import QueuePlayNextIcon from '@material-ui/icons/QueuePlayNext';
import PowerSettingsNewIcon from '@material-ui/icons/PowerSettingsNew';
import GitHubIcon from '@material-ui/icons/GitHub';
import LanguageChange from '@components/LanguageChange';
import DeviceDetector from '@components/DeviceDetector';
import toast from '@components/Toast';

function TopBar({ title, isMobile = false }) {
  const [isOpenMenu, setIsOpenMenu] = useState(false);
  const [anchorEl, setAnchorEl] = useState(null);
  const openMenu = (event) => {
    setIsOpenMenu(true);
    setAnchorEl(event.target);
  };

  const handleClose = () => {
    setIsOpenMenu(false);
  };

  const handleDeviceDetector = () => {
    DeviceDetector.show();
    handleClose();
  };

  const handleGitHub = () => {
    window.open('https://github.com/tencentyun/TRTCSDK/tree/master/Web/base-react-next', '_blank');
    handleClose();
  };

  const handleQuit = () => {
    Cookies.remove('trtc-token');
    Cookies.remove('userId');
    Cookies.remove('phoneNumber');
    goToPage('login');
  };

  const handleCopyLink = () => {
    try {
      const roomID = document.getElementById('RoomID').value;
      navigator && navigator.clipboard.writeText(`${location.href}?roomID=${roomID}`).then(() => {
        toast.success(a18n('复制成功'), 2000);
      }, () => {
        toast.info(a18n('复制失败'), 2000);
      });
    } catch (error) {
      console.log('handleCopyLink error = ', error);
    }
  };

  const configList = [
    { key: 'user', icon: PermIdentityOutlinedIcon, text: Cookies.get('phoneNumber') },
    { key: 'device', icon: QueuePlayNextIcon, text: a18n('设备检测'), callback: handleDeviceDetector },
    { key: 'link', icon: ShareIcon, text: a18n('复制链接'), callback: handleCopyLink },
    { key: 'language', icon: TranslateIcon, text: a18n('语言切换') },
    { key: 'github', icon: GitHubIcon, text: a18n('GitHub 地址'), callback: handleGitHub },
    { key: 'log-out', icon: PowerSettingsNewIcon, text: a18n('退出登录'), callback: handleQuit },
  ];

  return (
    <div className={clsx(styles['top-bar-container'], isMobile && styles['top-bar-container-mobile'])}>
      <p className={styles['top-bar-title']}>{title}</p>
      <IconButton
        aria-label="more"
        aria-controls="long-menu"
        aria-haspopup="true"
        onClick={openMenu}
        style={{ color: '#1890fe' }}
      >
        <MoreVertIcon />
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
              <span className={styles['menu-item-text']}>{configItem.text}</span>
              {configItem.key === 'language' && <LanguageChange toolTipsVisible={false}></LanguageChange>}
            </MenuItem>)
        }
      </Menu>
      {/* <div className={`${styles['icon-container']} ${styles['float-right']}`}>
        {!isMobile && <div className={styles['icon-item']}>
          <PermIdentityOutlinedIcon className={styles['icon-img']}></PermIdentityOutlinedIcon>
          <span className={styles['icon-text']}>{phoneNumber}</span>
        </div>}
        <div className={styles['icon-item']} onClick={handleQuit}>
          <ExitToAppOutlinedIcon className={styles['icon-img']}></ExitToAppOutlinedIcon>
          <span className={styles['icon-text']}>{a18n('退出登录')}</span>
        </div>
      </div>
        <LanguageChange></LanguageChange>
      </div>*/}
    </div>
  );
}

export default TopBar;
