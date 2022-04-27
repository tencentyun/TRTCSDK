import Aegis from 'aegis-web-sdk';

const isProd = window.location.origin === 'https://web.sdk.qcloud.com';

const AEGIS_ID = {
  dev: 'iHWefAYqvXVdajviap',
  prod: 'iHWefAYqpBFdmIMeDi',
};

const aegis = new Aegis({
  id: isProd ? AEGIS_ID.prod : AEGIS_ID.dev,
  reportApiSpeed: true, // 接口测速
  reportAssetSpeed: true, // 静态资源测速
});

export default aegis;
