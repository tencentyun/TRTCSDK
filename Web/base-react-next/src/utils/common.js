import { SDKAPPID, SECRETKEY } from '@app/config';
import Cookies from 'js-cookie';
import Router from 'next/router';
import { getUrlParam } from '@utils/utils';

/**
 * 页面跳转
 * @param {string} pathUrl 和文件夹名称保持一致
 */
export function goToPage(pathUrl, withoutHistory = false) {
  if (/(http|https):\/\/([\w.]+\/?)\S*/.test(pathUrl)) {
    window.open(pathUrl, '_blank');
    return;
  }
  const isProd = process.env.NODE_ENV === 'production';
  const tempArray = /\?/.test(pathUrl) ? pathUrl.split('?') : [pathUrl, ''];
  const prodHref = `${location.pathname.slice(0, location.pathname.lastIndexOf('/') + 1) + tempArray[0]}.html`;
  const pathName = isProd ? prodHref : `/${tempArray[0]}`;
  console.log('gotoPage = ', pathName);
  const query = tempArray[1]
    ? tempArray[1].split('&').reduce((cur, str) => ({ ...cur, [str.split('=')[0]]: str.split('=')[1] }), {})
    : Router.query;
  if (withoutHistory) {
    Router.replace(pathName);
  } else {
    Router.push({
      pathname: pathName,
      query,
    });
  }
}

/**
 * 确定页面跳转
 * 情况一：使用 api 接口获取 userSig 时，判断页面是否需要跳转到登录页面
 * 情况二：使用本地 SECRETKEY 获取 userSig 时，跳转到指定页面
 */
export function handlePageUrl(path) {
  const hasLoginPage = SDKAPPID && SECRETKEY.length === 0;
  // 使用 api 接口获取 userSig ，且 Cookies 中没有 token 或 token 失效跳转到登录页面
  if (hasLoginPage) {
    Cookies.get('trtc-api-example-token') ? (path && goToPage(path)) : goToPage('login');
    return;
  }
  // 使用本地 SECRETKEY 获取 userSig 时跳转到指定页面
  if (!hasLoginPage) {
    path && goToPage(path);
    return;
  }
}

/**
 * 处理 navigator 的路由点击跳转
 * @param {}} data sideBar组件onChange的参数
 */
export function handlePageChange(data) {
  if (data.type === 'group') {
    return;
  }
  const language = getLanguage();
  const path = language !== 'zh-CN' ? data.enPath || data.path : data.path;
  goToPage(path);
};

export function getLanguage() {
  let language = Cookies.get('trtc-api-example-lang') || getUrlParam('lang') || navigator.language || 'zh-CN';
  language = language.replace(/_/, '-').toLowerCase();

  if (language === 'zh-cn' || language === 'zh') {
    language = 'zh-CN';
  } else if (language === 'zh-tw' || language === 'zh-hk') {
    language = 'zh-TW';
  } else if (language === 'en' || language === 'en-us' || language === 'en-GB') {
    language = 'en';
  }
  return language;
}
