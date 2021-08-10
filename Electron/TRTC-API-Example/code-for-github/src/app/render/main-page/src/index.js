import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
/**
 * 国际化设置要在 App 引入前完成，否则 App 中同步 import 的模块国际化不会生效
 * International language settings should be initialized and imported before App module, 
 * otherwise modules imported synchronized in App module will not be translated correctly.
 */
import './initA18n';

import App from './App';


ReactDOM.render(
  <App/>,
  document.getElementById('root')
);
