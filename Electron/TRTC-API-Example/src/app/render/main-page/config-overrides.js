const path = require('path');
const os = require('os');

console.log('process.env.NODE_ENV:', process.env.NODE_ENV);

const TARGET_PLATFORM = (function(){
  let target = '';
  for (let i=0; i<process.argv.length; i++) {
    if (process.argv[i].includes('--platform=')) {
      target = process.argv[i].replace('--platform=', '');
      break;
    }
  }
  if (!['win32', 'darwin'].includes(target)) target = os.platform();
  return target;
})();

console.log(`TARGET_PLATFORM: ${TARGET_PLATFORM}`);

module.exports = function override(config, env) {
  config.resolve.alias = {
    ...config.resolve.alias,
    '@': path.resolve(__dirname),
    '@app': path.resolve(__dirname, 'src/app'),
    '@components': path.resolve(__dirname, 'src/rtc-components'),
    '@utils': path.resolve(__dirname, 'src/utils'),
    '@api': path.resolve(__dirname, 'src/api'),
    '@config': path.resolve(__dirname, 'src/config'),
    '@assets': path.resolve(__dirname, 'src/assets')
  };

  config.module.rules.unshift({
    test: /\.node$/,
    loader: 'native-ext-loader',
    options: {
      emit: true,
      // rewritePath: 'src/app/render/main-page/node_modules/trtc-electron-sdk/build/Release'
      rewritePath: process.env.NODE_ENV === 'production'
        ? TARGET_PLATFORM === 'win32' ? './resources' : '../Resources'
        : 'src/app/render/main-page/node_modules/trtc-electron-sdk/build/Release'
    }
  });

  // 不要采用 webpack 自动注入 mock process, 因为 electron_sdk 采用 process.platform, 自动注入会导致 process.platform undefined
  // https://webpack.js.org/configuration/node/#node
  config.node.process = false;

  // config.devtool = 'eval';

  return config;
}
