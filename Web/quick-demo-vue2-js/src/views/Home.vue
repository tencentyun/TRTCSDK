<!--
 * @Description: quick demo - vue2 版本页面
 * @Date: 2022-03-14 16:56:36
 * @LastEditTime: 2022-03-21 18:07:19
-->
<template>
  <div id="app">
    <!-- 头部栏 -->
    <comp-nav></comp-nav>
    <div class="content">
      <!-- quick demo 使用指引 -->
      <comp-guidance></comp-guidance>
      <!-- sdkAppId、secretKey、userId、roomId 参数输入区域 -->
      <p class="label">{{ $t('Params') }}</p>
      <div class="param-container">
        <comp-info-input
          label="sdkAppId" type="number" @change="handleValueChange($event, 'sdkAppId')"></comp-info-input>
        <comp-info-input
          label="secretKey" @change="handleValueChange($event, 'secretKey')"></comp-info-input>
        <comp-info-input
          label="userId" @change="handleValueChange($event, 'userId')"></comp-info-input>
        <comp-info-input
          label="roomId" type="number" @change="handleValueChange($event, 'roomId')"></comp-info-input>
      </div>
      <!-- 设备选择区域 -->
      <p class="label">{{ $t('Device Select') }}</p>
      <div class="param-container">
        <comp-device-select
          deviceType="camera" @change="handleValueChange($event, 'cameraId')"></comp-device-select>
        <comp-device-select
          deviceType="microphone" @change="handleValueChange($event, 'microphoneId')"></comp-device-select>
      </div>
      <!-- rtc 房间 -->
      <comp-room
        :sdkAppId="Number(sdkAppId)"
        :secretKey="secretKey"
        :userId="userId"
        :roomId="Number(roomId)"
        :cameraId="cameraId"
        :microphoneId="microphoneId"></comp-room>
    </div>
  </div>
</template>

<script>
import compNav from '@/components/comp-nav.vue';
import compGuidance from '@/components/comp-guidance.vue';
import compInfoInput from '@/components/comp-info-input.vue';
import compDeviceSelect from '@/components/comp-device-select.vue';
import compRoom from '@/components/comp-room.vue';
import { clearUrlParam } from '@/utils/utils';

export default {
  name: 'App',
  components: {
    compNav,
    compGuidance,
    compInfoInput,
    compDeviceSelect,
    compRoom,
  },
  data() {
    return {
      sdkAppId: 0,
      secretKey: '',
      userId: '',
      roomId: 0,
      cameraId: '',
      microphoneId: '',
    };
  },
  methods: {
    handleValueChange(value, key) {
      this[key] = value;
    },
  },
  mounted() {
    clearUrlParam();
  },
};
</script>

<style lang="scss" scoped>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  width: 100%;
  height: 100%;
  padding-bottom: 40px;
  .content {
    width: 80%;
    margin: 0 auto;
    max-width: 1320px;
    .label {
      margin: 14px 0 6px;
      text-align: left;
      font-weight: bold;
    }
    .param-container {
      width: 100%;
      display: flex;
      justify-content: space-between;
      flex-wrap: wrap;
      div {
        width: calc((100% - 20px) / 2);
        margin-bottom: 10px;
      }
      div:nth-last-child(2), div:nth-last-child(1) {
        margin-bottom: 0;
      }
    }
  }
}
</style>

<i18n>
{
	"en": {
		"Params": "Params",
    "Device Select": "Device Select"
	},
	"zh": {
		"Params": "参数",
    "Device Select": "设备选择"
	}
}
</i18n>

