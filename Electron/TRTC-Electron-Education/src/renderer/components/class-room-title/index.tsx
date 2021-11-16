import React, { useEffect, useState } from 'react';
import { trtcUtil } from 'renderer/utils/trtc-edu-sdk';
import Time from '../class-room-title-time/index';
import { USER_EVENT_NAME } from '../../../constants';
import './index.scss';

function ClassTitle(props: Record<string, any>) {
  const { enterRoomTime } = props;
  const [owner, setOwner] = useState('');
  const ownerHandler = (event: { data: string; eventCode: string }) => {
    setOwner(event.data);
  };

  useEffect(() => {
    trtcUtil.trtcEducation?.emitter.on(
      USER_EVENT_NAME.ON_OWNER_READY,
      ownerHandler,
      null
    );
    return () => {
      trtcUtil.trtcEducation?.emitter.off(
        USER_EVENT_NAME.ON_OWNER_READY,
        ownerHandler
      );
    };
  }, []);

  return (
    <div className="trtc-edu-class-room-title">
      {owner}发起的在线课堂{trtcUtil.trtcEducation?.roomID}｜ 已上课{' '}
      <Time enterRoomTime={enterRoomTime} />
    </div>
  );
}

export default ClassTitle;
