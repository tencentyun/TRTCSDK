import React, { useState, useEffect } from 'react';
import { Radio, Button, Message, Form, Input } from 'element-react';
import TrtcElectronEducation from 'trtc-electron-education';

let rtcClient:any = null

export default function HomePage(props:any) {
  const [classId, setClassId] = useState("");
  const [nickName, setNickName] = useState("");
  const [role, setRole] = useState('teacher');
  const [userID, setUserID] = useState('')

  useEffect(() => {
    try {
      //@ts-ignore
      const data = JSON.parse(localStorage.getItem('TRTC_EDU_TOKEN'));//登录信息存在localStorage
      setUserID(data['userId'])
      if(!rtcClient) {
        rtcClient = new TrtcElectronEducation({
          sdkAppId: data['sdkAppId'],
          userID: data['userId'],
          userSig: data['userSig']
        });
        bindEvent(rtcClient)
      }
    } catch(err) { //未登录
      props.history.push('/login')
    }
    return () => {
      unBindEvent()
      rtcClient = null;
    }
  }, [])

  function onError(event: { data: { errmsg: string; errcode: number; }; }) {
    console.log('error', event)
    Message({
      message: event.data.errmsg + event.data.errcode,
      type: 'error'
    });
  }
  function onWarning(event: { data: { errmsg: string; errcode: string; }; }) {
    console.log('warning', event)
    Message({
      message: event.data.errmsg + event.data.errcode,
      type: 'warning'
    });
  }
  function kickedOut() {
    Message({
      message: '被踢下线',
      type: 'warning'
    });
    localStorage.setItem('TRTC_EDU_TOKEN', '');
    props.history.push('/login');//跳去登录页面
  }
  function bindEvent(rtcClient: any) {
    const EVENT = rtcClient.EVENT;
    rtcClient.on(EVENT.ERROR, onError)
    rtcClient.on(EVENT.WARNING, onWarning)
    rtcClient.on(EVENT.KICKED_OUT, kickedOut)
  }
  function unBindEvent() {
    const EVENT = rtcClient.EVENT;
    rtcClient.off(EVENT.ERROR, onError)
    rtcClient.off(EVENT.WARNING, onWarning)
    rtcClient.off(EVENT.KICKED_OUT, kickedOut)
  }
  function reLogin() {
    localStorage.setItem('TRTC_EDU_TOKEN', '');
    props.history.push('/login')
  }
  function enterClass() {
    if(!classId) {
      Message('请输入教室ID');
      return;
    }
    if(!nickName) {
      Message('请输入昵称');
      return;
    }
    if(nickName.length > 10) {
      Message('昵称请少于10个字符');
      return;
    }
    const params = {
      classId,
      nickName,
      role
    }
    if(role === 'teacher') {
      rtcClient.createRoom(params).then(() => {
        goClass();
      }).catch((e:any) => {
        if(e.message && e.message.indexOf('操作者为群主') > 0) {//兼容房间没有销毁的情况
          goClass()
        } else {
          Message({
            message: '教室ID已被使用，请输入其他教室ID',
            type: 'warning'
          });
        }
      })
    } else if(role === 'student') {
      rtcClient.enterRoom(params).then((data: any) => {
        if(data && data.code === 'UserIsGroupLeader') {
          Message({
            message: '您是这个教室的老师，请以老师身份进教室',
            type: 'warning'
          });
        } else {
          goClass()
        }
      }).catch((e:any) => {
        console.log('进房失败', e)
        Message({
          message: '教室ID不存在',
          type: 'warning'
        });
      })
    }
  }
  function goClass() {
    props.history.push({pathname: '/classRoom',state:{
      rtcClient: rtcClient,
      classId: classId,
      userID: userID,
      role: role,
      nickName: nickName
    }
  })
  }
  return (
      <div className="home-container" style={{height:400, marginTop: 150}}>
        <h3>实时音视频互动课堂</h3>
        <Form labelPosition='left' labelWidth="80" className="demo-form-stacked">
        <Form.Item label="教室ID">
            <Input value={classId} maxLength={10} placeholder="请输入10位以内的数字" onChange={(value: any) => setClassId(value.replace(/[^\d]/g,''))}></Input>
          </Form.Item>
          <Form.Item label="昵称">
            <Input value={nickName} placeholder="请输入昵称" onChange={(value: any) => setNickName(value)}></Input>
          </Form.Item>
          <Form.Item label="角色">
            <Radio value="teacher" checked={role === 'teacher'} onChange={(value: any) => setRole(value)}>老师</Radio>
            <Radio value="student" checked={role === 'student'} onChange={(value: any) => setRole(value)}>学生</Radio>
          </Form.Item>
        </Form>
        <div><Button type="primary" className="button-enter" onClick={enterClass}>进入教室</Button></div>
        <div><Button className="button-enter" style={{border: '1px solid #0A818C', color: '#0A818C'}} type="text" onClick={reLogin}>返回登录界面</Button></div>
      </div>
  )
}
