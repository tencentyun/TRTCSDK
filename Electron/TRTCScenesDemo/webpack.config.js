const path = require('path');

module.exports = {
  mode: 'development',
  target: 'electron-renderer',
  entry: './js/demo.js',
  output: {
    path: path.join(__dirname, 'dist'),
    publicPath: path.join(__dirname, 'static'),
    filename: 'bundle.js',
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: "babel-loader"
      },
      {
        test: /\.node$/, 
        use: 'node-loader'
      }
    ]
  },

  resolve: {
    extensions: ['.js', '.node'],
  }
};