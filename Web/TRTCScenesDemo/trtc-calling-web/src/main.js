import Vue from 'vue'
import 'element-ui/lib/theme-chalk/index.css';
import {
  Input, Button, Message, MessageBox, Autocomplete, Dialog,
  DropdownItem, DropdownMenu, Dropdown
} from 'element-ui';
import store from './store';
import {createRouter} from './router'
import {createTrtcCalling} from './trtc-calling';
import TRTCCalling from 'trtc-calling-js';
import App from './App.vue'

Vue.use(Input);
Vue.use(Button);
Vue.use(Autocomplete);
Vue.use(Dialog);
Vue.use(Dropdown);
Vue.use(DropdownMenu);
Vue.use(DropdownItem);

Vue.prototype.$message = Message;
Vue.prototype.$confirm = MessageBox.confirm;

Vue.prototype.$trtcCalling = createTrtcCalling();
Vue.prototype.TrtcCalling = TRTCCalling;

Vue.config.productionTip = false

new Vue({
  render: h => h(App),
  store,
  router: createRouter()
}).$mount('#app')
