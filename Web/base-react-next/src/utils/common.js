import { SDKAPPID, SECRETKEY } from '@app/config';
import Cookies from 'js-cookie';
import Router from 'next/router';

/**
 * 页面跳转
 * @param {string} pathUrl 和文件夹名称保持一致
 */
export function goToPage(pathUrl) {
  if (/(http|https):\/\/([\w.]+\/?)\S*/.test(pathUrl)) {
    window.open(pathUrl, '_blank');
    return;
  }
  const isProd = process.env.NODE_ENV === 'production';
  const prodHref = `${location.pathname.slice(0, location.pathname.lastIndexOf('/') + 1) + pathUrl}.html`;
  const pathName = isProd ? prodHref : `/${pathUrl}`;
  Router.push({
    pathname: pathName,
    query: Router.query,
  });
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
    Cookies.get('token') ? (path && goToPage(path)) : goToPage('login');
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
  goToPage(data.path);
};
