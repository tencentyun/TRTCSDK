import React, { useEffect } from 'react';
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import './App.global.scss';
import ClassRoom from './pages/class-room';
import ClassRoomTopView from './pages/class-room-top-view';
import ShareScreenSelectPage from './pages/share-screen-select';
import SharePreviewPage from './pages/share-preview';
import Login from './pages/home';
import StudentHome from './pages/student/home';
import { USER_EVENT_NAME } from '../constants';
import {
  toggleLogin,
  // updateScene,
  updateRole,
  updateRoomID,
  // updateName,
  updateUserID,
  updateDeviceState,
  updateCurrentDevice,
  updateShareScreenInfo,
  updateAllStudentMuteState,
  updatePlatform,
  updateEnterRoomTime,
} from './store/user/userSlice';

const viewMap = new Map();
viewMap.set('class-room', ClassRoom);
viewMap.set('class-room-top', ClassRoomTopView);
viewMap.set('share-screen-select', ShareScreenSelectPage);
viewMap.set('share-preview', SharePreviewPage);
viewMap.set('student', StudentHome);
viewMap.set('login', Login);

function ViewManager() {
  const logPrefix = '[ViewManager]';

  const dispatch = useDispatch();
  function handleInitData(event, args) {
    console.warn(`${logPrefix}.handleInitData args:`, args);
    dispatch(toggleLogin(true));
    // dispatch(updateScene(args.currentUser.scene));
    dispatch(updateRole(args.currentUser.role));
    dispatch(updateRoomID(args.currentUser.roomID));
    dispatch(updateUserID(args.currentUser.userID));
    dispatch(updateDeviceState(args.currentUser));
    dispatch(updateCurrentDevice(args.currentUser));
    dispatch(updateShareScreenInfo(args.currentUser.sharingScreenInfo));
    dispatch(updateAllStudentMuteState(args.currentUser.isAllStudentMuted));
    dispatch(updatePlatform(args.currentUser.platform));
    if (args.currentUser.enterRoomTime) {
      dispatch(updateEnterRoomTime(args.currentUser.enterRoomTime));
    }
  }

  useEffect(() => {
    window.electron.ipcRenderer.on(USER_EVENT_NAME.INIT_DATA, handleInitData);
    return () => {
      window.electron.ipcRenderer.off(
        USER_EVENT_NAME.INIT_DATA,
        handleInitData
      );
    };
  }, []);
  const query = new URLSearchParams(window.location.search); // useQuery();
  const viewName = query.get('view');
  let Component = viewMap.get(viewName);
  if (!Component) {
    // window.console.error(`Not valid view: ${viewName}`);
    Component = Login; // To-do: Component = View404;
  }

  document.body.className = `body-view-${viewName}`;

  return (
    <Router>
      <Switch>
        <Route path="/login" component={Login} />
        <Route path="/" component={Component} />
      </Switch>
    </Router>
  );
}

export default ViewManager;
