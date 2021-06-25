// import LanguageDetector from 'i18next-browser-languagedetector';
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';
import resources from './locales/index';
import dynamic from 'next/dynamic';
const { getUrlParam, getCookie, getLanguage } = dynamic(import('@utils/utils'), { ssr: false });

/**
 * The interesting part here is by i18n.use(initReactI18next) we pass the i18n instance to react-i18next
 * which will make it available for all the components via the context api.
 * Then import that in index.js
 */
i18n
  .use(LanguageDetector)    // 检测浏览器语言
  .use(initReactI18next) // passes i18n down to react-i18next,make it available for all components via the context api
  .init({ // for all options read: https://www.i18next.com/overview/configuration-options
    resources,
    // fallbackLng: 'en', // 选择默认语言，选择内容为上述配置中的 key，即 en_US/zh_CN
    lng: (typeof getUrlParam === 'function' && getUrlParam('lang'))
      || (typeof getCookie === 'function' && getCookie('lang'))
      || (typeof getLanguage === 'function' && getLanguage()) || 'en', // 先获取 cookie 中的语言设置, 然后在获取浏览器设置的语言
    debug: true,
    keySeparator: false, // we do not use keys in form messages.welcome
    interpolation: {
      escapeValue: false, // react already safes from xss
    },
  });

export default i18n;
