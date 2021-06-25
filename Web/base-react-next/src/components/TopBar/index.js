import React, { useState, useEffect } from 'react';
import styles from './index.module.scss';
import PermIdentityOutlinedIcon from '@material-ui/icons/PermIdentityOutlined';
import ExitToAppOutlinedIcon from '@material-ui/icons/ExitToAppOutlined';
import Cookies from 'js-cookie';
import { goToPage } from '@utils/common';
import clsx from 'clsx';

function TopBar({ title, isMobile = false }) {
  const [phoneNumber, setPhoneNumber] = useState('');

  useEffect(() => {
    setPhoneNumber(Cookies.get('phoneNumber'));
  }, []);

  const handleQuit = () => {
    Cookies.remove('token');
    Cookies.remove('userId');
    Cookies.remove('phoneNumber');
    goToPage('login');
  };

  return (
    <div className={clsx(styles['top-bar-container'], isMobile && styles['top-bar-container-mobile'])}>
      <p className={styles['top-bar-title']}>{title}</p>
      <div className={`${styles['icon-container']} ${styles['float-right']}`}>
        {!isMobile && <div className={styles['icon-item']}>
          <PermIdentityOutlinedIcon style={{ color: '#1890fe', fontSize: '30px' }}></PermIdentityOutlinedIcon>
          <span className={styles['icon-text']}>{phoneNumber}</span>
        </div>}
        <div className={styles['icon-item']} onClick={handleQuit}>
          <ExitToAppOutlinedIcon style={{ color: '#1890fe', fontSize: '30px' }}></ExitToAppOutlinedIcon>
          <span className={styles['icon-text']}>退出登录</span>
        </div>
      </div>
    </div>
  );
}

export default TopBar;
