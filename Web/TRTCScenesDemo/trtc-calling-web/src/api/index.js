import axios from 'axios';
import qs from 'qs';

const API_DOMAIN = 'https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com';

export async function getSmsVerifyCode(phoneNum) {
  let data = {
    method: 'getSms',
    phone: phoneNum
  };
  const options = buildOptions(data, '/release/sms')
  return axios(options);
}

export async function loginSystemByVerifyCode(loginInfo) {
  const {phoneNum, sessionId, verifyCode} = loginInfo;
  let data = {
    method: 'login',
    phone: phoneNum,
    code: verifyCode,
    sessionId
  };
  const options = buildOptions(data, '/release/sms');
  return axios(options);
}

export async function loginSystemByToken(phoneNum, token) {
  let data = {
    method: 'login',
    phone: phoneNum,
    token
  };
  const options = buildOptions(data, '/release/sms');
  return axios(options);
}

export async function fetchUserInfoByPhone(phone, token) {
  let data = {
    phone,
    token
  };
  const options = buildOptions(data, '/release/getUserInfo');
  return axios(options);
}

export async function fetchUserInfoByUserId(userId, token) {
  let data = {
    userId,
    token
  };
  const options = buildOptions(data, '/release/getUserInfo');
  return axios(options);
}

export async function updateUserName(name, userId, token) {
  let data = {
    userId,
    name,
    token
  };
  const options = buildOptions(data, '/release/setNickname');
  return axios(options);
}

function buildOptions(data, apiPath) {
  return {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    data: qs.stringify(data),
    url: `${API_DOMAIN}${apiPath}`,
  }
}
