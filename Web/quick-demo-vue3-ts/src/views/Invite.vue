<template>
  <el-row style='padding: 0 10px 40px 10px'>
    <el-col :md='{span: 18, offset: 3}' :sm='{span: 24}'>
      <div class="invite">
        <div class='share-link'>
          <div class='alert'>{{ t('inviteUrl') }}</div>
        </div>
      </div>
      <div style='padding-top: 10px'>
        <el-button type='primary' @click='handleJoin'>
          Join
        </el-button>
        <el-button type='primary' @click='handleLeave'>
          Leave
        </el-button>
      </div>
      <div id='local' style='max-width: 640px;margin-top: 20px'></div>
      <div class='remote-container'>
        <template v-for='item in store.invitedRemoteStreams' :key='item.getId()'>
          <div :id='item.getId()' style='max-width: 50%'></div>
        </template>
      </div>
    </el-col>
  </el-row>
</template>
<script lang='ts' setup>
import { useI18n } from 'vue-i18n';
import { ElMessage } from 'element-plus/es';
import { nextTick } from 'vue';
import { getParamKey } from '@/utils/utils';
import Client from '@/utils/client';
import appStore from '@/store';

const { t } = useI18n();
const store = appStore();

const sdkAppId = parseInt(getParamKey('sdkAppId'), 10);
const userId = getParamKey('userId');
const userSig = getParamKey('userSig');
const roomId = parseInt(getParamKey('roomId'), 10);

const state = { url: window.location.href.split('?')[0] };
window.history.pushState(state, '', 'index.html#/invite');

if (!sdkAppId || !userId || !userSig || !roomId) {
  ElMessage.error(t('check'));
}
let localClient: any;

async function handleJoin() {
  try {
    localClient = new Client({
      sdkAppId,
      userSig,
      userId,
      roomId,
    });
    await localClient.join();
    await localClient.publish();
    const localStream = localClient.getLocalStream();
    const client = localClient.getClient();

    client.on('stream-subscribed', handleSubscribed);
    client.on('stream-removed', handleRemoved);
    await nextTick();
    localStream.play('local');
  } catch (error: any) {
    ElMessage({
      message: error.message_,
      type: 'error',
    });
  }
}

async function handleSubscribed(event: any) {
  const remoteStream = event.stream;
  const id = remoteStream.getId();
  const remoteId = `${id}`;
  console.log(1212, event);
  store.invitedRemoteStreams.push(remoteStream);
  await nextTick();
  remoteStream.play(remoteId).then(() => {
    console.log(`RemoteStream play success: [${userId}]`);
  }).catch((error: any) => {
    console.log(`RemoteStream play failed: [${userId}], error: ${error.message_}`);
  });
}

async function handleRemoved(event: any) {
  const remoteStream = event.stream;
  const id = remoteStream.getId();
  store.invitedRemoteStreams = store.invitedRemoteStreams.filter((stream: any) => stream.getId() !== id);
}

async function handleLeave() {
  await localClient.leave();
}
</script>
<style lang='stylus' scoped>
.invite
  display flex
  padding-top 20px

.share-link
  color #084298
  background-color #cfe2ff
  border-color #b6d4fe
  width 100%
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

.remote-container
  display flex
  flex-wrap wrap
  justify-content space-between
  padding-top 20px
</style>
