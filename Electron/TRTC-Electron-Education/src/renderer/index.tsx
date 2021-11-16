import React from 'react';
import { render } from 'react-dom';
import { Provider } from 'react-redux';
import store from './store';
import ViewManager from './ViewManager';

render(
  <Provider store={store}>
    <ViewManager />
  </Provider>,
  document.getElementById('root')
);
