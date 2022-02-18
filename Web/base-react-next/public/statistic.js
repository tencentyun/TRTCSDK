/* eslint-disable wrap-iife */
// 实例化 aegis
const tamProjectId = 'iHWefAYqqgZuNTnWMj';
(function () {
  if (!window) {
    console.log('window is undefined');
    return;
  }
  const { Aegis } = window;
  if (!Aegis) {
    console.log('Aegis is undefined');
    return;
  }

  const aegis = new Aegis({
    id: tamProjectId, // 项目key
    // uin: '', // 用户唯一 ID（可选）
    spa: true,
    reportApiSpeed: true, // 接口测速
    reportAssetSpeed: true, // 静态资源测速
    pagePerformance: true, // 开启页面测速
    hostUrl: 'https://tamaegis.com', // 海外会有地方限制 qq 域名, 默认为 aegis.qq.com
  });

  window.aegis = aegis;
})();
