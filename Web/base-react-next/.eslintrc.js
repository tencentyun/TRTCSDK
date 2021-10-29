module.exports = {
  parser: 'babel-eslint',
  extends: ['eslint-config-tencent', 'plugin:react/recommended'],
  rules: {
    'react/prop-types': 0,
  },
  settings: {
    react: {
      version: "detect",
    },
  }
};
