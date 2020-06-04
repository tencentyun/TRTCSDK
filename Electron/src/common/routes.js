import index from '../pages/index.vue';
import trtcIndex from '../pages/trtc/trtc-index.vue';
import trtcRoom from '../pages/trtc/trtc-room.vue';
import liveIndex from '../pages/live/live-index.vue';
import liveRoomAnchor from '../pages/live/live-room-anchor.vue';
import liveRoomAudience from '../pages/live/live-room-audience.vue';
import notFound from '../pages/404.vue';


let options = [
  {path: '/', redirect: '/index'},
  {path: '/index', name: 'index', component: index},
  {path: '/trtc-index', name: 'trtc-index', component: trtcIndex},
  {path: '/trtc-room/:userId/:roomId/:cameraId', name: 'trtc-rom', component: trtcRoom},
  {path: '/live-index/:active?',name:'live-index', component: liveIndex},
  {path: '/live-room-anchor/:userId/:roomId/:cameraId',name:'live-room-anchor', component: liveRoomAnchor},
  {path: '/live-room-audience/:userId/:roomId',name:'live-room-audience', component: liveRoomAudience},
  {path: '/404',name:'not-found', component: notFound},
];
export default options;