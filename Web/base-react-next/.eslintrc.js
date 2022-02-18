module.exports = {
  parser: 'babel-eslint',
  globals: {
    "SpeechRecognizer": 'readonly',
    "ASR": 'readonly'
  },
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
