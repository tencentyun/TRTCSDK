/*
 * @Description: Agies
 * @Date: 2022-03-18 17:42:38
 * @LastEditTime: 2022-04-07 17:42:51
 */

import Vue from 'vue';
import Aegis from 'aegis-web-sdk';

const isProd = location.origin === 'https://web.sdk.qcloud.com';

const AEGIS_ID = {
  dev: 'iHWefAYqvXVdajviap',
  prod: 'iHWefAYqpBFdmIMeDi',
};

const aegis = new Aegis({
  id: isProd ? AEGIS_ID.prod : AEGIS_ID.dev,
  reportApiSpeed: true, // 接口测速
  reportAssetSpeed: true, // 静态资源测速
});

Vue.prototype.$aegis = aegis;
