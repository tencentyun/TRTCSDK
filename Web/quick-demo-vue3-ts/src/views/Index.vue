<template>
  <el-row style='padding: 0 10px 40px 10px'>
    <el-col :md='{span: 18, offset: 3}' :sm='{span: 24}'>
      <Guidance />
      <Inputs />
      <Device @switchDevice='switchDevice' />
      <h1 style='font-size: 14px;font-weight: 500'>{{ t('operation') }}</h1>
      <div class='btn-line'>
        <el-button type='primary' @click='handleJoin'>
          Join Room
        </el-button>
        <el-button type='primary' @click='handlePublish'>
          Publish
        </el-button>
        <el-button type='primary' @click='handleUnpublish'>
          Unpublish
        </el-button>
        <el-button type='primary' @click='handleLeave'>
          Leave Room
        </el-button>
      </div>
      <div class='btn-line'>
        <el-button type='primary' @click='handleStartShare'>Start Share Screen</el-button>
        <el-button type='primary' @click='handleStopShare'>Stop Share Screen</el-button>
      </div>
      <div class='share-link' v-if='store.isJoined'>
        <div class='alert'>{{ t('invite') }}</div>
        <div class='invite'>
          <button class="invite-btn" @click='copy'>
            <img src="../assets/clippy.svg" alt="Copy to clipboard" class='clip'>
          </button>
          <el-input id="foo" v-model="inviteLink"></el-input>
        </div>
      </div>
      <div class='pusher'>
        <div class='logs'>
          <strong>Log:</strong>
          <template v-for='(item, index) in store.logs' :key='index'>
            <div class='log'>
              <template v-if="item.type === 'success'">
                <span>🟩 </span>{{ item.content }}
              </template>
              <template v-else>
                <span>🟥 </span>{{ item.content }}
              </template>
            </div>
          </template>
        </div>
        <div class='local' id='local' v-if='store.isJoined'>
          <div class='tag'>
            <div :class="audioMuted ? 'muteAudio' :'unmuteAudio'" @click='muteAudio'></div>
            <div :class="videoMuted ? 'muteVideo' :'unmuteVideo'" @click='muteVideo'></div>
          </div>
        </div>
      </div>
      <Player />
    </el-col>
  </el-row>
</template>

<script lang='ts' setup>
import { useI18n } from 'vue-i18n';
import { ElMessage } from 'element-plus/es';
import TRTC, { Client, LocalStream } from 'trtc-js-sdk';
import { inject, ref } from 'vue';
import { copyText } from 'vue3-clipboard';
import Guidance from '@/components/ui/Guidance.vue';
import Inputs from '@/components/Inputs.vue';
import Device from '@/components/Device.vue';
import Player from '@/components/Player.vue';
import appStore from '@/store/index';
import ShareClient from '@/utils/shareClient';

const $bus = inject('$bus');
const $aegis: any = inject('$aegis');

const { t } = useI18n();
const store = appStore();

let localClient: Client;
let localStream: LocalStream;
let shareClient: any;
const audioMuted = ref(false);
const videoMuted = ref(false);

const inviteLink = ref<string>();

const addSuccessLog = (str: string) => {
  store.logs.push({
    type: 'success',
    content: str,
  });
};

const addFailedLog = (str: string) => {
  store.logs.push({
    type: 'failed',
    content: str,
  });
};

const muteAudio = () => {
  if (!audioMuted.value) {
    localStream.muteAudio();
    audioMuted.value = true;
  } else {
    localStream.unmuteAudio();
    audioMuted.value = false;
  }
};

const muteVideo = () => {
  if (!videoMuted.value) {
    localStream.muteVideo();
    videoMuted.value = true;
  } else {
    localStream.unmuteVideo();
    videoMuted.value = false;
  }
};

async function handleStartShare() {
  shareClient = new ShareClient({
    sdkAppId: parseInt(store.sdkAppId, 10),
    userId: `share${store.userId}`,
    roomId: parseInt(store.roomId, 10),
    secretKey: store.secretKey,
  });
  try {
    await shareClient.join();
    await shareClient.publish();
    addSuccessLog('Start share screen success');
    store.isShared = true;
  } catch (error: any) {
    addFailedLog(`Start share error: ${error.message_}`);
  }
}
async function handleStopShare() {
  try {
    await shareClient.unpublish();
    await shareClient.leave();
    addSuccessLog('Stop share screen success');
    store.isShared = false;
  } catch (error: any) {
    addFailedLog(`Stop share error: ${error.message_}`);
  }
}

async function createLocalStream() {
  try {
    localStream = TRTC.createStream({
      userId: store.userId,
      audio: true,
      video: true,
      cameraId: store.videoDeviceId,
      microphoneId: store.audioDeviceId,
    });
    localStream.setVideoProfile('480p');

    await localStream.initialize();
    addSuccessLog(`LocalStream [${store.userId}] initialized`);

    localStream.play('local').then(() => {
      addLocalControlView();
      addSuccessLog(`LocalStream [${store.userId}] playing`);
    }).catch((e) => {
      addFailedLog(`LocalStream [${store.userId}] failed to play. Error: ${e.message_}`);
    });
  } catch (error: any) {
    addFailedLog(`LocalStream failed to initialize. Error: ${error.message_}`);
  }
}

async function handleJoin() {
  if (!store.getInitParamsStates()) {
    ElMessage({ message: t('paramsNeed'), type: 'error' });
    return;
  }
  const userSig = store.getUserSig();

  try {
    localClient = TRTC.createClient({
      mode: 'rtc', sdkAppId: parseInt(store.sdkAppId, 10), userId: store.userId, userSig,
    });
    addSuccessLog(`Client [${store.userId}] created`);
    installEventHandlers();
    await localClient.join({ roomId: parseInt(store.roomId, 10) });
    store.isJoined = true;
    inviteLink.value = store.createShareLink();
    addSuccessLog(`Join room [${store.roomId}] success`);
    $aegis.reportEvent({
      name: 'joinRoom',
      ext1: 'joinRoom-success',
      ext2: 'webrtcQuickDemoVue3',
      ext3: store.sdkAppId,
    });
  } catch (error: any) {
    addFailedLog(`Join room ${store.roomId} failed, please check your params. Error: ${error.message_}`);
    $aegis.reportEvent({
      name: 'joinRoom',
      ext1: `joinRoom-failed#${store.roomId}*${store.userId}*${error.message_}`,
      ext2: 'webrtcQuickDemoVue3',
      ext3: store.sdkAppId,
    });
  }

  await createLocalStream();
  await handlePublish();
}

async function handlePublish() {
  if (!store.isJoined) {
    ElMessage({ message: 'call publish()- please join() firstly', type: 'warning' });
    return;
  }
  if (store.isPublished) {
    ElMessage({ message: 'duplicate publish() observed', type: 'warning' });
    return;
  }

  try {
    await localClient.publish(localStream);
    addSuccessLog('LocalStream is published successfully');
    store.isPublished = true;
    $aegis.reportEvent({
      name: 'publish',
      ext1: 'publish-success',
      ext2: 'webrtcQuickDemoVue3',
      ext3: store.sdkAppId,
    });
  } catch (error: any) {
    addFailedLog(`LocalStream is failed to publish. Error: ${error.message_}`);
    $aegis.reportEvent({
      name: 'publish',
      ext1: `publish-failed#${store.roomId}*${store.userId}*${error.message_}`,
      ext2: 'webrtcQuickDemoVue3',
      ext3: store.sdkAppId,
    });
  }
}

async function handleUnpublish() {
  if (!store.isJoined) {
    ElMessage({ message: 'unpublish() - please join() firstly', type: 'warning' });
    return;
  }
  if (!store.isPublished) {
    ElMessage({ message: 'call unpublish() - you have not published yet', type: 'warning' });
    return;
  }
  try {
    await localClient.unpublish(localStream);
    store.isPublished = false;
    addSuccessLog('Unpublish localStream success');
    $aegis.reportEvent({
      name: 'unpublish',
      ext1: 'unpublish-success',
      ext2: 'webrtcQuickDemoVue3',
      ext3: store.sdkAppId,
    });
  } catch (error: any) {
    addFailedLog(`LocalStream is failed to unpublish. Error: ${error.message_}`);
    $aegis.reportEvent({
      name: 'unpublish',
      ext1: `unpublish-failed#${store.roomId}*${store.userId}*${error.message_}`,
      ext2: 'webrtcQuickDemoVue3',
      ext3: store.sdkAppId,
    });
  }
}

async function handleLeave() {
  if (!store.isJoined) {
    ElMessage({ message: 'leave() - please join() firstly', type: 'warning' });
    return;
  }
  if (store.isPublished) {
    await handleUnpublish();
  }
  try {
    uninstallEventHandlers();
    await localClient.leave();
    store.isJoined = false;
    addSuccessLog('Leave room success');
    if (localStream) {
      localStream.stop();
      localStream.close();
      localStream = null;
    }
    $aegis.reportEvent({
      name: 'leaveRoom',
      ext1: 'leaveRoom-success',
      ext2: 'webrtcQuickDemoVue3',
      ext3: store.sdkAppId,
    });
  } catch (error: any) {
    addFailedLog(`Leave room failed. Error: ${error.message_}`);
    $aegis.reportEvent({
      name: 'leaveRoom',
      ext1: `leaveRoom-failed#${store.roomId}*${store.userId}*${error.message_}`,
      ext2: 'webrtcQuickDemoVue3',
      ext3: store.sdkAppId,
    });
  }
}

async function switchDevice({ videoId, audioId }: { videoId: string, audioId: string }) {
  if (!store.isJoined) {
    return;
  }
  if (videoId) {
    try {
      await localStream.switchDevice('video', videoId);
      addSuccessLog('LocalStream switch video device success');
    } catch (error: any) {
      addFailedLog('Switch video device failed');
    }
  }
  if (audioId) {
    try {
      await localStream.switchDevice('audio', audioId);
      addSuccessLog('LocalStream switch audio device success');
    } catch (error: any) {
      addFailedLog('Switch audio device failed');
    }
  }
}

function addLocalControlView() {
  console.log('addLocalControlView');
}

function installEventHandlers() {
  if (!localClient) {
    return;
  }
  localClient.on('error', handleError);
  localClient.on('client-banned', handleBanned);
  localClient.on('peer-join', handlePeerJoin);
  localClient.on('peer-leave', handlePeerLeave);
  localClient.on('stream-added', handleStreamAdded);
  localClient.on('stream-subscribed', handleStreamSubscribed);
  localClient.on('stream-removed', handleStreamRemoved);
  localClient.on('stream-updated', handleStreamUpdated);
  localClient.on('mute-video', handleMuteVideo);
  localClient.on('mute-audio', handleMuteAudio);
  localClient.on('unmute-video', handleUnmuteVideo);
  localClient.on('unmute-audio', handleUnmuteAudio);
}

function handleMuteVideo(event: any) {
  addSuccessLog(`[${event.userId}] mute video`);
}

function handleMuteAudio(event: any) {
  addSuccessLog(`[${event.userId}] mute audio`);
}

function handleUnmuteVideo(event: any) {
  addSuccessLog(`[${event.userId}] unmute video`);
}

function handleUnmuteAudio(event: any) {
  addSuccessLog(`[${event.userId}] unmute audio`);
}

function handleError(error: any) {
  ElMessage({ message: `LocalClient error: ${error.message_}`, type: 'error' });
  addSuccessLog(`LocalClient error: ${error.message_}`);
}

function handleBanned(error: any) {
  ElMessage({ message: `Client has been banned for ${error.message_}`, type: 'error' });
  addSuccessLog(`Client has been banned for ${error.message_}`);
}

function handlePeerJoin(event: any) {
  const { userId } = event;
  if (userId !== 'local-screen') {
    addSuccessLog(`Peer Client [${userId}] joined`);
  }
}

function handlePeerLeave(event: any) {
  const { userId } = event;
  if (userId !== 'local-screen') {
    addSuccessLog(`[${userId}] leave`);
  }
}

function handleStreamAdded(event: any) {
  const remoteStream = event.stream;
  const id = remoteStream.getId();
  const userId = remoteStream.getUserId();

  if (remoteStream.getUserId() === `share_${store.userId}`) {
    // don't need to screen shared by us
    localClient.unsubscribe(remoteStream).catch((error: any) => {
      addFailedLog(`unsubscribe failed: ${error.message_}`);
    });
  } else {
    addSuccessLog(`remote stream added: [${userId}] ID: ${id} type: ${remoteStream.getType()}`);
    localClient.subscribe(remoteStream).catch((error: any) => {
      addFailedLog(`subscribe failed: ${error.message_}`);
      $aegis.reportEvent({
        name: 'subscribe',
        ext1: `subscribe-failed#${store.roomId}*${store.userId}*${error.message_}`,
        ext2: 'webrtcQuickDemoVue3',
        ext3: store.sdkAppId,
      });
    });
  }
}

function handleStreamSubscribed(event: any) {
  const remoteStream = event.stream;
  const userId = remoteStream.getUserId();
  addSuccessLog(`RemoteStream subscribed: [${userId}]`);
  ($bus as any).emit('stream-subscribed', event);
  $aegis.reportEvent({
    name: 'subscribe',
    ext1: 'subscribe-success',
    ext2: 'webrtcQuickDemoVue3',
    ext3: store.sdkAppId,
  });
}

function handleStreamRemoved(event: any) {
  const remoteStream = event.stream;
  const userId = remoteStream.getUserId();
  addSuccessLog(`RemoteStream removed: [${userId}]`);
  ($bus as any).emit('stream-removed', event);
}

function handleStreamUpdated(event: any) {
  const remoteStream = event.stream;
  const userId = remoteStream.getUserId();
  addSuccessLog(`RemoteStream updated: [${userId}] audio:${remoteStream.hasAudio()} video:${remoteStream.hasVideo()}`);
}

function uninstallEventHandlers() {
  if (!localClient) {
    return;
  }
  localClient.off('error', handleError);
  localClient.off('error', handleError);
  localClient.off('client-banned', handleBanned);
  localClient.off('peer-join', handlePeerJoin);
  localClient.off('peer-leave', handlePeerLeave);
  localClient.off('stream-added', handleStreamAdded);
  localClient.off('stream-subscribed', handleStreamSubscribed);
  localClient.off('stream-removed', handleStreamRemoved);
  localClient.off('stream-updated', handleStreamUpdated);
  localClient.off('mute-video', handleMuteVideo);
  localClient.off('mute-audio', handleMuteAudio);
  localClient.off('unmute-video', handleUnmuteVideo);
  localClient.off('unmute-audio', handleUnmuteAudio);
}

function copy() {
  copyText(inviteLink.value, undefined, (error: any) => {
    if (error) {
      ElMessage({ message: 'Copy failed!', type: 'error' });
    } else {
      ElMessage({ message: 'Copied!', type: 'success' });
    }
    inviteLink.value = store.createShareLink();
  });
}

</script>

<style lang='stylus' scoped>
.btn-line
  padding-bottom 10px

.share-link
  color #084298
  background-color #cfe2ff
  border-color #b6d4fe
  padding 15px 20px
  font-size 14px
  border-radius 4px

.el-button
  background-color #0d6efd
  font-size 14px
  font-weight 400
  padding 4px 8px

.el-button:hover
  background-color #0d6efd

.el-button:focus
  background-color #0d6efd

.el-button + .el-button
  margin-left 6px

.invite
  display flex
  padding-top 6px

  .invite-btn
    height 32px
    display flex
    justify-content center
    align-items center
    border: 1px solid #d5d5d5;
    border-radius 3px
    padding 6px 12px
    cursor pointer
    background-color #eee

  .clip
    width 12px
    height 12px

.logs
  min-width 180px
  width calc(100% - 490px)
  height 360px
  margin-right 10px
  margin-bottom 10px
  border 1px solid #ccc
  padding 6px
  overflow-y scroll

.log
  font-size 12px

.local
  width 480px
  height 360px
  margin 0 0 10px 0
  position relative

@media (max-width: 540px)
  .logs
    width 100%
    height 150px
    margin-right 0

  .local
    width 100%
    height 100%

.pusher
  padding-top 10px
  display flex
  width 100%
  flex-direction row
  flex-wrap wrap
  justify-content space-between

.muteAudio
  background url(../assets/mic-mute.svg) center center no-repeat

.unmuteAudio
  background url(../assets/mic.svg) center center no-repeat

.muteVideo
  background url(../assets/camera-mute.svg) center center no-repeat

.unmuteVideo
  background url(../assets/camera.svg) center center no-repeat

.tag
  position absolute
  bottom 0
  width 100%
  height 25px
  z-index 999
  background rgba(0, 0, 0, 0.3)
  display flex
  padding 0 4px
  flex-direction row-reverse

.tag > div
  height 25px
  width 25px
  cursor pointer

</style>
