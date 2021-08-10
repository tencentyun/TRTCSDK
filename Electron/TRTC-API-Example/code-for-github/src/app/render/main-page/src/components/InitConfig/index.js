import a18n from 'a18n'
import React, { useState } from 'react';
import rand from '@utils/rand';
import initConfigUtil from '@utils/init-config-util';
import './index.scss';

const Max_Room_Id = 4294967295;

function InitConfig(props) {
  if (!initConfigUtil.loadRoomId()) {
    initConfigUtil.storeRoomId(parseInt(rand(10000000)));
  }
  if (!initConfigUtil.loadLocalUserId()) {
    initConfigUtil.storeLocalUserId(rand(10000000, true));
  }
  
  const [roomId, setRoomId] = useState(initConfigUtil.loadRoomId());
  const [roomError, setRoomError] = useState(false);
  const [roomErrorMsg, setRoomErrorMsg] = useState('');
  const [userId, setUserId] = useState(initConfigUtil.loadLocalUserId());

  const handleRoomIdChange = (event) => {
    let value = window.parseInt(event.target.value);
    if (Number.isNaN(value)) {
      value = 0; 
      initConfigUtil.removeRoomId();
    } else {
      initConfigUtil.storeRoomId(value);
    }
    setRoomId(value);
  };

  const handleUserIdChange = (event) => {
    const value = event.target.value;
    setUserId(value);
    initConfigUtil.storeLocalUserId(value);
  };

  const validateRoomId = (event) => {
    const value = event.target.value;
    if(value < 1) {
      setRoomError(true);
      setRoomErrorMsg(a18n('房间号为大于零整数'));
    } else if (value > Max_Room_Id) {
      setRoomError(true);
      setRoomErrorMsg(a18n`房间号不能超过${Max_Room_Id}`);
    } else {
      setRoomError(false);
      setRoomErrorMsg(``);
    }
  }

  return (
    <div className="init-config">
      <form className="config-form">
        <div className={`form-line ${roomError ? 'error' : ''}`}>
          <label>{a18n('房间号：')}</label>
          <input
            placeholder={a18n('必填，数值类型，大于零整数')} 
            type="number"
            value={roomId}
            required
            min="1"
            max={Max_Room_Id}
            onInput={validateRoomId}
            onChange={handleRoomIdChange}
          />
          {
            roomErrorMsg && <div className="error-msg">{roomErrorMsg}</div>
          }
        </div>
        <div className={`form-line ${roomError ? 'error' : ''}`}>
          <label>{a18n('用户名：')}</label>
          <input
            placeholder={a18n('必填，字符类型，房间内须唯一')}
            type="text"
            value={userId}
            required
            maxLength="20"
            pattern="[\w\u4e00-\u9fa5]+"
            onChange={handleUserIdChange} />
        </div>
      </form>
    </div>
  );
}

export default InitConfig;