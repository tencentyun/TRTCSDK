import React, { Suspense } from 'react';
import { HashRouter, Route, Switch } from 'react-router-dom';
import ConfirmDialog from './components/Modal/confirmDialog';
import Notification from './components/Toast/notification';

import './App.css';
import Home from './home';
const App = () => {
  return (
    <HashRouter>
      <Suspense fallback={<div>Loading</div>}>
        <Switch>
          <Route path="/home" component={Home} />
          <Route exact path="/" component={Home} />
        </Switch>
      </Suspense>
      <Notification></Notification>
      <ConfirmDialog></ConfirmDialog>
    </HashRouter>
  )
};

export default App;
