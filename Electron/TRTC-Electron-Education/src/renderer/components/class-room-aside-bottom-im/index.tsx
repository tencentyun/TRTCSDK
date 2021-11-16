import React, { useRef, useEffect, useState } from 'react';
import { trtcUtil } from '../../utils/trtc-edu-sdk/index';
import './index.scss';

function BottomIm(props: Record<string, any>) {
  const { messageList } = props;
  const [inputMsg, setInputMsg] = useState<string>('');
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const updateInputMsg = (event: {
    target: { value: React.SetStateAction<string> };
  }) => {
    setInputMsg(event.target.value);
  };

  function sendMessage() {
    if (inputMsg === '' || inputMsg === null || /^\s+$/gi.test(inputMsg)) {
      return;
    }
    trtcUtil.trtcEducation?.sendMessage(
      inputMsg,
      trtcUtil.trtcEducation.roomID
    );
    setInputMsg('');
  }
  const handleKeyDown = (event: any) => {
    if (event.key === 'Enter') {
      event.preventDefault();
      sendMessage();
    }
  };

  useEffect(() => {
    // @ts-ignore
    messagesEndRef.current.scrollIntoView(false); // 与底部对齐
  });

  return (
    <div className="im-content">
      <div className="content-top-chat">
        {messageList &&
          messageList.map((user: any, index: any) => {
            return (
              // eslint-disable-next-line react/no-array-index-key
              <div
                // eslint-disable-next-line react/no-array-index-key
                key={index}
                className={
                  user.userID === trtcUtil.trtcEducation?.userID
                    ? 'content-bottom-chat sent'
                    : 'content-bottom-chat receive'
                }
              >
                <div>{user.userID}</div>
                <div className="content-bottom-chat-out">
                  <span className="content-bottom-chat-inner">
                    {user.content}
                  </span>
                </div>
              </div>
            );
          })}
        <div ref={messagesEndRef} />
      </div>
      <div className="content-bottom-submit">
        <div className="content-bottom-feel" />
        <textarea
          value={inputMsg}
          onChange={updateInputMsg}
          onKeyDown={handleKeyDown}
          className="content-bottom-input"
          placeholder="请输入内容"
        />
      </div>
    </div>
  );
}

export default BottomIm;
