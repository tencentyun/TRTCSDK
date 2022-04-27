import { getLanguage } from '@/utils/utils';
import { createI18n } from 'vue-i18n';

function loadLocaleMessages() {
  const locales = require.context('./lang', true, /[A-Za-z0-9-_,\s]+\.json$/i);
  const messages: any = {};
  locales.keys().forEach((key) => {
    const matched = key.match(/([A-Za-z0-9-_]+)\./i);
    if (matched && matched.length > 1) {
      const locale = matched[1];
      messages[locale] = locales(key);
    }
  });
  return messages;
}

const i18n = createI18n({
  locale: getLanguage() || 'en',
  legacy: false, // 使用Composition API，这里必须设置为false
  globalInjection: true,
  global: true,
  fallbackLocale: 'en',
  messages: loadLocaleMessages(),
});

export default i18n;
