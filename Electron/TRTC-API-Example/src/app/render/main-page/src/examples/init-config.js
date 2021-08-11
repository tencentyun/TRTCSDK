import a18n from 'a18n'
import React, { useState } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Input from '@material-ui/core/Input';
import FormControl from '@material-ui/core/FormControl';
import InputLabel from '@material-ui/core/InputLabel';
import rand from '@utils/rand';
import initConfigUtil from '@utils/init-config-util';

const useStyles = makeStyles((theme) => ({
  root: {
    '& > *': {
      margin: theme.spacing(1),
    },
  },
  "pre-config": {
    margin: "1rem",
  },
  "form-line": {
    display: 'block',
    marginBottom: '2rem',
    '&:last-child': {
      marginBottom: 0
    }
  },
  notice: {
    margin: "2rem 0",
    // color: 'red',
    fontSize: "2rem",
    fontWeight: 400
  }
}));

function InitConfig(props) {
  if (!initConfigUtil.loadRoomId()) {
    initConfigUtil.storeRoomId(parseInt(rand(10000000)));
  }
  if (!initConfigUtil.loadLocalUserId()) {
    initConfigUtil.storeLocalUserId(rand(10000000, true));
  }

  const [roomId, setRoomId] = useState(initConfigUtil.loadRoomId());
  const [userId, setUserId] = useState(initConfigUtil.loadLocalUserId());
  const classes = useStyles();

  const handleRoomIdChange = (event) => {
    const value = window.parseInt(event.target.value);
    setRoomId(value);
    initConfigUtil.storeRoomId(value);
  };

  const handleUserIdChange = (event) => {
    const value = event.target.value;
    setUserId(value);
    initConfigUtil.storeLocalUserId(value);
  };

  return (
    <div className={classes['pre-config']}>
      <div className={classes.notice}>{a18n('温馨提示：开始体验前，请先设置房间号和用户名。')}</div>
      <form className={classes.root} autoComplete="off">
        <FormControl className={classes['form-line']}>
          <InputLabel htmlFor="room-id">{a18n('房间号')}</InputLabel>
          <Input id="room-id" placeholder={a18n('数值类型，需大于零')} type="number" value={roomId} onChange={handleRoomIdChange} />
        </FormControl>
        <FormControl className={classes['form-line']}>
          <InputLabel htmlFor="user-id">{a18n('用户名')}</InputLabel>
          <Input id="user-id" placeholder={a18n('字符类型，房间内须唯一')} value={userId} onChange={handleUserIdChange} />
        </FormControl>
      </form>
    </div>
  );
}

export default InitConfig;
