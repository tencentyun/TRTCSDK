import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { RouteComponentProps } from 'react-router-dom';
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';
import Select from '@material-ui/core/Select';
import MenuItem from '@material-ui/core/MenuItem';
import FormControl from '@material-ui/core/FormControl';
import {
  updateUserID,
  updateRoomID,
  updateClassType,
} from '../../store/user/userSlice';
import { USER_EVENT_NAME } from '../../../constants';

import './index.scss';

function Login(props: RouteComponentProps) {
  const userID = useSelector((state: any) => state.user.userID);
  const roomID = useSelector((state: any) => state.user.roomID);
  const classType = useSelector((state: any) => state.user.classType);
  const dispatch = useDispatch();
  const isLogin = useSelector((state: any) => state.user.isLogin);
  if (isLogin) {
    props.history.push('/');
  }

  function handleRoomIDChange(event: React.ChangeEvent<HTMLInputElement>) {
    const newRoomID = +event.target.value;
    if (isNaN(newRoomID)) {
      return;
    }
    dispatch(updateRoomID(newRoomID));
  }

  function handleUserIDChange(event: React.ChangeEvent<HTMLInputElement>) {
    // dispatch(updateName(event.target.value as string));
    dispatch(updateUserID(event.target.value as string));
  }

  function handleClassTypeChange(event: React.ChangeEvent<HTMLSelectElement>) {
    dispatch(updateClassType(event.target.value as string));
  }

  function createClass() {
    if (!userID) {
      return;
    }
    (window as any).electron.ipcRenderer.send(
      USER_EVENT_NAME.ENTER_CLASS_ROOM,
      {
        roomID,
        userID,
        role: 'teacher',
      }
    );
  }

  function enterClass() {
    if (!userID) {
      return;
    }
    (window as any).electron.ipcRenderer.send(
      USER_EVENT_NAME.STUDENT_ENTER_CLASS_ROOM,
      {
        roomID,
        userID,
        role: 'student',
      }
    );
  }

  return (
    <div className="login">
      <form className="login-form" noValidate autoComplete="off">
        <div className="form-item">
          <div className="form-item-label">您的名称</div>
          <TextField
            variant="outlined"
            value={userID}
            onChange={handleUserIDChange}
          />
        </div>
        <div className="form-item">
          <div className="form-item-label">课堂ID</div>
          <TextField
            variant="outlined"
            value={roomID}
            inputProps={{ inputMode: 'numeric' }}
            onChange={handleRoomIDChange}
          />
        </div>
        <div className="form-item">
          <div className="form-item-label">课堂类型</div>
          <FormControl variant="outlined">
            <Select value={classType} onChange={handleClassTypeChange as any}>
              <MenuItem value="education">互动课堂</MenuItem>
            </Select>
          </FormControl>
        </div>
        <div className="form-item">
          <Button
            variant="contained"
            className="create-class-btn"
            onClick={createClass}
          >
            创建课堂
          </Button>
          <Button
            variant="contained"
            className="enter-class-btn"
            onClick={enterClass}
          >
            进入课堂
          </Button>
        </div>
      </form>
      <div className="login-empty" />
    </div>
  );
}

export default Login;
