module.exports = {
  extends: ['eslint-config-tencent', 'plugin:react/recommended'],
  rules: {
    'react/prop-types': 0
  },
  settings: {
    react: {
      version: '17.0.2',
    },
  },
  // rules: {
  //   'comma-dangle': ['error', {
  //     arrays: 'never',
  //     objects: 'never',
  //     imports: 'never',
  //     exports: 'never',
  //     functions: 'never'
  //   }]
  // }
};
