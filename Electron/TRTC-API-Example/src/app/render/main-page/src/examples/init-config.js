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
      <div className={classes.notice}>温馨提示：开始体验前，请先设置房间ID 和用户ID。</div>
      <form className={classes.root} autoComplete="off">
        <FormControl className={classes['form-line']}>
          <InputLabel htmlFor="room-id">房间ID</InputLabel>
          <Input id="room-id" placeholder="数值类型，需大于零" type="number" value={roomId} onChange={handleRoomIdChange} />
        </FormControl>
        <FormControl className={classes['form-line']}>
          <InputLabel htmlFor="user-id">用户ID</InputLabel>
          <Input id="user-id" placeholder="字符类型，房间内须唯一" value={userId} onChange={handleUserIdChange} />
        </FormControl>
      </form>
    </div>
  )
}

export default InitConfig;
