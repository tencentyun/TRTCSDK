// eslint-disable-next-line import/no-unresolved
import Cookies from 'js-cookie';

// eslint-disable-next-line @typescript-eslint/naming-convention
const SEVEN_DAYs = 7; // default 7 days
const ONE_DAY_MILLISECOND = 864e5; // one day in milliseconds

const cookieStorage = {
  set(key, value, options = {}) {
    // If using "file://" access protocol, the "document.domain" is empty string
    if (document.domain) {
      Cookies.set(key, value, options);
    } else {
      // Date type of options.expires must be number or Date. If not, use the default
      if (
        typeof options.expires !== 'number' &&
        !(options.expires instanceof Date)
      ) {
        options.expires = SEVEN_DAYs;
      }
      if (typeof options.expires === 'number') {
        options.expires = new Date(
          Date.now() + options.expires * ONE_DAY_MILLISECOND
        );
      }
      if (options.expires) {
        options.expires = options.expires.toUTCString();
      }
      window.localStorage.setItem(
        `cookie_${key}`,
        JSON.stringify({
          value,
          options,
        })
      );
    }
  },
  get(key) {
    if (document.domain) {
      return Cookies.get(key);
    }
    let value = null;
    let cookieItem = window.localStorage.getItem(`cookie_${key}`);
    if (cookieItem) {
      try {
        cookieItem = JSON.parse(cookieItem);
        if (cookieItem?.options?.expires) {
          const expires = new Date(cookieItem.options.expires).getTime();
          if (expires > Date.now()) {
            value = cookieItem.value;
          } else {
            // cookie has expired, remove it
            this.remove(key);
          }
        } else {
          // invalid cookie value
          this.remove(key);
        }
      } catch (err) {
        console.warn(
          `[CookieStorage] come across invalid key/value: ${key}:${cookieItem}`
        );
        this.remove(key);
      }
    }

    return value;
  },
  remove(key) {
    if (document.domain) {
      Cookies.remove(key);
    } else {
      window.localStorage.removeItem(`cookie_${key}`);
    }
  },
};

export default cookieStorage;
