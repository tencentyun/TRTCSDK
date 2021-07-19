/**
 * 页面跳转
 * @param {string} pageName 和文件夹名称保持一致
 */
export function goToPage(path) {
  window.location.href = path || '/home';
}
