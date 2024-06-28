import { SDKAPPID, SECRETKEY } from '@app/config';
import Cookies from 'js-cookie';
import Router from 'next/router';
import { getUrlParam, getUrlParamObj } from '@utils/utils';

/**
 * 页面跳转
 * @param {string} pathUrl 和文件夹名称保持一致
 * @param {boolean} withoutHistory 是否不保留历史记录，默认保留
 */
export function goToPage(pathUrl, withoutHistory = false) {
  if (/(http|https):\/\/([\w.]+\/?)\S*/.test(pathUrl)) {
    window.open(pathUrl, '_blank');
    return;
  }

  // 确认跳转页面链接
  const isProd = process.env.NODE_ENV === 'production';
  const [toPathName, toPathSearch] = /\?/.test(pathUrl) ? pathUrl.split('?') : [pathUrl, ''];
  const toHref = isProd
    ? `${location.pathname.slice(0, location.pathname.lastIndexOf('/') + 1) + toPathName}.html`
    : `/${toPathName}`;
  console.log('gotoPage = ', toHref);

  // 确认跳转页面参数
  const customQueryObj = getUrlParamObj();
  const queryObj = toPathSearch
    ? Object.assign(toPathSearch.split('&').reduce((cur, str) => ({ ...cur, [str.split('=')[0]]: str.split('=')[1] }), {}), customQueryObj)
    : customQueryObj;
  if (toPathName === 'login') {
    queryObj.from = Router.pathname.slice(1);
  } else {
    delete queryObj.from;
  }
  const queryString = Object.keys(queryObj).reduce((cur, key) => (cur ? `${cur}&${key}=${queryObj[key]}` : `${cur}${key}=${queryObj[key]}`), '');

  // 页面跳转
  if (withoutHistory) {
    Router.replace(queryString ? `${toHref}?${queryString}` : `${toHref}`);
  } else {
    Router.push({
      pathname: toHref,
      query: queryObj,
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
  let language = getUrlParam('lang') || Cookies.get('trtc-api-example-lang') || navigator.language || 'zh-CN';
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
