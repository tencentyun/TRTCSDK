/**
 * 页面跳转
 * @param {string} pathUrl 和文件夹名称保持一致
 */
// eslint-disable-next-line import/prefer-default-export
export function goToPage(pathUrl) {
  window.setTimeout(() => {
    let hash = '';
    if (pathUrl === 'login') {
      hash = `#/login`;
    } else {
      hash = `#/home/${pathUrl}`;
    }
    window.location.href = window.location.href.split('#')[0] + hash;
  }, 100);
}
