import React from 'react';
import { Switch, Route } from 'react-router-dom';
import routes from './constants/routes.json';
import App from './containers/App';
import HomePage from './containers/HomePage';
import LoginPage from './containers/LoginPage';
import ClassRoomPage from './containers/ClassRoomPage';

export default function Routes() {
  return (
    <App>
      <Switch>
        <Route path={routes.CLASSROOM} component={ClassRoomPage} />
        <Route path={routes.HOME} component={HomePage} />
        {/* 要放在最后一行 */}
        <Route path={routes.LOGIN} component={LoginPage} />
      </Switch>
    </App>
  );
}
