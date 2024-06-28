<!--
 * @Description: 设备选择组件
 * @Date: 2022-03-10 15:47:24
 * @LastEditTime: 2022-03-29 17:02:21
-->
<template>
  <div class="select-container">
    <span class="label">{{ deviceType }}</span>
    <el-select
      class="select"
      v-model="activeDeviceId"
      :placeholder="deviceType"
      @change="handleChange">
      <el-option
        v-for="item in deviceList"
        :key="item.deviceId"
        :label="item.label"
        :value="item.deviceId">
      </el-option>
    </el-select>
  </div>
</template>

<script>
import TRTC from 'trtc-js-sdk';
export default {
  name: 'compDeviceSelect',
  props: {
    deviceType: {
      type: String,
    },
  },
  data() {
    return {
      deviceList: [],
      activeDevice: {},
      activeDeviceId: '',
    };
  },
  methods: {
    async getDeviceList() {
      switch (this.deviceType) {
        case 'camera':
          this.deviceList = await TRTC.getCameras();
          break;
        case 'microphone':
          this.deviceList = await TRTC.getMicrophones();
          break;
        case 'speaker':
          this.deviceList = await TRTC.getSpeakers();
          break;
        default:
          break;
      }
      [this.activeDevice] = this.deviceList;
      this.activeDeviceId = this.deviceList[0].deviceId;
      this.$emit('change', this.activeDeviceId);
    },
    handleChange() {
      this.$emit('change', this.activeDeviceId);
    },
  },
  mounted() {
    navigator.mediaDevices.getUserMedia({ audio: true, video: true }).then(() => {
      this.getDeviceList();
    });
    navigator.mediaDevices.addEventListener('devicechange', this.getDeviceList);
  },
  beforeDestroy() {
    navigator.mediaDevices.removeEventListener('devicechange', this.getDeviceList);
  },
};
</script>

<style lang="scss" scoped>
.select-container {
  display: flex;
  .label {
    display: inline-block;
    padding: 0 20px;
    width: 120px;
    height: 40px;
    text-align: left;
    line-height: 40px;
    border-top: 1px solid #DCDFE6;
    border-left: 1px solid #DCDFE6;
    border-bottom: 1px solid #DCDFE6;
    border-radius: 4px 0 0 4px;
    color: #909399;
    background-color: #F5F7FA;
    font-weight: bold;
  }
  .select {
    flex-grow: 1;
  }
}
</style>

<style lang="scss">
.select {
  input {
    border-radius: 0 4px 4px 0 !important;
  }
}
</style>
