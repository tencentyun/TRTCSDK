// vue.config.js
const StringReplaceWebpackPlugin = require('string-replace-webpack-plugin');
const os = require('os');
console.log('process.argv:', process.argv);
console.log('\n\n');

function getArgvToObject() {
  let cmdArgvs = process.argv;
  let param = {};
  let key = '';
  let tmp = [];
  for (let i = 0 ; i<cmdArgvs.length; i++) {
    if (/^--[\w\d_-]+/g.test(cmdArgvs[i])){
      tmp = cmdArgvs[i].replace('--', '').split('=');
      key = tmp[0].toUpperCase();
      param[key] = tmp[1];
    }
  }
  console.log('getArgvToObject param: ', param);
  return param
}

let param = getArgvToObject();

if (!param.TRTC_ENV) {
  param.TRTC_ENV = 'development'
}

if ( !param.TRTC_ENV || !['production', 'development'].includes(param.TRTC_ENV)) {
  console.log('TRTC_ENV set default: development');
  param.TRTC_ENV = 'development'
}

if (!param.TARGET_PLATFORM || !['darwin', 'win32'].includes(param.TARGET_PLATFORM)) {
  console.log(`TARGET_PLATFORM set default: ${os.platform()}`);
  param.TARGET_PLATFORM = os.platform();
}

console.log('param:', param);

let vueCliConfig = {
  publicPath: './',
  configureWebpack: {
    devtool: 'source-map',
    module: {
      rules: [
        {
          test: /\.node$/,
          loader: 'native-ext-loader',
          options: {
              emit: true,
              rewritePath: param.TRTC_ENV === 'production'
              ? param.TARGET_PLATFORM === 'win32' ? './resources' : '../Resources'
              : './node_modules/trtc-electron-sdk/build/Release'
          }
        }
      ],
    },
    plugins: [
      new StringReplaceWebpackPlugin(),
    ]
  }
}

module.exports = vueCliConfig;