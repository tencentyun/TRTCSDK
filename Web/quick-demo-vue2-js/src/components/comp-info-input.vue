<!--
 * @Description: 信息输出框
 * @Date: 2022-03-10 15:21:23
 * @LastEditTime: 2022-03-21 18:07:11
-->
<template>
  <el-input :placeholder="label" :type="type" v-model="infoValue">
    <template slot="prepend">
      <span class="label">{{ label }}</span>
    </template>
  </el-input>
</template>

<script>
import { getUrlParam } from '@/utils/utils.js';
export default {
  name: 'userIdInput',
  props: {
    label: String,
  },
  data() {
    return {
      type: 'string',
      infoValue: '',
    };
  },
  watch: {
    infoValue: {
      immediate: true,
      handler(val) {
        this.$emit('change', this.type === 'number' ? Number(val) : val);
      },
    },
  },
  mounted() {
    switch (this.label) {
      case 'userId': {
        const userId = getUrlParam('userId');
        this.infoValue = userId ? userId : `user_${parseInt(Math.random() * 100000000, 10)}`;
        break;
      }
      case 'roomId': {
        const roomId = getUrlParam('roomId');
        this.type = 'number';
        this.infoValue = roomId ? roomId : parseInt(Math.random() * 100000, 10);
        break;
      }
      case 'sdkAppId': {
        const sdkAppId = getUrlParam('sdkAppId');
        this.type = 'number';
        this.infoValue = sdkAppId ? sdkAppId : '';
        break;
      }
      case 'secretKey': {
        const secretKey = getUrlParam('secretKey');
        this.infoValue = secretKey ? secretKey : '';
        break;
      }
      default:
        break;
    }
  },
};
</script>

<style lang="scss" scoped>
.label {
  width: 80px;
  display: inline-block;
  font-weight: bold;
}
</style>
