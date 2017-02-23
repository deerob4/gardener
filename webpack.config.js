let path = require('path');
let webpack = require('webpack');

const join = (dest) => path.resolve(__dirname, dest);
const web = (dest) => join('web/static/' + dest);

let config = {
  entry: web('js/index.js'),
  output: {
    path: join('priv/static/js'),
    filename: 'index.js'
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        include: web('js'),
        exclude: join('/node_modules/'),
        loader: 'babel-loader'
      },
      {
        test: /\.css$/,
        exclude: join('/node_modules'),
        use: [
          { loader: 'style-loader' },
          { loader: 'css-loader' },
          {
            loader: 'postcss-loader',
            options: {
              plugins: ctx => [
                require('postcss-cssnext')
              ]
            }
          }
        ]
      }
    ]
  },
  resolve: {
    alias: {
      css: web('css'),
      components: web('js/components'),
    }
  }
};

module.exports = config;
