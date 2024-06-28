/*
 * @Description: 单页面vue.config.js
 * @Date: 2022-03-09 16:52:32
 * @LastEditTime: 2022-03-22 20:18:51
 */
const path = require('path');
function resolve(dir) {
  return path.join(__dirname, dir);
}

module.exports = {
  publicPath: './',

  chainWebpack: (config) => {
    config.resolve.alias.set('@', resolve('./src'));

    config.module
      .rule('svg')
      .exclude.add(path.join(__dirname, 'src/assets/icons')) // 排除存放svg目录
      .end();
    config.module
      .rule('icons') // 添加新规则
      .test(/\.svg$/)
      .include.add(path.join(__dirname, 'src/assets/icons')) // 新规则应用于存放svg的目录
      .end()
      .use('svg-sprite-loader')
      .loader('svg-sprite-loader')
      .options({
        symbolId: 'icon-[name]',
      })
      .end();
  },

  devServer: {
    open: true,
    host: 'localhost',
    port: 8080,
  },

  pluginOptions: {
    i18n: {
      locale: 'zh',
      fallbackLocale: 'en',
      localeDir: 'locales',
      enableInSFC: true,
      enableBridge: false,
    },
  },
};
