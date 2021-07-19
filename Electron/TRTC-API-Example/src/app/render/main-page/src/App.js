import './App.css';

import React, { Suspense } from 'react';
import { HashRouter, Route, Switch } from 'react-router-dom';

import Home from './examples/home';
// import Login from './login';
const App = () => {
  return (
    <HashRouter>
      <Suspense fallback={<div>Loading</div>}>
        <Switch>
          {/* <Route exact path="/login" component={Login} /> */}
          <Route path="/home" component={Home} />
          <Route exact path="/" component={Home} />
          {/* <Route exact path="/">
            <Redirect to="/home" />
          </Route> */}
        </Switch>
      </Suspense>
    </HashRouter>
  )
};

export default App;
