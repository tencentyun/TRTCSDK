import React, { useState, useEffect } from 'react';

import { Button, Dialog, Message } from 'element-react';

//@ts-ignore
import handImg from '../imgs/hand.png'
//@ts-ignore
import voiceGif from '../imgs/voice.gif'
//@ts-ignore
import speakImg from '../imgs/speak.png'
//@ts-ignore
import noSpeakImg from '../imgs/noSpeak.png'
//@ts-ignore
import closeImg from '../imgs/close.png'

interface StudentClassProps {
  rtcClient: any,
  userID: string,
  isMic: boolean,
  classId: string,
  role: string,
  history: any,
  nickName: string
}

export default function StudentClass(props: StudentClassProps) {
  const [courseEndVisible, setCourseEndVisible] = useState(false);//课程是否结束
  const [isVideoAdd, setIsVideoAdd] = useState(false);
  const [isBegin, setIsBegin] = useState(false);//是否开始上课
  const [isQaTime, setIsQaTime] = useState(false);
  const [teacherUserID, setTeacherUserID] = useState('');
  const [studentSpeak, setStudentSpeak] = useState(false);
  const [isShareAdd, setIsShareAdd] = useState(false);
  const [speakVisible, setSpeakVisible] = useState(false);
  const [isRaiseHand, setRaiseHand] = useState(false);//是否举手

  const {rtcClient, classId, role, isMic} = props;

  function remoteVideoAdd(event: { data: { userID: string; }; }) {
    setTeacherUserID(event.data.userID)
    setIsVideoAdd(true)
  }
  function remoteVideoRemove(event: { data: { userID: string; }; }) {
    setTeacherUserID(event.data.userID)
    setIsVideoAdd(false)
  }
  function screenShareAdd(event: { data: { userID: string; }; }) {
    setTeacherUserID(event.data.userID)
    setIsShareAdd(true)
  }
  function screenShareRemove(event: { data: { userID: string; }; }) {
    setTeacherUserID(event.data.userID)
    setIsShareAdd(false)
    rtcClient.stopRemoteView({
      userID: event.data.userID,
      streamType: 3//屏幕分享
    });
  }
  function teacherEnter() {
    setIsBegin(true)
  }
  function teacherLeave() {
    setIsBegin(false)
  }
  function questionTimeStarted() {
    Message('老师已开放举手，现在你可以申请举手发言啦！')
    setIsQaTime(true)
  }
  function questionTimeStopped() {
    setIsQaTime(false)
    setStudentSpeak(false)
    setSpeakVisible(false)
    setRaiseHand(false)
  }
  function invitedToPlatform() {
    setStudentSpeak(true);
    setSpeakVisible(true)
  }
  function answerFinished() {
    setStudentSpeak(false);
    setSpeakVisible(false)
    setRaiseHand(false)
    Message({
      message: '你已被老师禁麦',
      type: 'success'
    });
  }
  function roomDestroyed() {
    setCourseEndVisible(true)
  }
  //绑定事件
  function bindEvent() {
    const EVENT = rtcClient.EVENT;
    // 老师开启摄像头
    rtcClient.on(EVENT.REMOTE_VIDEO_ADD, remoteVideoAdd)
    // 老师关闭摄像头
    rtcClient.on(EVENT.REMOTE_VIDEO_REMOVE, remoteVideoRemove)
    // 老师开启屏幕分享
    rtcClient.on(EVENT.SCREEN_SHARE_ADD, screenShareAdd)
    // 老师关闭屏幕分享
    rtcClient.on(EVENT.SCREEN_SHARE_REMOVE, screenShareRemove)
    //老师开始上课
    rtcClient.on(EVENT.TEACHER_ENTER, teacherEnter)
    //老师结束上课
    rtcClient.on(EVENT.TEACHER_LEAVE, teacherLeave)
    //老师开始问答
    rtcClient.on(EVENT.QUESTION_TIME_STARTED, questionTimeStarted)
    //老师结束问答
    rtcClient.on(EVENT.QUESTION_TIME_STOPPED, questionTimeStopped)
    //邀请学生上台回答
    rtcClient.on(EVENT.BE_INVITED_TO_PLATFORM, invitedToPlatform)
    //被老师禁麦
    rtcClient.on(EVENT.ANSWERING_FINISHED, answerFinished)
    //教室已被销毁
    rtcClient.on(EVENT.ROOM_DESTROYED, roomDestroyed)
  }
  //学生主动闭麦
  function exitSpeak() {
    setRaiseHand(false)
    setStudentSpeak(false)
    rtcClient.closeMicrophone();
  }
  //学生举手
  function raiseHand() {
    setRaiseHand(true);
    rtcClient.raiseHand();
    Message({
      message: '举手成功，请等待老师同意。发言时建议佩戴耳机，避免麦克风收录到电脑外放的声音。',
      type: 'success'
    });
  }
  // 学生退出教室
  function exitRoom() {
    rtcClient.exitRoom(role, classId)
    props.history.push('/home')
  }
  function clearData() {
    setIsVideoAdd(false)
    setIsQaTime(false)
    setStudentSpeak(false)
    setIsShareAdd(false)
    setSpeakVisible(false)
    setRaiseHand(false)
  }
  useEffect(() => {
    rtcClient.stopRemoteView({
      userID: teacherUserID,
      streamType: 1 //1-大画面，2-小画面
    });
    if(isVideoAdd && !isShareAdd) {
      showFullVideo()
    } else if(isVideoAdd && isShareAdd) {
      showScreenVideo()
      showSubScreen()
    } else if(!isVideoAdd && isShareAdd) {
      showSubScreen()
    }
  }, [isVideoAdd, isShareAdd])
  function showScreenVideo() {
    const view = document.getElementById('studentScreenVideo');
    rtcClient.startRemoteView({
      userID: teacherUserID,
      streamType: 1,//1-大画面，2-小画面
      view: view
    });
  }
  function showFullVideo() {
    const view = document.getElementById('studentFullVideo');
    rtcClient.startRemoteView({
      userID: teacherUserID,
      streamType: 1,//1-大画面，2-小画面
      view: view
    });
  }
  function showSubScreen() {
    const viewScreen = document.getElementById('localSub');
    rtcClient.startRemoteView({
      userID: teacherUserID,
      streamType: 3,//屏幕分享
      view: viewScreen
    });
  }
  function unBindEvent() {
    const EVENT = rtcClient.EVENT;
    rtcClient.off(EVENT.REMOTE_VIDEO_ADD, remoteVideoAdd)
    rtcClient.off(EVENT.REMOTE_VIDEO_REMOVE, remoteVideoRemove)
    rtcClient.off(EVENT.SCREEN_SHARE_ADD, screenShareAdd)
    rtcClient.off(EVENT.SCREEN_SHARE_REMOVE, screenShareRemove)
    rtcClient.off(EVENT.TEACHER_ENTER, teacherEnter)
    rtcClient.off(EVENT.TEACHER_LEAVE, teacherLeave)
    rtcClient.off(EVENT.QUESTION_TIME_STARTED, questionTimeStarted)
    rtcClient.off(EVENT.QUESTION_TIME_STOPPED, questionTimeStopped)
    rtcClient.off(EVENT.BE_INVITED_TO_PLATFORM, invitedToPlatform)
    rtcClient.off(EVENT.ANSWERING_FINISHED, answerFinished)
    rtcClient.off(EVENT.ROOM_DESTROYED, roomDestroyed)
  }
  useEffect(() => {
    if(!isBegin) {//未开始上课或者结束上课
      clearData()
    }
    if(!isMic) {//本地没有麦克风
      setSpeakVisible(false)
    }
  }, [isBegin, isMic])
  useEffect(() => {
    bindEvent()
    return () => {
      clearData()
      unBindEvent()
    }
  }, [])
  return(
    <div>
        <Dialog
        title="授课已结束"
        closeOnClickModal = {false}
        size="small"
        visible={ courseEndVisible }
        onCancel={ () => {
          setCourseEndVisible(false);
          exitRoom()
        }}
        >
        <Dialog.Body>
        老师已经结束了授课，并解散了该课堂
        </Dialog.Body>
        <Dialog.Footer className="dialog-footer">
          <Button type="primary" onClick={ () => {setCourseEndVisible(false);exitRoom()} }>我知道了</Button>
        </Dialog.Footer>
      </Dialog>
      <Dialog
        title="可以发言了"
        closeOnClickModal = {false}
        size="tiny"
        visible={ speakVisible }
        onCancel={ () => {setSpeakVisible(false)}}>
        <Dialog.Body>
          老师请你上台发言，你可以面向麦克风发言啦
        </Dialog.Body>
        <Dialog.Footer className="dialog-footer">
          <Button type="primary" onClick={ () => setSpeakVisible(false) }>我知道了</Button>
        </Dialog.Footer>
      </Dialog>
    <div className="studentPage">
      <div className="iconButton studentIconButton">
      {studentSpeak ?
      <span><img style={{cursor: 'default'}} src={speakImg}/></span>
      :
      <span><img style={{cursor: 'default'}} src={noSpeakImg}/></span>
      }
      <span><img src={closeImg} onClick={exitRoom}/></span>
      </div>
      {isBegin ?
      <div className="courseBegin">
        {isShareAdd ?
        <div>
        <div id="studentScreenVideo"></div>
        <div id='localSub'></div>
        </div>
        : null}
        {isVideoAdd && !isShareAdd ?
        <div>
        <div id="studentFullVideo"></div>
        </div>
        : null}
        {isQaTime ?
        <div>
          {studentSpeak ?
          <div>
          <p className="handsTips" style={{color: '#0A818C'}}>正在发言...</p>
          <p className="hands" onClick={exitSpeak}>
            <span>退出</span>
          </p>
          </div>
          : <p className="hands" onClick={raiseHand}>
            <img src={handImg} />
          </p>}
          {isRaiseHand && !studentSpeak ?
          <p className="handsTips">等待老师同意...</p>
          : null}

        </div>
        : null }
        {!isVideoAdd && !isShareAdd ?
        <div className="studentCourseVoice">
          <img src={voiceGif} />
          <p style={{marginLeft: '-5px', marginTop: '-3px'}}>仅声音</p>
        </div>
        : null }
      </div>
      :
      <div className="courseNotBegin">
        <h3>等待老师开始授课</h3>
        <p>开始授课后，你才会接收到视频或声音信息</p>
      </div>
      }
    </div>
    </div>
  )
}
