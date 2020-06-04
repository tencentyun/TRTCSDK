import React, { useState, useEffect } from 'react';
import { Tabs, Button, Dialog, Message, Layout } from 'element-react';
import Chat from '../components/Chat'
import UserList from '../components/UserList'
import TeacherClass from '../components/TeacherClass';
import {ipcRenderer} from 'electron'
import StudentClass from '../components/StudentClass';

//@ts-ignore
import logoImg from '../imgs/logo.png'

export default function ClassRoomPage(props:any) {
  const [tab, setTab] = useState('1');
  const [isBegin, setIsBegin] = useState(false);//是否开始上课
  const [isMic, setIsMic] = useState(true);//本地是否有麦克风
  const [exitClassVisible, setExitClassVisible] = useState(false);

  const [memberList, setMemberList] = useState([]);
  if(!props.location.state) {
    props.history.push('/login')
    return null;
  }
  const {rtcClient, userID, classId, role, nickName} = props.location.state;

  function enterRoomSuccess(event: { data: { result: number; }; }) {
    const result = event.data.result;
    if(result < 0) {
      if(role === 'teacher') {
        Message({
          message: '开始上课失败' + result,
          type: 'error'
        });
      } else {
        Message({
          message: '进入教室失败' + result,
          type: 'error'
        });
      }
    } else {
      if(role === 'teacher') {
        setIsBegin(true)
      }
    }
  }
  function leaveRoomSuccess() {
    if(role === 'teacher') {
      setIsBegin(false)
    }
  }
  function kickedOut() {
    rtcClient.rtcCloud.exitRoom();
    Message({
      message: '被踢下线',
      type: 'warning'
    });
    localStorage.setItem('TRTC_EDU_TOKEN', '');
    props.history.push('/login');
  }
  function onError(event: { data: { errmsg: string; errcode: number; }; }) {
    console.log('error', event)
    if(event.data.errcode == -1302) {
      setIsMic(false)
      setTimeout(() => {//这里自动置为true
        setIsMic(true)
      }, 1000)
      Message({
        message: '未发现麦克风设备' + event.data.errcode,
        duration: 10000,
        type: 'error'
      });
    } else if(event.data.errcode == -1301) {
      Message({
        message: '未发现摄像头设备' + event.data.errcode,
        duration: 10000,
        type: 'error'
      });
    } else {
      Message({
        message: event.data.errmsg + event.data.errcode,
        type: 'error'
      });
    }
  }
  function onWarning(event: { data: { errmsg: string; errcode: string; }; }) {
    console.log('warning', event)
    Message({
      message: event.data.errmsg + event.data.errcode,
      type: 'warning'
    });
  }
  //绑定事件
  function bindEvent() {
    const EVENT = rtcClient.EVENT;
    // 进入trtc房间
    rtcClient.on(EVENT.ENTER_ROOM_SUCCESS, enterRoomSuccess)
    // 离开trtc房间
    rtcClient.on(EVENT.LEAVE_ROOM_SUCCESS, leaveRoomSuccess)
    //学生加入教室
    rtcClient.on(EVENT.STUDENT_ENTER, getMemberList)
    //学生离开教室
    rtcClient.on(EVENT.STUDENT_LEAVE, getMemberList)
    //被踢下线
    rtcClient.on(EVENT.KICKED_OUT, kickedOut)
    //监听sdk的错误
    rtcClient.on(EVENT.ERROR, onError)
    //监听sdk的warning
    rtcClient.on(EVENT.WARNING, onWarning)
  }

  function getMemberList() {
    rtcClient.getMemberList(classId).then((res: {data: { memberList: any; }}) => {
      const memberList = res.data.memberList;
      const newList:any = []
      let ownerItem = {}
      memberList.map((item:any) => {
        if(item['role'] === 'Owner') {
          ownerItem = item;
        } else {
          newList.push(item);
        }
      })
      newList.unshift(ownerItem);
      setMemberList(newList);
    }).catch(() => {
      setMemberList([]);
    })
  }
  // 老师退出教室
  function exitClass() {
    rtcClient.exitRoom(role, classId)
    rtcClient.destroyRoom(classId).finally(() => {
      props.history.push('/home')
    })
  }
  // 学生退出教室
  function exitRoom() {
    rtcClient.exitRoom(role, classId)
    props.history.push('/home')
  }
  function closeWindow() {
    console.log('app-close', role)
    if(role === 'teacher') {
      setExitClassVisible(true);
    } else {
      exitRoom()
    }
  }
  function unBindEvent() {
    const EVENT = rtcClient.EVENT;
    rtcClient.off(EVENT.ENTER_ROOM_SUCCESS, enterRoomSuccess)
    rtcClient.off(EVENT.LEAVE_ROOM_SUCCESS, leaveRoomSuccess)
    rtcClient.off(EVENT.STUDENT_ENTER, getMemberList)
    rtcClient.off(EVENT.STUDENT_LEAVE, getMemberList)
    rtcClient.off(EVENT.KICKED_OUT, kickedOut)
    rtcClient.off(EVENT.ERROR, onError)
    rtcClient.off(EVENT.WARNING, onWarning)
  }
  useEffect(() => {
    bindEvent()
    ipcRenderer.send('enterClass');//已经进入教室
    //监听窗口关闭事件
    ipcRenderer.on('app-close', closeWindow)
    return () => {
      ipcRenderer.send('leaveClass');//离开教室
      ipcRenderer.off('app-close', closeWindow)
      unBindEvent()
    }
  }, [])

  return (
    <div className="classRoom">
      <Dialog
        title="确定要退出教室？"
        closeOnClickModal = {false}
        size="tiny"
        visible={ exitClassVisible }
        onCancel={ () => {setExitClassVisible(false)}}>
        <Dialog.Body>
          退出教室后，该教室会被解散，学生无法看到您分享的画面和声音。
        </Dialog.Body>
        <Dialog.Footer className="dialog-footer">
          <Button type="primary" onClick={ () =>  {exitClass();setExitClassVisible(false)}}>退出</Button>
          <Button onClick={ () => setExitClassVisible(false) }>取消</Button>
        </Dialog.Footer>
      </Dialog>

      <div className="header">
        <img className="logo" src={logoImg} />
        <span style={{marginLeft: 40}}>腾讯实时音视频互动课堂</span>
        <span style={{marginLeft: 20}}>教室ID:{classId} </span>
        <span style={{marginLeft: 20}}>用户:{userID}{nickName ? '-' + nickName : ''}</span>

        <Button type="text" style={{width: 100,float: 'right',marginRight: 10}} onClick={() => {
          if(role === 'teacher') {
            setExitClassVisible(true)
          } else {
            exitRoom();
          }
        }}><i className="el-icon-close el-icon-left"></i>退出教室</Button>
      </div>

      <Layout.Row style={{padding: 10}}>
        <Layout.Col span="18" className="roomCol">

        {role === 'teacher' ?
        <TeacherClass
          rtcClient={rtcClient}
          classId={classId}
          role={role}
          nickName={nickName}
        />
        :
        <StudentClass
          rtcClient={rtcClient}
          userID={userID}
          isMic={isMic}
          classId={classId}
          role={role}
          history={props.history}
          nickName={nickName}
        />
        }

        </Layout.Col>
        <Layout.Col span="6">
          {role === 'teacher' ?
          <div className="roomRight courseNotice">学生进入{classId}教室即可听课</div>
          :
          <div className="roomRight courseNotice">欢迎来到教室：{classId}</div>
          }
          <div className="roomRight">
            <Tabs activeName={tab} onTabClick={ (tab) =>  setTab(tab.props.name)}>
              <Tabs.Pane label="消息列表" name="1">
                <Chat rtcClient={rtcClient} classId={classId} userID={userID} nickName={nickName} />
              </Tabs.Pane>
              <Tabs.Pane label="成员列表" name="2">
                <UserList memberList={memberList} getMemberList={getMemberList} rtcClient={rtcClient} tab={tab} role={role} isBegin={isBegin} />
              </Tabs.Pane>
            </Tabs>
            </div>
          </Layout.Col>
      </Layout.Row>
    </div>
  )
}
