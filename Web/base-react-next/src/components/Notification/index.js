import React from 'react';
import { Alert } from '@material-ui/lab';
import { Snackbar } from '@material-ui/core';

/**
 * 封装 Alert、Snackbar 组件, 实现 Notification 组件
 * @param {object} props
 * @params {object} props.notify 包含 isOpen, type, message, duration 属性的对象
 * @params {boolean} props.notify.isOpen 是否显示消息提示
 * @params {string} props.notify.type Alert 组件的消息类型, 枚举值有: 'error', 'info', 'success', 'warning'
 * @params {string} props.notify.message 提示的消息内容
 * @params {number}} props.notify.duration 消息提示持续时间
 * @param {function} props.setNotify
 */
export default function Notification(props) {
  const defaultDuration = 3000;
  const defaultAlertType = 'info';
  const { notify, setNotify } = props;
  const handleClose = () => {
    setNotify({
      ...notify,
      isOpen: false,
    });
  };

  return (
    <Snackbar
      open={notify.isOpen}
      message={notify.message}
      autoHideDuration={notify.duration || defaultDuration}
      anchorOrigin={{
        vertical: 'top',
        horizontal: 'center',
      }}
      onClose={handleClose}
    >
      <Alert severity={notify.type || defaultAlertType} onClose={handleClose}>{notify.message}</Alert>
    </Snackbar>
  );
}
