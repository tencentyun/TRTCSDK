const USER_AGENT = navigator.userAgent;

export const IS_IPAD = /iPad/i.test(USER_AGENT);
export const IS_IPHONE = /iPhone/i.test(USER_AGENT) && !IS_IPAD;
export const IS_IPOD = /iPod/i.test(USER_AGENT);
export const IS_IOS = IS_IPHONE || IS_IPAD || IS_IPOD;
export const IS_WIN = /Windows/i.test(USER_AGENT);
export const IS_MAC = !IS_IOS && /MAC OS X/i.test(USER_AGENT);
export const IS_CHROME_ONLY = /Chrome/i.test(USER_AGENT);
