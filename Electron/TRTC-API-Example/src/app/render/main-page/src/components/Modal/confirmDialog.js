import { Button, Dialog, DialogActions, DialogContent, DialogTitle, Typography } from '@material-ui/core';
import InfoIcon from '@material-ui/icons/Info';
import React, { useEffect, useState } from 'react';
import Modal from './index';
import styles from './confirmDialog.module.scss';
import a18n from 'a18n';

/**
 * 封装 Dialog 组件, 简化 Dialog 组件的使用
 * @param {object} props
 * @params {object} props.confirmDialog 包含 isOpen, title, subTitle, content, onConfirm 属性的对象
 * @params {boolean} props.notify.isOpen 是否显示 confirm 弹框
 * @params {string} props.notify.title 弹框主标题
 * @params {string} props.notify.subTitle 弹框副标题
 * @params {string | Node} props.notify.content 弹框内容
 * @params {function} props.notify.onConfirm 弹框 OK 按钮相应函数
 * @param {function} props.setConfirmDialog
 */
export default function ConfirmDialog() {
  const [confirmDialog, setConfirmDialog] = useState({ isOpen: false });

  useEffect(() => {
    Modal.confirm = (confirmProps) => {
      addConfirm(confirmProps);
    };
  }, []);

  const addConfirm = (confirmProps) => {
    setConfirmDialog({
      ...confirmDialog,
      isOpen: true,
      ...confirmProps,
    });
  };

  const handleCancel = () => {
    setConfirmDialog({ isOpen: false });
  };

  const handleConfirm = () => {
    const { onOk } = confirmDialog;
    setConfirmDialog({ isOpen: false });
    typeof onOk === 'function' && onOk();
  };

  return (
    <Dialog
      open={confirmDialog.isOpen}
      onClose={handleCancel}
      className={styles['dialog-container']}
    >
      <DialogTitle disableTypography className={styles['dialog-header-container']}>
        <div className={styles['dialog-title-container']}>
          <InfoIcon color='primary'></InfoIcon>
          <Typography variant='h6' className={styles['dialog-title']}>{confirmDialog.title}</Typography>
        </div>
        <Typography variant='subtitle2'>{confirmDialog.subTitle}</Typography>
      </DialogTitle>
      <DialogContent className={styles['dialog-content']}>
        {typeof confirmDialog.content === 'string'
          ? <Typography variant='body1'>{confirmDialog.content}</Typography>
          : confirmDialog.content
        }
      </DialogContent>
      <DialogActions className={styles['dialog-action']}>
        <Button autoFocus onClick={handleCancel} color="primary">
          {a18n('取消')}
        </Button>
        <Button onClick={handleConfirm} color="primary">
          {a18n('确定')}
        </Button>
      </DialogActions>
    </Dialog>
  );
}
