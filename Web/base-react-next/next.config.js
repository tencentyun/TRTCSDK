const path = require('path');

const prod = process.env.NODE_ENV === 'production';

module.exports = {
  assetPrefix: prod ? './' : '',
  webpack: (config) => {
    // eslint-disable-next-line no-param-reassign
    config.resolve.alias = {
      ...config.resolve.alias,
      '@': path.resolve(__dirname),
      '@components': path.resolve(__dirname, 'src/components'),
      '@styles': path.resolve(__dirname, 'src/styles'),
      '@utils': path.resolve(__dirname, 'src/utils'),
      '@locales': path.resolve(__dirname, 'src/locales'),
      '@config': path.resolve(__dirname, 'src/config'),
      '@api': path.resolve(__dirname, 'src/api'),
      '@app': path.resolve(__dirname, 'src/app'),
    };
    if (!config.externals) {
      config.externals = [];
    }
    if (prod) { // yarn run build 时引用外部 trtc-js-sdk
      config.externals.push({'trtc-js-sdk': 'TRTC'});
    }

    return config;
  },
};
