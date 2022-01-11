/**
 * 功能: 手机号检查
 * @param {String} phoneNumber
 * @param {Number} phoneArea
 */
export function checkPhoneNumber(phoneNumber, phoneArea) {
  if (!phoneNumber || !phoneArea) {
    return false;
  }
  const reg = /^1[3|4|5|7|8|6|9][0-9]\d{8}$/;

  switch (phoneArea) {
    case 86:
      return reg.test(phoneNumber);
    default:
      return true;
  }
}
