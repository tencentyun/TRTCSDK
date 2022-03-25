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

    // 配置处理svg
    const svgRule = config.module.rule('svg'); // 找到svg-loader
    svgRule.uses.clear(); // 清除已有的loader, 如果不这样做会添加在此loader之后
    svgRule.exclude.add(/node_modules/); // 正则匹配排除node_modules目录
    svgRule // 添加svg新的loader处理
      .test(/\.svg$/)
      .use('svg-sprite-loader')
      .loader('svg-sprite-loader')
      .options({
        symbolId: 'icon-[name]',
      });

    // 修改images loader 添加svg处理
    const imagesRule = config.module.rule('images');
    imagesRule.exclude.add(resolve('src/assets/icons'));
    config.module
      .rule('images')
      .test(/\.(png|jpe?g|gif|svg)(\?.*)?$/);
    config.plugins.delete('named-chunks');
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
