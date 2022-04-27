<template>
  <NavBar/>
  <router-view/>
</template>

<script lang="ts" setup>
import TRTC from 'trtc-js-sdk';
import { ElMessage } from 'element-plus/es';
import { inject } from 'vue';
import NavBar from '@/components/ui/NavBar.vue';

const $aegis: any = inject('$aegis');

// check current environment is supported TRTC or not
TRTC.checkSystemRequirements().then((checkResult) => {
  if (!checkResult.result) {
    console.log('checkResult', checkResult.result, 'checkDetail', checkResult.detail);
    ElMessage({ message: 'Your browser does not supported TRTC!', type: 'error' });
    window.location.href = 'https://web.sdk.qcloud.com/trtc/webrtc/demo/detect/index.html';
  }
});

$aegis.reportEvent({
  name: 'loaded',
  ext1: 'loaded-success',
  ext2: 'webrtcQuickDemoVue3',
});
</script>

<style lang="stylus">
*
  box-sizing border-box
  font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', Arial, 'Microsoft YaHei', PingFang SC, sans-serif;

body
  margin 0
  padding 0
  width 100%
  height 100%

a
  color #0d6efd
  text-decoration none
</style>
