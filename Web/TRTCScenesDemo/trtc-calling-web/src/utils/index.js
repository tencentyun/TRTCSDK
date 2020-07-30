const LOG_PREFIX = 'trtc-callling-webrtc-demo:';

export function isValidatePhoneNum(phoneNum) {
  const reg = new RegExp('^1[0-9]{10}$', 'gi');
  return phoneNum.match(reg);
}

export function isUserNameValid(username) {
  return username && username.length <= 20;
}

export function setUserLoginInfo({token, phoneNum}) {
  localStorage.setItem('userInfo', JSON.stringify({token, phoneNum}));
}

export function addToSearchHistory(searchUser) {
  const MAX_HISTORY_NUM = 3;
  let searchUserList = getSearchHistory();
  const found = searchUserList.find(user => user.userId === searchUser.userId);
  if (!found) {
    searchUserList.push(searchUser);
  }
  if (searchUserList.length > MAX_HISTORY_NUM) {
    searchUserList = searchUserList.slice(-MAX_HISTORY_NUM);
  }
  localStorage.setItem('searchHistory', JSON.stringify(searchUserList));
}

export function getSearchHistory() {
  try {
    return JSON.parse(localStorage.getItem('searchHistory') || '[]');
  } catch (e) {
    return [];
  }
}

export function getUserLoginInfo() {
  try {
    return JSON.parse(localStorage.getItem('userInfo') || '{}');
  } catch (e) {
    return {};
  }
}

export function log(content) {
  console.log(`${LOG_PREFIX} ${content}`)
}
