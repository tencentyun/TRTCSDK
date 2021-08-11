import React from 'react';
import { Alert } from '@material-ui/lab';
import { Snackbar } from '@material-ui/core';
import styles from './index.module.scss';

/**
 * 封装 Alert、Snackbar 组件, 实现 Notification 组件
 * @param {object} props
 * @params {object} props 包含 isOpen, type, message, duration 属性的对象
 * @params {string} props.type Alert 组件的消息类型, 枚举值有: 'error', 'info', 'success', 'warning'
 * @params {string} props.message 提示的消息内容
 * @params {number}} props.duration 消息提示持续时间
 */
export default function Notice(props) {
  const defaultDuration = 3000;
  const defaultAlertType = 'info';
  const [open, setOpen] = React.useState(true);
  const { type, message, duration, onClose } = props;
  const handleClose = () => {
    onClose && onClose();
    setOpen(false);
  };

  return (
    <Snackbar
      className={styles['snack-bar']}
      open={open}
      message={message}
      autoHideDuration={duration || defaultDuration}
      anchorOrigin={{
        vertical: 'top',
        horizontal: 'center',
      }}
      onClose={handleClose}>
      <Alert severity={type || defaultAlertType} onClose={handleClose}>{message}</Alert>
    </Snackbar>
  );
}
