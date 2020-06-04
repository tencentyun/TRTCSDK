/*
  工具类方法
*/

export const Tool = {

  //获取url参数上的集合
  getUrlParam(urlStr:string) {
    let url = ''
    if (typeof urlStr == "undefined") {
        url = decodeURI(location.search); //获取url中"?"符后的字符串
    } else {
        url = "?" + urlStr.split("?")[1];
    }
    const theRequest:any = new Object();
    if (url.indexOf("?") != -1) {
        const str = url.substr(1);
        const strs = str.split("&");
        for (var i = 0; i < strs.length; i++) {
            theRequest[strs[i].split("=")[0]] = decodeURI(strs[i].split("=")[1]);
        }
    }
    return theRequest;
  }
}
