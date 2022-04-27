<template>
  <div class='select-container'>
    <h1 style='font-size: 14px;font-weight: 500'>{{ t('device') }}</h1>
    <el-row :gutter='10'>
      <el-col :span='12' class='device-container'>
        <div class='label'>Camera</div>
        <el-select
          class='select'
          v-model='store.videoDeviceId'
          placeholder='Camera'
          @change='handleDeviceChange'>
          <el-option
            v-for='item in store.cameraList'
            :key='item.deviceId'
            :label='item.label'
            :value='item.deviceId'>
          </el-option>
        </el-select>
      </el-col>
      <el-col :span='12' class='device-container'>
        <div class='label'>Microphone</div>
        <el-select
          class='select'
          v-model='store.audioDeviceId'
          placeholder='Microphone'
          @change='handleDeviceChange'>
          <el-option
            v-for='item in store.microphoneList'
            :key='item.deviceId'
            :label='item.label'
            :value='item.deviceId'>
          </el-option>
        </el-select>
      </el-col>
    </el-row>
    <p style='font-size: 14px'>PS: 进房之前请确认当前页面允许使用摄像头和麦克风</p>
  </div>
</template>

<script lang='ts' setup>
import { defineEmits } from 'vue';
import { useI18n } from 'vue-i18n';
import TRTC from 'trtc-js-sdk';
import { ElMessage } from 'element-plus/es';
import appStore from '@/store/index';
import { DeviceItem } from '@/types/type';

const store = appStore();
const { t } = useI18n();
const emit = defineEmits(['switchDevice']);

const updateDevice = async () => {
  console.log('updateDevice');
  const cameraItems: DeviceItem[] = await TRTC.getCameras();
  cameraItems.forEach((item) => { item.value = item.deviceId; });
  const microphoneItems: DeviceItem[] = await TRTC.getMicrophones();
  microphoneItems.forEach((item) => { item.value = item.deviceId; });

  store.$patch({
    cameraList: cameraItems,
    microphoneList: microphoneItems,
  });

  if (!store.videoDeviceId) {
    store.videoDeviceId = cameraItems[0].deviceId;
  }

  if (!store.audioDeviceId) {
    store.audioDeviceId = microphoneItems[0].deviceId;
  }
};

navigator.mediaDevices.getUserMedia({ audio: true, video: true }).then((stream) => {
  stream.getTracks().forEach((track) => { track.stop(); });
  updateDevice();
}).catch(() => {
  ElMessage({ message: t('permit'), type: 'error' });
});

navigator.mediaDevices.ondevicechange = updateDevice;

const handleDeviceChange = () => {
  emit('switchDevice', {
    videoId: store.videoDeviceId,
    audioId: store.audioDeviceId,
  });
};
</script>

<style lang='stylus' scoped>
.select-container
  padding-bottom 5px
  .device-container
    display flex
    width 100%

  .label
    padding 0 20px
    width 120px
    height 32px
    line-height 32px
    font-size 14px
    border-top 1px solid #DCDFE6
    border-left 1px solid #DCDFE6
    border-bottom 1px solid #DCDFE6
    border-radius 4px 0 0 4px
    color #212529
    background-color #F5F7FA

  .select
    width 100%
</style>
