/**
 * Base webpack config used across other specific configs
 */

import path from 'path';
import os from 'os';
import webpack from 'webpack';
import webpackPaths from './webpack.paths.js';
import { dependencies as externals } from '../../build/app/package.json';

const targetPlatform = (function(){
  let target = os.platform();
  for (let i=0; i<process.argv.length; i++) {
    if (process.argv[i].includes('--target_platform=')) {
      target = process.argv[i].replace('--target_platform=', '');
      break;
    }
  }
  if (!['win32', 'darwin'].includes) target = os.platform();
  return target;
})();
console.log('targetPlatform', targetPlatform);

const getRewritePath = function() {
  console.log('getRewritePath:', process.env.NODE_ENV);
  let rewritePathString = '';
  if (process.env.NODE_ENV === 'production') {
    rewritePathString = targetPlatform === 'win32' ? './resources' : '../Resources';
  } else if (process.env.NODE_ENV === 'development') {
    rewritePathString = 'node_modules/trtc-electron-sdk/build/Release';
  }
  return rewritePathString;
};

export default {
  externals: [...Object.keys(externals || {})],

  module: {
    rules: [
      { test: /\.node$/, loader: 'native-ext-loader', options: { rewritePath: getRewritePath() } },
      {
        test: /\.[jt]sx?$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            cacheDirectory: true,
          },
        },
      },
    ],
  },

  output: {
    path: webpackPaths.srcPath,
    // https://github.com/webpack/webpack/issues/1114
    library: {
      type: 'commonjs2',
    },
  },

  /**
   * Determine the array of extensions that should be used to resolve modules.
   */
  resolve: {
    extensions: ['.js', '.jsx', '.json', '.ts', '.tsx'],
    modules: [webpackPaths.srcPath, 'node_modules'],
    // fallback: {
    //   fs: require.resolve('fs'),
    // },
  },

  plugins: [
    new webpack.EnvironmentPlugin({
      NODE_ENV: 'production',
    }),
  ],
  // node: {
  //   global: false,
  //   __filename: false,
  //   __dirname: false,
  // },
  // target: 'node'
};
