<!--
 * @Description: App.vue
 * @Date: 2022-03-21 12:16:32
 * @LastEditTime: 2022-03-21 12:21:49
-->
<template>
  <router-view/>
</template>

<script>
export default {
  name: 'App',
  mounted() {
    this.$aegis.reportEvent({
      name: 'loaded',
      ext1: 'loaded-success',
      ext2: 'webrtcQuickDemoVue2',
    });
  },
};
</script>
