import Vue from 'vue';
import Router from 'vue-router';

import store from '../store';
import HomePage from '../components/home-page';
import Login from '../components/login';
import AudioCall from '../components/audio-call';
import VideoCall from '../components/video-call';

Vue.use(Router);

export function createRouter () {
  const router = new Router({
    mode: 'hash',
    fallback: false,
    routes: [
      { path: '/', component: HomePage},
      { path: '/login', component: Login},
      { path: '/audio-call', component: AudioCall},
      { path: '/video-call', component: VideoCall}
    ]
  });
  router.beforeEach((to, from, next) => {
    if (!store.state.isLogin) {
      if (to.fullPath !== '/login') {
        if (from.fullPath !== '/login') {
          next('/login');
        }
        return;
      }
    }
    next();
  })
  return router;
}

const originalPush = Router.prototype.push
   Router.prototype.push = function push(location) {
   return originalPush.call(this, location).catch(err => err)
}