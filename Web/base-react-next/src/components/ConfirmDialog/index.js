import { Button, Dialog, DialogActions, DialogContent, DialogTitle, makeStyles, Typography } from '@material-ui/core';
import React from 'react';


const useStyles = makeStyles(theme => ({
  dialog: {
    padding: theme.spacing(2),
    position: 'absolute',
    top: theme.spacing(5),
  },
  'dialog-content': {
    textAlign: 'center',
  },
  'dialog-action': {
    // justifyContent: 'center',
  },
}));

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
export default function ConfirmDialog(props) {
  const classes = useStyles();
  const { confirmDialog, setConfirmDialog } = props;

  const handleCancel = () => {
    setConfirmDialog({
      ...confirmDialog,
      isOpen: false,
    });
  };
  return (
    <Dialog
      open={confirmDialog.isOpen}
      onClose={handleCancel}
      className={classes.dialog}
    >
      <DialogTitle disableTypography>
        <Typography variant='h6'>{confirmDialog.title}</Typography>
        <Typography variant='subtitle2'>{confirmDialog.subTitle}</Typography>
      </DialogTitle>
      <DialogContent className={classes['dialog-content']}>
        {typeof confirmDialog.content === 'string'
          ? <Typography variant='body1'>{confirmDialog.content}</Typography>
          : confirmDialog.content
        }
      </DialogContent>
      <DialogActions className={classes['dialog-action']}>
        <Button autoFocus onClick={handleCancel} color="primary">
          Cancel
        </Button>
        <Button onClick={confirmDialog.onConfirm} color="primary">
          Ok
        </Button>
      </DialogActions>
    </Dialog>
  );
}
