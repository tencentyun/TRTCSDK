import React, { useState, useEffect } from 'react';

import {Button, Dialog, Message, Radio, Icon } from 'element-react';

//@ts-ignore
import logoImg from '../imgs/logo.png'
//@ts-ignore
import cameraImg from '../imgs/camera.png'
//@ts-ignore
import cameraIcon from '../imgs/cameraIcon.png'
//@ts-ignore
import nocameraIcon from '../imgs/nocameraIcon.png'
//@ts-ignore
import screenImg from '../imgs/screen.png'
//@ts-ignore
import screenIcon from '../imgs/screenIcon.png'
//@ts-ignore
import noscreenIcon from '../imgs/noscreenIcon.png'
//@ts-ignore
import handImg from '../imgs/hand.png'
//@ts-ignore
import handHoverImg from '../imgs/handHoverImg.png'
//@ts-ignore
import voiceGif from '../imgs/voice.gif'
//@ts-ignore
import speakGif from '../imgs/speak.gif'
//@ts-ignore
import speakImg from '../imgs/speak.png'
//@ts-ignore
import noSpeakImg from '../imgs/noSpeak.png'
//@ts-ignore
import closeImg from '../imgs/close.png'
//@ts-ignore
import addImg from '../imgs/add.png'
//@ts-ignore
import cameraScreenIcon from '../imgs/cameraScreenIcon.png'

interface TeacherClassProps {
  rtcClient: any,
  classId: string,
  role: string,
  nickName: string
}
let initHandsList:[] = []
export default function TeacherClass(props: TeacherClassProps) {
  const {rtcClient, classId, role} = props;
  const [isBegin, setIsBegin] = useState(false);//是否开始上课
  const [screenVisible, setScreenVisible] = useState(false);
  const [courseType, setCourseType] = useState('voice');//授课方式
  const [exitCourseVisible, setExitCourseVisible] = useState(false);
  const [handsVisible, setHandsVisible] = useState(false);
  const [speakOpen, setSpeakOpen] = useState(true);
  const [screenOpen, setScreenOpen] = useState(false);
  const [cameraOpen, setCameraOpen] = useState(false);
  const [selectScreen, setSelectScreen] = useState({})
  const [screenList, setScreenList] = useState([]);
  const [handsUserList, setHandsUserList] = useState(initHandsList);

  const TRTCVideoResolution = rtcClient.TRTCVideoResolution;
  // 打开摄像头
  function openPreviewCamera() {
    const domEle = document.getElementById('teacherLocalVideo');
    rtcClient.openCamera(domEle);
  }
  //老师开始问答时间
  function startQuestionTime() {
    setHandsVisible(true);
    rtcClient.startQuestionTime(classId)
  }
  //获取屏幕分享列表
  function getScreenShareList() {
    const screenList = rtcClient.getScreenShareList();
    setScreenList(screenList);
    setScreenVisible(true);
    setTimeout(()=>{
      randerScrrenCapture(screenList);
    }, 500);
  }
  //渲染屏幕分享列表
  function randerScrrenCapture(screenList:any) {
    if (screenList.length === 0) {
      return;
    }
    let srcInfos = null;
    let elId = '';
    let cnvs = null;
    let imgData = null;

    for (let i = 0; i < screenList.length; i++) {
      srcInfos = screenList[i];
      if (!srcInfos['thumbBGRA']) continue;
      elId = `screen_${srcInfos['sourceId']}`;
      cnvs = document.getElementById(elId);
      // @ts-ignore
      cnvs.width = srcInfos['thumbBGRA']['width'];
      // @ts-ignore
      cnvs.height = srcInfos['thumbBGRA']['height'];
      imgData =  new ImageData(new Uint8ClampedArray(srcInfos['thumbBGRA']['buffer']), srcInfos['thumbBGRA']['width'],  srcInfos['thumbBGRA']['height'] );
      // @ts-ignore
      cnvs.getContext("2d").putImageData(imgData, 0, 0);
    }
  }

  //老师开始上课
  function startClass() {
    if(courseType === 'screen' || courseType === 'videoScreen') {
      //@ts-ignore
      if(!selectScreen['sourceId']) {
        Message('请选择屏幕分享的窗口')
        getScreenShareList()
        return
      }
      setTimeout(() => {
        //@ts-ignore
        onSelectScreenCapture(selectScreen['type'], selectScreen['sourceId'], selectScreen['sourceName'])
      }, 500)
    }
    closeCamera();
    rtcClient.enterRoom({
      role,
      classId
    })
    setSpeakOpen(true);
    setIsBegin(true);
    if(courseType === 'video') {
      setCameraOpen(true)
      setScreenOpen(false)
    } else if(courseType === 'videoScreen') {
      setCameraOpen(true)
      setScreenOpen(true)
    } else if(courseType === 'screen') {
      setCameraOpen(false)
      setScreenOpen(true)
    } else {
      setCameraOpen(false)
      setScreenOpen(false)
    }
  }
  // 关闭问答时间
  function stopQuestionTime() {
    initHandsList = []
    setHandsUserList([])
    setHandsVisible(false);
    rtcClient.stopQuestionTime(classId)
  }
  // 关闭屏幕分享
  function closeScreenShare() {
    rtcClient.stopScreenCapture()
    Message({
      message: '已关闭屏幕分享',
      type: 'success'
    });
  }

  // 关闭摄像头
  function closeCamera() {
    rtcClient.closeCamera();
  }

  function arrayUnique(arr:[], name:string) {
    let hash:any = {};
    return arr.reduce(function (item, next) {
      hash[next[name]] ? '' : hash[next[name]] = true && item.push(next);
      return item;
    }, []);
  }
  //邀请学生上台
  function inviteToPlatform(toUserID:string) {
    rtcClient.inviteToPlatform(toUserID).then(() => {
      Message({
        message: '邀请学生发言成功',
        type: 'success'
      });
    }).catch(() => {
      Message({
        message: '邀请学生发言失败',
        type: 'error'
      });
    });
  }
   //开始屏幕分享推拉流
   function onSelectScreenCapture(type: number, sourceId:string, sourceName: string) {
    rtcClient.stopScreenCapture();
    // sdk bug，停止采集屏幕分享后，不能马上开始新的屏幕分享推流，todo
    setTimeout(() => {
      rtcClient.startScreenCapture({
        type,
        sourceId,
        sourceName
      })
    }, 500)

    setScreenOpen(true);
    setScreenVisible(false);
    Message({
      message: '已开启屏幕分享，学生端会收到屏幕分享的画面',
      type: 'success'
    });
  }
  function finishAnswering(toUserID:string) {
    rtcClient.finishAnswering(toUserID).then(() => {
      const newList: any = handsUserList.filter((item: any) => {
        return item.userID != toUserID
      })
      setHandsUserList(newList)
      Message({
        message: '下台成功',
        type: 'success'
      });
    }).catch(() => {
      Message({
        message: '下台失败',
        type: 'error'
      });
    });
  }
  function clearData() {
    setSelectScreen({});
    setCourseType('voice');
    setIsBegin(false);
    setHandsVisible(false);
    initHandsList = []
    setHandsUserList([])
  }
  // 老师下课
  function exitRoom() {
    clearData()
    rtcClient.exitRoom(role, classId)
  }
  function studentRaiseHand(event: { data: { from: any; payload: any }; }) {
    let nickName = ''
    try {
      const payloadData = JSON.parse(event.data.payload.data);
      console.log('payloadData', payloadData)
      nickName = payloadData.nickName
    } catch(e) {}

    let listArr:any = initHandsList.concat([])
    listArr.push({
      userID: event.data.from,
      nick: nickName
    })
    listArr = arrayUnique(listArr, 'userID');
    initHandsList = listArr

    setHandsUserList(listArr);
  }
  function bindEvent() {
    const EVENT = rtcClient.EVENT;
    //学生举手事件
    rtcClient.on(EVENT.STUDENT_RAISE_HAND, studentRaiseHand)
  }
  function unBindEvent() {
    const EVENT = rtcClient.EVENT;
    rtcClient.off(EVENT.STUDENT_RAISE_HAND, studentRaiseHand)
  }
  useEffect(() => {
    closeCamera()
    if(cameraOpen && !screenOpen) {
      const domEle = document.getElementById('fullLocalVideo');
      rtcClient.openCamera(domEle, TRTCVideoResolution.TRTCVideoResolution_640_480);
    } else if(cameraOpen && screenOpen) {
      const domEle = document.getElementById('screenLocalVideo');
      rtcClient.openCamera(domEle);
    }
  }, [cameraOpen, screenOpen])
  useEffect(() => {
    bindEvent()
    return () => {
      clearData()
      unBindEvent()
    }
  }, [])
  return (
    <div>
      <Dialog
        title="确定结束授课？"
        closeOnClickModal = {false}
        size="tiny"
        visible={ exitCourseVisible }
        onCancel={ () => {
          setExitCourseVisible(false)
        }}
        >
        <Dialog.Body>
        下课后，学生无法看到您分享的画面和声音
        </Dialog.Body>
        <Dialog.Footer className="dialog-footer">
          <Button type="primary" onClick={ () =>  {exitRoom();setExitCourseVisible(false)}}>退出</Button>
          <Button onClick={ () => setExitCourseVisible(false) }>取消</Button>
        </Dialog.Footer>
      </Dialog>
      <Dialog
        title="请选择一个窗口进行共享"
        size="large"
        visible={ screenVisible }
        onCancel={ () => setScreenVisible(false) }
        lockScroll={ false }
      >
        <Dialog.Body>
          <div className="screenDialogBody">
          {
            screenList && screenList.map(item => {
              return <div className="screenDialogCard" key={item['sourceId']} onClick={()=> {
                setScreenVisible(false);
                if(isBegin) {
                  onSelectScreenCapture(item['type'], item['sourceId'], item['sourceName'])
                }
                setSelectScreen({type: item['type'], sourceId: item['sourceId'], sourceName: item['sourceName']})
              }}>
                <canvas id={'screen_' + item['sourceId']} width='192' height='120'></canvas>
                <div style={{ padding: 5 }}>
                  <div className="bottom clearfix">
                    <p style={{overflow: 'hidden', whiteSpace:'nowrap', textOverflow:'ellipsis'}}>{item['sourceName']}</p>
                  </div>
                </div>
              </div>
            })
          }
          </div>
        </Dialog.Body>
      </Dialog>
    <div className="teacherPage">
      {!isBegin ?
      <div className="teacherRoom">
      <h3>请选择授课方式</h3>
      <p>您可在上课期间随时调整授课方式</p>
      <div className="teacherPageContent">
        <div id="teacherLocalVideo">
          <div className="previewTip">摄像头预览</div>
        </div>
        <div className="teacherCard">
          <img src={cameraImg} width='50' height='50' className="image" />
          <img src={addImg} style={{verticalAlign: 'top', marginLeft: 10, marginRight: 10, paddingTop: 20}} width='15' height='15' className="image" />
          <img src={screenImg} width='50' height='50' className="image" />
          <div className="cardButton">
            <Radio value="videoScreen" checked={courseType === 'videoScreen'} onChange={(value:string) => {
              setCourseType(value)
              openPreviewCamera()
              getScreenShareList()
            }}>摄像头+屏幕分享</Radio>
          </div>
        </div>
        <div className="teacherCard screenCard">
          <img src={screenImg} width='50' height='50' className="image" />
          <div className="cardButton">
              <Radio value="screen" checked={courseType === 'screen'} onChange={(value:string) => {
                setCourseType(value)
                closeCamera()
                getScreenShareList()
              }}>屏幕分享</Radio>
          </div>
        </div>
        <div className="teacherCard cameraCard">
          <img src={cameraImg} width='50' height='50' className="image" />
          <div className="cardButton">
            <Radio value="video" checked={courseType === 'video'} onChange={(value:string) => {
              setCourseType(value);
              openPreviewCamera()}
            }>摄像头</Radio>
          </div>
        </div>
        <div className="teacherCard voiceCard">
          <img src={speakImg} width='50' height='50' className="image" />
          <div className="cardButton">
            <Radio value="voice" checked={courseType === 'voice'} onChange={(value:string) => {
              closeCamera()
              setCourseType(value)}
              }>仅声音</Radio>
          </div>
        </div>
        {!isBegin ?
        <Button className="courseButton" type="primary"  onClick={startClass}>开始授课</Button>
        : null}
        {isBegin ?
        <Button className="courseButton" type="primary" onClick={() => setExitCourseVisible(true)}>下课</Button>
        : null }
      </div>
      </div>
      : null}
      {isBegin ?
      <div>
        <div className="iconButton">
          {cameraOpen ?
          <span><img src={cameraIcon} onClick={() => {closeCamera();setCameraOpen(false)}}/></span>
          : <span><img src={nocameraIcon} onClick={() => {
            setCameraOpen(true)
            }}/></span>}
          {screenOpen ?
          <span><img src={screenIcon} onClick={() => {
            setScreenOpen(false);
            closeScreenShare()
          }}/></span>
          : <span><img src={noscreenIcon} onClick={() => {
            //@ts-ignore
            if(selectScreen['sourceId']) {
              //@ts-ignore
              onSelectScreenCapture(selectScreen['type'], selectScreen['sourceId'], selectScreen['sourceName'])
            } else {
              getScreenShareList()
            }
          }}/></span>}
          <span><img src={cameraScreenIcon} onClick={() => {
            getScreenShareList()
          }}/></span>
          {speakOpen ?
          <span><img src={speakImg} onClick={()=> {rtcClient.closeMicrophone();setSpeakOpen(false)}} /></span>
          :
          <span><img src={noSpeakImg} onClick={()=> {rtcClient.openMicrophone();setSpeakOpen(true)}} /></span>
          }
          <span><img src={closeImg} onClick={() => setExitCourseVisible(true)}/></span>
        </div>
        {handsVisible ?
        <div className="handsList">
          <span onClick = {() => stopQuestionTime()} className="closeHands">
            <Icon name='close' />
          </span>
          <h4>举手列表</h4>
          <ul>
          {handsUserList && handsUserList.map(item => {
            const usernick = item['nick'] ? item['userID'] + '-' + item['nick'] : item['userID']
            return (
            <li key={item['userID']} style={{position:'relative'}}>
              <span className="userInfo" title={usernick}>{usernick}</span>
              <span onClick={() => inviteToPlatform(item['userID'])} style={{position:'absolute',right:35,cursor: 'pointer'}}>上台</span>
              <span onClick={() => finishAnswering(item['userID'])} style={{position:'absolute',right:0, cursor: 'pointer'}}>下台</span>
            </li>
            )
          })}
          </ul>
          {handsUserList.length === 0 ? <p>暂无人举手</p> : null}
        </div>
        : null}
        <p className="hands" onClick={startQuestionTime}><img src={handImg} /></p>

        {speakOpen && !cameraOpen && !screenOpen ?
        <div className="courseVoice">
          <img src={speakImg} />
          <p style={{marginLeft: '-20px', marginTop: 0}}>仅声音</p>
          <img style={{marginLeft: '-10px', marginTop: 0}} src={speakGif}/>
        </div>
        :null}
        {/* 开启屏幕分享，没开摄像头 */}
        {screenOpen && !cameraOpen ?
        <div className="courseScreen">
          <div id="screenLocalVideo"></div>
          <p>您当前正在屏幕分享，此处学生看到的是屏幕分享的画面</p>
        </div>
        :null}
        {/* 开启摄像头，没开屏幕分享 */}
        {!screenOpen && cameraOpen ?
          <div id="fullLocalVideo">
          </div>
        :null}
        {/* 开启摄像头，开屏幕分享 */}
        {screenOpen && cameraOpen ?
        <div className="courseScreen">
          <div id="screenLocalVideo"></div>
          <p>您当前正在屏幕分享，此处学生看到的是屏幕分享的画面</p>
        </div>
        :null}
      </div>
      : null}
    </div>
    </div>
  )
}
