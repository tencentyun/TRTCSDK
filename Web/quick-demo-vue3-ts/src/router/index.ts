import { createRouter, createWebHashHistory, RouteRecordRaw } from 'vue-router';
import Index from '../views/Index.vue';

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'home',
    component: Index,
  },
  {
    path: '/invite',
    name: 'invite',
    component: () => import(/* webpackChunkName: "about" */ '../views/Invite.vue'),
  },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes,
});

export default router;
