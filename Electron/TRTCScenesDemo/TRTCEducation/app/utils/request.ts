import axios from 'axios'
import querystring from 'querystring'

const BASEURL = 'https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/eduSms';

export function ServicePost(params: any) {
    let requesurl = `${BASEURL}`
    const body = querystring.encode(params);
    return new Promise((resolve, reject) => {
        axios.post(requesurl, body, {
            timeout: 35000,
            withCredentials: true,
            headers: { 'content-type': 'application/x-www-form-urlencoded' }
        }).then(res => {
            resolve(res.data);
        }).catch(error => {
            reject(error)
        })
    })
}

// TODO
// 返回码、CGI测速上报
export default function Service(url: string, params?: object) {

    const uriObj = Object.assign({}, params)
    const uri = qs.stringify(uriObj, { arrayFormat: 'indices' }) //去掉最后一个&、
    return new Promise((resolve, reject) => {
        let requesurl = `${BASEURL}${url}?${uri}`

        if (url.indexOf("http") >= 0) {
            requesurl = `${url}?${uri}`
        }
        axios(requesurl, {
            timeout: 35000,
            withCredentials: true
        }).then(data => {
            let json = typeof data.data === 'string' ? JSON.parse(data.data) : data.data;
            if (json.Response['Error']) {
                reject(new Error(json.Response.Error.Message))
            } else {
                resolve(json.Response)
            }
        }).catch(error => {
            console.error('发生系统错误' + error.errmsg);

            reject(error)
        })
    })
}
