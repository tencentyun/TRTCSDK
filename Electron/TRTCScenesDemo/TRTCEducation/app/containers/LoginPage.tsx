import React, { useState } from 'react';
import { Button, Message, Form, Input } from 'element-react';
import genTestUserSig from '../debug/GenerateTestUserSig'

export default function LoginPage(props:any) {
  const [userID, setUserID] = useState("");

  //短信验证码形式登录
  function login() {
    if(!userID) {
      Message({
        message: '请输入用户ID',
        type: 'warning'
      });
      return
    }
    const data = genTestUserSig(userID)
    if(data.sdkAppId === 0) { // 没有配置sdkappid和密钥信息
      return;
    }
    localStorage.setItem('TRTC_EDU_TOKEN', JSON.stringify(data));
    props.history.push('/home')
  }
  return (
      <div className='home-container'>
        <h3>实时音视频互动课堂</h3>
        <Form labelPosition='left' labelWidth="80" className="demo-form-stacked">
        <Form.Item label="用户ID">
            <Input value={userID} placeholder="请输入用户ID" maxLength={10} onChange={(value: any) => setUserID(value.replace(/[^\d]/g,''))}></Input>
          </Form.Item>
        </Form>
        <Button className="button-enter" type="primary" size='large' onClick={login} style={{marginTop: 40}}>登录</Button>
      </div>
  )
}
