import Vue from 'vue'
import routes from './common/routes';
import App from './app';
import VueRouter from 'vue-router';
import mainMenu from './components/main-menu.vue';
import navBar from './components/nav-bar.vue';
import trtcStateCheck from './components/trtc-state-check';
import { BootstrapVue, IconsPlugin, BSidebar , BToast, ToastPlugin, ModalPlugin} from 'bootstrap-vue'

import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';
import './common.css';

let vueRouter = new VueRouter({
  mode: 'hash',
  base: 'index',
  routes: routes
});
// 安装 vue 插件
Vue.use(BootstrapVue);
Vue.use(IconsPlugin);
Vue.use(VueRouter);
Vue.use(ToastPlugin);
Vue.use(ModalPlugin);

// 安装自定义组件
Vue.component('main-menu', mainMenu);
Vue.component('nav-bar', navBar);
Vue.component('trtc-state-check', trtcStateCheck);
Vue.component('b-sidebar', BSidebar);
Vue.component('b-toast', BToast);

Vue.config.productionTip = true;

// 实例化一个 Vue
let vueApp = new Vue({
  router: vueRouter,
  render : h=>h(App)
});
vueApp.$mount("#trtc-electron-demo");

window.$app = vueApp;

window.addEventListener('popstate', () => {
  console.demoWarn('popstate: ', window.location.pathname);
});
