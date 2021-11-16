/* eslint-disable @typescript-eslint/naming-convention */
import a18n from 'a18n';
import locales_en from './locales/en-US.json';
import locales_zh from './locales/zh-CN.json';

const LANGUAGE_NAME_EN = 'en-US';
const LANGUAGE_NAME_ZH = 'zh-CN';

a18n.addLocaleResource(LANGUAGE_NAME_EN, locales_en);
a18n.addLocaleResource(LANGUAGE_NAME_ZH, locales_zh);

function calcValidLanguage(lang) {
  if (/^zh\b/.test(lang)) {
    return LANGUAGE_NAME_ZH;
  }
  return LANGUAGE_NAME_EN;
}

// eslint-disable-next-line @typescript-eslint/naming-convention
// eslint-disable-next-line no-underscore-dangle
let _locale = calcValidLanguage(
  window.localStorage.getItem('lang') ||
    window.navigator.language ||
    LANGUAGE_NAME_ZH
);
a18n.setLocale(_locale);

window.a18n = a18n; // 覆盖preload.js中初始化的a18n（Override the 'a18n' definition in proload.js file）

export function setLocale(lang) {
  _locale = calcValidLanguage(lang);
  window.localStorage.setItem('lang', _locale);
  a18n.setLocale(_locale);
  window.location.reload();
}

export function getLocale() {
  return _locale;
}
