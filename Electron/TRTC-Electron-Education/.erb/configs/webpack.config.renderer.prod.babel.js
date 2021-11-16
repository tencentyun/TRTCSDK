/**
 * Build config for electron renderer process
 */

import path from 'path';
import webpack from 'webpack';
import HtmlWebpackPlugin from 'html-webpack-plugin';
import MiniCssExtractPlugin from 'mini-css-extract-plugin';
import { BundleAnalyzerPlugin } from 'webpack-bundle-analyzer';
import CssMinimizerPlugin from 'css-minimizer-webpack-plugin';
import { merge } from 'webpack-merge';
import TerserPlugin from 'terser-webpack-plugin';
import baseConfig from './webpack.config.base';
import webpackPaths from './webpack.paths.js';
import checkNodeEnv from '../scripts/check-node-env';
import deleteSourceMaps from '../scripts/delete-source-maps';

checkNodeEnv('production');
deleteSourceMaps();

const devtoolsConfig =
  process.env.DEBUG_PROD === 'true'
    ? {
        devtool: 'source-map',
      }
    : {};

export default merge(baseConfig, {
  ...devtoolsConfig,

  mode: 'production',

  // target: ['web', 'electron-renderer'],
  /**
   * 支持渲染进程使用node.js require()，更好的方式是使用上一行配置。
   * 此处需要结合 nodeIntegration:true 一起使用，才能正常使用 TRTC-Electron-SDK。
   * 文档说明：https://electron-react-boilerplate.js.org/docs/native-modules/
   *
   * 如何更健壮优雅的使用 TRTC-Electron-SDK，可使用以下两种方式规避此处不佳的配置：
   * （1）所有 TRTC-Electron-SDK 的使用都在主进程，渲染进程基于IPC方式调用 TRTC-Electron-SDK能力；
   *      --可行性和技术复杂度有待验证
   * （2）TRTC-Electron-SDK中将 node.js 模块（写文件）的能力下移到底层。
   *      --需要修改 SDK 接口
   */
  target: 'electron-renderer',

  entry: [
    'core-js',
    'regenerator-runtime/runtime',
    path.join(webpackPaths.srcRendererPath, 'index.tsx'),
  ],

  output: {
    path: webpackPaths.distRendererPath,
    publicPath: './',
    filename: 'renderer.js',
    // 上方 target: 'electron-renderer' 时，以下配置需要删除
    // library: {
    //   type: 'umd',
    // },
  },

  module: {
    rules: [
      {
        // CSS/SCSS
        test: /\.s?css$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader,
            options: {
              // `./dist` can't be inerhited for publicPath for styles. Otherwise generated paths will be ./dist/dist
              publicPath: './',
            },
          },
          'css-loader',
          'sass-loader',
        ],
      },
      // WOFF Font
      {
        test: /\.woff(\?v=\d+\.\d+\.\d+)?$/,
        use: {
          loader: 'url-loader',
          options: {
            limit: 10000,
            mimetype: 'application/font-woff',
          },
        },
      },
      // WOFF2 Font
      {
        test: /\.woff2(\?v=\d+\.\d+\.\d+)?$/,
        use: {
          loader: 'url-loader',
          options: {
            limit: 10000,
            mimetype: 'application/font-woff',
          },
        },
      },
      // OTF Font
      {
        test: /\.otf(\?v=\d+\.\d+\.\d+)?$/,
        use: {
          loader: 'url-loader',
          options: {
            limit: 10000,
            mimetype: 'font/otf',
          },
        },
      },
      // TTF Font
      {
        test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/,
        use: {
          loader: 'url-loader',
          options: {
            limit: 10000,
            mimetype: 'application/octet-stream',
          },
        },
      },
      // EOT Font
      {
        test: /\.eot(\?v=\d+\.\d+\.\d+)?$/,
        use: 'file-loader',
      },
      // SVG Font
      {
        test: /\.svg(\?v=\d+\.\d+\.\d+)?$/,
        use: {
          loader: 'url-loader',
          options: {
            limit: 10000,
            mimetype: 'image/svg+xml',
          },
        },
      },
      // Common Image Formats
      {
        test: /\.(?:ico|gif|png|jpg|jpeg|webp)$/,
        use: 'url-loader',
      },
    ],
  },

  optimization: {
    minimize: true,
    minimizer: [
      new TerserPlugin({
        parallel: true,
      }),
      new CssMinimizerPlugin(),
    ],
  },

  plugins: [
    /**
     * Create global constants which can be configured at compile time.
     *
     * Useful for allowing different behaviour between development builds and
     * release builds
     *
     * NODE_ENV should be production so that modules do not perform certain
     * development checks
     */
    new webpack.EnvironmentPlugin({
      NODE_ENV: 'production',
      DEBUG_PROD: false,
    }),

    new MiniCssExtractPlugin({
      filename: 'style.css',
    }),

    new BundleAnalyzerPlugin({
      analyzerMode:
        process.env.OPEN_ANALYZER === 'true' ? 'server' : 'disabled',
      openAnalyzer: process.env.OPEN_ANALYZER === 'true',
    }),

    new HtmlWebpackPlugin({
      filename: 'index.html',
      template: path.join(webpackPaths.srcRendererPath, 'index.ejs'),
      minify: {
        collapseWhitespace: true,
        removeAttributeQuotes: true,
        removeComments: true,
      },
      isBrowser: false,
      isDevelopment: process.env.NODE_ENV !== 'production',
    }),
  ],
});
