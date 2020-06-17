/**
 * 用于生成随机数字或随机字符串
 * @param {number} mult - 位数，个、十、千、万
 * @param {boolean} toASCCIIStr - 是否生成随机 asccii 字符串
 * @return {string | number}
 */
export default function(mult=1000, toASCCIIStr=false) {
    if (toASCCIIStr === false) {
        return Math.floor(Math.random() * mult);
    }
    let strModle = '0123456789abcdefghijklmnopqrstuvwxyz';
    let numLen = Math.ceil(Math.log10(mult)+1);
    let tmp = [];
    tmp.length = numLen;
    for (let i = 0; i < numLen; i++) {
        tmp.push(strModle[Math.round(Math.random() * strModle.length)]);
    }
    return tmp.join('');
}