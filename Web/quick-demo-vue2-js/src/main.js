/*
 * @Description: 全局样式
 * @Date: 2022-03-09 16:42:16
 * @LastEditTime: 2022-03-29 16:36:04
 */
import Vue from 'vue';
import App from './App.vue';
import TRTC from 'trtc-js-sdk';
import '@/utils/aegis.js';

import '@/assets/style/global.css';
import '@/assets/icons';
import '@/assets/style/theme/index.css';
import { isMobile } from '@/utils/utils';

import {
  Collapse,
  CollapseItem,
  Select,
  Option,
  Input,
  Button,
  Message,
  MessageBox,
  Tooltip,
  Alert,
} from 'element-ui';

import router from './router';
import i18n from './locales/i18n';

/**
 *  重写ElementUI的Message
 */
const showMessage = Symbol('showMessage');
class DonMessage {
  success(options, single = true) {
    this[showMessage]('success', options, single);
  }
  warning(options, single = true) {
    this[showMessage]('warning', options, single);
  }
  info(options, single = true) {
    this[showMessage]('info', options, single);
  }
  error(options, single = true) {
    this[showMessage]('error', options, single);
  }
  [showMessage](type, options) {
    Message[type](options);
  }
}

Vue.use(Collapse);
Vue.use(CollapseItem);
Vue.use(Select);
Vue.use(Option);
Vue.use(Input);
Vue.use(Button);
Vue.use(Tooltip);
Vue.use(Alert);
Vue.prototype.$alert = MessageBox.alert;
Vue.prototype.$message = new DonMessage();
Vue.prototype.$isMobile = isMobile;

Vue.config.productionTip = false;

document.title = i18n.t('title');
TRTC.Logger.setLogLevel(TRTC.Logger.LogLevel.DEBUG);
new Vue({
  router,
  i18n,
  render: h => h(App),
}).$mount('#app');
