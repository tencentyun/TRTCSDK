import React, { useState, useEffect, useRef } from 'react';
import { Button, Message, Input } from 'element-react';
import '../css/chat.css'
let chatArr:any = []
export default function Chat(props: any) {
  const {rtcClient, classId, userID, nickName} = props;
  const EVENT = rtcClient.EVENT
  const chatRef = useRef(null)
  let [text, setText] = useState('');
  const [chatList, setChatList] = useState([]);
  function sendClassMessage() {
    let textValue = text;

    //@ts-ignore
    if(chatRef.current && chatRef.current.props && chatRef.current.props.value) {
      //@ts-ignore
      textValue = chatRef.current.props.value
    }
    if(!textValue) {
      Message({
        message: '请输入发送内容',
        type: 'warning'
      });
      return;
    }
    if(textValue.length > 100) {
      Message({
        message: '发送文本太长',
        type: 'warning'
      });
      return;
    }
    const params = {
      classId: classId,
      message: textValue
    }
    setText('');
    rtcClient.sendTextMessage(params).then(() => {
      chatArr.push({
        name: nickName ? userID + '-' + nickName : userID,
        message: textValue,
        isSelf: true
      })
      const newArr = chatArr.concat([])
      setChatList(newArr);
      const msgEnd:any = document.getElementById('msgEnd');
      msgEnd.scrollIntoView();
    }).catch(() => {
      Message({
        message: '发送失败，请重试',
        type: 'error'
      });
    })
  }
  function onMessageReceived(event: { data: any; }) {
    // event.data - 存储 Message 对象的数组 - [Message]
    const messageData = event.data
    messageData.map((item:any) => {
      if(item.conversationType === 'GROUP' && item.payload.text) {//群组消息
        chatArr.push({
          name: item.nick ? item.from + '-' + item.nick : item.from,
          message: item.payload.text,
          isSelf: false
        })
      }
    })
    const newArr = chatArr.concat([])
    setChatList(newArr);
    const msgEnd:any = document.getElementById('msgEnd');
    msgEnd && msgEnd.scrollIntoView();
  }

  useEffect(() => {
    rtcClient.on(EVENT.MESSAGE_RECEIVED, onMessageReceived);
    //注册键盘事件
    document.addEventListener('keypress', handleEnterKey)
    return () => {
      clearData()
    }
  }, [])
  function handleEnterKey(e: any) {
    if(e.keyCode === 13){ //e.nativeEvent获取原生的事件对像
      sendClassMessage();
      e.returnValue = false;
    }
  }
  function clearData() {
    rtcClient.off(EVENT.MESSAGE_RECEIVED, onMessageReceived);
    document.removeEventListener('keypress', handleEnterKey)
    chatArr = []
  }
  return (
    <div className='chat-message-container'>
      <div className = 'chat-message-content'>
        {
          chatList.map((item:any ,index: number) => {
            return (
              <div key = {index} className = {item.isSelf ? 'message sent' : 'message receive'}>
                <div className = 'nickname'>{item.name}</div>
                <div className = 'content'>{item.message}</div>
              </div>
            )
          })
        }
      <div id="msgEnd" style={{height:0,overflow:'hidden'}}></div>
      </div>
      <Input
      type="textarea"
      ref={chatRef}
      className='chat-input'
      rows={2}
      placeholder="说点什么"
      onChange={(text: any) => {setText(text);}}
      value={text}
      />
      <Button className='chat-button' type="primary" onClick={() => sendClassMessage()}>发送</Button>
      {/* <Input className='chat-input' value={text} placeholder="说点什么" onChange={(text: any) => {setText(text)}} append={<Button type="primary" onClick={() => sendClassMessage()}>发送</Button>} /> */}
    </div>
  )
}
