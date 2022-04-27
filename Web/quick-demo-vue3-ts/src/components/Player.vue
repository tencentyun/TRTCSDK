<template>
  <div class='player-container'>
    <template v-for='item in store.remoteStreams' :key='item.getId()'>
      <div class='remote' :id='item.getId()'></div>
    </template>
  </div>
</template>

<script lang='ts' setup>
import { inject, nextTick } from 'vue';
import appStore from '@/store/index';

const store = appStore();

const $bus = inject('$bus');

($bus as any).on('stream-subscribed', async (event: any) => {
  const remoteStream = event.stream;
  const id = remoteStream.getId();
  const userId = remoteStream.getUserId();
  const remoteId = `${id}`;
  store.remoteStreams.push(remoteStream);
  await nextTick();
  remoteStream.play(remoteId).then(() => {
    store.addSuccessLog(`RemoteStream play success: [${userId}]`);
  }).catch((error: any) => {
    store.addFailedLog(`RemoteStream play failed: [${userId}], error: ${error.message_}`);
  });

  console.log('stream-subscribed ID: ', id);
});

($bus as any).on('stream-removed', (event: any) => {
  const remoteStream = event.stream;
  const id = remoteStream.getId();
  store.remoteStreams = store.remoteStreams.filter((stream: any) => stream.getId() !== id);
});

</script>

<style lang='stylus' scoped>
.player-container
  display flex
  width 100%
  min-height 100px
  flex-direction row

.remote
  width 25%
  min-height 100px
  margin 0 10px 10px 0
  position relative

@media (max-width: 540px)
  .remote
    width 100%
    min-height 100px
    margin 0 10px 10px 0
    position relative
    margin-right: 0;

</style>
